#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/path_guard.sh"
run=$(realpath "${1:?RUN_DIR required}")
require_package_path "$run/code"
task=${2:?TASK_ID required}
[[ "$task" =~ ^[1-9][0-9]*$ ]] || exit 2
[[ -n ${SLURM_JOB_ID:-} ]] || { echo 'Run only inside a NOTS Slurm allocation' >&2; exit 2; }
cd "$run/code"
meta="$run/logs/task_${task}_${SLURM_JOB_ID}_$$_shell.txt"
exec 3>"$meta"
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" >&3' EXIT
printf 'started_utc=%s\nhost=%s\npid=%s\n' "$(date -u --iso-8601=seconds)" "$(hostname)" "$$" >&3
printf 'command=' >&3; printf '%q ' Rscript --vanilla "$run/code/worker.R" "$run" "$task" >&3; printf '\n' >&3
sha256sum --check --quiet SHA256SUMS
source ./environment.sh
module list >&3 2>&1
env | sort | grep -E '^(SLURM_|R_LIBS|OMP_|OPENBLAS_|MKL_|LOADEDMODULES=)' >&3 || true
Rscript --vanilla "$run/code/worker.R" "$run" "$task"
