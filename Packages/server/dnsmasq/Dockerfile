FROM debian:stable

MAINTAINER Boban Pulinchery <boban@ecodiver.in>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                   dnsmasq \
                   procps \
    && rm -rf /var/lib/apt/lists/*

# ENVIRONMENT VARIABLES:
# SERVER: DNS server to which the query to forward.
# HOST_ALLOWED: allowed hosts to query to dns server, space seperated list
# HOST_MAP: static host to ip map like "ipaddress=hostname ipaddress2=hostname2"
# LOGFILE: file to log queries.



COPY data/  /

ENTRYPOINT ["/usr/sbin/startup.sh"]

CMD ["dnsmasq" , "--no-daemon", "--no-resolv"]
