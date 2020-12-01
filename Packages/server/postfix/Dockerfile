FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   postfix \
                   ca-certificates \
                   procps \
    && rm -rf /var/lib/apt/lists/*


# default values; see:startup.sh
# when extending change these values as required.

# ENV PROTOCOLS= \
#     HOST_NAME= \
#     DESTINATION= \
#     BANNER= \
#     RELAY= \
#     RELAY_DOMAINS= \
#     PORT= \
#     USER= \
#     PASSWORD= \
#     MAIL_LOG=/dev/stdout \
#     KEY_FILE=PATH/TO/KEY from /etc/postfix/certs\
#     CERT_FILE=PATH/TO/CERT from /etc/postfix/certs\

COPY data /

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]

CMD ["/usr/sbin/postfix","start-fg"]
