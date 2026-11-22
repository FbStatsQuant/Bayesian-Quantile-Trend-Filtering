# NOTS Slurm array pattern (from the deleted `Temp/NOTS_Exercise`)

A 3,000-task array exercise (seeds x tau x noise x VS/S) that ran the individual sampler. Only the pattern is kept:

```bash
#SBATCH --job-name=inner_quantiles
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --array=1-3000%400        # 3,000 copies, at most 400 running at once
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=04:00:00           # per task
#SBATCH --output=logs/fit_%a.out  # one log per array index

cd /home/fb31/projects/Quant_Reg/NOTS_Exercise
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=$HOME/R/library
export OMP_NUM_THREADS=1          # one processor
Rscript worker.R                  # worker.R maps SLURM_ARRAY_TASK_ID to (seed, tau, noise, baseline)
```

Production versions of this pattern: `experiments/interior_quantiles/individual_nots_20261003/slurm/` and the `slurm/` folders of the other packages.
