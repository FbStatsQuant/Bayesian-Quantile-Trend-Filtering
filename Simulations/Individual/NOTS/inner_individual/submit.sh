#!/bin/bash
# Manual entry point, to be used ONLY after the user's explicit deployment approval.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
name=${1:?Usage: bash submit.sh UNIQUE_RUN_NAME (after approval)}
[[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || exit 2
cd "$package"
source ./environment.sh
sha256sum --check SHA256SUMS
# Require a successful NOTS validation of exactly this package, including source/config.
[[ -f validation/APPROVED_PACKAGE_SHA256 ]] || { echo 'Run the NOTS validation job first' >&2; exit 2; }
[[ $(sha256sum SHA256SUMS | cut -d' ' -f1) == $(cat validation/APPROVED_PACKAGE_SHA256) ]] || {
  echo 'Package changed since validation; validate the new package' >&2; exit 2;
}
run="$package/runs/$name"
raw="${RAW_BASE:-/scratch/fb31/qr_data/inner_individual}/$name"
mkdir -p "$package/runs" "$(dirname "$raw")"
[[ ! -e "$run" && ! -e "$raw" ]] || { echo 'Choose a new run name; existing outputs are preserved' >&2; exit 2; }
mkdir "$run" "$raw"
mkdir "$run/code" "$run/logs" "$run/metadata" "$run/tasks" "$run/summary"
ln -s "$raw" "$run/raw"
cp -a "$package/source" "$package/slurm" "$package/paper_reference" "$run/code/"
cp "$package/"*.R "$package/"*.sh "$package/"*.py "$package/README.md" "$run/code/"
cp "$package/SHA256SUMS" "$run/metadata/package_SHA256SUMS"
cp "$package/validation/APPROVED_PACKAGE_SHA256" "$run/metadata/validated_package_hash.txt"
[[ ! -d "$package/audit" ]] || cp -a "$package/audit" "$run/metadata/preparation_audit"
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
# One 3,000-task array, with the user's requested cap of 400 concurrent fits.
printf 'sbatch --parsable --chdir=%q %q %q\n' "$run" "$run/code/slurm/array.slurm" "$run" >> metadata/launch_commands.txt
job=$(sbatch --parsable --chdir="$run" "$run/code/slurm/array.slurm" "$run")
job=${job%%;*}
printf 'all_cells\t%s\n' "$job" | tee -a metadata/array_jobs.tsv
deps=$(cut -f2 metadata/array_jobs.tsv | paste -sd: -)
printf 'sbatch --parsable --dependency=afterany:%s --chdir=%q %q %q\n' "$deps" "$run" "$run/code/slurm/process.slurm" "$run" >> metadata/launch_commands.txt
job=$(sbatch --parsable --dependency="afterany:$deps" --chdir="$run" "$run/code/slurm/process.slurm" "$run")
printf '%s\n' "${job%%;*}" > metadata/process_job_id.txt
printf 'Submitted %s\nRaw draws %s\nProcessing job %s\n' "$run" "$raw" "$job"
