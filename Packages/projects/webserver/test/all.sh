#!/bin/bash

DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd ../../..
export PATH="$(realpath "${DIR}/../../../../Scripts"):${PATH}"
cd "${DIR}"
mapfile -t value<<<"$(find . -executable -name 'test_*' -exec bash -c '${1} 1>&2 && echo 1 || echo 0' {} \;)"

succes=0
for data in "${value[@]}"; do
    test "$data" -eq 1 && ((succes++))
done

if [[ "${succes}" -ne "${#value[@]}" ]]; then
    echo "$((${#value} - succes)) failed"
fi

echo "${succes} / ${#value[@]} succeeded"
