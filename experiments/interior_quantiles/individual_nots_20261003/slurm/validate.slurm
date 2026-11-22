#!/bin/bash
#SBATCH --job-name=inner_individual_validate
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=01:00:00
#SBATCH --output=validate_%j.out
#SBATCH --error=validate_%j.err
set -euo pipefail
source "${1:?PACKAGE_DIR required}/path_guard.sh"
require_inner_individual_path "${1:?PACKAGE_DIR required}/validate.sh"
bash "${1:?PACKAGE_DIR required}/validate.sh"
