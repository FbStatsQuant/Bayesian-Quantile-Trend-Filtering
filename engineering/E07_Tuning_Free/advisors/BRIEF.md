# E-07 advisor brief: tuning-free individual BQTF sampler (Engineering, 2026-11-23)

You are an internal advisor to the BQTF Engineering Department, the head of which is the author of this brief. Felipe, the owner (Rice Statistics), wants his **individual** Bayesian quantile trend-filtering sampler made as tuning-free as possible: priors with good defaults, informed by the new theory. Your job is **analysis and recommendations only**:
- Write one memo, at `engineering/E07_Tuning_Free/advisors/<YOUR_NAME>_memo.md` (Fable or Astra).
- Make no commits. Do not edit any other file.
- Run no heavy compute. Tiny local R/Python checks (seconds, 1 core) are fine. Never touch `/projects`, NOTS or ssh.
- I will verify each of your points independently and rule on it, so **show derivations and evidence**, and label any guess as a guess.

## The model and the sampler (read these)
- **Paper sampler:** `method/individual/Individual_Sampler_PMALA_Augmented.R`, `method/individual/pmala_exact_methods_note.md`, `method/individual/prox_admm_metric.cpp`.
  - The ALD working likelihood with scale σ, with Kozumi–Kobayashi z-augmentation.
  - A Laplace prior on D^{(k+1)}θ (k = 2 default, flat on degree-k polynomials).
  - λ ~ Gamma(a₀, b₀), σ ~ IG(a_σ, b_σ).
  - The Gibbs blocks are θ | z, λ, σ (P-MALA: a preconditioned MALA under a curvature metric W + cD′D with c = min(κλ²/2, 1e8), and an ADMM proximal map), then z | θ, then λ | θ (conjugate, plus an ASIS interweaving step), then σ | θ.
- **Paper settings:** `paper/sections/simulations.tex`.
  - VS uses Gamma(1, 1e-3) with ASIS, 30k sweeps and 10k burn-in. S uses Gamma(1, 5e-4) without ASIS, 20k sweeps and 5k burn-in.
  - σ ~ IG(0.1, 0.1), n = 500, init θ = y.
- **Theory statements:** `writing/W01_Statements/statements.tex`.
  - Regimes i–iv, assumptions (A1)–(A4), (EM) and (M).
  - σ̄ = τ(1−τ)/f_min. The learned σ sits near σ₀ = E ρ_τ(ε − q) < σ̄ for log-concave noise.
  - Theorem B is proved, with fixed λ and σ; A, A⁺, the oracle λ ≍ n^{5/2}/V for k = 2, and the rates are covered there as well.
  - `writing/W01_Statements/simulation_laws.R` computes σ̄ and σ₀ for the paper's heteroscedastic noise.
- **Engineering evidence:** `engineering/E02_Rate_Sims/REPORT.md` (learned-λ results, the P1 spread law, P-MALA vs Gibbs), `engineering/E04_Sampler_Check/REPORT.md`, `engineering/E05_PMALA_Fix/REPORT.md` (why P-MALA collapses at b₀ = n⁻²), and `engineering/E02_Rate_Sims/e02_lib.R`.
  - `e02_lib.R` contains the exact banded Gibbs reference: a scale mixture with 1/s ~ InvGauss, a perturb-and-solve banded QR θ draw, and `asis_step`.

## Non-negotiables (Felipe)
- Keep the overall Gibbs structure, and a **P-MALA-like θ update** (a preconditioned MALA; the preconditioner may change), followed by λ | θ and σ | θ.
- Individual sampler only, with k = 2 as the default.
- The user supplies only y, τ and optionally k.
- Any change that alters the paper's reported results needs HQ approval. Flag such changes.

## Two σ treatments, both to be presented
- **Option P:** σ | θ learned under a theory-coherent prior, which may depend on τ. The VP's prior recommendation is pending, so use IG(0.1, 0.1) as the stand-in. Ask whether any proper prior can move σ's posterior meaningfully, given n = 500 and its data-dominated conditional IG(a_σ + n, b_σ + Σρ…).
- **Option F:** σ fixed and deterministic, above σ̄, with λ learned under Gamma(a₀, c·n^{−5/2}) (decision D1; the proof uses a₀ = 2).
  - In simulation σ = 1.1σ̄.
  - In real use, a plug-in σ = c·τ(1−τ)/f̂, where f̂ is the sparsity or density at the τ-quantile, estimated with a Siddiqui or Hall–Sheather-type difference quotient from a pilot fit, or something better you can justify.
  - The heteroscedastic case needs f_min over u, not an average.

## Questions, ranked by user value (answer what you can, deepest on 1–3)
1. **λ prior default.** One rule must replace the paper's per-signal b₀. Candidates: b₀ = c·n^{−5/2}, a compound-Gamma (polynomial-tailed) prior, the paper's fixed b₀, or a better one.
   - It must be **invariant to the scale of y**. The penalty is λσ‖Dθ‖₁, or λ‖Dθ‖₁ in regime (iii); do the unit analysis and propose a standardisation.
   - What a₀ and c? How does the default interact with Options P and F?
2. **σ default** under Options P and F, including the plug-in estimator, its bias, and whether it stays above σ̄.
3. **Preconditioner and mixing for the P-MALA θ move.** For example:
   - the Gaussian-twin precision W + (λ²/2)D′D, banded;
   - a joint λ–θ move stronger than ASIS (E-05: ESS(log λ) ≈ 2 in 20k);
   - block-sampling the polynomial null space;
   - initialisation (E-05 root cause: λ | θ = y collapse);
   - step-size adaptation.
   Expected ESS/s against the exact Gibbs reference.
4. **Tuning-free operation:** automatic burn-in and adaptation, the default initialisation, and an automatic stopping rule (ESS or R-hat).

## Deliverable
A memo under ~1500 words:
- A ranked list of concrete recommendations. Each gives the exact default formula, rationale with a derivation or citation of the evidence files, expected effect, implementation cost, risk, and whether it changes the paper's results.
- Then the **3–5 pilot experiments** you would run first, within a 40 core-hour budget. The full grid is VS and S × 3 noise families × τ ∈ {0.05, 0.25, 0.5, 0.75, 0.95, 0.99}, at n = 500.
