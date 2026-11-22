#!/bin/bash
# bash chain.sh RUN_DIR BATCH
# Submits batch BATCH of metadata/batches.tsv as one array (at most `concurrency` tasks running), plus a
# small chain job that runs this script for BATCH + 1 after the whole array has ended (afterany).
# After the last batch it submits the processing job. Only one batch is queued at a time, which keeps
# the queue under NOTS's limit of 5,000 submitted jobs per user.
# SBATCH may point to a stub (validation dry run); default is the real sbatch.
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
batch=${2:?BATCH required}
source "$run/code/Extreme_Individual/path_guard.sh"
require_extreme_path "$run/code"
[[ "$batch" =~ ^[1-9][0-9]*$ ]] || exit 2
SBATCH=${SBATCH:-sbatch}
unset SLURM_MEM_PER_CPU SLURM_MEM_PER_NODE SLURM_MEM_PER_GPU
table="$run/metadata/batches.tsv"
nb=$(($(wc -l < "$table") - 1))
code="$run/code/Extreme_Individual"
log() { printf '%s\t%s\n' "$(date -u --iso-8601=seconds)" "$*" >> "$run/metadata/chain_log.tsv"; }
if ((batch > nb)); then
  job=$($SBATCH --parsable --chdir="$run" --job-name=ext_ind_process --output="$run/logs/process_%j.out" \
        --error="$run/logs/process_%j.err" "$code/slurm/process.slurm" "$run")
  printf '%s\n' "${job%%;*}" > "$run/metadata/process_job_id.txt"
  log "process job ${job%%;*}"
  exit 0
fi
b=
IFS=$'\t' read -r b method first last time mem name conc < <(awk -F'\t' -v b="$batch" 'NR > 1 && $1 == b' "$table") || true
[[ "$b" == "$batch" ]] || { echo "Batch $batch missing from $table" >&2; exit 2; }
arr=$($SBATCH --parsable --chdir="$run" --job-name="$name" --time="$time" --mem="$mem" \
      --array="${first}-${last}%${conc}" --output="$run/logs/%x_%A_%a.out" --error="$run/logs/%x_%A_%a.err" \
      "$code/slurm/array.slurm" "$run")
arr=${arr%%;*}
printf '%s\t%s\t%s\t%s-%s\n' "$batch" "$method" "$arr" "$first" "$last" >> "$run/metadata/array_jobs.tsv"
log "batch $batch ($method, tasks $first-$last, max $conc running) array job $arr"
nxt=$($SBATCH --parsable --dependency="afterany:$arr" --chdir="$run" --job-name=ext_ind_chain --time=00:15:00 \
      --mem=1G --output="$run/logs/chain_%j.out" --error="$run/logs/chain_%j.err" \
      "$code/slurm/chain.slurm" "$run" "$((batch + 1))")
log "chain job ${nxt%%;*} will submit batch $((batch + 1)) after array $arr ends"
printf 'Submitted batch %s (%s): array %s; chain job %s\n' "$batch" "$method" "$arr" "${nxt%%;*}"
