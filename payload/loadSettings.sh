#!/bin/bash

# Create the export for all values supplied in the settings.json file
[ -f settings.json ] && {
  TEMP_SETTINGS=$(mktemp /dev/shm/SETTINGS_XXXXXXXXXXX)
  cat settings.json |
    jq --raw-output 'to_entries | .[] | "export " + .key + "=\"" + .value + "\""' \
      >$TEMP_SETTINGS
  source $TEMP_SETTINGS
  rm -f $TEMP_SETTINGS
}

#################################################################
# Change these values for your mail server
# When using STFjord to deploy with Terraform, these values are
# replace by those in settings.json
export MX_HOST=${MX_HOST-"mail"}
export MX_DOMAIN=${MX_DOMAIN-"mWorks.tech"}
export COUNTRY=${COUNTRY-"US"}
export STATE=${STATE-"Texas"}
export LOCATION=${LOCATION-"Dallas"}
export ORGANIZATION=${ORGANIZATION-"Machine Works Tech"}
export ORG_UNIT=${ORG_UNIT-"Security Team"}
export COMMON_NAME=${MX_DOMAIN}
export ENVIRONMENT=${ENVIRONMENT-"PROD"}        # Set this value to PROD to generate strong passwords for accounts.
export EMAIL_ACCOUNTS=${EMAIL_ACCOUNTS-"royce"} # Space seperated list of account names to create.
#################################################################
