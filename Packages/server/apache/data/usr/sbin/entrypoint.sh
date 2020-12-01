#!/bin/bash


DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
    /bin/run-parts "$DIR"
fi
echo "finishing " "$@"
exec "$@"
