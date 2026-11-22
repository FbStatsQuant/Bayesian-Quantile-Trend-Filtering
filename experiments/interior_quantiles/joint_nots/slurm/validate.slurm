#!/bin/bash
#SBATCH --job-name=joint_interior_check
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=validation/validate_%j.out
#SBATCH --error=validation/validate_%j.err
set -euo pipefail
bash "${1:?PACKAGE_DIR required}/validate.sh"
