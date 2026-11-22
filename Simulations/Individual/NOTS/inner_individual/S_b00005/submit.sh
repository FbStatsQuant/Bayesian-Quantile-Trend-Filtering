#!/bin/bash
# Creates an immutable run snapshot and submits the PILOT only: seed 1 in all 15 noise x tau cells.
# Usage: bash submit.sh UNIQUE_RUN_NAME
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
name=${1:?Usage: bash submit.sh UNIQUE_RUN_NAME}
[[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || exit 2
cd "$package"
source ./environment.sh
sha256sum --check --quiet SHA256SUMS
run="$package/runs/$name"
raw="${RAW_BASE:-/scratch/fb31/qr_data/inner_individual_S_b00005}/$name"
mkdir -p "$package/runs" "$(dirname "$raw")"
[[ ! -e "$run" && ! -e "$raw" ]] || { echo 'Choose a new run name; existing outputs are preserved' >&2; exit 2; }
mkdir "$run" "$raw"
mkdir "$run/code" "$run/logs" "$run/metadata" "$run/tasks" "$run/summary"
ln -s "$raw" "$run/raw"
cp -a "$package/source" "$package/slurm" "$run/code/"
cp "$package/"*.R "$package/"*.sh "$package/README.md" "$run/code/"
cp "$package/SHA256SUMS" "$run/metadata/package_SHA256SUMS"
cd "$run/code"
Rscript --vanilla preflight.R | tee "$run/metadata/preflight.txt"
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
cp SHA256SUMS "$run/metadata/source_SHA256SUMS"
chmod -R a-w "$run/code"
{ date -u --iso-8601=seconds; hostname; uname -a; module list; df -h "$raw"; } > "$run/metadata/environment.txt" 2>&1
printf '%q ' "$0" "$@" > "$run/metadata/submission_command.txt"; printf '\n' >> "$run/metadata/submission_command.txt"
printf '%s\n' "$raw" > "$run/metadata/raw_location.txt"
cd "$run"
: > metadata/array_jobs.tsv
spec=$(paste -sd, metadata/pilot_task_ids.txt)
printf 'sbatch --parsable --array=%s --chdir=%q %q %q\n' "$spec" "$run" "$run/code/slurm/array.slurm" "$run" >> metadata/launch_commands.txt
job=$(sbatch --parsable --array="$spec" --chdir="$run" "$run/code/slurm/array.slurm" "$run")
job=${job%%;*}
printf 'pilot\t%s\t%s\n' "$job" "$spec" | tee -a metadata/array_jobs.tsv
printf 'Submitted pilot %s\nRun %s\nRaw draws %s\n' "$job" "$run" "$raw"
