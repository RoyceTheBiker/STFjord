#!/bin/bash

# tfwrap is a wrapper for terraform to ready the remote state,
# read values from the settings JSON file, and init the
# environment for deployment.

# arguments
#   validate | plan | deploy | destroy
#   path/to/settings.json

# Check for two arguments
[ ${#@} -eq 2 ] || help 
 
# First argument is action
ACTION=
case "${1}" in
  "plan")
  "validate")
  "deploy")
  "destroy")
    ACTION=${1}
  ;;
*)
  help
  ;;
esac

# Second argument JSON file
REMOTE_STATE=false
[ -f ${2} ] || help

cat ${2} | jq read the value of remote state

export TF_VAR_settings_json=${2}

function help {
  echo "This script requires two arguments"
  echo "The first is an action of validate, plan, deploy, or destroy"
  echo "The second is the path to the settings JSON file for this action"
  exit 1
}

function tf_init {
  echo terraform init
}

function tf_validate {
  tf_init
  echo terraform validate
}

function tf_plan {
  tf_init
  echo terraform plan --var-file=${TF_VAR_settings_json}
}

function tf_deploy {
  tf_init
  echo terraform deploy --var-file=${TF_VAR_settings_json}
}

function tf_destroy {
  tf_init
  echo terraform destroy --var-file=${TF_VAR_settings_json}
}

# test digital ocean token
doctl apps list-regions > /dev/null || {
  echo "doctl could not connect to Digital Ocean"
  echo "Check that your token is current"
  echo "Create a token at https://cloud.digitalocean.com/account/api/tokens"

  echo "The add the token to the local system using"
  echo "doctl auth init"
  exit 1
}


[ $REMOTE_STATE == true ] && {
  # https://docs.digitalocean.com/products/spaces/how-to/create/
  echo check digital ocean for state storage, or create it
}

case "$ACTION" in
  "validate") tf_validate ;;
  "plan") tf_plan ;;
  "deploy") tf_deploy ;;
  "destroy") tf_destroy ;;
esac





