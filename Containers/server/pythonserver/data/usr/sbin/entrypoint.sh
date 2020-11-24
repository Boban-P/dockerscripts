#!/bin/bash


DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
    /bin/run-parts "$DIR"
fi

if [[ ($1 == "daphne") && ($2 == "--bind") && ($3 == "0.0.0.0") && ($# -eq 3) ]]; then
    file="$(find . -maxdepth 2 -mindepth 2 -name 'asgi.py' | head -1 | sed 's/^\.\///' )"
    if [[ -n "${file}" ]]; then
        set -- "$@" "$(dirname "${file}").asgi:application"
    fi
fi

exec "$@"
