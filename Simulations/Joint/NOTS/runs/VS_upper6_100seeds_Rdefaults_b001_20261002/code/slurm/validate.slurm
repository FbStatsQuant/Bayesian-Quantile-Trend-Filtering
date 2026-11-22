#!/bin/bash
#SBATCH --job-name=joint_scripts_check
#SBATCH --partition=debug
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --output=validate_%j.out
#SBATCH --error=validate_%j.err
set -euo pipefail
bash "${1:?PACKAGE_DIR required}/validate.sh"
