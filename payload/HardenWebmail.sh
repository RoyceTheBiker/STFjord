#!/bin/bash
set -e
Release="Thu 30 Oct 2025 17:07:37 MDT"

#################################################################
# Change these values for your mail server
# These values are passed in from RockyLinuxWebmail.sh
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

RLWM_HL=${HOME}/RLWM_Harden_steps
mkdir -pv ${RLWM_HL}

source $(dirname $0)/lib.sh

LAST_SECTION=
Header "Harden Rocky Linux Webmail"
Header "$Release"

RESUME=false
[[ "${1}x" == "--resumex" ]] && RESUME=true || :

for i in Harden_*; do
  if [[ ${RESUME} == false || ! -f ${RLWM_HL}/${i} ]]; then
    # Create a backup of these files
    source ${i}
    grep CreateRollback ${TRAP_LOG} | head >${RLWM_HL}/${i}
  fi
done

# Generate a security audit report
dnf -y install lynis
lynis audit system | tee lynis.report.txt

# End of script
