#!/bin/bash
# E-10 on NOTS: one chain per array task (1 core).  Submit from the run directory's code snapshot, e.g.
#   RUN=/projects/ml75/fb31/BQTF/runs/E10-lambdamix-<date>
#   sbatch --array=0-215%96 --job-name=bqtf-e10-cal -o $RUN/logs/%x_%A_%a.out --export=ALL,RUN=$RUN $RUN/code/nots/e10_job.slurm
# Writes only under $RUN (outputs) and /scratch/fb31/BQTF (compile cache, tmp).  Never writes to NOTS home.
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --mem=3G
#SBATCH --time=03:00:00
set -euo pipefail
: "${RUN:?RUN not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library            # read-only use of the existing library
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
CODE="${CODE:-$RUN/code}"
tag="${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID:-0}"
export E10_CODE="$CODE" E10_OUT="$RUN/out" TMPDIR="/scratch/fb31/BQTF/tmp_$tag"
export R_USER_CACHE_DIR="/scratch/fb31/BQTF/rcpp_cache_$tag"
mkdir -p "$TMPDIR" "$R_USER_CACHE_DIR" "$RUN/logs" "$RUN/out"
echo "[$(date -Is)] host=$(hostname) task=${SLURM_ARRAY_TASK_ID:-none}"
Rscript "$CODE/e10_run.R" "${SLURM_ARRAY_TASK_ID:-0}"
rm -rf "$TMPDIR" "$R_USER_CACHE_DIR"
echo "[$(date -Is)] done"
