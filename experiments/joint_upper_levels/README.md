# Joint VS simulation scripts for NOTS

Production destination: `/home/fb31/projects/Quant_Reg/Joint_Sampler`.
Production jobs are launched exclusively by `bash submit.sh RUN_NAME`.

## Experiment

- Seeds 1–100 for each of Normal, Beta, and Mixed (the sampler's name for mixture).
- Each of the 300 tasks fits tau = 0.90, 0.93, 0.96, 0.97, 0.98, 0.99 jointly.
- VS baseline, n = 500, order 2 (third differences).
- 30,000 sweeps, 10,000 burn-in, 200 warm sweeps, no thinning: 20,000 kept draws.
- Gamma lambda prior: shape 1, rate 0.01, exactly as in the unchanged current R sampler.
  All sampler parameters are checked against the source Settings block before submission.
  The superseded sqrt(n) run is preserved separately; no 0.001 batch was submitted.
  The paper states a 0.001 rate; keep that distinction when comparing its existing table.
- Other numerical and adaptation settings match the supplied joint sampler, including
  adaptation throughout sampling (`adapt_all = TRUE`). Completion is not a convergence claim.
- Data RNG uses seed s; MCMC uses s + 1000, Mersenne-Twister/Inversion/Rejection.

## Files and submission

`worker.R` loads definitions from the unchanged source snapshot and calls the joint sampler.
`slurm/all_noises.slurm` requests one 300-task array, capped at 60 concurrent tasks,
one CPU and 8 GB per task, 24 hours on commons. Tasks 1–100 are Normal seeds 1–100,
101–200 are Beta seeds 1–100, and 201–300 are Mixed seeds 1–100.
The separate per-noise Slurm files remain available for deliberate manual use;
`submit.sh` uses only the single 300-task array.
`slurm/process.slurm` runs after the entire array terminates (afterany); incomplete runs
produce task_status.csv and a nonzero exit, never a partial average.

```bash
cd /home/fb31/projects/Quant_Reg/Joint_Sampler
bash submit.sh VS_upper6_100seeds
```

Submission creates a fresh `runs/RUN_NAME/code` snapshot, marks it read-only, and records
SHA-256 hashes, exact launch commands, job IDs, configuration, environment, and timestamps.
Existing run names are rejected. Every job verifies the code manifest before execution.
The original local sampler and historical outputs are never edited.

Raw posterior draws go to `/scratch/fb31/qr_data/joint_sampler/RUN_NAME`, linked as
`runs/RUN_NAME/raw`. Set RAW_BASE before submission to choose another large-data location.
Uncompressed theta draws require about 144 GB (134 GiB) across 300 tasks, plus traces.
Scratch is temporary storage: archive completed raw files before the site's retention limit.
Task summaries, generated data, logs, and metadata remain under the home project run.
No raw files are automatically deleted. A failed job preserves its attempt and can be
rerun with `run_task.sh RUN_DIR NOISE SEED`; inspect/remove a stale worker.lock only after
confirming the old job has ended. Successful tasks refuse overwrite. Requeue processing
after any retries; the snapshot's process.slurm accepts the run directory as its argument.

## Metrics and saved results

For every seed and tau, the point estimate is the posterior mean at each of the n locations.
MSE = mean squared error against the true conditional quantile; MAD = mean absolute error
(not median absolute deviation); MCIW = mean width of the pointwise equal-tail 95% credible
interval (2.5% and 97.5% empirical quantiles, R type 7). No observations/seeds are dropped.

`summary/average_metrics_tau096_099.csv` has 12 rows: three noises by four target taus.
Each mean is the unweighted average of 100 per-seed metrics. Between-seed standard errors
and mean coverage are also saved. All-six-quantile metrics and raw/summary RDS files allow
recomputation. The processor validates configuration, seeds, taus, finite metrics, and saved
draw ordering, and recomputes metrics from the saved estimates/intervals/truth.
Inspect acceptance/outside rates and traces before interpreting scientific results.

## Validation (separate from the production experiment)

```bash
sbatch slurm/validate.slurm /home/fb31/projects/Quant_Reg/Joint_Sampler
```

This persistent compute-node job checks R/shell syntax and dependencies, compiles the kernels,
runs six tiny workers (n=32, 24 sweeps, 8 burn-in, two seeds per noise), tests that missing
tasks are rejected, checks all 12 averages, and reconstructs metrics from raw draws.
All validation evidence is kept under `validation/`; it does not assess production convergence
or runtime. Production resource requests are initial allocations, not benchmark estimates.
