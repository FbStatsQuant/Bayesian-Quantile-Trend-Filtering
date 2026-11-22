# Joint sampler at interior quantiles (VS and S) for NOTS

Production destination: `/home/fb31/projects/Quant_Reg/Inner_Joint` (all scripts live here).
Production jobs are launched exclusively by `bash submit.sh RUN_NAME`.

## Experiment

Each task jointly fits one batch of levels; one batch per target, and only the target is reported.
(The earlier 3-batch run is `runs/interior_b001_100seeds_20261003`.)

| Batch | Levels fitted jointly                          | Target |
|-------|------------------------------------------------|--------|
| t05   | 0.025, 0.05, 0.075, 0.10, 0.15, 0.20           | 0.05   |
| t25   | 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40       | 0.25   |
| t50   | 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80       | 0.50   |
| t75   | 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90       | 0.75   |
| t95   | 0.80, 0.85, 0.90, 0.925, 0.95, 0.975           | 0.95   |

- Baselines VS and S; noises Normal, Beta, Mixed; seeds 1–100: 2 × 3 × 5 × 100 = 3000 tasks.
- n = 500, order 2 (third differences); 30,000 sweeps, 10,000 burn-in, 200 warm sweeps.
- Priors: lambda ~ Gamma(shape 1, rate 0.01); sigma ~ IG(0.1, 0.1). All other sampler settings
  are those of the source Settings block (checked by `check_defaults.R` before submission) and
  identical to the extreme-quantile run `Joint/NOTS/runs/VS_upper6_100seeds_Rdefaults_b001_20261002`.
  The sampler source files are byte-identical to that run's snapshot.
- Data RNG uses seed s (the noise draw depends only on seed, baseline and noise, so all three
  batches of a seed share the same y); MCMC uses s + 1000.

## Resources

One CPU, 4 GB (3-batch run with up to 6 levels peaked at 1.7 GB), 8 h limit per task (3-batch run:
median 0.77 h, max 1.42 h). At most 400 tasks run at once. `submit.sh` reads the site's MaxArraySize:
above the task count it submits one array `1-3000%400`, otherwise two arrays (VS, S) at `%200` each.
`slurm/process.slurm` runs after all arrays end (afterany) and writes no averages unless every
task is valid.

Array index mapping: `submit.sh` writes `task_grid()` to `metadata/task_index.tsv` (read-only) and
`array.slurm` looks each index up there. Seed fastest, then batch, noise, baseline: 1–1500 are VS,
1501–3000 are S; within a baseline, 500 per noise (Normal, Beta, Mixed) and 100 per batch.

## Outputs

Raw files go to `/scratch/fb31/qr_data/inner_joint/RUN_NAME` (override with RAW_BASE), linked as
`runs/RUN_NAME/raw`. They keep every 20th retained theta draw (1000 per task) and the full
lambda/sigma/delta/acceptance traces: about 35-40 MB per task, ~115 GB total. Point estimates and
intervals are computed from all 20,000 retained draws before thinning.

`summary/` (after processing):
- `average_metrics_targets.csv`: 30 rows (baseline × noise × target tau), mean and SE of MSE,
  MAD (mean absolute error) and MCIW (mean width of the pointwise equal-tail 95% interval), coverage.
- `comparison_paper_interior.csv`: joint vs the manuscript's interior tables (PMALA, Laplace,
  Horseshoe, ADMM) for every metric; source in `paper_reference/`.
- `diagnostics_all_taus.csv`: acceptance, outside-box rate, IPM share, runtime at every fitted level.
- `per_seed_all_taus.csv`, `per_seed_targets.csv`, `task_status.csv`, `results.rds`.

## Commands

```bash
cd /home/fb31/projects/Quant_Reg/Inner_Joint
mkdir -p validation && sbatch slurm/validate.slurm "$PWD"      # tiny end-to-end check (36 tasks)
bash submit.sh interior_b001_100seeds                          # production (only when instructed)
python3 status.py runs/interior_b001_100seeds                  # progress
```

A failed task keeps its attempt directory and can be rerun with
`bash runs/RUN/code/run_task.sh runs/RUN BASELINE NOISE BATCH SEED` (inspect/remove a stale
`worker.lock` only after confirming the old job has ended), then rerun `slurm/process.slurm RUN_DIR`.
