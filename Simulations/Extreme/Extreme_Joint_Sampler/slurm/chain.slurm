#!/bin/bash
# Submits the next batch (or the processing job) after the previous array has ended. Options set by chain.sh.
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
set -euo pipefail
run=${1:?RUN_DIR required}
source "$run/code/Extreme_Joint_Sampler/path_guard.sh"
require_extreme_path "$run/code"
bash "$run/code/Extreme_Joint_Sampler/chain.sh" "$run" "${2:?BATCH required}"
