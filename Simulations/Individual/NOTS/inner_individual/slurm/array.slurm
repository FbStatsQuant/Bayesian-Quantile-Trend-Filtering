#!/bin/bash
#SBATCH --job-name=inner_individual
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=04:00:00
#SBATCH --array=1-3000%400
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
set -euo pipefail
run=${1:?RUN_DIR required}
source "$run/code/path_guard.sh"
require_inner_individual_path "$run/code"
idx=${SLURM_ARRAY_TASK_ID:?Slurm array task ID required}
[[ "$idx" =~ ^[0-9]+$ ]] && ((idx >= 1 && idx <= 3000)) || exit 2
bash "$run/code/run_task.sh" "$run" "$idx"
