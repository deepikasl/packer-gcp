#!/bin/bash -e

set -o pipefail

export PROJECT_ID=$1
if [ -z "$PROJECT_ID" ]; then
    echo "Need to provide PROJECT_ID as Input 1"
    exit 1
fi

export MACHINE_TYPE=$2
if [ -z "$MACHINE_TYPE" ]; then
    echo "Need to provide MACHINE_TYPE as Input 2"
    exit 1
fi

export SOURCE_IMAGE_FAMILY=$3
if [ -z "$SOURCE_IMAGE_FAMILY" ]; then
    echo "Need to provide SOURCE_IMAGE_FAMILY as Input 3"
    exit 1
fi

export REGION=$4
if [ -z "$REGION" ]; then
    echo "Need to provide REGION as Input 4"
    exit 1
fi

export ZONE=$5
if [ -z "$ZONE" ]; then
    echo "Need to provide ZONE as Input 5"
    exit 1
fi

export SSH_USERNAME=$6
if [ -z "$SSH_USERNAME" ]; then
    echo "Need to provide SSH_USERNAME as Input 6"
    exit 1
fi

export SERVICE_ACCOUNT_JSON=$7
if [ -z "$SERVICE_ACCOUNT_JSON" ]; then
    echo "Need to provide SERVICE_ACCOUNT_JSON as Input 7"
    exit 1
fi

export IMAGE_FAMILY=$8
if [ -z "$IMAGE_FAMILY" ]; then
    echo "Need to provide IMAGE_FAMILY as Input 8"
    exit 1
fi


set_context(){
  echo "PROJECT_ID=$PROJECT_ID"
  echo "MACHINE_TYPE=$MACHINE_TYPE"
  echo "SOURCE_IMAGE_FAMILY=$SOURCE_IMAGE_FAMILY"
  echo "REGION=$REGION"
  echo "ZONE=$ZONE"
  echo "SSH_USERNAME=${#SSH_USERNAME}" #print only length not value
  echo "SERVICE_ACCOUNT_JSON=$SERVICE_ACCOUNT_JSON"
  echo "IMAGE_FAMILY=$IMAGE_FAMILY"
}

get_image_list() {
  export IMAGE_NAMES_SPACED=$(eval echo $(tr '\n' ' ' < images.txt))
  echo "IMAGE_NAMES_SPACED=$IMAGE_NAMES_SPACED"
}

build_image() {
  echo "-----------------------------------"
  echo "validating image template"
  echo "-----------------------------------"

  packer validate -var PROJECT_ID=$PROJECT_ID \
    -var MACHINE_TYPE=$MACHINE_TYPE \
    -var SOURCE_IMAGE_FAMILY=$SOURCE_IMAGE_FAMILY \
    -var REGION=$REGION \
    -var ZONE=$ZONE \
    -var SSH_USERNAME=$SSH_USERNAME \
    -var SERVICE_ACCOUNT_JSON=$SERVICE_ACCOUNT_JSON \
    -var IMAGE_FAMILY=$IMAGE_FAMILY \
    packer.json

  echo "building image"
  echo "-----------------------------------"

  packer build -machine-readable -var PROJECT_ID=$PROJECT_ID \
    -var MACHINE_TYPE=$MACHINE_TYPE \
    -var SOURCE_IMAGE_FAMILY=$SOURCE_IMAGE_FAMILY \
    -var REGION=$REGION \
    -var ZONE=$ZONE \
    -var SSH_USERNAME=$SSH_USERNAME \
    -var SERVICE_ACCOUNT_JSON=$SERVICE_ACCOUNT_JSON \
    -var IMAGE_NAMES_SPACED="${IMAGE_NAMES_SPACED}" \
    -var IMAGE_FAMILY=$IMAGE_FAMILY \
    u18Packer.json 2>&1 | tee output.txt

  cat output.txt
  # this is to get the ami from output
  AMI_ID=$(cat output.txt | awk -F, '$0 ~/artifact,0,id/ {print $6}' | cut -d':' -f 2)
  echo $AMI_ID>ami.txt
}

main() {
  eval `ssh-agent -s`
  ps -eaf | grep ssh
  which ssh-agent

  set_context
  get_image_list
  build_image
}

main
