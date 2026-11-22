#!/bin/bash
#SBATCH --job-name=joint_VS_300
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --array=1-300%60
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
set -euo pipefail
run=${1:?Use submit.sh or supply RUN_DIR}
task=${SLURM_ARRAY_TASK_ID:?Slurm array task ID required}
[[ "$task" =~ ^[0-9]+$ ]] && ((task >= 1 && task <= 300)) || exit 2
noises=(Normal Beta Mixed)
noise=${noises[$(((task - 1) / 100))]}
seed=$(((task - 1) % 100 + 1))
bash "$run/code/run_task.sh" "$run" "$noise" "$seed"
