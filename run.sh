#!/bin/bash
set -o nounset

readonly PERSIST="/root/docker/volumes/vnc"
readonly TARGET="/data"

docker run -it -p 5901:5901 -v ${PERSIST}:${TARGET} docker-xfce-vnc:latest
