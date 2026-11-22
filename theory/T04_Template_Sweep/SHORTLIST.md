# T-04 Proof-template shortlist (Stage-A theorem)

*Theory Department, 2026-11-22. Five cheap searchers (2 Sonnet 5.5, 1 Haiku 5.5, 1 Codex gpt-6.1-terra, 1 Codex gpt-6-luna). I read the finalists' theorem statements, assumptions and proof sketches myself. Audit trail: `search_log.md`.*

## Verdict

**No paper reaches a 4 or a 5.** Nobody has a proof we could largely copy. No paper combines any two of the following:
- a Laplace / ℓ₁ / total-variation prior on differences;
- a check-loss or misspecified likelihood in growing dimension;
- a Laplace-type small-ball bound for integrated walks.

The two papers below are the best **partial** blueprints. Each covers a different half of our proof:
- **Atchadé (2017)** covers the likelihood side: steps (b), (d) and (e).
- **Bach & Klein (2022)** covers the prior side: the difference-penalty prior with an improper polynomial part, the spectral small-ball computation, and the hyperprior on the smoothing scale.

The prior's Laplace-specific concentration is already covered by Agapiou, Dashti & Helin (2021, Prop. 2.15 and Thm 3.1), which is in `Papers/`.

Both searchers who scored above 3 picked papers that were excluded: Agapiou & Wang (5/5) is already in `Papers/`, and Agapiou & Savva (4/5) is a T-01 entry. That confirms our existing library already holds the strongest prior-side templates.

---

### 1. Atchadé (2017): good-event template for the misspecified likelihood. Usefulness **3/5**

**Citation.** Y. F. Atchadé, *On the contraction properties of some high-dimensional quasi-posterior distributions*, Ann. Statist. 45(5), 2248–2273 (2017). [arXiv:1508.07929](https://arxiv.org/abs/1508.07929).

**What it proves.** It gives contraction for a quasi-posterior, meaning a quasi-likelihood q_{n,θ} (not necessarily the true density) times a sparsity prior on ℝᵈ, with d and n both growing (Theorem 3, eqs. 2.8–2.9). The proof is *pathwise*. It defines a "good" sample set Eₙ, the intersection of three events:
- a score event E_{n,0}: sup over the cone of |⟨∇log q_{θ⋆}, u⟩| ≤ λ/2;
- a curvature event Ě_{n,1}: Bregman excess ≤ −r(‖θ−θ⋆‖)/2 on the cone;
- a lower-bound event Ê_{n,1}, which controls the normalizing constant.

On Eₙ it bounds the posterior mass of each annulus {jMε̄ < ‖θ−θ⋆‖ ≤ (j+1)Mε̄} by packing numbers times e^{−r(jMε̄/2)/8}, a peeling argument. P(Eₙᶜ) is bounded separately. There are no tests, no KL neighbourhoods and no true-model likelihood.

**What it would carry in our proof.**
- The good-event structure is exactly our L6 + L8 + L9 skeleton:
  - E_{n,0} becomes our bounded check-loss score uᵢ = τ − 1{yᵢ ≤ θ⋆ᵢ}. It is bounded, so no moments are needed; this is Padilla's Lemma 24.
  - Ě_{n,1} becomes our uniform excess-check-loss lower bound, L8.
  - Ê_{n,1} becomes our evidence lower bound, L6.
  - The peeling sum over annuli is a concrete mechanism for the far region, L9.
- **What changes:**
  - Their H2 needs differentiable log q, so we substitute Knight's identity / the subgradient decomposition for the check loss.
  - Their split cones and spike-and-slab prior (H3) become our two-level Laplace sieve (ADH) with the shift and small-ball prior mass.
  - ℓ₂ becomes the Huber loss Δ²ₙ, and packing numbers become the entropy of the sieve shells.

---

### 2. Bach & Klein (2022): prior-side template for a difference-penalty prior with an improper polynomial part. Usefulness **3/5**

**Citation.** P. Bach and N. Klein, *Posterior concentration rates for Bayesian penalized splines*, [arXiv:2109.04288](https://arxiv.org/abs/2109.04288) (v3, 2022).

**What it proves.** Theorem 4.1: Gaussian nonparametric regression with a Bayesian O-spline (P-spline) prior gives near-optimal contraction n^{−m₀/(2m₀+1)}(log n)^{1/2} in the empirical L² norm. The prior is a Gaussian q-th-order **difference-penalty** prior, partially improper on polynomials, and carries a hyperprior on the smoothing variance. The hyperprior condition A5 is a two-sided "balance between over- and undersmoothing". It holds for, e.g., a Weibull(1/2) hyperprior and fails for others (Cor. 4.2).

**What it would carry in our proof.**
- The prior-mass lower bound for a difference prior. Three pieces transfer:
  - a proper version of the partially improper prior (Def. 2.2), a direct template for our flat quadratic part (L5);
  - the split into a polynomial part and a penalized part, analysed in the Demmler–Reinsch eigenbasis with the eigenvalue bounds of Xiao (2019). This is the rigorous counterpart of our numerical spectral small-ball computation, the Gaussian half of L3;
  - the shifted-ball inequality (Hoffmann-Jørgensen).
- Its hyperprior condition A5 is the natural template for the **Stage-C** analysis of λ ~ Gamma(a₀, b₀,ₙ), via the smoothing variance τ² ↔ 1/λ².
- **What changes:**
  - Everything is Gaussian. The prior's Laplace version needs ADH's p = 1 concentration and a Laplace small-ball comparison.
  - The likelihood is a known-variance Gaussian, analysed with KL plus χ² tests; our misspecified check loss replaces this with item 1's good-event route.

---

## Near misses (rejected)

- **Agapiou & Savva (2024), arXiv 2209.06045 (T-01 entry; scored 3–4 by S4/S5).** Its explicit Laplace-series small ball (Lemmas 3.2, D.1) and adaptive scale treatment are useful. But its series is *orthogonal with independent weighted coordinates*, whereas our walk is not: the summation operator's singular basis destroys independence (S4's point). ADH already covers the concentration side.
- **Agapiou & Wang, arXiv 2112.05679 (scored 5/5 by S5).** Already in `Papers/`. Its Theorem 2.4, Lemma 6.3 (small ball) and Lemma 6.5 (two-level concentration) are on our reading list.
- **Dolera, Favaro & Giordano, arXiv 2411.06981.** A test-free route via log-concavity and Wasserstein/Poincaré bounds (Theorem 2, Lemma 5). It is attractive for L9, but relies on a product posterior that factorizes coordinatewise under a Gaussian likelihood; ours does not.
- **Agapiou & Castillo (2024), Ann. Statist., arXiv 2308.04916.** A prior-mass-only route for non-Gaussian models (Thms 8–9), but only for tempered posteriors (ρ < 1). A fallback if a fractional Stage A were acceptable.
- **Alquier, Li & Wintenberger (2013), arXiv 1202.4294, and Mai (2024), arXiv 2409.01687.** PAC-Bayes check-loss Gibbs bounds with Lipschitz increments. They give excess risk in expectation, not contraction, with bounded or random design.
- **Alquier & Ridgway (2020).** Same family as fractional posteriors; it needs E(p_θ/p₀)^α ≤ 1, which fails under misspecification.
- **Chakraborty & Ghosal (monotone regression), Chatterjee & Bhattacharya (misspecified GP), Castillo et al. (robust GP, arXiv 2611.11582).** Fixed design or misspecification, but Gaussian-type working likelihoods and no transferable step. Each scored 2.
- **Small-ball literature (Dunker, Lifshits & Linde 1998; Lifshits 1997; Gao, Hannig & Torcaso 2003; Aurzada; Vysotsky).** These treat independent weighted series, exponential weights, or persistence rather than discrete-L² small balls. No direct result for the projected thrice-summed Laplace walk exists, so **L3's Laplace step stays open** (Gaussian half: Fill & Torcaso and Bach & Klein's spectral method).

## Implications for T-03

1. Adopt **Atchadé's good-event / peeling structure** as the explicit proof architecture for L6, L8 and L9, with Knight's identity in place of differentiability.
2. Cite **Bach & Klein** for L5 and for the Gaussian spectral half of L3.
3. Record S4's caveat in the memo's doubts: the Laplace small ball cannot be read off weighted-iid results, because the rotation destroys independence.
