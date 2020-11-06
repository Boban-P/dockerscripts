#!/bin/bash

# Add or remove child balancer


case "$1" in
    add)
        sed -i '/.*BalancerMember "http:\/\/'$2'.*/d' /etc/apache2/sites-enabled/default.conf
        sed -i 's%#CHILDBALANCER\(.*\)\(BalancerMember "http://\)\(BALANCER_URL\)\(.*\)%\1\2'$2'\4\n#CHILDBALANCER\1\2\3\4%' /etc/apache2/sites-enabled/default.conf
        /etc/init.d/apache2 reload
        ;;
    remove)
        sed -i '/.*BalancerMember "http:\/\/'$2'.*/d' /etc/apache2/sites-enabled/default.conf
        /etc/init.d/apache2 reload
    ;;
esac


