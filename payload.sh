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
export MX_HOST="roundcube"
export MX_DOMAIN="mworks.tech"
export COUNTRY="US"
export STATE="Texas"
export LOCATION="Dallas"
export ORGANIZATION="Machine Works"
export ORG_UNIT="Security Department"
export COMMON_NAME=${MX_DOMAIN}
export ENVIRONMENT="PROD" # Set this value to PROD to generate strong passwords for accounts.
export TEST_EMAIL_ACCOUNTS="royce"
#################################################################

# Add the Extra Packages for Enterprise Linux repository
dnf -y install epel-release

# Activate Certbot to create signed certificates
curl https://cdn.silicontao.com/RockyLinuxWebmail/CertbotSetup.sh | bash

echo "Skipping payload for Droplet testing."
exit 0

# Setup Roundcube with database, Postfix, and Dovecot
curl https://cdn.silicontao.com/RockyLinuxWebmail/RockyLinuxWebmail.sh | bash

# Setup ClamAV and Milter for Postfix
curl https://cdn.silicontao.com/RockyLinuxWebmail/ClamAV4Postfix.sh | bash

# Harden the server.
# Switch to encrypted ports.
curl https://cdn.silicontao.com/RockyLinuxWebmail/HardenWebmail.sh | bash
