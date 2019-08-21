#!/bin/bash

# Configuration
# Find execution dir
export INSTALL_DIR=$(dirname $(realpath $0))
if [ "$EMAIL" = "" ]
then
  export EMAIL=$(grep 'email.*=' ~/.gitconfig|cut -d= -f2|sed 's/\s//g')
else
  echo "PLEASE SET UP YOUR GIT EMAIL"
  echo "git config --global user.email johndoe@example.com"
  exit 2
fi

# Here we want the dockerhub account with a / or an empty string.
if [ "$DOCKER_HUB_ACCT" = "" ]
then
  export DOCKER_HUB_ACCT=$(docker info|grep Username:|cut -d: -f2|sed 's/\s//g'|sed 's|/*$|/|')
fi

export CPUS=4 #$(($(lscpu|grep '^CPU(s):'|cut -d: -f2|sed 's/\s//g')/2))

echo "CONFIGURATION INFO:"
echo "EMAIL=($EMAIL)"
echo "INSTALL_DIR=($INSTALL_DIR)"
echo "DOCKER_HUB_ACCT=($DOCKER_HUB_ACCT)"
echo "CPUS=${CPUS}"

source ~/.bashrc
set -e
set -x
cd $INSTALL_DIR
docker pull fedora
docker build --no-cache --build-arg CPUS=$CPUS --build-arg BUILD_TYPE=Debug -f phylanx.devenv -t ${DOCKER_HUB_ACCT}phylanx.devenv .

docker build --build-arg IMAGE=${DOCKER_HUB_ACCT}phylanx.devenv -f test.docker -t phylanx-test .
docker run --rm phylanx-test cat test-out.txt > test-out.txt
echo $EMAIL > email-body-1.html
echo 'Phylanx Build Status' >> email-body-1.html
rm -f email-body-1.txt
touch email-body-1.txt
python3 parse.py 
if [ $? = 0 ]
then
  docker tag ${DOCKER_HUB_ACCT}phylanx.devenv:latest ${DOCKER_HUB_ACCT}phylanx.devenv:working
  bash push.sh
  set +e
  docker stop devenv
  sleep 5
  docker run --name devenv --privileged -v devenv_homefs-phylanx:/home/jovyan -d --rm ${DOCKER_HUB_ACCT}phylanx.devenv:working 
  set -e
  echo 'Succeeded in building phylanx devenv.' >> email-body-1.txt
else
  echo 'Failed to build phylanx devenv.' >> email-body-1.txt
fi
echo '' >> email-body-1.txt
touch test-out.txt
tail -20 test-out.txt >> email-body-1.txt
mail -s "Auto Update Phylanx" ${EMAIL} < email-body-1.txt
