#!/bin/bash

setup() {
    if [[ ! -d "/easyrsa/$1" ]]; then
        if [[ ! -f "/easyrsa/vars.example" ]]; then
            mkdir /easyrsa >/dev/null 2>&1
            ln -s /usr/share/easy-rsa/* /easyrsa/
        fi
        cd /easyrsa
        EASYRSA_PKI="$1" ./easyrsa init-pki
    fi
}

setvar() {
    [[ -z "${COUNTRY}" ]] && >&2 echo "Required Parameter COUNTRY missing use -e COUNTRY=Value while starting conatiner" && exit 1
    [[ -z "${PROVINCE}" ]] && >&2 echo "Required Parameter PROVINCE missing use -e PROVINCE=Value while starting conatiner" && exit 1
    [[ -z "${CITY}" ]] && >&2 echo "Required Parameter CITY missing use -e CITY=Value while starting conatiner" && exit 1
    [[ -z "${ORG}" ]] && >&2 echo "Required Parameter ORGANISATION missing use -e ORG=Value while starting conatiner" && exit 1
    [[ -z "${EMAIL}" ]] && >&2 echo "Required Parameter EMAIL missing use -e EMAIL=Value while starting conatiner" && exit 1
    [[ -z "${UNIT}" ]] && >&2 echo "Required Parameter ORGANISATION_UNIT missing use -e UNIT=Value while starting conatiner" && exit 1
    [[ -z "${CN}" ]] && >&2 echo "Required Parameter COMMON NAME missing use -e CN=Value while starting conatiner" && exit 1

    sed -e "s/^#\?\(set_var EASYRSA_REQ_COUNTRY[^\"]*\).*$/\1\"${COUNTRY}\"/" \
        -e "s/^#\?\(set_var EASYRSA_REQ_PROVINCE[^\"]*\).*$/\1\"${PROVINCE}\"/" \
        -e "s/^#\?\(set_var EASYRSA_REQ_CITY[^\"]*\).*$/\1\"${CITY}\"/" \
        -e "s/^#\?\(set_var EASYRSA_REQ_ORG[^\"]*\).*$/\1\"${ORG}\"/" \
        -e "s/^#\?\(set_var EASYRSA_REQ_EMAIL[^\"]*\).*$/\1\"${EMAIL}\"/" \
        -e "s/^#\?\(set_var EASYRSA_REQ_OU[^\"]*\).*$/\1\"${UNIT}\"/" \
        -e "s/^#\?\(set_var EASYRSA_KEY_SIZE[\t\s]*\).*$/\1${KEY_SIZE:-2048}/" \
        -e "s/^#\?\(set_var EASYRSA_ALGO[\t\s]*\).*$/\1${ALGORITHM:-ec}/" \
        -e "s/^#\?\(set_var EASYRSA_CA_EXPIRE[\t\s]*\).*$/\1${CA_EXPIRE_DAYS:-3650}/" \
        -e "s/^#\?\(set_var EASYRSA_CERT_EXPIRE[\t\s]*\).*$/\1${CERT_EXPIRE_DAYS:-1080}/" \
        -e "s/^#\?\(set_var EASYRSA_DIGEST[^\"]*\).*$/\1\"${DIGEST:-sha512}\"/" \
        -e "s/^#\?\(set_var EASYRSA_REQ_CN[^\"]*\).*$/\1\"${CN}\"/" \
        -e "s/^#\?\(set_var EASYRSA_BATCH[^\"]*\).*$/\1\"batch\"/" \
        /easyrsa/vars.example >/easyrsa/vars
}

# Ref: https://gist.github.com/QueuingKoala/e2c1c067a312384915b5

case "${CERT_TYPE}" in
    CA)
        setup "${CERT_TYPE}"
        if setvar; then
            cd /easyrsa && EASYRSA_PKI="${CERT_TYPE}" ./easyrsa build-ca nopass
        fi
        ;;
    SUB-CA)
        if [[ -z "${SUB_CA_NAME}" ]]; then
            >&2 echo "Required Parameter SUB CA NAME missing use -e SUB_CA_NAME=Value while starting conatiner"
            exit 1
        fi
        if [[ -d "/easyrsa/${SUB_CA_NAME}" ]]; then
            >&2 echo "Sub CA ${SUB_CA_NAME} already exists, remove directory to create new"
        else
            setup "${SUB_CA_NAME}"
            if setvar; then
                cd /easyrsa
                EASYRSA_PKI="${SUB_CA_NAME}" ./easyrsa build-ca nopass subca
                EASYRSA_PKI=CA ./easyrsa import-req ${SUB_CA_NAME}/reqs/ca.req ${SUB_CA_NAME}
                EASYRSA_PKI=CA ./easyrsa sign-req ca ${SUB_CA_NAME}
                cp CA/issued/${SUB_CA_NAME}.crt ${SUB_CA_NAME}/ca.crt
            else
                rm -rf /easyrsa/"${SUB_CA_NAME}"
            fi
        fi
        ;;
    SERVER)
        if [[ -z "${SUB_CA_NAME}" ]]; then
            >&2 echo "Required Parameter SUB CA NAME missing use -e SUB_CA_NAME=Value while starting conatiner"
            exit 1
        fi
        if [[ ! -d "/easyrsa/${SUB_CA_NAME}" ]]; then
            >&2 echo "CA- ${SUB_CA_NAME} not exists"
            exit 1
        fi
        if [[ -f "/easyrsa/${CN}-bundle.crt" ]]; then
            >&2 echo "certificate already issued"
            exit 1
        fi
        args=()
        if [[ -n "${ALT_NAMES}" ]]; then
            args+=(--subject-alt-name "${ALT_NAMES}")
        fi
        cd /easyrsa
        EASYRSA_PKI="${SUB_CA_NAME}" ./easyrsa "${args[@]}" gen-req ${CN} nopass
        EASYRSA_PKI="${SUB_CA_NAME}" ./easyrsa sign-req server ${CN}
        cat ${SUB_CA_NAME}/issued/${CN}.crt  ${SUB_CA_NAME}/ca.crt > ${CN}-bundle.crt
        ;;
    CLIENT)
        if [[ -z "${SUB_CA_NAME}" ]]; then
            >&2 echo "Required Parameter SUB CA NAME missing use -e SUB_CA_NAME=Value while starting conatiner"
            exit 1
        fi
        if [[ ! -d "/easyrsa/${SUB_CA_NAME}" ]]; then
            >&2 echo "CA- ${SUB_CA_NAME} not exists"
            exit 1
        fi
        if [[ -f "/easyrsa/${CN}-bundle.crt" ]]; then
            >&2 echo "certificate already issued"
            exit 1
        fi
        cd /easyrsa
        EASYRSA_PKI="${SUB_CA_NAME}" ./easyrsa gen-req ${CN} nopass
        EASYRSA_PKI="${SUB_CA_NAME}" ./easyrsa sign-req client ${CN}
        cat ${SUB_CA_NAME}/issued/${CN}.crt  ${SUB_CA_NAME}/ca.crt > ${CN}-bundle.crt
        ;;
esac
if [[ $# -gt 0 ]]; then
    exec "$@"
fi
