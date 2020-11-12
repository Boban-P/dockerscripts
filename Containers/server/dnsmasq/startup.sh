#!/bin/bash
#!/bin/bash

address=""

if [[ -n ${HOST_MAP} ]]; then
    for entry in ${HOST_MAP}
    do
        ip=${entry%=*}
        domain=${entry#*=}
        address="${address}\naddress=/${domain}/${ip}"
    done
fi

sed \
    -e "s@server=/sites/nsip@server=${HOST_ALLOWED}/${SERVER}@" \
    -e "s@address=/host/ip@${address}@" \
    -e "s@log-facility=/var/log/dnsmasq.log@log-facility=${LOGFILE}@" \
    /dnsmasq.conf > /etc/dnsmasq.conf

exec "$@"
