#!/bin/bash

set -e

target=${target:=cpu}
prgenv=${prgenv:=gnu}
version=${version:=3.17.1}
name=qmcpack

#prefix_root=${prefix_root:= /global/common/software/nersc/testing}
prefix_root=${prefix_root:=$SCRATCH/testing}


prefix=$prefix_root/$name/$version/$prgenv

#if [ -d "$prefix" ]; then
#    echo "Prefix directory exists. Please verify install location."
#    exit 1
#fi
#mkdir -p $prefix

# Get source from GitHub
if ! [ -e $prefix/qmcpack ]; then
    cd $prefix
    git clone https://github.com/QMCPACK/qmcpack.git
fi

cd $prefix/qmcpack
git checkout v${version}


module load PrgEnv-$prgenv
module load cray-fftw
module load cray-hdf5-parallel
module load cmake/3.24.3 #<--because default is old

pwd
ls

build_dir=$prefix/qmcpack/build_$target
mkdir -p $build_dir
cd $build_dir

module list
pwd

cmake .. -DCMAKE_SYSTEM_NAME=CrayLinuxEnvironment \
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
    -DQMC_COMPLEX=ON \
    -DQMC_MIXED_PRECISION=ON \
    -DENABLE_OFFLOADS=OFF \
    -DENABLE_CUDA=OFF


cmake --build . -j16


if [ $? -eq 0 ]; then
    cmake --install .
fi


## Run tests
##
## WARNING: For QMCPACK, there are a lot of tests.

# ctest
