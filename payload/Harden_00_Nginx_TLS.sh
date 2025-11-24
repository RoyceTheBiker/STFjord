#!/bin/bash

source $(dirname $0)/lib.sh
Header "Nginx TLS"
ELL="/etc/letsencrypt/live"

# The port 80 service needs to be disabled for Certbot to renew certificates every 3 months.
# The BASH operator ${VAR,,} changes all letters to lowercase.
CreateRollback.sh SEQ /etc/nginx/nginx.conf
sed -i /etc/nginx/nginx.conf -e '/^ *listen *80/s/80/443 ssl http2/' # Change IPv4 port 80 to be 443
sed -i /etc/nginx/nginx.conf -e '/^ *listen *.*:80/d'                # Remove IPv6 port 80
sed -i /etc/nginx/nginx.conf -e '/^ *root/a \
        ssl_certificate "'${ELL}/${MX_HOST,,}.${MX_DOMAIN,,}'/fullchain.pem";\
        ssl_certificate_key "'${ELL}/${MX_HOST,,}.${MX_DOMAIN,,}'/privkey.pem";\
        ssl_session_cache shared:SSL:1m;\
        ssl_session_timeout  10m;\
        ssl_ciphers PROFILE=SYSTEM;\
        ssl_prefer_server_ciphers on;'

systemctl restart nginx.service
