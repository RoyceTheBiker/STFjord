#!/bin/bash

# This payload installs the Rocky Linux Webmail project.
# https://silicontao.com/main/marquis/article/RoyceTheBiker/Rocky%20Linux%20Webmail%20Server
#
# This Git repository only contains the Terraform code to standup a single Droplet in Digital Ocean
# using Rocky Linux.
#
# Replace this payload script to deploy a different project into a Rocky Linux Digital Ocean Droplet.

# Exit the script on error event.
set -e

#################################################################
# Change these values for your mail server
export MX_HOST=${MX_HOST-"mail"}
export MX_DOMAIN=${MX_HOST-"mWorks.tech"}
export COUNTRY=${COUNTRY-"US"}
export STATE=${STATE-"Texas"}
export LOCATION=${LOCATION-"Dallas"}
export ORGANIZATION=${ORGANIZATION-"Machine Works Tech"}
export ORG_UNIT=${ORG_UNIT-"Security Team"}
export COMMON_NAME=${MX_DOMAIN}
export ENVIRONMENT=${ENVIRONMENT-"PROD"}        # Set this value to PROD to generate strong passwords for accounts.
export EMAIL_ACCOUNTS=${EMAIL_ACCOUNTS-"royce"} # Space seperated list of account names to create.
#################################################################

# Change to the directory that this script is in.
cd $(dirname $0)

# CreateRollback makes a backup and a rollback script to restore a file before making changes to it.
install -v -m700 CreateRollback.sh /usr/bin

# This Digial Ocean image was created with a orphaned RPM lock file.
rm -f /var/lib/rpm/.rpm.lock && sleep 10 || :

# Add the Extra Packages for Enterprise Linux repository
dnf -y install epel-release

ls -lha /var/lib/rpm/.rpm.lock && sleep 10 || :

cat settings.json | jq

halt
exit
sleep 20

# My vimrc. This is optional, nice if you are working in the shell.
curl https://cdn.silicontao.com/RockyLinuxWebmail/vimrc >~/.vimrc

# Activate Certbot to create signed certificates
[ -f CertbotSetup.sh ] && bash ./CertbotSetup.sh

# Setup Roundcube with database, Postfix, and Dovecot
[ -f RockyLinuxWebmail.sh ] && bash ./RockyLinuxWebmail.sh

# Setup ClamAV and Milter for Postfix
[ -f ClamAV4Postfix.sh ] && bash ./ClamAV4Postfix.sh

# Harden the server.
# Switch to encrypted ports.
[ -f HardenWebmail.sh ] && bash ./HardenWebmail.sh

# Just for dev, stand up the server then turn it off
echo "Halting server for testing"
halt -p
