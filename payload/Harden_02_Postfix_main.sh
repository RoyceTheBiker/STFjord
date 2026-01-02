#!/bin/bash

source $(dirname $0)/lib.sh
Header "Harden Postfix"
CreateRollback.sh SEQ /etc/postfix/

# Changes to main.cf
MAINCF=/etc/postfix/main.cf
sed -i ${MAINCF} -e 's/^smtp_tls_security_level .*/smtp_tls_security_level = encrypt/'
sed -i ${MAINCF} -e 's/^smtpd_tls_security_level .*/smtpd_tls_security_level = may/'
sed -i ${MAINCF} -e 's/^\(inet_protocols \).*/\1= ipv4/'
sed -i ${MAINCF} -e '/#myhostname.*host.domain.tld/{s/^#//;s/=.*/= '${MX_HOST}.${MX_DOMAIN}'/}'
sed -i ${MAINCF} -e '/#mydomain.*domain.tld/{s/^#//;s/=.*/= '${MX_DOMAIN}'/}'

# copy the line smtp_tls_CAfile to smtpd_tls_CAfile
sed -i ${MAINCF} -e '/smtp_tls_CAfile/{H;1h;{s/smtp/smtpd/}}'
# mynetworks_style = host ; could be required to allow local traffic.

# Changes to master.cf
MASTERCF=/etc/postfix/master.cf
sed -i ${MASTERCF} -e 's/^\(smtp *inet\)/#\1 /'  # Disable un-encrypted service.
sed -i ${MASTERCF} -e 's/^#\(smtps *inet\)/\1 /' # Enable encrypted service.
sed -i ${MASTERCF} -e 's/^#\( *-o smtpd_tls\)/\1/'

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
