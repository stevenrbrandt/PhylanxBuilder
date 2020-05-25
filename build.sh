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

if [ "$BUILD_TYPE" = "" ]
then
  export BUILD_TYPE=Debug
fi

# Disable parallel testing in the hopes that tests will pass...
# Ticket https://github.com/STEllAR-GROUP/phylanx/issues/810
#export CTEST_PARALLEL_LEVEL=${USE_PROCS}
#export HPX_COMMANDLINE_OPTIONS=--hpx:bind=none

# For singularity, prevent these from being over-written
unset CC
unset CXX

if [ -w /work/$USER ]
then
  PHX_ROOT=/work/$USER
else
  PHX_ROOT=$HOME
fi

if [ "$CHECKOUT_DIR" = "" ]
then
  export CHECKOUT_DIR=$PHX_ROOT
fi
cd $CHECKOUT_DIR
if [ ! -d phylanx ]
then
  git clone https://github.com/STEllAR-GROUP/phylanx.git
fi

if [ "$BUILD_DIR" = "" ]
then
  export BUILD_DIR=$PHX_ROOT/phylanx/build
fi

if [ "$INSTALL_DIR" = "" ]
then
  export INSTALL_DIR=$PHX_ROOT/install
fi

if [ ! -d $BUILD_DIR ]
then
    CONFIG=1
fi

if [ -d /usr/local/lib64/cmake/HPX ]
then
  HPX_DIR=/usr/local/lib64/cmake/HPX
else
  HPX_DIR=/usr/local/lib/cmake/HPX
fi

if [ $CONFIG = 1 ]
then
  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
  cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
      -DHPX_DIR=$HPX_DIR \
      -DPHYLANX_WITH_TESTS_UNIT=on \
      -DPYTHON_EXECUTABLE=/usr/local/bin/python3 \
      -DPHYLANX_WITH_CXX17=on \
      -DPHYLANX_WITH_TOOLS=on \
      -DBlazeTensor_DIR=/blaze_tensor/build/cmake \
      ..
fi
cd $BUILD_DIR
make -j $USE_PROCS $* 2>&1 | tee make.out
