#!/bin/bash
build.sh install tests > test-out.txt 2>&1
bash versions.sh >> test-out.txt
cd ~/phylanx
#rm -f $(find . -type f -a ! -name \*.so\*)
rm -fr ~/phylanx
mkdir -p ~jovyan/phylanx/build
ln -s ~jovyan/install/phylanx/lib64 ~jovyan/phylanx/build/lib
