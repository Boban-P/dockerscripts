#!/bin/bash
show_help() {
    echo "Usage: $0 site_name empty|[add|remove ip:port ...]"
}
# Add or remove child balancer

args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-update)
            NO_UPDATE=1
            ;;
        *)
            args+=("$1")
            ;;
    esac
    shift
done

set -- "${args[@]}"

name="$(sed 's/[^a-zA-Z0-9_]/_/g' <<<"${1}")"

conf_file="$(find /etc/apache2/sites-enabled -name "??_${name}.conf")"
[[ -z "${conf_file}" ]] && >&2 echo "site configuration not found" && exit 1

case "$2" in
    add)
        [[ $# -lt 3 ]] && >&2 show_help && exit 1
        conf_data="$(cat "${conf_file}")"
        for url in "${@:3}"; do
            conf_data="$(sed -e '/BalancerMember "http:\/\/'"${url}"'"/d' \
                -e 's%\(.*\)#SITEBALANCER\(.*\)\(BalancerMember "http://\)\(BALANCER_URL\)\(.*\)%\1\3'"${url}"'\5\n\1#SITEBALANCER\2\3\4\5%' \
            <<<"${conf_data}")"
        done
        cat <<<"${conf_data}" >"${conf_file}"
        ;;
    remove)
        [[ $# -lt 3 ]] && >&2 show_help && exit 1
        for url in "${@:2}"; do
            options+=(-e '/BalancerMember "http:\/\/'"${url}"'"/d')
        done
        sed -i "${options[@]}" "$conf_file"
        ;;
    empty)
        [[ $# -ne 2 ]] && >&2 show_help && exit 1
        sed -i '/^[^#]\+BalancerMember /d' "${conf_file}"
        ;;
    reset)
        [[ $# -lt 3 ]] && >&2 show_help && exit 1
        conf_data="$(sed '/^[^#]\+BalancerMember /d' "${conf_file}")"
        for url in "${@:3}"; do
            conf_data="$(sed -e 's%\(.*\)#SITEBALANCER\(.*\)\(BalancerMember "http://\)\(BALANCER_URL\)\(.*\)%\1\3'"${url}"'\5\n\1#SITEBALANCER\2\3\4\5%' \
            <<<"${conf_data}")"
        done
        cat <<<"${conf_data}" >"${conf_file}"
        ;;
    *)
        show_help
        exit 1
        ;;
esac

if [[ -z "${NO_UPDATE}" ]]; then
    apache2ctl graceful
fi
