# Theorem B (light-tail fallback, "A-LT"): oracle contraction in Δ²ₙ under a global MGF condition

**Status:** draft (2026-11-22).
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

**B does not relax the scale restriction; it adds to it.** (EM) is a condition on the pair (law, σ). It implies three constraints on σ:
- **Local.** If fᵢ(q) exists, the expansion of L8′(c), log E e^{−ωX} = ½(ω²τ(1−τ) − ωfᵢ(q))δ² + o(δ²) ≤ −bωδ², forces fᵢ(q) ≥ ωτ(1−τ) + 2b. Hence ω < fᵢ(q)/(τ(1−τ)), i.e. **σ > σ̄** (point density), with margin 2b.
- **Tail.** The noise must be lighter-tailed than the working ALD: a right-tail rate > ωτ and a left-tail rate > ω(1−τ). Otherwise a constant shift through the flat c gives E₀N(ℝⁿ) = ∞ (VP).
- **Mid-range.** The bound must also hold at intermediate δ (Astra's bounded counterexample: an atom at ±4 breaks it at δ = 4).

**Coverage.** B covers none of the paper's runs as executed: t₂ and Cauchy noise are excluded by the tail constraint, and Gaussian noise at σ₀ < σ̄ is excluded exactly as in Theorem A.

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

**How strict is σ̄_B?** By the VP's check, the exact global threshold equals the local ω̄ (within grid tolerance) for Gaussian, Laplace, logistic and uniform noise. For the mixture 0.9N(0, 0.1²) + 0.1N(0, 3²) it is much stricter: σ̄_B ≈ 3.6σ₀ at τ = ½. *Re-verification pending:* `checks/global_threshold.py` is queued (owls_run refused); the VP's script was not saved.

## Theorem B

**Assumptions.**
- (A1); (A3) with fixed V; (EM) with the given ω.
- The upper half of (A2), which L6 needs for C₁ (mᵢ(δ) ≤ C₁δ² near 0). Neither (EM) nor the envelope gives this, because both bound tails or MGFs, not densities.
- λ deterministic, either λₙ ≍ n^{5/2}/V (primary) or λₙ ≍ (n³/V)^{3/4} (fallback). Correspondingly εₙ² = (log n)^c V^{1/3}n^{−5/6} or (log n)^c V^{1/4}n^{−3/4}.

**Conclusion (Δ²ₙ).** There is M = M(b, ω, f̄, L, C_pr) such that

  sup_P E_P Πₙ( Δ²ₙ(θ − θ\*) > M ε² | y ) → 0.

The supremum is over all laws satisfying the assumptions.

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
4. *Combine.*

   E₀Πₙ(E | y) ≤ C₃(bω)·(2/(ε√n))³ · exp{−[bM/2 − (1.44C₁+1) − C_pr/ω]·ωnε²} + 1.44/(nε²).

   Since nε² → ∞, the first term → 0 once M > (2/b)[1.44C₁ + 2 + C_pr/ω], and the second → 0. ∎

## Corollaries and remarks

- **Squared loss (flagged, not claimed).** The VP's sketch:
  - Fubini on {λ‖u − u\*‖₁ > Tm} gives TV⁽³⁾(δ) ≲ n³/λ in posterior probability.
  - Interpolation, now non-circular because Δ²ₙ ≲ ε² is already known, then gives ‖δ‖∞ → 0, and hence ‖δ‖²ₙ ≲ Mε², for λ ≥ n^{3/2+}.
  - This is checked at the level of exponents only, and the TV step needs the same flat-part integration with an extra λ‖u‖₁ tilt. **To be written only if it closes cleanly; flagged until then.**
- **Window.** a₀ is no longer set by L10; the lower end of the window comes from the prior side only.
- **Learned λ (unchecked remark).** The numerator bound is free of λ, so a hyperprior on λ integrates inside Fubini. Learned λ at fixed σ would then need only hyperprior mass ≥ e^{−nε²} near the oracle: a fixed-b₀ Gamma fails this, a polynomial tail passes (VP). Not pursued now.
- **Positioning (HQ decision).** If Theorem A is proved, B becomes the warm-up proposition, kept for its distinct conclusions (wider window, possible learned-λ corollary). If A is not proved, B is the main theorem, and moment-free contraction is a conjecture supported by the t₂ and Cauchy simulations.
  - *Referee question "why exponential moments for a quantile method?":* the honest answer is that the assumption belongs to the proof technique.
- **Odds (advisors), for Δ²ₙ at one oracle tuning, up to logs:** Astra 95% at n^{−3/4} and 85% at n^{−5/6}; Fable 90% and 80%. The remaining risk is on the prior side and in L6.
- **Status of the inputs.**
  - L2, L4, L5, L4q: advisor-checked.
  - L4q-M: accepted with fixes (applied).
  - L3: numerical check PASSED (NOTS job 2857810); self-checked once its fixes are committed.
  - L6: draft, self-checked.
  - L8′: numerical check PASSED (NOTS job 2857877).
  - **New here:** Propositions 1 and 2, and the assembly.
