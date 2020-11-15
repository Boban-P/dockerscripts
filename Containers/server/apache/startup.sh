#!/bin/bash

#################
# DEFAULT VALUES#
#################
LISTEN_PORT=${LISTEN_PORT:-80}
LISTEN_SSLPORT=${LISTEN_SSLPORT:-443}
SITE_NAME=${SITE_NAME:-localhost}
# SITE_ALIAS=
SITE_ADMIN=${SITE_ADMIN:-"webmaster@${SITE_NAME}"}
SSL_ON=${SSL_ON:-0}
ENABLE_MODE_balancer=${ENABLE_MODE_balancer:-0}
export ENABLE_MODE_rewrite=${ENABLE_MODE_rewrite:-1}
PHP_BALANCER_URL=${PHP_BALANCER_URL:-"127.0.0.1:5555"}
PHP_ENVIRONMENT=${PHP_ENVIRONMENT:-"development"}
CHILD_BALANCER_URL=${CHILD_BALANCER_URL:-"127.0.0.1:8080"}
# DOCUMENT_ROOT=
SITE_LOG_LEVEL=${SITE_LOG_LEVEL:-warn}
SSL_ONLY=${SSL_ONLY:-0}
# TRUSTED_PROXY=""
# On | Off | EMail
SERVER_SIGNATURE=${SERVER_SIGNATURE:-"Off"}
# Full | OS | Minimal | Minor | Major | Prod
SERVER_TOKEN=${SERVER_TOKEN:-"Prod"}
# Set to one of:  On | Off | extended
TRACE_ENABLE=${TRACE_ENABLE:-"Off"}
# Set to one of: production | staging
# ACME_ENABLE=0 \
# ACME_PROVIDER=letsencrypt|letsencrypt-staging(default)|https://url.to.certificat/provider/path
if [[ -n "${ACME_PROVIDER}" ]];then
    ACME_ENABLE=1
fi

a2dissite 000-default >/dev/null

sed -i -e "s/Listen 80/Listen ${LISTEN_PORT}/" -e "s/Listen 443/Listen ${LISTEN_SSLPORT}/" /etc/apache2/ports.conf
echo "ServerName ${SITE_NAME}" >>/etc/apache2/apache2.conf

# enable new modules
modules=()
for line in $(env | grep -e '^ENABLE_MODE_'); do
    data=${line#ENABLE_MODE_}
    name=${data%=*}
    if [[ (-n ${data#*=}) && (${data#*=} != "0") ]]; then
        case $name in
            "balancer")
                modules+=(proxy_balancer lbmethod_byrequests remoteip)
                if [[ ( -n "${DOCUMENT_ROOT}" ) && ( -n "${PHP_BALANCER_URL}" ) ]]; then
                    modules+=(proxy_fcgi)
                else
                    modules+=(proxy_http)
                fi
                ;;
            *)
                modules+=("$name")
        esac
    fi
done

if [[ "${SSL_ON:-0}" != "0" ]]; then
    modules+=(ssl md)
fi

if [[ ${#modules[@]} -gt 0 ]]; then
    a2enmod "${modules[@]}" >/dev/null
fi

# enable new configurations
confs=()
for line in $(env | grep -e '^ENABLE_CONF_'); do
    data=${line#ENABLE_CONF_}
    if [[ (-n ${data#*=}) && (${data#*=} != "0") ]]; then
        confs+=("${data%=*}")
    fi
done

if [[ ${#confs[@]} -gt 0 ]]; then
    a2enconf "${confs[@]}" >/dev/null
fi

if [[ -n "${TRUSTED_PROXY}" ]]; then
    TRUSTED_PROXY_STRING="RemoteIPTrustedProxy ${TRUSTED_PROXY}"
fi

# SECURITY
# Set to one of:  Full | OS | Minimal | Minor | Major | Prod
# ServerTokens ${SERVER_TOKEN}
# Set to one of:  On | Off | EMail
# ServerSignature ${SERVER_SIGNATURE}
# Set to one of:  On | Off | extended
# TraceEnable ${TRACE_ENABLE}
sed -i -e 's/^ServerTokens .*$/ServerTokens '"${SERVER_TOKEN}/" \
    -e 's/^ServerSignature .*$/ServerSignature '"${SERVER_SIGNATURE}/" \
    -e 's/^TraceEnable .*$/TraceEnable '"${TRACE_ENABLE}/" \
    /etc/apache2/conf-available/security.conf

# A node balancer do not have document root enabled.
# IF document root is enabled and php backend exists
# then php node balancer is enabled.
BALANCER=""
if [[ "${ENABLE_MODE_balancer:-0}" == "1" ]]; then
    if [[ -n "${PHP_ENVIRONMENT}" ]]; then
        envset='SetEnv ENVIRONMENT "'"${PHP_ENVIRONMENT}"'"'
    else
        envset=""
    fi

    if [[ ( -n "${DOCUMENT_ROOT}" ) && ( -n "${PHP_BALANCER_URL}" )]]; then
        BALANCER="     RemoteIPHeader X-Forwarded-For
                 ${TRUSTED_PROXY_STRING}
    <Proxy \"balancer://phpcluster\">
#PHPBALANCER        BalancerMember \"fcgi://BALANCER_URL\"
    </Proxy>
    # ProxyPassMatch not working with balancer.
    # https://stackoverflow.com/a/41339419
    #ProxyPassMatch ^/(.*\.php)$ balancer://phpcluster${DOCUMENT_ROOT%/}/\$1
    <FilesMatch \.php$>
        ${envset}
        SetEnv HTTPS on
        SetHandler \"proxy:balancer://phpcluster\"
    </FilesMatch>
"
    else
        BALANCER="    RemoteIPHeader X-Client-IP
    <Proxy \"balancer://childcluster\">
#CHILDBALANCER           BalancerMember \"http://BALANCER_URL\"
    </Proxy>
    ProxyPass        \"/\" \"balancer://childcluster/\"
    ProxyPassReverse \"/\" \"balancer://childcluster/\"
"
    fi
fi

if [[ -n "${DOCUMENT_ROOT}" ]]; then
    DOCUMENT_ROOT="
    DocumentRoot \"${DOCUMENT_ROOT}\"
    <Directory \"${DOCUMENT_ROOT}\">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
"
fi

if [[ -n "${SITE_ALIAS}" ]]; then
    SITE_ALIAS="ServerAlias ${SITE_ALIAS}"
else
    SITE_ALIAS='# ServerAlias'
fi

# VirtualHost skeleton

VHOST_CONF="    ServerName ${SITE_NAME}
    ${SITE_ALIAS}
    ServerAdmin ${SITE_ADMIN}
${DOCUMENT_ROOT}
${BALANCER}
    LogLevel ${SITE_LOG_LEVEL}
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined"

hostfile="
<VirtualHost *:${LISTEN_PORT}>
${VHOST_CONF}
</VirtualHost>
"

if [[ "${SSL_ON:-0}" != "0" ]]; then

    if [[ -n "${ACME_ENABLE//0/}" ]]; then
        case "${ACME_PROVIDER:-letsencrypt-staging}" in
            letsencrypt|default)
                ;;
            letsencrypt-staging)
                CERTIFICATE_AUTHORITY="MDCertificateAuthority https://acme-staging-v02.api.letsencrypt.org/directory"
                ;;
            *)
                CERTIFICATE_AUTHORITY="MDCertificateAuthority ${ACME_PROVIDER}"
                ;;
        esac
        ACME_CONF="ServerAdmin ${SITE_ADMIN}
MDCertificateAgreement accepted
MDomain ${SITE_NAME}
MDPrivateKeys RSA 4096
${CERTIFICATE_AUTHORITY:-"# "}
MDStoreDir /etc/apache2/md

## Turn on OCSP Stapling ##
SSLUseStapling On
SSLStaplingCache \"shmcb:logs/ssl_stapling\"

## md status
<Location \"/md-status\">
    SetHandler md-status
</Location>
"
        SSLEngine_CONF="       SSLEngine on"
    else
        if [[ (! -f "/etc/apache2/ssl/${SITE_NAME}.pem") || (! -f "/etc/apache2/ssl/${SITE_NAME}.key") ]];then
            mkdir -p /etc/apache2/ssl
            cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/apache2/ssl/"${SITE_NAME}.pem"
            cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/apache2/ssl/"${SITE_NAME}.key"
        fi
        SSLEngine_CONF="
     SSLEngine on
     SSLCertificateFile	/etc/apache2/ssl/${SITE_NAME}.pem
     SSLCertificateKeyFile   /etc/apache2/ssl/${SITE_NAME}.key
       "
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

    hostfile="${ACME_CONF}${hostfile}
<VirtualHost *:${LISTEN_SSLPORT}>
${VHOST_CONF}
${SSLEngine_CONF}
    <FilesMatch \"\\.(cgi|shtml|phtml|php)$\">
        SSLOptions +StdEnvVars
    </FilesMatch>
</VirtualHost>
"
fi


# Do for ssl.


# Add php balancer node
if [[ -n "${PHP_BALANCER_URL}" ]];then
    hostfile=$(sed 's%#PHPBALANCER\(.*\)\(BalancerMember "fcgi://\)\(BALANCER_URL\)\(.*\)%\1\2'"${PHP_BALANCER_URL}"'\4\n#PHPBALANCER\1\2\3\4%' <<< "${hostfile}")
fi

if [[ -n "${CHILD_BALANCER_URL}" ]]; then
    hostfile=$(sed 's%#CHILDBALANCER\(.*\)\(BalancerMember "http://\)\(BALANCER_URL\)\(.*\)%\1\2'"${CHILD_BALANCER_URL}"'\4\n#CHILDBALANCER\1\2\3\4%' <<< "${hostfile}")
fi

cat <<< "${hostfile}" >/etc/apache2/sites-enabled/default.conf

exec "$@"
