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

# Change to the directory that this script is in.
cd $(dirname $0)
source lib.sh

# CreateRollback makes a backup and a rollback script to restore a file before making changes to it.
install -v -m700 CreateRollback.sh /usr/bin

# This Digial Ocean image was created with a orphaned RPM lock file.
rm -f /var/lib/rpm/.rpm.lock && sleep 10 || :

# Add the Extra Packages for Enterprise Linux repository
dnf -y install epel-release
dnf -y install jq

ls -lha /var/lib/rpm/.rpm.lock && sleep 10 || :

# loadSettings needs to be sourced, not executed, because
# the exported variables need to be availble at this level.
source loadSettings.sh

# Before we do anything else, set the desired timezone
# Timezone is one word, but here we use SCREAMING_SNAKE_CASE
# to not interfere with any other variable
timedatectl set-timezone ${TIME_ZONE}

# Change the local logging to use the new TZ
echo "TZ=\"${TIME_ZONE}\"" >>/etc/sysconfig/rsyslog
ystemctl restart rsyslog.service

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
