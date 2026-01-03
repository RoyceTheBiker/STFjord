#!/bin/bash

source "$(dirname $0)/lib.sh"
Header "Harden PHP-FPM"

CreateRollback.sh SEQ /etc/php.ini
sed -i /etc/php.ini -e '/^expose_php/s|On|Off|'
systemctl restart php-fpm.service
