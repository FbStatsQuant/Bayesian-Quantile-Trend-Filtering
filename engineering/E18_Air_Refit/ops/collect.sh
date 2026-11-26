#!/bin/bash
# Usage: collect.sh [--allow-failures] RUN_ID EXPECTED_RDS_COUNT [SUMMARY_FILE ...]
# Use "-" as the RDS count for output formats that have no per-fit RDS.
set -euo pipefail
umask 077
allow=0
if [[ ${1:-} == --allow-failures ]]; then allow=1; shift; fi
(( $# >= 2 ))
run_id=$1 expected=$2
shift 2
[[ $run_id =~ ^E18-[A-Za-z0-9._-]+$ && $expected =~ ^([0-9]+|-)$ ]]
for file in "$@"; do [[ $file =~ ^[A-Za-z0-9_.-]+$ && $file != .* && $file != E18_RESULTS.sha256 ]]; done
if (( allow )); then set -- "$@" E18_ACCOUNTING.psv; fi
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
nots="$root/engineering/E17_b0_1e5/ops/nots.sh"
dest="$root/runs/$run_id"
[[ ! -e "$dest" ]]
remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
run="$HOME/BQTF/tmp/e18-results/$1"
expected=$2
allow=$3
shift 3
cd "$run"
id=$(cut -d';' -f1 slurm_job_id)
task_count=$(cat slurm_task_count)
out=$(cat slurm_output_dir)
[[ $task_count =~ ^[1-9][0-9]*$ && $out =~ ^[A-Za-z0-9-]+$ ]]
status_tmp=$(mktemp "$run/.E18-accounting.XXXXXXXX")
trap 'rm -f "$status_tmp"' EXIT
sacct -j "$id" -n -P --format=JobID%48,State%32,TotalCPU,ExitCode > "$status_tmp"
awk -F'|' -v number="$task_count" -v allow="$allow" '
        $1 ~ /^[0-9]+_[0-9]+$/ {
            n++
            state=$2
            sub(/[ +].*$/, "", state)
            if (state !~ /^(COMPLETED|FAILED|CANCELLED|TIMEOUT|OUT_OF_MEMORY|NODE_FAIL|PREEMPTED|DEADLINE|BOOT_FAIL|REVOKED)$/ ||
                (!allow && (state != "COMPLETED" || $4 != "0:0"))) bad=1
            if (state != "COMPLETED" || $4 != "0:0") print > "/dev/stderr"
        }
        END {if (n!=number) bad=1; exit bad}
    ' "$status_tmp"
if (( allow )); then
    case "$out:$expected:$task_count" in
        sim:1200:1200|admm-sim:300:300|onizuka-hs:300:300|onizuka-lap:300:300) ;;
        *) echo 'Permissive collection is available for terminal production simulation arrays.' >&2; exit 2 ;;
    esac
    mkdir -p "$out"
    test "$(find "$out" -type f -name '*.rds' -printf . | wc -c)" -le "$expected"
    mv "$status_tmp" E18_ACCOUNTING.psv
else
    failed=$(find "$out" -name '*.fail.rds' -print)
    if [[ -n $failed ]]; then printf '%s\n' "$failed" >&2; exit 5; fi
    if [[ $expected != - ]]; then
        test "$(find "$out" -type f -name '*.rds' -printf . | wc -c)" -eq "$expected"
    fi
    test -n "$(find "$out" -type f -print -quit)"
fi
for file in "$@"; do test -f "$file"; done
tmp=$(mktemp "$run/.E18-results.XXXXXXXX")
trap 'rm -f "$tmp" "$status_tmp"' EXIT
{
    find "$out" -type f -print0
    if (($#)); then printf '%s\0' "$@"; fi
} | LC_ALL=C sort -zu | xargs -0 sha256sum > "$tmp"
mv "$tmp" E18_RESULTS.sha256
sha256sum -c --quiet E18_RESULTS.sha256
sha256sum E18_RESULTS.sha256
printf 'Collected stage directory: %s\n' "$out"
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e18-collect "$run_id" "$expected" "$allow" "$@"
receipt=$(bash "$nots" control "$cmd")
printf '%s\n' "$receipt"
digest=$(awk '$2=="E18_RESULTS.sha256"{print $1}' <<<"$receipt")
out=$(awk '/^Collected stage directory: /{print $4}' <<<"$receipt")
[[ $digest =~ ^[0-9a-f]{64}$ && $out =~ ^[A-Za-z0-9-]+$ ]]

mkdir -p "$root/runs"
stage=$(mktemp -d "$root/runs/.e18-results.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
printf -v cmd ' %q' bash -c '
    set -euo pipefail
    cd "$HOME/BQTF/tmp/e18-results/$1"
    out=$2
    shift 2
    tar -cf - "$out" E18_RESULTS.sha256 "$@"
' e18-pull "$run_id" "$out" "$@"
bash "$nots" bulk "$cmd" | tar -xf - -C "$stage"
(
    cd "$stage"
    if (( allow )); then
        test "$(find "$out" -type f -name '*.rds' -printf . | wc -c)" -le "$expected"
    elif [[ $expected != - ]]; then
        test "$(find "$out" -type f -name '*.rds' -printf . | wc -c)" -eq "$expected"
    fi
    diff -u <(find "$out" -type f | LC_ALL=C sort) \
        <(sed -n "s/^[0-9a-f]\{64\}  \($out\/.*\)$/\1/p" E18_RESULTS.sha256 | LC_ALL=C sort)
    test "$(sha256sum E18_RESULTS.sha256 | cut -d' ' -f1)" = "$digest"
    sha256sum -c --quiet E18_RESULTS.sha256
)
mv -T --no-clobber "$stage" "$dest"
[[ ! -e "$stage" ]]
printf 'Verified %s with manifest %s\n' "$dest" "$digest"
