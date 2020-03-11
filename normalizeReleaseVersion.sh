#!/bin/bash -e

if [ $# -ne 1 ]; then
  echo "ERROR!!! need an input string to normalize"
  exit 1
fi
readonly RELEASE="$1"
main() {
  if [ -z "$RELEASE" ]; then
    echo "ERROR!!! Empty release version"
    exit 1
  fi
  if [[ "$RELEASE" == *"master"* ]]; then
    ## For master branch
    export PIPELINES_VERSION="0.0.0-m000"
  elif [[ "$RELEASE" == *"feature-"* ]]; then
    ## For feature branches
    parsed_version=$(echo $RELEASE | cut -d- -f3)
    export PIPELINES_VERSION="0.0.0-f${parsed_version}"
  elif [[ "$RELEASE" == *"bugfix-"* ]]; then
    ## For bugfix branch
    parsed_version=$(echo $RELEASE | cut -d- -f3)
    export PIPELINES_VERSION="0.0.0-b${parsed_version}"
  elif [[ "$RELEASE" == *"release-"* ]]; then
    ## For release branch
    # note that version should be in the format release-1.0.0-m001
    export PIPELINES_VERSION=${RELEASE#release-}
  else
    ## Any non-compatible version results in error
    echo "ERROR!!! Invalid control plane version, exiting installer build process"
    exit 1
  fi
  printf "$PIPELINES_VERSION"
}

main
