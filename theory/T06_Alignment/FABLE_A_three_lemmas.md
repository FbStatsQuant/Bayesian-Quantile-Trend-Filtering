# The three lemmas for the local Occam bound (learned-σ A-rule gap, C1's window)

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute; nothing is numerically verified. Reuses Lemma F (audited), Lemma F′ and Lemma Lev (`FABLE_A_theoremH.md`, audit queued), C1 with W′, L5, L10-I, C2 §3.1–3.3. Written in one pass; **not audited**. Does not treat the Gaussian τ = ½ instance (Fable B).*

**Labels.** PROVED = every line is written here and rests on audited statements, on Lemmas F′/Lev, or on standard facts named in the text. SKETCH = argument given, a detail open.

## 0. Verdict

| Item | Status |
|---|---|
| **Lemma 1** (uniform quadratic remainder on C1's body) | **PROVED** (§2), for ℓ ≥ C·n^{54/25}·polylog |
| **Lemma 2a** (eigenvalues of DDᵀ, two-sided, sharp constant; sharp sums) | **PROVED** (§3.1) |
| **Lemma 2b** (deterministic sandwich for the scale-mixture covariance) | **PROVED** (§3.2) |
| **Lemma 2c** (Laplace transform of the prior: **one-sided** exponent bound (4b′)^{1/6}·nℓ^{−1/3}, uniform in the shift; audit finding 6) | **PROVED** (§3.3), for ℓ ≥ C·n^{9/4} |
| **Lemma 3** (assembly without Cauchy–Schwarz, exact in the mixture) ⇒ **Theorem LO**: Z̃_ω(ℓ) ≤ n^{C}·exp{−κ₁·nℓ^{−1/3}} whenever **β = ωt/f < 6** | **PROVED at fixed (ω, ℓ)** (§4), for ℓ ≥ C·n^{99/43}·polylog (99/43 ≈ 2.30) |
| Uniformity in ω on a compact and in ℓ on the window; consequence for the A-rule | **OPEN — genuine gap** (audit finding 10; repair route in finding 11). The §5 sketch is withdrawn as a proof |

**Two corrections to `FABLE_A_Arule_lowertail.md` §7.**
1. The threshold "β < 5.2" attributed there to a Hölder assembly is wrong. With Young's inequality on the coarse score and Hölder between the fine MGF and the prior's Laplace transform, the best possible threshold is (π/0.6)·[max_θ θ^{5/6}(1−θ)^{1/6}]² = 5.24·0.637² ≈ **2.1**, and with Lemma F's proven (non-sharp) Frobenius constant it drops below 1, i.e. below (EM). That route is abandoned.
2. The assembly below is different: it integrates the Laplace prior **exactly** as a Gaussian scale mixture and uses monotonicity in the mixing variances. It has no Cauchy–Schwarz, Hölder or Young loss, and it reaches the Gaussian-proxy threshold **6** itself. The truth shift costs only a constant.

**Risk reduced.** The local face (LO) of the design condition is now a theorem at fixed (ω, ℓ) on the top part of C1's window, with the conjectured constant. What is still open is listed in §5: uniformity (routine), and the tuning range below n^{99/43} (no route, as before).

---

## 1. Setting and the statement

- (A1); full (A2) in secant form with (L, f, f̄); (A3) with V. ω = 1/s fixed. t := τ(1−τ). ψᵢ := τ − 1{Zᵢ < 0}: independent, mean zero, variance t, values in [τ − 1, τ].
- Knight: ℛ(δ) = −⟨ψ, δ⟩ + R(δ), R = ΣᵢRᵢ(δᵢ) ≥ 0, E R = M, M(δ) ≥ (f/2)‖δ‖₂² when ‖δ‖∞ ≤ L (C2 §3.1–3.2).
- Tuning ℓ; k := n·ℓ^{−1/3}; x₀ := ℓ^{−1/3}; T ≥ 4; T₀ := Tn³/ℓ; K′ := {‖δ‖ₙ ≤ r, TV(δ) ≤ T₀}, C1's body at level ℓ with W′ (r² = C_rT^{2/7}ℓ^{−2/7}(log n)^{6/7}).
- A₀ := P⊥S (n×m). Since DA₀ = I and range A₀ ⊂ (null D)^⊥, **A₀ = D⁺ = Dᵀ(DDᵀ)^{−1}**. a_j := A₀e_j. v₁ := 2/ℓ² (the variance of Laplace(ℓ)).
- Centred evidence Z̃_ω(ℓ) := ∫e^{−ωℛ(δ)}dc Π_ℓ(du), δ = N(c − c\*) + S(u − u\*).
- **β := ω·t/f** (= σ̄/s with σ̄ = t/f). For η ∈ (0, ½): f′ := (1 − η)f, a := ωf′, β′ := ωt/f′ = β/(1 − η), **k_\* := (2ωf′)^{1/6}·n·ℓ^{−1/3}/π** (the effective number of fitted modes).

**Theorem LO (local Occam bound).** Let β < 6. There are ε ∈ (0, 1), C < ∞ and K₀ (depending on 6 − β and the class constants) such that for every K ≥ K₀ and every ℓ with C(K)·n^{99/43}(log n)^{c} ≤ ℓ ≤ n³/(TV·K), with probability ≥ 1 − C/K − C/k_\* − P₀(Ω_Gᶜ):

  **Z̃_ω(ℓ) ≤ n^{C}·e^{CK}·exp{−(1 − ε)·(π/6)·(6 − β)·k_\*} = n^{C}e^{CK}·exp{−κ₁·n·ℓ^{−1/3}},  κ₁ := (1 − ε)(6 − β)(2ωf)^{1/6}/6·(1 − η)^{1/6}.**

For β ≤ 1 this is the (EM) range; the content is 1 < β < 6. (f may be taken as the lower secant constant on [−s_K, s_K], which tends to the density at the quantile.)

**Non-identical noise.** f is a lower bound for **every** i, so here β = t/(s·minᵢfᵢ). For heteroscedastic Gaussian noise at the learned scale this is β₀ = [τ(1−τ)/φ(z_τ)²]·(sd_max/sd_mean): below 6 at τ = 0.5 when sd_max/sd_mean < 3.8, and at τ = 0.05 only when it is < 1.34. The averaged condition conjectured in `FABLE_A_Arule_lowertail.md` §6.2 (which would remove the factor sd_max/sd_mean) is **not** proved here; it would need Lemma 2b with position-dependent weights fᵢ.

---

## 2. Lemma 1: uniform quadratic remainder — PROVED

**Lemma 1.** Let s(x) := 6√x + 7.06·x^{2/5}T₀^{1/5} (L10-I's sup-norm bound on {‖δ‖ₙ² ≤ x, TV ≤ T₀}) and assume s(r²) ≤ L. Let η ∈ (0, 1), K ≥ 1 and

  **(S)** 24.4·T^{1/6}·K·√(2f̄·s(x₀)·log 2n)·ℓ^{1/36} + 17.5·T^{1/3}·K·log(2m)·ℓ^{−1/9} ≤ η·f/4.

Then with probability ≥ 1 − 6.3/K, simultaneously for all δ ∈ K′:

  **|R(δ) − M(δ)| ≤ η·M(δ) + η·(f/4)·k,  in particular R(δ) ≥ (1 − η)(f/2)‖δ‖₂² − η(f/4)k.**

Since s(x₀) ≍ T^{1/5}n^{3/5}ℓ^{−1/3}, (S) holds for **ℓ ≥ C(K/η)^{36/5}(log n)^{18/5}·n^{54/25}** (54/25 = 2.16).

*Proof.*
1. *Active coordinates.* Fix x with s := s(x) ≤ L and put S(x) := {‖δ‖ₙ² ≤ x, TV(δ) ≤ T₀}; on it ‖δ‖∞ ≤ s. Rᵢ(y) = (y − Zᵢ)1{0 ≤ Zᵢ ≤ y} for y > 0 and (Zᵢ − y)1{y ≤ Zᵢ < 0} for y < 0. So y ↦ Rᵢ(y) is 1-Lipschitz, Rᵢ(0) = 0, and **Rᵢ ≡ 0 on [−s, s] unless |Zᵢ| ≤ s**.
2. *Symmetrization and contraction on the active set.* With Rademacher ε independent of the data: E sup_{S(x)}|R − M| ≤ 2E sup|ΣᵢεᵢRᵢ(δᵢ)|. Conditionally on the data, only i with |Zᵢ| ≤ s contribute, and the Ledoux–Talagrand contraction on that index set gives ≤ 4·E sup_{S(x)}⟨ξ, δ⟩, with **ξᵢ := εᵢ·1{|Zᵢ| ≤ s}**. The ξᵢ are independent, mean zero, |ξᵢ| ≤ 1 and E ξᵢ² = P(|Zᵢ| ≤ s) ≤ p := 2f̄s (upper secant bound).
3. *Width with small-variance multipliers.* Use P_H, w_j of Lemma F′ (3 ≤ h ≤ m/4). As in W′: ⟨ξ, δ⟩ = ⟨P_Hξ, δ⟩ + Σⱼuⱼ⟨w_j, ξ⟩, u = Dδ.
   - Head: ≤ √(nx)·‖P_Hξ‖₂ and E‖P_Hξ‖₂ ≤ (Σᵢ(P_H)ᵢᵢ·E ξᵢ²)^{1/2} ≤ √(p·2m/h).
   - Tail: ≤ (T₀/n²)·max_j|⟨w_j, ξ⟩|. Each ⟨w_j, ξ⟩ has variance ≤ p‖w_j‖₂² ≤ 8.13·p·h⁵ and summands bounded by ‖w_j‖∞. **‖w_j‖∞ ≤ 13.1·h²**: w_j = (I − P_H)e with e Lemma F's explicit error vector, ‖e‖∞ ≤ 4.5h², ‖e‖₂ ≤ 2.85h^{5/2}, and ‖P_He‖∞ = max_i|⟨P_He_i, e⟩| ≤ (3/√h)‖e‖₂ ≤ 8.55h² by Lemma Lev. Bernstein's maximal inequality (sub-gamma with (v, b/3)) gives E max_j|⟨w_j, ξ⟩| ≤ 2.85·h^{5/2}√(2p·log 2m) + 4.37·h²·log 2m.
   - With h := ⌊X⌋, X := (√x·ℓ/T)^{1/3} (so TX³/ℓ = √x), exactly as in Lemma WH:

     E sup_{S(x)}⟨ξ, δ⟩ ≤ 6.1·√(p·log 2n)·n·x^{5/12}(T/ℓ)^{1/6} + 4.37·log(2m)·n·x^{1/3}(T/ℓ)^{1/3}.

   The gain over the score process is the factor √p = √(2f̄s): the remainder only sees the O(s) fraction of data within s of the quantile.
4. *Shells.* x_a := 2^ax₀, a = 0, …, a_max (x_{a_max} ≥ r²). In units of k: n·x₀^{5/12}ℓ^{−1/6} = k·ℓ^{1/36} and n·x₀^{1/3}ℓ^{−1/3} = k·ℓ^{−1/9}. With G_a := sup_{S(x_a)}|R − M| and s(x_a) ≤ 2^{a/2}s(x₀):

   E G_a ≤ k·[24.4·T^{1/6}√(2f̄s(x₀)log 2n)·ℓ^{1/36}·2^{a/4+5a/12} + 17.5·T^{1/3}log(2m)·ℓ^{−1/9}·2^{a/3}].

5. *Markov with geometric levels.* P(G_a > K·2^{a/4}·E G_a) ≤ 2^{−a/4}/K, and Σ_a2^{−a/4} ≤ 6.3. Under (S), K·2^{a/4}·E G_a ≤ η(f/4)·k·2^{a} for every a (the exponents 2a/3 + a/4 and a/3 + a/4 are ≤ a).
6. *Conclusion.* If ‖δ‖ₙ² ∈ (x_{a−1}, x_a] with a ≥ 1, then M(δ) ≥ (f/2)n·x_{a−1} = (f/4)k2^{a}, so |R − M| ≤ ηM. If ‖δ‖ₙ² ≤ x₀, |R − M| ≤ η(f/4)k. ∎

**Remarks.** No envelope or chaining is needed: the active-set contraction puts the variance gain into the multipliers, and the width is then the in-house projector argument. The window n^{54/25} comes from s(x₀)·ℓ^{1/18} → 0; the event is ω-free.

---

## 3. Lemma 2: the prior, sharply

### 3.1 Lemma 2a: the spectrum of DDᵀ — PROVED

**Lemma 2a.** Let μ₁ ≤ … ≤ μ_m be the eigenvalues of DDᵀ. The nonzero singular values of A₀ = P⊥S are σ_r = μ_r^{−1/2}, and

  **(2·sin(π⌊r/2⌋/n))⁶ ≤ μ_r ≤ (2·sin(π⌊(r+3)/2⌋/n))⁶ ≤ (π(r + 3)/n)⁶,  1 ≤ r ≤ m.**

Consequently, for ϱ > 0 and κ := ϱ^{1/6}n/π ≥ 4, and any η ∈ (0, 1):
- (cost) Σ_r log(1 + ϱ/μ_r) ≥ 2π·κ − 24·log κ − 24 − κ⁶/(5m⁵);
- (gain) Σ_r (ϱ/μ_r)/(1 + ϱ/μ_r) ≤ (π/3)·κ/(1 − η²/2) + 1 + (πκ/2)⁶/(5(ηn)⁵);
- (crude gain, all κ) Σ_r (ϱ/μ_r)/(1 + ϱ/μ_r) ≤ (π²/6)·κ + 1.

*Proof.*
- A₀ᵀA₀ = (DDᵀ)^{−1}, so σ_r² = 1/μ_r.
- (DDᵀ)_{jk} = Σ_l c_lc_{l+j−k} with stencil c = (−1, 3, −3, 1): every row of D carries the full stencil, so DDᵀ is exactly the m×m Toeplitz matrix with symbol g(θ) = |1 − e^{iθ}|⁶ = (2 sin(θ/2))⁶.
- Let C_n be the n×n circulant with the same band. Its leading m×m block is DDᵀ: a wrap-around entry would need |j − k| ≥ n − 3 = m. Its eigenvalues are g(2πj/n), j = 0, …, n − 1; in increasing order λ_(i) = (2 sin(π⌊i/2⌋/n))⁶.
- Cauchy interlacing for a principal submatrix of codimension 3: λ_(r) ≤ μ_r ≤ λ_(r+3).
- (cost) 1/μ_r ≥ (n/(π(r + 3)))⁶, so the sum is ≥ Σ_{r≤m}log(1 + (κ/(r + 3))⁶) ≥ ∫₄^{m+4}log(1 + (κ/y)⁶)dy = κ∫_{4/κ}^{(m+4)/κ}log(1 + y^{−6})dy. Use ∫₀^∞log(1 + y^{−6})dy = π/sin(π/6) = 2π, ∫₀^c log(1 + y^{−6})dy ≤ c·log(1 + c^{−6}) + 6c, and log(1 + y^{−6}) ≤ y^{−6}.
- (gain) For r ≥ 2, μ_r ≥ (2 sin(π(r − 1)/(2n)))⁶ ≥ (π(r − 1)/n)⁶·φ⁶ with φ = sin y/y at y = π(r − 1)/(2n) ≤ π/2; φ ≥ 2/π always and φ ≥ 1 − η²/2 for r − 1 ≤ ηn. Bound the r = 1 term by 1, the terms 2 ≤ r ≤ ηn + 1 by ∫₀^∞(1 + (y/κ′)⁶)^{−1}dy = (π/3)κ′ with κ′ = κ/(1 − η²/2), and the rest by Σ_{s>ηn}(πκ/(2s))⁶. The crude version uses φ ≥ 2/π for all r. ∎

**By-product.** This is a two-sided, sharp-constant version of L3 Step 4 (which has σ_r(A) ≤ 91.2·n^{5/2}r^{−3}): n^{−1/2}σ_r = n^{5/2}(πr)^{−3}(1 + O(1/r)) for r = o(n).

### 3.2 Lemma 2b: deterministic sandwich for Σ_V — PROVED

Laplace(ℓ)^{⊗m} is the law of u with uⱼ | V ~ N(0, Vⱼ), Vⱼ i.i.d. exponential with mean v₁ (L3 Step 1). Put Σ_V := A₀·diag(V)·A₀ᵀ = ΣⱼVⱼa_ja_jᵀ.

Partition {1, …, m} into blocks b of consecutive indices with w ≤ |b| < 2w. ā_b := the block mean of the a_j; d_j := a_j − ā_b; 𝒟 := Σⱼd_jd_jᵀ.

**Lemma 2b.** Let γ, η ∈ (0, 1) and v̄ > 0, and suppose V satisfies maxⱼVⱼ ≤ v̄ and (1 − η)|b|v₁ ≤ Σ_{j∈b}Vⱼ ≤ (1 + η)|b|v₁ for every block. Then

  **c₋·v₁·A₀A₀ᵀ − γ^{−1}(v₁ + v̄)·𝒟 ⪯ Σ_V ⪯ c₊·v₁·A₀A₀ᵀ + (1 + γ^{−1})·v̄·𝒟,**

with c₊ := (1 + γ)(1 + η), c₋ := (1 − γ)(1 − η)/(1 + γ), and **tr 𝒟 ≤ (4/3)·w²·n⁴**.

*Proof.* For vectors: (ā + d)(ā + d)ᵀ ⪯ (1 + γ)āāᵀ + (1 + γ^{−1})ddᵀ and ⪰ (1 − γ)āāᵀ − (γ^{−1} − 1)ddᵀ. Also |b|·ā_bā_bᵀ ⪯ Σ_{j∈b}a_ja_jᵀ (Cauchy–Schwarz), and from the first inequality ā_bā_bᵀ ⪰ (1 + γ)^{−1}a_ja_jᵀ − γ^{−1}d_jd_jᵀ. Sum over j ∈ b with weights Vⱼ, use the block-sum bounds and Vⱼ ≤ v̄, then sum over b. For the trace: a_j − a_{j′} = P⊥(s_j − s_{j′}), and s_j(i) − s_{j+1}(i) = (i − j − 2)₊, so ‖s_j − s_{j+1}‖₂² ≤ n³/3 and ‖d_j‖₂ ≤ 2w·n^{3/2}/√3. ∎

**Probability of the hypothesis (PROVED).** P(Vⱼ > c₀v₁) = e^{−c₀}. For a block of N ≥ w exponentials (Cramér): P(sum ≥ (1 + η)Nv₁) ≤ e^{−Nη²/3} **for 0 < η ≤ ½** (audit finding 3; the exact rate is η − log(1 + η)) and P(sum ≤ (1 − η)Nv₁) ≤ e^{−Nη²/2}.

### 3.3 Lemma 2c: sharp Laplace transform of the prior — PROVED

**Lemma 2c.** Let b′ > 0, A ≥ 1, γ, η ∈ (0, ½), κ₋ := (4b′c₋)^{1/6}·nℓ^{−1/3}/π ≥ 4. If there is an integer w ≤ m/2 with 2(Aκ₋ + log 2m)/η² ≤ w and (16b′/(3γ))·(Aκ₋ + log 2m + 1)·w²n⁴/ℓ² ≤ η·κ₋ (possible when **ℓ ≥ C(A, γ, η, b′)·n^{9/4}**), then for every truth shift u\*:

  **E_{Π_ℓ}exp{−b′‖P⊥S(u − u\*)‖₂²} ≤ 2e^{−Aκ₋} + exp{−(1 − η/π)·π·κ₋ + 12·log κ₋ + 13},  π·κ₋ = (4b′c₋)^{1/6}·n·ℓ^{−1/3}.**

So the exponent is (4b′)^{1/6}·nℓ^{−1/3}·(1 − o(1)): the constant 4^{1/6}, with no logarithm. (Lemma RSB gave the order only.)

*Proof.* Conditionally on V, y := A₀u ~ N(0, Σ_V), so with a := 2b′: E[e^{−(a/2)‖y − y\*‖²} | V] = det(I + aΣ_V)^{−1/2}·exp{−(a/2)y\*ᵀ(I + aΣ_V)^{−1}y\*} ≤ det(I + aΣ_V)^{−1/2}. Take v̄ := 2(Aκ₋ + log 2m)v₁. Off the event of Lemma 2b (lower block bounds and the maximum), bound by 1; its probability is ≤ m·e^{−v̄/v₁} + (m/w)e^{−wη²/2} ≤ 2e^{−Aκ₋}. On it, Σ_V + E ⪰ X with X := c₋v₁A₀A₀ᵀ, E := γ^{−1}(v₁ + v̄)𝒟, and by concavity of log det,

  log det(I + aX) ≤ log det(I + aΣ_V + aE) ≤ log det(I + aΣ_V) + a·tr E.

Lemma 2a (cost) with ϱ = a·c₋·v₁ = 4b′c₋/ℓ² gives log det(I + aX) ≥ 2πκ₋ − 24 log κ₋ − 24 − κ₋⁶/(5m⁵), and a·tr E ≤ 2ηκ₋ by the second condition on w. ∎

---

## 4. Lemma 3: the assembly, exact in the mixture — PROVED at fixed (ω, ℓ)

### 4.1 Reduction to a Gaussian likelihood

On Ω_G (C1's event at level ℓ; needs C1's conditions (i), (i′) with W′): N_ℓ(K′ᶜ) ≤ n^{C}(e^{−ωf·nr²/8} + e^{−Tn/4}) (C1 Steps 5–6; no denominator is involved), and n·r² ≫ k. On Lemma 1's event, for δ ∈ K′: −ωℛ(δ) ≤ ω⟨ψ, δ⟩ − (a/2)‖δ‖₂² + ωη(f/4)k with a = ω(1 − η)f. Dropping the indicator of K′:

  **Z̃_ω(ℓ) ≤ e^{ωη(f/4)k}·𝒵 + N_ℓ(K′ᶜ),  𝒵 := ∫exp{ω⟨ψ, δ⟩ − (a/2)‖δ‖₂²}dc Π_ℓ(du).**

### 4.2 Exact formula

Write δ = Ng + (y − y\*), g ∈ ℝ³ (Lebesgue), y := A₀u, y\* := A₀u\* = P⊥θ\*, ψ_⊥ := P⊥ψ, z := y\* + ψ_⊥/f′, B_V := (I + aΣ_V)^{−1}. Integrating g, completing the square in y, and conditioning on V:

  **𝒵 = (2π/a)^{3/2}·e^{(ω/(2f′))‖ψ‖₂²}·E_V[det(I + aΣ_V)^{−1/2}·exp{−(a/2)·zᵀB_Vz}].**

(Checks: ω²/(2a) = ω/(2f′); the Gaussian identity E e^{−(a/2)‖y−z‖²} = det(I + aΣ)^{−1/2}e^{−(a/2)zᵀ(I+aΣ)^{−1}z} for y ~ N(0, Σ).)

### 4.3 Monotonicity replaces Cauchy–Schwarz

Both V-dependent factors are monotone in Σ_V in the Loewner order: det(I + aΣ_V)^{−1/2} decreases, and exp{−(a/2)zᵀB_Vz} increases. So if Σ₋ − E ⪯ Σ_V ⪯ Σ₊ for **fixed** matrices,

  det(I + aΣ_V)^{−1/2}·e^{−(a/2)zᵀB_Vz} ≤ exp{−½log det(I + aΣ₋) + (a/2)tr E}·exp{−(a/2)zᵀ(I + aΣ₊)^{−1}z}.

With B₊ := (I + aΣ₊)^{−1} and M₊ := Σ₊(I + aΣ₊)^{−1} = (I − B₊)/a, expanding z:

  (ω/(2f′))‖ψ‖² − (a/2)zᵀB₊z = (ω/(2f′))‖P_Nψ‖² + **½ω²·ψ_⊥ᵀM₊ψ_⊥** − [ω⟨B₊y\*, ψ⟩ + (a/2)‖B₊^{1/2}y\*‖²].

Every ψ-dependent term is now a **single fixed** quadratic or linear form: no uniformity over V is needed, and the shift y\* enters only through the last bracket.

### 4.4 The three score events (Chebyshev)

For a fixed symmetric matrix Q supported on range P⊥: E ψᵀQψ = t·tr Q and Var(ψᵀQψ) ≤ ¼‖Q‖_F² (the computation of C2 §3.3). For M = Σ(I + aΣ)^{−1}: ‖M‖_F² ≤ a^{−1}tr M.
- **(Q1) main gain.** P(ψᵀM₊ψ > (1 + η)t·tr M₊) ≤ (4aη²t²·tr M₊)^{−1} ≤ C/(η²k_\*).
- **(Q2) truth shift.** P(|⟨B₊y\*, ψ⟩| > √(Kt)·‖B₊y\*‖₂) ≤ 1/K. On the complement, since ‖B₊y\*‖ ≤ ‖B₊^{1/2}y\*‖: −ω⟨B₊y\*, ψ⟩ − (a/2)‖B₊^{1/2}y\*‖² ≤ sup_x[ω√(Kt)·x − (a/2)x²] = **K·β′/2**. The shift never costs more than a constant, whatever V and ℓ.
- **(Q3) flat part.** P(‖P_Nψ‖² > 3tK) ≤ 1/K; then (ω/(2f′))‖P_Nψ‖² ≤ 3Kβ′/2.
- **(Q4) the dyadic family, for atypical V.** For i ≥ 0 let Σ^{(i)} := 2^iv₁A₀A₀ᵀ, with M^{(i)}, B^{(i)} and κ^{(i)} := 2^{i/6}k_\*.
  - For the finitely many i with κ^{(i)} ≤ n: apply (Q1) with factor 2. Here tr M^{(i)} ≥ (κ^{(i)} − 3)/(2a) (the terms with r ≤ κ^{(i)} − 3 are ≥ ½ by Lemma 2a), so the failure probabilities sum to ≤ C/k_\*.
  - For κ^{(i)} > n: use the deterministic bound ψᵀM^{(i)}ψ ≤ ‖ψ‖₂²/a ≤ n/a.
  - For every i: apply (Q2) with K_i² := K·2^{i/6}; the failure probabilities sum to ≤ 9.2/K.

  By Lemma 2a (crude gain), on this event, for all i: the exponent of §4.3 with Σ₊ = Σ^{(i)} is ≤ **C₂·k_\*·2^{i/6}**, C₂ := β′(π²/6 + 1 + K/2 + 1/(2t)).

### 4.5 Splitting the mixture

Let C_ψ := (2π/a)^{3/2}e^{3Kβ′/2}, c₀ := the least power of 2 above max{(4C₂k_\*)^{6/5}, 8πk_\* + 4 log 2m}, v̄ := c₀v₁, and w an integer with

  **3(C₂k_\*c₀^{1/6} + 2πk_\* + log 2m)/η² ≤ w ≤ [3γη·k_\*·ℓ²/(8(ω² + a)·c₀·n⁴)]^{1/2}.**

- *Atypical maximum, maxⱼVⱼ ∈ (2^{i−1}v₁, 2^iv₁], i > log₂c₀.* Σ_V ⪯ Σ^{(i)} and det^{−1/2} ≤ 1, so the conditional integrand is ≤ C_ψe^{C₂k_\*2^{i/6}} while the probability is ≤ m·e^{−2^{i−1}}. Since 2^{5i/6} ≥ 4C₂k_\*, the total is ≤ C_ψ·2m·e^{−c₀/4} ≤ C_ψe^{−2πk_\*}.
- *Bounded maximum, some block sum off by more than η.* Integrand ≤ C_ψe^{C₂k_\*c₀^{1/6}}, probability ≤ (2m/w)e^{−wη²/3}: total ≤ C_ψe^{−2πk_\*} by the lower bound on w.
- *Typical V (Lemma 2b holds).* Σ₊ := c₊v₁A₀A₀ᵀ + (1 + γ^{−1})v̄𝒟 and Σ₋ := c₋v₁A₀A₀ᵀ, E := γ^{−1}(v₁ + v̄)𝒟 are fixed. By §4.3, (Q1)–(Q3), tr M₊ ≤ tr M(c₊v₁A₀A₀ᵀ) + (1 + γ^{−1})v̄·tr 𝒟 (from (I + aX + aE)^{−1} ⪰ (I + aX)^{−1} − a(I + aX)^{−1}E(I + aX)^{−1}), and Lemma 2a with ϱ = a·c_±·v₁, κ_± = c_±^{1/6}k_\*:

  log(integrand/C_ψ) ≤ (β′/2)(1 + η)·[(π/3)κ₊/(1 − η²/2) + 2] + K·β′/2 − π·κ₋ + 12·log κ₋ + 13 + 2η·k_\*.

  The trace terms are ≤ ηk_\* each by the upper bound on w (tr 𝒟 ≤ (4/3)w²n⁴).

The two conditions on w are compatible when k_\*^{13/10} ≤ c(γ, η, K)·ℓ/n², i.e. **ℓ ≥ C·n^{99/43}**.

### 4.6 Result

On Ω_G, Lemma 1's event and (Q1)–(Q4):

  log 𝒵 ≤ −(π/6)·k_\*·[6·c₋^{1/6} − β′·(1 + η)·c₊^{1/6}/(1 − η²/2)] + 2η·k_\* + C·K + 12 log k_\* + C.

As γ, η ↓ 0: c_± → 1 and β′ → β, so the bracket tends to 6 − β. For β < 6 choose γ, η with the bracket ≥ (1 − ε/2)(6 − β); the terms 2ηk_\* and ωη(f/4)k = O(η)·k_\* are absorbed, and N_ℓ(K′ᶜ) is negligible. This proves Theorem LO. ∎

**Where each lemma entered.** Lemma 1: §4.1 (check loss → Gaussian likelihood, constant 1 − η). Lemma 2a: the cost 2πκ₋ and the gain (π/3)κ₊, both with sharp constants. Lemma 2b: fixed Loewner bounds on typical V. Lemma 3 = §4.2–4.5. Lemma 2c is the special case ψ = 0 of the same computation, stated because it is the sharp companion of L3 and RSB.

---

## 5. What this gives, and what is still open

**Window.** Theorem LO needs ℓ ≥ C·n^{99/43}·polylog (from §4.5; Lemma 1 needs n^{54/25}, Lemma 2c n^{9/4}, C1 with W′ n^{21/11}). The oracle scale n^{5/2} is inside. The exponent 99/43 comes from crude trace bounds on 𝒟 and is not optimized.

**Uniformity — SKETCH.**
- *In ℓ.* The score forms depend on (ω, ℓ, i) only through one scalar, a·2^i·v₁, and are monotone in it. A geometric grid of ratio 1 + η in that scalar, with (Q1) at each point, has total failure probability ≲ (η³·min k_\*)^{−1}. Lemma 1's bodies are nested in ℓ, so a dyadic grid in ℓ (O(log n) points) with K = K_n ≫ log n suffices. This costs a factor e^{CK_n} in the bound, harmless when K_n = o(k_\*), and a factor K_n^{36/5} in the lower end of the window.
- *In ω on a compact.* The same scalar grid covers ω; Lemma 1 and Ω_G are ω-free.

**Consequence for the A-rule — SKETCH (given uniformity).** In `FABLE_A_Arule_lowertail.md` §5, hypothesis (E-III) is needed at scales s near σ̂ only: for |s − σ̂| ≥ ϵ the weight s^{−n}e^{−Q\*/s} is e^{−c(ϵ)n} below the benchmark, while C1's body bound gives Z̃_s(ℓ) ≤ e^{O(nr²)} = e^{o(n)}. On |s − σ̂| < ϵ, Theorem LO applies when **β₀ := t/(f·σ₀) < 6** with margin. Hence, under (LO) with β_c = 6:

  sup_P E_P Π(C·n^{99/43}(log n)^{c} ≤ λ < c₋·n^{5/2}(log n)^{−1/2} | y) → 0.

The posterior of λ puts no mass between n^{2.31} and the oracle scale. This is the (III-c) face on the top of the window, at the learned σ, with no floor.

**Still open.**
- (G4) ℓ between a large constant and n^{99/43}: Lemma 1 has no sup-norm localization there. No route.
- (G5) bounded ℓ: the numerical certificate (DC).
- Necessity (β > 6 ⇒ the evidence grows): §4.2's formula is an identity for the Gaussian-likelihood integral, so a matching lower bound needs only Lemma 1's two-sided form (proved), Jensen over typical V, and lower Chebyshev bounds. Not written.

## 6. Conditions and what was not verified

- Conditions: s(r²) ≤ L; (S) of Lemma 1; κ, κ_± ≥ 4 and κ⁶ = o(n⁵η⁵); the two-sided condition on w in §4.5; C1's (i), (i′) with W′ at level ℓ; k_\* → ∞.
- Standard facts quoted, not re-derived: Ledoux–Talagrand contraction (factor 2 with absolute values); Bernstein's maximal inequality in sub-gamma form; Cauchy interlacing; eigenvalues of circulants; the Gaussian integral identity; concavity of log det; operator convexity of the inverse; Cramér bounds for exponential sums.
- Lemma F′ and Lemma Lev are mine and not yet audited; Lemma 1 uses both (‖w_j‖∞ ≤ 13.1h² is new here).
- All numerical constants (24.4, 17.5, 13.1, 6.3, 9.2, the 24 and 12 in Lemma 2a/2c) were computed by hand once.
- The whole of §4 was derived in one sitting. The points most worth an auditor's time: the expansion in §4.3 (signs of the shift terms), the summability in (Q4), the compatibility window for w in §4.5, and the active-set contraction in Lemma 1 (step 2).
- Nothing here is numerically checked. A cheap check of Lemma 2a: eigenvalues of DDᵀ against (2 sin(π⌊r/2⌋/n))⁶ and (2 sin(π⌊(r+3)/2⌋/n))⁶ for one n.

---

## Theory response (2026-11-23, ~15:00 CT)

**Status: PROVED at fixed (ω, ℓ), one pass, NOT audited.** The cross-family audit (Astra) is the first Tuesday item.

**Checked by Theory:**
- **Lemma 2a, numerically.** The bounds hold at n = 20, 100 and 400 (`lemma2a_check.py`, `.out`).
- **A₀ = D⁺.** We have D·P⊥S = I − D·P_N·S = I and range ⊂ range Dᵀ.
- **The Hölder-threshold correction.** max θ^{5/6}(1−θ)^{1/6} = 0.637 at θ = 5/6, which gives ≈ 2.1. The 5.2 in `FABLE_A_Arule_lowertail.md` §7 is withdrawn.

**Scope consequence (Theory's computation).** Theorem LO uses min_i f_i. On the paper's designs that is the worst-case column of `beta_table.out`:
- **Gaussian τ = 0.05/0.95 fails:** worst-case β = 6.7 ≥ 6, i.e. sd_max/sd_mean = 1.5 > 1.34.
- **Beta τ = 0.95 fails:** 6.6.
- **Covered:** every other paper cell at τ ∈ [0.05, 0.95].

Removing the min-density loss needs the averaged condition (Lemma 2b with position-dependent fᵢ). This is now a named Tuesday piece.

**Data (κ̂ pilot, Engineering 75ad1a4, one seed).** The sign of the evidence slope is positive at τ = 0.05 on this Gaussian design. That supports the averaged condition, not the min-density one.


## Cross-family audit response (Astra, `reviews/AUDIT_astra_LO.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES for Theorem LO at fixed (ω, ℓ).** The strict threshold β < 6 and the window n^{99/43} are confirmed. **The uniform statement and the A-rule consequence (§5) are OPEN.**

Theory re-derived the load-bearing checks before ruling:
- the Cramér rate at η = 1: 1 − log 2 = 0.307 < ⅓;
- the window: 33/10 · 30/43 = 99/43;
- the (1 + 1/n)^m ≤ e interpolation in finding 11.

| # | Finding | Ruling | Change |
|---|---|---|---|
| 1 | Gaussian integration and shift signs: both shift terms negative; envelope fixed before Q2 | HOLDS | Fix the envelope B before applying Q2 in §4.3–4.4 (wording) |
| 2 | Dyadic score events: use H_i = K·2^{i/6}; failures < 9.2/K; count the flat score once | HOLDS | Notation in §4.4 (K_i², the fractional mode count) |
| 3 | Cramér upper tail η²/3 only for η ≤ ½; block-window existence calculation | HOLDS (checked) | §3.2 corrected in place; the §4.5 calculation is replaced by the audit's (ℓ^{43/30} ≳ n^{33/10}) |
| 4 | Coefficient 6 reached with slack after fixing 6 − β; **at the endpoint ℓ = n³/(TVK), "Vℓ = o(n³)" and "q → ∞" do not follow at fixed K** | HOLDS | §6: use C1's finite numerator inequality at the upper endpoint, and a large numerical lower bound on q (via K₀) in place of q → ∞ |
| 5 | Active-set contraction: factor 4; open interval {−s < Zᵢ < s}; shell intersection with K′; requires 3 ≤ X ≤ m/4 | HOLDS | Lemma 1: use the open active interval; state the X range |
| 6 | Lemma 2c is a **one-sided** exponent bound; the nominal coefficient needs A > π, κ₋ → ∞ and slack | HOLDS | §0 table relabelled; the text after 2c is qualified |
| 7 | Spectral input correct; gain-tail cutoff must be an integer J = ⌊ηn⌋; by-product error O(1/r + (r/n)²) | HOLDS (consistent with `lemma2a_check.out`) | Lemma 2a proof: integer cutoff; by-product restricted to r³ = O(n²) |
| 8 | Lemma F′ (trimmed knots) and Lemma Lev hold; ‖(I − P_H)e‖∞ < 13.1h² | HOLDS | **F′ and Lev are now audited** (this also serves Theorem H) |
| 9 | Non-identical noise: use the minimum *lower secant slope*, not the minimum point density; the cut-offs 3.82/1.34 check | HOLDS | §1 remark: secant constant, strict margin. **No averaged-density criterion is supplied** (Tuesday gap 2) |
| 10 | **Genuine gap in §5**: the scalar grid does not control the changing block matrices 𝒟(w), nor the signed shift ψᵀBy\*; K_n ≫ log n and K_n = o(min k\*) conflict at the large window | HOLDS | §5 withdrawn as a proof; uniformity is OPEN |
| 11 | (PLAUSIBLE) Repair route: an ℓ-grid at ratio 1 + 1/n interpolates the whole evidence within a factor e; log-convexity in ω handles compact σ-intervals; it needs stronger score tails (Hanson–Wright type, O(√(d log n) + log n)) on a polynomial grid | HOLDS as a route (the interpolation step was checked) | Becomes Tuesday gap 3's plan |

**Status: Theorem LO is PROVED at fixed (ω, ℓ) and cross-family audited, with the fixes above. Uniformity in (σ, λ), and hence the A-rule posterior statement, is OPEN.**
