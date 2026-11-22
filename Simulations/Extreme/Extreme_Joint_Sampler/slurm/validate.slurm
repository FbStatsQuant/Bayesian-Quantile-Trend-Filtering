#!/bin/bash
# sbatch --chdir=/home/fb31/projects/Quant_Reg/Extreme_Joint_Sampler slurm/validate.slurm /home/fb31/projects/Quant_Reg/Extreme_Joint_Sampler
#SBATCH --job-name=ext_joint_validate
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=6G
#SBATCH --time=02:00:00
#SBATCH --output=validation/validate_%j.out
#SBATCH --error=validation/validate_%j.err
set -euo pipefail
source "${1:?PACKAGE_DIR required}/path_guard.sh"
require_extreme_path "${1}/validate.sh"
bash "${1}/validate.sh"
