#!/bin/bash

source "$(dirname $0)/lib.sh"
Header "Disable IPv6"
# If IPv6 is needed, skip this part and adjust the firewall to protect the system.
# Our system does not need IPv6, so it is disabled here.
# This will remove all inet6 addresses. Services will contine to listen on inet6 ports,
# but have no way to make connections to those ports.
nmcli -g NAME con | grep -v "^lo$" | while read LINE; do
  nmcli connection modify "${LINE}" ipv6.method disable || :
done
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
