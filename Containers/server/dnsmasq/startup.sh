#!/bin/bash
#!/bin/bash

address=""

if [[ ! -z ${HOST_MAP} ]]; then
    for entry in ${HOST_MAP}
    do
        ip=${entry%=*}
        domain=${entry#*=}
        address="${address}"'\n'address=/${domain}/${ip}
    done
fi

cat /dnsmasq.conf | sed \
                            -e "s@server=/sites/nsip@server=${HOST_ALLOWED}/${SERVER}@" \
                            -e "s@address=/host/ip@""${address}"@ \
                            -e "s@log-facility=/var/log/dnsmasq.log@log-facility=${LOGFILE}@" \
                            >/etc/dnsmasq.conf

exec "$@"
