#!/usr/bin/env bash
docker build --rm -t local/c7-systemd .
docker container run -it --privileged -p 22:22 local/c7-systemd /usr/sbin/init
