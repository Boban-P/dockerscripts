#!/bin/bash

DIR="$(dirname "${BASH_SOURCE[0]}")"

if [[ ! -f "${HOME}/.bash_completion" ]]; then
    touch "${HOME}/.bash_completion"
fi

if [[ -z "$(cat "${HOME}/.bash_completion" | grep -e '^# installed by cloudscript installer')" ]]; then
    cat "${DIR}/bash_completion" >>"${HOME}/.bash_completion"
fi

mkdir -p "${HOME}/.local/bash_completions"

cp cloudscript.sh "${HOME}/.local/bash_completions"

