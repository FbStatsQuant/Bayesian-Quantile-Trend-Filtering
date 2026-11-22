#!/bin/bash
#SBATCH --job-name=joint_VS_Mixed
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --array=1-100%20
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
set -euo pipefail
run=${1:?Use submit.sh or supply RUN_DIR}
bash "$run/code/run_task.sh" "$run" Mixed "$SLURM_ARRAY_TASK_ID"
