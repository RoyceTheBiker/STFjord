#!/bin/bash
set -e
Release="Thu 30 Oct 2025 17:07:37 MDT"

#################################################################
# Change these values for your mail server
export MX_HOST=${MX_HOST-"mail"}
export MX_DOMAIN=${MX_DOMAIN-"SiliconTao.com"}
#################################################################

# The root user has an ID value of 0.
# Any ID value that is not 0 is not root.
[[ $(id -u) -ne 0 ]] && {
  echo "Please run this script as root" >&2
  echo "sudo $0" >&2
  exit 6
}

source $(dirname $0)/lib.sh

LAST_SECTION=
Header "Harden Rocky Linux Webmail"
Header "$Release"

for i in Harden_*; do
  # Create a backup of these files
  source ${i}
done

# End of script
