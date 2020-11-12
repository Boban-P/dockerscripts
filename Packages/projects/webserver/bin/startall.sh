#!/bin/bash


# Start/stop all services.

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
        postfix start 172.17.0.1:25
        dnsmasq start 172.17.0.1:53
        db start 172.17.0.1:3306
        app start -d 172.17.0.1 -m 172.17.0.1 -n 172.17.0.1 172.17.0.1:
        web start "$(app url 0)" 172.17.0.1:
        balancer start "$(web url 0)" 172.17.0.1
        ;;
esac
