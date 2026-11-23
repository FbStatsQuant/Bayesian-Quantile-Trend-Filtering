# Stage-A theorem: statement v3.1 (after the final reviews)

*BQTF Theory Department. v3.1, 2026-11-22; supersedes v3.*
- *Inputs:* the final reviews of v3 (Astra: NOT READY; Fable/VP: READY WITH CHANGES; both in `reviews/`), and Astra's advisor checks of L2, L4, L5 and L4q (`../T05_Proofs/reviews/`).
- *Scope:* statement and lemma statements only. Proofs are in `../T05_Proofs/`. Evidence is in `MEMO.md` §8.
- *Changes:* the changes from v3 are listed in "Response to the final reviews" at the end.

## Setting and normalization

- **Data.** Observations y₁, …, yₙ are independent on the grid xᵢ = i/n. Fix τ ∈ (0, 1). The target θ\* = (Fᵢ⁻¹(τ))ᵢ is the vector of true τ-quantiles (generalized inverse). All probability is under the true law P₀; the asymmetric Laplace distribution (ALD) is a working likelihood only.
- **Coordinates.** D = D⁽³⁾ ∈ ℝ^{(n−3)×n}, with m = n − 3. Write θ = Nc + Su, where:
  - c ∈ ℝ³ is the quadratic part, with N an orthonormal basis of the quadratics;
  - u = Dθ ∈ ℝᵐ;
  - S = C³[:, 4:n] is a right-inverse of D;
  - u\* = Dθ\*.
- **Prior.** The prior is dc ⊗ Π_λ(du). Here Π_λ := Laplace(λ)^{⊗m} is a **probability** measure; the Lebesgue part on c is the only improper factor.
- **Stage-A posterior.** σ > 0 and λ are fixed, and ω := 1/σ. For B ⊂ ℝⁿ,

  Πₙ,λ(B | y) = N(B)/N(ℝⁿ), where N(B) = ∫∫_{Nc+Su ∈ B} exp{ −ω Σᵢ [ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ)] } dc Π_λ(du).

  This is the paper's posterior with σ and λ frozen. N(ℝⁿ) ∈ (0, ∞) for every finite data vector, for n ≥ 4 (L5, advisor-checked).
- **Losses.** Δ²ₙ(v) = n⁻¹ Σᵢ min{|vᵢ|, vᵢ²}, and ‖v‖²ₙ = n⁻¹ Σᵢ vᵢ².
- **Other notation.**
  - TV⁽³⁾(θ) := n²‖Dθ‖₁.
  - κ := f/σ is the effective curvature, with f the lower margin constant in (A2).
  - A := n^{−1/2}P⊥S, B_ε := {u : ‖Au‖₂ ≤ ε}, and φ(ε) := −log Π_λ(B_ε).

## Assumptions

| Label | Assumption | Why reasonable / checkable |
|---|---|---|
| **(A1)** | y₁, …, yₙ are independent (not necessarily identically distributed) on the equispaced grid. | This is the paper's setting; Padilla & Chatterjee use the same. |
| **(A2)** | **Two-sided margin, uniform in i and n.** For all \|δ\| ≤ L: f\|δ\| ≤ \|Fᵢ(θ\*ᵢ + δ) − Fᵢ(θ\*ᵢ)\| ≤ f̄\|δ\|. | The lower half is Padilla's Assumption A. The upper half forces continuity of Fᵢ at the quantile, hence Fᵢ(θ\*ᵢ) = τ, which the margin needs (L2, advisor-checked). It also gives mᵢ(δ) ≤ min{\|δ\|, C₁δ²}. **No moment conditions.** Note that f is a **secant** bound on an interval, not the point density. |
| **(A3)** | TV⁽³⁾(θ\*) ≤ V, i.e. ‖u\*‖₁ ≤ V n^{−2}, with V fixed. **No sup-norm bound**: the posterior law of θ − θ\* is exactly invariant to adding a quadratic to θ\*. | The bounded-variation class of Padilla's slow rate (r = 3), equivalently Tibshirani's F₂(C). |
| **(A4)** | **Theorem A: strict slack.** ω ≤ (1−η)ω̄ for a fixed η ∈ (0, 1), with ω̄ := f/(τ(1−τ)); equivalently σ ≥ σ̄/(1−η), with σ̄ := τ(1−τ)/f. **Theorem A⁺ (target):** any fixed σ > 0. In both, λ is **deterministic**, in the window **n² ≤ λ ≤ n³/(V^{3/2}(log n)^{C₀})** with C₀ > 3c/5 (a₀ = 2; HQ decision). | Equivalently σ ≥ (1+η)σ̄ up to relabelling η. **The equality case ω = ω̄ is false:** Astra's counterexample uses uniform errors, τ = ½, ω = 2, where the MGF gain is cubic, not quadratic. With strict slack, L8′ gives a quadratic gain on \|δ\| ≤ Δ₀(η). The upper end of the window keeps the bias term below the spread. a₀ = 2 sits just above the non-circular threshold 21/11 of the two-stage L10 route (VP); nothing of interest lies below 2. The v3 values 3/2 and 9/5 are withdrawn, because they assumed ‖δ‖ₙ ≈ ε, which is the conclusion. C₀ > 3c/5 (equivalently 5C₀/3 > c, Astra) keeps the bias term below the spread at the upper end. |

The law class 𝒫ₙ = 𝒫ₙ(τ, L, f, f̄, V) is the set of all independent laws on the grid satisfying (A2) and (A3).

## σ̄ and κ (explicit)

**Exact increment law.** For a displacement δ > 0 at a coordinate with Z = y − θ\*, the check-loss increment is X = (1−τ)δ − clip(Z, 0, δ). It is bounded and needs no moments. Its MGF is exact (L8′(a)):

  E e^{−ωX} = h_τ(ωδ) − ω e^{−ω(1−τ)δ} ∫₀^δ e^{ωs}(F(s) − τ) ds,  h_τ(t) = τe^{−(1−τ)t} + (1−τ)e^{τt}.

If F has density f(q) at the quantile, expanding at δ = 0 gives

  log E e^{−ωX} = ½(ω²τ(1−τ) − ωf(q))δ² + o(δ²).

So the per-coordinate MGF is below 1 near 0 **iff ω < f(q)/(τ(1−τ))**.

**What this means for the Fubini route.**
- *Sharpness.* The local threshold is exact, not a Bernstein artefact (L8′(c)).
- *Sufficiency.* L8′(b) proves log E e^{−ωX} ≤ −(η/2)·ω·m(δ) on |δ| ≤ Δ₀(η, ω̄, τ), using only the secant constant f of (A2).
- *The bound is local only.* At a fixed ω < ω̄ the MGF exceeds 1 for large displacements under heavy tails. The VP's check at 0.9ω̄ gives E e^{−ωX} = 1.06 at δ = 10 for t₃, and 1.46 at δ = 5 for Cauchy. For the mixture row below, the exact threshold ω̄(Δ) falls from 14.4 to 6.7 to 2.3 as Δ grows. **So the Fubini route needs Δ ≲ c/ω, and depends entirely on sup-norm localization (L10).** It gives no global expected-numerator bound: for Cauchy errors the expected remote ratio grows like e^{ωnt/2}P(Y > t)ⁿ (Astra).

**Comparison with the paper's regime, σ₀ = E ρ_τ(ε − q_τ).** The gap ratio R := σ̄/σ₀ = τ(1−τ)/(f(q)σ₀) uses the **point density** f(q). Theorem A's condition uses the secant constant f ≤ f(q) of (A2) and strict slack η. So the table is the best case for Theorem A, not a guarantee.

| Noise | τ | R |
|---|---|---|
| Gaussian | 0.50 | **1.571 (π/2)** |
| Gaussian | 0.75 | 1.857 |
| Gaussian | 0.90 | 2.922 |
| Gaussian | 0.95 | 4.466 |
| Laplace (correctly specified ALD) | 0.50 | 1.000 (**not covered**: strict slack) |
| t₃ | 0.50 | 1.234 |
| t₂ | 0.50 | 1.000 (**not covered**: strict slack) |
| Uniform | 0.50 | 2.000 |
| 0.9 N(0, 0.1²) + 0.1 N(0, 3²) | 0.50 | 0.446 locally, **but not covered**. ω̄(Δ) falls 14.4 → 6.7 → 2.3 as Δ grows, and the numerically estimated critical scale for (EM) is σ_crit = 3.58σ₀ (6.22 at τ = ¾, 10.44 at τ = 0.9). These are the VP's figures, re-verified independently: `../T05_Proofs/checks/global_threshold.py`, NOTS job 2858270. |

Theorem A covers the paper's σ₀ only when R < 1 with room for the slack and the secant. For the light-tailed laws checked (Gaussian, Laplace, logistic, uniform; τ ∈ {½, ¾, 0.9}), the global threshold equals the local one within grid error, ratio 0.994–0.999 (VP; re-verified, NOTS job 2858270). For Gaussian noise it misses σ₀ by a factor of π/2 at the median, and the factor grows toward the tails. Source: `scratch/omega_bar_exact.out`.

**Dependence on κ = f/σ.**
- *Theorem A.* The rate carries κ^{−5/6}: ε² ∝ κ^{−5/6}[λ^{−1/3} + V²λ^{5/3}n^{−5}]. **M can be taken free of σ**, because both the evidence budget and the Chebyshev term in L6 scale with κnε².
- *Theorem A⁺.* The spread term carries an extra factor (1 ∨ σ̄/σ). σ̄ is exactly where the posterior spread (σ/f) equals the sandwich variance of the centre (τ(1−τ)/f²). Below σ̄, the rate is the centre's sampling error, τ(1−τ)f^{−2}κ^{1/6}λ^{−1/3}, which increases in κ (VP).
  - *Numerical check (Engineering, the VP's sandwich test).* Gaussian noise, τ = ½, σ = σ₀; 144 E-02 cells.
    - The across-replicate variance of the posterior mean, divided by the posterior spread, is **1.49 in the null-space (quadratic) directions** (IQR 1.30–1.63; π/2 = 1.571 predicted). It is **1.08 in the rough part** (IQR 1.00–1.17).
    - Reading: the full sandwich gap appears only where there is no penalty. In penalised directions it shrinks toward 1 by the ridge factor.
    - The null space has dimension 3 and contributes O(1/n) to ‖δ‖²ₙ. So below σ̄ the extra factor (1 ∨ σ̄/σ) is a **conservative upper bound**: empirically the rate is not inflated, and the σ̄ restriction is a proof-route limitation rather than a rate change. Source: Engineering, `analysis/sandwich_ratio.csv`.

**Plan for Theorem A⁺ (every fixed σ).** The Fubini route fails above ω̄ because it bounds the *expected* numerator. Two plans analyse the *realized* numerator on the sup-norm-localized set from L10.
- **(i) VP's Hölder–Knight route (preferred; checked at the level of exponents only).**
  - Knight: ℛ = −u′δ + Rₙ(δ), with Rᵢ = (δᵢ − Zᵢ)·1{0 < Zᵢ < δᵢ} ≥ 0.
  - Cauchy–Schwarz in ν splits N(E) into a score factor and a remainder factor.
  - The remainder factor is handled by Fubini for **any** ω on |δᵢ| ≤ 3f/(4ωf̄), since E Rᵢ² ≤ f̄|δᵢ|³/3.
  - The score factor: a coarse spline projection (J ≍ Mnε² knots, no net), plus the exact Laplace MGF in the fine directions.
  - No chaining is needed. Balancing gives the sandwich term above.
- **(ii) The v3 plan.** Knight decomposition; a coarse net on a structured sieve; fine-part integration against the prior; chaining of Rₙ across the scales below ε.

In both plans the far region is handled by **in-probability** arguments, never by an expected numerator. This is L8-b. Its risks are the score-factor MGF in the fine Laplace directions (Astra: a covariance trace alone does not give an exponential moment), and L10.

## Theorem A (target statement)

Assume (A1)–(A4): strict slack for Theorem A, or any σ for Theorem A⁺. Define

  **ε²(λ) := (log n)^c · κ^{−5/6} · [ λ^{−1/3} + V² λ^{5/3} n^{−5} ]**  (for Theorem A⁺, multiply the first term by (1 ∨ σ̄/σ)).

Then there are constants c, M, depending only on (τ, L, f, f̄, η) (and on σ, for A⁺), such that, **in both losses**,

  sup_{P ∈ 𝒫ₙ} sup_{λ in the window} E_P Πₙ,λ( Δ²ₙ(θ − θ\*) > M ε²(λ) | y ) → 0,
  sup_{P ∈ 𝒫ₙ} sup_{λ in the window} E_P Πₙ,λ( ‖θ − θ\*‖²ₙ > M ε²(λ) | y ) → 0.

The second statement follows from the first, because L10 is part of the proof: on {‖δ‖∞ ≤ Δ ≤ 1}, Δ²ₙ(δ) = ‖δ‖²ₙ.

**Which version is primary.**
- Theorem A⁺ (every σ) is the theorem that would cover the paper's practice; Theorem A (strict slack) is the first milestone.
- Within each, the **primary** version, to be proved first, fixes the single oracle tuning λₙ = n^{5/2}/V and is uniform over 𝒫ₙ.
- The **target** version above is uniform over the deterministic λ-window. **This uniformity does not by itself license a data-dependent λ.** A hyperposterior on λ (Stage C) needs its own argument: uniform bounds on expected tails for deterministic tunings cannot simply be plugged in.

**How the bias term is obtained across the window.**
- Where condition (C) of L4q holds (λε ≳ n^{10/7}·polylog via L3, or λε ≥ 8n² log(2n) elementarily), the quadratic shift (L4q, L4q-M) gives V²λ^{5/3}n^{−5}.
- Where (C) fails, i.e. at the low end of the window, the ℓ₁ shift (L4) gives λVn^{−3}. This is ≲ λ^{−1/3} there, so it is absorbed by the spread term (Astra).
- At fixed V the two regions overlap and cover the window.
- **Fallback label A-fb:** if L4q failed, the bias term would be κ^{−1/6}λVn^{−3}, with best rate κ^{−7/8}V^{1/4}n^{−3/4} at λ ≍ (n³/V)^{3/4}.

**Corollaries and remarks.**
- **Corollary A1 (oracle tuning).** λₙ ≍ n^{5/2}/V gives ε² ≍ (log n)^c κ^{−5/6} V^{1/3} n^{−5/6}. This is the **linear-smoother minimax rate** for this class (Donoho–Johnstone, as cited in Tibshirani 2014). The minimax rate is n^{−6/7}.
- **Corollary A2 (frequentist tuning).** At Padilla & Chatterjee's published tuning, λσ = c·n^{15/7}(log n)^{1/7} with c large enough for the given confidence level, ε² ≍ n^{−5/7} up to logs. At this tuning the MAP estimator attains n^{−6/7}(log n)^{1/7} (P&C Theorem 3).
- **Remark (knots).** For piecewise quadratics with s knots, the knot count gives no gain under this prior: the spread term does not depend on the truth. No corollary is stated.
- **Conjecture (lower bound, not claimed).** Πₙ,λ(Δ²ₙ < c·λ^{−1/3} | y) → 0. If this holds, the posterior is strictly slower than its mode at every λ. Proving it in one case (a quadratic truth) is the most valuable single addition against the "proof artefact" objection (VP).
## Theorem B (light-tail fallback, "A-LT"; to be proved first)

**Hypothesis (EM).** There is b > 0 such that, for all i, n and all δ ∈ ℝ, E exp{−ωXᵢ(δ)} ≤ exp{−bω·min(δ², |δ|)}.

**Checkable sufficient conditions.**
- **Proposition 1 (primary; Astra's envelope).** P(Zᵢ > t) ≤ (1−τ)e^{−b₊t} and P(Zᵢ < −t) ≤ τe^{−b₋t} for all t ≥ 0, with b₊ > ωτ and b₋ > ω(1−τ). Heteroscedastic laws are allowed. The prefactors are essential.
- **Proposition 2 (alternative; VP).** (A2), sup E e^{c|Zᵢ|} ≤ K, and σ ≥ σ̄_B := 1/ω_B(τ, L, f, c, K), the proved sufficient bound. It is distinct from the numerically estimated critical scale σ_crit.

**Statement.** Fix ω, b > 0, τ, (L, f̄), V and the oracle comparison constants. Let 𝒫ₙᴮ be the class of laws satisfying (A1), the upper half of (A2) (for C₁ in L6), (A3) and (EM) with this **common** b. Take deterministic λ at the oracle λₙ ≍ n^{5/2}/V, with **εₙ² = C(log n)^{1/6}V^{1/3}n^{−5/6}**, or at the fallback λₙ ≍ (n³/V)^{3/4}, with **εₙ² = C(log n)^{1/6}V^{1/4}n^{−3/4}**. Then sup_{𝒫ₙᴮ} E_P Πₙ(Δ²ₙ(θ − θ\*) > Mε² | y) → 0 for any M > (2/b)(1.44C₁ + 1 + C_pr/ω). No bound is uniform as b → 0. These radii carry no κ, because B assumes no lower secant constant. [**Proof complete, advisor-checked**: Astra (B, L6), Fable (L3); every input is advisor-checked.]

**Loss.** Δ²ₙ only. A squared-loss corollary for λ ≥ n^{3/2+} (posterior TV control by Fubini, then interpolation) is flagged and not claimed.

**Proof (T-05).** Fubini on all of ℝⁿ. The flat quadratic integral is bounded by C₃(bω), free of n, λ, u and θ\*. Then L6. **L7, L9 and L10 are not needed.** L2, L3, L4/L4q, L5 and L6 are used as in Theorem A.

**Scope.** (EM) implies the strict point-density threshold **F′(q) ≥ ωτ(1−τ) + 2b**, tail necessity P(Z > d) ≤ e^{−ω(τ+b)d} (d ≥ 1) with its reflection, and a mid-range condition. Gaussian noise at σ₀ is therefore still excluded, as are t₂ and Cauchy noise; B covers none of the paper's runs as executed. **But B does not imply A4's secant condition:** for uniform errors on [−1, 1], τ = ½, ω = 1, B applies while A4's σ̄ = 2 > σ (Astra). So B covers some cases A does not.

**Positioning.** If A is proved, B is the warm-up proposition, kept for its distinct conclusions: it covers some cases A does not (the secant versus point-density example); a **prospective** wider window (endpoints, radius and uniform prior budget not yet supplied); a possible learned-λ corollary (unchecked). If A is not proved, B is the main theorem, and moment-free contraction is a conjecture supported by the t₂ and Cauchy simulations.

**Odds (advisors):** Astra 95% at n^{−3/4} and 85% at n^{−5/6}; Fable 90% and 80%.

## Lemmas (revised and split)

**Prior side.** All statements are under the normalized Π_λ and centred at u\*. Status as of v3.1 is in brackets.

| Lemma | Statement | Difficulty |
|---|---|---|
| **L1 (basis)** | θ = Hα (falling factorial, Tibshirani's Lemma 2). Π_λ corresponds to iid Laplace(2λ/n²) on α_{4:n}. | Trivial; verified numerically. |
| **L3 (small ball)** | For n ≥ 5 and x := n^{5/2}/(λε): φ(ε) ≤ 30·x^{2/5}(log m)^{1/5} + 6. **Loss of (log m)^{1/5} only.** [Advisor-checked: Fable, FABLE_L3_L8p.md.] | Proved via the Gaussian scale mixture of the Laplace law, Anderson's theorem, Horn's inequality for the singular values of C³, and a head/tail product bound. No Laplace small-deviation theory is needed. |
| **L4 (ℓ₁ shift)** | Π_λ(x + C) ≥ e^{−λ‖x‖₁}Π_λ(C) for every measurable C. (Agapiou–Dashti–Helin's Prop. 2.11 is the centred-ball case at unit scale.) [Advisor-checked.] | Trivial. |
| **L4q (quadratic shift, new)** | Let K(ρ) := 4δ_A·Φ(ρ/4)/ρ, with Φ(λr) := φ(r) and δ_A := maxⱼ‖a_{j+1} − aⱼ‖ ≤ n/√3. If δ_A ≤ λr/2, then for every h, Π_λ(h + B_r) ≥ Π_λ(B_r)·exp(−λΣⱼ min{\|hⱼ\|, c_K λhⱼ²}), with c_K = e^{K(λr)}/(1 − e^{−2}). **Condition (C):** K ≤ 1 (so c_K ≤ 3.15). It holds for λr ≥ 51·n^{10/7}(log m)^{1/7} (via L3), or for λr ≥ 8n² log(2n) (elementary). K is nonincreasing in λr. [L4q: advisor-checked, ACCEPT.] | **Decides n^{−5/6} versus n^{−3/4}.** Route: symmetrization (AM–GM); Jensen; a density bound at 0 for the log-concave conditional marginal, via neighbour compensation, L4 and Borell. |
| **L4q-M (mollified truth)** | For 3 ≤ w ≤ m/2, the explicit signed local-quadratic kernel gives u_h with ‖u_h‖₂ ≤ CV/(n²√w), ‖u_h‖∞ ≤ CV/(n²w) and ‖S(u\* − u_h)‖ₙ² ≤ CV²(w/n)⁵. It is applied at half radius: Π_λ(u_h + B_{ε/2}) uses δ_A ≤ λε/4 and K′ := K(λε/2). This gives ε² ≥ C·c_{K′}^{5/6}·V²λ^{5/3}n^{−5}, with w ≍ n(ε/V)^{2/5}. [Advisor-checked: Astra, ACCEPT WITH FIXES; fixes applied.] | Medium. The kernel must be signed: a nonnegative kernel gives V²(w/n)⁴. |
| **L5 (quadratic part)** | The flat coordinates c are integrated with the same Lebesgue normalization in N(B) and in N(ℝⁿ). The posterior is proper and quadratically equivariant. [Advisor-checked.] | By construction. |
| **L7 (sieve)** | For Ã = A_ε + R₂B₂ + R₁B₁ (ADH Prop. 2.15, p = 1): Π_λ((u\* + Ã)ᶜ) ≤ e^{λ‖u\*‖₁}·e^{−r/K}/Π_λ(A_ε). The fine-scale component A_ε is a **multiscale** small-ball set. | Medium. It may be unnecessary under the VP's two-stage L10 route. Astra notes that at the oracle the centring charge can be ≍ n^{1/2}, against an evidence budget of ≍ n^{1/6}. |

**Likelihood side.**

| Lemma | Statement | Difficulty |
|---|---|---|
| **L2 (excess risk)** | For all δ: c₀Δ²ₙ(δ) ≤ n⁻¹M(θ\* + δ) ≤ min{‖δ‖₁/n, C₁‖δ‖²ₙ}, and n⁻¹Σᵢ Var Xᵢ ≤ ‖δ‖²ₙ. Here Xᵢ = ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ) and M = Σᵢ E₀Xᵢ. [Advisor-checked, with fixes applied.] | Easy (P&C Lemma 13 plus (A2)). |
| **L6 (evidence)** | For any ω: P₀( N(ℝⁿ) ≥ ν(G)·exp{−ω(1.44C₁ + 1)nε²} ) ≥ 1 − 1.44/(nε²), with ν(G) = V₃(ε√n/2)³·Π_λ(u_h + B_{ε/2}). [Advisor-checked: Astra, ASTRA_B_L6.md.] | Medium. Jensen plus Chebyshev; moment-free. |
| **L8′ (= L8-a, bounded numerator)** | Exact MGF identity, and log E e^{−ωXᵢ(δ)} ≤ −B·ω·mᵢ(δ) on \|δ\| ≤ Δ, with B ≥ η/2 when ω ≤ (1−η)ω̄ and Δ ≤ Δ₀(η, ω̄, τ). Hence E₀Πₙ(Mε² < ‖δ‖²ₙ, ‖δ‖∞ ≤ Δ \| y) → 0. [Advisor-checked: Fable, FABLE_L3_L8p.md.] | Easy once written. The expectation is taken only on the bounded region. |
| **L8-b (realized numerator)** | Theorem A⁺ on the localized set: the Hölder–Knight route (preferred) or the v3 plan. | **High.** |
| **L9-a (far region)** | Πₙ(Δ²ₙ > K \| y) → 0 **in P₀-probability**, by convexity of the empirical risk plus log-concavity of Πₙ. Moment-free; **no expected remote numerator.** | Medium. It may be subsumed by L10 Stage 1. |
| **L9-c (sieve complement)** | Πₙ(outside the sieve \| y) → 0 in P₀-probability. | High as written. It may be avoided by the VP's two-stage L10 route. |
| **L10 (sup-norm)** | Πₙ(‖θ − θ\*‖∞ > Δ \| y) → 0 in P₀-probability, for a fixed Δ ≤ Δ₀. **It needs independent localization:** interpolation on a shell that is already small in ‖·‖ₙ cannot establish entry into that shell (Astra). Candidate (VP): (1) TV⁽³⁾(δ) ≲ n³/λ in posterior probability; then P&C's uniform bound over TV balls, plus convexity along rays, gives Δ²ₙ ≲ λ^{−2/7}, moment-free, for any ω. (2) The interpolation ‖P_R δ‖∞ ≲ ‖δ‖ₙ^{4/5}·TV⁽³⁾(δ)^{1/5} then gives ‖δ‖∞ → 0 for λ/n^{21/11} → ∞. This fixes a₀. **Stage 2 = L10-I: advisor-checked** (`../T05_Proofs/L10I_interpolation.md`). **Stage 1: parked.** | **Highest risk; essential.** P&C's Lemma 19 is off by n^{r−1} as printed (verified). |

## Main open doubts (ranked by proof risk; both final reviews agree on the order; status as of the 2026-11-22 checkpoint)

**Already closed:** Theorem B (light tails), proof complete and advisor-checked (`../T05_Proofs/THEOREM_B_COMPLETE.md`).


1. **L10, with L9-a and L9-c.** This is the circularity above. Stage 2 (L10-I) is advisor-checked. Stage 1 is **parked at the checkpoint**, with a sketch route in `../T05_Proofs/parked/L10_stage1_NOTES.md`.
2. **L8-b (A⁺ only).** If it fails, the theorem keeps strict slack: Gaussian σ₀ stays excluded, and learning σ is blocked.
3. **L9-c and L7 as written.** These are avoidable via the route in item 1.
4. **L4q, L4q-M:** advisor-checked (low risk). If L4q-M failed, n^{−5/6} would become n^{−3/4}.
   - *Numerical support:* E-02 Gaussian-twin ratio 1.00 ± 0.02; bias-equivalence 0.996–1.013; calibrated kinked bias² slopes matching 5a/3 − 5 and excluding ℓ₁ (MEMO §8.1a′, §8.1a″, §8.1e).
5. **L3.** Low; a failure costs polylogs only.
6. **L6.** Low; it is correct given its inputs.

**Odds (advisors, for one deterministic oracle tuning, moment-free):**
- A at n^{−3/4}: Astra 75% with the strict slack now adopted (60% for the v3 equality case); Fable 60%.
- A at n^{−5/6}: Astra 65% with strict slack (50%); Fable 55%.
- A⁺ at n^{−5/6}: 40% (both).
- With an exponential-tail assumption: 90% at n^{−3/4} and 80% at n^{−5/6} (Fable).

**What a referee attacks first (VP).**
1. The theorem does not cover the method as run: the paper's fixed b₀ gives λ ≍ n^{3/4}, and the learned σ lands below σ̄ for Gaussian noise. This needs the b₀,ₙ decision and A⁺, or honest scoping.
2. It is an upper bound only, for a posterior whose mode is faster.
3. The oracle λ depends on the unknown V.
4. Novelty against P&C plus ADH: lead with L4q and the truth-independent spread.

## Response to the final reviews (v3 → v3.1)

**HQ decisions applied (final reviews and light-tail opinions):** Theorem B under (EM), with Astra's envelope (Proposition 1) and the VP's ψ₁ condition (Proposition 2), proved first, before L10; the mixture row corrected; σ ≥ (1+η)σ̄ (written as ω ≤ (1−η)ω̄); a₀ = 2 with C₀ > 3c/5; both losses; the min shown only as the fallback label; two-stage L10 first; light-tail fallback theorem; Hölder–Knight before net and chaining for A⁺; referee points recorded for the outlook.

**Astra (NOT READY).**
1. *Equality in A4 is false (uniform counterexample).* **Accepted.** A4 now requires strict slack, ω ≤ (1−η)ω̄. L8′ proves the quadratic gain under strict slack, with explicit Δ₀(η). The point-density versus secant distinction is now stated at the R-table, and the Laplace and t₂ rows are marked not covered.
2. *Improper prior: correct. No global expected-numerator bound (Cauchy example).* **Accepted.** The far-region lemmas (L9-a, L9-c, L10) are now stated in P₀-probability. The expected numerator is used only on the bounded region (L8′). SKELETON Step 3 bounds E₀Πₙ(E₂ | y) ≤ 1, never E₀N(E₂).
3. *L3 Horn index; head bound; polylog. L4q: keep (C) and the ellipsoid; L4q-M to be written.* **Accepted.** The index is now ⌊(r+2)/3⌋. The full Gaussian product in the head bound removes the log K factor, giving (log m)^{1/5}. The L4q row states the ellipsoid and (C). L4q-M is now written and advisor-reviewed (ACCEPT WITH FIXES), with c_{K′}^{5/6} kept explicit.
4. *Fallback saves one prior argument; L4 suffices at the low end; fix a₀ by proof; 5C₀/3 > c; no licence for data-dependent λ.* **Accepted.** See A4, "How the bias term is obtained across the window", and the sentence on Stage C.
5. *Risk ranking, L10 highest; interpolation cannot establish entry.* **Accepted.** The L10 row states the circularity and the candidate independent localization. It is the current T-05 item.
6. *Odds.* Recorded above.

**Fable/VP (READY WITH CHANGES).**
1. *A4 strict slack; the sharpness sentence on ω̄(Δ); M free of σ in A, with factor (1 ∨ σ̄/σ) in A⁺; fix a₀ by a non-circular argument and state C₀ > 3c/5; state both losses; the min is only a fallback label; the L2 fix in the table.* **All accepted.** C₀ > 3c/5 is the same condition as Astra's 5C₀/3 > c.
2. *Primary versus fallback; L4q-M with an interior kernel after extending θ\* by its end quadratics; the L3 fixes.* **Accepted.** The extension trick is recorded in L4q-M as an alternative to the explicit boundary kernel.
3. *Hölder–Knight route for A⁺; free numerical test (replicate variance of the posterior mean ÷ rough spread ≈ π/2).* **Adopted** as the preferred L8-b plan. The test will be requested from Engineering on existing E-02 output.
4. *Two-stage L10; exponential-tail fallback.* **Adopted (HQ decision).** The two-stage route is the design being tried first in T-05. The light-tail variant is now Theorem B under (EM), with Astra's envelope as Proposition 1 and the VP's ψ₁ condition as Proposition 2. HQ ordered it proved before L10. Both light-tail opinions (ADOPT WITH CHANGES) are in `reviews/LIGHT_TAIL_*.md`.
5. *Odds; referee attacks.* Recorded above.
