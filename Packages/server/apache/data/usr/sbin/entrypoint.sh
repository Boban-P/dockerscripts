#!/bin/bash


DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
    /bin/run-parts --exit-on-error "$DIR"
    state=$?
    [[ "${state}" -ne 0 ]] && exit ${state}
fi

exec "$@"
