#!/usr/bin/env bash
set -euo pipefail
: "${E16_RUN_DIR:?run directory required}"
: "${OWLS_JOB_CORES:?start via owls_run}"
[[ $(hostname -s) == owls && $OWLS_JOB_CORES == 1 ]]
script_dir=$(cd "$(dirname "$0")" && pwd)
export R_LIBS_USER="$HOME/R/x86_64-redhat-linux-gnu-library/4.6:$HOME/R/library"
for id in joint_VS_s1_b1e-05_c1001 ind_VS_s1_b1e-05_t50 ind_VS_s1_b1e-05_t90; do
    [[ ! -f "$E16_RUN_DIR/pilot/$id.rds" ]] || continue
    available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
    if (( available < 23 * 1024 * 1024 )); then
        echo "Pilot waiting for at least 23 GiB available memory"
        exit 75
    fi
    printf '[%s] pilot starting %s (MemAvailable %s KiB)\n' "$(date -Is)" "$id" "$available"
    export MAKEFLAGS=-j1
    /usr/bin/time -a -o "$E16_RUN_DIR/pilot/$id.time" -f '%U\t%S\t%e\t%M\t%x' \
        Rscript --vanilla "$script_dir/run.R" pilot "$id" >>"$E16_RUN_DIR/pilot/$id.log" 2>&1
done
Rscript --vanilla "$script_dir/plan.R"
