#!/bin/bash
# E-10 joint check on NOTS (1 core per task): 0 = E-10 code, poly move | 1 = E-10 code, spline move (fixed grid) | 2 = pre-E-10 joint code (HEAD 6b2a9a0)
#   sbatch --array=0-2 --job-name=bqtf-e10-joint -o $RUN/joint/logs/%x_%A_%a.out --export=ALL,RUN=$RUN $RUN/code_joint/new/joint/e10_joint.slurm
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=03:00:00
set -euo pipefail
: "${RUN:?RUN not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
i=${SLURM_ARRAY_TASK_ID:-0}; rules=(poly fixed head); trees=(new new head)
export E10_JOINT_DIR="$RUN/code_joint/${trees[$i]}/joint" E10_OUT="$RUN/joint" TMPDIR="$HOME/BQTF/tmp/tmp_${SLURM_JOB_ID}_$i"
mkdir -p "$TMPDIR" "$RUN/joint/logs"
echo "[$(date -Is)] host=$(hostname) task=$i rule=${rules[$i]} tree=${trees[$i]}"
Rscript "$RUN/code_joint/new/joint/e10_joint_check.R" "${rules[$i]}"
rm -rf "$TMPDIR"
echo "[$(date -Is)] done"
