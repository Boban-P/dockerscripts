#!/bin/bash

[[ (-z "${INSTALL_ARG_KVM_GID}") || (-z "${INSTALL_ARG_LIBVIRT_GID}") ]] && 2> echo "kvm OR libvirt not available in host" && exit 1

cd ${DIR}
mkdir "${DIR}/data"
wget -nc -O "${ANDROID_STUDIO_FILE}" "${ANDORID_STUDIO_URL}"
gunzip -t "${ANDROID_STUDIO_FILE}" || rm -rf "${ANDROID_STUDIO_FILE}"
tar -xzf "${ANDROID_STUDIO_FILE}" -C "${DIR}/data"

