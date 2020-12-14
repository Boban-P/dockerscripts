#!/bin/bash

# Add or remove child balancer


case "$1" in
    add)
        sed -i -e '/.*BalancerMember "http:\/\/'"${2}"'"/d' \
            -e 's%#CHILDBALANCER\(.*\)\(BalancerMember "http://\)\(BALANCER_URL\)\(.*\)%\1\2'"${2}"'\4\n#CHILDBALANCER\1\2\3\4%' \
            /etc/apache2/sites-enabled/00_default.conf
        ;;
    remove)
        sed -i '/.*BalancerMember "http:\/\/'"${2}"'"/d' /etc/apache2/sites-enabled/00_default.conf
    ;;
esac

apache2ctl graceful
