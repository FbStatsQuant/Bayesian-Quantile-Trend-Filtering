# Air-quality peak-detection simulation: Onizuka Laplace BQTF add-on (NOTS)

Folder on NOTS: `/home/fb31/projects/Quant_Reg/Air_sim_Lap/Driver`. Add-on to the production run `Air_sim/Individual/runs/air_n500_100seeds_20261008`
(pmala, admm, onizuka_hs): it adds ONE method, `onizuka_lap` (Onizuka, Hashimoto and Sugasawa's Laplace-prior BQTF,
`BQTF.MCMC.Lap.multi` of the unchanged `Onizuka/source/BQTF-function.R`). **Nothing is submitted to production until the user gives the deployment command.**

| Setting | Value |
|---|---|
| Data | `simulate_air()` of `common_air.R`, byte-identical to the production run's file; n = 500, sd_eps = 0.25; data seed s |
| Seeds, levels | seeds 1-100, tau = 0.01, 0.05, 0.10, one quantile per task; 300 tasks (index 1-100 tau 0.01, 101-200 tau 0.05, 201-300 tau 0.10) |
| Sampler | `BQTF.MCMC.Lap.multi(X = seq_len(n), Y = y, TForder = 2, pp = tau, mc = 8000, sparse = FALSE, sig.init = c(1, 1))`, `set.seed(seed + 1000)` immediately before the call; draws 2001-8000 retained; posterior mean and 0.025/0.975 pointwise quantiles |
| Metrics | `air_metrics()` of the unchanged `common_air.R` (MSE, RMSE, MAD, CL, coverage, MCIW, CAA at h = 0.5, 0.75, 1, 1.2 and the y-theta variant) |
| Diagnostics | the Laplace function returns only theta draws; sigma2/tau2 diagnostics are NA (summary.csv columns `mean_onizuka_sigma2/tau2` are NA, as are the pmala/admm columns) |

## Differences from Air_sim
- `Driver/` replaces `Individual/`; there is no ADMM or PMALA folder. `common_air.R` is unchanged (sha256 checked by validation).
- `config.R`: method `onizuka_lap`, 300-task grid, `02:00:00` / `2G`, no pmala/admm settings.
- `process_lap.R` (new): `process_campaign_lap()` = `process_campaign()` without the paired-vs-pmala table; `summary.csv` has the same columns.
- `Onizuka/worker_onizuka_lap.R` (new): the Laplace worker (library shim skips `Bessel` only, as in Extreme_Onizuka).
- `validate_checks.R`, `validate.sh`, `run_task.sh`, `submit.sh`, `seal.sh`, `status.sh`, `path_guard.sh`, `make_tables.R`: folder list and method names only.

## Commands (on NOTS, from this folder)

    bash seal.sh                                   # after any edit: re-seal both folders
    sbatch --chdir=$PWD slurm/validate.slurm $PWD  # validation job (required before production)
    bash submit.sh NAME 1                          # pilot: seed 1, all levels, production settings
    bash submit.sh NAME                            # PRODUCTION, only on the user's command
    bash status.sh runs/NAME
    bash retry.sh runs/NAME 1 INDEX_SPEC           # then: sbatch --chdir=runs/NAME slurm/process.slurm runs/NAME

Raw task outputs and logs: `/scratch/fb31/qr_data/air_sim_lap/RUN_NAME/{tasks,logs}`, linked from `runs/RUN_NAME/`.
