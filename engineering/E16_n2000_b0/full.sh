#!/usr/bin/env bash
# Control the Owls allocations within one service cgroup for shared CPU accounting.
set -euo pipefail
: "${E16_RUN_DIR:?run directory required}"
: "${INVOCATION_ID:?start in a dedicated systemd user service}"
[[ $(hostname -s) == owls ]]
script_dir=$(cd "$(dirname "$0")" && pwd)
joint_cores=$1
individual_cores=$2
joint_reservation=$3
individual_reservation=$4
(( joint_cores >= 1 && joint_cores <= 4 && individual_cores >= 0 && joint_cores + individual_cores <= 30 ))
unset OWLS_BUDGET_CORES OWLS_MAX_JOBS
shopt -s nullglob
records=("$E16_RUN_DIR"/pilot/*.time "$E16_RUN_DIR"/full/*.time)
E16_PRIOR_CPU_SECONDS=$(awk -F '\t' 'NF == 5 { total += $1 + $2 } END { printf "%.2f\n", total }' "${records[@]}")
export E16_PRIOR_CPU_SECONDS
printf '[%s] Starting E-16 with %s joint and %s individual slots\n' "$(date -Is)" "$joint_cores" "$individual_cores"

group() {
    local cores=$1 status
    shift
    while true; do
        if /usr/bin/taskset -c 0-14,20-79 "$HOME/.config/bvs-hq/owls/owls_run" -j "$cores" -- \
                /usr/bin/python3 "$script_dir/dispatch.py" "$@"; then
            return 0
        else
            status=$?
            if (( status != 75 )); then
                return "$status"
            fi
        fi
        sleep 60
    done
}

group "$joint_cores" joint "$joint_reservation" 0 1 &
jobs=("$!")
individual_groups=$(( (individual_cores + 7) / 8 ))
for (( index = 0; index < individual_groups; index++ )); do
    group_cores=$((individual_cores - 8 * index))
    if (( group_cores > 8 )); then group_cores=8; fi
    group "$group_cores" ind "$individual_reservation" "$index" "$individual_groups" &
    jobs+=("$!")
done

result=0
for pid in "${jobs[@]}"; do
    wait "$pid" || result=$?
done
printf '[%s] All E-16 allocations exited, status %s\n' "$(date -Is)" "$result"
exit "$result"
