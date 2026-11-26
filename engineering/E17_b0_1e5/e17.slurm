#!/bin/bash
#SBATCH --job-name=bqtf-e17
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --mem=768M
#SBATCH --time=00:15:00

set -euo pipefail
(( $# == 2 )) || { echo "Usage: e17.slurm DESIGN RUN_DIR" >&2; exit 2; }
design=$1
run=$(realpath -e "$2")
case "$run" in
    "$(realpath -e "$HOME/BQTF")"/runs/E17-*) ;;
    *) echo "Use an E-17 run directory under ~/BQTF/runs" >&2; exit 2 ;;
esac
task=${SLURM_ARRAY_TASK_ID:?Submit as a Slurm array}
scratch="$HOME/BQTF/tmp/e17_${SLURM_ARRAY_JOB_ID:?}_$task"
cleanup() {
    for attempt in 1 2 3 4 5; do
        if rm -rf -- "$scratch"; then return; fi
        sleep "$attempt"
    done
    echo "Could not remove $scratch" >&2
}
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT
export TMPDIR="$scratch/tmp" R_USER_CACHE_DIR="$scratch/rcpp-cache"
mkdir -p "$TMPDIR" "$R_USER_CACHE_DIR" "$run/out"
cd "$run/code"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library
export OMP_NUM_THREADS=1 OMP_THREAD_LIMIT=1 OPENBLAS_NUM_THREADS=1 GOTO_NUM_THREADS=1
export FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 BLIS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
export RCPP_PARALLEL_NUM_THREADS=1 MAKEFLAGS=-j1
Rscript --vanilla engineering/E17_b0_1e5/e17_run.R "$design" "$run" "$task"
