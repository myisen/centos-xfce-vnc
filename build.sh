#!/bin/bash
set -o nounset

args=""
if [[ "${1:-}" == "-f" ]]; then
    args="--force-rm --no-cache"
fi

docker build ${args} -t centos-xfce-vnc:latest .
