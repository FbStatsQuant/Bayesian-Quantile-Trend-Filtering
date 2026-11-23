# Light-tail fallback theorem ("Theorem B"): VP opinion

*Fable (VP / senior advisor), 2026-11-22. Proof steps below are checked at sketch level (inequalities derived by hand, one numerical check); not a written proof.*

**Verdict: ADOPT WITH CHANGES.** It closes, with a two-page proof. But it does not touch the σ restriction, and the threshold on σ can get worse.

## 1. The assumption

What the global route uses is exactly one per-coordinate condition on the pair (law, σ):

**(EM)** there is b > 0 with sup_{i,n} E exp{−ωXᵢ(δ)} ≤ exp{−bω·min(δ², |δ|)} for **all** δ ∈ ℝ.

State Theorem B under (A1)–(A3) + (EM), and give the checkable sufficient condition as a proposition:

**(A5)** sup_{i,n} E exp{c|yᵢ − θ\*ᵢ|} ≤ K, and σ ≥ σ̄_B(τ, L, f, f̄, c, K).

- A uniform ψ₁ bound is the same thing as (A5); nothing weaker works. (EM) **forces** right-tail rate > τ/σ and left-tail rate > (1−τ)/σ, i.e. noise tails lighter than the working ALD's. Otherwise a constant shift through the flat c gives E₀N(ℝⁿ) = ∞.
- (EM) also forces σ > σ̄. So σ has three constraints: local (σ̄), tail (max(τ, 1−τ)/c), and mid-range.

## 2. What it removes

- **Gone:** L7, L9-a, L9-c, L10. L8′ is replaced by its global version. L3, L4, L4q, L5, L6 are unchanged.
- **Window:** a₀ is no longer set by L10; the lower end comes from the prior side only.
- **Loss:** Theorem B is in Δ²ₙ. Squared loss is no longer automatic. Sketch: Fubini on {λ‖u − u\*‖₁ > Tm} gives TV⁽³⁾(δ) ≲ n³/λ, then interpolation (now non-circular) gives ‖δ‖∞ → 0 for λ ≥ n^{3/2+}. Exponents only.
- **No help for A⁺ or for σ ≥ (1+η)σ̄.** The threshold belongs to the expected numerator. L8-b still needs localization, hence L10.
- **Possible bonus (unchecked):** the numerator bound is free of λ, so a hyperprior on λ integrates inside Fubini. Learned λ at fixed σ then needs only hyperprior mass ≥ e^{−nε²} near the oracle. A fixed-b₀ Gamma fails that; a polynomial tail passes.

## 3. Does it close? Yes

1. **Fubini on all of ℝⁿ.** E₀N(E) = ∫_E ∏ᵢ E e^{−ωXᵢ(δᵢ)} dν ≤ ∫_E e^{−bω·nΔ²ₙ(δ)} dν.
2. **Flat part.** Σᵢ min(δᵢ², |δᵢ|) ≥ ½·min(‖δ‖₂², ‖δ‖₂), and ‖δ‖₂ ≥ ‖c − c₀(u)‖₂ since N is orthonormal. So ∫ e^{−(bω/2)nΔ²ₙ} dν ≤ C₃(bω) := ∫_{ℝ³} e^{−(bω/4)min(|c|², |c|)} dc, **free of n, λ, u and θ\***.
3. **Numerator.** E₀N{Δ²ₙ > Mε²} ≤ C₃·e^{−(bω/2)Mnε²}. With L6: E₀Πₙ(Δ²ₙ > Mε² | y) ≤ C₃(ε√n)^{−3}·exp{−[bM/2 − (1.44C₁+1) − C_pr/ω]·ωnε²} + 1.44/(nε²).
4. **(A5) ⇒ (EM).** For δ > 0, W = clip(Z, 0, δ): log E e^{−ωX} ≤ −ωm(δ) + ½ω²E[W²e^{ωW}]. For ω ≤ c/2, E[W²e^{ωW}] ≤ C_V·min(δ², 1). L2 gives m(δ) ≥ c₀·min(δ², δ), moment-free. So b = c₀/2 once ω ≤ min(c/2, c₀/C_V). Use L8′(b) on |δ| ≤ Δ₀ to keep the sharp local constant.

**Numerical check of the exact global threshold** (ω_glob ÷ local ω̄; δ up to 40; f = density at the quantile; τ ∈ {½, ¾, 0.9}):
- Gaussian, Laplace, logistic, uniform: ≥ 0.993, i.e. 1 within grid tolerance. At 0.9·ω_glob, b = 0.005–0.025, so M is large.
- Mixture 0.9N(0, 0.1²) + 0.1N(0, 3²): 0.125, 0.076, 0.063. **The "covered" mixture row fails globally**: σ̄_B ≈ 3.6·σ₀ at τ = ½.

## 4. Worth stating?

Yes, but position it by what it adds, not as a weaker copy of A.
- **If A is proved:** A is the main theorem. B becomes a proposition or the warm-up proof, kept only for its distinct conclusions (wider window, learned-λ corollary).
- **If A is not proved by submission:** B is the main theorem, and moment-free contraction is a stated conjecture backed by the t₂ and Cauchy simulations.
- **Referee:** "why exponential moments for a quantile method?" Answer honestly: the assumption belongs to the proof technique. B covers none of the paper's runs as executed: t₂ and Cauchy are excluded, and Gaussian at σ₀ < σ̄ is excluded exactly as in A.

## 5. Recommendation and order

**Adopt with changes:** (i) hypothesis (EM), with (A5) + σ̄_B as the sufficient condition; (ii) keep σ ≥ (1+η)σ̄ and say B does not relax it; (iii) correct the mixture row; (iv) state B in Δ²ₙ, squared loss as a corollary for λ ≥ n^{3/2+}.

**Order: B first, before L10.** It needs only one new half-page lemma (step 4) plus step 2; everything else is reused by A, so nothing is wasted. Then L10 by the two-stage route. My odds stand: 90% at n^{−3/4}, 80% at n^{−5/6}; the remaining risk is L3, L4q and L6 only.
