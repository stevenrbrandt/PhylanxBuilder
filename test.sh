#!/bin/bash
build.sh install tests > test-out.txt 2>&1
cd ~/phylanx
rm -f $(find . -type f -a ! -name \*.so\*)
