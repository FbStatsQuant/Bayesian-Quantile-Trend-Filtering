# E-17 individual simulations at b0 = 1e-5

The interior grid reuses the 3,000 E-14 task IDs and the extreme grid
reuses the 3,600 E-15 task IDs. Only the prior rate changes in the
parameterized runners. The saved posterior means support crossing counts
for the extreme levels. Reports are prepared for HQ.

| Setting | E-17 |
| --- | --- |
| Sampler | `63f2a56205b8d2ec311565db8c98874cd96754b2` |
| Grid | VS and S, Normal, Beta and Mixed noise, n = 500, k = 2, seeds 1–100 |
| Interior τ | 0.05, 0.25, 0.50, 0.75, 0.95 |
| Extreme τ | 0.90, 0.93, 0.96, 0.97, 0.98, 0.99 |
| Priors | λ ~ Gamma(1, 1e-5) in shape/rate form for both signals, σ ~ IG(0.1, 0.1) |
| RNG | Original design generators. Data seed is the replication seed. MCMC seed is 10001 + zero-based task index within its design, as in E-14 and E-15. |
| Chain | 30,000 sweeps, 10,000 burn-in, including 200 warm sweeps with λ held. Data-based start and acceptance target 0.50. |
| Updates | `asis = TRUE`, `asis_q = "fixed"`, spline dimensions 10, 20, 40. Trend block move off. |
| Saved values | One compact RDS per fit with posterior mean and pointwise bands, truth, metrics, and diagnostics. λ and σ means use all 20,000 post-burn-in draws. The stored traces retain 1,000 points over the full chain. |

Run directories on Owls for the collected production results are
`runs/E17-interior-20261125/` and `runs/E17-extreme-20261125/`.
The corresponding pilot runs use a `-pilot` suffix and the full
production sweep counts. The runner inherits both original generators
and preserves the existing E-14 and E-15 prior defaults.

## Pilot and budget

| Design | Zero-based task indices | VS pilot fits | S pilot fits |
| --- | --- | --- | --- |
| Interior | 0, 700, 1400, 1599, 2300, 2999 | Normal 0.05 seed 1, Beta 0.50 seed 1, Mixed 0.95 seed 1 | Normal 0.05 seed 100, Beta 0.75 seed 1, Mixed 0.95 seed 100 |
| Extreme | 500, 700, 1600, 1899, 2600, 3599 | Normal 0.99 seed 1, Beta 0.93 seed 1, Mixed 0.98 seed 1 | Normal 0.90 seed 100, Beta 0.96 seed 1, Mixed 0.99 seed 100 |

Apply the E-14 gates to the pilots. Require every expected fit with a
successful Slurm exit, zero σ-guard events, and acceptance in [0.4, 0.6].
Check the sampler hash, chain schedule and b0 on each fit. Use the
maximum pilot MaxRSS with headroom to set the production memory request.
The starting allocation is one core, 768 MiB, and 15 minutes per task.
[e17_pilot.R](e17_pilot.R) accepts a CSV with one Slurm array task per
row and columns `design,index,cpu_seconds,state,exit_code`. Convert
`TotalCPU` to seconds and take allocation rows only, so batch steps
are counted once.

Let `C_I` and `C_X` be the sums of measured pilot CPU seconds for the
six interior and six extreme fits. The projected core-hours are
`(C_I + C_X + 3000 * C_I / 6 + 3600 * C_X / 6) / 3600`.
Require the interior production projection to be at most 150
core-hours, as in E-14, and the combined projection including both
pilots to be at most **330 core-hours**. Recheck actual Slurm TotalCPU
during production against the same shared cap, including failed
attempts and retries. Budget each further tranche against the hours
already charged plus the maximum CPU allocation still in flight and
the new tranche's time limit. For a one-core task, its upper bound is
the scheduled wall-time limit. The forecast alone cannot enforce the
hard cap.

Using prior accounting gives 141.876 + 162.085 = **303.961 core-hours**
for production and **0.554** for 12 reference-cost pilots, for
**304.515 core-hours total** and **25.485 hours of headroom**. This is
a planning estimate. Recompute from measured 1e-5 pilot CPU before
production. [E-14 accounting](../E14_Inner_Rerun/RUN.md#production-results) ·
[E-15 accounting](../E15_Extreme_Individual/RUN.md#production-results)

## Bundle and run snapshot

Use the verified full Git bundle with engineering HEAD and the pinned
sampler commit. On NOTS after GO, verify the bundle, fetch its HEAD
into a clean checkout, and compare the two HEADs. Run
[e17_snapshot.sh](e17_snapshot.sh) from the verified checkout with an
empty directory under BQTF. It archives the sampler and both required
C++ kernels from the sampler commit, and the runners and generators from
the engineering commit. Install that snapshot as `RUN/code` separately
for each pilot and production run.

The Slurm entrypoint takes `DESIGN RUN_DIR` after the script path.
Supply `--output="$RUN/logs/%x_%A_%a.out"` when submitting and create
`RUN/logs` first. Use the pilot indices above and collect the projected
budget and gate report before production. Production indices are 0–2999
for the interior and 0–3599 for the extreme. Stage submissions within
the shared commons limits and remaining CPU budget.

## Analysis after collection

```bash
Rscript --vanilla engineering/E17_b0_1e5/e17_tables.R \
  runs/E17-interior-20261125/ runs/E17-extreme-20261125/ \
  runs/E14-inner-rerun-20261125/ runs/E14b-inner-S-b1e3-20261125/ \
  runs/E15-extreme-indiv-20261125/
```

The builder verifies the task keys, sampler, rate, MCMC seeds and
run lengths and independently re-aggregates the MSE from the validated
run files. The b0 = 1e-3 columns take VS from E-14 and S from E-14b
for the interior, and both signals from E-15 for the extreme. The
six-decimal Markdown displays the old published value, the b0 = 1e-3
mean, the E-17 mean, and E-17 divided by the old published value.
The extreme published values are originally printed at four decimal
places. These are padded in Markdown, and that same printed value
is the ratio denominator.

Reports land under `out/interior/` and `out/extreme/` only after
both grids pass. The interior report includes `old_vs_new_mse.md`,
the detailed MSE, MAD, MCIW and crossing comparisons, `recomputed_claims.md`, and six LaTeX
fragments with the published competitor rows. HQ holds those artifacts
for release.

The extreme report is for comparison only. It includes `old_vs_new_mse.md`
and CSV comparisons for MSE, crossings, λ ESS, and λ medians. It shows E-17 relative
to both published values and E-15. The Markdown emphasizes every τ = 0.99
row, and all three extreme CSVs mark those rows with
`is_extreme_tau_099`. The crossing comparison records neighboring
and all-level average counts at 0.96–0.99. Only the four posterior
means from the same data seed enter each count, using the original
strict-inversion convention. Extreme LaTeX and manuscript claims are
disabled pending the owner's decision.

`health_by_tau.csv` summarizes each interior signal, τ, and prior rate
over the 300 noise/seed fits. `extreme/lambda_ess_by_tau.csv` summarizes
the corresponding extreme ESS and λ medians. The λ ESS values use
`coda::effectiveSize` on all 20,000 post-burn-in λ draws, matching
the earlier engineering reports. λ medians are medians of per-fit
means from the same every-30-sweeps posterior trace in each cohort.
This common trace summary also covers E-14 VS, whose compact
outputs predate the full-trace λ mean field.

Interior crossings use all five levels with the same within-seed
definition. The HQ headlines count each pair once across 100 seeds in
each of the three noises. The reports count fits below 0.40 acceptance
and name those fits in `low_acceptance_fits.csv`.

The full-size fixture exercised both builders with 6,600 synthetic
E-17 fits and their 6,600 archived references. The synthetic curves
tested ties in crossing counts and supported known ESS and λ medians.
The scope check verified six interior LaTeX fragments, the interior
claims, all extreme τ = 0.99 flags, and comparison-only extreme outputs.
A separate pilot fixture checked the seed grid and rejection above the
shared cap.
