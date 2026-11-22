#!/bin/bash
# E-02 on NOTS.  Submit from the run directory's code snapshot, e.g.
#   RUN=/projects/ml75/fb31/BQTF/runs/E02-rates-20261122
#   sbatch --array=0-3 --job-name=bqtf-e02-T3 -o $RUN/logs/%x_%A_%a.out --export=ALL,RUN=$RUN,PHASE=T3 $RUN/code/nots/e02_job.slurm
#   sbatch --job-name=bqtf-e02-validate -c 4 -t 04:00:00 -o $RUN/logs/%x_%j.out --export=ALL,RUN=$RUN,PHASE=validate $RUN/code/nots/e02_job.slurm
# Writes only under $RUN (outputs) and /scratch/fb31/BQTF (compile cache, tmp).  Never writes to NOTS home.
#SBATCH --partition=commons
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G
#SBATCH --time=08:00:00
set -euo pipefail
: "${RUN:?RUN not set}" "${PHASE:?PHASE not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library            # read-only use of the existing library (Rcpp, quantreg, SparseM, coda)
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
CODE="${CODE:-$RUN/code}"                          # code snapshot dir (code, code_v2, ...)
export E02_DIR="$CODE" E02_KERNEL="$CODE/prox_admm_metric.cpp" E02_OUT="$RUN" E02_CAL="$CODE/calibration.rds"
tag="${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID:-0}"
export E02_CACHE="/scratch/fb31/BQTF/rcpp_cache_$tag" TMPDIR="/scratch/fb31/BQTF/tmp_$tag"
mkdir -p "$E02_CACHE" "$TMPDIR" "$RUN/logs"
echo "[$(date -Is)] host=$(hostname) phase=$PHASE array=${SLURM_ARRAY_TASK_ID:-none}/${SLURM_ARRAY_TASK_COUNT:-1} cpus=$SLURM_CPUS_PER_TASK"
if [ "$PHASE" = lamsteps ]; then
  Rscript "$CODE/lamsteps_test.R"
elif [ "$PHASE" = e04 ]; then
  Rscript "$CODE/e04_checks.R"
elif [ "$PHASE" = pvg ]; then
  Rscript "$CODE/pmala_vs_gibbs.R"
elif [ "$PHASE" = validate ]; then
  Rscript "$CODE/validate_samplers.R"
else
  Rscript "$CODE/run_grid.R" "$PHASE"
fi
rm -rf "$E02_CACHE" "$TMPDIR"
echo "[$(date -Is)] done"
