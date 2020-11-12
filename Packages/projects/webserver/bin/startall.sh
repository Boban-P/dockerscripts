#!/bin/bash


# Start/stop all services.
ip=""
args=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --ip)
            ip=${2}
            shift
            shift
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

set -- "${args[@]}"

if [[ -z "${ip}" ]]; then
    ip=172.17.0.1
fi


case "$1" in
    stop)
        balancer stop
        web stop
        app stop
        db stop
        dnsmasq stop
        postfix stop
        ;;
    stopall)
        balancer stop
        web stopall
        app stopall
        db stop
        dnsmasq stop
        postfix stop
        ;;
    *)
        postfix start ${ip}:25
        dnsmasq start "${ip}":53
        db start "${ip}":3306
        app start -d "${ip}" -m "${ip}" -n "${ip}" "${ip}":
        web start "$(app url 0)" "${ip}":
        balancer start "$(web url 0)" "${ip}"
        ;;
esac
