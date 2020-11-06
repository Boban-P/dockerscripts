#!/bin/bash

# Add or remove php balancer

case "$1" in
    add)
        sed -i '/.*BalancerMember "fcgi:\/\/'$2'.*/d' /etc/apache2/sites-enabled/default.conf
        sed -i 's%#PHPBALANCER\(.*\)\(BalancerMember "fcgi://\)\(BALANCER_URL\)\(.*\)%\1\2'$2'\4\n#PHPBALANCER\1\2\3\4%' /etc/apache2/sites-enabled/default.conf
        /etc/init.d/apache2 reload
        ;;
    remove)
        sed -i '/.*BalancerMember "fcgi:\/\/'$2'.*/d' /etc/apache2/sites-enabled/default.conf
        /etc/init.d/apache2 reload
    ;;
esac


