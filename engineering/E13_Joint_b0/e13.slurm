#!/bin/bash
# E-13a screen on NOTS: one task of e13_run.R per array index (1 core).  Rows 1-16 = joint runs, 17-48 = individual runs
# (Rscript e13_run.R list).  Runs from the code snapshot $RUN/code; writes only under $RUN and $HOME/BQTF/tmp/<per-task>.
#   RUN=$HOME/BQTF/runs/E13-joint-b0-20261125
#   sbatch --array=1-16  --mem=4G --time=05:00:00 --job-name=bqtf-e13-joint -o $RUN/logs/%x_%A_%a.out --export=ALL,RUN=$RUN $RUN/code/engineering/E13_Joint_b0/e13.slurm
#   sbatch --array=17-48 --mem=2G --time=01:00:00 --job-name=bqtf-e13-ind   -o $RUN/logs/%x_%A_%a.out --export=ALL,RUN=$RUN $RUN/code/engineering/E13_Joint_b0/e13.slurm
# Timing pilot: add --export=...,E13_ITER=400,E13_BURN=300 (output file gets an _it400 suffix).
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
set -euo pipefail
: "${RUN:?RUN not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
i=${SLURM_ARRAY_TASK_ID:?array index}
tag="${SLURM_ARRAY_JOB_ID:-$SLURM_JOB_ID}_$i"
export E13_ROOT="$RUN/code" E13_OUT="$RUN" TMPDIR="$HOME/BQTF/tmp/e13_$tag" R_USER_CACHE_DIR="$HOME/BQTF/tmp/e13_$tag/cache"
mkdir -p "$TMPDIR" "$R_USER_CACHE_DIR" "$RUN/logs" "$RUN/out" "$RUN/crash"
trap 'rm -rf "$TMPDIR"' EXIT
echo "[$(date -Is)] host=$(hostname) task=$i"
cd "$E13_ROOT"
Rscript "$E13_ROOT/engineering/E13_Joint_b0/e13_run.R" task "$i" "${E13_ITER:-30000}" "${E13_BURN:-10000}"
echo "[$(date -Is)] done"
