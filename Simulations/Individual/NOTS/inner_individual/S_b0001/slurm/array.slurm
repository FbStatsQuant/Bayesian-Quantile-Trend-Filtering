#!/bin/bash
#SBATCH --job-name=S_b0001
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
# The --array specification is always given on the sbatch command line (pilot or release).
set -euo pipefail
run=${1:?RUN_DIR required}
source "$run/code/path_guard.sh"
require_package_path "$run/code"
idx=${SLURM_ARRAY_TASK_ID:?Slurm array task ID required}
[[ "$idx" =~ ^[0-9]+$ ]] && ((idx >= 1 && idx <= 1500)) || exit 2
bash "$run/code/run_task.sh" "$run" "$idx"
