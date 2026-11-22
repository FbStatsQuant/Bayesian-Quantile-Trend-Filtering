#!/bin/bash
# After a successful pilot: submit the remaining 1,485 fits (max 400 running) and the processing job.
# Usage: bash release.sh RUN_DIR
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/path_guard.sh"
run=$(realpath "${1:?RUN_DIR required}")
require_package_path "$run/code"
cd "$run"
[[ $(cut -f1 metadata/array_jobs.tsv) == pilot ]] || { echo 'Release already submitted or pilot missing' >&2; exit 2; }
pilot_job=$(cut -f2 metadata/array_jobs.tsv)
[[ -z $(squeue -h -j "$pilot_job" 2>/dev/null) ]] || { echo 'Pilot still in the queue' >&2; exit 2; }
n_pilot=$(wc -l < metadata/pilot_task_ids.txt)
n_done=$(find tasks -name SUCCESS -type f | wc -l)
[[ $n_done == "$n_pilot" ]] || { echo "Pilot incomplete: $n_done of $n_pilot" >&2; exit 2; }
# Remaining task IDs as compact ranges.
spec=$(tail -n +2 metadata/task_manifest.csv | cut -d, -f5 | grep -vxFf metadata/pilot_task_ids.txt | sort -n |
  awk 'NR==1{s=$1;p=$1;next} $1==p+1{p=$1;next} {printf "%s%s,", s, (s==p?"":"-"p); s=$1; p=$1}
       END{printf "%s%s", s, (s==p?"":"-"p)}')
printf 'sbatch --parsable --array=%s%%400 --chdir=%q %q %q\n' "$spec" "$run" "$run/code/slurm/array.slurm" "$run" >> metadata/launch_commands.txt
job=$(sbatch --parsable --array="${spec}%400" --chdir="$run" "$run/code/slurm/array.slurm" "$run")
job=${job%%;*}
printf 'release\t%s\t%s%%400\n' "$job" "$spec" | tee -a metadata/array_jobs.tsv
deps=$(cut -f2 metadata/array_jobs.tsv | paste -sd: -)
printf 'sbatch --parsable --dependency=afterany:%s --chdir=%q %q %q\n' "$deps" "$run" "$run/code/slurm/process.slurm" "$run" >> metadata/launch_commands.txt
pjob=$(sbatch --parsable --dependency="afterany:$deps" --chdir="$run" "$run/code/slurm/process.slurm" "$run")
printf '%s\n' "${pjob%%;*}" > metadata/process_job_id.txt
printf 'Released array %s; processing job %s\n' "$job" "${pjob%%;*}"
