#!/bin/bash


case "$1" in
    add)
        echo "${3}"$'\t'"${2}" >>/etc/hosts
        ;;
    remove)
        file="$(mktemp)"
        sed '/'"${3}"$'\t'"${2}"'/d' /etc/hosts >"${file}"
        cat "${file}" >/etc/hosts
        rm "${file}"
        ;;
esac
