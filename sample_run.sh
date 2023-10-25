#! /bin/bash

set -eu
set -o pipefail

# params - base
DOCKER_USER=user
BASE_IMAGENAME=devc-ubuntu22:rust
BASE_DOCKERFILE=Dockerfile.silipwn
BASE_CONTAINERNAME=lib-replacer

# default mount volumes
DEFAULT_MOUNTS=(
#   "--volume /tmp/.X11-unix:/tmp/.X11-unix"
    "--volume $HOME:/host_home"
    "--volume $HOME/Dropbox:/home/$DOCKER_USER/Dropbox"
    "--volume /mnt/data/Code:/home/$DOCKER_USER/code" # Specific to local code installation
    "--volume $HOME/.ssh:/home/$DOCKER_USER/.ssh"
)

# stop running devc container
echo ">> [0] stopping (and removing) existing container if any..."
! docker container stop $BASE_CONTAINERNAME
! docker container rm --force $BASE_CONTAINERNAME

# update base image
echo ">> [1] updating base image..."
docker image build \
	${@:1} \
	--build-arg UID=$(id -u) --build-arg GID=$(id -g) \
	--tag ${BASE_IMAGENAME} \
	--file ${BASE_DOCKERFILE} .

# build container
echo ">> [2] creating and running the proj container..."
docker container run \
	-it \
	--label="no-prune" \
	--name ${BASE_CONTAINERNAME} \
	--hostname ${BASE_CONTAINERNAME} \
	${DEFAULT_MOUNTS[@]} \
	${BASE_IMAGENAME}

# Disabled the DISPLAY var, cause running via SSH
#       --env DISPLAY=$DISPLAY \
