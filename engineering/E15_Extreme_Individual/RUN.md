# E-15 Extreme upper quantiles, individual Bayesian-PMALA

The 3,600 runs cover VS and S, Normal, Beta, and Mixed noise, quantiles
0.90, 0.93, 0.96, 0.97, 0.98, and 0.99, and data seeds 1–100. Each fit
uses n = 500 and trend-filtering order 2. Slurm indices are 0–3599.
The seed varies fastest, then quantile, noise, and signal in the order
listed. After generating the data, the runner sets the chain seed to
`10001 + index` with Mersenne-Twister, Inversion, and Rejection.

## Original data and priors

The 0.90 and 0.93 rows trace to the Oct. 21 individual campaign
`extreme_individual_VS_S_10k3k_tau090_093_20261021`. The four higher
levels trace to the Oct. 7 campaign
`extreme_individual_VS_S_10k3k_20261007`. Both sets are listed in the
[table generator](../../experiments/extreme_quantiles/tables_4lev_20261023/paper_tables_4lev_vs_6lev.R)
and feed the consolidated published values.

The [legacy archive manifest](../E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256)
records the same `common_extreme.R`, `worker_pmala.R`, and sampler file
hashes for both snapshots. The first two match the repository bytes and
the sampler matches after restoring the archived CRLF line endings.
The original `submit.sh` wrote `dput(cfg)` to `metadata/config.txt` and
exported the task and batch grids. With the repository config the three
recreated files match the Oct. 7 hashes. Changing only `cfg$taus` to
`c(0.90, 0.93)` also reproduces the Oct. 21 hashes
exactly. The Oct. 21 config hash is
`7ab6eafabeeaf66e4cfae59e7132df0e43a7d0766c2d45af52ba3118d42c1749`,
and its task manifest hash is
`9b311ce12b648a6674bb1fa2be66ce9d57aab04f3bd6f9d31a66f4deeef8fe78`.

`e15_verify_data.R` reruns those checks and compares response and truth
SHA-256 hashes for all 3,600 tasks with the original individual and joint
sampler generators. It hashes IEEE-754 numeric vectors as little-endian
binary64 and verifies that each of the 600 signal/noise/seed groups has
one response vector shared across all six quantiles. The verified hash
CSV has SHA-256
`642e6e94d5828999bfc394f4e84c880ecf32608b3b299bfb87945da0f957709c`.

The original individual sampler uses an unscaled trend-filtering prior,
σ ~ IG(0.1, 0.1), and λ ~ Gamma(1, b0) in shape/rate form. Both legacy
configs override b0 to 0.01 for VS and 0.001 for S. E-14 used the same
shape and σ parameters with rates 0.001 and 0.0005, respectively.
E-15 applies the owner's common rate of 0.001 to both signals. The
shape and σ parameters retain their legacy values.

## Sampler and outputs

Use commit `63f2a56205b8d2ec311565db8c98874cd96754b2`, pinned in each
result and in `code/run_manifest.dcf`. The original campaigns used 10,000
sweeps with 3,000 burn-in, ASIS off, and target acceptance 0.55. E-15 uses
30,000 sweeps with 10,000 burn-in and target 0.50, as in E-14. The target
controls adaptation and the pilot checks acceptance at the requested
settings. The runner uses the data-based start, 200 warm sweeps with λ
held and the burn-in σ guard, fixed spline-held ASIS (dimensions 10, 20,
and 40), no θ block move, and diminishing adaptation throughout.

The output includes the posterior mean and 95% pointwise bands for θ,
truth, MSE, MAD, mean interval width, and pointwise coverage. λ ESS is
computed with coda on all post-burn-in draws. The λ and σ means use all
20,000 post-burn-in draws and their retained traces have 1,000 points
each over the full chain. A successful RDS is written atomically and
skipped on rerun. A caught error writes an atomic `<id>.fail.rds`.
A job that exits before reaching R is identified by its missing ID and
Slurm log.

## NOTS

Transfer a Git bundle verified on Owls and NOTS and compare the two
HEADs. Archive the sampler R file and individual and joint C++ kernels
from the pinned sampler commit. Archive the E-15 run scripts and
`experiments/extreme_quantiles/packages/Extreme_Individual/common_extreme.R`
from the verified engineering HEAD. Extract into `$RUN/code` and record
`Sampler-Commit` and `Engineering-Commit` in `code/run_manifest.dcf`.

The common-rate pilot uses indices `0,500,1000,1700,1900,2600,3000,3500`
in a separate directory. It tests 0.99 for both signals and covers all
three noises. Together with the two E-14b pilot tasks, production
requires ten completions, zero σ guards, and all acceptances in
[0.4, 0.6]. The combined production projection from Slurm TotalCPU must
be at most 260 core-hours. Submit production as one `bqtf-e15` array.

Reference pilot `2894358` used the legacy VS/S rates. Its associated
production array `2894375` was cancelled when the owner set the common
rate. The cancelled array used 46.330329 Slurm core-hours and its
outputs are preserved in `E15-extreme-indiv-20261125-cancelled-2894375`.

Common-rate pilots `2895795` (E-15) and `2895796` (E-14b) passed. All ten
tasks completed with zero σ guards and acceptance of 0.49490–0.50100.
The combined production projection was 208.416 core-hours. The bundle
verified on both hosts with identical engineering HEAD
`20cc922927e2d68375f5a55bc91d13ec4bb68ffb`.

```bash
RUN="$HOME/BQTF/runs/E15-extreme-indiv-20261125"
code="$RUN/code/engineering/E15_Extreme_Individual"
mkdir -p "$RUN/logs"
sbatch --array=0-3599%400 --export="ALL,RUN=$RUN" \
    --output="$RUN/logs/%x_%A_%a.out" "$code/e15.slurm"
```

Each task uses one core, 768 MiB and a 15-minute limit on commons. The
module versions, package library, and job-local compile cache follow
E-14. After job completion, run `e15_check.R RUN_DIR 600` and
`e15_summary.R RUN_DIR` from the snapshot. Verify the result and summary
hashes on both systems before sealing the NOTS run.

## Production results

Array `2895854` completed all 3,600 runs at the common rate. The checker
found zero missing IDs and zero failure files. Slurm TotalCPU summed
to 583,504.383 seconds (162.084551 core-hours). Together with E-14b,
production used 235.820396 core-hours, or 236.230656 including both
common-rate pilots. Including the cancelled legacy-rate array and its
reference pilot as well, all E-15 and E-14b Slurm work used 282.796798
core-hours.

Acceptance ranged from 0.48790 to 0.50990. No run triggered the σ guard,
and all runs recorded 200 warm-start IPM fallbacks. The Owls copy is
`runs/E15-extreme-indiv-20261125/`. All 3,602 result and summary hashes
verified on both hosts. The transfer manifest SHA-256 is
`1eb06ba314b5f4715c1d551896bbaa95d65eb4b45c6f7436a5cb92d8cefb0873`.
The NOTS run was sealed after transfer. All 7,222 seal entries verified.
