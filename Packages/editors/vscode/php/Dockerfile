FROM bb526/vscode:latest

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

ARG PHP_VERSION=7.3

USER root

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
    && rm -rf /var/lib/apt/lists/*

USER developer
