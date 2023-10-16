#!/bin/bash

set -e

target=${target:=gpu}
prgenv=${prgenv:=llvm}
version=${version:=3.17.1}
name=qmcpack

#prefix_root=${prefix_root:= /global/common/software/nersc/testing}
prefix_root=${prefix_root:=$SCRATCH/testing}


prefix=$prefix_root/$name/$target/$version/$prgenv

#if [ -d "$prefix" ]; then
#    echo "Prefix directory exists. Please verify install location."
#    exit 1
#fi
if ! [ -d "$prefix" ]; then
    mkdir -p $prefix
fi

# Get source from GitHub
if ! [ -e $prefix/qmcpack ]; then
    cd $prefix
    git clone https://github.com/QMCPACK/qmcpack.git
fi

cd $prefix/qmcpack
#git checkout v${version}


module load gpu
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

export CC=$(which cc) CXX=$(which CC) FC=$(which ftn)

#cmake .. -DCMAKE_SYSTEM_NAME=CrayLinuxEnvironment \
#    -DCMAKE_INSTALL_PREFIX=$(pwd)/install_dir \
#    -DQMC_COMPLEX=ON \
#    -DQMC_MIXED_PRECISION=ON \
#    -DQMC_GPU_ARCHS=sm_80 \
#    -DENABLE_OFFLOAD=ON \
#    -DENABLE_CUDA=ON
#
##    -DCMAKE_C_COMPILER='cc' \
##    -DCMAKE_CXX_COMPILER='CC' \


#echo "**********************************"
#echo '$ clang -v'
#clang -v
#echo "**********************************"

TYPE=Release
Machine=perlmutter
Compiler=Clang16

#if [[ $# -eq 0 ]]; then
#  source_folder=`pwd`
#elif [[ $# -eq 1 ]]; then
#  source_folder=$1
#else
#  source_folder=$1
#  install_folder=$2
#fi

source_folder=$prefix/qmcpack


if [[ -f $source_folder/CMakeLists.txt ]]; then
  echo Using QMCPACK source directory $source_folder
else
  echo "Source directory $source_folder doesn't contain CMakeLists.txt. Pass QMCPACK source directory as the first argument."
  exit
fi

for name in offload_cuda_real_MP offload_cuda_real offload_cuda_cplx_MP offload_cuda_cplx \
            cpu_real_MP cpu_real cpu_cplx_MP cpu_cplx
do

CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=$TYPE -DBLAS_LIBRARIES=$CRAY_LIBSCI_LIB"

if [[ $name == *"cplx"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DQMC_COMPLEX=ON"
fi

if [[ $name == *"_MP"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DQMC_MIXED_PRECISION=ON"
fi

if [[ $name == *"offload"* || $name == *"cuda"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DQMC_GPU_ARCHS=sm_80"
fi

if [[ $name == *"offload"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DENABLE_OFFLOAD=ON"
fi

if [[ $name == *"cuda"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DENABLE_CUDA=ON"
fi

folder=build_${Machine}_${Compiler}_${name}

if [[ -v install_folder ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_INSTALL_PREFIX=$install_folder/$folder"
fi

echo "**********************************"
echo "$folder"
echo "$CMAKE_FLAGS"
echo "**********************************"

mkdir $folder
cd $folder

if [ ! -f CMakeCache.txt ] ; then
cmake $CMAKE_FLAGS -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx $source_folder
fi

if [[ -v install_folder ]]; then
  make -j16 install && chmod -R -w $install_folder/$folder
else
  make -j16
fi

cd ..

echo
done



cmake --build . -j16


if [ $? -eq 0 ]; then
    cmake --install .
fi


## Run tests
##
## WARNING: For QMCPACK, there are a lot of tests.

# ctest
