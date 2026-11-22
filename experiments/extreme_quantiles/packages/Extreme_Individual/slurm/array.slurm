#!/bin/bash
# Array of individual tasks. Job name, time, memory, index range and the 400-task cap are set by chain.sh.
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
set -euo pipefail
run=${1:?RUN_DIR required}
source "$run/code/Extreme_Individual/path_guard.sh"
require_extreme_path "$run/code"
bash "$run/code/Extreme_Individual/run_task.sh" "$run" "${SLURM_ARRAY_TASK_ID:?array task ID required}"
