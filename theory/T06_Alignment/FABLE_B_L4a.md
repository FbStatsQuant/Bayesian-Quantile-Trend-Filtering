# L4a: λ ∈ [ℓ₀, n^{3/2}·polylog] — what can and cannot be proved today

*Fable, research sub-agent for Theory, 2026-11-23, written under a hard stop. By hand; no compute. **Not audited.** Inputs: `L4a_assumption.md`, `FABLE_B_L2_analysis.md` (Lemmas E1–E3, Proposition N-W), `FABLE_A_theoremH.md` (Theorem H and H-σ, audited), `FABLE_A_three_lemmas.md`, the end of `astra_gap4_sign.md`. I did not read `FABLE_A_gap4.md` or `FABLE_A_L4b.md` beyond what the task message says about them.*

**Labels.** PROVED = fully written here from elementary facts or audited statements. SKETCH = argument given, a step open. CONJECTURE = heuristic.

## 0. Verdict

**L4a is not proved, and its λ-range is not shrunk.** I could not exclude any growing sub-range [ℓ₀, ℓ₀·polylog] or [ℓ₀, n^{c}]. What this note contributes is: the exact form and size of what must be shown; two exact inequalities that are the right tools; an explanation of the n^{3/2} barrier that points to one specific missing lemma; and the status of the hybrid lead and of its two risks.

| # | Claim | Status |
|---|---|---|
| 1 | L4a follows from an evidence inequality (L4a-E) at scales near σ₀ only, with a required size of only e^{−C·n^{1/6}}·n^{−2} below the benchmark | PROVED given Theorem H-σ and the benchmark denominator (§1) |
| 2 | **Fractional comparison:** w.p. ≥ 1 − e^{−a}, log p(Y) ≤ log f(Y) + α⁻¹·log ρ_α(f, p) + a/α, ρ_α = ∫f^{1−α}p^{α} | PROVED (§2) |
| 3 | So L4a-E is implied by an affinity bound (AFF): the model at (s, ℓ) is Rényi-further from the truth than the benchmark model is Kullback-far, by c·n^{−5/6} per observation | PROVED reduction (§2); (AFF) itself is open |
| 4 | **Low-mode elimination:** Z̃ ≤ E_V[S(V)·E(Ψ(δ_R) \| V)], with S(V) the explicit conditional sup-density of the d low modes and Ψ a log-concave flat integral over a (d+3)-dimensional subspace | PROVED (§3) |
| 5 | For a Gaussian difference prior the inequality decouples exactly; for the Laplace prior a decorrelation step between S(V) and the high modes is missing | PROVED / open (§3) |
| 6 | The n^{3/2} barrier is the leverage bound ‖δ‖∞ ≤ C·d/√n on the low-mode subspace; typical posterior draws have ‖δ‖∞ ≈ √(d·log n/n). A posterior (not worst-case) sup-norm bound would move the barrier to ℓ ≫ polylog | PROVED observation + CONJECTURE (§4); **NEW LEMMA NEEDED** |
| 7 | Hybrid lead: heuristic threshold β ≲ 4.2; risk (ii) (sparse kinks) reduces to a condition on constants; risk (i) (conditional structure) is item 5 | CONJECTURE (§5) |
| 8 | No bound obtained by comparing with the true density through a plain Markov step can pass a constant ℓ₀ | PROVED for the bound of `FABLE_B_L2_analysis.md` (§6 there, as restricted by the audit) |

---

## 1. What must be shown — PROVED reduction

**Evidence form.** With E(ℓ) the σ-integrated evidence, Π(λ ∈ A | y) = ∫_A p_n(ℓ)E(ℓ)dℓ/∫p_nE, p_n(ℓ) = b_ne^{−b_nℓ}, b_n = 1016·n^{−5/2}.

- *Prior factor.* P_{p_n}(λ ≤ n^{3/2}(log n)^{c}) ≤ 1016·(log n)^{c}/n. The prior helps by a factor 1/n, no more.
- *Denominator.* On the window J = [κn^{5/2}, 2κn^{5/2}] the evidence is ≥ benchmark × e^{−C_J·n^{1/6}(log n)^{1/6}} (V2T Step 3, as used in Theorem U).
- *Scales.* Theorem H-σ (audited) applies to the posterior conditioned on λ ≥ Λ_a for any Λ_a ≫ polylog(n), and gives σ/σ₀,ₙ → 1 there. Hence Π(λ ≥ Λ_a, |σ/σ₀ − 1| > ε₀ | y) → 0 for every fixed ε₀: **on the L4a range above polylog(n), only scales s ∈ σ₀(1 ± ε₀) matter.**
- *Theorem H also bounds the evidence from above there:* on its event, for ℓ ≥ Λ_a and ω in a compact, Z̃_ω(ℓ) ≤ n^{C}·exp{C·n·r_a²}, n·r_a² ≍ n·Λ_a^{−2/7}·polylog (the Huber body has ν̄-mass ≤ V₃R_c³ and −ℛ ≤ sup_{K_H}|ℛ − M| on it; the cones are negligible). So the evidence in the L4a range can exceed the benchmark by at most e^{O(n·ℓ^{−2/7}polylog)}. This is the right order of magnitude (the conjectured truth is e^{−c·nℓ^{−1/3}}) but the wrong sign.

**Sufficient condition (L4a-E).** With probability → 1, for all s ∈ σ₀(1 ± ε₀) and all ℓ ∈ [Λ_a, n^{3/2}(log n)^{c}]:

  **Z̃_s(ℓ) ≤ n^{−2}·exp{−2C_J·n^{1/6}(log n)^{1/6}}.**

Together with `FABLE_B_L2_analysis.md` on [ℓ₁, ℓ₀] this gives L4a, **except for the stretch [ℓ₀, Λ_a] between a constant and polylog(n)**, where Theorem H is not available and neither scale localization nor any evidence bound beyond Proposition N-W is proved.

**Size against sign.** The conjectured value of log Z̃ in the range is −c·n·ℓ^{−1/3} ≤ −c·n^{1/2}/polylog. The required size is n^{1/6}·polylog. So there is a polynomial amount of room in size; the whole difficulty is the sign, as for κ(ℓ).

---

## 2. Tool 1: the fractional comparison — PROVED

**Lemma F1.** Let Y have density f, let p be any probability density, α ∈ (0, 1], and ρ_α(f, p) := ∫f^{1−α}p^{α} ≤ 1. Then for a > 0, with probability ≥ 1 − e^{−a}:

  **log p(Y) ≤ log f(Y) + α⁻¹·log ρ_α(f, p) + a/α.**

*Proof.* P(p(Y)/f(Y) > e^{−b}) ≤ e^{αb}·E[(p(Y)/f(Y))^{α}] = e^{αb}ρ_α. Take αb = −log ρ_α − a. ∎

α = 1 is the Markov step of Lemma E2 (ρ₁ = 1). For α < 1 the term α⁻¹log ρ_α is −(1 − α)/α times a Rényi divergence, and it tends to −KL(f ‖ p) as α ↓ 0.

**Consequence for the evidence.** By Lemma E1-W, log Z(s, ℓ) = −n log t + log(det W/|det G|) + log p̃_{s,ℓ}(Q̃Wy), and by §8.3 of `FABLE_B_L2_analysis.md` the true density at the data is e^{−n·h̄ₙ + o(n)}. Hence, with probability → 1,

  n⁻¹log Z(s, ℓ) ≤ −log t − h̄ − 𝔇_α(s, ℓ) + a/(αn) + o(1),  **𝔇_α(s, ℓ) := −(αn)⁻¹·log ρ_α(f̃, p̃_{s,ℓ}).**

Since b\* = −log t − h̄ − Δ_KL, (L4a-E) holds at (s, ℓ) as soon as

  **(AFF)  𝔇_α(s, ℓ) ≥ Δ_KL + 3C_J·n^{−5/6}(log n)^{1/6} for some α with 1/(αn) = o(n^{−5/6}).**

For the pure-noise model (ℓ = ∞) the affinity factorizes: 𝔇_α(s, ∞) = avgᵢ[−α⁻¹log∫fᵢ^{1−α}q_s^{α}] → avgᵢKL(fᵢ ‖ q_s) ≥ Δ_KL as α ↓ 0. So (AFF) is the statement that **adding the prior's signal to the working noise moves the model away from the truth, in Rényi divergence, by more than c·n^{−5/6} per observation.** This is an information-theoretic form of L4a with no posterior in it.

**Why it is not proved.** The affinity is concave in p, so for the mixture p = ∫π(dg)q^{E}(· − g) Jensen gives a lower bound on ρ_α, which is the wrong direction. The standard remedy (partition the signal space and use (Σw_kX_k)^{α} ≤ Σw_k^{α}X_k^{α}) costs α⁻¹·log Σ_kw_k^{α}; with α ≲ ℓ^{−1/3}, as needed to recover Δ_KL to the required accuracy, this cost is of order n·log ℓ over the fitted modes and swamps the gain n·ℓ^{−1/3}. Eliminating the low modes by a sup-density bound instead (§3) avoids that cost for them, and leaves the high modes.

---

## 3. Tool 2: eliminating the low modes — PROVED inequality

Fix (ω, ℓ) and, for simplicity, a quadratic truth (u\* = 0). Z̃ = E_u∫e^{−ωℛ(Nc + A₀u)}dc. Let P_T ∈ ℝ^{d×n} have as rows the d lowest eigenvectors of A₀A₀ᵀ, g_T := P_TA₀u ∈ ℝ^d, and δ_R := (P⊥ − P_TᵀP_T)A₀u (the high modes). Let 𝒮 := range N ⊕ range P_Tᵀ (dimension d + 3) and

  **Ψ(x) := ∫_𝒮 e^{−ωℛ(a + x)}da**  (Lebesgue measure on 𝒮).

**Lemma F2.** With V the mixing variances of the Laplace prior (u | V ~ N(0, diag V)):
- (a) Given V and δ_R, g_T has a Gaussian density bounded by **S(V) := (2π)^{−d/2}·det(P_TDᵀ·diag(V)^{−1}·DP_Tᵀ)^{1/2}**.
- (b) **Z̃ ≤ E_V[S(V)·E(Ψ(δ_R) | V)].**
- (c) Ψ is a log-concave function on ℝⁿ.

*Proof.* (a) G := QA₀u is, given V, centred Gaussian on ℝ^m with precision (QA₀)^{−ᵀ}diag(V)^{−1}(QA₀)^{−1}, and (QA₀)^{−1} = DQᵀ because DQᵀQA₀ = DP⊥A₀ = I. The conditional law of a block of a Gaussian vector given the complementary block has precision equal to the corresponding diagonal block, here P_TDᵀdiag(V)^{−1}DP_Tᵀ. (b) Write A₀u = P_Tᵀg_T + δ_R, condition on (V, δ_R), bound the conditional density of g_T by S(V), and integrate (c, g_T) over ℝ³ × ℝ^d, which is the Lebesgue integral over 𝒮. (c) ℛ is convex, so e^{−ωℛ} is log-concave, and marginals of log-concave functions are log-concave (Prékopa). ∎

**Gaussian prior.** If the uⱼ were N(0, v₁) (V ≡ v₁), the modes are independent, S = ∏_{r≤d}(μ_r/(2πv₁))^{1/2} is a constant, δ_R is independent of g_T, and (b) reads **Z̃ ≤ S·E Ψ(δ_R)**: the low modes are removed at the exact price of the prior's density, and what remains is the flat-prior evidence of a (d+3)-dimensional quantile-regression model, averaged over an independent high-mode perturbation.

**Laplace prior: what is missing.** S(V) and δ_R are dependent through V, and E_V S(V) alone is delicate (E V^{−1} = ∞; only half-powers of V^{−1} are integrable). Lemma E3 handled the analogous unconditional quantity by AM–GM on the Cauchy–Binet expansion; here the factor E(Ψ(δ_R) | V) sits inside the expectation. A decorrelation inequality of the form E_V[S(V)·h(V)] ≤ C^{d}·S(v₁)·sup-or-average of h is needed. I expect a cost e^{O(d)}, which would be affordable (see §5), but I have no proof. **This is risk (i) of the hybrid lead, in its precise form.**

---

## 4. Where the n^{3/2} barrier comes from, and what would remove it

After Lemma F2 the central object is Ψ(x): a flat-prior evidence over the subspace 𝒮 of dimension d + 3, d ≍ θ·n·ℓ^{−1/3}.

- **Its Laplace approximation** is Ψ(0) ≈ (2π/(ωf))^{(d+3)/2}·exp{ω‖P_𝒮ψ‖²/(2f)} ≈ (2π/(ωf))^{d/2}·e^{β·d/2}, which is what the proxy uses. It requires the quadratic expansion of the check loss, i.e. Lemma 1's control of the remainder, on the part of 𝒮 that carries the integral: {a ∈ 𝒮 : ‖a‖₂² ≲ d/(ωf)}.
- **PROVED observation.** On that set the only deterministic sup-norm bound is the leverage bound: ‖a‖∞ ≤ max_i‖P_𝒮e_i‖₂·‖a‖₂ ≤ √(C·d/n)·‖a‖₂ (Lemma Lev-type), i.e. ‖a‖∞ ≲ d/√n. It tends to 0 only if d ≪ √n, which is **ℓ ≫ n^{3/2}**. This is the barrier in L4a's upper end.
- **But the bound is far from typical.** A vector of 𝒮 with squared norm d/(ωf) and no special alignment has coordinates of size √(d/n), and its sup-norm is ≈ √(d·log n/n), which tends to 0 whenever d ≪ n/log n, i.e. for **every ℓ ≫ polylog(n)**. The vectors that saturate the leverage bound concentrate their mass on O(n/d) coordinates; under the flat measure on 𝒮 weighted by e^{−ωℛ} they form a set of small mass.

**NEW LEMMA NEEDED (SUP).** For the log-concave measure on 𝒮 with density ∝ e^{−ωℛ(a + x)}, uniformly over the relevant x: the mass of {‖a − â‖∞ > C√(d·log n/n)} is ≤ n^{−C′}, and its centre â has ‖â‖∞ ≲ √(d·log n/n). Each coordinate a_i is a one-dimensional marginal of a log-concave measure, so it has exponential tails at the scale of its standard deviation; what is missing is a bound on that standard deviation of the right order (d/(nωf))^{1/2} **without** assuming the quadratic expansion it is meant to justify. A bootstrap (crude sup-norm → partial curvature → better variance → better sup-norm) is the natural route. I did not carry it out.

With (SUP), Lemma 1 would apply on the bulk of 𝒮 for all ℓ ≫ polylog(n), and the low-mode factor Ψ would be computable to 1 + o(1) in the exponent, which is the input the hybrid needs. This does not conflict with Astra's obstructions: those rule out pointwise (sup-over-body) sign arguments and monotonicity in ℓ; here the sign comes from an integral over 𝒮, which is posterior-averaged by construction.

---

## 5. The hybrid lead: status — CONJECTURE

**Bookkeeping (Gaussian-prior heuristics, per unit of κ = effective dimension).** Low modes r ≤ θκ through Lemma F2 with the Laplace approximation of Ψ: exponent −½Σ_{r≤θκ}[log ρ_r − log π − β] = −κ·[3θ·log(1/θ) + 3θ − (log π + β)θ/2]. High modes r > θκ: +(β − 1)·κ/(10θ⁵) to leading order. At θ = 1 the total is κ·[−3 + (log π + β)/2 + (β − 1)/10], negative for **β < 4.2**; smaller θ helps the first bracket and hurts the second. (My earlier figure 4.5 used a slightly different low-mode constant.) So the hybrid, if every step were rigorous, would cover the Gaussian and Mixed designs at τ ∈ [0.25, 0.75] (β̄ ≤ 1.9) and not the outer levels (β̄ ≈ 4.4–5.1).

**Risk (i), conditional structure.** It is the decorrelation step of §3. Open.

**Risk (ii), sparse large kinks under Laplace tails.** The high-mode factor is handled in expectation over the data, E₀e^{−γωℛ(δ)} ≤ exp{Σᵢmin(γ²ω²δᵢ²/8, γω|δᵢ|)} (Lemma N of `FABLE_B_lowerbound.md`; the linear branch is essential, because E e^{c·u²} = ∞ for a Laplace variable). The prior expectation of the right side is finite iff γω·max_j‖(high-mode part of sⱼ)‖₁ < ℓ. With J ≍ θκ knots Lemma F gives ‖·‖₁ ≲ (n/J)³ ≍ ℓ/θ³, so the condition is **C·γω/θ³ < 1: a condition on constants, not on n or ℓ.** So sparse kinks are not fatal in order of magnitude, but they force θ to be large enough, which works against the low-mode gain. Whether the constants are compatible for any β > 1 I do not know; with Lemma F's proven constant (C_F = 29.1) I expect they are not, and that a sharper version of the high-mode ℓ₁ bound would be needed.

**Net assessment.** Three things stand between the lead and a theorem: (SUP) of §4, the decorrelation of §3, and the constants in risk (ii). None is a one-hour item. If I had to rank them: (SUP) is the one whose resolution would also help Fable A's routes (it is the missing localization below n^{3/2}); the other two are specific to this route.

---

## 6. What this means for the plan

- **L4a stays a named assumption.** Its supported form is unchanged: the κ̂ pilot (sign positive at τ = 0.05–0.5, lost at 0.97).
- **It can be restated more narrowly, with no new mathematics** (§1): only for scales s ∈ σ₀(1 ± ε₀) (Theorem H-σ), and as the evidence inequality (L4a-E), whose required size is tiny compared with its conjectured value. The restatement makes clear that the assumption is about a sign.
- **A gap in the chain to record:** the stretch between the constant ℓ₀ of L2 and polylog(n), where Theorem H does not apply. It is inside L4a as currently stated, so nothing breaks; but neither scale localization nor the evidence bound e^{O(nℓ^{−2/7})} is available there.
- **Cheap diagnostic for (SUP) (UNTESTED).** From existing fixed-λ chains at mid ℓ: record max_i|θᵢ − θ\*ᵢ| per draw and compare with √(k̂·log n/n), k̂ := the fitted dimension implied by κ̂. If the ratio stays bounded as n grows, (SUP) is plausible at those tunings. Cost: a pass over saved draws, where they were saved.

## 7. Flags

- Lemmas F1 and F2 are new and short; they are unaudited.
- §1 uses Theorem H and H-σ as stated in `FABLE_A_theoremH.md` §1; I read the statement, not the proof, and the evidence bound e^{O(n·r²)} is my reading of how its event is used (body mass times e^{ωG}), not a quoted display.
- §4's "typical sup-norm" is a heuristic about the measure on 𝒮; only the leverage bound is proved.
- §5 is exponent bookkeeping in a Gaussian-prior proxy.

---

## Theory response (2026-11-23)

**Status: L4a remains OPEN, and its range is not shrunk. The note is UNAUDITED.**

**What it adds:**
1. **An exact reduction** to one evidence inequality, at scales near σ₀ by Theorem H-σ. Polynomial room in size; the difficulty is the sign.
2. **Two exact tools:** the fractional (Rényi) comparison, and low-mode elimination.
3. **The missing lemma, identified precisely:** a *posterior* sup-norm bound on the low-mode subspace, ‖δ‖∞ ≈ √(d·log n/n). It would serve both L4a and L4b, so it is the single most valuable target for Tuesday.

**Record:** between L2's constant ℓ₀ and polylog(n), Theorem H does not apply. This range lies inside L4a's named assumption.

**The hybrid lead** stays a CONJECTURE, with heuristic threshold β ≲ 4.2.
