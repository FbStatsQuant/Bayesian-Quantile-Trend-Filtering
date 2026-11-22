#!/bin/bash
# One individual task inside a Slurm allocation: bash run_task.sh RUN_DIR INDEX
# The method of INDEX (metadata/task_manifest.tsv) selects the worker in its own folder.
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
source "$run/code/Extreme_Individual/path_guard.sh"
require_extreme_path "$run/code"
idx=${2:?INDEX required}
[[ "$idx" =~ ^[1-9][0-9]*$ ]] || exit 2
[[ -n ${SLURM_JOB_ID:-} ]] || { echo 'Run only inside a NOTS Slurm allocation' >&2; exit 2; }
method=$(awk -F'\t' -v i="$idx" 'NR > 1 && $1 == i { print $2 }' "$run/metadata/task_manifest.tsv")
case "$method" in
  pmala) worker=Extreme_Individual/worker_pmala.R ;;
  admm) worker=Extreme_admm/worker_admm.R ;;
  onizuka_lap|onizuka_hs) worker=Extreme_Onizuka/worker_onizuka.R ;;
  *) echo "Index $idx is not in the task manifest" >&2; exit 2 ;;
esac
cd "$run/code"
sha256sum --check --quiet SHA256SUMS
source Extreme_Individual/environment.sh
printf 'task %s method %s host %s job %s started %s\n' "$idx" "$method" "$(hostname)" "$SLURM_JOB_ID" "$(date -u --iso-8601=seconds)"
Rscript --vanilla "$run/code/$worker" "$run" "$idx"
