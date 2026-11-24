#!/bin/bash
# E-08 on NOTS: 10 fits (arm x tau), one array task each. Submit from the run directory's code snapshot, e.g.
#   RUN=/projects/ml75/fb31/BQTF/runs/E08-lambdaprior-20261123
#   mkdir -p $RUN/logs $RUN/out
#   sbatch -o $RUN/logs/%x_%A_%a.out --export=ALL,RUN=$RUN $RUN/code/E08_Lambda_Prior/e08_job.slurm
# Layout: $RUN/code/method/individual/{Individual_Sampler_PMALA_Augmented.R,prox_admm_metric.cpp}, $RUN/code/E08_Lambda_Prior/*.R
# Writes only under $RUN and /scratch/fb31/BQTF.  Never writes to NOTS home.
#SBATCH --job-name=bqtf-e08
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00
#SBATCH --array=1-10
set -euo pipefail
: "${RUN:?RUN not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library R_LIBS=/projects/ml75/fb31/BQTF/Rlib
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
tag="${SLURM_ARRAY_JOB_ID:-${SLURM_JOB_ID:-0}}_${SLURM_ARRAY_TASK_ID:-0}"
export BQTF_REPO="$RUN/code"
export E08_CACHE="/scratch/fb31/BQTF/rcpp_cache_e08_$tag" TMPDIR="/scratch/fb31/BQTF/tmp_e08_$tag"
mkdir -p "$E08_CACHE" "$TMPDIR" "$RUN/logs" "$RUN/out"
echo "[$(date -Is)] host=$(hostname) task=${SLURM_ARRAY_TASK_ID} cpus=${SLURM_CPUS_PER_TASK:-1}"
Rscript "$RUN/code/E08_Lambda_Prior/e08_run.R" "$RUN/out" "$SLURM_ARRAY_TASK_ID"
rm -rf "$E08_CACHE" "$TMPDIR"
echo "[$(date -Is)] done"
