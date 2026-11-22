#!/bin/bash
#SBATCH --job-name=inner_quantiles
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --array=1-3000%400
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=04:00:00
#SBATCH --output=logs/fit_%a.out

# Everything above is the request, and it applies to EACH of the 3,000 fits:
#   --array=1-3000%400   3,000 copies, numbered 1 to 3,000, at most 400 running at once
#   --cpus-per-task=1    one processor
#   --mem=4G             4 GB of memory
#   --time=04:00:00      stop the fit if it takes more than 4 hours
#   --output             what R prints goes to logs/fit_<number>.out

cd /home/fb31/projects/Quant_Reg/NOTS_Exercise
module load GCC/14.3.0 R/4.5.2          # load R
export R_LIBS_USER=$HOME/R/library      # where my R packages are installed
export OMP_NUM_THREADS=1                # use only the one processor we asked for

Rscript worker.R
