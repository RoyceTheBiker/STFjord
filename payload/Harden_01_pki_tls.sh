#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname $0)/lib.sh"

Header "Harden Link certificates"

EPT="/etc/pki/tls"
CreateRollback.sh SEQ ${EPT}

rm -f ${EPT}/private/postfix.key
ln -s ${ELL}/${MX_HOST,,}.${MX_DOMAIN,,}/privkey.pem ${EPT}/private/postfix.key
rm -f ${EPT}/certs/postfix.pem
ln -s ${ELL}/${MX_HOST,,}.${MX_DOMAIN,,}/fullchain.pem ${EPT}/certs/postfix.pem
