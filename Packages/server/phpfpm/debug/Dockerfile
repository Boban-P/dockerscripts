FROM bb526/server:phpfpm

LABEL maintainer="Boban Pulinchery <boban@ecodiver.in>"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	           php-xdebug \
    && rm -rf /var/lib/apt/lists/*

# configure xdebug
COPY data /

# ADD xdebug port as env variable
ENV REMOTE_DEBUG_PORT=9000
