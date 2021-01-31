FROM debian:stable

LABEL maintainer='Boban Pulinchery <boban@ecodiver.in>'


ARG PHP_VERSION=7.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	           php${PHP_VERSION}-fpm \
	           php${PHP_VERSION}-mysql \
	           php${PHP_VERSION}-pdo \
	           php${PHP_VERSION}-gd \
	           php${PHP_VERSION}-bcmath \
	           php${PHP_VERSION}-json \
	           php${PHP_VERSION}-curl \
	           php${PHP_VERSION}-ldap \
	           php${PHP_VERSION}-mbstring \
	           php${PHP_VERSION}-soap \
	           php${PHP_VERSION}-sqlite3 \
	           php${PHP_VERSION}-xml \
	           php${PHP_VERSION}-zip \
	           php${PHP_VERSION}-intl \
	           php${PHP_VERSION}-imagick \
			   libfcgi-bin \
               msmtp \
               procps \
               ca-certificates \
    && (ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm || true) \
    && rm -rf /var/lib/apt/lists/*

RUN echo "PHP_VERSION=${PHP_VERSION}" >>/phpversion.conf


# default values; see:startup.sh
# when extending change these values as required.

ENV FILE_UPLOAD=On \
    URL_FOPEN=On \
    MEMMORY_LIMIT=512M \
    MAX_EXECUTION_TIME=240 \
    MAX_FILE_UPLOAD_SIZE=200M \
    MAX_POST_SIZE=400M \
    MAX_INPUT_VARS=1500 \
    LISTEN_PORT=80
#    MAIL_FORWARD_HOST=smtp.google.com \
#    MAIL_PASSWORD= \
#    MAIL_USER= \
#    FROM_MAIL_ADDRESS=no-replay@example.com \
#    DNS_SERVER=127.0.0.1

COPY data /

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]

CMD ["/usr/sbin/php-fpm", "-F"]
