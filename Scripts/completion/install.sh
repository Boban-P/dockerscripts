#!/bin/bash

DIR="$(dirname "${BASH_SOURCE[0]}")"

if [[ ! -f "${HOME}/.bash_completion" ]]; then
    touch "${HOME}/.bash_completion"
fi

if ! grep -q -e '^# installed by cloudscript installer' "${HOME}/.bash_completion" ; then
    cat "${DIR}/bash_completion" >>"${HOME}/.bash_completion"
fi

mkdir -p "${HOME}/.local/bash_completions"

cp "${DIR}/cloudscript.sh" "${HOME}/.local/bash_completions"
