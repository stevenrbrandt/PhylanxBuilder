#!/bin/bash
docker push $DOCKER_HUB_ACCT/phylanx.devenv:working
ssh -p 8000 rostam singularity build images/phylanx-devenv.simg docker://$DOCKER_HUB_ACCT/phylanx.devenv:working
