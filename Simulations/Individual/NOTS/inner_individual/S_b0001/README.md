# S baseline, inner quantiles, individual P-MALA with lambda rate 0.001

Requested 2026-10-08. Rerun of the S half of the 2026-10-03 campaign
(`../runs/VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z`, package `..`). The only changes are the
user's overrides, declared in `config.R` and enforced against the source Settings block:

| Setting | 2026-10-03 | This run |
|---|---|---|
| lambda prior | Gamma(1, rate 0.01) | Gamma(1, **rate 0.001**) |
| ASIS lambda step | on | **off** |
| Sweeps / burn-in | 15,000 / 3,000 | **20,000 / 5,000** (15,000 draws kept) |

Everything else is unchanged: sampler snapshot `source/` (byte-identical to the 10-03 snapshot), k = 2,
n = 500, sigma ~ IG(0.1, 0.1), curvature metric kappa = 3, adapt target 0.50 throughout, 150 ADMM
iterations, theta = y start, 200 warm sweeps, data seed s, MCMC seed s + 1000 (same responses as 10-03).
Grid: S x {Normal, Beta, Mixed} x tau {0.05, 0.25, 0.50, 0.75, 0.95} x seeds 1-100 = 1,500 fits.

NOTS location: `/home/fb31/projects/Quant_Reg/Inner_Individual/S_b0001` (scripts refuse other paths).
Raw draws: `/scratch/fb31/qr_data/inner_individual_S_b0001/RUN_NAME`, linked as `runs/RUN_NAME/raw`.

## Steps

```bash
cd /home/fb31/projects/Quant_Reg/Inner_Individual/S_b0001
bash submit.sh RUN_NAME            # snapshot code, preflight, submit the pilot: seed 1, all 15 cells
bash status.sh runs/RUN_NAME
Rscript --vanilla runs/RUN_NAME/code/process_results.R runs/RUN_NAME --pilot   # pilot table + crossings
bash release.sh runs/RUN_NAME      # remaining 1,485 fits (%400) + processing job (afterany)
```

The pilot tasks are part of the run, so the final averages use all 100 seeds without refitting seed 1.
`process_results.R` verifies every output hash, configuration, source manifest and paired data, recomputes
the metrics, and refuses incomplete runs. Output: `summary/attempt_*/average_metrics.csv` (15 rows:
mean and standard error of MSE, MAD, MCIW, coverage; median MSE; acceptance; ESS; time),
`per_seed_metrics.csv`, `crossings_adjacent.csv` and `average_crossings.csv` (adjacent-level crossings of the
posterior-mean curves). Retries: `sbatch --chdir=RUN --array=IDS%400 RUN/code/slurm/array.slurm RUN`, then resubmit
`process.slurm`. Completed tasks refuse overwrite.

Local checks (2026-10-08, Temp `s_b0001_test`): preflight; rejection of undeclared changes (adapt target, order,
wrong override); tiny run (n = 32, 2 seeds, 40 sweeps) through the worker, pilot and full processing; refusal of
incomplete processing and of overwrites; worker draws bitwise identical to a direct sampler call.
