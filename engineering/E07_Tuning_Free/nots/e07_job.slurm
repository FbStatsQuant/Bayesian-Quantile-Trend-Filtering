#!/bin/bash
# E-07 on NOTS. Submit from the run directory's code snapshot, e.g.
#   RUN=$HOME/BQTF/runs/E07-tuningfree-20261123
#   sbatch --job-name=bqtf-e07-g0 -c 8 --mem=32G -t 01:00:00 -o $RUN/logs/%x_%j.out --export=ALL,RUN=$RUN,SCRIPT=e07_g0.R $RUN/code/nots/e07_job.slurm
# Writes only under $RUN and $HOME/BQTF/tmp.  Never writes to NOTS home.
#SBATCH --partition=commons
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=01:00:00
set -euo pipefail
: "${RUN:?RUN not set}" "${SCRIPT:?SCRIPT not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library R_LIBS=$HOME/BQTF/ops/Rlib
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
CODE="${CODE:-$RUN/code}"
tag="${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID:-0}"
export E07_DIR="$CODE" E02_DIR="$CODE/e02" E05_DIR="$CODE/e05" E02_KERNEL="$CODE/e02/prox_admm_metric.cpp" E07_OUT="$RUN"
export E02_CACHE="$HOME/BQTF/tmp/rcpp_cache_$tag" E07_CACHE="$HOME/BQTF/tmp/rcpp_cache_$tag" TMPDIR="$HOME/BQTF/tmp/tmp_$tag"
mkdir -p "$E02_CACHE" "$TMPDIR" "$RUN/logs"
echo "[$(date -Is)] host=$(hostname) script=$SCRIPT cpus=$SLURM_CPUS_PER_TASK"
Rscript "$CODE/$SCRIPT" ${ARGS:-}
rm -rf "$E02_CACHE" "$TMPDIR"
echo "[$(date -Is)] done"
