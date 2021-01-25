#!/bin/bash

if [ "$DOCKER_HUB_ACCT" != "" ]
then
  docker push ${DOCKER_HUB_ACCT}phylanx${TAG}.devenv:working
  docker tag phylanx-test${TAG} ${DOCKER_HUB_ACCT}phylanx${TAG}.test:working
  docker push ${DOCKER_HUB_ACCT}phylanx${TAG}.test:working
fi

# Push to remote machine if there is one.
if [ "${REMOTE}" != "" ]
then
  ssh ${REMOTE} singularity build -F ~/images/phylanx-devenv${TAG}.simg docker://${DOCKER_HUB_ACCT}phylanx${TAG}.devenv:working
  ssh ${REMOTE} chmod 755 ~/images/phylanx-devenv${TAG}.simg

  ssh ${REMOTE} singularity build -F ~/images/phylanx-test${TAG}.simg docker://${DOCKER_HUB_ACCT}phylanx${TAG}.test:working
  ssh ${REMOTE} chmod 755 ~/images/phylanx-test${TAG}.simg 
  #ssh ${REMOTE}  bin/build-image.sh ~/images/phylanx-devenv.simg docker://${DOCKER_HUB_ACCT}phylanx${TAG}.devenv:working
fi
