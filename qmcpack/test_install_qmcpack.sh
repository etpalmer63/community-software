#!/bin/bash

#SBATCH -A nstaff
#SBATCH -C gpu
#SBATCH -N 1
#SBATCH -G 1
#SBATCH -q regular
#SBATCH -t 01:00:00
#SBATCH --job-name=qmcpack_test
#SBATCH --error=qmcpack_test_%A.err
#SBATCH --output=qmcpack_test_%A.out


prgenv=llvm
#testdir= /pscratch/sd/e/epalmer/testing/qmcpack/gpu/3.17.1/llvm/qmcpack/build_gpu/build_perlmutter_Clang16_cpu_real/
testdir=/pscratch/sd/e/epalmer/testing/qmcpack/gpu/3.17.1/llvm/qmcpack/build_gpu/build_perlmutter_Clang16_offload_cuda_real/
 
cd $testdir

module load gpu
module load PrgEnv-$prgenv
module load cray-fftw
module load cray-hdf5-parallel
module load cmake/3.24.3 #<--because default is old
module load python

ctest -V -j 64 -R deterministic --output-on-failure
