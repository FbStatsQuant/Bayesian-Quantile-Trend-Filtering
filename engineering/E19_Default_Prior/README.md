# E-19 default λ prior on the interior benchmarks

Status: pre-registered on 2026-11-26 by HQ, under the owner's delegation.
No E-19 fit has run. This file is committed before any fit and is not
edited after launch, except to add run records under "Run log".

E-19 launches only after the E-18 Stage 2′ run is complete and reported
to HQ. E-18 keeps priority.

## Question

Does the air-quality λ prior, Gamma(a0 = n, b0 = 1e-2), also work on the
§4.1 interior benchmarks?

- If it does (PASS), it becomes the paper's default prior.
- If it does not (FAIL), it stays an air-only setting.

## Design

E-19 uses the exact E-14 interior design. The only change is the λ prior.

| Setting | E-14 comparator (archived) | E-19 |
| --- | --- | --- |
| Signals × noise × τ × seeds | VS, S × Normal, Beta, Mixed × τ ∈ {0.05, 0.25, 0.50, 0.75, 0.95} × data seeds 1–100 (3,000 fits) | Same |
| Task index and MCMC seed | Zero-based index; MCMC seed 10001 + index | Same |
| Sampler | `63f2a56`, k = 2, data-based start, 200 warm sweeps with λ held, spline-held ASIS (`asis_q = "fixed"`), target acceptance 0.5 | Same |
| Sweeps / burn-in | 30,000 / 10,000 | Same |
| σ prior | IG(0.1, 0.1) | Same |
| **λ prior** | **Gamma(1, 1e-3) for VS; Gamma(1, 5e-4) for S** | **Gamma(500, 1e-2) for both** (a0 = n = 500) |
| Point estimate, interval, and metrics | As stored by [e14_run.R](../E14_Inner_Rerun/e14_run.R) | Same code path |

The comparator is the archived E-14 run in
`runs/E14-inner-rerun-20261125/out/`: 3,000 RDS files, checked against
`E14_RESULTS.sha256`, with 0 failed attempts and 0 reruns. These are the
values behind the current paper (VS b0 = 1e-3, S b0 = 5e-4). The E-14b
S run at b0 = 1e-3 is **not** the comparator.

The E-19 runner calls the E-14 fit function with `a0 = 500` and
`b0 = 1e-2`. Today `e14_run.R` hard-codes `a0 = 1`. E-19 adds a
parameter whose default keeps E-14 unchanged; nothing else in the fit
changes. The E-19 runner also writes two outputs that E-14 did not
store:

- the θ ESS summary;
- the warm-up counter `n_warm_ipm_unconverged`, next to `n_ipm_fallback`.

Both are reporting additions only.

## Pairing and reproducibility

Pairs are formed on the data seed: the same signal, noise, τ and seed
give the same y and truth in both runs. E-19 checks y and truth against
the E-14 RDS for every fit. A mismatch stops the run.

MCMC paths are not expected to match across runs. The prior differs,
and paths also differ across CPU or node families (see the E-14 replay
2921171). The comparison is paired on the data, not on the MCMC path.

## Verdict rule (fixed before any fit)

Per cell, d_i = MSE_E19,i − MSE_E14,i over the paired seeds. The paired
z is mean(d) / (sd(d) / √n_pairs). The MSE ratio is mean MSE(E-19) /
mean MSE(E-14). Coverage is the pointwise 95% coverage, the fraction of
the 500 points with lo ≤ truth ≤ hi, averaged over seeds.

**PASS** (the prior becomes the paper default) only if ALL of these
hold:

1. For each signal separately, the geometric mean over its 15 cells of
   MSE(E-19)/MSE(E-14) is ≤ 1.00.
2. No cell has E-19 significantly worse, meaning paired z > 2 AND an
   MSE ratio > 1.10.
3. For each signal, the median over cells of E-19 coverage is ≥ the
   median over cells of E-14 coverage minus 0.05.

Otherwise the verdict is **FAIL**, and the air-only framing stands.

The verdict is reported mechanically, with every per-cell number for
both runs where stored:

- MSE, MAD and MCIW;
- coverage;
- log-λ ESS and θ ESS (E-19 only);
- acceptance;
- warm-up counters.

Cells are listed worst first.

## Gates

The usual E-14 gates apply to the pilot and to production:

- every expected fit present, with a successful Slurm exit;
- zero σ-guard events;
- median acceptance in [0.4, 0.6];
- sampler hash `63f2a56`, chain schedule and (a0, b0) checked on every
  fit.

## Pilot and budget

- **Pilot:** 6 fits, chosen as in E-17: zero-based indices 0, 700,
  1400, 1599, 2300 and 2999. On VS these are Normal τ 0.05 seed 1,
  Beta τ 0.50 seed 1 and Mixed τ 0.95 seed 1. On S they are Normal
  τ 0.05 seed 100, Beta τ 0.75 seed 1 and Mixed τ 0.95 seed 100.
  The pilot runs on a compute node and loads every library before
  fitting.
- **Projection:** with C the summed measured pilot CPU seconds
  (allocation rows of Slurm TotalCPU), projected core-hours =
  (C + 3000 · C / 6) / 3600.
- **Cap: 160 core-hours,** including the pilot, failed attempts and
  retries. If the projection is within the cap, launch production
  without waiting for HQ. If it is over, stop and report.
- **Memory:** the production request is the maximum pilot MaxRSS plus
  headroom. The E-14 starting allocation was 1 core, 768 MiB and
  15 minutes per task.
- Actual TotalCPU is rechecked during production against the cap.

## Operations

Standing NOTS rules apply:

- job names start with `bqtf-`;
- `commons` partition, with an explicit `--mem` on every job;
- array concurrency `%300`;
- one ssh connection through the lock;
- cancel only by explicit job ID;
- no push from NOTS.

If an agent hits a usage limit, it pauses until the reset, and HQ is
told the reset time. Submitted jobs keep running.

## Run log

### 2026-11-26 pairing preflight

- Runner commit `1433cc6e5cef68e7cab0894bb17a27b097372517`.
- All 3,002 entries in the E-14 SHA-256 manifest verified on Owls. All
  3,000 archived RDS files contain `truth`. Zero contain a stored response
  vector `y`. Each of the six pilot indices failed the comparator
  input check before sampling.
- The assembled Owls snapshot matched the Git blobs at `63f2a56` for
  `Individual_Sampler_PMALA_Augmented.R`
  (`c8396881c360f03b61dea7b2bb238813370be1fe`) and
  `prox_admm_metric.cpp` (`a12026d3e524b58de0aca0139eb7dacc4e3589eb`).
  NOTS verification is pending.
- The pairing gate blocked submission. No Slurm job IDs were assigned,
  and NOTS usage was 0 core-hours. The pilot projection and E-19 verdict
  are unavailable.

### 2026-11-26 pairing amendment

HQ approved this amendment because E-14 never stored the responses
(`y`). For every E-19 fit, the regenerated truth must still match the
corresponding archived E-14 truth bit for bit. The response is regenerated
using the exact `e14_data.R` blob at `01526e1`
(`b2023dc92bb6d3a51136a6013fd63d7b6d6ee7d9`), verified in the run's code
copy on Owls and NOTS.

Before the pilot, all 12 cases in [DATA_MATCH.md](../E14_Inner_Rerun/DATA_MATCH.md)
must match both reference SHA-256 digests, calculated over little-endian
IEEE-754 double bytes of the response and truth. Any mismatch stops the
run. Each E-19 RDS records the SHA-256 of its regenerated response using
the same byte encoding. All other preregistered settings and gates apply.

### 2026-11-26 NOTS pairing preflight

- Amendment commit `734795015fc21f0a58674255269e2f8c3915aab4`. The retry
  used snapshot commit `df8c31c1fbf16a33a4e30cf919f3ff3254f36f4f`,
  which computes the Git blob hash in R on nodes without Git.
- The bundle verified on Owls and NOTS, and the snapshot source HEAD
  matched Owls. The NOTS code copy matched the sampler and kernel blobs
  listed above and the pinned generator blob. The E-14 archive manifest
  also verified on NOTS. Owls matched all 24 reference digests.
- Standalone test `2931381` exited `1:0` before generating data because
  Git was unavailable on the compute node. Allocation TotalCPU was
  0.775 s and batch MaxRSS was 70,060 KiB.
- Standalone retry `2931519` exited `1:0` at the amended pairing gate.
  On the compute node, 4 of 12 response digests and 5 of 12 truth
  digests matched, with zero cases matching both. Allocation TotalCPU
  was 0.935 s and batch MaxRSS was 62,004 KiB.
- Total usage was 1.710 CPU s (0.000475 core-hours). Both jobs stopped
  before sampling and produced zero fit files. No pilot or production
  array was submitted. No pilot projection or E-19 verdict is available.

### 2026-11-26 second pairing amendment

HQ approved an absolute tolerance of `1e-12` for pairing after the
NOTS reference check exposed cross-platform math-library rounding.
Of the 3,000 Owls-regenerated truth vectors, 1,000 matched archived
E-14 bit for bit, and the largest absolute difference was `8.9e-16`.
The exact-match rates were 0% for Beta, 20% for Mixed, and 80% for Normal.
[Paired audit](preflight/truth_owls_vs_e14.csv)

Every fit still regenerates its data on NOTS with the verified
`01526e1` generator. The fit stops before sampling if its maximum
absolute difference from archived E-14 truth exceeds `1e-12`.
Each result records that maximum and the SHA-256 of its regenerated
response in little-endian IEEE-754 double encoding.

Before the pilot, the NOTS compute node must reproduce the 12 reference
responses and 12 truth vectors to a maximum absolute difference of
`1e-12` per vector. The reference was built on Owls from the pinned
generator and verified against all 24 exact SHA-256 digests in
[DATA_MATCH.md](../E14_Inner_Rerun/DATA_MATCH.md). The
[reference RDS](preflight/reference_owls.rds) SHA-256 is
`6a2972c8fcc9cd3a70148fa1037972ef6dde349e63539713e630fb7f4715359d`.
All other preregistered settings and gates apply.

### 2026-11-26 completed run

- Second amendment and reference commit `b667a28`. Before submission,
  Owls and NOTS verified the bundle and matched snapshot commit
  `1ed7885d8a6a185e01aeb272ad25aeafa0e586cf`, the pinned sampler and
  kernel blobs, the data generator blob, and the reference SHA-256.
- One-fit test `2932596` passed all 24 reference comparisons on the
  NOTS compute node, with a largest absolute difference of
  `8.881784197001252e-16`. The fit completed with exit `0:0`, zero σ
  guards and acceptance 0.50160. TotalCPU was 160.283 s and MaxRSS
  was 624,420 KiB (609.785 MiB).
- Pilot `2932737` completed all six fits with exit `0:0`, zero σ
  guards, and acceptance 0.49665–0.50210 (median 0.499975).
  The sampler, chain schedule, prior, and pairing checks passed for
  every fit. Allocation TotalCPU was 949.123 s (0.263645 core-hours)
  and maximum MaxRSS was 646,364 KiB (631.215 MiB). Projected usage was
  132.086284 core-hours, or 132.131282 including the preceding
  attempts. [Pilot accounting](e19_pilot_resources.csv)
- Production `2932799` ran with `%300` and 896 MiB per task. It
  completed 3,000 of 3,000 fits with exit `0:0`, zero σ guards,
  acceptance 0.48030–0.50955 (median 0.49970), and zero maximum
  absolute truth delta against E-14. The sampler, chain schedule,
  prior, and pairing checks passed for every fit. All results
  have a response digest. The monitor was restarted at 15:33 CT
  after an output-file rename interrupted its directory scan. No
  production fits were retried.
- Production allocation TotalCPU was 501,944.888 s (139.429136
  core-hours). Total usage across all five jobs, including the failed
  preflights, was **139.737779 core-hours** of the 160 core-hour cap.
  Owls verified all 3,003 entries in `E19_RESULTS.sha256`. The
  manifest SHA-256 is
  `3defec190b32fcf3f91503e837576c592618c0a78dd9656f6ca3c6a9be4ff12a`.

**FAIL.** Condition 1 required geometric mean MSE ratios at most
1.00. VS had 8.859499 and S had 0.784494. Condition 2 required zero
significantly worse cells. All 15 VS cells and zero S cells had
both paired z > 2 and MSE ratio > 1.10. Condition 3 required E-19
median coverage of at least 0.82348 for VS and 0.83444 for S, based
on E-14 medians of 0.87348 and 0.88444. E-19 medians were 0.53614
for VS and 0.71394 for S. The air-only framing stands.
[Per-cell results](e19_cells.csv) · [Verdict](e19_verdict.csv)
· [Analysis](e19_analyze.R), commit `45be85b`.
