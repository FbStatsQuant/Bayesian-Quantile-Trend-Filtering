#!/bin/bash
# Usage: submit.sh interior|extreme pilot|full THROTTLE RUN_ID BUNDLE_HEAD SLURM_PATH [AFTER_JOB_ID]
set -euo pipefail
(( $# == 6 || $# == 7 ))
campaign=$1 phase=$2 throttle=$3 run_id=$4 head=$5 slurm=$6 after=${7:-}
[[ $throttle =~ ^[1-9][0-9]{0,2}$ ]] && (( throttle <= 300 ))
[[ $run_id =~ ^E17-[A-Za-z0-9._-]+$ && $head =~ ^[0-9a-f]{40}$ ]]
[[ $slurm =~ ^[A-Za-z0-9_/-]+[.]slurm$ ]]
[[ -z $after || ( $phase == full && $after =~ ^[0-9]+$ ) ]]
case "$campaign" in
    interior) count=3000 ;;
    extreme) count=3600 ;;
    *) exit 2 ;;
esac
case "$phase" in
    pilot)
        indices=$(git show "$head:engineering/E17_b0_1e5/e17_pilot.R" |
            Rscript --vanilla -e '
                env <- new.env()
                source(file("stdin", open = "r"), local = env)
                cat(paste(env$e17_pilot_indices[[commandArgs(TRUE)[1L]]], collapse = ","))
            ' "$campaign")
        [[ $indices =~ ^[0-9]+(,[0-9]+)*$ ]]
        IFS=, read -r -a selected <<<"$indices"
        count=${#selected[@]}
        if (( throttle > count )); then throttle=$count; fi
        job="bqtf-e17-$campaign-pilot"
        ;;
    full) indices="0-$((count - 1))"; job="bqtf-e17-$campaign" ;;
    *) exit 2 ;;
esac
if (( $(date +%s) < $(TZ=CST6CDT date -d '2026-11-25 21:00:00' +%s) )); then
    echo 'E-17 submission opens at 21:00 CT on November 25' >&2
    exit 2
fi
ops=$(cd "$(dirname "$0")" && pwd)
remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
campaign=$1 throttle=$2 run_id=$3 head=$4 slurm=$5 indices=$6 count=$7 job=$8 after=$9
root="$HOME/BQTF"
staged="$root/tmp/e17-code-$head"
run="$root/tmp/e17-results/$run_id"
code="$run/code"
[[ ! -e "$run/slurm_job_id" ]]
if [[ -d "$run/out" && -n "$(find "$run/out" -type f -print -quit)" ]]; then
    echo 'This run directory already contains results.' >&2
    exit 3
fi
test "$(awk '/^Engineering-Commit:/{print $2}' "$staged/run_manifest.dcf")" = "$head"
(cd "$staged" && sha256sum -c --quiet SHA256SUMS)
test -f "$staged/$slurm"

queue=$(squeue -h -r -u fb31 -p commons -o '%F|%j')
if awk -F'|' -v job="$job" -v after="$after" '
    $2 ~ /^bqtf-e17-/ && ($2 == job || (job !~ /-pilot$/ && $1 != after) ||
        (job ~ /-pilot$/ && $2 !~ /-pilot$/)) {blocked=1}
    END{exit !blocked}
' <<<"$queue"; then
    echo 'An active E-17 array overlaps this submission.' >&2
    exit 4
fi
queued=$(awk 'NF{n++} END{print n+0}' <<<"$queue")
if (( queued + count > 5000 )); then
    printf 'Commons has %s submitted tasks. Waiting for room for %s more.\n' "$queued" "$count" >&2
    exit 4
fi
mkdir -p "$run/logs" "$run/out"
if [[ ! -e "$code" ]]; then cp -a "$staged" "$code"; fi
cmp "$code/SHA256SUMS" "$staged/SHA256SUMS"
(cd "$code" && sha256sum -c --quiet SHA256SUMS)
cd "$run"
dependency=()
if [[ -n $after ]] && awk -F'|' -v after="$after" '$1 == after {found=1} END{exit !found}' <<<"$queue"; then
    dependency=(--dependency="afterany:$after")
fi
id=$(sbatch --parsable --job-name="$job" --partition=commons --mem=768M --cpus-per-task=1 \
    --time=00:15:00 --array="$indices%$throttle" --export="ALL,RUN=$run,E17_CAMPAIGN=$campaign" \
    "${dependency[@]}" --output="$run/logs/%x_%A_%a.out" "$code/$slurm" "$campaign" "$run")
printf 'Submitted %s as %s (%s%%%s)\n' "$job" "$id" "$indices" "$throttle"
printf '%s\n' "$id" > "$run/.slurm_job_id.tmp"
mv "$run/.slurm_job_id.tmp" "$run/slurm_job_id"
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e17-submit "$campaign" "$throttle" "$run_id" "$head" "$slurm" "$indices" "$count" "$job" "$after"
bash "$ops/nots.sh" control "$cmd"
