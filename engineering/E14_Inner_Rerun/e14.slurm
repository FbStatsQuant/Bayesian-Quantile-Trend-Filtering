#!/bin/bash
# Submit from the run snapshot with the array and log options documented in RUN.md.
#SBATCH --job-name=bqtf-e14
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --mem=3G
#SBATCH --time=03:00:00
#SBATCH --output=/home/fb31/BQTF/runs/E14-inner-rerun-20261125/logs/%x_%A_%a.out

set -euo pipefail

RUN=$(realpath -e "${RUN:-$HOME/BQTF/runs/E14-inner-rerun-20261125}")
case "$RUN" in
    "$(realpath -e "$HOME/BQTF")"/*) ;;
    *) echo "RUN must be under $HOME/BQTF" >&2; exit 2 ;;
esac
code="$RUN/code/engineering/E14_Inner_Rerun"
task="${SLURM_ARRAY_TASK_ID:?Submit as a Slurm array}"
scratch="$HOME/BQTF/tmp/${SLURM_ARRAY_JOB_ID:?}_$task"
cleanup() {
    for attempt in 1 2 3 4 5; do
        if rm -rf -- "$scratch"; then
            return
        fi
        sleep "$attempt"
    done
    echo "Could not remove $scratch" >&2
}
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

export TMPDIR="$scratch/tmp" R_USER_CACHE_DIR="$scratch/rcpp-cache"
mkdir -p "$TMPDIR" "$R_USER_CACHE_DIR" "$RUN/out"
cd "$RUN/code"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library
export OMP_NUM_THREADS=1 OMP_THREAD_LIMIT=1 OPENBLAS_NUM_THREADS=1 GOTO_NUM_THREADS=1
export FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 BLIS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
export RCPP_PARALLEL_NUM_THREADS=1 MAKEFLAGS=-j1

echo "[$(date -Is)] host=$(hostname) task=$task"
Rscript --vanilla "$code/e14_run.R" "$RUN" "$task"
echo "[$(date -Is)] done"
