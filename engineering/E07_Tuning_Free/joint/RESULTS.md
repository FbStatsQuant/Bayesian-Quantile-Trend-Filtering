# E-07 lamjump port to the joint sampler: smoke test

File: `Joint_Sampler_PMALA_Augmented_E07lamjump.R` (copy of method/joint; method/ untouched).
Added: `lamjump_step` (verbatim individual, used when J = 1), `lamjump_box_step` (box prox T_B at lambda' forward and at lambda reverse;
untruncated Gaussian; theta* outside [lower, upper] rejected with no reverse solve and no runif; same MH ratio and log-lambda Jacobian),
`gibbs_joint_pmala(..., lamjump = FALSE, lamjump_s = 0.3)`; per level after the lambda/ASIS block, RM adaptation toward 0.25 (same rule
as individual, per-level s). New outputs: `lj_acc`, `lj_outside`, `s_lamjump`, `acc_lamjump`, `lj_outside_post`.
Harness: `smoke_scripts/` (sources the files up to "# ---- Main"; kernels from method/ via load_box_cpp(joint_dir, ind_dir)).

## Identity check (lamjump = FALSE vs original), seed 1001, n = 200, J = 2 (0.90, 0.93), 260 sweeps (warm 200, burn 220)
theta draws `identical()` = TRUE, max|diff| = 0; lambda, sigma, delta also identical. (lamjump = TRUE differs, as it should.)

## Smoke test: n = 500, VS/Normal, seed 1, taus 0.90..0.99, config.R settings, 3000 sweeps / 1000 burn-in, sampler seed 1001, 1 core each
Post-burn-in means. Crossings among posterior means (all 15 pairs, and draws): 0 in both runs.

| tau | lj acc | lj outside-box | s final | lambda mean (LJ) | lambda mean (no LJ) | MSE (LJ) | MSE (no LJ) |
|---|---|---|---|---|---|---|---|
| 0.90 | 0.353 | 0.096 | 0.120 | 14992 | 15971 | 0.1189 | 0.1360 |
| 0.93 | 0.362 | 0.182 | 0.135 | 16345 | 20197 | 0.1654 | 0.1853 |
| 0.96 | 0.378 | 0.179 | 0.146 | 18859 | 21646 | 0.1716 | 0.1801 |
| 0.97 | 0.298 | 0.297 | 0.129 | 14710 | 18481 | 0.1779 | 0.1876 |
| 0.98 | 0.374 | 0.182 | 0.149 | 18242 | 17776 | 0.1934 | 0.2042 |
| 0.99 | 0.255 | 0.383 | 0.062 | 657 | 924 | 0.3999 | 0.5638 |

Seconds per sweep: 0.166 (lamjump) vs 0.133 (no lamjump), +25%. Theta-move acceptance (LJ / no LJ), post burn-in: 0.78/0.78, 0.76/0.76, 0.75/0.74, 0.63/0.70, 0.75/0.74, 0.46/0.51.
Theta-move outside-box rate (LJ / no LJ): 0.10/0.12, 0.17/0.17, 0.19/0.19, 0.31/0.23, 0.20/0.18, 0.39/0.30.

## Caveats
- Both runs are far from converged at 3000 sweeps: lambda starts ~m = 497 but drifts to ~40000 at the low levels by sweep 500 and decays slowly
  (sweep 1000 -> 3000: ~36000 -> ~5300-10000); theta acceptance was ~0 for levels 1-5 until delta recovered after sweep ~500-1000.
  MSEs (0.12-0.56) are 5-10x the paper individual values, in both runs: this is a burn-in/short-chain effect, NOT a lamjump bug,
  and the LJ-vs-no-LJ MSE gap is single-seed, single-chain and not evidence either way.
- Lamjump outside-box rejection (0.10-0.38) is high at upper levels (tight boxes); it is the proposal being untruncated, as specified.
- Single seed per arm; no mixing diagnostics (ESS) computed.
