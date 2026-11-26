#!/bin/bash
# Usage: submit.sh MODE RUN_ID BUNDLE_HEAD SLURM_PATH ARRAY MEM TIME [WORKER_STAGE]
set -euo pipefail
(( $# == 7 || $# == 8 ))
mode=$1 run_id=$2 head=$3 slurm=$4 array=$5 mem=$6 limit=$7
case "$mode" in sim-pilot|sim|sim-admm|real-pilot|real|real-admm) ;; *) exit 2 ;; esac
case "$mode" in sim-pilot) stage=sim ;; real-pilot) stage=real ;; sim-admm) stage=admm-sim ;;
    real-admm) stage=admm-real ;; *) stage=$mode ;; esac
stage=${8:-$stage}
[[ $stage =~ ^[A-Za-z0-9-]+$ ]]
[[ $run_id =~ ^E18-[A-Za-z0-9._-]+$ && $head =~ ^[0-9a-f]{40}$ ]]
[[ $slurm =~ ^[A-Za-z0-9_/-]+[.]slurm$ && $slurm != *..* ]]
[[ $array =~ ^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$ ]]
[[ $mem =~ ^[1-9][0-9]*[MG]$ && $limit =~ ^[0-9]+:[0-5][0-9]:[0-5][0-9]$ ]]
throttle=${E18_THROTTLE:-300}
[[ $throttle =~ ^[1-9][0-9]{0,2}$ ]] && (( throttle <= 300 ))
count=$(awk -F',' '{
    for (i=1; i<=NF; i++) {
        n=split($i, endpoints, "-")
        first=endpoints[1]+0; last=n==2 ? endpoints[2]+0 : first
        if (last<first || last>4999) exit 2
        for (j=first; j<=last; j++) {if (seen[j]++) exit 2; count++}
    }
    print count
}' <<<"$array")
case "$mode:$count" in
    sim-pilot:6|sim:1200|real-pilot:3|real:24|sim-admm:*|real-admm:*) ;;
    *) echo "Unexpected task count for $mode: $count" >&2; exit 2 ;;
esac
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
mode=$1 run_id=$2 head=$3 slurm=$4 array=$5 mem=$6 limit=$7 throttle=$8 count=$9 stage=${10}
run="$HOME/BQTF/tmp/e18-results/$run_id"
snapshot="$HOME/BQTF/tmp/e18-code-$head"
code="$run/code"
[[ ! -e "$run/slurm_job_id" ]]
if [[ -d "$run/$stage" && -n "$(find "$run/$stage" -type f -print -quit)" ]]; then
    echo 'Existing output requires checking the prior job before submitting again.' >&2
    exit 3
fi
queue=$(squeue -h -r -u fb31 -p commons -o '%j')
if awk '/^bqtf-e18-/{active=1} END{exit !active}' <<<"$queue"; then
    echo 'An E-18 array is already active under the shared throttle.' >&2
    exit 4
fi
queued=$(awk 'NF{n++} END{print n+0}' <<<"$queue")
if (( queued + count > 5000 )); then
    printf 'Commons has %s submitted tasks and needs room for %s more.\n' "$queued" "$count" >&2
    exit 4
fi
(cd "$snapshot" && sha256sum -c --quiet SHA256SUMS)
test -f "$snapshot/$slurm"
mkdir -p "$run/logs"
if [[ ! -e "$code" ]]; then cp -a "$snapshot" "$code"; fi
cmp "$code/SHA256SUMS" "$snapshot/SHA256SUMS"
(cd "$code" && sha256sum -c --quiet SHA256SUMS)
cd "$run"
printf '%s\n' "$count" > "$run/slurm_task_count"
printf '%s\n' "$stage" > "$run/slurm_output_dir"
job=$(sbatch --parsable --job-name="bqtf-e18-$mode" --partition=commons --cpus-per-task=1 \
    --mem="$mem" --time="$limit" --array="$array%$throttle" \
    --export="ALL,RUN=$run,E18_MODE=$mode" --output="$run/logs/%x_%A_%a.out" "$code/$slurm" "$stage" "$run")
printf 'Submitted bqtf-e18-%s as %s (%s%%%s, mem=%s, time=%s)\n' "$mode" "$job" "$array" "$throttle" "$mem" "$limit"
printf '%s\n' "$job" > "$run/.slurm_job_id.tmp"
mv "$run/.slurm_job_id.tmp" "$run/slurm_job_id"
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e18-submit "$mode" "$run_id" "$head" "$slurm" "$array" "$mem" "$limit" "$throttle" "$count" "$stage"
bash "$root/engineering/E17_b0_1e5/ops/nots.sh" control "$cmd"
