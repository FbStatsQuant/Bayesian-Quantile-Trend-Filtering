#!/bin/bash
# Usage: collect.sh interior|extreme RUN_ID NEW_OWLS_DIRECTORY
set -euo pipefail
umask 077
(( $# == 3 ))
campaign=$1 run_id=$2 dest=$3
[[ $run_id =~ ^E17-[A-Za-z0-9._-]+$ && ! -e $dest ]]
case "$campaign" in interior) count=3000 ;; extreme) count=3600 ;; *) exit 2 ;; esac
ops=$(cd "$(dirname "$0")" && pwd)
remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
run="$HOME/BQTF/tmp/e17-results/$1"
campaign=$2 count=$3
cd "$run"
id=$(cut -d';' -f1 slurm_job_id)
scratch=$(mktemp -d "$HOME/BQTF/tmp/e17-collect.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
sacct -j "$id" -n -P --format=JobID%48,State%32,TotalCPU,ExitCode |
    awk -F'|' '$1 ~ /^[0-9]+_[0-9]+$/' > "$scratch/sacct"
if ! awk -F'|' -v expected="$count" '
    $2 ~ /^(PENDING|RUNNING|COMPLETING|CONFIGURING|SUSPENDED|REQUEUED|RESIZING|SIGNALING|STAGE_OUT)$/ {active++}
    END{exit NR != expected || active}' "$scratch/sacct"; then
    echo 'Production accounting is not terminal. Check again after the monitoring interval.' >&2
    exit 5
fi
awk -F'|' '
    function seconds(v, p, clock, n, i, days, sec) {
        n=split(v,p,"-"); days=n==2?p[1]:0
        n=split(p[n],clock,":")
        for(i=1;i<=n;i++) sec=60*sec+clock[i]
        return sec+days*86400
    }
    {cpu+=seconds($3); states[$2]++}
    END{for (s in states) print states[s],s; printf "TotalCPU core-hours: %.6f\n",cpu/3600}
' "$scratch/sacct"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library TMPDIR="$scratch"
Rscript --vanilla code/engineering/E17_b0_1e5/ops/validate_outputs.R "$campaign" "$run"
awk -F'|' '$2!="COMPLETED" || $4!="0:0"{bad=1; print > "/dev/stderr"} END{exit bad}' "$scratch/sacct"
{
    printf '%s\n' e17_summary.csv e17_health.csv
    find out -type f -name '*.rds' -print
} | LC_ALL=C sort | xargs -d '\n' sha256sum > "$scratch/hashes"
test "$(wc -l < "$scratch/hashes")" -eq "$((count+2))"
mv "$scratch/hashes" E17_RESULTS.sha256
sha256sum -c --quiet E17_RESULTS.sha256
sha256sum E17_RESULTS.sha256
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e17-collect "$run_id" "$campaign" "$count"
receipt=$(bash "$ops/nots.sh" control "$cmd") || { status=$?; printf '%s\n' "$receipt"; exit "$status"; }
printf '%s\n' "$receipt"
digest=$(awk '$2 == "E17_RESULTS.sha256" {print $1}' <<<"$receipt")
[[ $digest =~ ^[0-9a-f]{64}$ ]]

mkdir -p "$(dirname "$dest")"
stage=$(mktemp -d "$(dirname "$dest")/.e17-results.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
printf -v cmd ' %q' bash -c '
    set -euo pipefail
    cd "$HOME/BQTF/tmp/e17-results/$1"
    sha256sum -c --quiet E17_RESULTS.sha256 >&2
    tar -cf - out e17_summary.csv e17_health.csv E17_RESULTS.sha256
' e17-pull "$run_id"
bash "$ops/nots.sh" bulk "$cmd" | tar -xf - -C "$stage"
(
    cd "$stage"
    test "$(find out -maxdepth 1 -type f -name '*.rds' -printf . | wc -c)" -eq "$count"
    test "$(wc -l < e17_summary.csv)" -eq "$((count+1))"
    test "$(sha256sum E17_RESULTS.sha256 | cut -d' ' -f1)" = "$digest"
    sha256sum -c --quiet E17_RESULTS.sha256
)
mv -T --no-clobber "$stage" "$dest"
[[ ! -e "$stage" ]]
printf 'Verified %s results in %s with manifest %s\n' "$count" "$dest" "$digest"
