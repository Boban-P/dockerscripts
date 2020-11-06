FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   apache2 \
                   procps \
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

ENV LISTEN_PORT=80 \
    LISTEN_SSLPORT=443 \
    SITE_NAME=localhost \
    SITE_ALIAS= \
    SITE_ADMIN=webmaster@localhost \
    SSL_ON=0 \
    ENABLE_MODE_balancer=0 \
    ENABLE_MODE_rewrite=1 \
    PHP_BALANCER_URL=127.0.0.1:5555 \
    CHILD_BALANCER_URL=127.0.0.1:8080 \
    DOCUMENT_ROOT= \
    SITE_LOG_LEVEL=warn \
    SSL_ONLY=0


COPY startup.sh phpBalancer.sh childBalancer.sh /

ENTRYPOINT ["/startup.sh"]

CMD ["apachectl" , "-D", "FOREGROUND"]

