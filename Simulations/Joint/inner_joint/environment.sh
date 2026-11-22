#!/bin/bash
# Source after set -euo pipefail. NOTS toolchain and single-threaded BLAS.
module purge
module load GCC/14.3.0
module load R/4.5.2
export R_LIBS_USER="/home/fb31/R/library${R_LIBS_USER:+:$R_LIBS_USER}"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
export BLIS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
