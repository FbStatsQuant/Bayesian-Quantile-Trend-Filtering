#!/bin/bash
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
baseline=${2:?VS or S required}
noise=${3:?Normal, Beta or Mixed required}
batch=${4:?batch name (t05, t25, t50, t75, t95) required}
seed=${5:?SEED required}
cd "$run/code"
sha256sum --quiet --check SHA256SUMS
source ./environment.sh
meta="$run/logs/shell/${baseline}_${noise}_${batch}_${seed}_${SLURM_JOB_ID:-manual}.txt"
mkdir -p "$(dirname "$meta")"
exec 3>"$meta"
printf 'started_utc=%s\nhost=%s\npid=%s\n' "$(date -u --iso-8601=seconds)" "$(hostname)" "$$" >&3
printf 'command=' >&3; printf '%q ' Rscript --vanilla "$run/code/worker.R" "$run" "$baseline" "$noise" "$batch" "$seed" >&3; printf '\n' >&3
module list >&3 2>&1
env | sort | grep -E '^(SLURM_|R_LIBS|OMP_|OPENBLAS_|MKL_|LOADEDMODULES=)' >&3 || true
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" >&3' EXIT
Rscript --vanilla "$run/code/worker.R" "$run" "$baseline" "$noise" "$batch" "$seed"
