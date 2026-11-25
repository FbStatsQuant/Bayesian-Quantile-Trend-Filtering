#!/bin/bash
# E-06 on NOTS.  Submit from the run directory's code snapshot, e.g.
#   RUN=$HOME/BQTF/runs/E06-ratevalid-<date>
#   c=$(sbatch --parsable --job-name=bqtf-e06-cal -c 16 -t 01:00:00 -o $RUN/logs/%x_%j.out --export=ALL,RUN=$RUN,PHASE=cal $RUN/code/nots/e06_job.slurm)
#   sbatch --dependency=afterok:$c --array=0-3 --job-name=bqtf-e06-main -o $RUN/logs/%x_%A_%a.out --export=ALL,RUN=$RUN,PHASE=main $RUN/code/nots/e06_job.slurm
# Writes only under $RUN (outputs) and $HOME/BQTF/tmp (compile cache, tmp).  Never writes to NOTS home.
#SBATCH --partition=commons
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G
#SBATCH --time=06:00:00
set -euo pipefail
: "${RUN:?RUN not set}" "${PHASE:?PHASE not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library            # read-only use of the existing library (Rcpp, quantreg, SparseM, coda)
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
CODE="${CODE:-$RUN/code}"
export E06_DIR="$CODE" E02_DIR="$CODE" E02_KERNEL="$CODE/prox_admm_metric.cpp" E06_OUT="$RUN"
tag="${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID:-0}"
export E02_CACHE="$HOME/BQTF/tmp/rcpp_cache_$tag" TMPDIR="$HOME/BQTF/tmp/tmp_$tag"
mkdir -p "$E02_CACHE" "$TMPDIR" "$RUN/logs"
echo "[$(date -Is)] host=$(hostname) phase=$PHASE array=${SLURM_ARRAY_TASK_ID:-none}/${SLURM_ARRAY_TASK_COUNT:-1} cpus=$SLURM_CPUS_PER_TASK"
if [ "$PHASE" = cal ]; then
  Rscript "$CODE/e06_calibrate.R"
elif [ "$PHASE" = analyze ]; then
  Rscript "$CODE/e06_analyze.R"
else
  Rscript "$CODE/e06_run.R" "$PHASE"
fi
rm -rf "$E02_CACHE" "$TMPDIR"
echo "[$(date -Is)] done"
