#!/bin/bash


# Start/stop all services.
ip=""
publicip=""
args=()
sitename=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --ip)
            ip=${2}
            shift
            shift
            ;;
        --public)
            publicip=${2}
            shift
            shift
            ;;
        --sitename)
            sitename+=("--sitename" "${2}")
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

if [[ -z "${publicip}" ]]; then
    publicip=${ip}
fi


case "$1" in
    stop)
        balancer stop
        web stop
        app stop
        db stop
        dns stop
        mail stop
        ;;
    stopall)
        balancer stop
        web stopall
        app stopall
        db stop
        dns stop
        mail stop
        ;;
    *)
        mail --publiship ${ip} --port 25 start
        dns --publiship ${ip} --port 53 start
        db --publiship ${ip} --port 3306 start
        app --db ${ip} --dns ${ip} --mail ${ip} --publiship ${ip} start
        web --app "$(app url 0)" --publiship "${ip}" --trust "${publicip}" start
        balancer --node "$(web url 0)" --publiship "${publicip}" start
        ;;
esac
