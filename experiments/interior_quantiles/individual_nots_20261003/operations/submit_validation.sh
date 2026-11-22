#!/bin/bash
set -euo pipefail
cd /home/fb31/projects/Quant_Reg/Inner_Individual
sha256sum --check SHA256SUMS
mkdir -p deployment
stamp=$(date -u +%Y%m%dT%H%M%SZ)
printf 'sbatch --parsable --chdir=%q %q %q\n' "$PWD" "$PWD/slurm/validate.slurm" "$PWD" > "deployment/validation_launch_${stamp}.txt"
job=$(sbatch --parsable --chdir="$PWD" "$PWD/slurm/validate.slurm" "$PWD")
printf '%s\n' "$job" | tee "deployment/validation_job_${stamp}.txt"
date -u --iso-8601=seconds
