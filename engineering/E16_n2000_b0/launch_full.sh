#!/usr/bin/env bash
# Call after reviewing and reporting the successful pilot.
set -euo pipefail
: "${E16_RUN_DIR:?run directory required}"
[[ $(hostname -s) == owls ]]
[[ $# == 3 && $1 =~ ^[1-8]$ ]] || {
    echo "Usage: launch_full.sh <cores> <joint reservation GiB> <individual reservation GiB>" >&2
    exit 2
}
run_dir=$(realpath "$E16_RUN_DIR")
script_dir="$run_dir/source/engineering/E16_n2000_b0"
[[ -s "$run_dir/plan.tsv" && -s "$run_dir/pilot/measurements.csv" ]]
free -g
systemd-run --user --unit=bqtf-e16-full --quiet --working-directory="$PWD" \
    --setenv="E16_RUN_DIR=$run_dir" --setenv=OWLS_BUDGET_CORES=8 --setenv=OWLS_MAX_JOBS=3 \
    -p RestartForceExitStatus=75 -p RestartSec=60s \
    -p "StandardOutput=append:$run_dir/full/unit.log" \
    -p "StandardError=append:$run_dir/full/unit.log" \
    /usr/bin/taskset -c 0-14,20-79 "$HOME/.config/bvs-hq/owls/owls_run" \
    -j "$1" -- /usr/bin/python3 "$script_dir/dispatch.py" --joint-gib "$2" --ind-gib "$3"
