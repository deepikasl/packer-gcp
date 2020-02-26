#!/bin/bash -e

set -o pipefail

build_image() {
  echo "-----------------------------------"
  echo "validating image template"
  echo "-----------------------------------"

  packer validate packer.json

  echo "-----------------------------------"
  echo "building image"
  echo "-----------------------------------"

  packer build packer.json
}

distribute_images() {
  echo "-----------------------------------"
  echo "distributing images"
  echo "-----------------------------------"

  gcloud compute images create u16-poc-asia-east1 --source-image u16-poc-us-west1 --source-image-project gcp-dn --storage-location asia-east1
  gcloud compute images create u16-poc-europe-west2 --source-image u16-poc-us-west1 --source-image-project gcp-dn --storage-location europe-west2
}

make_image_public() {
  echo "-----------------------------------"
  echo "making images public"
  echo "-----------------------------------"

  gcloud compute images add-iam-policy-binding u16-poc-us-west1 --member='allAuthenticatedUsers' --role='roles/compute.imageUser'
  gcloud compute images add-iam-policy-binding u16-poc-asia-east1 --member='allAuthenticatedUsers' --role='roles/compute.imageUser'
  gcloud compute images add-iam-policy-binding u16-poc-europe-west2 --member='allAuthenticatedUsers' --role='roles/compute.imageUser'
}

main() {
build_image
distribute_images
make_image_public

}

main
