# Lower tail of λ under the A-rule (λ ~ Gamma(1, b_n), b_n = c_b·n^{−5/2}, no truncation): reduction, what is proved, and the gap

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute; the numbers in §6 are hand computations. Reuses `astra_noFloor.md` (audited), `astra_softfloor.md` (audit pending), `FABLE_V2T_proof.md`, `FABLE_A_n56.md`, `FABLE_A_theoremH.md`, Theorem B (L2–L6, (EM)), Lemma S. Not audited.*

**Labels.** PROVED = fully written here from audited statements or elementary facts. SKETCH = argument given, a detail open. CONJECTURE = heuristic only.

**A-rule.** b_n = c_b·n^{−5/2} with c_b = 500^{5/2}/5500 ≈ 1016, so the prior mean of λ is n^{5/2}/c_b. Write t := τ(1−τ), k := min(τ, 1−τ), m := n − 3.

## 0. Verdict

**The requested input is not proved at the learned σ ≈ σ₀.** It is proved at fixed σ in the (EM) range, and it is reduced, at the learned σ, to one explicit evidence inequality whose constant must be sharp.

| # | Claim | Status |
|---|---|---|
| 1 | The hyperprior drops out: Π(λ < Λ₋ \| y) ≤ e^{2κc_b}·∫₀^{Λ₋}Z(ℓ)dℓ / ∫_J Z(ℓ)dℓ, J = [κn^{5/2}, 2κn^{5/2}]. The A-rule gives no lower-tail help; everything is an evidence comparison in Lebesgue measure | **PROVED** (§1) |
| 2 | Class-wide pieces: (I) λ < (1−η)·2t/(eσ₀) is excluded; (III-a) {Q(θ) < qn, λ ≥ ℓ₀} is excluded; (III-b) σ > H₀ is excluded | **PROVED** (§2) |
| 3 | **Lemma RSB** (reverse small ball): Π_ℓ(∃c : H(δ) ≤ nρ²) ≤ exp{−m·min(c₀, c_R(ρℓ)^{−2/5})}, for every truth shift. Matches L3's order | **PROVED**, constants c₀, c_R through a fixed bump (§3) |
| 4 | **Lower tail in the (EM) range**: at fixed σ with (EM), E_P Π_σ(λ < c₋n^{5/2}(log n)^{−1/2} \| y) → 0 for the A-rule | **PROVED** from 3 (§4) |
| 5 | **Conditional theorem at the learned σ**: evidence margin (E) ⇒ Π(λ < c₋n^{5/2}(log n)^{−1/2} \| y) → 0 ⇒ V0T\*'s machinery, rate n^{−5/6}(log n)^{1/3} | assembly **PROVED**; last step (V0T\* with κ₋ ∝ (log n)^{−1/2}) SKETCH (§5) |
| 6 | The exact design condition is (E): excess code length of every under-smoothed pair (s, ℓ) over the truth ≥ κ·min(1, ℓ^{−1/3}). It has two faces: (DC) at bounded ℓ and (LO) β := σ̄/σ₀ < β_c as ℓ → ∞ | identification PROVED as a sufficient condition; β_c = 6 is CONJECTURE (§6) |
| 7 | Values of β for the paper's noise families (hand-computed): Gaussian 1.57 / 1.86 / 4.47 / 13.9 at τ = 0.5 / 0.25 / 0.05 / 0.01; Beta(1, 11) 1.12 / 1.52 / 6.0 / 18.9 at τ = 0.05 / 0.5 / 0.95 / 0.99 | computed, not verified numerically |
| 8 | Why (E) is not proved: for 1 < β < 6 the *expected* evidence is useless (it is dominated by rare score configurations), and every available realized bound loses the constant | explained, with the three missing lemmas (§7) |

---

## 1. Reduction: the hyperprior drops out — PROVED

Let Z(s, ℓ) := s^{−n}∫e^{−Q(θ)/s}dc Π_ℓ(du) (uncentred evidence at scale s and tuning ℓ; Astra's normalization) and Z(ℓ) := ∫IG(ds)Z(s, ℓ). The posterior density of λ is ∝ b_ne^{−b_nℓ}Z(ℓ). For Λ₋ ≤ κn^{5/2} and J := [κn^{5/2}, 2κn^{5/2}]:

  **Π(λ < Λ₋ | y) ≤ ∫₀^{Λ₋}e^{−b_nℓ}Z(ℓ)dℓ / ∫_J e^{−b_nℓ}Z(ℓ)dℓ ≤ e^{2κc_b}·∫₀^{Λ₋}Z(ℓ)dℓ / ∫_J Z(ℓ)dℓ.**

With κ = 1/c_b (J at the prior mean) the constant is e². Consequences.
- The A-rule's prior is flat, up to a constant factor, on (0, 2κn^{5/2}]. It neither helps nor hurts the lower tail. The whole question is whether the evidence Z(ℓ) at small ℓ loses to the evidence on J.
- A weaker target is not cheaper. Theorem H would accept any Λ₋ ≫ n^{1/2}·polylog, but excluding {λ < Λ₋} still requires the evidence to lose on all of (0, Λ₋), and the low end of that range (bounded and moderately growing ℓ) is where the tools are weakest (§7, G4–G5). Asking for Λ₋ ≍ n^{5/2} only adds the range where the tools are strongest.
- p_n(λ < Λ₋) = 1 − e^{−b_nΛ₋} is only polynomially small, while the denominator costs e^{−Cn^{1/6}}. So "expected evidence ≤ constant" (what (EM) gives directly) is **not** enough: the numerator must itself be exponentially small, e^{−κn·Λ₋^{−1/3}}.

**Benchmark (PROVED; `FABLE_A_noFloor.md` §1 + V2T Step 3).** With σ̂ₙ := Q(θ\*)/n (= σ₀,ₙ + o_P(1) by the law of large numbers), on V2T's event Ω_D for the window J:

  ∫_J p_n(dℓ)Z(ℓ) ≥ p_n(J)·exp{−n(1 + log σ̂ₙ) − C_D·nε_J² − O(log n)},  nε_J² = C_ε·n^{1/6}[κ^{−1/3}(log m)^{1/6} + κ^{5/3}V²],

and p_n(J) = e^{−κc_b}(1 − e^{−κc_b}). In code-length form: the truth costs 1 + log σ̂ₙ per observation, plus n^{−5/6}-order terms. (σ̂ₙ, not σ₀,ₙ: their difference is O_P(n^{−1/2}), which matters at the n^{1/6} scale. It cancels exactly in the centred comparison of §2 (III-c) and is harmless in the exponential-order comparisons.)

---

## 2. The regimes of ℓ, and the class-wide pieces — PROVED

**Exact evidence formula (Astra, audited).** Z(s, ℓ) = J_n·(ℓ/2)^m·t^{−n}·𝔼_s exp{−ℓ‖D(y − E)‖₁}, with E₁, …, Eₙ i.i.d. normalized asymmetric-Laplace of scale s (auxiliary), and 1 ≤ J_n ≤ n^{9/2}.

**(I) Tiny ℓ, every law.** The expectation is ≤ 1, so n⁻¹log sup_s Z(s, ℓ) ≤ log(ℓ/(2t)) + O(log n/n). This is below −1 − log σ₀ − η as soon as

  ℓ ≤ ℓ₁ := (1 − η)·2t/(e·σ₀,ₙ)·e^{−η}.

So Π(λ < ℓ₁ | y) ≤ e^{−ηn/2} with probability → 1. (For the Gaussian paper design at τ = 0.5: 2t/(eσ₀) = 1.38.)

**(III-a) Interpolating fits at larger ℓ, every law.** On Lemma S's event {‖Dy‖₁ ≥ nd/2}, Q(θ) < qn (q = kd/32) forces ‖Dθ‖₁ ≥ nd/4. Hence, uniformly in s,

  Z(s, ℓ; Q < qn) ≤ J_n(ℓ/2)^m e^{−ℓnd/4}·s^{−n}∫e^{−Q/s}dθ = J_n(ℓ/2)^m·e^{−ℓnd/4}·t^{−n}.

Per observation: log(ℓ/(2t)) − dℓ/4 + o(1), which is ≤ −2 − log B for all ℓ ≥ ℓ₀ = ℓ₀(d, t, B). So {Q < qn, λ ≥ ℓ₀} has posterior mass ≤ e^{−n/2}. In particular, **on {λ ≥ ℓ₀} the scale is bounded below** (σ ≥ q/2 with mass → 1) without any floor of order log n.

**(III-b) Extreme scales, every law.** Lemma S §2, whose two flat-integral bounds hold for every ℓ: the numerator on s > H₀ is ≤ C_kH₀^{3−n}, and on {s < l, Q ≥ qn} it is ≤ C_k·sup_{s<l}s^{3−n}e^{−qn/(2s)}. Both are exponentially below the benchmark for Lemma S's (l, H₀).

**What remains.** Two regions, and only these:
- **(II)** ℓ ∈ [ℓ₁, ℓ₀], any s: bounded tuning. Astra's two counterexamples live here (ℓ ≈ 1/R with s → 0, and ℓ = 1 with a small positive s).
- **(III-c)** ℓ ∈ [ℓ₀, Λ₋], s in the compact I := [l, H₀]: growing tuning at a non-degenerate scale. Here the centred evidence Z̃_s(ℓ) := N_{1/s,ℓ}(ℝⁿ) = ∫e^{−ℛ/s}dν_ℓ is the right object, and the s-integral cancels between numerator and denominator:

  mass of (III-c) ≤ sup_{s∈I}[∫_{ℓ₀}^{Λ₋}p_n(dℓ)Z̃_s(ℓ) / ∫_J p_n(dℓ)Z̃_s(ℓ)].

---

## 3. Lemma RSB: reverse small ball for the Laplace difference prior — PROVED (constants via a fixed bump)

L3 bounds the small-ball probability from below. The lower tail of λ needs the matching bound from above, for shifted balls, in the Huber-type loss H(δ) := Σᵢmin(δᵢ², |δᵢ|).

**Lemma RSB.** There are absolute constants w₀ ≥ 8, c₀ > 0, c_R > 0 such that for every n with m ≥ 2w₀, every ℓ > 0, every truth (c\*, u\*) and every ρ ∈ (0, 1] with (ρℓ)^{2/5} ≤ m/C:

  Π_ℓ(u : there is c ∈ ℝ³ with H(N(c − c\*) + S(u − u\*)) ≤ n·ρ²) ≤ exp{−m·min(c₀, c_R·(ρℓ)^{−2/5})}.

The order m(ρℓ)^{−2/5} is that of L3 (30·n(λε)^{−2/5}(log m)^{1/5}), without the logarithm.

*Proof.*
1. *Block functionals.* Fix a nonzero bump β ∈ C³ with support in (0, 1). For a window length w ≥ w₀ and block b = 1, …, B := ⌊m/(w + 3)⌋, let v_b ∈ ℝᵐ be β sampled on the w interior points of the b-th window of length w + 3, zero elsewhere. Put a_b := Dᵀv_b/‖Dᵀv_b‖₂. The a_b are unit vectors with disjoint supports (Dᵀv_b lives on the window's w + 3 indices). Riemann sums give, for w ≥ w₀: ‖v_b‖₂ ≥ c_β√w, ‖Dᵀv_b‖₂ ≤ C_β·w^{−3}·√w, ‖Dᵀv_b‖∞ ≤ C_β·w^{−3} and ‖Dᵀv_b‖₂ ≥ c_β′·w^{−3}√w. Hence ‖a_b‖∞ ≤ C_a·w^{−1/2} and ‖Dᵀv_b‖₂/‖v_b‖₂ ≤ C_v·w^{−3}.
2. *They read u only.* For δ = N(c − c\*) + S(u − u\*): ⟨Dᵀv_b, δ⟩ = ⟨v_b, Dδ⟩ = ⟨v_b, u − u\*⟩, because DN = 0 and DS = I. So ⟨a_b, δ⟩ = (X_b − x_b)/‖Dᵀv_b‖₂ with X_b := ⟨v_b, u⟩, x_b := ⟨v_b, u\*⟩. The X_b are **independent** under Π_ℓ (disjoint supports), and free of c.
3. *Most blocks are small.* Let H_b be the part of H on block b. If H(δ) ≤ nρ², at least ⌈B/2⌉ blocks have H_b ≤ 2nρ²/B ≤ 7wρ² (B ≥ m/(2(w + 3)), w ≥ 8, n ≥ 33). On such a block, splitting coordinates at 1: |⟨a_b, δ⟩| ≤ √H_b + ‖a_b‖∞·H_b ≤ √(7w)·ρ + 7C_a√w·ρ² ≤ C_b·√w·ρ with C_b := √7 + 7C_a, since ρ ≤ 1.
4. *Anticoncentration.* X_b = Σⱼv_{b,j}uⱼ has characteristic function ∏ⱼ(1 + v_{b,j}²s²/ℓ²)^{−1}, of modulus ≤ (1 + s²‖v_b‖₂²/ℓ²)^{−1}. Fourier inversion gives a density ≤ (2π)^{−1}∫(1 + s²‖v_b‖₂²/ℓ²)^{−1}ds = ℓ/(2‖v_b‖₂). Hence, for every x,

   Π_ℓ(|X_b − x| ≤ C_b√w·ρ·‖Dᵀv_b‖₂) ≤ C_b√w·ρ·ℓ·‖Dᵀv_b‖₂/‖v_b‖₂ ≤ C_bC_v·ρℓ·w^{−5/2} =: p.

5. *Union.* The event requires ⌈B/2⌉ of the B independent events: probability ≤ 2^B·p^{B/2}.
6. *Choice of w.* If x := (16C_bC_v·ρℓ)^{2/5} ≥ w₀, take w := ⌈x⌉ ≤ 2x: then p ≤ 1/16, the bound is 2^{−B}, and B ≥ m/(2(w + 3)) ≥ m/(6x). If x < w₀, take w := w₀: again p ≤ 1/16 and B ≥ m/(2(w₀ + 3)). So c_R := (log 2)/(6(16C_bC_v)^{2/5}) and c₀ := (log 2)/(2(w₀ + 3)). ∎

**Corollary (Laplace transform of the prior).** With C₃(β) := sup_u∫_{ℝ³}e^{−βH/2}dc < ∞ (Theorem B, Step 2), for every β > 0, ℓ > 0 and truth:

  Φ_β(ℓ) := ∫e^{−βH(δ)}dc Π_ℓ(du) ≤ 2C₃(β)·exp{−n·min(c₀′, κ_E·ℓ^{−1/3})},  κ_E := ½·(β/2)^{1/6}·c_R^{5/6},  c₀′ := ½·min(c₀, β/2).

*Proof.* For ρ ∈ (0, 1]: on {H > nρ²}, e^{−βH} ≤ e^{−βnρ²/2}·e^{−βH/2}; on {H ≤ nρ²}, e^{−βH} ≤ e^{−βH/2} and the u-projection of the set has Π_ℓ-mass ≤ RSB. So Φ_β ≤ C₃[e^{−βnρ²/2} + e^{−m·min(c₀, c_R(ρℓ)^{−2/5})}]. Take ρ^{12/5} = min(1, 2c_Rℓ^{−2/5}/β), which equalizes βρ²/2 and c_R(ρℓ)^{−2/5} at (β/2)^{1/6}c_R^{5/6}ℓ^{−1/3}; use m ≥ n/2. ∎

---

## 4. The lower tail in the (EM) range — PROVED (given §3)

**Proposition LT-EM.** Fix ω = 1/σ and assume (A1), upper (A2), (A3) and Theorem B's (EM) at ω with constant b: E e^{−ωXᵢ(x)} ≤ e^{−bω·min(x², |x|)} for all x. Let λ ~ Gamma(1, b_n), b_n = c_bn^{−5/2}, untruncated. Then there is c₋ > 0 (depending on the class constants, ω, c_b, κ) with

  sup_P E_P Π_ω(λ < c₋·n^{5/2}·(log n)^{−1/2} | y) → 0.

*Proof.* Put Λ₋ := c₋n^{5/2}(log n)^{−1/2} and β := bω.
- *Numerator.* By Tonelli, (A1) and (EM): E₀∫₀^{Λ₋}p_n(dℓ)Z̃_ω(ℓ) = ∫₀^{Λ₋}p_n(dℓ)∫E₀e^{−ωℛ}dν_ℓ ≤ ∫₀^{Λ₋}p_n(dℓ)Φ_β(ℓ) ≤ 2C₃·exp{−n·min(c₀′, κ_EΛ₋^{−1/3})} = 2C₃·exp{−κ_E·c₋^{−1/3}·n^{1/6}(log n)^{1/6}} for large n. No continuum of events is needed: the bound is on the ℓ-integrated numerator.
- *Denominator.* V2T Step 3 on J: on Ω_D, ∫_J p_n(dℓ)Z̃_ω(ℓ) ≥ V₃(ε_J√n/2)³·p_n(J)·exp{−(3 + ω(1.25C₁ + 1))·nε_J²}, with nε_J² ≤ C_J·n^{1/6}(log n)^{1/6}.
- *Ratio.* Markov at level K on the numerator: with probability ≥ 1 − 1/K − 1.25/(nε_J²), the posterior mass is ≤ K·poly(n)·exp{−[κ_Ec₋^{−1/3} − (3 + ω(1.25C₁ + 1))C_J]·n^{1/6}(log n)^{1/6}}. Choose c₋ so that the bracket is positive. ∎

**What this gives.** At a fixed scale in the (EM) range (σ ≥ σ̄, roughly), the A-rule's posterior of λ sits above c₋n^{5/2}/√(log n), and `FABLE_A_theoremH.md` Corollary P / V0T\* then apply. This is the first lower-tail result with no floor and no truncation. It does **not** cover the learned σ: for the paper's designs σ₀/σ̄ = 1/β is 0.64 at best.

**Remark (uses Felipe's new freedom; UNTESTED).** If the IG hyperparameters may depend on (n, τ), a scale prior concentrating on the (EM) range would make Proposition LT-EM apply to the fitted model. That changes the likelihood temperature, needs a design-level bound on σ̄, and belongs to the soft-floor/σ-prior question; no pilot evidence exists.

---

## 5. Conditional theorem at the learned σ — assembly PROVED

**Hypothesis (E): evidence margin.** There are κ > 0, γ > 0 and events of probability → 1 (uniformly over the design class) on which:
- **(E-II)** for all ℓ ∈ [ℓ₁, ℓ₀]: n⁻¹log sup_{s>0}Z(s, ℓ) ≤ −1 − log σ₀,ₙ − γ;
- **(E-III)** for all s ∈ I = [l, H₀] and all ℓ ∈ [ℓ₀, n^{5/2}]: Z̃_s(ℓ) ≤ n^{C}·exp{−κ·n·ℓ^{−1/3}}.

In code-length terms, with 𝓗(s, ℓ) := −n⁻¹log(tⁿZ(s, ℓ)) the per-observation code length of the data under the model "rough trend at rate ℓ plus AL(s) noise", and 𝓗₀ := 1 + log(σ₀/t) that of the truth: **𝓗(s, ℓ) − 𝓗₀ ≥ κ·min(1, ℓ^{−1/3}) for every under-smoothed (s, ℓ)**. This is the quantitative, roughness-graded no-interpolation margin.

**Theorem (conditional).** Under the assumptions of V0T\* and (E), for the A-rule with σ ~ IG(a, b), no truncation: there is c₋ > 0 with

  sup_P E_P Π(λ < c₋·n^{5/2}·(log n)^{−1/2} | y) → 0.

*Proof.* Split {λ < Λ₋} into (I), (II), (III-a), (III-b), (III-c) of §2.
- (I), (III-a), (III-b): §2, each of mass ≤ e^{−cn} relative to the benchmark of §1 (which is e^{−n(1+log σ₀) − o(n)}).
- (II): (E-II), integrating over ℓ ∈ [ℓ₁, ℓ₀] and s with unit prior masses; the ratio to the benchmark is ≤ e^{−γn + o(n)}/p_n(J).
- (III-c): by the cancellation in §2, (E-III) and V2T Step 3's centred denominator, the mass is ≤ [p_n(λ ≤ Λ₋)/p_n(J)]·n^{C′}·exp{−κnΛ₋^{−1/3} + (3 + ω₂(1.25C₁ + 1))nε_J²}, which → 0 for small c₋ exactly as in §4. ∎

**Consequence — SKETCH for the last step.** By the identity Π(B | y) ≤ Π(B | y, λ ≥ Λ₋) + Π(λ < Λ₋ | y), the conditioned posterior is V0T\*'s model with floor Λ₋ = κ₋,ₙn^{5/2}, κ₋,ₙ = c₋(log n)^{−1/2}, and window mass 1 − e^{−b_nΛ₋} ≍ (log n)^{−1/2}. V0T\*'s constants do not involve κ₋ except through ε̄² ≍ n^{−5/6}[κ₋^{−1/3}(log n)^{1/6} + κ₋^{5/3}V²], so the rate would be **n^{−5/6}(log n)^{1/3}**. V0T\* is written for fixed κ₋; the n-dependent version was not re-derived line by line.

---

## 6. The exact design condition

(E) is a property of the noise design alone (plus smoothness of the truth). It has two faces.

### 6.1 (DC): no partial interpolation at bounded tuning — the (II) face

n⁻¹log 𝔼_s exp{−ℓ‖D(y − E)‖₁} + log(ℓ/(2t)) < −1 − log σ₀ − γ on [ℓ₁, ℓ₀] × (0, ∞).

- At s → 0 it is exactly the audited necessary condition σ₀ < 2tR (ℓ = 1/R). Astra's first counterexample violates it there; the second violates it at ℓ = 1 and a small positive s, although σ₀ < 2tR holds. Both are bounded, nearly atomic two-cluster laws.
- **A provable upper bound on the left side (PROVED).** Stencils j ≡ a (mod 4) use disjoint coordinates. Hölder over the four classes gives, for every (s, ℓ) and every data vector,

  n⁻¹log 𝔼_s e^{−ℓ‖D(y−E)‖₁} ≤ (4n)⁻¹Σⱼ log 𝔼_s exp{−4ℓ·|(Dy)ⱼ − (DE)ⱼ|}.

  The right side is an average of one-dimensional integrals, exact at s = 0. It certifies (DC) only for small ℓ (it grows like ¾·log ℓ). Longer blocks (drop three stencils per block of length L_b; cost 3·log(ℓ/2)/L_b) converge to the truth but must be evaluated numerically.
- **For the paper's designs (DC) is not established here.** It is a finite-dimensional numerical certificate (block free energies on a compact (s, ℓ) region), not an asymptotic statement. UNTESTED. I expect it to hold: these laws have smooth unimodal or mixture densities with no atoms, and at s → 0 the margin σ₀/(2tR) is 0.18–0.47.

### 6.2 (LO): the local Occam constant — the (III-c) face

For ℓ → ∞ the fitted wiggles are small and the model is locally Gaussian (CONJECTURE, Gaussian proxy; derivation in `FABLE_joint_V2.md`, `FABLE_A_noFloor.md` §5):

  log Z̃_s(ℓ) ≈ −(π/6)·(6 − σ̄/s)·k_eff(ℓ, s),  k_eff ≍ n·ℓ^{−1/3}·(f₀/s)^{1/6},  σ̄ := t/f₀,

with f₀ the noise density at the quantile. So (E-III) holds at the learned scale iff

  **(LO) β := σ̄/σ₀ = τ(1−τ)/(f₀·σ₀) < β_c,  β_c = 6 conjecturally.**

For non-identical noise the per-mode sums localize, and the condition becomes an average (CONJECTURE): t·∫f(x)^{−5/6}dx < 6σ₀·∫f(x)^{1/6}dx. For a scale family (f(x) ∝ 1/sd(x)) this is implied by the homoscedastic condition at the same shape (Chebyshev's sum inequality), so heteroscedasticity does not hurt.

**β is a design quantity one can compute.** Hand values:

| Noise | Formula | β at τ = 0.01 / 0.05 / 0.25 / 0.5 / 0.75 / 0.95 / 0.99 |
|---|---|---|
| Gaussian (any scale; heteroscedastic ≤ these) | τ(1−τ)/φ(z_τ)² | 13.9 / 4.47 / 1.86 / 1.57 / 1.86 / 4.47 / 13.9 |
| Beta(1, b), b = 1 (uniform) | 2 | 2 at every τ |
| Beta(1, b), b = 11 | τ(b+1)(1−τ)^{1/b−1}/(b²·q), q = 1 − (1−τ)^{1/b} | 1.10 / 1.12 / — / 1.52 / — / 6.0 / 18.9 |
| Beta(1, b), b = 6 | same | — / — / — / — / — / 5.7 / 16.7 |

(For Beta(1, b): σ₀ = (1−τ)·q·b/(b+1) and f₀ = b(1−τ)^{(b−1)/b}.)

**Reading.**
- β ≤ 1 is, to first order, the (EM) range, where §4 is a theorem. None of the paper's cells is there; the nearest are the low Beta quantiles at the steep end (β ≈ 1.1).
- 1 < β < 6: Gaussian and mixture at τ ∈ [0.05, 0.95], Beta at τ ≤ 0.95. Here (LO) is expected to hold, and this is exactly the range where no proof exists.
- β > 6: Gaussian at τ ∈ {0.01, 0.99}, Beta at τ = 0.99 (and borderline at 0.95 for the steep end b = 11). Here the proxy says the evidence **rewards** under-smoothing, so the A-rule's λ should drift below its prior mean as n grows. This is a testable prediction from the existing exact-Gibbs output: posterior median of λ/n^{5/2} by τ and n. At n ≤ 2000 and τ = 0.01 the asymptotic regime may not be reached (20 or fewer points below the curve), so absence of drift there would not refute the proxy.

### 6.3 Why Astra's counterexamples are excluded and the paper's families are not

Astra's laws are bounded with nearly atomic clusters: R = n⁻¹E‖DZ‖₁ is small relative to σ₀/t (first example), or the stencil outputs are bounded away from zero so that a small auxiliary scale pays nothing (second example). Both fail (DC). The paper's families have densities bounded above and below near every quantile on a connected support, which is what the (LO) computation needs (a local quadratic remainder), but (LO) additionally needs the number β < β_c. So the design condition is **not** "continuous density bounded above and below" alone: Gaussian noise at τ = 0.01 satisfies that and has β = 13.9.

---

## 7. The gap, isolated

**Why the (EM) proof stops at β = 1.** For x small, E e^{−ωXᵢ(x)} = exp{(ω²t/2 − ωf₀/2)x²(1 + o(1))}, which exceeds 1 exactly when β > 1. Then E₀Z̃_s(ℓ) ≥ ∫e^{+c‖δ‖₂²}dν_ℓ locally, which is enormous (the flat directions alone make the local Gaussian integral diverge). Per mode: the realized gain is (β/2)·ρ/(1 + ρ), but its exponential moment over the score is (1 − βρ/(1 + ρ))^{−1/2}, infinite once βρ/(1 + ρ) ≥ 1. So for 1 < β < 6 the typical evidence is exponentially small while its expectation is not: **the bound must be realized, on a score event, and it must keep the constant.**

**Why the realized bounds available today lose the constant.**
- C2-type (Knight + Cauchy–Schwarz + RSB): per unit of k_eff the exponent is ω√(2jξ) + C₂ω²/j⁵ − ω(f/4)ξ − (c_R/2)(2ξ)^{−1/5} (shell ξ, split j). It is negative only for ω below a non-sharp constant, i.e. for β below some β₁ that is in all likelihood < 1. This reproves less than §4.
- C1/Theorem-H-type (supremum over a body): gives Z̃_s(ℓ) ≤ e^{+C·n·ℓ^{−2/7}}, the wrong sign.

**Three lemmas that would close (E-III) on C1's window (ℓ ≥ n^{21/11}) — SKETCH.**
1. *(G1) Uniform quadratic remainder.* On the localized body, R(δ) ≥ (1 − η)(f₀/2)‖δ‖₂² − o(k_eff), uniformly. The remainder has variance ≲ f̄|δᵢ|³, so a variance-sensitive chaining bound gains √s_K over the score process; the exponent check is s_K ≪ ℓ^{−1/18}, which holds with W′ (s_K ≍ n^{−13/70}) or after C2's sup-norm rate n^{−7/30}.
2. *(G2) Sharp Laplace transform of the prior.* ∫e^{−ω(f₀/2)‖δ‖₂²}dc Π_ℓ(du) = exp{−(π + o(1))·k_eff}. RSB gives the order, not the constant π; it needs the Weyl asymptotics of the singular values of P⊥S and concentration of log det over the Gaussian scale mixture.
3. *(G3) Assembly without Cauchy–Schwarz.* Conditionally on the mixture variances the evidence is an explicit Gaussian integral. The coarse part gains at most (β/2)(1 + η) per dimension of P_J (C2's event ‖P_Jψ‖₂² ≤ (1 + η)t(J + 3) already has the sharp constant); the fine part is C2's Laplace MGF. With sharp constants in both, the gain is ≤ 0.6β·k_eff against the cost π·k_eff: a provable threshold **β < π/0.6 ≈ 5.2**, close to the conjectured 6 and covering every paper cell with β < 6 except Beta at τ = 0.95 near b = 11. With Lemma F's non-sharp fine constant the threshold degrades like (constant ratio)^{−1/6}.

**Two further gaps.**
- *(G4) Intermediate tuning ℓ₀ ≤ ℓ ≤ n^{21/11}.* No sup-norm localization there, hence no (G1). Theorem H localizes in Huber loss but gives the wrong sign for the evidence. I have no route.
- *(G5) Bounded tuning (DC).* Numerical certificate only (§6.1).

**Necessity direction — SKETCH.** If β > 6, restricting the scale mixture to typical variances and applying Jensen to the remainder gives Z̃_s(ℓ) ≥ exp{+(π/6)(β − 6)(1 − o(1))k_eff} on C1's window, so the posterior of λ cannot stay at the n^{5/2} scale. I believe this half is provable with (G1) reversed (an upper bound on the remainder in expectation), and it would make (LO) with β_c ≤ 6 a necessary design condition for the A-rule at Λ₋ ≍ n^{5/2}.

---

## 8. Recommendation and risk

**Tuesday.** (i) Audit Lemma RSB and Proposition LT-EM: they are short, new and self-contained, and RSB is the upper small-ball companion of L3 that every evidence-comparison route needs. (ii) Have Engineering read β off the table in §6.2 against the existing exact-Gibbs output (posterior median of λ/n^{5/2} by τ, n, family). If λ is stable where β < 6 and drifts where β > 6, the design condition (LO) is the right statement for the paper, as a stated assumption with numerical support. (iii) Only then invest in (G1)–(G3).

**Main risk.** The whole (III-c) face rests on a sharp constant that is conjectural (β_c = 6 from a Gaussian proxy; 5.2 from the sketched route). If the true threshold is lower, cells at τ = 0.05/0.95 (β = 4.47) are the first to fail. And (G4) has no route at all, so even with (G1)–(G3) the theorem would need (E-III) as an assumption on ℓ ∈ [ℓ₀, n^{21/11}].

## 9. Not verified

- Lemma RSB's bump constants (c_β, C_β, C_a, C_v, w₀) are asserted from Riemann sums, not computed.
- §6.2's table is hand arithmetic from closed forms; the Beta σ₀ formula was derived once. The mixture family was not evaluated.
- V2T Step 3 and Theorem B's Step 2 (C₃) are used as stated; `astra_softfloor.md` is cited only for context (its audit is pending); `astra_noFloor.md`'s evidence formula is audited.
- Everything in §6.2 and §7 beyond the stated inequalities is proxy-level.
