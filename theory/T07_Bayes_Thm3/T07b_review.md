# T07b: independent review of T07a (Bayesian counterpart of Padilla–Chatterjee Theorem 3)

Reviewer: review sub-agent, 24 November 2026. Reviewed: `T07a_statement.tex` (statement only; no proofs and no other file under `theory/` were read). Nothing here is committed.

## Verdict table

| Question | Verdict | One-line reason |
|---|---|---|
| 1. Are the assumptions reasonable? | **Yes, with three points to fix before a referee sees it** | A, V* = O(1) and independence are Padilla's. B is new but is the standard two-sided density condition. The three points: fixed σ₀ and deterministic λ are not what the paper's sampler does; "any fixed σ₀ > 0" needs a check of Step 4 (learning-rate threshold, §1.3); "any c > 0" is still open in the statement itself. |
| 2. Do the simulation settings satisfy the assumptions? | **Data side: yes, in all 99 combinations. Procedure side: no** | A, B and V* = O(1) hold for every truth × noise × τ; the weak spots are constants only (THEORETICAL NITPICK). The theorem's fixed σ₀ and deterministic λ ≍ n^{5/2} are not the simulated procedure (λ ~ Gamma, σ ~ IG, joint sampler at extreme levels): SEVERE MISALIGNMENT for λ and for the joint sampler, a bridgeable gap for σ. |
| 3. Misspecification | **Handled correctly in principle; Remark 3 is too thin for the paper** | The posterior is a Gibbs posterior on the check loss with learning rate 1/σ₀. It targets the τ-quantile because the quantile minimizes the expected check loss for any data law. A gives separation, B gives the evidence bound. Misspecification moves the spread, not the centre, so the theorem says nothing about coverage. |

---

## 1. How reasonable are the assumptions?

### 1.1 Hypothesis by hypothesis

| Hypothesis | What it says | Status vs Padilla | How restrictive |
|---|---|---|---|
| **Assumption A** | Near each quantile θ*_i the CDF grows at least linearly: \|F_i(θ*_i+δ) − F_i(θ*_i)\| ≥ f\|δ\| for \|δ\| ≤ L, uniformly in i and n. | **Direct, verbatim** (Padilla §2.1). | Mild. No moments. It is a chord condition, weaker than a density lower bound (Padilla says so, citing He & Shi 1994 Condition 2 and Belloni & Chernozhukov 2011 D.1). It excludes discrete or rounded data, flat spots of F at the quantile, noise scale growing without bound in i, and τ = τ_n → 0 or 1. For any law f ≤ min(τ, 1−τ)/L, so the constant degrades linearly at extreme τ. |
| **Assumption B** | The same increments are at most f̄\|δ\|: no atom at the quantile, density bounded near it. | **New.** Padilla has no upper bound. | Mild and standard (precedents in §1.2). It excludes atoms at θ*_i, densities unbounded near the quantile, and noise scale shrinking to 0 in i. It needs no smoothness of the density, so it is weaker than Belloni–Chernozhukov D.1. |
| **V\* = O(1)** | n^{r−1}‖D^{(r)}θ*‖₁ stays bounded. | **Direct**, and slightly more general: Padilla's Theorem 3 needs V* = Θ(1) because his λ ∝ V*^{−(2r−1)/(2r+1)}; here λ does not involve V*. | Standard ("canonical scaling", Padilla Remark 3). θ* is a triangular array; for θ*_i = Q(i/n) it holds when Q^{(r−1)} has bounded variation. Note Q includes the noise quantile curve, not only f. |
| **r ≥ 2** | Order of differences at least 2. | **New restriction** (Padilla covers r ≥ 1). | No cost for the paper (r = 3). It is an artifact of the sup-norm localization step and excludes the fused-lasso case r = 1. |
| **Fixed σ₀** | ALD scale is a constant, not learned. | **New**: an estimator has no scale. | Restrictive relative to the method, which puts σ ~ IG(0.1, 0.1). Same device as Sriram et al. (2013), who fix σ = 1 for their Theorems 1–2 and treat a prior on σ separately (their §6). |
| **λ = c·n^{(2r−1)/2}** | Deterministic prior rate; λ_TV = c·n^{1/2}. | **New tuning.** Padilla: λ_TV ≍ n^{1/(2r+1)}(log n)^{1/(2r+1)}, V*-dependent, c > c_{1,ε}. | Restrictive relative to the method, which puts λ ~ Gamma(1, b₀) and learns it. It gives the linear-smoother rate n^{−(2r−1)/(2r)}, not Padilla's n^{−2r/(2r+1)}. For r = 3 the gap is n^{1/42}: a factor 1.16 at n = 500 and 1.39 at n = 10⁶. |
| **Independence** | y_i independent, not identically distributed. | **Direct.** | Standard. Excludes serially dependent noise, which is common in trend-filtering applications. |

### 1.2 Precedents for the new items

**Assumption B (two-sided density condition).**
- Koenker (2005), *Quantile Regression*, Cambridge University Press, §4.2, Condition A1 of Theorem 4.1: densities f_i "uniformly bounded away from 0 and ∞" at the conditional quantiles. This is exactly A + B at the quantile. *Quoted from memory; my web check found the chapter but not the wording. Confirm against the book before citing.*
- Belloni & Chernozhukov (2011), *Ann. Statist.* 39(1), 82–130, Condition D.1: conditional density and its derivative bounded above, density at the quantile bounded away from zero. Stronger than A + B. Checked against the arXiv text (0904.2931).
- Atchadé (2017), *Ann. Statist.* 45(5), 2248–2273, events (2.5) and (2.6): a lower curvature bound through a rate function, and an upper bound L_{n,θ} ≥ −(L̄/2)‖θ − θ⋆‖² needed, in his words, "in order to control the normalizing constant of the quasi-posterior distribution". (2.5) is the analogue of A, (2.6) of B. Read in the local PDF.
- Ghosal & van der Vaart (2007), *Ann. Statist.* 35(1), 192–223, Theorem 1: prior mass of the Kullback–Leibler neighbourhoods B_n(θ₀, ε; k). B is what turns those neighbourhoods into ℓ₂ balls here.
- Syring & Martin (2023), *Bernoulli* 29(2), 1080–1108, prior condition (12): mass of {m(θ, θ⋆) ∨ v(θ, θ⋆) ≤ ε^r}. Their quantile assumptions (Assumption 1.2 and 8.3 in the arXiv v6 copy we hold) ask for a *continuous* density bounded away from zero near the quantile; continuity supplies the local upper bound.

**Why B is not in Sriram et al. (2013).** Their model is finite-dimensional. A Lipschitz bound |M̂_i| ≤ |δ_i| then suffices, because shrinking the prior neighbourhood costs only a polynomial factor. In an n-dimensional problem the Lipschitz bound alone would force a sup-norm ball of radius ε_n² in place of an ℓ₂ ball of radius √n·ε_n, and that changes the rate. So B is the natural price of the nonparametric setting.

**Fixed σ₀.** Sriram, Ramamoorthi & Ghosh (2013), *Bayesian Analysis* 8(2), 479–504: σ = 1 fixed in Theorems 1–2; with a prior on σ (§6) the posterior of σ is consistent at C* = lim n⁻¹ Σ E ρ_τ(y_i − θ*_i). This is the σ̄_n of T07a Remark 2, so Remark 2 has a published parametric precedent. Syring & Martin (2023), Theorem 3.5, cover a random learning rate bracketed by a deterministic one, the template for a learned-σ version.

**Deterministic λ at a non-adaptive rate.** Castillo, Schmidt-Hieber & van der Vaart (2015), *Ann. Statist.* 43(5), 1986–2018, Theorem 7 (Bayesian LASSO). The statement cites it already.

**r ≥ 2.** No precedent; it is a proof artifact and the statement says so.

### 1.3 What a referee would object to

1. **The theorem is not about the paper's sampler.** σ and λ are learned in the method and fixed in the theorem. Remark 2 bridges σ credibly. Nothing bridges λ: no result places the Gamma-prior posterior of λ in the window λ ≍ n^{5/2}.
2. **"Any fixed σ₀ > 0" needs checking against Step 4 of the roadmap.** For a fixed θ near θ*, a direct expansion gives
   E exp{−M̂_i(δ)/σ₀} = 1 − (δ²/2σ₀)·(f_i − τ(1−τ)/σ₀) + o(δ²),
   so the expected exponentiated excess loss is below 1 only if **σ₀ > τ(1−τ)/f_i**. I confirmed this numerically (N(0,1) errors, τ = 0.5, threshold 1/σ₀ = 1.596: the expectation is 0.9992 at 1/σ₀ = 1 and 1.0009 at 1/σ₀ = 2, δ = 0.1). At σ₀ = 1 the condition holds in every simulation setting. At the sampler-relevant σ₀ = σ̄_n of Remark 2 it fails almost everywhere: the ratio σ̄_n f_i/(τ(1−τ)) is 0.43–0.85 (Gaussian, τ = 0.5), 0.15–0.30 (Gaussian, τ = 0.05), 0.05–0.10 (Gaussian, τ = 0.99), 0.63–0.65 (mixed normal, τ = 0.5); only some Beta design points at τ ≤ 0.5 exceed 1. So a shell bound obtained by taking the expectation inside the prior integral (the Syring–Martin route, which is why their results need a "sufficiently small" learning rate) cannot give Remark 2. A uniform high-probability bound on M̂ − M over each shell, or the fractional-power device of Sriram et al. (their Lemma 4, 0 < d < 1), has no such threshold. **Action: confirm which route project Lemmas C2 and F take; if it is the first, replace "any σ₀ > 0" by a threshold and rewrite Remark 2.** I could not check this without the proofs.
3. **"Any c > 0" is unsettled** (the statement's own list). If the proofs need a₁ ≤ cV* ≤ a₂, the tuning depends on the unknown V*, as Padilla's does, and the theorem must say so.
4. **The rate is the linear-smoother rate.** A referee will read Theorem 1 with Remark 4 as "the posterior is rate-suboptimal over bounded-variation classes". That is the honest reading. Two things should be stated plainly: the result is an upper bound at one λ, and the claim that no deterministic λ does better is proved only for r = 3 and λ ≲ n^{5/2}.
5. **Loss versus what the paper reports.** Δ_n² ≤ MSE and Δ_n² ≤ MAD, so contraction in Δ_n² is the weaker statement, and Δ_n² is not convex, so a bound for the posterior mean (the paper's point estimate) does not follow by Jensen. A posterior-mean corollary needs the localization step plus control of the posterior second moment.
6. **V\*-dependence of M is hidden.** For the VS signal V* ≈ 7300 (§2.2). A referee may ask for the explicit dependence; Remark 4 suggests V*^{1/r}.
7. **Corollary 1.** It inherits Padilla's Θ(1) and c > c_{1,ε}. "Every mode" is slightly more than Padilla states (he writes θ̂ = arg min); check that his proof uses only optimality.
8. **Independence** for a trend-filtering method. Standard, but expect the question.

---

## 2. Do the simulation settings satisfy the assumptions?

Settings: truths VS, S, PC; noises Gaussian (s(u) = (1+u²)/4), Beta(1, 11−10u), mixed normal (component variance 0.5); τ ∈ {0.05, 0.25, 0.50, 0.75, 0.95} and {0.90, 0.93, 0.96, 0.97, 0.98, 0.99}; r = 3; u_i = i/n. That is 3 × 3 × 11 = 99 combinations. A and B depend on noise × τ only; V* depends on all three.

### 2.1 Assumptions A and B: hold in all 33 noise × τ cells

Density at the τ-quantile, range over u ∈ (0, 1], and chord constants inf/sup of |F(q+δ) − F(q)|/|δ| over 0 < |δ| ≤ L with L = 0.1 (grid of 2000 design points):

| τ | Gaussian: density | Gaussian: chords | Beta: density | Beta: chords | Mixed: density | Mixed: chords |
|---|---|---|---|---|---|---|
| 0.05 | 0.206–0.413 | 0.175 / 0.566 | 1.000–10.49 | 0.500 / 10.74 | 0.140–0.146 | 0.125 / 0.164 |
| 0.25 | 0.636–1.271 | 0.591 / 1.419 | 1.000–8.46 | 1.000 / 9.68 | 0.432–0.449 | 0.411 / 0.470 |
| 0.50 | 0.798–1.596 | 0.793 / 1.596 | 1.000–5.86 | 1.000 / 8.18 | 0.542–0.564 | 0.540 / 0.564 |
| 0.75 | 0.636–1.271 | 0.591 / 1.419 | 0.942–3.12 | 0.881 / 5.65 | 0.432–0.449 | 0.411 / 0.470 |
| 0.95 | 0.206–0.413 | 0.175 / 0.566 | 0.407–1.000 | 0.305 / 1.44 | 0.140–0.146 | 0.125 / 0.164 |
| 0.90 | 0.351–0.702 | 0.308 / 0.890 | 0.626–1.356 | 0.514 / 2.59 | 0.239–0.248 | 0.218 / 0.271 |
| 0.93 | 0.269–0.537 | 0.231 / 0.710 | 0.506–1.000 | 0.396 / 1.92 | 0.183–0.190 | 0.165 / 0.210 |
| 0.96 | 0.172–0.345 | 0.145 / 0.484 | 0.350–1.000 | 0.254 / 1.19 | 0.117–0.122 | 0.104 / 0.138 |
| 0.97 | 0.136–0.272 | 0.113 / 0.393 | 0.286–1.000 | 0.200 / 1.00 | 0.093–0.096 | 0.081 / 0.110 |
| 0.98 | 0.097–0.194 | 0.079 / 0.291 | 0.213–1.000 | 0.141 / 1.00 | 0.066–0.069 | 0.057 / 0.079 |
| 0.99 | 0.053–0.107 | 0.042 / 0.170 | 0.125–1.000 | 0.076 / 1.00 | 0.036–0.038 | 0.031 / 0.044 |

- **A holds** in every cell with L = 0.1 and f equal to the first chord number. The worst cell is mixed normal at τ = 0.99, f = 0.031.
- **B holds** in every cell with f̄ the global density bound: 1.596 (Gaussian), 11 (Beta), 0.564 (mixed normal).
- The conditions are uniform in n because u ranges over the compact (0, 1] and all quantities are continuous in u.

**Beta noise, the three places to look.**
1. *Lower endpoint.* The density jumps from 0 to b = 11 − 10u at x = 0, and at low τ the quantile sits next to the jump: the smallest distance to 0 is 0.0047 (τ = 0.05), 0.026 (τ = 0.25), 0.061 (τ = 0.50), all at u → 0. A still holds because it is a chord condition: once θ*_i + δ leaves the support the chord equals τ/|δ| ≥ τ/L. This is why f = 0.500 at τ = 0.05, L = 0.1, against a density of 10.5 at the quantile. A density-form assumption (He–Shi) would hold only with L < 0.0047. At n = 500 the estimation error (RMSE ≈ 0.02 in the paper's Beta, τ = 0.05 cells) is larger than 0.0047, so downward errors meet a linear, not quadratic, expected loss. The constant is poor; the assumption holds.
2. *Upper endpoint as u → 1.* For b > 1 the density b(1−x)^{b−1} vanishes at x = 1; at u = 1 it is Uniform(0, 1) with density 1 up to the endpoint. The convergence is not uniform at x = 1, but this does not matter: the upper quantile stays at distance (1−τ)^{1/b} ≥ 1−τ from the endpoint, and the density at the 0.99-quantile is at least 0.125 (attained at u = 0.64). Because b ≥ 1 on the whole design the density never blows up at x = 1, so B is safe. It would fail for a design reaching b < 1.
3. *The quantile curve.* q_τ(u) = 1 − (1−τ)^{1/(11−10u)} is smooth on [0, 1] but steep near u = 1: sup|q_τ'''| is 273 (τ = 0.05), 928 (0.25), 799 (0.50), 142 (0.75), 448 (0.95), 130 (0.99), all attained at u ≥ 0.95. This feeds V* (§2.2).

**Classification.** A and B: satisfied everywhere. Poor constants at τ ≥ 0.96 (f from 0.03 to 0.25) and at Beta, τ = 0.05: **THEORETICAL NITPICK**. Reason: the degradation is the generic factor min(τ, 1−τ) that Padilla's Remark 2 already announces, and the paper's own MSE tables move as the constants predict. The ratio of τ(1−τ)/f² between τ = 0.99 and τ = 0.50 is 8.8 for Gaussian and 8.9 for mixed normal; the Bayesian-PMALA MSE ratios on VS are 0.0502/0.0068 = 7.4 and 0.2458/0.0269 = 9.1. This is a consistency check at one n, not a test of the rate.

### 2.2 V* = O(1): holds in all 99 combinations

TV^{(3)}(θ*) = n²‖D^{(3)}θ*‖₁ with θ*_i = f(u_i) + q_τ(u_i), range over the 11 levels:

| Truth | Noise | n = 500 | n = 2000 | n = 16000 | Comment |
|---|---|---|---|---|---|
| VS | Gaussian | 7275.6 | 7282.2 | 7282.8 | same at every τ |
| VS | Beta | 7282.9–7310.8 | 7290.0–7318.7 | 7290.6–7319.5 | |
| VS | Mixed | 7275.5–7275.9 | 7282.2–7282.6 | 7282.7–7283.1 | |
| S | Gaussian | 156.4 | 157.5 | 157.9 | limit 16π² = 157.9 |
| S | Beta | 141.8–177.1 | 143.1–178.7 | 143.5–179.2 | below 157.9 at τ ≤ 0.75, above at τ ≥ 0.90 |
| S | Mixed | 156.3–156.6 | 157.4–157.7 | 157.8–158.1 | |
| PC | Gaussian | 36.0 | 36.0 | 36.0 | exact: jumps of f″ are 12 + 12 + 12 |
| PC | Beta | 44.9–79.4 | 45.3–80.7 | 45.5–81.1 | largest at τ = 0.50 |
| PC | Mixed | 36.2–37.2 | 36.2–37.2 | 36.2–37.2 | |

Every row converges, so V* = O(1) (indeed Θ(1)) holds in every combination.

Contribution of the noise quantile curve alone, TV^{(3)}(q_τ):
- Gaussian: exactly 0. s(u)·z_τ is quadratic in u and D^{(3)} annihilates it.
- Mixed normal: 0.17 to 1.22.
- Beta: 9.5 (τ = 0.05), 36.8 (0.25), 45.1 (0.50), 22.2 (0.75), 23.9 (0.95), 22.5 (0.90), 23.8 (0.93), 23.4 (0.96), 22.3 (0.97), 20.1 (0.98), 15.6 (0.99).

So the reminder in the brief has weight in one place only: under Beta noise the quantile curve more than doubles V* for PC (36 → 81 at τ = 0.5) and shifts it by −9% to +13% for S. For VS it is invisible.

**Classification.**
- V* = O(1): satisfied. **THEORETICAL NITPICK** on constants.
- The constant worth knowing: V*(VS) ≈ 7280, which is 46 times V*(S) and 200 times V*(PC). At n = 500 the bump is resolved (TV at n = 250 is already 7255). M depends on the bound on V*; with the heuristic V*^{1/3} the VS constant is 3.6 times the S constant. No practical weight for the truth of the theorem, but a referee may ask for the dependence.

### 2.3 The remaining hypotheses

| Hypothesis | In the simulations | Classification |
|---|---|---|
| r ≥ 2 | r = 3 | satisfied |
| Independence | independent draws | satisfied |
| Fixed σ₀ | σ ~ IG(0.1, 0.1), learned | **Fails as stated; bridgeable.** σ concentrates at σ̄_n (Remark 2; Sriram §6). I computed σ̄_n at τ = 0.05/0.25/0.50/0.75/0.95: Gaussian 0.034/0.106/0.133/0.106/0.034; Beta 0.009/0.037/0.056/0.050/0.018; mixed 0.075/0.231/0.290/0.231/0.075; at τ = 0.99: 0.0089/0.0046/0.0193. The Gaussian 0.133 and 0.034 match the E-08 values quoted in Remark 2. I rate it between the two classes: not a nitpick, because the learned-σ theorem is not proved and §1.3 item 2 bears on exactly σ₀ = σ̄_n; not severe, because the route is known. |
| λ = c·n^{5/2} deterministic | λ ~ Gamma(1, 10⁻³) (VS) or Gamma(1, 5×10⁻⁴) (S), learned | **SEVERE MISALIGNMENT.** The theorem does not describe the simulated procedure: the posterior is a mixture over λ and nothing proved places λ near c·n^{5/2}. The only data I found: E-08 (VS, Gaussian, n = 500, one seed) has median λ between 1.7×10³ and 2.5×10³, that is λV*/n^{5/2} between 2.2 and 3.3. One n cannot confirm or refute the exponent. |
| Single posterior at one τ | extreme levels are also fitted by the joint non-crossing sampler | **SEVERE MISALIGNMENT** for the joint-sampler rows: the theorem has no ordering constraint. The individual Bayesian-PMALA rows at extreme τ are covered in the same sense as the interior ones. |
| n → ∞ | n = 500 only; MSE and MAD of the posterior mean | Not an assumption. The simulations do not test the rate, and the theorem does not bound the posterior mean (§1.3 item 5). At τ = 0.99 there are n(1−τ) = 5 expected observations above the quantile. |

**Summary for Question 2.** Nothing on the data-generating side is misaligned: all 99 combinations satisfy A, B and V* = O(1), with weak constants at extreme τ, at Beta τ = 0.05 and for VS. The misalignment is on the procedure side, and it is the same for every combination: learned λ (severe), the joint sampler (severe), learned σ (bridgeable). The paper should present the theorem as a result about the fixed-(σ, λ) posterior that sits inside the sampler, not as a guarantee for the reported simulations.

---

## 3. Misspecification

### 3.1 How a proof handles it

The proof never uses that the data are ALD. Dividing numerator and denominator of the posterior by exp{−Σρ_τ(y_i − θ*_i)/σ₀} gives

Π_λ(B | y) = ∫_B exp{−M̂(θ)/σ₀} dΠ(θ) / ∫ exp{−M̂(θ)/σ₀} dΠ(θ),  M̂(θ) = Σ_i [ρ_τ(y_i − θ_i) − ρ_τ(y_i − θ*_i)].

This is a Gibbs posterior: prior × exp(−ω × empirical risk), with the check loss as loss and ω = 1/σ₀. Every expectation and probability is under the true law of y. Three objects carry the proof.
- The **expected excess loss** M(θ) = E M̂(θ) = Σ_i ∫₀^{δ_i} [F_i(θ*_i + z) − F_i(θ*_i)] dz (Padilla eq. (19); Belloni–Chernozhukov eq. B.3). It replaces the Kullback–Leibler divergence of a well-specified proof.
- The **fluctuation** M̂ − M. Because |M̂_i| ≤ |δ_i| (Padilla Remark 11) it is a sum of bounded terms: no moments of y are needed, and Var M̂ ≤ ‖δ‖² with no assumption at all.
- The **prior mass** near θ* (here near a smoothed truth), as in any contraction proof.

Compared with Ghosal & van der Vaart (2007), Theorem 1: their Kullback–Leibler neighbourhoods B_n(θ₀, ε; k) become excess-risk neighbourhoods {M ≤ nε², Var M̂ ≤ nε²} (Syring & Martin's condition (12)), and their tests become exponential bounds on M̂ over shells (Syring & Martin's Condition 1 and 2).

### 3.2 Why the τ-quantile and not something else

The integrand of M_i has the sign of z, so M_i(θ_i) ≥ 0 with equality only at θ_i = θ*_i when F_i is strictly increasing there. Equivalently, the first-order condition of E ρ_τ(y_i − θ) is F_i(θ) = τ. This is a property of the check loss and holds for every data law.

In likelihood language: KL(p_{0i} ‖ ALD(θ_i, σ₀, τ)) = constant + M_i(θ_i)/σ₀, so the Kullback–Leibler projection of the truth onto the ALD location family is the true τ-quantile, for every σ₀ (Sriram et al. 2013, Lemma 2 and Proposition 1). A misspecified posterior concentrates at the Kullback–Leibler minimizer (Kleijn & van der Vaart 2006, *Ann. Statist.* 34(2), 837–877). In general that point differs from the feature of interest. For the ALD it is the feature of interest. Everything else about the ALD (its shape, its other quantiles, its scale) is wrong, and that shows up in the spread (§3.5).

### 3.3 The roles of the expected check loss, A and B

- **Expected check loss M**: the population criterion. It fixes the target (§3.2) and is the yardstick in both halves of the ratio.
- **Assumption A, curvature from below**: M(θ* + δ) ≥ c₀ Σ_i min{|δ_i|, δ_i²} = c₀ n Δ_n²(δ) (Padilla Lemma 13). This is separation: far from θ* in the Δ loss means a large expected loss, hence a small numerator. It also explains the loss. CDF increments are at most 1, so M_i can grow only linearly far out; the curvature is quadratic near and linear far, which is the shape of Δ². Atchadé's rate function r(x) = τx²/(1 + bx) and Syring & Martin's "locally sub-exponential" case (their §4.1, with the Bernstein condition holding near θ⋆ only) describe the same shape. Their remedy is a sup-norm sieve imposed through the prior (their Assumption 8.4). T07a proves the sup-norm localization instead (Step 3), and that is where r ≥ 2 enters.
- **Assumption B, growth from above**: M(θ* + δ) ≤ (f̄/2)‖δ‖² for ‖δ‖_∞ ≤ L. It makes excess-risk neighbourhoods contain ℓ₂ balls, so the denominator is at least exp(−C n ε_n²) times a prior small-ball mass. An estimator has no denominator, so Padilla does not need B. Atchadé's event (2.6) plays the same role.
- A + B together say the expected loss is equivalent to a quadratic near θ* with condition number f̄/f. In the simulations f̄/f at L = 0.1 runs from 1.0 (mixed normal, τ = 0.5) to 21 (Beta, τ = 0.05).

### 3.4 Relation to the Gibbs and quasi-posterior literature

- **Syring & Martin (2023).** The T07a posterior is their Gibbs posterior (5) with ω = 1/σ₀. They say of Sriram et al. that "their posterior is effectively a Gibbs posterior" (supplement, quantile regression section, in the arXiv v6 copy). Their Proposition 8 gives a nonparametric quantile-curve rate with a sieve prior and a small learning rate. T07a differs in the prior (Laplace on r-th differences, improper, with n parameters), in the loss class (bounded variation, not Hölder) and in claiming every fixed σ₀ rather than a small learning rate; see §1.3 item 2.
- **Atchadé (2017).** Same architecture: a good event on which the quasi-log-likelihood has curvature bounded below (2.5) and above (2.6), plus a small score (2.7). His theorem does not apply as it stands: H2 requires a differentiable log quasi-likelihood, and the check loss has no sample curvature at all. Its curvature exists only in expectation, so the argument has to go through M = E M̂ and an empirical-process bound, which is what the roadmap does. Cite him for the framework, not for the result.
- **Sriram, Ramamoorthi & Ghosh (2013).** The parametric ancestor: linear quantile regression, fixed design, independent non-identical responses, σ = 1, proper or improper prior; consistency (Theorem 1) and rates n^{−δ} with δ < 1/2 almost surely, and M_n/√n in probability (Theorem 2). Their Assumption 3(ii) is Assumption A. Their Assumption 4 asks for two moments, which T07a does not need. They have no Assumption B (reason in §1.2). T07a is the nonparametric rate analogue.
- **Ghosal & van der Vaart (2007).** The template: prior mass, complexity, tests. T07a keeps the template and replaces the Kullback–Leibler objects by excess-risk objects.

### 3.5 Does the fixed σ₀ play the role of a learning rate?

Yes, exactly: ω = 1/σ₀ in Syring & Martin's definition. The consequences are these.
1. **Centre: unaffected.** The Kullback–Leibler minimizer in θ is θ* for every σ₀.
2. **Mode.** It is PQTF with penalty σ₀λ, so (σ₀, λ) → (aσ₀, λ/a) keeps the mode and changes the spread. An estimator sees only the product σ₀λ; the posterior sees both.
3. **Rate.** σ₀ enters the constant M, not the exponent, as the theorem states. This is the generic Gibbs result for a constant learning rate, subject to the check in §1.3 item 2.
4. **Spread and coverage: affected, and not calibrated by any default.** In the parametric case the ALD posterior variance is proportional to σ₀/f while the sampling variance of its centre is proportional to τ(1−τ)/f² (Chernozhukov & Hong 2003, *J. Econometrics* 115(2), 293–346; Yang, Wang & He 2016, *Int. Statist. Rev.* 84(3), 327–344). Their ratio is τ(1−τ)/(σ₀ f). At σ₀ = σ̄_n and Gaussian noise it equals τ(1−τ)/φ(z_τ)²: 1.57 at τ = 0.5, 4.5 at τ = 0.05 and 0.95, 13.9 at τ = 0.99. So at the scale where the sampler's σ sits the posterior is narrower than the sampling variability of its centre, more so at extreme levels. This is a parametric calculation and I did not check coverage in the trend-filtering setting, but it is the reason the paper must not read the theorem as a coverage statement. Calibrating a learning rate is a separate problem (Syring & Martin 2019, *Biometrika* 106(2), 479–486).
5. **A learning rate that is learned.** A generic Gibbs posterior cannot learn ω from the data. The ALD can, because its normalizing constant τ(1−τ)/σ penalizes small σ; the result is σ → σ̄_n, the Kullback–Leibler-optimal scale (Sriram et al., eq. (5)–(6)). It is a principled default. It is not the calibrated value, and by item 4 it is on the narrow side.

### 3.6 Proposed paragraph for the paper

> The asymmetric Laplace density is a working likelihood: we do not assume that the data follow it, and every probability statement in Theorem X is under the true distribution of the data. The posterior is therefore a Gibbs, or quasi-, posterior built on the check loss, in which 1/σ acts as a learning rate (Syring and Martin, 2023; Atchadé, 2017). It concentrates on the true τ-quantile because, whatever the distribution of y_i, the τ-quantile minimizes the expected check loss and hence the Kullback–Leibler divergence from the truth to the asymmetric Laplace family (Sriram, Ramamoorthi and Ghosh, 2013); the only conditions on the data are that their densities are bounded away from zero and from infinity near the quantile, with no moment condition. Misspecification changes the spread of the posterior and not its centre, so the theorem describes where the posterior concentrates and how fast, not the frequentist coverage of its credible intervals (Yang, Wang and He, 2016).

Shorter alternative for a remark, two sentences: the first and third sentences above.

---

## 4. How the numbers were obtained, and what was not checked

- Scripts and outputs are in the session scratch space, not the repo: `/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/57888c30-7fd5-455f-ac75-2d1ae51794fa/scratchpad/code/` (`check2.py`, `check2.out`, `check3.py`, `check3.out`). The scratch space is not durable; ask if they should be kept.
- V*: third differences of f(u_i) + q_τ(u_i) for n from 250 to 16000. Closed-form quantiles for Gaussian and Beta, Newton iteration for the mixed normal.
- Chord constants: 2000 design points × 600 values of δ, log-spaced in (10⁻⁵, L].
- σ̄_n: closed forms (Gaussian, Beta, normal mixture), n = 500 design.
- Compute note: the first two runs were started as bare `python3` before I had read the Owls policy; the second ran about 10 minutes on roughly one core with a large memory footprint and I stopped it. The last run went through `owls_run -j 1`.
- Not checked: any proof; the audited project lemmas the roadmap cites; coverage in the trend-filtering setting; the behaviour of the learned λ beyond the single E-08 table.
- References not opened as PDFs (cited from memory or from the web search): Koenker (2005), Belloni & Chernozhukov (2011), Kleijn & van der Vaart (2006), Chernozhukov & Hong (2003), Yang, Wang & He (2016), Syring & Martin (2019), He & Shi (1994). Volume and page numbers for Syring & Martin (2023) and Atchadé (2017) are the published ones; section and equation numbers are from the arXiv copies in `literature/`.
