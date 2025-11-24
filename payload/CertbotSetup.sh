#!/bin/bash
set -e
Release="Sat  4 Oct 2025 11:45:22 MDT"

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

source $(dirname $0)/lib.sh

Header "Certbox setup"
Header "$Release"

# About 10% of the deployments fail because something leaves the lock file behind.
function Wait4RpmLock {
  [[ -f /var/lib/rpm/.rpm.lock ]] && {
    ps -ef | grep -iE "rpm|dnf"
    ls -lha /var/lib/rpm/
    sleep 20
    rm -vf /var/lib/rpm/.rpm.lock || :
  }
}

if [ -f letsencrypt.mWorks.tbj ]; then
  # For development the previously generated certificates are used.
  tar xfj letsencrypt.mWorks.tbj -C /
  exit 0
fi

Wait4RpmLock
dnf -y install certbot
Wait4RpmLock

# This will generate our signed certificates without interaction.
# Certificates will be in /etc/letsencrypt/live/${MX_HOST,,}.${MX_DOMAIN,,}
# as fullchain.pem the signed public certificate, and privkey.pem the private key.
# The path for letsencrypt is all lowercase even if the domain name has upper case.
# BASH in Rocky Linux 9 can change variables to lower case using ${VAR,,}
certbot certonly --non-interactive --agree-tos \
  --no-eff-email \
  --standalone \
  --no-redirect \
  --email "admin@${MX_DOMAIN}" \
  --domains "${MX_HOST}.${MX_DOMAIN}"

cat >>/etc/cron.d/certbot <<@EOF
# /etc/cron.d/certbot: crontab entries for the certbot package
#
# Upstream recommends attempting renewal twice a day
#
# Eventually, this will be an opportunity to validate certificates
# haven't been revoked, etc.  Renewal will only occur if expiration
# is within 30 days.
#
# Important Note!  This cronjob will NOT be executed if you are
# running systemd as your init system.  If you are running systemd,
# the cronjob.timer function takes precedence over this cronjob.  For
# more details, see the systemd.timer manpage, or use systemctl show
# certbot.timer.
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew --no-random-sleep-on-renew
@EOF
