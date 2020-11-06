#!/bin/bash

a2dissite 000-default >/dev/null

sed -i -e "s/Listen 80/Listen ${LISTEN_PORT}/" -e "s/Listen 443/Listen ${LISTEN_SSLPORT}/" /etc/apache2/ports.conf
echo "ServerName ${SITE_NAME}" >>/etc/apache2/apache2.conf

# enable new modules
modules=()
for line in $(env | grep -e '^ENABLE_MODE_'); do
    data=${line#ENABLE_MODE_}
    if [[ (! -z ${data#*=}) && (${data#*=} != "0") ]]; then
        modules+=(${data%=*})
    fi
done

if [[ "${SSL_ON:-0}" != "0" ]]; then
    modules+=(ssl)
fi

if [[ "${ENABLE_MODE_balancer:-0}" != "0" ]]; then
    modules+=(proxy_balancer lbmethod_byrequests)
    if [[ ( ! -z "${DOCUMENT_ROOT}" ) && ( ! -z "${PHP_BALANCER_URL}" ) ]]; then
        modules+=(proxy_fcgi)
    else
        modules+=(proxy_http)
    fi
fi

if [[ ${#modules[@]} -gt 0 ]]; then
    a2enmod "${modules[@]}" >/dev/null
fi

# enable new configurations
confs=()
for line in $(env | grep -e '^ENABLE_CONF_'); do
    data=${line#ENABLE_CONF_}
    if [[ (! -z ${data#*=}) && (${data#*=} != "0") ]]; then
        confs+=(${data%=*})
    fi
done

if [[ ${#confs[@]} -gt 0 ]]; then
    a2enconf "${confs[@]}" >/dev/null
fi

# A node balancer do not have document root enabled.
# IF document root is enabled and php backend exists
# then php node balancer is enabled.
BALANCER=""
if [[ "${ENABLE_MODE_balancer:0}" == "1" ]]; then

    if [[ ( ! -z "${DOCUMENT_ROOT}" ) && ( ! -z "${PHP_BALANCER_URL}" )]]; then
        BALANCER="
     <Proxy \"balancer://phpcluster\">
#PHPBALANCER                     BalancerMember \"fcgi://BALANCER_URL\"
     </Proxy>
     # ProxyPassMatch not working with balancer.
     # https://stackoverflow.com/a/41339419
     #ProxyPassMatch ^/(.*\.php)$ balancer://phpcluster${DOCUMENT_ROOT%/}/\$1
     <FilesMatch \.php$>
                 SetHandler \"proxy:balancer://phpcluster\"
     </FilesMatch>
"
    else
        BALANCER="
     <Proxy \"balancer://childcluster\">
#CHILDBALANCER           BalancerMember \"http://BALANCER_URL\"
     </Proxy>
     ProxyPass        \"/\" \"balancer://childcluster/\"
     ProxyPassReverse \"/\" \"balancer://childcluster/\"
"
    fi
fi

if [[ ! -z "${DOCUMENT_ROOT}" ]]; then
    DOCUMENT_ROOT="
    DocumentRoot \"${DOCUMENT_ROOT}\"
    <Directory \"${DOCUMENT_ROOT}\">
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Require all granted
    </Directory>
"
fi

if [[ ! -z "${SITE_ALIAS}" ]]; then
    SITE_ALIAS="ServerAlias ${SITE_ALIAS}"
fi

# VirtualHost skeleton

VHOST_CONF="
ServerName ${SITE_NAME}
${SITE_ALIAS}
ServerAdmin ${SITE_ADMIN}

${DOCUMENT_ROOT}
${BALANCER}

LogLevel ${SITE_LOG_LEVEL}
ErrorLog \${APACHE_LOG_DIR}/error.log
CustomLog \${APACHE_LOG_DIR}/access.log combined

"

hostfile="
<VirtualHost *:${LISTEN_PORT}>
${VHOST_CONF}
</VirtualHost>
"

if [[ "${SSL_ON:-0}" != "0" ]]; then
    if [[ ! -d /etc/apache2/ssl ]]; then
        mkdir -p /etc/apache2/ssl
        cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/apache2/ssl/${SITE_NAME}.pem
        cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/apache2/ssl/${SITE_NAME}.key
    fi
    
    if [[ "${SSL_ONLY:-0}" != "0" ]]; then
        hostfile="
<VirtualHost *:${LISTEN_PORT}>
             ServerName ${SITE_NAME}
             ${SITE_ALIAS}
             ServerAdmin ${SITE_ADMIN}
             Redirect permanent / https://${SITE_NAME}/
</VirtualHost>
"
    fi
    
    hostfile=${hostfile}"
<VirtualHost *:${LISTEN_SSLPORT}>
${VHOST_CONF}
        SSLEngine on
        SSLCertificateFile	/etc/apache2/ssl/${SITE_NAME}.pem
        SSLCertificateKeyFile   /etc/apache2/ssl/${SITE_NAME}.key
        <FilesMatch \"\\.(cgi|shtml|phtml|php)$\">
	            SSLOptions +StdEnvVars
        </FilesMatch>
</VirtualHost>
"
fi


# Do for ssl.


# Add php balancer node
if [[ ! -z "${PHP_BALANCER_URL}" ]];then
    hostfile=$(sed 's%#PHPBALANCER\(.*\)\(BalancerMember "fcgi://\)\(BALANCER_URL\)\(.*\)%\1\2'${PHP_BALANCER_URL}'\4\n#PHPBALANCER\1\2\3\4%' <<< ${hostfile})
fi

if [[ ! -z "${CHILD_BALANCER_URL}" ]]; then
    hostfile=$(sed 's%#CHILDBALANCER\(.*\)\(BalancerMember "http://\)\(BALANCER_URL\)\(.*\)%\1\2'${CHILD_BALANCER_URL}'\4\n#CHILDBALANCER\1\2\3\4%' <<< ${hostfile})
fi

cat <<< ${hostfile} >/etc/apache2/sites-enabled/default.conf

exec "$@"
