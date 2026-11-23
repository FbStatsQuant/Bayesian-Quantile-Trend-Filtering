# Theorem B (light-tail fallback, "A-LT"): oracle contraction in Δ²ₙ under a global MGF condition

**Status:** advisor-checked (2026-11-22), Astra (`reviews/ASTRA_B_L6.md`). Propositions 1 and 2: ACCEPT. Assembly: ACCEPT WITH FIXES, all applied (see "Response to the advisor check"). B is fully checked once L3 passes its advisor check (Fable, running). The mixture-row numbers are re-verified (NOTS job 2858270).
- **Source.** Written after the two light-tail opinions, Astra (`../T03_Feasibility/reviews/LIGHT_TAIL_astra.md`) and Fable/VP (`../T03_Feasibility/reviews/LIGHT_TAIL_fable.md`). Both say ADOPT WITH CHANGES. Felipe approved it as the fallback theorem, and HQ has decided to prove **B first, before L10**.
- **Structure (HQ decision).**
  - The hypothesis is the VP's (EM).
  - **Proposition 1** (the primary checkable condition) is Astra's two-sided envelope.
  - **Proposition 2** (the alternative) is a uniform ψ₁ bound plus a σ threshold.
- **Separation from Theorem A.** Everything in this file affects only Theorem B. Theorem A (moment-free) does not use it, and nothing here changes L2–L6 or L8′.
- **Depends on:** L2, L3, L4q + L4q-M (primary) or L4 (fallback), L5, L6, L8′ (Proposition 2, optional sharp local constant).
- **Does not need:** L7, L9-a, L9-c, L10.

## The hypothesis (EM)

**(EM)** There is b > 0 such that, for all i, n and **all** δ ∈ ℝ,

  E exp{−ωXᵢ(δ)} ≤ exp{−bω·min(δ², |δ|)},

where Xᵢ(δ) = ρ_τ(Zᵢ − δ) − ρ_τ(Zᵢ) and Zᵢ = yᵢ − θ\*ᵢ.

**What (EM) implies about the scale (Astra, B/L6 review #3).** (EM) is a condition on the pair (law, σ). It has three consequences:
- **Local: a strict point-density threshold.** If Fᵢ is differentiable at the quantile, comparing quadratic coefficients in the expansion of L8′(c) gives **Fᵢ′(q) ≥ ωτ(1−τ) + 2b**. This is a strict point-density threshold, and Gaussian noise at σ₀ is still excluded. It does **not** imply A4's secant-based condition. *Counterexample (Astra):* uniform errors on [−1, 1], τ = ½, ω = 1. Proposition 1 applies with b₊ = b₋ = 1, since (1−t)₊ ≤ e^{−t}. But on the valid A2 interval L = 4 the best lower secant is 1/8, which gives A4's σ̄ = 2 > σ = 1. **So B covers some cases that Theorem A, with its secant constant, does not.**
- **Tail necessity.** For d ≥ 1, the event {Zᵢ > d} alone contributes e^{ωτd}P(Zᵢ > d) to the MGF. So (EM) forces **P(Zᵢ > d) ≤ e^{−ω(τ+b)d}**, and reflection gives P(Zᵢ < −d) ≤ e^{−ω(1−τ+b)d}. This alone excludes polynomial tails. *(The earlier claim that failure of (EM) gives infinite expected evidence is withdrawn. Astra's counterexample: a density ∝ e^{−ω|z|/2}/(1+|z|)², at the critical rate, has finite expected evidence.)*
- **Mid-range.** The bound must also hold at intermediate δ (Astra's bounded counterexample: an atom at ±4 breaks it at δ = 4).

**Coverage.** B covers none of the paper's runs as executed. t₂ and Cauchy noise are excluded by tail necessity, and Gaussian noise at σ₀ is excluded by the point-density threshold.

## Proposition 1 (Astra's envelope ⇒ (EM))

**(A5-env)** For every i and every t ≥ 0,

  P(Zᵢ > t) ≤ (1−τ)e^{−b₊t},  P(Zᵢ < −t) ≤ τe^{−b₋t},  with  b₊ > ωτ,  b₋ > ω(1−τ).

Heteroscedastic laws are allowed. The prefactors (1−τ) and τ are essential: a generic envelope Ce^{−bt} can fail at intermediate δ.

**Claim.** (A5-env) ⇒ (EM), with bω = a(ω, τ, b₊, b₋) > 0.

**Proof.**
1. *Exact MGF.* For d > 0, by L8′(a),

   E e^{−ωXᵢ(d)} = e^{−ω(1−τ)d}[1 + ω∫₀^d e^{ωs}P(Zᵢ > s) ds].

2. *Insert the envelope.* Write α := ω(1−τ) and b := b₊. Then

   E e^{−ωXᵢ(d)} ≤ U(d) := e^{−αd}[1 + α∫₀^d e^{(ω−b)s} ds].

   U depends only on (ω, τ, b), and it is strictly decreasing in b for each d > 0.
3. *Critical rate.* At b = ωτ we have ω − b = α, so the bracket equals e^{αd} and U ≡ 1. Since b > ωτ, **U(d) < 1 for every d > 0**.
4. *Near 0.* U(d) = 1 − (α/2)(b − ωτ)d² + O(d³). So −log U(d)/d² → (α/2)(b − ωτ) > 0.
5. *At infinity.*
   - If b > ω: U(d) ≤ (1 + α/(b−ω))e^{−αd}.
   - If b = ω: U(d) = e^{−αd}(1 + αd).
   - If ωτ < b < ω: U(d) ≤ (1 + α/(ω−b))e^{−(b−ωτ)d}.

   In every case lim inf_{d→∞} −log U(d)/d ≥ min(α, b − ωτ) > 0.
6. *Compactness.* g(d) := −log U(d)/min(d², d) is continuous and positive on (0, ∞), with positive limits (or lim infs) at 0 and at ∞. So a₊ := inf_{d>0} g(d) > 0.
7. *The case d < 0.* It is identical, with τ ↔ 1−τ and b₊ → b₋; the critical rate is ω(1−τ). This gives a₋.

Take a := min(a₊, a₋). ∎

*An explicit a (open):* not needed for the theorem, but it would make M explicit.

## Proposition 2 (ψ₁ bound + σ threshold ⇒ (EM); the VP's step 4)

**(A5-ψ₁)** sup_{i,n} E exp{c|Zᵢ|} ≤ K for some c > 0 and K < ∞. Assume also (A2), which gives c₀ in L2.

Set C_V := max{e^{c/2}, 16K/(ce)²}. Then (EM) holds with b = c₀/2 whenever

  ω ≤ ω_B := min{c/2, c₀/C_V},  i.e. σ ≥ σ̄_B := 1/ω_B.

**Proof.** Take δ > 0; the case δ < 0 is symmetric, with τ ↔ 1−τ and the left tail. Let W := clip(Zᵢ, 0, δ), so that Xᵢ = (1−τ)δ − W (L2).
1. *Expansion.* For Y = ωW ≥ 0, log E e^Y ≤ E e^Y − 1 ≤ EY + ½E[Y²e^Y]. Also EW = (1−τ)δ − mᵢ(δ) (L2). Hence

   log E e^{−ωXᵢ(δ)} = −ω(1−τ)δ + log E e^{ωW} ≤ −ω mᵢ(δ) + ½ω² E[W²e^{ωW}].

2. *Moment bound.* We have W ≤ min(Zᵢ₊, δ).
   - If δ ≤ 1: E[W²e^{ωW}] ≤ δ²e^{ω} ≤ δ²e^{c/2}.
   - If δ > 1: E[W²e^{ωW}] ≤ E[Zᵢ₊²e^{(c/2)Zᵢ₊}] ≤ sup_z z²e^{−(c/2)z}·E e^{cZᵢ₊} ≤ 16K/(ce)².

   So E[W²e^{ωW}] ≤ C_V·min(δ², 1) ≤ C_V·min(δ², δ).
3. *Margin.* By L2 (moment-free), mᵢ(δ) ≥ c₀·min(δ², |δ|). Therefore

   log E e^{−ωXᵢ(δ)} ≤ −ω·min(δ², |δ|)·(c₀ − ωC_V/2) ≤ −(c₀/2)·ω·min(δ², |δ|)  when ω ≤ c₀/C_V. ∎

**Sharp local constant (optional).** On |δ| ≤ Δ₀, L8′(b) gives log E e^{−ωX} ≤ −(η/2)ω·m(δ) under ω ≤ (1−η)ω̄, with the sharp local threshold. One can use it near 0 and the bound above for |δ| > Δ₀. That relaxes c₀/C_V only on |δ| ≤ Δ₀, so the global threshold σ̄_B is unchanged. The proposition above is the simple version.

**How strict is the exact critical scale?** Write σ_crit for the numerically estimated critical scale of (EM), i.e. the smallest σ for which E e^{−ωX(δ)} ≤ 1 for all δ. This is a different object from the sufficient bound σ̄_B = 1/ω_B proved above, and the proposition proves only σ̄_B. By the VP's check, σ_crit equals the local point-density threshold (within grid tolerance) for Gaussian, Laplace, logistic and uniform noise. For the mixture 0.9N(0, 0.1²) + 0.1N(0, 3²) it is much stricter: σ_crit ≈ 3.6σ₀ at τ = ½.

**Re-verified independently** with `checks/global_threshold.py` (8e2565b; Engineering, NOTS job 2858270; δ ∈ [−40, 40], 4×10⁵ grid points per side). In the script output the column labelled "sigma_bar_B" is σ_crit.
- Gaussian, Laplace, logistic and uniform at τ ∈ {½, ¾, 0.9}: ω_crit/ω_loc = 0.994–0.999.
- Mixture: ω_crit/ω_loc = 0.125, 0.076 and 0.063, i.e. **σ_crit/σ₀ = 3.58, 6.22 and 10.44** at τ = ½, ¾ and 0.9 (the local value is 0.45–0.66).

These match the VP's figures.

## Theorem B

**Law class (fixed before the supremum; Astra #1).** Fix ω > 0, b > 0, τ, the upper-margin constants (L, f̄), V > 0, and the comparison constants of the oracle tuning. 𝒫ₙᴮ is the class of independent laws satisfying (A1), the upper half of (A2) with (L, f̄), (A3) with V, and (EM) with **this common b**: the same b for every law in the class, every coordinate, every n and every δ ∈ ℝ.

**Assumptions.**
- (A1); (A3) with fixed V; (EM) with the given ω and the common b.
- The upper half of (A2), which L6 needs for C₁ (mᵢ(δ) ≤ C₁δ² near 0). Neither (EM) nor the envelope gives this, because both bound tails or MGFs, not densities.
- λ deterministic, either λₙ ≍ n^{5/2}/V (primary) or λₙ ≍ (n³/V)^{3/4} (fallback), with fixed comparison constants. Correspondingly εₙ² = C(log n)^c V^{1/3}n^{−5/6} or C(log n)^c V^{1/4}n^{−3/4}, with **c ≥ 1/6**.
  - *Why c ≥ 1/6.* At half radius L3 gives φ(ε/2) ≲ nλ^{−2/5}ε^{−2/5}(log m)^{1/5} + 6, which is ≤ nε² when ε² ≳ λ^{−1/3}(log m)^{1/6}.
  - *Matching orders.* The log-free spread λ^{−1/3} and the bias term are both of order V^{1/3}n^{−5/6} at the primary tuning (L4q-M route), and both of order V^{1/4}n^{−3/4} at the fallback (L4 route).
  - *B does not use κ.* These radii are stated directly. Theorem A's κ contains a lower secant constant that B does not assume.

**Conclusion (Δ²ₙ).** Any M > (2/b)(1.44C₁ + 1 + C_pr/ω) works. Here C_pr depends on V and the comparison constants, and **no bound is uniform as b → 0**. For such M,

  sup_P E_P Πₙ( Δ²ₙ(θ − θ\*) > M ε² | y ) → 0.

The supremum is over 𝒫ₙᴮ.

**Proof.** Write H(δ) := nΔ²ₙ(δ) = Σᵢ min(δᵢ², |δᵢ|) and E := {H > Mnε²}.

1. *Expected numerator on all of ℝⁿ (Tonelli, independence, (EM)).*

   E₀N(E) = ∫_E ∏ᵢ E e^{−ωXᵢ(δᵢ)} dν ≤ ∫_E e^{−bωH} dν ≤ e^{−bωMnε²/2} ∫ e^{−bωH/2} dν.

2. *The flat part is bounded by an absolute constant.*
   - *Claim:* H(δ) ≥ min(‖δ‖₂², ‖δ‖₂). Let A = {i : |δᵢ| > 1}, p = Σ_{Aᶜ}δᵢ² and q = Σ_A δᵢ². Then H ≥ p + √q, since ‖·‖₁ ≥ ‖·‖₂ on A. If A = ∅, H = p = ‖δ‖₂². Otherwise q ≥ 1, and (p + √q)² ≥ p + q, so H ≥ ‖δ‖₂.
   - *Reduction to c.* ‖δ‖₂ ≥ ‖P_N δ‖₂ = ‖c − c₀(u)‖₂, with c₀(u) := c\* − NᵀS(u − u\*), because N is orthonormal. Since r ↦ min(r², r) is nondecreasing, for each u,

     ∫_{ℝ³} e^{−bωH/2} dc ≤ C₃(bω) := ∫_{ℝ³} e^{−(bω/2)min(|c|², |c|)} dc < ∞.

   - *Integrate over u.* Π_λ has mass 1, so ∫ e^{−bωH/2} dν ≤ C₃(bω). **This is free of n, λ, u and θ\*.**
3. *Denominator (L6).* On an event of probability ≥ 1 − 1.44/(nε²),

   N(ℝⁿ) ≥ V₃(ε√n/2)³ · Π_λ(u_h + B_{ε/2}) · e^{−ω(1.44C₁+1)nε²}.

   The prior-mass bound is −log Π_λ(u_h + B_{ε/2}) ≤ C_pr nε². This comes from L3 together with the half-radius L4q and L4q-M (primary), or from L3 and L4 with u_h = u\* (fallback).
   - *Primary route, conditions (large-n admissibility; Astra #2):* δ_A ≤ λε/4 and K′ = K(λε/2) ≤ 1. At the primary oracle λε ≍ n^{25/12}V^{−5/6}(log n)^{c/2}, which eventually exceeds the half-radius threshold 102·n^{10/7}(log m)^{1/7} of R1 and gives δ_A ≤ n/√3 ≤ λε/4. The bandwidth w ≍ n(ε/V)^{2/5} satisfies w → ∞ and w/n → 0. So both uses of L4q-M are admissible for n ≥ n₀(V).
   - *Volume term.* It is kept exactly, as −log[V₃(ε√n/2)³]. At either oracle nε² → ∞ and this term is O(log n).
   - *Uniformity:* the prior side does not depend on the law P, so uniformity over P is unaffected.
4. *Combine.*

   E₀Πₙ(E | y) ≤ (C₃(bω)/V₃)·(2/(ε√n))³ · exp{−[bM/2 − (1.44C₁+1) − C_pr/ω]·ωnε²} + 1.44/(nε²).

   This uses Πₙ(E | y) ≤ N(E)·1_Ω/L + 1_{Ωᶜ}, where L is the deterministic lower bound of step 3 and Ω its event.

   Since nε² → ∞, the first term → 0 once M > (2/b)(1.44C₁ + 1 + C_pr/ω), so that the bracket is positive. The second term → 0. ∎

## Corollaries and remarks

- **Squared loss (flagged, not claimed).** The VP's sketch:
  - Fubini on {λ‖u − u\*‖₁ > Tm} gives TV⁽³⁾(δ) ≲ n³/λ in posterior probability.
  - Interpolation, now non-circular because Δ²ₙ ≲ ε² is already known, then gives ‖δ‖∞ → 0, and hence ‖δ‖²ₙ ≲ Mε², for λ ≥ n^{3/2+}.
  - This is checked at the level of exponents only, and the TV step needs the same flat-part integration with an extra λ‖u‖₁ tilt. **To be written only if it closes cleanly; flagged until then.**
- **Window (prospective).** B is proved only at the two oracle tunings. A wider λ-window, whose lower end would come from the prior side only rather than from L10, is prospective until its endpoints, radius and uniform prior budget are supplied.
- **Learned λ (unchecked remark).** The numerator bound is free of λ, so a hyperprior on λ integrates inside Fubini. Learned λ at fixed σ would then need only hyperprior mass ≥ e^{−nε²} near the oracle: a fixed-b₀ Gamma fails this, a polynomial tail passes (VP). Not pursued now.
- **Positioning (HQ decision).** If Theorem A is proved, B becomes the warm-up proposition, kept for its distinct conclusions: it **covers some cases A does not** (A4's secant constant can be strictly worse than the point density, e.g. the uniform-error example); a prospective wider window; a possible learned-λ corollary. If A is not proved, B is the main theorem, and moment-free contraction is a conjecture supported by the t₂ and Cauchy simulations.
  - *Referee question "why exponential moments for a quantile method?":* the honest answer is that the assumption belongs to the proof technique.
- **Odds (advisors), for Δ²ₙ at one oracle tuning, up to logs:** Astra 95% at n^{−3/4} and 85% at n^{−5/6}; Fable 90% and 80%. The remaining risk is on the prior side and in L6.
- **Status of the inputs.**
  - L2, L4, L5, L4q: advisor-checked.
  - L4q-M: accepted with fixes (applied).
  - L3: numerical check PASSED (NOTS job 2857810); self-checked once its fixes are committed.
  - L6: draft, self-checked.
  - L8′: numerical check PASSED (NOTS job 2857877).
  - **New here:** Propositions 1 and 2, and the assembly.

## Response to the advisor check (Astra, `reviews/ASTRA_B_L6.md`)

Verdicts: assembly ACCEPT WITH FIXES; Proposition 1 ACCEPT; Proposition 2 ACCEPT. All fixes concern wording and scope; no mathematics changed.

1. **Law class.** ω, b, τ, (L, f̄), V and the oracle comparison constants are fixed first, and (EM) holds with one common b across the class. Any M > (2/b)(1.44C₁ + 1 + C_pr/ω) works; no bound is uniform as b → 0.
2. **Radii.** c ≥ 1/6, from the small-ball logarithm at half radius. The radii are stated directly, without κ. Large-n admissibility of L4q-M at the primary oracle is recorded. The wider window is marked prospective.
3. **Scale claim.** This is now the exact implication F′(q) ≥ ωτ(1−τ) + 2b, a strict point-density threshold. B does not imply A4's secant condition (Astra's uniform example), so B covers some cases A does not. The positioning line and the MEMO addendum are corrected.
4. **Infinite-evidence claim: deleted.** Tail necessity P(Z > d) ≤ e^{−ω(τ+b)d} (d ≥ 1), with its reflection, is kept.
5. **Symbols.** σ_crit is the numerically estimated critical scale; σ̄_B = 1/ω_B is the proved sufficient bound.
