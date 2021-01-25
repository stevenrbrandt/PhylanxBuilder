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
for bt in Release Debug
do
    export BUILD_TYPE=$bt
    for img in apex # apex noapex f30
    do

        echo "=====[BEGIN $bt $img]====="
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
        if [ "$BUILD_TYPE" = "Release" ]
        then
          export TAG=.rel
        else
          export TAG=
        fi
        if [ "$img" = "noapex" ]
        then
          export TAG="$TAG.noapex"
        fi
        if [ "$img" = "f30" ]
        then
          export TAG="$TAG.f30"
        fi
        echo "BUILD_TYPE=$BUILD_TYPE, TAG=$TAG"
        if [ "$img" = "f30" ]
        then
          docker pull fedora:30
        else
          docker pull fedora:26
        fi
        docker build --no-cache --build-arg CPUS=$CPUS --build-arg BUILD_TYPE=$BUILD_TYPE -f ${img}.devenv -t ${DOCKER_HUB_ACCT}phylanx${TAG}.devenv .

        docker build --build-arg CPUS=$CPUS --build-arg BUILD_TYPE=$BUILD_TYPE --build-arg IMAGE=${DOCKER_HUB_ACCT}phylanx${TAG}.devenv -f test.docker -t phylanx-test${TAG} .
        docker run --rm phylanx-test${TAG} cat test-out.txt > test-out-$bt-$img.txt
        cp test-out-$bt-$img.txt test-out.txt
        echo $EMAIL > email-body-$bt-$img.html
        echo 'Phylanx Build Status' >> email-body-$bt-$img.html
        rm -f email-body-$bt-$img.txt
        touch email-body-$bt-$img.txt
        set +e
        python3 parse.py test-out-$bt-$img.txt
        if [ $? = 0 ]
        then
          docker tag ${DOCKER_HUB_ACCT}phylanx${TAG}.devenv:latest ${DOCKER_HUB_ACCT}phylanx${TAG}.devenv:working
          bash push.sh
          set +e
          docker stop devenv
          sleep 5
          docker run --name devenv --privileged -v devenv_homefs-phylanx:/home/jovyan -d --rm ${DOCKER_HUB_ACCT}phylanx${TAG}.devenv:working 
          set -e
          echo "Succeeded in building phylanx $bt $img." >> email-body-$bt-$img.txt
        else
          echo "Failed to build phylanx $bt $img." >> email-body-$bt-$img.txt
        fi
        echo '' >> email-body-$bt-$img.txt
        touch test-out-$bt-$img.txt
        tail -20 test-out-$bt-$img.txt >> email-body-$bt-$img.txt
        mail -s "Auto Update Phylanx for $bt $img" ${EMAIL} < email-body-$bt-$img.txt
        echo "=====[END $bt $img]====="
    done
done
