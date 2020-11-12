#!/bin/bash

value="$(load projects:webserver dependancy_map)"
expected="server:phpfpm server:mariadb server:apache server:postfix server:dnsmasq"
if [[ "${value}" != "${expected}" ]]; then
    echo "${value} != ${expected}"
    exit 1
fi