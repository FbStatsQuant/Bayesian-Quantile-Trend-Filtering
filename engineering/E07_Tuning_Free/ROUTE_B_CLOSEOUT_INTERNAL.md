# E-07 route B closeout (INTERNAL; not for Felipe)
*Engineering, 2026-11-23.*
- **Status:** route B was CLOSED by HQ at 16:40 CT because the joint gate failed Felipe's MSE bar (§1).
- **Record:** this file is the internal record of the measured results. Every number is paired (same datasets and seeds, same posterior) against Felipe's original sampler code at its published settings.
- **What stays in the repo:** the exact individual Gibbs stays as the company's simulation tool for Theory work, as in E-02. The joint v1, v2 and v3 samplers stay as an internal record.
- **Compute:** E-07 total 86.7 core-h (cap 88).

## 1. Joint gate (the decider): FAILED
- **Design:** the paper's own joint designs, with his settings in both arms.
  - **Tail set:** levels 0.90, 0.93, 0.96, 0.97, 0.98, 0.99. λⱼ ~ Gamma(1, b₀) with b₀ = 0.01 (VS) and 0.001 (S), from his package config `experiments/extreme_quantiles/packages/Extreme_Joint_Sampler/config.R`, line 12: `lambda_prior_rate = c(VS = 0.01, S = 0.001)`.
  - **Central set:** the interior joint batch t50, levels 0.2–0.8. b₀ = 0.01, from `experiments/interior_quantiles/joint_nots/config.R`, line 26.
  - **Both sets:** σⱼ ~ IG(0.1, 0.1) learned; ordering θ₁ ≤ … ≤ θ_J; 30,000 sweeps with 10,000 burn-in in both arms (his: 1 chain, as published; new: 2 chains).
  - **Grid:** signals VS and S × noise Gaussian, Beta, mixed normal, **seed 1** (one seed per configuration).
  - **Note:** the joint b₀ values differ from his individual-sampler values (VS 1e-3, S 5e-4) because they are his own joint configs. They are not ours.
- **Results** (78 levels; `joint_gibbs/gate_results/joint_gate_levels.csv`; plots `joint_gibbs/gate_results/*.png`):

| | Median MSE ratio (v3 / his) | Max | Levels > 1.25 | Levels < 1 |
|---|---|---|---|---|
| All 78 levels | 1.057 | 1.62 | **10** | 23 |
| Central set (42) | 1.059 | 1.62 | | 12 |
| Tail set (36) | 1.057 | 1.50 | | 11 |

  - **The bar** is median ≤ 1.10 and no level > 1.25. The 10 levels above 1.25 fail it.
  - **The 10 levels above 1.25 are:**
    - S-Beta central 0.3, 0.5, 0.6 and 0.7 (1.26, 1.28, 1.46, 1.62);
    - VS-Beta central 0.6 (1.26);
    - S-Mixed tail 0.96–0.98 (1.35–1.51);
    - VS-Beta tail 0.90 (1.28);
    - VS-Mixed tail 0.93 (1.26).
  - His output has lower MSE than the exact posterior mean at 55 of the 78 levels.
  - **v3 wins at:** VS-Beta tail 0.93–0.99 (0.51–0.82), VS-Normal (central 0.80–1.04, tail 0.89–1.06) and VS-Mixed central (0.88–1.07).
  - **Everything other than MSE passes:** 0 crossings in both arms, v3 R̂(log λ) ≤ 1.008, ESS(log λ)/s ≈ 1500× his (median), v3 wall time ≈ 10% of his (430–750 s against 2700–5800 s per configuration).
- **Why (measured, same posterior):**
  - His joint λ is not converged: ESS(log λ) is 1–58 per 30k sweeps.
  - His λ medians are **1.0–3.6× v3's** at almost every level. v3's λ is confirmed by an independent exact sampler (v2, single-site truncated Gibbs).
  - Where his output wins, his over-smoothed, unconverged chain lands closer to the truth than the exact posterior mean does (mostly S, and mixed noise).
- **Caveat:** one seed per configuration.

## 2. Individual sampler: exact augmented Gibbs vs his P-MALA (same posterior)
**Same posterior** means his priors exactly (λ ~ Gamma(1, b₀) with b₀ = 1e-3 for VS and 5e-4 for S; σ ~ IG(0.1, 0.1)), the same ALD working likelihood, k = 2, and his data generator. The point estimate is the posterior mean, and MSE is measured against the true quantile curve.

| n | Cells × seeds | Median MSE ratio (new / his) | S | VS | Cells better | Worst cell | Wall time (new / his) | 95% band coverage (his → new) |
|---|---|---|---|---|---|---|---|---|
| 500 | 18 × 5 | **0.91** | 0.72 | 1.02 | 12/18 | 1.04 | **0.19** | 0.79 → 0.80 |
| 1000 | 18 × 3 | **0.72** | 0.56 | 0.89 | 17/18 | 1.01 | **0.20** | 0.78 → 0.81 |
| 2000 | 6 × 3 | **0.49** | 0.44 | 0.58 | 6/6 | 0.65 | **0.14** | 0.77 → 0.77 |

- **Cells:** VS and S × Gaussian, Beta, mixed normal × τ ∈ {0.05, 0.5, 0.95}. At n = 2000 the cells are Gaussian only.
- **Per-cell tables** with paired 95% CIs: `gibbs_vs/paired_gibbs_vs_pmala.csv` (n = 500) and `gibbs_vs/paired_more_seeds.csv` (n = 1000/2000).
- **Fit plots** (data, true quantile, his fit, new fit, MSE and time in each title): `gibbs_vs/figs/`.
- **VS at n = 500:** ratios 0.97–1.04. His VS runs (ASIS on) already reach the posterior at n = 500. Two VS cells are 3–4% higher with CIs excluding 1 (Beta 0.05, Mixed 0.95).

**Mixing.** ESS(log λ) per second is ≈ 600–1700× his at n = 500.

**Convergence.** Each new-sampler fit runs 4 chains and stops when the rank-normalised R̂ is ≤ 1.01 and bulk and tail ESS are ≥ 400, with a cap of 20,000 sweeps per chain. 4 of 162 fits hit the cap without passing. **All four are included in the ratios above.**

| Cell | Seed | New: R̂, ESS(log λ), MSE | His (same data): ESS(log λ), MSE |
|---|---|---|---|
| n = 500 S Mixed 0.05 | 5 | 1.031, 93, 0.0901 | 8.5, 0.117 |
| n = 1000 S Mixed 0.95 | 2 | 1.014, 257, 0.0403 | 1.7, 0.0768 |
| n = 1000 VS Beta 0.95 | 1 | 1.063, 62, 0.00865 | 2.9, 0.00967 |
| n = 1000 VS Normal 0.05 | 2 | 1.010, 444, 0.00833 | 12.9, 0.0196 |

His sampler runs a single chain, so it has no R̂. Its ESS(log λ) is 1.2–13 per published-length run in these cells.

## 3. His own sampler: run length on S
His published S runs (20k sweeps, ASIS off) are too short. Running **his unchanged sampler** longer lowers S MSE:

| Sweeps (× published) | Median S MSE ratio vs 1× | Cells better | His λ ÷ posterior λ |
|---|---|---|---|
| 1× | 1 | — | 0.46 |
| 2× | 0.85 | 9/9 | 0.69 |
| 4× | 0.80 | 9/9 (4× vs 2×: 0.92) | 0.91 |

- **S needs ≈ 4× the published sweeps.**
- **VS needs no change:** his VS λ is at 0.99 of the posterior. This rests on partial 2× controls (21 fits) plus earlier checks.
- **Table:** `r1/runlength/runlength_cells.csv`.

## 4. Within his sampler: fewer ADMM iterations (S only)
- With 8 ADMM iterations per proximal map instead of 150, his sampler runs ≈ 8× more sweeps in the same wall time.
- **On S:** MSE median 0.75 (0.59–0.96, 9/9 cells better) at 0.94× his wall time.
- **On VS it gives no gain**, so it is reported for S only.
- **Table:** `r1/I8_vs_L_fits.csv`.

## 5. Outcome
- **No method from route B qualifies:** there is no joint win at his published settings. Nothing from this file goes to Felipe.
- **Facts about his published sampler** are summarised separately in `PAPER_RISK_convergence.md`, for HQ's decision.
