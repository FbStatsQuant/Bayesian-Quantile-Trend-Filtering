#!/bin/bash
#SBATCH --job-name=bqtf-e18
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:20:00
set -euo pipefail
(( $# == 2 )) || exit 2
stage=$1
run=$(realpath -e "$2")
case "$run" in "$(realpath -e "$HOME/BQTF")"/runs/E18-*) ;; *) exit 2 ;; esac
scratch="$HOME/BQTF/tmp/e18_${SLURM_ARRAY_JOB_ID:?}_${SLURM_ARRAY_TASK_ID:?}"
trap 'rm -rf -- "$scratch"' EXIT
export TMPDIR="$scratch/tmp" R_USER_CACHE_DIR="$scratch/rcpp-cache"
mkdir -p "$TMPDIR" "$R_USER_CACHE_DIR"
cd "$run/code"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
case "$stage" in admm-sim|admm-real) module load GLPK/5.0 ;; esac
export R_LIBS_USER=/home/fb31/R/library
export OMP_NUM_THREADS=1 OMP_THREAD_LIMIT=1 OPENBLAS_NUM_THREADS=1 GOTO_NUM_THREADS=1
export FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 BLIS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
export RCPP_PARALLEL_NUM_THREADS=1 MAKEFLAGS=-j1
Rscript --vanilla engineering/E18_Air_Refit/e18_run.R "$stage" "$run" "$SLURM_ARRAY_TASK_ID"
