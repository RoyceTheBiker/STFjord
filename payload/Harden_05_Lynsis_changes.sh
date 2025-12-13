#!/bin/bash

SERVICES="mariadb"
for i in $SERVICES; do

  /usr/bin/systemd-analyze security ${i}.service
done
