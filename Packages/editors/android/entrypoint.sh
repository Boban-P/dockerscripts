#!/bin/bash


if [[ -d "./Android/Sdk/platform-tools" ]]; then
    PATH="$(realpath "./Android/Sdk/platform-tools"):${PATH}"
fi

exec "$@"
