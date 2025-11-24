#!/bin/bash

source $(dirname $0)/lib.sh
Header "Harden Roundcube"

CreateRollback.sh SEQ /var/www/roundcubemail-1.6.11/config/config.inc.php
sed -i /var/www/roundcubemail-1.6.11/config/config.inc.php -e "/config..smtp_host../s|=.*|= 'tls://localhost:587';|"
