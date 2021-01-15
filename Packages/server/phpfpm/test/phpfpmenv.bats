
setup_file() {
    local phpip siteip
    # Set php container.
    phpcontainer="$(docker run --rm -d \
        --mount type=bind,source=${BATS_TEST_DIRNAME}/files/www,destination=/home/www \
    bb526/server:phpfpm)"
    phpip="$(docker inspect ${phpcontainer} -f "{{.NetworkSettings.IPAddress}}")"
    # set webserver.
    sitecontainer="$(docker run --rm -d \
        -e CONFIG_TYPE=phpapp \
        --mount type=bind,source=${BATS_TEST_DIRNAME}/files/www,destination=/home/www \
        -e DOCUMENT_ROOT=/home/www \
    bb526/server:apache)"
    # set balancer proxy.
    balancercontainer="$(docker run --rm -d \
        -e CONFIG_TYPE=balancer \
        -e SSL_ON=1 \
    bb526/server:apache)"
    balancerip="$(docker inspect ${balancercontainer} -f "{{.NetworkSettings.IPAddress}}")"
    docker exec ${sitecontainer} appBalancer.sh add ${phpip}:80
    siteip="$(docker inspect ${sitecontainer} -f "{{.NetworkSettings.IPAddress}}")"
    docker exec ${balancercontainer} childBalancer.sh add ${siteip}:80
    export balancercontainer
    export balancerip
    export sitecontainer
    export phpcontainer
}

teardown_file() {
    docker stop ${balancercontainer} >/dev/null &
    docker stop ${sitecontainer} >/dev/null &
    docker stop ${phpcontainer} >/dev/null &
}



@test "php \$_SERVER['HTTPS'] is set" {
    httpoutput="$(wget -q --no-check-certificate -O - "https://${balancerip}/index.php")"
    [ "$(grep '$_SERVER\[HTTPS]' <<<"${httpoutput}" | wc -l)" -gt 0 ]
}

@test "php \$_SERVER['HTTPS'] is set on directory path" {
    httpoutput="$(wget -q --no-check-certificate -O - "https://${balancerip}")"
    [ "$(grep '$_SERVER\[HTTPS]' <<<"${httpoutput}" | wc -l)" -gt 0 ]
}

@test "php \$_SERVER['HTTP_HOST] is set" {
    httpoutput="$(wget -q --no-check-certificate -O - "https://${balancerip}")"
    [ "$(grep '$_SERVER\[HTTP_HOST]' <<<"${httpoutput}")" == "\$_SERVER[HTTP_HOST] = ${balancerip}" ]
}
