#!/bin/bash

source $(dirname $0)/lib.sh
CreateRollback.sh SEQ /etc/postfix/main.cf /etc/postfix/master.cf
sed -i /etc/postfix/main.cf -e 's/^smtp_tls_security_level .*/smtp_tls_security_level = encrypt/'
sed -i /etc/postfix/master.cf -e 's/^\(smtp *inet\)/#\1 /'  # Disable un-encrypted service.
sed -i /etc/postfix/master.cf -e 's/^#\(smtps *inet\)/\1 /' # Enable encrypted service.
sed -i /etc/postfix/master.cf -e 's/^#\( *-o smtpd_tls\)/\1/'
sed -i /etc/postfix/main.cf -e 's/^\(inet_protocols \).*/\1= ipv4/'
echo "smtpd_tls_security_level = encrypt"
systemctl restart postfix.service
