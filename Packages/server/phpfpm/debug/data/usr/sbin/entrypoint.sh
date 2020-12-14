#!/bin/bash

touch /dockery_do_run
while [[ -f /dockery_do_run ]]; do

    source /dockery_do_run
    unlink /dockery_do_run

    DIR=/docker-entrypoint.d

    if [[ -d "$DIR" ]]
    then
        /bin/run-parts "$DIR"
    fi

    "$@"
done
