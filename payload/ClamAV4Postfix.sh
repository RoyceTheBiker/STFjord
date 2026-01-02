#!/bin/bash
set -e
Release="Tue 23 Sep 2025 10:56:30 MDT"

#################################################################
# Change these values for your mail server
# These values are passed in from RockyLinuxWebmail.sh
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

Header "Rocky Linux Webmail setup"
Header "$Release"

Header "Install ClamAV"
dnf -y update
dnf -y install clamav
dnf -y install clamd
dnf -y install clamav-milter

Header "Update Freshclam"
freshclam

Header "Configure Freshclam Service"
sed -i /usr/lib/systemd/system/clamav-freshclam.service \
  -e 's|^ExecStart.*|ExecStart=/bin/freshclam -d -c 1|'

systemctl start clamav-freshclam.service
systemctl enable clamav-freshclam.service

Header "Configure and start the ClamAV scanner service"
sed -i /etc/clamd.d/scan.conf -e 's/#LocalSocket \/run/LocalSocket \/run/g'
systemctl start clamd@scan
systemctl enable clamd@scan

Header "Configure ClamAV Mail Filter"
CONF=/etc/mail/clamav-milter.conf
sed -i $CONF -e '/^Example$/d'
sed -i $CONF -e 's|^#MilterSocket inet:7357$|MilterSocket /var/run/clamav-milter/clamav-milter.socket|'
sed -i $CONF -e '/MilterSocket .var.run/aMilterSocketMode 660'

sed -i $CONF -e 's|^#ClamdSocket unix:/run/clamav/clamd.sock|ClamdSocket unix:/run/clamd.scan/clamd.sock|'
sed -i $CONF -e 's/^#OnInfected Quarantine/OnInfected Blackhole/'
sed -i $CONF -e 's/^#AddHeader Replace/AddHeader Yes/'
sed -i $CONF -e 's/^#LogFacility LOG_MAIL/LogFacility LOG_MAIL/'

systemctl start clamav-milter.service
systemctl enable clamav-milter.service

Header "Configure Postfix Milter"

cat >>/etc/postfix/main.cf <<@EOF
milter_default_action = tempfail
smtpd_milters = unix:/run/clamav-milter/clamav-milter.socket
non_smtpd_milters = unix:/run/clamav-milter/clamav-milter.socket
@EOF

Header "Add postfix user to clamilt group"
usermod -G clamilt -a postfix
systemctl restart postfix.service
