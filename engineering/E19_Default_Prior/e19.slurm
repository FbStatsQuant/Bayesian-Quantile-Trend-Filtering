#!/bin/bash
# For the pre-pilot job, export E19_TASK_INDEX. For arrays, use the Slurm index.
# Set RUN and E14_OUT, and pass explicit memory and output options to sbatch.
#SBATCH --job-name=bqtf-e19
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --time=00:15:00

set -euo pipefail

RUN=$(realpath -e "${RUN:?Set the E-19 run directory}")
comparator=$(realpath -e "${E14_OUT:?Set the verified E-14 output directory}")
task="${SLURM_ARRAY_TASK_ID:-${E19_TASK_INDEX:?Set the task index for a non-array job}}"
[[ "$task" =~ ^[0-9]+$ ]]
code="$RUN/code/engineering/E19_Default_Prior"
scratch="$RUN/../../tmp/e19_${SLURM_ARRAY_JOB_ID:-${SLURM_JOB_ID:?}}_$task"
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
export R_LIBS_USER="$HOME/R/library"
export OMP_NUM_THREADS=1 OMP_THREAD_LIMIT=1 OPENBLAS_NUM_THREADS=1 GOTO_NUM_THREADS=1
export FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 BLIS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
export RCPP_PARALLEL_NUM_THREADS=1 MAKEFLAGS=-j1

echo "[$(date -Is)] host=$(hostname) task=$task"
if [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then
    Rscript --vanilla "$code/e19_run.R" "$RUN" --preflight
fi
Rscript --vanilla "$code/e19_run.R" "$RUN" "$task" "$comparator"
echo "[$(date -Is)] done"
