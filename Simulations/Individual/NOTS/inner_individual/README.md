# Individual inner quantiles: NOTS deployment package

Prepared on 2026-10-03 at the user's request. The user subsequently gave explicit
deployment approval ("Green light, deploy") and requested queue monitoring every
10 minutes. NOTS is the destination
for this whole campaign, including small computational validation. Owls is not used.

Local package: `Simulations/Individual/NOTS/inner_individual`.
Planned remote package: `/home/fb31/projects/Quant_Reg/Inner_Individual`.
All campaign scripts, sampler sources, Slurm files, validation snapshots, and production
code snapshots must remain within this folder. Deploy the local package's **contents**
directly here. Shell entry points resolve paths and reject code directories outside
this folder; the monitoring script enforces the same location. Raw data on scratch
are output files only, not a second script location.
The parent directory already exists. Read-only SSH inspection found no AGENTS.md in
its ancestor directories; recheck before deployment and preserve any new instructions.
The inspection transcript is in `audit/nots_readonly_probe.txt`.

## Experiment

| Setting | Value |
|---|---|
| Sampler | Supplied Individual_Sampler_PMALA_Augmented.R; exact, unchanged snapshot |
| Signals | VS and S |
| Noise | Normal, Beta, Mixed |
| Quantiles | 0.05, 0.25, 0.50, 0.75, 0.95, fitted separately |
| Replications | Seeds 1 through 100 in every cell; 3,000 fits total |
| Design | n=500, k=2, third differences |
| Lambda prior | Gamma(shape=1, **rate=0.01**) in every fit |
| Sigma prior | Inverse-Gamma(0.1, 0.1) |
| Sweeps | 15,000 total; discard first 3,000; retain all 12,000 remaining draws |
| Initialization | theta=y; lambda=n-k-1; sigma=z=1; 200 warm sweeps |
| P-MALA | Curvature metric, kappa=3, MH correction, ASIS on, one theta move |
| Proximal solver | 150 fixed ADMM iterations; tolerance=0 |
| Adaptation | Initial delta=0.2, target=0.5, gain=1, exponent=0.6; adapt throughout |
| RNG | Mersenne-Twister / Inversion / Rejection; data seed=s; MCMC seed=s+1000 |

Run lengths use the user's explicit 15k/3k override in every production fit; the
unchanged source and paper snapshots retain their historical 30k/10k specification.
Production configuration checks enforce 15,000 total sweeps and 3,000 burn-in.
All remaining settings are explicit in `config.R` and checked against the supplied
sampler's Settings block. Its function signature has different fallback values, so
the worker explicitly passes the settings used by its standalone main program.
Data generation is taken directly from the unchanged sampler: VS is
`2+sin(4u-2)+2*exp(-30*(4u-2)^2)`, S is `sin(2*pi*u)`, with u=i/n.
Normal SD is `(1+u^2)/4`, Beta parameters are `(1,11-10u)`, and Mixed has weight u
on N(-0.2,0.5) and 1-u on N(0.2,0.5), where 0.5 is the variance.
The same seed/signal/noise gives the identical response for all five quantiles.

This campaign reruns the individual sampler only. It does not rerun Onizuka, ADMM,
or the joint sampler, or edit paper tables. `paper_reference/` preserves the relevant
current TeX specification. The older `pmala_exact_methods_note.md` contains superseded
prior and algorithm descriptions; the executable sampler and current paper govern
this package. Historical runs are preserved. Future comparisons must label the prior
used by each old run (including a=b=1 and b=sqrt(n)); do not relabel them as b=0.01.

## Files and execution, after authorization

`prepare_package.py` only checks local syntax and snapshot hashes, records provenance,
and seals the package manifest. It never sources R files, compiles C++, generates
data, runs numerical validation, or submits jobs. `inspect_nots.py` performs read-only
SSH inspection. Neither script deploys anything. Local syntax results are recorded in
`audit/static_checks.json`; they are not evidence of remote numerical validation.

After deployment approval, re-read applicable remote instructions, copy this whole
package to the planned destination, check `sha256sum --check SHA256SUMS`, and submit
the validation job first. Record transfer hashes and the returned validation job ID.

```bash
cd /home/fb31/projects/Quant_Reg/Inner_Individual
sbatch --parsable --chdir="$PWD" slurm/validate.slurm "$PWD"
```

Inspect the actual Slurm exit status and saved validation logs. A successful validation
checks dependencies and compilation; runs two small seeds in all 30 cells; checks
identical data across levels; reconstructs all metrics from saved raw draws; verifies
all 30 mean/standard-error rows; and rejects duplicates and missing fits. Small test
settings (n=32, 40 sweeps, 12 burn-in) live only in a separate validation snapshot,
with the same lambda prior. This checks the workers, not production convergence or
production runtime. The validation receipt binds to this exact package hash.

Then submit the production campaign:

```bash
bash submit.sh VS_S_inner_100seeds_b001_YYYYMMDD
```

Submission refuses an unvalidated/changed package or an existing run name. It creates
an immutable code/configuration snapshot, a 3,000-row task manifest, SHA-256 manifests,
environment and timestamp records, exact launch commands, and scheduler IDs.
One array contains 3,000 tasks in six consecutive 500-task blocks: VS Normal,
VS Beta, VS Mixed, S Normal, S Beta, S Mixed. Within each block, the first 100 tasks
are tau=0.05 seeds 1-100, the next 100 are tau=0.25, and so on. Every task uses one
CPU, 4 GB RAM, and up to four hours on commons. The array is capped at **400 active
fits**, using `--array=1-3000%400`, as explicitly requested by the user.
These resource requests are provisional allocations, not measured runtime estimates.
If submission partially fails, inspect recorded jobs; do not repeat submission blindly.

Raw RDS files are written under `/scratch/fb31/qr_data/inner_individual/RUN_NAME`,
linked from `runs/RUN_NAME/raw`. Set RAW_BASE before submission if needed.
Theta draws alone need 144 GB decimal (about 134 GiB), plus parameter traces, data,
and metadata. Check quota and free space before launch, and archive raw draws before
scratch expiry. No script deletes saved fits or historical outputs.

## Results, monitoring, and retries

Each task saves its full retained theta draws, full parameter/adaptation/acceptance
traces, generated response and quantile truth, RNG states, exact configuration, package
versions, host/process/Slurm IDs, start/end timestamps, logs, exit status, output hashes,
posterior means, and equal-tail pointwise 95% intervals (R quantile type 7).
Metrics are MSE, mean absolute error (MAD), mean interval width (MCIW), and coverage.
Diagnostics include acceptance, log-lambda/log-sigma and midpoint-theta ESS, and
lambda means from the first and second retained halves. One chain per cell/seed;
completion and ESS values alone do not establish convergence.

`slurm/process.slurm` is submitted with an afterany dependency on the full array.
It verifies all output checksums (including raw files), configurations, identities,
and paired data, then reconstructs metrics from saved curves/truth. It refuses to
average incomplete or invalid campaigns. Successful output has exactly 30 rows in
`summary/attempt_*/average_metrics.csv`, with 100 seeds per row, Monte Carlo means,
between-seed standard errors, coverage, and diagnostic summaries. Per-seed metrics
and RDS results are saved alongside it. Each processing attempt is separate, so an
unsuccessful retry cannot appear to have newly generated an old averages file.

```bash
python3 status.py /absolute/path/to/runs/RUN_NAME
```

This saves actual squeue/sacct responses and task-marker observations under
`metadata/monitor/`. Inspect worker logs as well as these snapshots. A stale lock
does not prove a job is alive; check the recorded scheduler/process state first.

Failed attempts are preserved. To retry only failed array indices, submit the
immutable run snapshot with the desired `--array` override:

```bash
sbatch --chdir="$RUN" --array=FAILED_INDICES%400 "$RUN/code/slurm/array.slurm" "$RUN"
```

Record the command and returned job ID in run metadata, monitor the retry, and
resubmit `process.slurm` with an afterany dependency on those retry jobs. Completed
tasks refuse overwrite. Remove a stale `worker.lock` only after confirming the old
worker has ended. Production settings and seeds must not change during retries.

## Deployment and monitoring records

Actual transfer, scheduler, and validation records are preserved in `deployment/`
and each run's metadata; inspect those records for the current execution status.
After production submission, `bash start_monitor.sh RUN_DIR` starts a persistent
read-only queue/accounting monitor. It checks every 600 seconds and saves snapshots
under `RUN_DIR/metadata/monitor`, stopping after the processing job is terminal and
the queue is empty. The assistant reports inspected observations in the active
conversation; the remote monitor itself does not send chat messages.
