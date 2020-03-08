#!/bin/bash -e
pull_images() {
  for IMAGE_NAME in $IMAGE_NAMES_SPACED; do
    echo "Pulling -------------------> $IMAGE_NAME"
    sudo docker pull $IMAGE_NAME
  done
}

pull_images
