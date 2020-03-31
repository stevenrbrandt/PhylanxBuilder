#!/bin/bash
cd
set -x
build.sh config install tests > test-out.txt 2>&1
bash versions.sh >> test-out.txt
cd ~/phylanx

# Clean up build
rm -f $(find . -type f -a ! \( -name \*.so\* -o -name physl \) )
