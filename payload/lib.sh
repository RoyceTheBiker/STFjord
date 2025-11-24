#!/bin/bash

# When an error happens, show the last 25 lines of BASH
# script that lead up to the error.
function CrashReport {
  echo "tail -n 25 ${TRAP_LOG}"
  tail -n 25 ${TRAP_LOG}
}

if [ "${TRAP_LOG}x" = "x" ]; then
  echo "Start trap logging"
  export TRAP_LOG=$(mktemp /tmp/TRAP_LOG_XXXXXXXXXXX)
  exec 2>$TRAP_LOG
  set -x
  set -e
fi
trap "CrashReport" ERR

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
