#!/bin/bash
set -e
Release="Thu 30 Oct 2025 17:07:37 MDT"

#################################################################
# Change these values for your mail server
MX_HOST=${MX_HOST-"mail"}
MX_DOMAIN=${MX_DOMAIN-"SiliconTao.com"}
#################################################################

# The root user has an ID value of 0.
# Any ID value that is not 0 is not root.
[[ $(id -u) -ne 0 ]] && {
  echo "Please run this script as root" >&2
  echo "sudo $0" >&2
  exit 6
}

LAST_SECTION=
function Header {
  LAST_SECTION="$1"
  Color yellow
  printf "%0.s-" {1..40}
  printf "\n    "
  Color cyan
  printf "%s   \n" "$1"
  Color yellow
  printf "%0.s-" {1..40}
  Color off
  echo
}

function Color {
  tput bold
  case $1 in
  black) tput setaf 0 ;;
  red) tput setaf 1 ;;
  green) tput setaf 2 ;;
  yellow) tput setaf 3 ;;
  blue) tput setaf 4 ;;
  magenta) tput setaf 5 ;;
  cyan) tput setaf 6 ;;
  white) tput setaf 7 ;;
  off) tput sgr0 ;;
  esac
}

Header "Harden Rocky Linux Webmail"
Header "$Release"

Header "Nginx TLS"
ELL="/etc/letsencrypt/live"
# The port 80 service needs to be disabled for Certbot to renew certificates every 3 months.
# The BASH operator ${VAR,,} changes all letters to lowercase.
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

EPT="/etc/pki/tls"
rm -f ${EPT}/private/postfix.key
ln -s ${ELL}/${MX_HOST,,}.${MX_DOMAIN,,}/privkey.pem ${EPT}/private/postfix.key
rm -f ${EPT}/certs/postfix.pem
ln -s ${ELL}/${MX_HOST,,}.${MX_DOMAIN,,}/fullchain.pem ${EPT}/certs/postfix.pem

# Create a backup of these files
cp /etc/postfix/main.cf ~/
cp /etc/postfix/master.cf ~/

sed -i /etc/postfix/main.cf -e 's/^smtp_tls_security_level .*/smtp_tls_security_level = encrypt/'
sed -i /etc/postfix/master.cf -e 's/^\(smtp *inet\)/#\1 /'  # Disable un-encrypted service.
sed -i /etc/postfix/master.cf -e 's/^#\(smtps *inet\)/\1 /' # Enable encrypted service.
sed -i /etc/postfix/master.cf -e 's/^#\( *-o smtpd_tls\)/\1/'
sed -i /etc/postfix/main.cf -e 's/^\(inet_protocols \).*/\1= ipv4/'
echo "smtpd_tls_security_level = encrypt"
systemctl restart postfix.service

sed -i /var/www/roundcubemail-1.6.11/config/config.inc.php -e "/config..smtp_host../s|=.*|= 'tls://localhost:587';|"

Header "Disable IPv6"
# If IPv6 is needed, skip this part and adjust the firewall to protect the system.
# Our system does not need IPv6, so it is disabled here.
# This will remove all inet6 addresses. Services will contine to listen on inet6 ports,
# but have no way to make connections to those ports.
nmcli -g NAME con | while read LINE; do
  nmcli connection modify "${LINE}" ipv6.method disable || :
done
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# End of script
