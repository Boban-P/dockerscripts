FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   ca-certificates \
                   ssl-cert \
                   procps \
    && echo "deb https://deb.debian.org/debian buster-backports main" >>/etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -t buster-backports install -y --no-install-recommends \
                   apache2 \
    && rm -rf /var/lib/apt/lists/*


# default values; see:startup.sh
# when extending add/change these values as required.
# special env variable.
# SITE_NAME: fully qualified domain name.
# SITE_ALIAS: site alias to be used in virtualhost file.
# DOCUMENT_ROOT: the document root.
# SSL_ON: set 1 to enable ssl,
# ENABLE_MODE_${mode_name}: modules to enable, will execute a2enmod ${mode_name}
# ENABLE_CONF_${conf_name}: configurations to enable, will execute a2enconf ${conf_name}

# additionally when starting the container, env can be set/modified.
# startup.sh will recognize this and configure the server accordingly.

# ENV LISTEN_PORT=80 \
#     LISTEN_SSLPORT=443 \
#     SITE_NAME=localhost \
#     SITE_ALIAS= \
#     SITE_ADMIN=webmaster@localhost \
#     SSL_ON=0 \
#     CONFIG_TYPE=balancer|phpapp|pythonapp
#     APP_BALANCER_URL=127.0.0.1:5555 \
#     APP_ENVIRONMENT="development" \
#     CHILD_BALANCER_URL=127.0.0.1:8080 \
#     DOCUMENT_ROOT= \
#     SITE_LOG_LEVEL=warn \
#     SSL_ONLY=0 \
#     TRUSTED_PROXY="" \
#     SERVER_SIGNATURE="Off" \
#     SERVER_TOKEN="Prod" \
#     TRACE_ENABLE="Off" \
#     ACME_ENABLE=0 \
#     ACME_PROVIDER=letsencrypt|letsencrypt-staging(default)|https://url.to.certificat/provider/path
#     PATH_ALIASES=location=path,location2=path2


COPY data /

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]

CMD ["apachectl" , "-D", "FOREGROUND"]
