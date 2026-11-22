#!/bin/bash
# One joint task inside a Slurm allocation: bash run_task.sh RUN_DIR INDEX
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
source "$run/code/Extreme_Joint_Sampler/path_guard.sh"
require_extreme_path "$run/code"
idx=${2:?INDEX required}
[[ "$idx" =~ ^[1-9][0-9]*$ ]] || exit 2
[[ -n ${SLURM_JOB_ID:-} ]] || { echo 'Run only inside a NOTS Slurm allocation' >&2; exit 2; }
awk -F'\t' -v i="$idx" 'NR > 1 && $1 == i { found = 1 } END { exit !found }' "$run/metadata/task_manifest.tsv" \
  || { echo "Index $idx is not in the task manifest" >&2; exit 2; }
cd "$run/code"
sha256sum --check --quiet SHA256SUMS
source Extreme_Joint_Sampler/environment.sh
printf 'task %s host %s job %s started %s\n' "$idx" "$(hostname)" "$SLURM_JOB_ID" "$(date -u --iso-8601=seconds)"
Rscript --vanilla "$run/code/Extreme_Joint_Sampler/worker_joint.R" "$run" "$idx"
