#!/bin/bash
set -euo pipefail
date -u --iso-8601=seconds
for d in / /home /home/fb31 /home/fb31/projects /home/fb31/projects/Quant_Reg /home/fb31/projects/Quant_Reg/Inner_Individual /scratch /scratch/fb31 /scratch/fb31/qr_data /scratch/fb31/qr_data/inner_individual; do
  if [[ -f "$d/AGENTS.md" ]]; then printf '\nAGENTS %s\n' "$d/AGENTS.md"; cat "$d/AGENTS.md"; fi
done
ls -la /home/fb31/projects/Quant_Reg/Inner_Individual
df -h /home/fb31/projects/Quant_Reg/Inner_Individual /scratch/fb31
quota -s || true
squeue -u fb31 -o '%.24i %.32j %.10T %.10M %.30R'
module purge
module load GCC/14.3.0 R/4.5.2
command -v Rscript
module list
