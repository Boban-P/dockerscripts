#!/bin/bash
#!/bin/bash

address=""
LOGFILE=${LOGFILE:-/var/log/dnsmasq.log}

if [[ -n ${HOST_MAP} ]]; then
    for entry in ${HOST_MAP}
    do
        ip=${entry%=*}
        domain=${entry#*=}
        address="${address}\naddress=/${domain}/${ip}"
    done
fi
args=(-e "s@address=/host/ip@${address}@" -e "s@log-facility=/var/log/dnsmasq.log@log-facility=${LOGFILE}@")
if [[ (-n "${HOST_ALLOWED}" ) && (-n "${SERVER}") ]]; then
    args+=(-e "s@server=/sites/nsip@server=/$(printf "%s/" ${HOST_ALLOWED})${SERVER}@")
else
    args+=(-e "/server=\/sites\/nsip/d")
fi

sed -i "${args[@]}" /etc/dnsmasq.conf

exec "$@"
