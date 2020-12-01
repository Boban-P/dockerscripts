#!/bin/bash

# Add or remove php balancer

case "$1" in
    add)
        sed -i -e '/.*BalancerMember "[a-z]\+:\/\/'"${2}"'"/d' \
            -e 's%#APPBALANCER\(.*\)\(BalancerMember "[a-z]\+://\)\(BALANCER_URL\)\(.*\)%\1\2'"${2}"'\4\n#APPBALANCER\1\2\3\4%' \
            /etc/apache2/sites-enabled/default.conf
        ;;
    remove)
        sed -i '/.*BalancerMember "[a-z]\+:\/\/'"${2}"'"/d' /etc/apache2/sites-enabled/default.conf
    ;;
esac

apache2ctl graceful
