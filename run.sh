#!/bin/bash
set -o nounset

docker run -it -p 5901:5901 docker-xfce-vnc:latest
