#!/bin/bash
cd
set -x

export BUILD_DIR=/usr/local/build
export INSTALL_DIR=/usr/local/phylanx
export PYTHONUSERBASE=/usr/local/userbase
#export BRANCH=distributed_performance

# I don't understand why this is necessary
export PYTHON_DIR=$(python3 -c 'import sys; print("/usr/local/userbase/lib/python%d.%d/site-packages" % (sys.version_info.major, sys.version_info.minor))')

mkdir -p $PYTHON_DIR
build.sh config install 
build.sh tests > test-out.txt 2>&1
bash versions.sh >> test-out.txt
cd ~/phylanx

# Clean up build
cd $BUILD_DIR
rm -f $(find . -type f -a ! \( -name \*.so\* -o -name physl \) )
