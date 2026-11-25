# E-13a: joint multi-quantile sampler, choice of the λ-prior rate b0 (screen at n = 500)

Phase 2 (after the fixes) is first. Phase 1 (the diagnosis screen, before any change to `method/`) is kept below as the record.

# Phase 2: after the warm-start and z-draw fixes (HQ GO 2026-11-25)

**What changed in `method/`:** see [CHANGES.md](CHANGES.md), one line per change with the reason the stationary target is unchanged. In short:
- a data-only start: a running-median pilot fit gives θ0, σ0 and z0;
- the warm start's optimiser is now solved accurately: ADMM must meet its tolerance, otherwise the interior-point solver (IPM) takes over;
- λ is held at its start value during the 200 warm sweeps;
- a σ guard acts in burn-in only and is logged;
- a numerically stable inverse-Gaussian formula for the z draw.

The same code is in both samplers, and `e13b_zdraw_test.R` checks that it is identical.

**Where things are.**
- NOTS run directory: `runs/E13b-joint-b0-fix-20261125/`. Code snapshots: `code/` (after, commit 3ec3328) and `code_before/` (772a4a3).
- Jobs:
  - 2889828: joint, tasks 1–12;
  - 2889829: individual + before/after reference, tasks 13–44;
  - 2889830 and 2889831: checks;
  - 2890368: analysis;
  - 2890403: long reference chains.
- The outputs are pulled to Owls `runs/E13b-joint-b0-fix-20261125/nots/`.
- Tables:
  - [e13b_screen_table.md](e13b_screen_table.md): one row per b0 × move × τ;
  - [e13b_screen_runs.csv](e13b_screen_runs.csv): one row per run × level;
  - [e13b_reference.csv](e13b_reference.csv), [e13b_reference_chains.csv](e13b_reference_chains.csv) and [e13b_reference_lambda_drift.csv](e13b_reference_lambda_drift.csv): before vs after;
  - [e13b_zdraw_ks.csv](e13b_zdraw_ks.csv): the z-draw test.
- Scripts: `e13b_run.R`, `e13b.slurm`, `e13b_analyze.R`, `e13b_zdraw_test.R`, `e13b_warm_check.R`, `e13b_joint_tests.R`.

## Tests

| Test | Result |
|---|---|
| z draw vs the exact law (KS, 1e5 draws, τ = 0.3 and 0.7, σ = 0.12; residual \|e\| = 1e-6, 1e-8, 1e-10, 1e-12, 0.05) | **New: passes all 10 cases** (KS p 0.20–0.58). **Old: fails at \|e\| ≤ 1e-8** (KS D 0.045–0.061 at 1e-8; 0.42–0.44 at 1e-10 and 1e-12, where 42–44% of draws sit at the 1e4 clamp instead of near the true z ≈ 0.05). Old and new agree at 1e-6 and 0.05 (same random numbers, identical KS statistic). |
| Joint sampler tests T1–T4 + T3b | **PASS** (T1: J = 1 is bitwise identical to the individual sampler under the new start). Needs `--mem=16G` (the T2 grid). |
| Joint prox test P1 (`identical(p_0$theta, p_u)`) | Fails, **identically on the before code** (check 9): pre-existing, not touched. |
| Individual `run_tests()` | Tests 1–6d pass. Test 7 (the λ-jump move, **off by default**) fails, **identically on the before code** (check 8: E λ 0.842 vs exact 3.287, in both). Pre-existing, not touched. |
| Warm start, b0 = 1e-5, accurate solves, λ held (`e13b_warm_check.R`) | Individual: acceptance 0.70, MSE 0.006. Joint: acceptance 0.62–0.65, MSE 0.005–0.018, σ 0.05–0.14 throughout. Every warm solve matches glmgen (relative objective gap ≤ 1.5e-8). |
| Same, but λ drawn during the warm start (the old rule) | Fails as predicted: λ → 1e7, acceptance 0, MSE 0.18 (individual) and 0.24–0.91 (joint). **This is why λ is held.** |

## Screen results (n = 500; 12 joint runs, 24 individual references; ranges over the 4 levels × 2 chains)

| b0 | move | crash | λ joint | λ joint / λ indiv | MSE joint / indiv (mean; range) | λ split R-hat | λ ESS (min; median) | acceptance | σ max after warm | σ guard fired | crossings |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1e-5 | new (fixed) | none | 2.15e3–2.47e3 | 1.03–1.13 | 0.93; 0.90–1.07 | 1.00 | 74; 188 | 0.50 | 0.07–0.17 | 0 | 0 |
| 1e-5 | old (poly) | none | 1.79e3–2.59e3 | 0.83–1.10 | 0.90; 0.78–1.00 | 1.17–1.43 | 7; 9.5 | 0.50 | 0.07–0.16 | 0 | 0 |
| 1e-4 | new | none | 2.10e3–2.47e3 | 1.03–1.12 | 0.94; 0.77–1.03 | 1.02–1.05 | 130; 169 | 0.50 | 0.07–0.17 | 0 | 0 |
| 1e-4 | old | none | 1.99e3–2.59e3 | 1.07–1.25 | 0.98; 0.91–1.07 | 1.10–1.35 | 5; 8.5 | 0.49–0.50 | 0.07–0.17 | 0 | 0 |
| 1e-3 | new | none | 1.86e3–2.27e3 | 1.01–1.10 | 0.95; 0.86–1.03 | 1.00–1.02 | 162; 244 | 0.50–0.51 | 0.07–0.16 | 0 | 0 |
| 1e-3 | old | none | 1.77e3–2.56e3 | 0.90–1.28 | 0.99; 0.92–1.07 | 1.02–1.28 | 8; 11.5 | 0.50 | 0.07–0.17 | 0 | 0 |

- **Crossings: 0** quantile-crossing instances (draw × point × adjacent pair) over the 20k kept draws of every joint run. This holds by construction (the box).
- **Warm-start IPM fallback:** it fired in **every** warm sweep of every run (200 per level), joint and individual. ADMM at its fixed step parameter never reached the 1e-6 tolerance in 300 iterations.
  - The IPM ends on its stall rule (its "converged" flag is 0), which is normal for it. It still matched glmgen to a relative objective gap of 1.5e-8 or better.
- **σ guard: never fired** (0 of 10k burn-in sweeps in all 36 runs). σ after the warm start stays at 0.06–0.17, the data scale. In phase 1 it was 30–1,200.
- **Individual references:** λ 1.7e3–2.5e3, MSE 0.0038–0.0049 at τ ≤ 0.7 and 0.027–0.031 at τ = 0.9, 2.2–2.5 min per run; σ guard 0.
- **Prior pull** (the new move, individual, b0 = 1e-3 vs 1e-5): λ is lower by 5–11%, with no MSE change.
- **Run time:** 27.5–29.3 min per joint run, the same as phase 1.

## What it means

1. **The pathology is gone at every b0, including 1e-5.**
   - There are no crashes and no σ runaways.
   - The joint fit matches the individual fits: MSE ratio 0.95 on average, never above 1.07.
   - Every phase-1 failure cell (b0 = 1e-5 both moves, b0 = 1e-4 old move) is now healthy.
   - **b0 no longer needs to be large for stability. It can be chosen on statistical grounds.**
2. **Use the new λ move (fixed).**
   - It mixes λ: R-hat ≤ 1.05, ESS 74–331.
   - The old move does not: ESS 5–19, R-hat up to 1.43.
   - This is the same finding as in phase 1, now without the confound.
3. **b0 = 1e-5 is clean**, so the n = 2000 comparison is 1e-5 vs 1e-3 (see the plan below).

## Before vs after: the individual sampler at its defaults (HQ test 3)

- **Setting:** VS, n = 500, τ = 0.75, data seed 1, chains 1001–1004.
- **Before:** commit 772a4a3, the code before E-13a. **After:** the fixed code.
- **The MC standard error** is the between-chain SE (the standard deviation over the 4 chains / 2); z = the difference / the SE of the difference.

| statistic | before | after | difference (SE) | z |
|---|---|---|---|---|
| **Long chains: 120k sweeps (10k burn-in), the decisive comparison** | | | | |
| MSE | 0.00521 | 0.00519 | −0.00002 (0.00009) | −0.21 |
| coverage of the 95% band | 0.9615 | 0.9620 | +0.0005 (0.0013) | 0.40 |
| width of the 95% band | 0.2832 | 0.2831 | −0.0002 (0.0009) | −0.18 |
| λ mean | 2,301 | 2,314 | +13 (12) | 1.06 |
| σ mean | 0.11000 | 0.11001 | +0.00001 (0.00003) | 0.27 |
| **Usual length: 30k sweeps (10k burn-in)** | | | | |
| MSE | 0.00515 | 0.00533 | +0.00019 (0.00022) | 0.84 |
| coverage | 0.965 | 0.955 | −0.011 (0.016) | −0.67 |
| width | 0.2824 | 0.2816 | −0.0009 (0.0016) | −0.55 |
| λ mean | 2,251 | 2,342 | **+91 (13)*** | **6.8*** |
| σ mean | 0.10996 | 0.11009 | +0.00012 (0.00004) | 2.8 |

\* The SE of 13 understates the uncertainty, so z = 6.8 overstates the gap. In the long before-chains, the quarter means of λ vary by about ±100 between chains (2,120–2,381), whereas the within-run SE is about 10 (HQ review, 2026-11-25).

- **λ differs by 4% at 30k. This is consistent with slow λ burn-in in the old code, and the two versions agree at 120k.**
  - The old start leaves λ ≈ 400–570 at the end of the warm start, and λ then climbs slowly from below.
  - In the long before-chains, the λ mean over the first 20k kept sweeps is 2,224–2,267 (the 30k-run window), and over the last 20k it is 2,297–2,372.
  - The after chains are flat from the start: 2,317–2,363 in the first 20k and 2,310–2,372 in the last 20k.
  - At 120k sweeps the two versions agree on every statistic (all |z| ≤ 1.06).
  - The σ gap at 30k (0.1%, z = 2.8) also disappears.
- **The fix therefore shortens the effective burn-in of the individual sampler** and leaves its target unchanged. This is relevant to E-14, which reruns the paper's individual simulations at the usual length. In this case, the old code's 30k-sweep λ mean was about 2.5% below the stationary value (2,251 vs about 2,308); MSE, coverage and width were not affected beyond MC noise.
- **Caveat:** the ESS that coda reports within a single 30k run does not reveal this slow drift. Only the long chains and the independent starting points do. The long chains give λ ESS ≈ 1,100–1,600 per 110k kept draws.
- Files: [e13b_reference.csv](e13b_reference.csv) and [e13b_reference_chains.csv](e13b_reference_chains.csv) (30k); [e13b_reference_long.csv](e13b_reference_long.csv) and [e13b_reference_long_chains.csv](e13b_reference_long_chains.csv) (120k); [e13b_reference_lambda_drift.csv](e13b_reference_lambda_drift.csv).

## n = 2000 confirmation plan (NOT submitted; replaces the phase-1 plan)

- **Design:**
  - Joint J = 4 (τ = 0.3, 0.5, 0.7, 0.9), new move, Normal noise, data seed 1, 30k sweeps with 10k burn-in, 2 chains (1001/1002).
  - Baselines VS, S and PC × **b0 ∈ {1e-5, 1e-3}** = **12 joint runs**.
  - Individual reference: same baselines, b0 and τ, one chain = **24 runs**.
  - The phase-1 boundary pair (b0 = 1e-4) is dropped: with λ held during the warm start there is no λ ceiling (m + 1)/b0 left to locate.
- **Cost:**
  - At n = 500 on NOTS: 28 min per joint run, 2.3 min per individual run. All kernels are banded and O(n) per sweep, so expect about 4×: about 2 h per joint run and about 9 min per individual run.
  - Memory: about 1.3 GB of θ draws, so `--mem=8G` (joint) and 3G (individual).
  - Joint 12 × 2 h = 24 core-hours; individual 24 × 0.15 h = 3.6 core-hours; a 600-sweep pilot about 0.2 core-hours. **Total ≈ 28 core-hours.** This needs a GO.
- **Pass criteria (data-only, per run):**
  - σ guard never fires, and σ_j after the warm start stays within 10 × σ0_j;
  - P-MALA acceptance 0.4–0.6;
  - λ split R-hat ≤ 1.05 and ESS ≥ 100 per level;
  - joint MSE within 1.2× of the individual's at every level (a check only, using the truth after the fact).
  - **Pick 1e-5 (the least prior pull) if all 1e-5 runs pass; otherwise 1e-3.**
- **Scripts:** `e13b_run.R` needs n, the baseline and the b0 grid as task-table parameters (a small change). It reuses `e13b.slurm` with the larger `--mem` and `--time=05:00:00`.

## Compute used in phase 2 (NOTS, from sacct)

About **8.7 core-hours**. Slurm allocates 2 hardware threads per 1-core task, so sacct shows 17.3 CPU-hours.

| Jobs | Core-hours |
|---|---|
| Joint, 12 runs | 5.7 |
| Individual + before/after reference, 32 runs | 1.4 |
| Long reference chains, 8 × 120k sweeps | 1.2 |
| Checks and tests | 0.4 |
| Analyses | < 0.01 |

The approved ceiling was 10. Owls: none (owls_run refused while other teams used 8 cores, so all checks ran on NOTS).

# Phase 1 (before any change to method/)

**Question.** Does the joint sampler (several quantile levels fitted together, with no crossing) run stably, and at which b0 in λ ~ Gamma(1, b0)?

**Setting.**
- Data: VS baseline, Normal noise, n = 500, data seed 1, order 2.
- Joint fit of τ = (0.3, 0.5, 0.7, 0.9).
- σ ~ IG(0.1, 0.1); 30k sweeps with 10k burn-in, 200 warm sweeps; samplers' defaults.
- Grid: b0 ∈ {1e-5, 1e-4, 1e-3, 1e-2} × λ move {poly (old), fixed (new spline move)} × 2 chains (seeds 1001/1002) = 16 joint runs.
- Reference: the individual sampler at the same b0 and move, one chain per τ (32 runs).
- Nothing in `method/` was changed.

**Where things are.**
- Runs: NOTS jobs 2889019 (joint) and 2889020 (individual), plus pilot 2889011. Outputs are in `runs/E13-joint-b0-20261125/` on NOTS, pulled to Owls `runs/E13-joint-b0-20261125/nots/`.
- Diagnosis: [DIAGNOSIS.md](DIAGNOSIS.md).
- Per-run table: [e13_screen_runs.csv](e13_screen_runs.csv). Per-cell table: [e13_screen_table.md](e13_screen_table.md). Summary: [e13_screen_summary.csv](e13_screen_summary.csv).

## Results (one row per b0 × move; ranges over the 4 levels and 2 chains)

| b0 | move | crash | λ joint | λ joint / λ indiv at 1e-5 | λ indiv / λ indiv at 1e-5 | MSE joint / indiv (mean; max) | λ split R-hat (max) | λ ESS (min; median) | σ max | min/run |
|---|---|---|---|---|---|---|---|---|---|---|
| 1e-5 | new | none | 2.1e3 to 1.9e5 | 1.1 to 83 | 1.00 | **11,700; 33,000** | 1.57 | 7; 29 | **5.4** | 29.7 |
| 1e-5 | old | none | 1.9e3 to 1.1e5 | 0.9 to 66 | 1.00 | **5,200; 26,000** | 1.53 | 3; 324 | **3.3** | 29.3 |
| 1e-4 | new | none | 2.1e3 to 2.4e3 | 1.03 to 1.13 | 0.95 to 1.04 | 0.96; 1.11 | 1.01 | 169; 236 | 0.14 | 29.1 |
| 1e-4 | old | none | 2.1e3 to 7.0e4 | 0.96 to 31 | 0.93 to 1.33 | **23; 40** | **2.78** | 2; 4 | 0.26 | 29.0 |
| 1e-3 | new | none | 1.9e3 to 2.3e3 | 0.94 to 1.06 | 0.90 to 0.95 | 0.99; 1.14 | 1.03 | 159; 218 | 0.14 | 28.9 |
| 1e-3 | old | none | 2.1e3 to 2.6e3 | 0.95 to 1.34 | 0.70 to 1.18 | 1.01; 1.12 | 1.32 | 6; 9 | 0.14 | 28.8 |
| 1e-2 | new | none | 1.1e3 to 1.3e3 | 0.56 to 0.60 | 0.53 to 0.56 | 1.01; 1.18 | 1.02 | 191; 238 | 0.13 | 28.8 |
| 1e-2 | old | none | 1.2e3 to 1.4e3 | 0.54 to 0.81 | 0.44 to 0.66 | 0.95; 1.09 | 1.31 | 6; 12 | 0.14 | 28.4 |

- **Healthy reference:** individual λ ≈ 1.5e3–2.6e3 for b0 ≤ 1e-3 and about 1.2e3 at b0 = 1e-2. Individual MSE ≈ 0.004–0.005 at τ ≤ 0.7 and about 0.028 at τ = 0.9. σ ≈ 0.06–0.14.
- **No crossings anywhere:** 0 of the 20k draws in every run, and 0 crossings in the posterior means. This holds by construction (the box), so it is no evidence of mixing.
- **No crashes** in the 48 runs. The crash reproduces at J = 2 (see DIAGNOSIS §2).
- **Warm-start λ ceiling** (the largest λ in sweeps 1–200), about (m + 1)/b0: 5e7 / 5e6 / 5e5 / 5e4 for b0 = 1e-5 / 1e-4 / 1e-3 / 1e-2, identical for both moves.
  - **σ collapse in the warm start** (σ above 1, against a data scale of about 0.1): at b0 = 1e-5 and 1e-4 in all 8 runs (σ up to 45–1,200); never at b0 = 1e-3 or 1e-2.
- **After the collapse:**
  - **b0 = 1e-4, new move:** recovers before the burn-in ends (chain 1 by sweep 2,600; chain 2 by sweep 210).
  - **b0 = 1e-4, old move:** stays over-smoothed (λ 2–7e4, MSE 0.03–0.17).
  - **b0 = 1e-5, both moves:** still broken at sweep 30k (σ up to 5.4, MSE 0.3–150).

## What it means

1. **At b0 = 1e-5 the joint sampler is not usable, with either move.** The levels that have an upper neighbour collapse during the warm start (DIAGNOSIS §1) and are still off the data after 30k sweeps.
   - **The new move does not remove the pathology:** at b0 = 1e-5 its stuck λ is higher and its MSE mostly worse than the old move's.
   - **The new move shifts the safe range by one decade:** at b0 = 1e-4 it recovers from the collapse within the burn-in, while the old move does not.
2. **At b0 = 1e-3 and 1e-2 there is no collapse, and the joint fit matches the individual fits.** MSE ratio 0.95–1.01 on average, at most 1.18, at every level.
3. **The new move mixes λ well.** Split R-hat ≤ 1.03 and ESS 159–382. The old move's λ ESS is only 6–20 even when healthy, with R-hat up to 1.32. So **use the new move in the joint sampler.**
4. **Prior pull:**
   - b0 = 1e-3 lowers λ by 5–10% relative to b0 = 1e-5 (individual: 0.90–0.95), with no MSE change.
   - b0 = 1e-2 lowers λ by about 45% (0.53–0.60). MSE matches the individual fit at the same b0, but at τ = 0.3 it is 15–25% higher than at b0 = 1e-3 (0.0051 vs 0.0040–0.0044).
5. **b0 here works around a warm-start defect.** It does not fix it.
   - The warm start's optimiser is badly scaled at large λ (88% of its solves are inaccurate).
   - b0 helps only because it caps λ at about (m + 1)/b0 during the warm start.
   - **The real fix is the warm start** (DIAGNOSIS §3). With it, b0 could be chosen on statistical grounds alone.

## Proposal (phase 1; superseded: with the fixes, b0 = 1e-5 is clean)

**b0 = 1e-3 with the new move ("fixed").**

**Data-only reason:**
- It is the smallest b0 (the least prior pull on λ) at which no chain collapses. The collapse is visible without the truth: σ_j jumps to 30–1,200 against a data scale of about 0.1, P-MALA acceptance drops to 0, and the λ split R-hat exceeds 1.5.
- It leaves a 10× margin to the first failing value (1e-4 collapsed in all 4 runs, and recovered only with the new move).
- Its pull on λ is 5–10%.
- At b0 = 1e-2 the pull is about 45% with no stability gain at n = 500.

**Caveat for larger n.** The warm-start λ ceiling is about (m + 1)/b0, so it grows with n. At n = 2000, b0 = 1e-3 gives a ceiling of about 2e6. That lies between the n = 500 collapse value (5e6) and the safe value (5e5). Hence the confirmation below tests 1e-3 against 1e-2.

## n = 2000 confirmation plan (phase 1; superseded by the phase-2 plan above)

- **Design:**
  - Joint J = 4 (τ = 0.3, 0.5, 0.7, 0.9), new move, Normal noise, data seed 1, 30k sweeps with 10k burn-in, 2 chains (1001/1002).
  - Baselines VS, S and PC × b0 ∈ {1e-3, 1e-2} = **12 joint runs**.
  - Individual reference: same baselines, b0 and τ, one chain = **24 runs**.
  - Optional boundary pair: VS at b0 = 1e-4, 2 chains (+2 runs), to locate the collapse edge at n = 2000.
- **Cost:**
  - At n = 500 on NOTS: 29 min per joint run, 2.2 min per individual run.
  - All kernels are banded, O(n) per sweep, so expect about 4×: about 2 h per joint run and about 9 min per individual run. Memory: the θ draws are 20k × 2000 × 4 × 8 bytes ≈ 1.3 GB, so request `--mem=8G` for joint runs and 3G for individual runs.
  - Joint 12 × 2 h = 24 core-hours; individual 24 × 0.15 h = 3.6 core-hours; boundary pair 4 core-hours. **Total ≈ 28 core-hours (32 with the boundary pair).** This is above the 20 core-hour pre-approval, so it needs a GO.
  - Measure with a 600-sweep pilot first.
- **Pass criteria (data-only, per run):**
  - σ_j never above 1 after the warm start (a data-scale flag);
  - P-MALA acceptance 0.4–0.6;
  - λ split R-hat ≤ 1.05 and ESS ≥ 100 per level;
  - joint MSE within 1.2× of the individual's at every level (check only, using the truth after the fact).
  - **Pick 1e-3 if all 1e-3 runs pass; otherwise 1e-2.**
- **Scripts:** `e13_run.R` needs n, baseline and the b0 grid as task-table parameters (a small change). It reuses `e13.slurm` with the larger `--mem` and `--time=05:00:00`.

## Compute used

- NOTS: about 9.1 core-hours. Joint: 16 runs × 29 min = 7.7 h. Individual: 32 runs × 2.2 min = 1.2 h. Pilot: 0.5 min.
- Owls: 8 short diagnosis runs via owls_run -j 1, about 15 core-minutes in total.
