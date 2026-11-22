# Stage-A theorem: statement v2 (after both reviews)

*BQTF Theory Department. v2, 2026-11-22; supersedes v1. Statement and lemma statements only, no proofs. The responses to the reviewers, and the evidence, are in `MEMO.md` §8. The reviews themselves are in `reviews/`.*

## Setting and normalization

- **Data.** Observations y₁, …, yₙ are independent on the grid xᵢ = i/n. Fix τ ∈ (0, 1). The target θ\* = (Fᵢ⁻¹(τ))ᵢ is the vector of true τ-quantiles. All probability is under the true law P₀; the asymmetric Laplace distribution (ALD) is a working likelihood only.
- **Coordinates.** D = D⁽³⁾ ∈ ℝ^{(n−3)×n}, with m = n − 3. Write θ = Nc + Su, where:
  - c ∈ ℝ³ is the quadratic part, with N an orthonormal basis of the quadratics;
  - u = Dθ ∈ ℝᵐ;
  - S is a right-inverse of D;
  - u\* = Dθ\*.
- **Prior.** The prior is dc ⊗ Π_λ(du). Here Π_λ := Laplace(λ)^{⊗m} is a **probability** measure; the Lebesgue part on c is the only improper factor.
- **Stage-A posterior.** σ > 0 and λ are fixed, and ω := 1/σ. For B ⊂ ℝⁿ,

  Πₙ,λ(B | y) = N(B)/N(ℝⁿ), where N(B) = ∫∫_{Nc+Su ∈ B} exp{ −ω Σᵢ [ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ)] } dc Π_λ(du).

  This is the paper's posterior with σ and λ frozen. N(ℝⁿ) < ∞ almost surely for n ≥ 4.
- **Loss.** Δ²ₙ(v) = n⁻¹ Σᵢ min{|vᵢ|, vᵢ²}.
- **Other notation.** TV⁽³⁾(θ) := n²‖Dθ‖₁, and κ := f/σ is the effective curvature, with f the lower margin constant in (A2).

## Assumptions

| Label | Assumption | Why reasonable / checkable |
|---|---|---|
| **(A1)** | y₁, …, yₙ are independent (not necessarily identically distributed) on the equispaced grid. | This is the paper's setting; Padilla & Chatterjee use the same. |
| **(A2)** | **Two-sided margin, uniform in i and n.** For all \|δ\| ≤ L: f\|δ\| ≤ \|Fᵢ(θ\*ᵢ + δ) − Fᵢ(θ\*ᵢ)\| ≤ f̄\|δ\|. | The lower half is Padilla's Assumption A. The upper half is *sufficient and proof-driven*: it excludes atoms at the quantile, and it gives the global bound mᵢ(δ) ≤ max(f̄/2, 1/L)·δ². It is checkable for every simulated noise law (Gaussian, Beta, mixed normal, t₂, Cauchy). **No moment conditions.** |
| **(A3)** | TV⁽³⁾(θ\*) ≤ V, with V fixed (slow growth is allowed later). **No sup-norm bound**: the posterior law of θ − θ\* is exactly invariant to adding a quadratic to θ\*. | The bounded-variation class of Padilla's slow rate (r = 3), equivalently Tibshirani's F₂(C). |
| **(A4)** | **Theorem A:** σ ≥ σ̄ := τ(1−τ)/f, with f the local density constant in (A2); equivalently ω = 1/σ ≤ ω̄ = f/(τ(1−τ)). **Theorem A⁺ (target):** any fixed σ > 0. In both, λ is deterministic, in the window n^{a₀} ≤ λ ≤ n³/(V^{3/2}(log n)^{C₀}). The endpoints are *sufficient*, not necessary. | σ̄ is **sharp for the integrated-likelihood-ratio route** (see the σ̄ paragraph below). a₀ comes from L10: 3/2 via the two-level sieve, or 9/5 conservatively. The upper end keeps the bias term below 1. |

The law class 𝒫ₙ = 𝒫ₙ(τ, L, f, f̄, V) is the set of all independent laws on the grid satisfying (A2) and (A3).

## σ̄ and κ (explicit)

**Exact increment law.** For a displacement δ > 0 at a coordinate with Z = y − θ\*, the check-loss increment is

  X = (1−τ)δ − clip(Z, 0, δ),

which is bounded and needs no moments. Its moment-generating function is

  E e^{−ωX} = e^{−ω(1−τ)δ}[1 + ∫₀^δ ω e^{ωs}(1 − F(s)) ds].

Expanding at δ = 0 gives log E e^{−ωX} = ½(ω²τ(1−τ) − ωf(q))δ² + o(δ²). So the per-coordinate MGF is below 1 near 0 **iff ω < f(q)/(τ(1−τ))**.

**What this means for the Fubini route.** The threshold is exact, not a Bernstein artefact. Numerically, the exact threshold ω̄(Δ) equals this local value for every Δ tested, for Gaussian, Laplace, t, and uniform noise. So **neither a sharper MGF bound nor a different Δ can close the gap**. The integrated-likelihood-ratio (Fubini) route works exactly for σ ≥ σ̄ = τ(1−τ)/f.

**Comparison with the paper's regime, σ₀ = E ρ_τ(ε − q_τ).** The gap ratio is R := σ̄/σ₀ = τ(1−τ)/(f(q)σ₀):

| Noise | τ | R |
|---|---|---|
| Gaussian | 0.50 | **1.571 (π/2)** |
| Gaussian | 0.75 | 1.857 |
| Gaussian | 0.90 | 2.922 |
| Gaussian | 0.95 | 4.466 |
| Laplace (correctly specified ALD) | 0.50 | **1.000** (boundary) |
| t₃ | 0.50 | 1.234 |
| t₂ | 0.50 | 1.000 |
| Uniform | 0.50 | 2.000 |
| 0.9 N(0, 0.1²) + 0.1 N(0, 3²) | 0.50 | **0.446** (covered) |

So Theorem A covers the paper's σ₀ only when R ≤ 1, i.e. for noise strongly peaked at the quantile. For Gaussian noise it misses σ₀ by a factor of π/2 at the median, and the factor grows toward the tails. Source: `scratch/omega_bar_exact.out`.

**Dependence on κ = f/σ.** The condition σ ≥ σ̄ is equivalent to κ ≤ f²/(τ(1−τ)). The rate carries κ^{−5/6} in front: ε² ∝ κ^{−5/6}[λ^{−1/3} + V²λ^{5/3}n^{−5}]. Larger σ (smaller κ) widens the spread, but stays within constants.

**Plan for Theorem A⁺ (every fixed σ).** The Fubini route fails above ω̄ because it bounds the *expected* numerator. The fluctuation term ½ω²τ(1−τ)‖δ‖² is then charged on the whole displacement. The plan analyses the *realized* numerator on the sup-norm-localized set from L10, in five steps:
1. **Knight decomposition.** On {‖δ‖∞ ≤ Δ}, write n·M̂(θ\* + δ) = −u′δ + n·m(δ) + Rₙ(δ). Here uᵢ = τ − 1{Zᵢ ≤ 0} is the bounded score, m is the population excess risk (≳ Δ²ₙ), and Rₙ is a centred remainder with bounded, variance-controlled increments.
2. **Coarse part.** Split δ into a coarse part on an ε-net of the structured sieve (entropy ≲ nε²) and a fine-scale part. Uniformly over the net, \|u′δ_c\| ≲ √(nε²)·√n·‖δ_c‖ₙ. On the shell ‖δ‖ₙ ≥ √M·ε this is ≤ n‖δ_c‖²ₙ/√M, which is dominated by n·m(δ_c) for **any** ω once M is large.
3. **Fine part.** Integrate the fine-scale part against the prior rather than taking a supremum. The linear tilt exp(ω u′v) contributes about exp(½ω²u′Σ_v u), whose exponent is ≍ τ(1−τ)·tr Σ_v ≲ nε² in P₀-probability. That is the spread term again.
4. **Remainder.** Rₙ is controlled by chaining across the scales below ε (the VP's multiscale requirement).
5. **Far region.** L9-a (convexity and log-concavity) and L10 handle everything outside the localized set.

This is L8-b made concrete. Its risks are the chaining of Rₙ and L10. If it succeeds it removes σ̄ entirely; the constant M then depends on ω.

## Theorem A (target statement)

Assume (A1)–(A4), with σ ≥ σ̄ for Theorem A, or any σ for Theorem A⁺. Define

  **ε²(λ) := (log n)^c · κ^{−5/6} · [ λ^{−1/3} + min{ κ^{−1/6}λV n^{−3}, V² λ^{5/3} n^{−5} } ].**

Then there are constants c, M depending only on (τ, L, f, f̄, σ) such that

  sup_{P ∈ 𝒫ₙ} sup_{λ in the window} E_P Πₙ,λ( Δ²ₙ(θ − θ\*) > M ε²(λ) | y ) → 0.

**Which version is primary.** Theorem A⁺ (every σ) is the theorem that covers the paper's practice; Theorem A (σ ≥ σ̄) is the first milestone. Within each, the **primary** version, to be proved first, fixes the single oracle tuning λₙ = n^{5/2}/V and is uniform over 𝒫ₙ. The **target** version above, uniform over the λ-window, is the one Stage B needs. Inside the window the min always selects the second term, V²λ^{5/3}n^{−5}. The first term is what survives if the quadratic shift lemma (L4q) fails.

**Corollaries and remarks.**
- **Corollary A1 (oracle tuning).** λₙ ≍ n^{5/2}/V gives ε² ≍ (log n)^c κ^{−5/6} V^{1/3} n^{−5/6}. This is the **linear-smoother minimax rate** for this class (Donoho–Johnstone, as cited in Tibshirani 2014). The minimax rate is n^{−6/7}.
- **Corollary A2 (frequentist tuning).** At Padilla & Chatterjee's published tuning, λσ = c·n^{15/7}(log n)^{1/7} with c large enough for the given confidence level, ε² ≍ n^{−5/7} up to logs. At this tuning the MAP estimator attains n^{−6/7}(log n)^{1/7} (P&C Theorem 3).
- **Corollary A3 (average squared error).** If L10 holds in P₀-probability, the same rate holds for ‖θ − θ\*‖²ₙ, since ‖δ‖²ₙ ≤ max(1, ‖δ‖∞)Δ²ₙ(δ).
- **Fallback theorem A-fb (if L4q fails).** The same statement holds with the min replaced by its first term, κ^{−1/6}λVn^{−3}. Its best rate is κ^{−7/8}V^{1/4}n^{−3/4}, at λ ≍ (n³/V)^{3/4}. It uses the same likelihood-side lemmas.
- **Remark (knots).** For piecewise quadratics with s knots, the knot count gives no gain under this prior: the spread term does not depend on the truth. No corollary is stated.
- **Conjecture (lower bound, not claimed).** Πₙ,λ(Δ²ₙ < c·λ^{−1/3} | y) → 0. If this holds, the posterior is strictly slower than its mode at every λ.

## Lemmas (revised and split)

**Prior side.** All statements are under the normalized Π_λ and centred at u\*.

| Lemma | Statement | Difficulty |
|---|---|---|
| **L1 (basis)** | θ = Hα (falling factorial, Tibshirani's Lemma 2). Π_λ corresponds to iid Laplace(2λ/n²) on α_{4:n}. | Trivial; verified numerically. |
| **L3 (small ball)** | −log Π_λ(‖P⊥Su‖ₙ ≤ ε) ≤ C(n^{5/2}/(λε))^{2/5} for (log n)/λ ≤ ε ≤ n^{5/2}/λ. | Medium. The Gaussian case is classical (twice-integrated Brownian motion; Fill & Torcaso; spectral method of Bach & Klein). **The Laplace case is open**: the rotation destroys independence. Verified numerically. |
| **L4 (ℓ₁ shift)** | Π_λ(u\* + B) ≥ e^{−λ‖u\*‖₁}Π_λ(B) for every B. This is Agapiou–Dashti–Helin's Prop. 2.11 with p = 1. | Trivial. |
| **L4q (quadratic shift, new)** | For symmetric convex B of small-ball type and ‖h‖∞ ≤ 1/λ: Π_λ(h + B) ≥ exp(−Cλ²‖h‖₂²)Π_λ(B). It is applied with h = D(θ\* mollified over w = (λ²/κ)^{1/6} grid points). | **Medium–high; decides n^{−5/6} versus n^{−3/4}.** Not in ADH: they note the p ≠ 2 shift loss is in the Z-norm. Route: symmetrize over ±h (AM–GM), giving Π(h + B) ≥ Π(B)·E_{Π\|B} exp{−λΣⱼ(\|hⱼ\| − \|uⱼ\|)₊}, then use the near-zero density of the log-concave conditional marginals. |
| **L5 (quadratic part)** | The flat coordinates c are integrated with the same Lebesgue normalization in N(B) and in N(ℝⁿ). | By construction. |
| **L7 (sieve)** | For Ã = A_ε + R₂B₂ + R₁B₁ (ADH Prop. 2.15, p = 1): Π_λ((u\* + Ã)ᶜ) ≤ e^{λ‖u\*‖₁}·e^{−r/K}/Π_λ(A_ε). The fine-scale component A_ε is a **multiscale** small-ball set, with entropy controlled at every scale below ε. | Medium. |

**Likelihood side.**

| Lemma | Statement | Difficulty |
|---|---|---|
| **L2 (excess risk)** | For all δ: c₀Δ²ₙ(δ) ≤ n⁻¹M(θ\* + δ) ≤ C₁ min{‖δ‖₁/n, ‖δ‖²ₙ}, globally, and n⁻¹Σᵢ Var Xᵢ ≤ ‖δ‖²ₙ. Here Xᵢ = ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ) and M = Σᵢ E₀Xᵢ. | Easy (P&C Lemma 13 plus (A2)). |
| **L6 (evidence)** | P₀( N(ℝⁿ) ≥ ε³ exp{−C nκε²} ) → 1, with the prior mass from L3, L4/L4q and L5. | Medium. |
| **L8 (shells)** | Π(Mε² < Δ²ₙ ≤ K, inside the sieve | y) → 0. **Route L8-a (milestone, small ω only):** a Fubini-integrated numerator bound on {‖θ − θ\*‖∞ ≤ Δ}, with no supremum and no entropy. **Route L8-b (target, any σ):** in-probability uniform bounds on the empirical excess loss over nested structured sieves, chained across scales below ε (VP), inside an Atchadé-type peeling over the shells. | **High.** The old uniform-over-ε-ball version is withdrawn: the reviewers' counterexample shows the ε-ball fits the residual signs. |
| **L9-a (far region)** | Π(Δ²ₙ > K | y) → 0 for a constant K, by convexity of the empirical risk plus log-concavity of Πₙ. Moment-free. | Medium. Log-concavity in dimension n reaches only a constant K, not Mε². |
| **L9-c (sieve complement)** | Π(outside the sieve | y) → 0. This needs an explicit bound on the integrated numerator outside the sieve, not just small prior mass. | High. |
| **L10 (sup-norm)** | Π(‖θ − θ\*‖∞ > Δ | y) → 0. Route: the interpolation bound ‖P_R δ‖∞ ≲ ‖δ‖ₙ^{4/5}·TV⁽³⁾(δ)^{1/5} on localized shells. This sets a₀. | **High; essential.** It is needed for L8-a, for Corollary A3 and for a₀. P&C's Lemma 19 is off by n^{r−1} as printed (verified); the correct bound is ‖P_R δ‖∞ ≲ TV⁽³⁾(δ). |

## Main open doubts

1. **L4q (quadratic shift).** It decides between the primary rate n^{−5/6} and the fallback n^{−3/4}.
   - *Evidence for n^{−5/6} (company sampler, E-04 passed):* the E-02 Gaussian-twin arm gives Laplace ÷ Gaussian-twin = 1.00 ± 0.02 for bias², Δ² and MSE on the kinked truth, over a ∈ {2, 9/4, 5/2, 8/3} and n ≤ 16k (MEMO §8.1a′). The noiseless bias-equivalence table on the company sampler gives Laplace ÷ spline bias² = 0.996–1.013 in all 16 cells (n = 300–2400, a = 2–8/3; MEMO §8.1a″). Earlier, in my own-Gibbs check, since retired, the Laplace posterior-mean bias² equals the smoothing-spline bias² to within 0.5%, at n = 300–2400 and λ = n² to n^{2.67}. In every cell it is far below the ℓ₁-shift bound (MEMO §8).
   - *Decisive test:* Engineering's kinked-truth runs at a ∈ {5/2, 8/3}. Under n^{−5/6}, the risk keeps falling until a = 5/2; under n^{−3/4}, it rises past 9/4.
2. **L8-b and L9-c (likelihood side for arbitrary σ).** These are the main proof risk. L8-a gives a small-ω milestone only.
3. **L10 and a₀.** The interpolation route is plausible but unproved.
4. **L3 in the Laplace case.** Open; it is needed by both versions.
5. **ALD spread law: confirmed for the ALD posterior** (Engineering, E-02 T3lam, exact Gibbs, κ = 16; E-04 passed, clamp effect ≤ 2%).
   - The slope of the rough spread in log λ is −0.372 at n = 1000 and −0.342 at n = 4000; predicted −1/3.
   - The constant is 0.28–0.35; predicted 0.3–0.4.
   - The spread is flat in n, ratio 1.01–1.04, while n·λ^{−1/3} ≳ 10. It breaks down at n·λ^{−1/3} ≈ 3, as predicted.
6. **The σ̄ gap.** Theorem A, with σ ≥ σ̄, misses the paper's σ₀ by the factor R (π/2 for Gaussian noise at τ = ½). Closing it is the job of Theorem A⁺ (plan above).
