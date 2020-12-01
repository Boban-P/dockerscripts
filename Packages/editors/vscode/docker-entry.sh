#!/bin/bash

for file in /home/developer/*; do
    if ! mountpoint -q "$file"; then
        [[ ! -f "$(dirname "$file")/.$(basename "$file")" ]] && rm -rf "$file"
    else
        current="$(dirname "$file")/.$(basename "$file")"
        touch $current
    fi
done

cleanup() {
    unlink "${current}"
}

# https://stackoverflow.com/a/41451517

trap 'cleanup' SIGTERM

"$@" &

wait $!

cleanup
