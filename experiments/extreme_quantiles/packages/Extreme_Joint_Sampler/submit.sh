#!/bin/bash
# PRODUCTION ENTRY POINT. Run ONLY on the user's explicit deployment command:
#   cd /home/fb31/projects/Quant_Reg/Extreme_Joint_Sampler && bash submit.sh UNIQUE_RUN_NAME
# Snapshots this folder into runs/RUN/code (read-only), puts task outputs and logs on scratch, and starts
# the batch chain: batch 1 = VS (300 tasks), then batch 2 = S (300 tasks), each with at most 400 running.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
name=${1:?Usage: bash submit.sh UNIQUE_RUN_NAME}
[[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || exit 2
source "$package/environment.sh"
(cd "$package" && sha256sum --check --quiet SHA256SUMS)
hash=$(sha256sum "$package/SHA256SUMS" | cut -d' ' -f1)
[[ -f "$package/validation/APPROVED_PACKAGE_SHA256" ]] || { echo 'Run the NOTS validation job first (sbatch slurm/validate.slurm)' >&2; exit 2; }
[[ "$hash" == "$(cat "$package/validation/APPROVED_PACKAGE_SHA256")" ]] || { echo 'Package changed since validation; validate again' >&2; exit 2; }
run="$package/runs/$name"
raw="${RAW_BASE:-/scratch/fb31/qr_data/extreme_joint}/$name"
[[ ! -e "$run" && ! -e "$raw" ]] || { echo 'Choose a new run name; existing outputs are preserved' >&2; exit 2; }
mkdir -p "$package/runs" "$raw/tasks" "$raw/logs"
mkdir "$run" "$run/code" "$run/code/Extreme_Joint_Sampler" "$run/metadata" "$run/summary"
ln -s "$raw/tasks" "$run/tasks"; ln -s "$raw/logs" "$run/logs"
(cd "$package" && tar --exclude=./runs --exclude=./validation -cf - .) | (cd "$run/code/Extreme_Joint_Sampler" && tar -xf -)
cd "$run/code"
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
chmod -R a-w "$run/code"
Rscript --vanilla -e 'source("Extreme_Joint_Sampler/config.R"); source("Extreme_Joint_Sampler/common_extreme.R"); validate_config(cfg)
  write.table(task_grid(cfg), "../metadata/task_manifest.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
  b <- batch_table(cfg); b$concurrency <- cfg$concurrency
  write.table(b, "../metadata/batches.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
  dput(cfg, file = "../metadata/config.txt")'
cp SHA256SUMS "$run/metadata/source_SHA256SUMS"
printf '%s\n' "$hash" > "$run/metadata/validated_package_hash.txt"
printf '%s\n' "$raw" > "$run/metadata/raw_location.txt"
{ date -u --iso-8601=seconds; hostname; uname -a; module list; df -h "$raw"; } > "$run/metadata/environment.txt" 2>&1
printf '%q ' "$0" "$@" > "$run/metadata/submission_command.txt"; printf '\n' >> "$run/metadata/submission_command.txt"
: > "$run/metadata/array_jobs.tsv"
bash "$run/code/Extreme_Joint_Sampler/chain.sh" "$run" 1
printf 'Run %s\nTask outputs and logs on %s\nMonitor: bash %s/status.sh %s\n' "$run" "$raw" "$package" "$run"
