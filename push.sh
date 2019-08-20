#!/bin/bash

if [ "$DOCKER_HUB_ACCT" != "" ]
then
  docker push ${DOCKER_HUB_ACCT}phylanx.devenv:working
  docker tag phylanx-test ${DOCKER_HUB_ACCT}phylanx.test:working
  docker push ${DOCKER_HUB_ACCT}phylanx.test:working
fi

# Push to remote machine if there is one.
if [ "${REMOTE}" != "" ]
then
  ssh ${REMOTE} singularity build -F ~/images/phylanx-devenv.simg docker://${DOCKER_HUB_ACCT}phylanx.devenv:working
  #ssh ${REMOTE}  bin/build-image.sh ~/images/phylanx-devenv.simg docker://${DOCKER_HUB_ACCT}phylanx.devenv:working
fi
