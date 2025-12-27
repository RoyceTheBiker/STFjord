#!/bin/bash

source $(dirname $0)/lib.sh
Header "Harden Postfix"
CreateRollback.sh SEQ /etc/postfix/

# Changes to main.cf
sed -i /etc/postfix/main.cf -e 's/^smtp_tls_security_level .*/smtp_tls_security_level = encrypt/'
sed -i /etc/postfix/main.cf -e 's/^smtpd_tls_security_level .*/smtpd_tls_security_level = encrypt/'
sed -i /etc/postfix/main.cf -e 's/^\(inet_protocols \).*/\1= ipv4/'
copy the line smtp_tls_CAfile to smtpd_tls_CAfile

# Changes to master.cf
sed -i /etc/postfix/master.cf -e 's/^\(smtp *inet\)/#\1 /'  # Disable un-encrypted service.
sed -i /etc/postfix/master.cf -e 's/^#\(smtps *inet\)/\1 /' # Enable encrypted service.
sed -i /etc/postfix/master.cf -e 's/^#\( *-o smtpd_tls\)/\1/'

# From testing, submission cannot use TLS.
# Email clients, both desktop and mobile apps, will not have certs.
# vim /etc/postfix/master.cf
# 18   -o syslog_name=postfix/submission
# 19   -o smtpd_tls_security_level=may

cat >>/etc/postfix/main.cf <<@EOF
smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
tls_medium_cipherlist = ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
@EOF

systemctl restart postfix.service
