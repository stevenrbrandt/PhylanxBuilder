#!/bin/bash

# Configuration
export INSTALL_DIR=$HOME/phylanx/devenv
export EMAIL=sbrandt@cct.lsu.edu
export DOCKER_HUB_ACCT=stevenrbrandt

source ~/.bashrc
set -e
set -x
cd $INSTALL_DIR
docker pull fedora
docker build --no-cache -f phylanx.devenv -t stevenrbrandt/phylanx.devenv .
docker build -f test.docker -t phylanx-test .
docker run --rm phylanx-test cat test-out.txt > test-out.txt
python3 parse.py 
echo $EMAIL > email-body-1.html
echo 'Phylanx Build Status' >> email-body-1.html
if [ $? = 0 ]
then
  docker tag $DOCKER_HUB_ACCT/phylanx.devenv:latest $DOCKER_HUB_ACCT/phylanx.devenv:working
  bash push.sh
  set +e
  docker stop devenv
  sleep 5
  docker run --name devenv --privileged -v devenv_homefs-phylanx:/home/jovyan -d --rm stevenrbrandt/phylanx.devenv:working 
  set -e
  echo '<h1>Succeeded in building phylanx devenv.</h1>' >> email-body-1.html
else
  echo '<h1>Failed to build phylanx devenv.</h1>' >> email-body-1.html
fi
echo '<pre>' >> email-body-1.html
touch test-out.txt
tail -20 test-out.txt >> email-body-1.html
echo '</pre>' >> email-body-1.html
email.pl email-body-1.html
