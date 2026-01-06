#!/bin/bash

# Fail2Ban for Rocky Linux 9 on Digital Ocean.
# https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-rocky-linux-9

# shellcheck disable=SC1091
source "$(dirname $0)/lib.sh"
Header "Fail2Ban Intrusion Prevention"

dnf -y install fail2ban

# Copy the conf file to make custom changes.
# jail.local = all rules are the same for all services
# jail.sshd, jail.<sevice> = create different rules for each service
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

systemctl enable fail2ban.service
systemctl start fail2ban.service
