# Theorem C1: contraction and sup-norm localization at EVERY fixed σ (moment-free)

*Theory Department, 2026-11-23.*

**Status: SELF-CHECKED (2026-11-23, 13:40 CT); not yet audited.** All six items of the self-check list pass; one fix (a log factor in condition (i)). It needs an audit by a different model before HQ can relay it.

**Purpose.** This is the σ-aligned headline candidate for `../ALIGNMENT_MEMO.md`, route C1. It needs no (EM), no σ ≥ σ̄ and no moments. Its rate is suboptimal.

## Setting

Stage-A posterior at fixed ω = 1/σ > 0 and deterministic λ (L5 notation): Πₙ(B | y) = N(B)/N(ℝⁿ), with N(B) = ∫_B e^{−ωℛ}dν and ν = dc ⊗ Π_λ.
- δ = θ − θ\*, ℛ(δ) = Σᵢ Xᵢ(δᵢ), M = E₀ℛ.
- TV(δ) := n²‖Dδ‖₁ = n²‖u − u\*‖₁.

Assumptions:
- (A1).
- **Full (A2)** with constants (L, f, f̄): the lower half gives the local margin, the upper half gives C₁ in L6.
- (A3) with fixed V.

## Statement

Fix T ≥ 4. Put T₀ := T·n³/λ and

  r² := C_r·T^{2/7}·n^{1/7}·λ^{−2/7}·(log n)^{6/7},

with C_r a constant depending only on f (chosen in Step 3).

Assume λ = λₙ is such that:
- **(i) the sup-norm condition** r⁴T₀ → 0, i.e. **λ/(n^{23/11}(log n)^{12/11}) → ∞**, since r⁴T₀ ≍ n^{23/7}λ^{−11/7}(log n)^{12/7};
- **(ii) the denominator** has a radius ε = εₙ ∈ (0, 1) with nε² → ∞, nε² = o(n r²), and prior budget −log Π_λ(u_h + B_{ε/2}) ≤ C_pr·nε² (L3 + L4 or L4q/L4q-M, as in Theorem B).

At λ ≍ n^{5/2}/V, (ii) holds with ε² ≍ (log n)^{1/6}V^{1/3}n^{−5/6}, and n^{−5/6} = o(n^{−4/7}).

Then, for every fixed ω > 0, and **uniformly over ω in any compact [ω₁, ω₂] ⊂ (0, ∞)**:

  sup_P E_P sup_{ω∈[ω₁,ω₂]} Πₙ,ω( ‖δ‖ₙ > r  or  TV(δ) > T₀ | y ) → 0.

The supremum over P is over the laws satisfying (A1)–(A3) with fixed constants.

Consequently, at λ ≍ n^{5/2}/V: ‖θ − θ\*‖²ₙ ≲ n^{−4/7}(log n)^{6/7} in posterior probability, and **‖θ − θ\*‖∞ → 0** (L10-I applied on the event). Both hold for every σ, uniformly on compacts.

## Proof

**Step 0 (the body and its gauge).** K′ := {‖δ‖ₙ ≤ r, TV(δ) ≤ T₀} is convex and symmetric, with gauge t(δ) := max(‖δ‖ₙ/r, TV(δ)/T₀).

**Step 1 (sup-norm on K′; L10-I, advisor-checked).** For δ ∈ K′, ‖δ‖∞ ≤ s_K := 6r + 7.06·r^{4/5}T₀^{1/5}. By (i), s_K → 0, so s_K ≤ L for n ≥ n₀. Then L2 (local branch) gives M(δ) ≥ (f/2)·n‖δ‖²ₙ on K′.

**Step 2 (convexity along rays).** ℛ is convex with ℛ(0) = 0, so ℛ(δ) ≥ t·ℛ(δ/t) for every t ≥ 1, whatever the sign of ℛ(δ/t). Split {t > 1} into two cones:
- A₁ := {t > 1, ‖δ‖ₙ/r ≥ TV(δ)/T₀}. Here δ₁ := δ/t satisfies ‖δ₁‖ₙ = r and TV(δ₁) ≤ T₀.
- A₂ := {t > 1, TV(δ)/T₀ > ‖δ‖ₙ/r}. Here δ₁ satisfies TV(δ₁) = T₀ and ‖δ₁‖ₙ ≤ r.

In both cases δ₁ ∈ K′.

**Step 3 (uniform empirical-process event).** Let G := sup_{K′}|ℛ − M| and Ω_G := {G ≤ (f/4)n r²}.
- *Expectation.* Lemma W (`W_width_lemma.md`), symmetrization and Ledoux–Talagrand give E G ≤ 4·[√n r(√3 + √k) + 40.8√(2 log 2m)·T₀nk^{−5/2}]. With k = ⌈(T₀√n/r)^{1/3}⌉ this is ≤ C·n^{7/12}r^{5/6}T₀^{1/6}√(log n) + C√n·r. Choosing C_r large enough (depending on f) makes this ≤ (f/8)n r².
- *Deviation.* Bousquet's inequality, with envelope ≤ 2s_K ≤ 2L, wimpy variance ≤ n r² and x = log n, gives a deviation ≲ √(n r² log n) + log n = o(n r²).
- *Result.* P₀(Ω_Gᶜ) → 0. **Ω_G does not depend on ω.** The step is moment-free, since |Xᵢ| ≤ |δᵢ|.

**Step 4 (the two faces on Ω_G).**
- On A₁: ℛ(δ₁) ≥ M(δ₁) − G ≥ (f/2)n r² − (f/4)n r² = (f/4)n r², hence ℛ(δ) ≥ t·(f/4)n r².
- On A₂: ℛ(δ₁) ≥ −G ≥ −(f/4)n r², hence ℛ(δ) ≥ −t·(f/4)n r².

**Step 5 (cone A₁, integrated against ν).** Put a := ω(f/4)n r².
- On A₁, t = ‖δ‖ₙ/r ≥ ‖c − c̄(u)‖₂/(√n r) (L5), and t > 1.
- Using e^{−at} ≤ e^{−a/2}e^{−(a/2)t}, we get, for each u, ∫ 1_{A₁}e^{−ωℛ}dc ≤ e^{−a/2}∫_{ℝ³}e^{−(a/2)‖c‖/(√n r)}dc = e^{−a/2}·8π·(2√n r/a)³.
- Π_λ has mass 1. So on Ω_G:

  N(A₁) ≤ 8π·(8/(ωf√n r))³·e^{−ωfnr²/8}.

**Step 6 (cone A₂, integrated against ν).**
- On A₂, t = TV(δ)/T₀ = n²‖u − u\*‖₁/T₀ depends only on u.
- For fixed u, the c-section lies in {‖c − c̄(u)‖₂ ≤ √n r t}, which has volume V₃(√n r t)³. The integrand is ≤ e^{a t}.
- Under Π_λ, Γ := λ‖u‖₁ ~ Gamma(m, 1). Also t ≤ Γ/(Tn) + s₀, with s₀ := V/T₀ = Vλ/(Tn³) → 0 (at the oracle s₀ = n^{−1/2}/T).
- Using t³ ≤ 6eᵗ and 1{t > 1} ≤ e^{β(t−1)} with β := Tn/2 − a − 1 > 0, and E e^{sΓ} = (1 − s)^{−m}:

  N(A₂) ≤ 6V₃(√n r)³·e^{−β + (Tn/2)s₀}·2^m ≤ 6V₃(√n r)³·e^{−Tn/4}.

  The last inequality holds for n ≥ n₀, because T ≥ 4, m log 2 ≤ 0.7n, a = o(n) and Tns₀ = o(n).

**Step 7 (denominator).** L6 (advisor-checked; any ω; event Ω₆ independent of ω) gives, on Ω₆, N(ℝⁿ) ≥ V₃(ε√n/2)³·e^{−(ω(1.44C₁+1) + C_pr)nε²}, with P₀(Ω₆ᶜ) ≤ 1.44/(nε²).

**Step 8 (combine).** On Ω_G ∩ Ω₆:

  Πₙ,ω(t > 1 | y) ≤ (8π/V₃)·(16/(ωf ε n r))³·exp{−ωfnr²/8 + (ω(1.44C₁+1) + C_pr)nε²} + 6·(2r/ε)³·exp{−Tn/4 + (ω(1.44C₁+1) + C_pr)nε²}.

Both terms → 0, because nε² = o(n r²), εnr → ∞ and nε² = o(n). The probability of the complement of the event is ≤ P₀(Ω_Gᶜ) + 1.44/(nε²) → 0.

**Uniformity in ω.** For ω ∈ [ω₁, ω₂], the first term is largest at ω₁ in its leading exponential (its polynomial prefactor at ω₁ is harmless), and the denominator is weakest at ω₂. So replacing ω by ω₁ in −ωfnr²/8 and by ω₂ elsewhere bounds the supremum. The condition is n r² ≫ (ω₂/ω₁)nε², which holds. The events Ω_G and Ω₆ are ω-free. ∎

## What this gives and what it does not

- **It gives:** posterior contraction and sup-norm localization for **every** fixed σ (including σ₀ < σ̄, where the learned σ lands), uniformly on compact σ-intervals, moment-free, at deterministic λ ≫ n^{23/11}.
  - Combined with the decomposition in memo (c) and a σ-concentration lemma (Astra, in progress), this would cover **learned σ** at deterministic λ.
- **It does not give** the optimal rate. That is n^{−4/7} here, against n^{−5/6}; with an entropy width instead of Lemma W, n^{−5/7}. The optimal rate below σ̄ is route C2 (Hölder–Knight), which can now use the sup-norm localization from C1.
- **It does not cover** learned λ under constant b₀, where λ ∝ n^{3/4} is outside (i).

## Self-check (done 13:40 CT)

1. Lemma W's constants and the choice of k when (T₀√n/r)^{1/3} > m.
2. The exact form of Bousquet's inequality used (one-sided, on the class {ℛ − M}), including the envelope with s_K.
3. Step 6's Chernoff algebra and the n₀ conditions.
4. That L6's prior-mass inputs hold at the claimed λ: the half-radius conditions of L4q-M at λ = n^{5/2}/V, as in Theorem B.
5. Measurability of the cone partition.
6. That (A2)'s lower half is needed only in Step 1 (the local margin), and that L6 needs only the upper half.

**Results of the self-check.**
1. **k ≤ m.** At the oracle, k\* = (T₀√n/r)^{1/3} ≤ m ⇔ λr ≥ T√n, which holds for λ ≥ n². (If k = m the tail vanishes but the head is ~ n r, too large, so k\* ≤ m is needed, and it holds.) ✓
2. **Bousquet.** Applied to F ∪ (−F), F = {(Xᵢ(δᵢ) − mᵢ(δᵢ))ᵢ : δ ∈ K′}, with sup|fᵢ| ≤ 2s_K and v ≤ n r². This gives P(G ≥ EG + √(2x(v + 4s_K·EG)) + 2s_K x/3) ≤ e^{−x}. With x = log n the deviation is o(n r²). ✓
3. **Step 6.** t ≤ Γ/(Tn) + s₀, because n²‖u‖₁/T₀ = Γ/(Tn) and n²‖u\*‖₁ ≤ V. The function t³e^{at}1{t>1} is increasing in t. Then t³ ≤ 6eᵗ, and the Gamma MGF at rate ½ is 2^m. The n₀ condition is Tn/4 ≥ a + 1 + Vλ/(2n²) + m log 2: true for T ≥ 4, since a = o(n) and Vλ/n² = o(n) for λ = o(n³/V). ✓
4. **L6 prior mass at λ ≍ n^{5/2}/V.** As in Theorem B (joins J5–J9, audited). ✓
5. **Measurability.** A₁ and A₂ are Borel (defined by continuous functions). ✓
6. **Use of (A2).** The lower half of (A2) enters only in Step 1 (the local margin) and in the threshold of Step 3; L6 uses only the upper half. ✓

**Fix:** condition (i) carries the log factor (log n)^{12/11}; it is still satisfied at λ ≍ n^{5/2}/V.
