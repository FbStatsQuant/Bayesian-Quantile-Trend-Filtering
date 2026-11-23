# E-07 consultant brief: a better PROXIMAL sampler than Felipe's (INTERNAL)
*Engineering, 2026-11-23. Read carefully; everything below is measured unless marked otherwise.*

## Your role
You are a senior consultant to the BQTF Engineering Department, and you lead on ideas.
- **The goal (Felipe):** a sampler that is consistently more accurate than his at **equal compute**. That means lower paired MSE against the true quantile across the paper's grid, no cell meaningfully worse (paired median ratio clearly below 1, no cell above 1.25), mixing and ESS/s no worse, and a joint non-crossing version that has actually been run and works.
- **Hard constraint:** the method must rest on **proximal operators like his** (proximal MCMC / P-MALA family). Exact Gaussian or augmented-Gibbs θ draws (Park–Casella type) are **out of scope as replacements**. Changes to hyperparameters or σ/λ handling inside his proximal sampler are allowed.
- **Rules:** write only `engineering/E07_Tuning_Free/consult/<YOUR_NAME>_ideas.md`. No commits, no NOTS/ssh, no heavy compute; tiny local checks of a few seconds on 1 core are OK. Label guesses as guesses. We run experiments; you design them.

## Read
- `method/individual/Individual_Sampler_PMALA_Augmented.R` (`gibbs_pmala_aug`, `pmala_step`, `asis_step`, `lamjump_step`, `metric_dc`) and `method/individual/prox_admm_metric.cpp`.
- `method/joint/Joint_Sampler_PMALA_Augmented.R` (the box-constrained P-MALA, `asis_box_step`).
- `paper/sections/methodology.tex` and `appendix_pmala.tex`.
- `paper/sections/simulations.tex` (benchmarks). The paper settings: VS uses b₀ = 1e-3, ASIS on, 30k sweeps, 10k burn. S uses b₀ = 5e-4, ASIS off, 20k sweeps, 5k burn. n = 500, σ ~ IG(0.1, 0.1), init θ = y, λ₀ = m.

## Measured facts (today; paired, same data and seeds; tables under `engineering/E07_Tuning_Free/`)
1. **His λ chain is the bottleneck.**
   - ESS(log λ) is **2–30 per paper-length run** at n = 500 (`sigma_sprint/sigma_sprint_table.csv`).
   - At **n = 1000/2000** the 2-chain **R̂(log λ) is 1.3–2.3**. His λ median is 20× below the exact posterior on S at n = 2000, and 2.8× below on VS (`route_a/variants_results/`).
   - σ, by contrast, mixes well and agrees with the exact posterior: Gibbs/P-MALA σ ratio 1.000 (0.94–1.07) (`route_a/results/`).
2. **S at n = 500 is under-converged at the published length.**
   - His own sampler at **2× sweeps lowers S MSE in 9/9 cells, median ratio 0.85** (0.78–0.95), with ESS/s unchanged (`r1/p3/p3_verdict_summary.csv`).
   - His as-run λ̄ is **0.46×** the exact-posterior median at 1× and **0.69×** at 2×.
3. **VS at n = 500 sits at its posterior.** With ASIS on, VS λ agrees with a converged run within noise. So there is no mixing headroom on VS at n = 500.
4. **Failed candidates (internal; do not re-propose without a new mechanism):**
   - **P1, ASIS on for S:** paired S median 1.01, one cell 1.26.
   - **P2, warm start at a SIC-chosen QTF MAP:** S median 1.05, VS max 1.11.
   - **P3, his `lamjump` (joint proximal (λ, θ) jump):** S median 0.87 against 1×, but **1.02 against 2× sweeps at equal wall time**, with ESS(log λ)/s 0.47×. Its gain was compute.
   - **Fixed σ (1.1σ̄, any λ rule):** MSE up to 24× worse on VS; σ must stay learned.
   - **λ fixed at κn^{5/2} (one global κ):** 3/18 cells above 1.25.
5. **Cost reference:** his sweep costs ≈ 5.4 ms at n = 500 (NOTS), linear in n. `lamjump` adds ≈ 100% per sweep.

## What we need from you (be concrete; ≤ 1500 words)
1. **Ranked list (3–6) of proximal-family ideas** most likely to give a **real per-compute accuracy gain**. For each idea give:
   - **Mechanism:** why it should fix his λ–θ mixing problem better than ASIS or lamjump, or otherwise improve accuracy per unit compute.
   - **Exact algorithm:** what changes in his code, with formulas, and why it is still an exact MCMC for his posterior (or the exact posterior of a stated variant).
   - **Cost per sweep** relative to his.
   - **Data signature that would CONFIRM it,** and the one that would KILL it, in a small paired pilot (≤ 2 core-h) at **equal wall time** against his sampler at k× sweeps.
   - **Joint version:** how it extends to the box-constrained ordered sampler.
2. **What you would NOT try, and why.**
