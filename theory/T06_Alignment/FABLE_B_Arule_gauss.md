# A-rule on the heteroscedastic Gaussian design at τ = ½: lower containment of λ

*Fable, research sub-agent for Theory, 2026-11-23. Pure mathematics, by hand; design constants evaluated with a calculator; no simulation. **Not audited.***

**Setting.** λ ~ Gamma(1, b_n), b_n = 1/(5500·(n/500)^{5/2}) = 1016.4·n^{−5/2}, untruncated; σ ~ IG(0.1, 0.1) (write (a, b) = (0.1, 0.1)); noise ε_i ~ N(0, s(u_i)²), s(u) = (1 + u²)/4, u_i = i/n; τ = ½, so ρ_τ(z) = |z|/2 and Q(θ) = ½‖y − θ‖₁. m = n − 3, t := τ(1−τ) = ¼.

**Labels.** PROVED = fully written here from elementary facts or audited statements. SKETCH = argument given, steps open. CONJECTURE = heuristic only.

## 0. Verdict

**The goal is not reached. At τ = ½ the statement Π(λ < Λ₋ | y) → 0 with Λ₋ → ∞ is not proved, for any diverging Λ₋.** What is proved is a constant floor, an exact reduction of the goal to one measurable quantity (the evidence slope κ(ℓ)), and the reason why no argument of the kind used so far can give its sign.

| # | Claim | Status |
|---|---|---|
| 1 | Design constants in closed form: σ₀ = √(2/π)/6 = 0.13298; R = √20·√(2/π)/3 = 1.18942; σ₀/(2τ(1−τ)R) = 1/√20 = 0.2236; local ratio β(u) := σ̄(u)/σ₀ = (3π/2)·s(u) ∈ [1.178, 2.356] | PROVED (§1) |
| 2 | With the A-rule prior, my bound C₂n is useless: the prior suppresses {λ < Λ} only by a power of n | PROVED (§2) |
| 3 | The expected likelihood ratio is > 1 near the truth at **every** design point (β(u) > 1 everywhere). So (EM) fails at σ₀ and no Fubini-type numerator bound can have the right sign | PROVED (§2) |
| 4 | Exact identities: the λ-posterior is ∝ p(ℓ)·E(ℓ); ℓ·∂_ℓ log E(ℓ) = κ(ℓ) := m − ℓ·E_ℓ‖Dθ‖₁; κ(ℓ) = (n + a)·E_ℓ[⟨∇Q(θ), θ − q⟩/(b + Q(θ))] − 3; E_post[λ] = (1 + E_post[m − λ‖Dθ‖₁])/b_n | PROVED (§3) |
| 5 | **Reduction.** If κ(ℓ) ≥ 0 on [ℓ₀, 2Λ_w] and κ(ℓ) ≥ κ̲_n on [Λ₋, Λ_w] with κ̲_n·log(Λ_w/Λ₋) → ∞, then Π(ℓ₀ ≤ λ < Λ₋ | y) → 0 | PROVED (§4) |
| 6 | Constant floor: Π(λ < 3.76(1 − η) | y) → 0 | PROVED given Proposition R of `FABLE_A_noFloor.md` (unaudited) (§5) |
| 7 | κ(ℓ) ≈ (π/18)·(6 − β_eff)·k_eff(ℓ) with k_eff ≍ n·ℓ^{−1/3} and β_eff ≈ 1.5; hence κ > 0, λ concentrates at min{(c·n/b_n)^{3/4}, oracle} and Λ₋ ≍ n^{5/2} holds | **CONJECTURE** (§6). This is the whole gap |
| 8 | τ = 0.25: same status, smaller margin. τ = 0.05: β(u) crosses 6 at u > 0.89; the net proxy sign is still positive. The net sign flips between τ = 0.96 and 0.97 | CONJECTURE (§7) |

**Why it does not close.** The prior Gamma(1, b_n) has shape 1. It cannot push λ up; only the data can. The data do so only if the marginal evidence E(ℓ) increases in ℓ, and that is a statement about the **sign** of a difference of two terms of the same order (fit gain against Occam cost). Every tool in the chain so far (Cauchy–Schwarz in C2, Hoeffding in Lemma N, the crude constants of L3⁻/L3⁺) loses constant factors, which is harmless for rates and fatal for a sign. A proof needs a realized evidence expansion exact to 1 + o(1); the three lemmas it would require are listed in §6.

---

## 1. The design — PROVED

- *Scale.* E|ε_i| = s(u_i)√(2/π), so σ₀,ₙ = n⁻¹ΣE ρ_τ(ε_i) = ½√(2/π)·n⁻¹Σs(u_i) → ½√(2/π)·∫₀¹s = √(2/π)/6 = **0.13298** (∫₀¹(1 + u²)/4 du = 1/3).
- *Roughness of the noise.* ε_j − 3ε_{j+1} + 3ε_{j+2} − ε_{j+3} is N(0, 20·s²(u_j)(1 + O(1/n))), so R = n⁻¹ΣE|(Dε)_j| → √20·√(2/π)/3 = **1.18942**.
- *Necessary condition.* σ₀/(2tR) = (1/6)/(√20/6) = **1/√20 = 0.2236**, exactly, for every scale function s. (Matches `noFloor_necessary.out`: 0.224.)
- *Local Occam ratio.* The density of ε_i at its median is f(u) = 1/(s(u)√(2π)), so σ̄(u) := t/f(u) = s(u)√(2π)/4 and

  **β(u) := σ̄(u)/σ₀ = (3π/2)·s(u)**, from 1.178 at u = 0 to 2.356 at u = 1; ∫₀¹β = π/2 = 1.571.

  The value 2.356 quoted for the design is the maximum over u.
- *Class membership.* (A1); full (A2) with f = 1/(0.5√(2π))·e^{−L²/(2·0.0625)}, f̄ = 1/(0.25√(2π)); uniform integrability; d ≤ σ₀,ₙ ≤ B. (A3) depends on the truth (S or VS), not on the noise.

For Gaussian noise at a general level τ the local ratio is β_τ(u) = 2β_max(τ)·s(u), with β_max(τ) the tabulated σ̄/σ₀: 2.785 (τ = 0.25), 6.698 (0.05), 20.9 (0.01). Its average over u is (2/3)β_max(τ).

---

## 2. Why the available bounds give nothing here — PROVED

**(a) The prior does not help.** P_p(λ < Λ) = 1 − e^{−b_nΛ} ≥ b_nΛ/2 for b_nΛ ≤ 1. So −log P_p(λ < Λ) ≤ log(2/(b_nΛ)) = O(log n) for every polynomial Λ. Lemma SF1 of `FABLE_B_softfloor.md` needs −log P_p(λ < Λ) ≥ (C₂ + η)n. The bound C₂n is therefore of no use with shape 1; it only says how far the prior is from being able to do the job.

**(b) The expected likelihood ratio has the wrong sign.** For the Laplace working likelihood at scale σ = 1/ω and a coordinate with density f_i at the quantile,

  E₀e^{−ωX_i(δ)} = 1 + (ωδ²/2)(ωt − f_i) + o(δ²)  (δ → 0),

so it is < 1 near 0 only if f_i ≥ ωt, i.e. σ ≥ σ̄_i (this is the "iff" recorded in Theorem B's scope and in the audit, finding 5). At σ = σ₀ this reads β(u_i) ≤ 1. By §1, β(u) ≥ 1.178 for every u. Hence at the learned scale the expected likelihood ratio exceeds 1 in a neighbourhood of the truth **at every design point**, (EM) fails for this design at σ₀, and Theorem B's route (numerator in expectation) is closed. Any bound obtained by taking E₀ inside the prior integral without tempering has exponent +ω²t·n‖δ‖²ₙ(1 − 1/β)/2 > 0.

**(c) Tempering loses the sign.** Hölder/Cauchy–Schwarz splits (as in C2) or a tempered exponent γ < 1/β restore a negative expectation, but at the price of constant factors in the comparison "fit gain against Occam cost". With β up to 2.36 the true margin in the proxy is the factor (1 − β/6) ∈ [0.61, 0.80] (§6); the constants lost by those devices are ≥ 2. So they cannot decide the sign.

---

## 3. Exact identities — PROVED

Let E(ℓ) be the joint evidence at tuning ℓ with σ integrated:

  E(ℓ) := ∫∫σ^{−n}e^{−Q(θ)/σ}IG(dσ)·dν_ℓ(θ) = c_IG·J_n·(ℓ/2)^m∫F(θ)e^{−ℓ‖Dθ‖₁}dθ,  F(θ) := (b + Q(θ))^{−(n+a)},

and let E_ℓ[·] denote the posterior of θ (σ learned) at fixed tuning ℓ, with density ∝ F(θ)e^{−ℓ‖Dθ‖₁}.

**(I1) Posterior of λ.** Π(λ ∈ dℓ | y) ∝ p(ℓ)·E(ℓ)dℓ, p(ℓ) = b_ne^{−b_nℓ}. (The factor λ^m of the model is the normalization of Π_λ.)

**(I2) Virial identity.** ℓ·∂_ℓ log E(ℓ) = m − ℓ·E_ℓ‖Dθ‖₁ =: **κ(ℓ)**. *Proof.* Differentiate (ℓ/2)^m e^{−ℓ‖u‖₁} under the integral; domination by e^{−ℓ′‖u‖₁}(1 + ‖u‖₁) for ℓ′ < ℓ. ∎ Hence E(ℓ)/E(ℓ′) = exp(−∫_ℓ^{ℓ′}κ(s)ds/s) for ℓ < ℓ′.

**(I3) Scaling identity.** For every quadratic sequence q,

  **κ(ℓ) = (n + a)·E_ℓ[⟨∇Q(θ), θ − q⟩/(b + Q(θ))] − 3 = E_ℓ[σ⁻¹⟨∇Q(θ), θ − q⟩] − 3.**

*Proof.* For s > 0, ∫F(θ)e^{−ℓ‖Dθ‖₁}dθ = sⁿ∫F(sϑ)e^{−ℓs‖Dϑ‖₁}dϑ. Q is convex and piecewise linear, so s ↦ F(sϑ) is locally Lipschitz and differentiation under the integral at s = 1 is justified; it gives 0 = n − (n + a)E_ℓ[⟨∇Q(θ), θ⟩/(b + Q)] − ℓE_ℓ‖Dθ‖₁. The same argument with θ = ϑ + s·q (which leaves ‖Dθ‖₁ unchanged) gives E_ℓ[⟨∇Q(θ), q⟩/(b + Q)] = 0. The second form uses E[σ⁻¹ | θ, y] = (n + a)/(b + Q(θ)). ∎

Here (∇Q(θ))_i = 1{y_i < θ_i} − τ for θ_i ≠ y_i. At τ = ½ and with δ = θ − θ\*, Z = y − θ\*:

  ⟨∇Q(θ), δ⟩ = ½Σ_iδ_i·sign(δ_i − Z_i) = −⟨ψ, δ⟩ + R′(δ),  R′_i(δ) := |δ_i|·1{Z_i strictly between 0 and δ_i} ≥ 0,

with ψ_i = ½ − 1{Z_i < 0}. So for a quadratic truth, **κ(ℓ) + 3 = E_ℓ[σ⁻¹(R′(δ) − ⟨ψ, δ⟩)]**: the evidence grows with ℓ exactly when, under the posterior at ℓ, the curvature term R′ outweighs the correlation of the fit with the signs of the noise. For a non-quadratic truth add E_ℓ[σ⁻¹⟨∇Q(θ), θ\* − q⟩], the bias term (negative, and negligible for ℓ well below the oracle — SKETCH).

**(I4) Mean identity.** Since λ | θ, y ~ Gamma(m + 1, b_n + ‖Dθ‖₁), E[λ(b_n + ‖Dθ‖₁) | θ] = m + 1, so

  **b_n·E_post[λ] = 1 + E_post[m − λ‖Dθ‖₁].**

The posterior mean of λ is (1 + average evidence slope)/b_n.

**(I5) Convexity bound (too weak here).** ⟨∇Q(θ), δ⟩ ≥ ℛ(δ), so for a quadratic truth κ(ℓ) ≥ E_ℓ[σ⁻¹ℛ(δ)] − 3. This has the right sign only if posterior draws fit the data worse than the truth on average. In the proxy E[ωℛ] per mode is s_r[½ − β(1 − s_r/2)], negative for β > 1: posterior draws overfit, and (I5) cannot be used.

---

## 4. Reduction of the goal to the sign of κ — PROVED

**Lemma (reduction).** Let 0 < ℓ₀ < Λ₋ < Λ_w with 2b_nΛ_w ≤ 1. Suppose that on a data event Ω_κ:
- (K1) κ(ℓ) ≥ 0 for all ℓ ∈ [ℓ₀, 2Λ_w];
- (K2) κ(ℓ) ≥ κ̲ ≥ 0 for all ℓ ∈ [Λ₋, Λ_w].

Then on Ω_κ: **Π(ℓ₀ ≤ λ < Λ₋ | y) ≤ e·(Λ₋/Λ_w)^{κ̲+1}.**

*Proof.* By (I2) and (K1), E is nondecreasing on [ℓ₀, 2Λ_w]; by (K2), E(Λ₋) ≤ E(Λ_w)·(Λ₋/Λ_w)^{κ̲}. By (I1), with p ≤ b_n and p ≥ b_ne^{−1} on [Λ_w, 2Λ_w]:

  Π(ℓ₀ ≤ λ < Λ₋ | y) ≤ ∫_{ℓ₀}^{Λ₋}pE/∫_{Λ_w}^{2Λ_w}pE ≤ b_nΛ₋E(Λ₋)/(b_ne^{−1}Λ_wE(Λ_w)) ≤ e·(Λ₋/Λ_w)^{κ̲+1}. ∎

**What this asks for.** With Λ_w = 1/(2b_n) = 2750·(n/500)^{5/2} and Λ₋ = Λ_w/K:
- the **sign** κ ≥ 0 on the whole range, and
- a **tiny size**: κ̲·log K → ∞. For Λ₋ ≍ n^{5/2} (K fixed) any κ̲_n → ∞ suffices; for Λ₋ = n^{1/2}·polylog, a constant κ̲ > 0 suffices because log K ≍ log n.

Since the conjectured size is κ(ℓ) ≍ n·ℓ^{−1/3} ≥ n^{1/6}, the size is not the difficulty. **The sign is.**

**κ is measurable.** κ(ℓ) = m − ℓ·E_ℓ‖Dθ‖₁ is a posterior mean in the fixed-λ sampler (σ learned). A grid of fixed-λ chains gives the evidence slope directly, with no evidence computation. See §8.

---

## 5. What is proved for this design: a constant floor

Proposition R (`FABLE_A_noFloor.md` §3, unaudited; it uses the weak prior Gamma(1, b₀) and applies verbatim with b_n): Π(‖Dθ‖₁ > (1 + η)nσ₀/(2t) | y) → 0. Since λ | θ ~ Gamma(m + 1, b_n + ‖Dθ‖₁) and b_n → 0,

  **Π(λ < (1 − η)·2t/σ₀ | y) → 0,  2t/σ₀ = 3.76.**

Together with §1 (ratio 1/√20 < 1) the full-interpolation corner is excluded: Q(θ) ≥ q₁n and σ ≥ q₁/2 with posterior mass → 1. So ℓ₀ in §4 can be any constant below 3.76. **From this constant to any diverging sequence nothing is proved.**

---

## 6. The gap: the sign of the evidence slope — CONJECTURE

**Proxy computation.** Replace the log-likelihood by ω[⟨ψ, δ⟩ − ½Σf_iδ_i²] and the Laplace prior by its Gaussian twin with precision P_ℓ. With F := ω·diag(f_i) and C := (F + P_ℓ)^{−1}, taking the data expectation of (I3) (Var ψ_i = t):

  κ(ℓ) ≈ tr(CF) − ω²t·tr(C·P_ℓ·C).

In the homogeneous case, with s_r = ρ_r/(1 + ρ_r), ρ_r = (k_eff/r)⁶: κ ≈ Σs_r − βΣs_r(1 − s_r) = k_eff·[π/3 − β·(π/3)(1 − 5/6)] = **(π/18)·(6 − β)·k_eff(ℓ)**, k_eff ≍ n·ℓ^{−1/3}. (∫₀^∞dx/(1+x⁶) = π/3, ∫₀^∞dx/(1+x⁶)² = 5π/18.) This agrees with `FABLE_A_noFloor.md` §5 (log E ≈ −(π/6)(6 − β)k_eff).

For this design the score is homoscedastic (Var ψ_i = ¼ for all i) and only the curvature f(u) varies. A locally homogeneous approximation gives κ ≈ (π/18)·∫(6 − β(u))·k_loc(u)du, with weights k_loc(u) ∝ f(u)^{1/6} that vary by a factor 2^{1/6}. So the effective ratio is close to ∫β = 1.571, the margin factor 1 − β/6 lies in [0.61, 0.80] pointwise, and

  **κ(ℓ) ≈ 0.77·k_eff(ℓ) > 0.**

**Consequences if the conjecture holds.**
- (K1), (K2) hold; by §4, Π(λ < Λ₋ | y) → 0 for every Λ₋ = o(Λ\*), Λ\* the maximizer of p(ℓ)E(ℓ).
- Fixed point of b_nℓ = κ(ℓ) with κ = c·n·ℓ^{−1/3}: ℓ = (c·n/b_n)^{3/4} ∝ n^{21/8} for the A-rule. This is above n^{5/2}, so for a truth with V > 0 the bias term of (I3) caps λ at the oracle order n^{5/2}/V: **the A-rule would self-tune to the oracle**, and Λ₋ ≍ n^{5/2} would hold with a V-dependent constant. At n = 500 the memo's fixed-point formula gives (0.27·n/b_n)^{3/4} ≈ 2.5·10⁴, close to the S oracle 3.6·10⁴.

**What a proof needs** (none of these exists; each is a new lemma):
1. *Uniform realized control of the curvature term.* sup over the localized body of |R′(δ) − E R′(δ)| = o(k_eff). The envelope bound of C1 is too large by a power of n; one needs a variance-sensitive chaining bound using that R′_i is supported on {|Z_i| ≤ ‖δ‖∞}. Available only where sup-norm localization holds (ℓ ≫ n^{21/11}).
2. *A Gaussian comparison for the Laplace prior that keeps the constant,* i.e. the posterior second moments of δ under the Laplace prior to 1 + o(1). L3⁻ and L3⁺ bracket the small-ball exponent only within a factor 117·75.
3. *Concentration of the score quadratic form* ω²ψᵀCψ around ω²t·tr(C) (Hanson–Wright), uniformly in ℓ.
4. *The range ℓ ≪ n^{21/11},* where there is no sup-norm localization and the quadratic approximation of the likelihood is not justified. Here even the heuristic is weaker (k_eff/n is not small for ℓ = O(1)). The goal Λ₋ ≫ n^{1/2}·polylog sits entirely in this range, so it is **not** easier than Λ₋ ≍ n^{5/2}: by §4 both need the sign on [ℓ₀, Λ_w].

---

## 7. Other levels (Gaussian design) — CONJECTURE

By §1, β_τ(u) = 2β_max(τ)·s(u), average (2/3)β_max(τ).

| τ | β(u) range | average | proxy margin 1 − β̄/6 | Reading |
|---|---|---|---|---|
| 0.50 | 1.18 – 2.36 | 1.57 | 0.74 | positive everywhere |
| 0.25, 0.75 | 1.39 – 2.79 | 1.86 | 0.69 | positive everywhere |
| 0.05, 0.95 | 3.35 – 6.70 | 4.47 | 0.26 | β(u) > 6 for u > 0.89 (s > 0.448): the evidence locally rewards roughness on the noisiest 11% of the design; the net sign is still positive because λ is global |
| 0.04, 0.96 | 3.88 – 7.76 | 5.17 | 0.14 | net positive, thin |
| 0.03, 0.97 | 4.71 – 9.43 | 6.29 | −0.05 | **net negative**: no growing fixed point |
| 0.01, 0.99 | 10.5 – 20.9 | 13.9 | −1.3 | negative |

What changes away from τ = ½:
- **τ = 0.25:** nothing structural. The identities of §3 hold for every τ (with ψ_i = τ − 1{Z_i < 0} and the same R′); the constant floor is 2t/σ₀ = 0.375/0.10593 = 3.54; the margin is slightly smaller.
- **τ = 0.05:** the necessary-condition ratio is still fine (0.304) and the constant floor is 0.095/0.03438 = 2.76, but the Occam margin is small and not uniform in u. A proof would have to work with the u-averaged quantity, so even the proxy requires the heteroscedastic (non-diagonal) computation of §6, not the homogeneous formula. If it holds, λ grows but with a constant about three times smaller than at τ = ½.
- **Beyond τ ≈ 0.965** the proxy predicts that the A-rule's λ does not follow the n^{21/8} or oracle law at all.

---

## 8. Flags

- **Status of the deliverable.** The requested proof is not delivered. The rigorous content is §1–§5; §6–§7 are heuristic.
- **Pilot that would test the conjecture directly (UNTESTED).** For the Gaussian design with the S and VS truths, n ∈ {500, 2000}, τ ∈ {0.5, 0.25, 0.05, 0.97}: run the fixed-λ sampler (σ learned) on a log-grid of about 10 values of ℓ between 4 and 2/b_n, and record κ̂(ℓ) = m − ℓ·mean(‖Dθ‖₁). Predictions: κ̂ > 0 and κ̂ ∝ ℓ^{−1/3} at τ = 0.5 and 0.25, with κ̂(0.25)/κ̂(0.5) ≈ 0.69/0.74 = 0.93 at equal ℓ (proxy margins); about a third at 0.05; negative or flat at 0.97. (The absolute scale of k_eff is not fixed by the proxy, so only signs, the exponent −1/3 and ratios across τ are predictions.) Check also (I4) on the full A-rule chain: b_n·mean(λ) = 1 + mean(m − λ‖Dθ‖₁), an exact identity that doubles as a sampler diagnostic. Cost: 10 short fixed-λ chains per cell. Nothing goes to HQ on this before the pilot.
- **The proxy constants** (0.77, the crossing at τ ≈ 0.965) come from a Gaussian-prior, quadratic-likelihood calculation with a locally homogeneous approximation. They are indicative only.
- **Dependence on unaudited material.** §5 uses Proposition R of `FABLE_A_noFloor.md`.
- **Relation to Fable A's general condition.** The reduction of §4 and the identities of §3 are design-free; they may be the right form for the general condition in `FABLE_A_Arule_lowertail.md` (a hypothesis on κ(ℓ), which is checkable by simulation), but I have not read that file.

---

## Theory response (2026-11-23, 15:00 CT)

**Status: NEGATIVE RESULT, logged. The goal is not reached.** At τ = ½ there is no diverging lower floor for λ. The rigorous content is §1–§5 and is not audited. Theory re-derived the following:
- **§1 β(u) = (3π/2)s(u) ∈ [1.178, 2.356]: HOLDS.** We have σ̄(u) = ¼√(2π)s(u) and σ₀ = ½√(2/π)·(1/3), so the ratio is (π/2)·s(u)/(1/3).
- **(I2) virial identity: HOLDS.**
- **(I3) scaling identity: HOLDS.** It follows from the dilation θ → sθ at s = 1, using ∇log F = −(n+a)∇Q/(b+Q) and quadratic translation invariance.
- **(I4) mean identity: HOLDS.** We have λ | θ ~ Gamma(m+1, b_n + ‖Dθ‖₁).
- **§4 reduction lemma: HOLDS.** p ≤ b_n on the numerator range and p ≥ b_ne^{−1} on [Λ_w, 2Λ_w].
- **§5 depends on Proposition R, which is unaudited**, so it is labelled as such.

**Value for Tuesday:**
1. **Sign, not size.** The reduction makes the A-rule lower tail a question of the *sign* of a measurable posterior mean, κ(ℓ) = m − ℓ·E_ℓ‖Dθ‖₁, on [ℓ₀, Λ_w]. It also shows that Λ₋ ≍ n^{1/2} is no easier than n^{5/2}.
2. **Same gap as Fable A.** The proxy threshold β ≈ 6 matches Fable A's independent derivation (`FABLE_A_Arule_lowertail.md` §7). Both notes localize the gap in the same place: constant-exact realized evidence, plus the range ℓ ≪ n^{21/11}.
3. **A cheap data test.** The κ̂(ℓ) pilot in §8 tests the conjecture directly. It is UNTESTED, and nothing goes to Felipe on it. Theory will request it from Engineering with a cost estimate.
