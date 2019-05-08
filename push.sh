#!/bin/bash

if [ "$DOCKER_HUB_ACCT" != "" ]
then
  echo docker push ${DOCKER_HUB_ACCT}phylanx.devenv:working
fi

# Push to remote machine if there is one.
if [ "${REMOTE}" != "" ]
then
  ssh ${REMOTE} singularity build ~/images/phylanx-devenv.simg docker://$DOCKER_HUB_ACCT/phylanx.devenv:working
fi
