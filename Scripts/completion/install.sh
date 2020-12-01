#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

DIR="$(realpath -s "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/..)"

scriptName="cloudscript"

if [[ -n "${1}" ]];then
    scriptName=${1}
fi

install() {
    bin_path=${bin_path:-/usr/local/bin}
    inst_location=${inst_location:-/usr/share/cloudscript}
    if [[ -f "${bin_path}/${scriptName}" ]]; then
        echo "script with ${scriptName} already exists in ${bin_path}" >&2
        exit 1
    fi

    if [[ -d "${inst_location}" ]]; then
        echo "${inst_location} exists" >&2
        exit 1
    fi

    if [[ -f "/usr/share/bash_completion/${scriptName}" ]]; then
        echo "completion script already exists" >&2
        exit 1
    fi

    mkdir -p "${inst_location}/function"
    cp -r "${DIR}/load" "${DIR}/conf" "${DIR}/function" /usr/share/cloudscript
    ln -s /usr/share/cloudscript/load "${bin_path}/${scriptName}"


    sed 's/%%cloudscript%%/'"${scriptName}"'/g' "${DIR}/completion/cloudscript.sh" >"/etc/bash_completion.d/${scriptName}"
}
uninstall() {
    bin_path=${bin_path:-/usr/local/bin}
    inst_location=${inst_location:-/usr/share/cloudscript}
    rm -rf "${inst_location}"
    rm -rf  /usr/share/cloudscript
    unlink "${bin_path}/${scriptName}"
    unlink "/etc/bash_completion.d/${scriptName}"
    rm -f /etc/cloudscript.conf
}

uninstall 2>/dev/null
install

if [[ ! -d "${DIR}/../Packages" ]]; then
    echo "Packages directory not found, not setting up ~/.cloudscript for user." >&2
    exit
fi

package_path="$(realpath -s "${DIR}/../Packages")"
filepath="$(realpath "${BASH_SOURCE[0]}")"

cat >/etc/cloudscript.conf <<<"
# copy this file to ~/.cloudscript
# and make any changes as needed.
include_dir = ${package_path}
image_prefix = bb526
"
