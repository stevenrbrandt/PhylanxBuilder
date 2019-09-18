#!/bin/bash
PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
if [ "$USE_PROCS" = "" ]
then
  USE_PROCS=$(($PROCS/2))
fi
if [ "$1" = "config" ]
then
    shift
    CONFIG=1
else
    CONFIG=0
fi

# Ticket https://github.com/STEllAR-GROUP/phylanx/issues/810
export CTEST_PARALLEL_LEVEL=${USE_PROCS}
export HPX_COMMANDLINE_OPTIONS=--hpx:bind=none

# For singularity, prevent these from being over-written
unset CC
unset CXX
cd
if [ ! -d ~/phylanx ]
then
  git clone https://github.com/STEllAR-GROUP/phylanx.git
fi
if [ ! -d ~/phylanx/build ]
then
    CONFIG=1
fi
if [ $CONFIG = 1 ]
then
  mkdir -p ~/phylanx/build
  cd ~/phylanx/build
  cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_INSTALL_PREFIX=$HOME/install/phylanx \
      -DHPX_DIR=/usr/local/lib64/cmake/HPX \
      -DPHYLANX_WITH_TESTS_UNIT=on \
      -DPYTHON_EXECUTABLE=/usr/local/bin/python3 \
      -DPHYLANX_WITH_CXX17=on \
      -DPHYLANX_WITH_TOOLS=on \
      -DBlazeTensor_DIR=/blaze_tensor/build/cmake \
      ..
fi
cd ~/phylanx/build
make -j $USE_PROCS $* 2>&1 | tee make.out
