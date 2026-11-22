#!/bin/bash
# One task per line of metadata/task_index.tsv; submit.sh sets --array (indices and the concurrency cap).
# Expected ~1 h per task (previous interior run: median 0.77 h, max 1.42 h); 8 h is a generous ceiling.
#SBATCH --job-name=joint_interior
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=08:00:00
#SBATCH --output=logs/slurm/%x_%A_%a.out
#SBATCH --error=logs/slurm/%x_%A_%a.err
set -euo pipefail
run=${1:?Use submit.sh or supply RUN_DIR}
offset=${2:-0}
task=$((${SLURM_ARRAY_TASK_ID:?Slurm array task ID required} + offset))
# The index is task_grid() from common.R (seed fastest, then batch, noise, baseline), written at submission.
line=$(awk -F'\t' -v t="$task" '$1 == t' "$run/metadata/task_index.tsv")
[[ -n "$line" ]] || { echo "Task $task not in task_index.tsv" >&2; exit 2; }
IFS=$'\t' read -r index baseline noise batch seed <<< "$line"
[[ "$index" == "$task" ]] || exit 2
# DECODE_ONLY=1 prints the task instead of running it (used by validate.sh).
if [[ "${DECODE_ONLY:-0}" == 1 ]]; then printf '%s\t%s\t%s\t%s\t%s\n' "$task" "$baseline" "$noise" "$batch" "$seed"; exit 0; fi
bash "$run/code/run_task.sh" "$run" "$baseline" "$noise" "$batch" "$seed"
