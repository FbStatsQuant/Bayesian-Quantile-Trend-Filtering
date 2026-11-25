#!/usr/bin/env bash
# Call after reviewing and reporting the successful pilot.
set -euo pipefail
: "${E16_RUN_DIR:?run directory required}"
[[ $(hostname -s) == owls ]]
[[ $# == 4 && $1 =~ ^[1-4]$ && $2 =~ ^(0|[1-9][0-9]?)$ ]] && (( $1 + $2 <= 30 )) || {
    echo "Usage: launch_full.sh <joint cores> <individual cores> <joint GiB> <individual GiB>" >&2
    exit 2
}
run_dir=$(realpath "$E16_RUN_DIR")
script_dir="$run_dir/source/engineering/E16_n2000_b0"
[[ -s "$run_dir/plan.tsv" && -s "$run_dir/pilot/measurements.csv" ]]
free -g
systemd-run --user --unit=bqtf-e16-full --quiet --working-directory="$PWD" \
    --setenv="E16_RUN_DIR=$run_dir" \
    -p "StandardOutput=append:$run_dir/full/unit.log" \
    -p "StandardError=append:$run_dir/full/unit.log" \
    /usr/bin/bash "$script_dir/full.sh" "$@"
