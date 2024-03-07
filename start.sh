#!/bin/bash

source preamble.sh
echo Using Docker Compose executable: $DOCKER_COMPOSE

DOCKER_COMPOSE_FILE=docker-compose.yaml

ARCHITECTURE=$(uname -m)
if [ $ARCHITECTURE = "arm" ] || [ $ARCHITECTURE = "arm64" ] || [ $ARCHITECTURE = "aarch64" ]; then
  DOCKER_COMPOSE_FILE=docker-compose.arm.yaml
  sed_i () { sed -i '' "$@"; }
else
  # Linux x86_64 has GNU sed with a slightly different syntax
  sed_i () { sed -i "$@"; }
fi

TARGET_PORTS=$(sm2 --ports | awk '{ print $1 }' | uniq | grep -vxF "0" | grep -vxF "6099" | grep -vxF "7900" | paste -sd "," -),11000,27017,$EXTRA_PORTS

# add or replace target ports in .env that should be accessible by browser on localhost
# we have to add them to the .env file so they are available if using lima nerdctl which
# doesn't copy environment variables from the current process into the vm running docker
# WARNING: lima nerdctl doesn't support alternatively named env files via composes env_file
touch .env 
sed_i '/^TARGET_PORTS=/d' .env
echo "TARGET_PORTS=$TARGET_PORTS" >> .env

$DOCKER_COMPOSE --file="$DOCKER_COMPOSE_FILE" up --detach --build
