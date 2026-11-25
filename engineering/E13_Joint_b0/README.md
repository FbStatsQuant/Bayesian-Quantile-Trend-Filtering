# E-13a: joint multi-quantile sampler, choice of the λ-prior rate b0 (screen at n = 500)

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

## Proposal

**b0 = 1e-3 with the new move ("fixed").**

**Data-only reason:**
- It is the smallest b0 (the least prior pull on λ) at which no chain collapses. The collapse is visible without the truth: σ_j jumps to 30–1,200 against a data scale of about 0.1, P-MALA acceptance drops to 0, and the λ split R-hat exceeds 1.5.
- It leaves a 10× margin to the first failing value (1e-4 collapsed in all 4 runs, and recovered only with the new move).
- Its pull on λ is 5–10%.
- At b0 = 1e-2 the pull is about 45% with no stability gain at n = 500.

**Caveat for larger n.** The warm-start λ ceiling is about (m + 1)/b0, so it grows with n. At n = 2000, b0 = 1e-3 gives a ceiling of about 2e6. That lies between the n = 500 collapse value (5e6) and the safe value (5e5). Hence the confirmation below tests 1e-3 against 1e-2.

## n = 2000 confirmation plan (NOT submitted)

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
