FROM debian:stable

LABEL maintainer="Boban Pulichery <boban@ecodiver.in>"


RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        easy-rsa openssl


COPY startup.sh /

# env vars
ENV COUNTRY='IN' \
    CA_EXPIRE_DAYS=3650 \
    CERT_EXPIRE_DAYS=1080 \
    DIGEST=sha512 \
    ALGORITHM=ec \
    KEY_SIZE=2048 \
    CERT_TYPE=CA
    # SUB_CA_NAME
    # PROVINCE=
    # CITY=
    # ORG=
    # EMAIL=
    # UNIT=
    # CN=
    # ALT_NAMES=DNS:domain,DNS:domain2

VOLUME [ "/easyrsa" ]

ENTRYPOINT [ "/startup.sh" ]
