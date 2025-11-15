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
export -f Header

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
export -f Color

Header "Harden Rocky Linux Webmail"
Header "$Release"

for i in Harden_*; do
  # Create a backup of these files
  source ${i}
done

# End of script
