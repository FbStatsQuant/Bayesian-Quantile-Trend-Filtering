#!/bin/bash
# Usage: assess_pilots.sh INTERIOR_RUN_ID EXTREME_RUN_ID
set -euo pipefail
(( $# == 2 ))
for id in "$@"; do [[ $id =~ ^E17-[A-Za-z0-9._-]+$ ]]; done
ops=$(cd "$(dirname "$0")" && pwd)
remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
interior="$HOME/BQTF/tmp/e17-results/$1"
extreme="$HOME/BQTF/tmp/e17-results/$2"
ij=$(cut -d';' -f1 "$interior/slurm_job_id")
ej=$(cut -d';' -f1 "$extreme/slurm_job_id")
scratch=$(mktemp -d "$HOME/BQTF/tmp/e17-pilot-accounting.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
sacct -j "$ij,$ej" -n -P --format=JobID%48,State%32,TotalCPU,ExitCode,MaxRSS > "$scratch/raw"
awk -F'|' '$1 ~ /^[0-9]+_[0-9]+[.]batch$/ && $5 != "" {print $1, "MaxRSS", $5}' "$scratch/raw"
awk -F'|' -v interior="$ij" -v extreme="$ej" '
        function seconds(value, sections, clock, n, j, result, days) {
            n = split(value, sections, "-")
            days = n == 2 ? sections[1] : 0
            n = split(sections[n], clock, ":")
            for (j = 1; j <= n; j++) result = result * 60 + clock[j]
            return result + days * 86400
        }
        BEGIN{print "design,index,cpu_seconds,state,exit_code"}
        $1 ~ /^[0-9]+_[0-9]+$/ {
            split($1, task, "_")
            design = task[1] == interior ? "interior" : (task[1] == extreme ? "extreme" : "")
            if (design != "") printf "%s,%s,%.3f,%s,%s\n", design, task[2], seconds($3), $2, $4
        }
    ' "$scratch/raw" > "$scratch/pilot.csv"
cat "$scratch/pilot.csv"
if ! awk -F',' 'NR > 1 && $4 !~ /^(PENDING|RUNNING|COMPLETING|CONFIGURING|SUSPENDED|REQUEUED|RESIZING|SIGNALING|STAGE_OUT)$/ {n++} END{exit n != 12}' "$scratch/pilot.csv"; then
    echo 'Pilot accounting is still in progress. Check again after the monitoring interval.' >&2
    exit 5
fi
cd "$interior/code"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library TMPDIR="$scratch"
Rscript --vanilla engineering/E17_b0_1e5/e17_pilot.R "$interior" "$extreme" "$scratch/pilot.csv"
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e17-assess "$@"
bash "$ops/nots.sh" control "$cmd"
