#!/bin/bash

function finish {
    docker stop webserver-app0 >/dev/null
}
trap finish EXIT

./Scripts/load projects:webserver app start -d 172.17.0.1 -m 172.17.0.1 -n 172.17.0.1 172.17.0.1: >/dev/null
test "$(./Scripts/load projects:webserver app cat /etc/hosts | grep 'dbhost' | wc -l)" -eq 1 || (echo "dbhost not added"; exit 1)
