#!/bin/bash


case "$1" in
    add)
        echo $3$'\t'$2 >>/etc/hosts
        ;;
    remove)
        sed -i '/'"$3$'\t'$2"'/d' /etc/hosts
        ;;
esac
