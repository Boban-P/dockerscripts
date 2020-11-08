FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   dnsmasq \
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

# SERVER: DNS server to which the query to forward.
# HOST_ALLOWED: allowed hosts to query /host[/host...]
# HOST_MAP: static host to ip map "ipaddress=hostname ipaddress2=hostname2"
# LOGFILE: file to log queries.
# SERVER_PORT: port at which dnsmasq listen.

ENV SERVER=8.8.8.8 \
    HOST_ALLOWED="/google.com/amazon.in" \
    HOST_MAP="127.0.0.1=myhost 127.0.0.1=myhost2" \
    LOGFILE=/var/log/dnsmasq.log


COPY startup.sh dnsmasq.conf  /

ENTRYPOINT ["/startup.sh"]

CMD ["dnsmasq" , "--no-daemon", "--no-resolv"]
