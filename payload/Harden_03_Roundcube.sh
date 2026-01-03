#!/bin/bash

source "$(dirname $0)/lib.sh"
Header "Harden Roundcube"

RQ_CONF=/var/www/roundcubemail-1.6.11/config/config.inc.php

CreateRollback.sh SEQ ${RQ_CONF}

# sed -i ${RQ_CONF} -e "/config..smtp_host../s|=.*|= 'tls://localhost:587';|"

# From testing, submission cannot use TLS.
# Email clients, both desktop and mobile apps, will not have certs.
# vim /var/www/roundcubemail-1.6.11/config/config.inc.php
#
# Roundcube seems unable to send email from the WUI if encryption is enforced.
# SMTP will have TLS set to may, to allow Roundcube to send email.
# It will trust external client apps to choose eencrypted.
# Failure to encrypt connection could allow emaiil to be read while in transit.
sed -i ${RQ_CONF} -e "/config..smtp_host../s|=.*|= 'localhost';|"
