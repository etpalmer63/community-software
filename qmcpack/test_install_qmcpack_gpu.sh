#!/bin/bash

#SBATCH -A nstaff
#SBATCH -C gpu
#SBATCH -N 1
#SBATCH -G 1
#SBATCH -q regular
#SBATCH -t 01:30:00
#SBATCH --job-name=qmcpack_test_gpu
#SBATCH --error=qmcpack_test_gpu%A.err
#SBATCH --output=qmcpack_test_gpu%A.out


testdir=/pscratch/sd/e/epalmer/testing/qmcpack/gpu/3.17.1/llvm/qmcpack/build_gpu/build_perlmutter_Clang16_offload_cuda_real/
 
cd $testdir

module load PrgEnv-llvm
module load gpu
module load cray-fftw
module load cray-hdf5-parallel
module load cmake/3.24.3 #<--because default is old
module load python

ctest -V -j 256 -R deterministic --output-on-failure

testdir=/pscratch/sd/e/epalmer/testing/qmcpack/gpu/3.17.1/llvm/qmcpack/build_gpu/build_perlmutter_Clang16_offload_cuda_real_MP/
 
cd $testdir

ctest -V -j 256 -R deterministic --output-on-failure

testdir=/pscratch/sd/e/epalmer/testing/qmcpack/gpu/3.17.1/llvm/qmcpack/build_gpu/build_perlmutter_Clang16_offload_cuda_cplx/
 
cd $testdir

ctest -V -j 256 -R deterministic --output-on-failure

testdir=/pscratch/sd/e/epalmer/testing/qmcpack/gpu/3.17.1/llvm/qmcpack/build_gpu/build_perlmutter_Clang16_offload_cuda_cplx_MP/

cd $testdir

ctest -V -j 256 -R deterministic --output-on-failure
