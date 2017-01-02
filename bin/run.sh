#!/bin/bash
IMAGE_NAME=matteocng/travis-test:latest
ADDITIONAL_OPTIONS=''
VOLUME_DIR='/app'
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

if [ $# -eq 0 ]; then
  echo "Provide the command you wish to run as an argument to this script"
  echo "Example: ./scripts/run.sh yarn test"
  exit 1
fi
if [ -z $(docker images -q $IMAGE_NAME) ] ; then
  echo "Docker image $IMAGE_NAME does not exist locally, build it first"
fi

docker run $ADDITIONAL_OPTIONS -itv ~/.docker-linux-tinycore-cache:/root/yarn-cache -v "$(pwd)":"$VOLUME_DIR" "$IMAGE_NAME" "$@"
