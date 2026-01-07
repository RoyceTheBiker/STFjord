#!/bin/bash

# tfwrap is a wrapper for terraform to ready the remote state,
# read values from the settings JSON file, and init the
# environment for deployment.

# arguments
#   validate | plan | apply | destroy
#   path/to/settings.json

ARG1=${1}
ARG2=${2}

function tf_help {
  echo "This script requires two arguments"
  echo "The first is an action of validate, plan, apply, or destroy"
  echo "The second is the path to the settings JSON file for this action"
  exit 1
}

function writeRemoteBackend {
  cat >>backend.tf <<@EOF
terraform {
  backend "s3" {
    bucket     = "terraform"
    region     = "us-east-1"
    key        = "fileShare/us-east-1"
  }
}
@EOF
}

function WriteBackend {
  cat >backend.tf <<@EOF
terraform {
  backend "local" {
    path  = "${STATE_LOCATION}"
  }
}
@EOF
}

function readSshKey {
  PRV_KEY=$(doctl compute ssh-key list --output json | jq --raw-output '.[]|.name') || {
    echo "Please start the SSH agent and add a private key."
    exit 2
  }
  export TF_VAR_SSH_KEY="${PRV_KEY}"
}

function debugLogging {
  export TF_LOG_PATH=debug.log
  export TF_LOG=DEBUG
}

function setTokenVar {
  cat "${ARG2}" | jq --raw-output '.do_token' | grep -q do_token && {
    echo "The DO token is no longer needed in the settings JSON" >&2
    echo "Please remove the token from the settings JSON file" >&2
    exit 1
  } || :
  export TF_VAR_do_token=$(doctl auth token)
}

function tf_init {
  debugLogging
  readSshKey
  setTokenVar
  WriteBackend
  if [ -f .terraform/terraform.tfstate ]; then
    rm -f .terraform/terraform.tfstate
  fi
  echo "terraform init"
  terraform init
}

function tf_validate {
  tf_init
  echo "terraform validate"
  terraform validate
}

function tf_plan {
  tf_init
  echo "terraform plan"
  terraform plan --var-file="${TF_VAR_settings_json}"
}

function tf_apply {
  tf_init
  echo "terraform apply"
  terraform apply --var-file="${TF_VAR_settings_json}"
}

function tf_destroy {
  tf_init
  echo "terraform destroy"
  terraform destroy --var-file="${TF_VAR_settings_json}"
}

# Check for two arguments
[ ${#@} -eq 2 ] || tf_help

# First argument is action
ACTION=
case "${ARG1}" in
"plan" | "validate" | "apply" | "destroy")
  ACTION=${ARG1}
  ;;
*)
  tf_help
  ;;
esac

# Second argument JSON file
REMOTE_STATE=false
[ -f "${ARG2}" ] || help

STATE_LOCATION=
MX_DOMAIN=$(cat "${ARG2}" | jq --raw-output '.MX_DOMAIN')
REMOTE_STATE=$(cat "${ARG2}" | jq 'has("REMOTE_STATE")')
[ "${REMOTE_STATE}x" == "truex" ] && {

  echo "read the value of remote state"
  STATE_LOCATION=$(cat "${ARG2}" | jq --raw-output '.REMOTE_STATE')
} || {
  # Split local state when not using remote state
  echo "MX_DOMAIN=$MX_DOMAIN"
  mkdir -p .states/${MX_DOMAIN}
  STATE_LOCATION=".states/${MX_DOMAIN}/${MX_DOMAIN}"
}

echo "REMOTE_STATE='$REMOTE_STATE'"
echo "STATE_LOCATION='$STATE_LOCATION'"

export TF_VAR_settings_json="${ARG2}"

# test digital ocean token
doctl apps list-regions >/dev/null || {
  echo "doctl could not connect to Digital Ocean"
  echo "Check that your token is current"
  echo "Create a token at https://cloud.digitalocean.com/account/api/tokens"

  echo "The add the token to the local system using"
  echo "doctl auth init"
  exit 1
}

[ "${REMOTE_STATE}x" == "truex" ] && {
  # https://docs.digitalocean.com/products/spaces/how-to/create/
  echo "check digital ocean for state storage, or create it"
  echo "doctl can't create buckets. going to use split local state for now"
  #doctl spaces keys list 2>/dev/null | grep -q "${STATE_LOCATION}" || {
  #  echo "Create bucket"
  #  set -x
  #  doctl spaces keys create "${STATE_LOCATION}" --grants 'bucket=terraform;permission=fullaccess'
  #}
}

case "$ACTION" in
"validate") tf_validate ;;
"plan") tf_plan ;;
"apply") tf_apply ;;
"destroy") tf_destroy ;;
esac
