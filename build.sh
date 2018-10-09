#!/bin/bash
set -o nounset

args=""
if [[ "${1:-}" == "-f" ]]; then
    args="--force-rm --no-cache"
fi

docker build ${args} -t docker-xfce-vnc:latest .
