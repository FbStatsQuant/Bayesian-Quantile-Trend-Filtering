#!/bin/bash
# Resubmit selected failed tasks of a batch against the run's frozen code (no chaining):
#   bash retry.sh RUN_DIR BATCH INDEX_SPEC        e.g.  bash retry.sh runs/NAME 2 305,411-415
# Completed tasks refuse to run again. Inspect failures first; remove a stale worker.lock only after
# confirming the old job has ended. Re-run processing afterwards: sbatch --chdir=RUN slurm/process.slurm RUN
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
batch=${2:?BATCH required}; spec=${3:?INDEX_SPEC required}
source "$run/code/Extreme_Joint_Sampler/path_guard.sh"
require_extreme_path "$run/code"
[[ "$spec" =~ ^[0-9,-]+$ ]] || exit 2
b=
IFS=$'\t' read -r b method first last time mem name conc < <(awk -F'\t' -v b="$batch" 'NR > 1 && $1 == b' "$run/metadata/batches.tsv") || true
[[ "$b" == "$batch" ]] || { echo "Unknown batch $batch" >&2; exit 2; }
job=$(sbatch --parsable --chdir="$run" --job-name="${name}_retry" --time="$time" --mem="$mem" --array="${spec}%${conc}" \
      --output="$run/logs/%x_%A_%a.out" --error="$run/logs/%x_%A_%a.err" "$run/code/Extreme_Joint_Sampler/slurm/array.slurm" "$run")
printf '%s\t%s_retry\t%s\t%s\n' "$batch" "$method" "${job%%;*}" "$spec" >> "$run/metadata/array_jobs.tsv"
printf '%s\tretry batch %s indices %s array job %s\n' "$(date -u --iso-8601=seconds)" "$batch" "$spec" "${job%%;*}" >> "$run/metadata/chain_log.tsv"
echo "Retry array ${job%%;*}"
