# Theorem LB: the posterior is not faster than its spread λ^{−1/3}

*Fable, research sub-agent for Theory, 2026-11-23. Full write-up, replacing the earlier skeleton. Pure mathematics, by hand. No simulation was run; the numerical constants (square roots, fifth roots) were evaluated with a calculator.*

**Audit status (Theory, 2026-11-23): PROVED and cross-family audited** (Astra, `reviews/AUDIT_astra_LB.md`: ACCEPT WITH FIXES). All eleven confirmed fixes and the plausible one are applied in this file; each change is marked **[Fix n]** and listed in the response table at the end.

**Labels.** PROVED = every step is written here and rests only on elementary facts or on audited statements, each cited where used. SKETCH = argument given, a step not written. Anything that needs a lemma not yet available is flagged **NEW LEMMA NEEDED**.

## 0. Result and status

**Claim.** At any fixed σ and deterministic λ, E₀Π(Δ²ₙ(θ − θ\*) ≤ c₀λ^{−1/3} | y) → 0, for a constant c₀ > 0, for every truth with TV⁽³⁾(θ\*) ≤ V and every λ with **λ → ∞ (eventually λ ≥ (32Σ)³) and λ ≤ a₂n^{5/2}/V** (so D = nλ^{−1/3} → ∞). Assumptions: (A1) and the upper half of (A2) only. **[Fix 7]** With an applicable upper theorem (C\* or V0T\* under full (A2); Theorem B under (EM)) this makes n^{−5/6} the exact posterior rate at the oracle, up to (log n)^{1/6} on the upper side. **[Fix 8]** Above the oracle the statement holds only inside the β-dependent tuning window of §8.3.

**Method.** A prior-mass argument (in the style of Castillo's lower bounds for Gaussian priors): the prior puts too little mass on a small ball around the truth for the evidence to compensate. It is **not** an anti-concentration argument for the posterior, and it uses no singular vectors and no Gaussian twin.

| # | Item | Status |
|---|---|---|
| 1 | Lemma A: block third-difference functionals L_k | PROVED (§2) |
| 2 | Lemma B: a symmetric log-concave density is ≤ 1/√(2·variance) | PROVED (§3) |
| 3 | Lemma L3⁻: small-ball **upper** bound, uniform over centres, ℓ₂ and Huber forms | PROVED (§4) |
| 4 | Lemma L3⁺: L3 without the logarithm | PROVED (§5), from Lemma F and L3 Step 6 (both audited) |
| 5 | Lemma N: E₀e^{−ωℛ(δ)} ≤ e^{c_ω H(δ)}, moment-free, no margin | PROVED (§6) |
| 6 | Denominator comparison (L6 with three centre routes) | PROVED (§7), from audited L6, L4, L4q, L4q-M |
| 7 | **Theorem LB** (fixed σ, deterministic λ), explicit finite-n bound | PROVED (§8) |
| 8 | Uniform in σ on compacts; σ learned at deterministic λ | PROVED (§9.1–9.2), from audited L6 and Lemma S §2 |
| 9 | λ mixed: lower bound on {λ ≤ λ_max}; V0T with constant b₀ | PROVED (§9.3), **log-free** (closed by the audit, [Fix 11]) |
| 10 | Posterior-dependent centre (true "spread" statement) | Partial result PROVED (§10); general statement **NEW LEMMA NEEDED** |
| 11 | Sharp lower bound above the oracle (bias-dominated λ) | **NEW LEMMA NEEDED** (§11) |
| 12 | Upper-side logarithm for any σ | SKETCH (§11) |

---

## 1. Setting and the audited statements used

- n ≥ 5, m = n − 3, D = D⁽³⁾ with (Dθ)ᵢ = θ_{i+3} − 3θ_{i+2} + 3θ_{i+1} − θᵢ, 1 ≤ i ≤ m. (If the repository's D has the opposite sign, replace L_k by −L_k below; nothing changes.)
- θ = Nc + Su, u = Dθ, DS = I, N an orthonormal basis of the quadratic sequences (L5). A := n^{−1/2}P⊥S, B_r := {u : ‖Au‖₂ ≤ r}, φ(r) := −log Π_λ(B_r).
- Π_λ = Laplace(λ)^{⊗m}, density ∏(λ/2)e^{−λ|uⱼ|}; ν = dc ⊗ Π_λ; N_ω(B) = ∫_B e^{−ωℛ}dν; Π(B | y) = N_ω(B)/N_ω(ℝⁿ); ω = 1/σ.
- δ = θ − θ\*, Zᵢ = yᵢ − θ\*ᵢ, Xᵢ(δ) = ρ_τ(Zᵢ − δ) − ρ_τ(Zᵢ), ℛ(δ) = ΣXᵢ(δᵢ), mᵢ = E Xᵢ.
- H(δ) := Σᵢmin(δᵢ², |δᵢ|) = nΔ²ₙ(δ). x := n^{5/2}/(λr), so that **x^{2/5} = n·(rλ)^{−2/5}**.

**Audited statements used** (file; where used here).
- (L2) |Xᵢ(δ)| ≤ |δ|; Xᵢ(δ) = (1−τ)δ − clip(Zᵢ, 0, δ) for δ > 0 and τa − clip(−Zᵢ, 0, a) for δ = −a < 0; Fᵢ(0−) ≤ τ ≤ Fᵢ(0) (`L2_excess_risk.md`; §6).
- (L5) c-sections: ‖δ‖₂ ≥ ‖c − c̄(u)‖₂ (`L5_normalization.md`; §4.4).
- (B-2) H(δ) ≥ min(‖δ‖₂², ‖δ‖₂) (`THEOREM_B_COMPLETE.md` §3 Step 2; §4.4).
- (L3-1) scale mixture uⱼ = √Vⱼ·ξⱼ, Vⱼ ~ Exp(rate λ²/2); (L3-6) P(Σ_{q≥1}b·q^{−6}ζ_q² ≤ r²) ≥ (3/4)·e^{−3.85K} with K = ⌈(8b/(5r²))^{1/5}⌉ (`L3_small_ball.md` Steps 1, 6; §5).
- (F) max_j‖(I − P_J)Seⱼ‖₂ ≤ C_F(n/J)^{5/2}, C_F = 29.1, for n ≥ 4 and 1 ≤ J ≤ m; P_J projects onto a space of dimension J + 3 containing range N (`FABLE_lemmaF_C2.md` §1; §5).
- (L4q-R2) ‖sⱼ‖₂² ≤ n⁵/20 (`L4q_quadratic_shift.md`; §5).
- (L6) evidence lower bound (`L6_evidence_lower_bound.md`; §7).
- (L4), (L4q half-radius form), (L4q-M) (`L4_l1_shift.md`, `L4q_quadratic_shift.md`; §7).
- (S §2) compact containment of σ (`astra_sigma_concentration.md`; §9.2). (V2T Steps 2–3) (`FABLE_V2T_proof.md`; §9.3).

---

## 2. Lemma A: block third-difference functionals — PROVED

Fix an integer h ≥ 1 with 4h ≤ n. Put K := ⌊n/(4h)⌋ ≥ 1, i_k := (k−1)·4h + 1 and I_k := {i_k, …, i_k + 4h − 1} for 1 ≤ k ≤ K. The I_k are disjoint subsets of {1, …, n}.

For i + 3h ≤ n let (Δ_h³θ)(i) := θ_{i+3h} − 3θ_{i+2h} + 3θ_{i+h} − θᵢ, and define

  **L_k(θ) := h⁻¹·Σ_{s=0}^{h−1}(Δ_h³θ)(i_k + s).**

The indices used are i_k + s + ph with 0 ≤ s < h and p ∈ {0, 1, 2, 3}. The map (s, p) ↦ s + ph is a bijection onto {0, …, 4h − 1}, so L_k uses each coordinate of I_k exactly once and no other.

**Lemma A.**
- **(a)** L_k(q) = 0 for every quadratic sequence q. Hence L_k(Nc + Su) = L_k(Su).
- **(b)** L_k(θ)² ≤ (20/h)·Σ_{i∈I_k}θᵢ² for every θ ∈ ℝⁿ.
- **(c)** L_k(Nc + Su) = Σ_{j=0}^{4h−4}w_h(j)·u_{i_k+j}, where w_h := h⁻¹·1_h^{∗4} is h⁻¹ times the four-fold convolution of the indicator of {0, …, h−1}. w_h > 0 on {0, …, 4h − 4}, Σⱼw_h(j) = h³, and **‖w_h‖₂² ≥ h⁵/4**. The index sets U_k := {i_k, …, i_k + 4h − 4} are disjoint subsets of {1, …, m}.
- **(d)** Under Π_λ the variables Λ_k := L_k(Su), 1 ≤ k ≤ K, are independent, symmetric, with Var Λ_k = (2/λ²)‖w_h‖₂² ≥ h⁵/(2λ²).

*Proof.*
(a) The step-h difference θ ↦ θ_{·+h} − θ_· lowers the degree of a polynomial sequence by one; three applications annihilate degree ≤ 2.

(b) By Cauchy–Schwarz over s, L_k(θ)² ≤ h⁻¹Σ_s(Δ_h³θ)(i_k + s)². By Cauchy–Schwarz with the coefficients (1, −3, 3, −1), whose squares sum to 20, (Δ_h³θ)(i)² ≤ 20·Σ_{p=0}^{3}θ²_{i+ph}. Summing over s and using the bijection gives the claim.

(c) Let E be the shift, (Eθ)ᵢ = θ_{i+1}. As polynomials in E: E^h − 1 = (E − 1)(1 + E + … + E^{h−1}), so (E^h − 1)³ = (1 + E + … + E^{h−1})³·(E − 1)³ = Σ_{l=0}^{3h−3}B_h(l)E^l·(E − 1)³, with B_h := 1_h^{∗3}. Both sides have degree 3h, so applying them at an index i with i + 3h ≤ n involves only θᵢ, …, θ_{i+3h}. Since ((E − 1)³θ)ᵢ = (Dθ)ᵢ = uᵢ for i ≤ m: (Δ_h³θ)(i) = Σ_{l=0}^{3h−3}B_h(l)u_{i+l}, and i + 3h − 3 ≤ m. Averaging over s gives the formula with w_h(j) = h⁻¹Σ_s B_h(j − s) = h⁻¹(1_h ∗ B_h)(j). The four-fold convolution counts the representations j = p₁ + p₂ + p₃ + p₄ with 0 ≤ p_i < h; it is positive exactly on {0, …, 4h − 4} and sums to h⁴. By Cauchy–Schwarz on a support of 4h − 3 points, ‖w_h‖₂² ≥ (h³)²/(4h − 3) ≥ h⁵/4. The largest index is i_k + 4h − 4 ≤ 4Kh − 3 ≤ n − 3 = m, and U_k ⊂ I_k.

(d) Under Π_λ the uⱼ are i.i.d. symmetric with variance 2/λ², and the U_k are disjoint. ∎

---

## 3. Lemma B: sup of a symmetric log-concave density — PROVED

**Lemma B.** Let g be an even log-concave probability density on ℝ with variance v. Then sup g = g(0) ≤ 1/√(2v).

*Proof.* An even log-concave function is maximal at 0 and nonincreasing on [0, ∞); a log-concave density is bounded and has all moments. Put G := g(0) and ℓ(x) := G·e^{−2G|x|}, a probability density with variance 1/(2G²). On [0, ∞) let ψ := log g − log ℓ = log g(x) − log G + 2Gx. It is concave, takes values in [−∞, ∞), and ψ(0) = 0. Let x₁ := sup{x ≥ 0 : ψ(x) ≥ 0} ∈ [0, ∞]. If ψ(a) ≥ 0 then ψ ≥ 0 on [0, a] by concavity. So g ≥ ℓ on [0, x₁) and g ≤ ℓ on (x₁, ∞).
- If x₁ ∈ {0, ∞}, then g − ℓ has a constant sign on (0, ∞) and integral 0 there, so g = ℓ a.e. and v = 1/(2G²).
- Otherwise (x² − x₁²)(g(x) − ℓ(x)) ≤ 0 for all x ≥ 0, and ∫₀^∞(g − ℓ) = 0, so ∫₀^∞x²(g − ℓ)dx = ∫₀^∞(x² − x₁²)(g − ℓ)dx ≤ 0.

In both cases v = 2∫₀^∞x²g ≤ 2∫₀^∞x²ℓ = 1/(2G²). ∎

**Corollary B1.** Under Π_λ each Λ_k has a density bounded by **λ/h^{5/2}** at every point.

*Proof.* Λ_k = Σⱼw_h(j)u_{i_k+j} is a sum of independent variables with even log-concave densities (w_h(j) > 0; a scaled Laplace density is log-concave). Convolution preserves evenness and log-concavity (Prékopa). By Lemma A(d) and Lemma B, the density is ≤ (2·h⁵/(2λ²))^{−1/2} = λ/h^{5/2}. ∎

**Lemma C (volume).** Let X₁, …, X_K be independent real variables with densities bounded by β. For every a ∈ ℝ^K, ρ > 0 and G ⊂ {1, …, K} with |G| = g ≥ 1:

  P(Σ_{k∈G}(X_k − a_k)² ≤ ρ²) ≤ β^g·π^{g/2}ρ^g/Γ(g/2 + 1) ≤ (√(2πe/g)·βρ)^g.

*Proof.* The joint density of (X_k)_{k∈G} is ≤ β^g; the ball has volume π^{g/2}ρ^g/Γ(g/2 + 1); Γ(t + 1) ≥ (t/e)^t. ∎

---

## 4. Lemma L3⁻: small-ball upper bound at every centre — PROVED

### 4.1 Statement

Let θ₀ ∈ ℝⁿ be **any** vector (the centre), λ > 0, r > 0, n ≥ 5. Define

  𝒰₂(θ₀, r) := {u : ∃c ∈ ℝ³, ‖Nc + Su − θ₀‖ₙ ≤ r},  𝒰_H(θ₀, r) := {u : ∃c ∈ ℝ³, H(Nc + Su − θ₀) ≤ nr²}.

Since H(δ) ≤ ‖δ‖₂², 𝒰₂ ⊂ 𝒰_H. For θ₀ = Nc₀ + Su₀, 𝒰₂(θ₀, r) = u₀ + B_r.

**Lemma L3⁻.**
- **(ℓ₂ form)** If 58.4·(rλ)^{2/5} ≤ n, then 𝒰₂(θ₀, r) is contained in a measurable set of Π_λ-mass ≤ **exp(−min{n/8, x^{2/5}/117})**.
- **(Huber form)** If 116.4·(rλ)^{2/5} ≤ n and r² ≤ min{1/16, λ^{−1/3}/168}, then 𝒰_H(θ₀, r) is contained in a measurable set of Π_λ-mass ≤ **exp(−min{n/16, x^{2/5}/466})**.

Both bounds are uniform in θ₀. In particular sup_{u₀}Π_λ(u₀ + B_r) ≤ exp(−min{n/8, x^{2/5}/117}), so φ(r) ≥ min{n/8, x^{2/5}/117}.

### 4.2 Proof of the ℓ₂ form

Let h := ⌈(142.2·rλ)^{2/5}⌉ ≥ 1. Then h ≤ max{1, 2(142.2·rλ)^{2/5}} ≤ max{1, 14.6(rλ)^{2/5}} (142.2^{2/5} = 7.264), so 4h ≤ n by hypothesis and n ≥ 4. Let K = ⌊n/(4h)⌋ ≥ n/(8h).

Let u ∈ 𝒰₂(θ₀, r) with witness c, δ := Nc + Su − θ₀, and a_k := L_k(θ₀). By Lemma A(a), L_k(δ) = Λ_k(u) − a_k. By Lemma A(b) and disjointness of the I_k:

  Σ_{k=1}^{K}(Λ_k(u) − a_k)² ≤ (20/h)·Σ_kΣ_{i∈I_k}δᵢ² ≤ 20nr²/h.

So 𝒰₂(θ₀, r) ⊂ E := {u : Σ_k(Λ_k(u) − a_k)² ≤ 20nr²/h}, a measurable set. By Lemma A(d), Corollary B1 and Lemma C (β = λ/h^{5/2}, ρ² = 20nr²/h, g = K):

  Π_λ(E) ≤ (√(2πe/K)·√(20n/h)·rλ/h^{5/2})^K ≤ (√(320πe)·rλ/h^{5/2})^K ≤ (52.3·rλ/h^{5/2})^K,

using 20n/(hK) ≤ 160. Since h^{5/2} ≥ 142.2·rλ and 52.3·e ≤ 142.2, the base is ≤ e⁻¹. Hence Π_λ(E) ≤ e^{−K} ≤ exp(−n/(8h)) ≤ exp(−min{n/8, n(rλ)^{−2/5}/116.8}). ∎

### 4.3 Proof of the Huber form

Let h := ⌈(805·rλ)^{2/5}⌉ ≥ 1, so h ≤ max{1, 29.1(rλ)^{2/5}} (805^{2/5} = 14.53) and 4h ≤ n. K ≥ n/(8h), g := ⌈K/2⌉ ≥ n/(16h).

*Clean blocks.* Let u ∈ 𝒰_H(θ₀, r) with witness c and δ as before. Let 𝔅 := {i : |δᵢ| > 1}. Each i ∈ 𝔅 contributes |δᵢ| > 1 to H(δ), so |𝔅| ≤ H(δ) ≤ nr². The hypotheses give r²h ≤ max{r², 29.1·r^{12/5}λ^{2/5}} ≤ 1/16 (the second term because r^{12/5}λ^{2/5} = (r²λ^{1/3})^{6/5} ≤ 168^{−6/5} ≤ 1/465.6). Hence nr² ≤ n/(16h) ≤ K/2. So at most ⌊K/2⌋ blocks meet 𝔅, and at least g blocks are clean. Choose a set G(δ) of exactly g clean blocks.

*On clean blocks* δᵢ² = min(δᵢ², |δᵢ|), so by Lemma A(b): Σ_{k∈G(δ)}(Λ_k(u) − a_k)² ≤ (20/h)·H(δ) ≤ 20nr²/h.

*Union bound.* 𝒰_H(θ₀, r) ⊂ ∪_{|G|=g}E_G, with E_G := {u : Σ_{k∈G}(Λ_k(u) − a_k)² ≤ 20nr²/h}. There are at most 2^K ≤ 4^g sets G. By Lemma C, with 20n/(hg) ≤ 320:

  Π_λ(∪E_G) ≤ 4^g·(√(640πe)·rλ/h^{5/2})^g ≤ (296·rλ/h^{5/2})^g ≤ e^{−g},

because √(640πe) ≤ 74, h^{5/2} ≥ 805·rλ and 296·e ≤ 805. Finally e^{−g} ≤ exp(−n/(16h)) ≤ exp(−min{n/16, n(rλ)^{−2/5}/465.6}). ∎

### 4.4 Consequence for ν — PROVED

Let θ\* = Nc\* + Su\* be any vector and ℋ_r := {(c, u) : H(θ − θ\*) ≤ nr²} = {Δ²ₙ(θ − θ\*) ≤ r²}. Under the hypotheses of the Huber form:

  **ν(ℋ_r) ≤ V₃·R_c³·exp(−min{n/16, x^{2/5}/466}),  R_c := max(√n·r, nr²).**

*Proof.* For fixed u, by (B-2) and (L5), H(δ) ≥ min(ρ², ρ) with ρ := ‖c − c̄(u)‖₂; so the c-section of ℋ_r lies in a ball of radius R_c. It is empty unless u ∈ 𝒰_H(θ\*, r) ⊂ ∪E_G. Integrate over u. ∎

**Remarks.**
- No condition on θ₀ or θ\* is used: no smoothness, no (A3).
- For the ℓ₂ ball alone, uniformity over centres also follows from Anderson's inequality (Π_λ is symmetric log-concave, B_r symmetric convex). The Huber set is not convex, so the block argument is needed there. The block argument also gives the exponent directly.
- The exponent 2/5 and the absence of a logarithm match L3's sharpness remark (T-03 slope 0.404).

---

## 5. Lemma L3⁺: L3 without the logarithm — PROVED

**Lemma L3⁺.** For n ≥ 5, λ > 0, r > 0: **φ(r) ≤ 75·x^{2/5} + 5**, x = n^{5/2}/(λr).

With §4: min{n/8, x^{2/5}/117} ≤ φ(r) ≤ 75·x^{2/5} + 5 whenever 58.4(rλ)^{2/5} ≤ n.

*Proof.* (The eigenvalue index is q, to keep r for the radius.)

*Step 1 (conditioning).* By (L3-1), given V = (V₁, …, V_m), Au ~ N(0, Σ_V) with Σ_V = MMᵀ, M := A·diag(V)^{1/2}. Let μ₁ ≥ … ≥ μ_m ≥ 0 be the squared singular values of M. Then P(‖Au‖₂ ≤ r | V) = P(Σ_{q≤m}μ_qζ_q² ≤ r²), ζ_q i.i.d. N(0, 1).

*Step 2 (tail sums of the spectrum).* Fix 1 ≤ J ≤ m and the projector P_J of (F). Since range N ⊂ range P_J: P_JP⊥ = P_J − P_N has rank J, and (I − P_J)P⊥ = I − P_J. So P_JM has rank ≤ J and (I − P_J)M = n^{−1/2}(I − P_J)S·diag(V)^{1/2}. By Weyl's inequality for singular values (σ_{i+j−1}(X + Y) ≤ σ_i(X) + σ_j(Y), with X = P_JM, i = J + 1): σ_{J+j}(M) ≤ σ_j((I − P_J)M) for all j ≥ 1. Squaring and summing:

  Σ_{q>J}μ_q ≤ ‖(I − P_J)M‖²_F = n⁻¹·ΣⱼVⱼ‖(I − P_J)Seⱼ‖₂² ≤ C_F²·n⁴·J^{−5}·S_V,  S_V := ΣⱼVⱼ,

by (F). **The uniform column bound of Lemma F is what makes the sum of the Vⱼ appear instead of their maximum**; this is where L3's log m is avoided.

*Step 3 (event).* E S_V = 2m/λ². Let Ω_V := {S_V ≤ 4m/λ²}; P(Ω_V) ≥ ½ by Markov. On Ω_V, for every 1 ≤ J ≤ m: Σ_{q>J}μ_q ≤ b₁J^{−5}, b₁ := 4C_F²n⁵/λ².

*Step 4 (individual eigenvalues, on Ω_V).*
- For 2 ≤ q ≤ m take J := ⌊q/2⌋. Then 1 ≤ J ≤ m, J ≥ q/3 and q − J ≥ q/2. Since the μ's decrease, (q − J)μ_q ≤ Σ_{J<q′≤q}μ_{q′} ≤ b₁J^{−5}, so μ_q ≤ (2/q)·b₁·(3/q)⁵ = 486·b₁·q^{−6}.
- For q = 1: μ₁ ≤ tr Σ_V = ΣⱼVⱼ‖Aeⱼ‖₂² ≤ S_V·n⁴/20 ≤ n⁵/(5λ²) ≤ 486b₁, by (L4q-R2).

So μ_q ≤ b·q^{−6} for all q ≥ 1, with b := 486b₁ = 1944·C_F²·n⁵/λ².

*Step 5 (series).* Increasing weights and appending terms only decrease the probability, so on Ω_V, by (L3-6): P(‖Au‖₂ ≤ r | V) ≥ P(Σ_{q≥1}b·q^{−6}ζ_q² ≤ r²) ≥ (3/4)e^{−3.85K₀}, K₀ := ⌈(8b/(5r²))^{1/5}⌉.

*Step 6 (assembly).* Π_λ(B_r) ≥ P(Ω_V)·(3/4)e^{−3.85K₀} ≥ (3/8)e^{−3.85K₀}. With C_F = 29.1: (8b/5)^{1/5} = (3110.4·846.81)^{1/5}·(n⁵/λ²)^{1/5} < 19.24·(n⁵/λ²)^{1/5} **[Fix 4]** (rigorous: 3110.4·846.81 = 2 633 917.8 < 19.24⁵ = 2 636 485.2, by raising to the fifth power), so K₀ ≤ 1 + 19.24·x^{2/5} and

  φ(r) ≤ log(8/3) + 3.85 + 74.1·x^{2/5} ≤ 75·x^{2/5} + 5. ∎

**Remark [Fix 4].** The argument holds also when the Gaussian-series cutoff K₀ exceeds m: (L3-6) is applied to the infinite series Σ_{q≥1}b q^{−6}ζ_q², which dominates the finite one.

**Remark.** With V ≡ 1 Steps 2 and 4 give σ_q(A) ≲ n^{5/2}q^{−3} without Horn's inequality; this is not used.

---

## 6. Lemma N: the numerator in expectation — PROVED

**Lemma N.** Assume (A1) and only that θ\*ᵢ is a τ-quantile of yᵢ. For every ω > 0 and δ ∈ ℝⁿ:

  **E₀e^{−ωℛ(δ)} ≤ exp(c_ω·H(δ)),  c_ω := max(ω, ω²/8).**

*Proof.* Fix i and write δ for δᵢ.
- By (L2), Xᵢ(δ) takes values in an interval of length |δ| ([−τδ, (1−τ)δ] for δ > 0; [−(1−τ)a, τa] for δ = −a < 0), and |Xᵢ(δ)| ≤ |δ|.
- mᵢ(δ) ≥ 0. Indeed, for δ > 0, mᵢ(δ) = (1−τ)δ − E clip(Zᵢ, 0, δ) = ∫₀^δ(Fᵢ(s) − τ)ds, and Fᵢ(s) ≥ Fᵢ(0) ≥ τ for s ≥ 0. For δ = −a < 0, mᵢ = ∫₀^a(τ − Fᵢ((−s)−))ds, and Fᵢ(t−) ≤ Fᵢ(0−) ≤ τ for t ≤ 0. No margin condition is used.
- Hoeffding's lemma: E e^{−ω(Xᵢ − mᵢ)} ≤ e^{ω²δ²/8}. So E e^{−ωXᵢ} ≤ e^{−ωmᵢ + ω²δ²/8} ≤ e^{ω²δ²/8}. Also e^{−ωXᵢ} ≤ e^{ω|δ|}.

Hence E e^{−ωXᵢ(δᵢ)} ≤ exp(min{ω²δᵢ²/8, ω|δᵢ|}) ≤ exp(c_ω·min(δᵢ², |δᵢ|)), and the product over i uses (A1). ∎

**Consequence.** For the deterministic set ℋ_r centred at θ\*, Tonelli gives

  E₀N_ω(ℋ_r) = ∫_{ℋ_r}E₀e^{−ωℛ(δ)}dν ≤ e^{c_ω nr²}·ν(ℋ_r).

Tonelli applies because the integrand is nonnegative and ν is σ-finite. **[Fix 5]** It applies also to a jointly measurable data-dependent indicator, but then the indicator stays inside the expectation, and no pointwise bound by e^{c_ω nr²}ν(·) follows; this is why the bad set is the deterministic ball around θ\* (see §10). mᵢ ≥ 0 holds also when Fᵢ has an atom at 0 (quantile optimality).

This replaces "E₀(likelihood ratio) ≤ 1", which fails for σ < σ̄. The price e^{c_ω nr²} is negligible because r² is a small multiple of λ^{−1/3}.

---

## 7. The denominator comparison — PROVED from audited lemmas

**(L6).** Under (A1) and upper (A2), for ω > 0, ε_d ∈ (0, 1) and a deterministic centre u_h with ‖P⊥S(u_h − u\*)‖ₙ ≤ ε_d/2: with P₀-probability ≥ 1 − 1.44/(nε_d²),

  N_ω(ℝⁿ) ≥ V₃(ε_d√n/2)³·Π_λ(u_h + B_{ε_d/2})·exp{−ω(1.44C₁ + 1)nε_d²},  C₁ = max(f̄/2, 1/L).

Throughout, **ε_d² := λ^{−1/3}** and **D := nλ^{−1/3} = nε_d²**. Then by L3⁺: φ(ε_d/2) ≤ 75·(2n^{5/2}/(λε_d))^{2/5} + 5 = 75·2^{2/5}·D + 5 ≤ 99D + 5, since n(λε_d)^{−2/5} = n·λ^{−2/5}·λ^{1/15} = D.

**Definition (shift budget).** A pair (θ\*, λ) is **β-admissible** if there is a deterministic u_h with ‖P⊥S(u_h − u\*)‖ₙ ≤ ε_d/2 and −log Π_λ(u_h + B_{ε_d/2}) ≤ φ(ε_d/2) + β·D.

**Three routes.**
- **(R0) Quadratic truth.** u\* = 0, u_h = 0: β = 0, for every λ.
- **(R1) ℓ₁ shift (L4), u_h = u\*.** Π_λ(u\* + B) ≥ e^{−λ‖u\*‖₁}Π_λ(B) and ‖u\*‖₁ ≤ V/n² give **β = Vλ^{4/3}/n³**, for every λ and every truth with (A3). β ≤ β₀ iff λ ≤ (β₀n³/V)^{3/4}.
- **(R2) Quadratic shift (L4q half-radius + L4q-M).** Let w := ⌊n(ε_d²/(4C_MV²))^{1/5}⌋ and u_h the L4q-M centre. Hypotheses, exactly those of the audited lemmas:
  - (h1) n/√3 ≤ λε_d/4 (gives δ_A ≤ λε_d/4);
  - (h2) λε_d ≥ 102·n^{10/7}(log m)^{1/7} (gives K′ ≤ 1, c_{K′} ≤ 3.144; it implies (h1));
  - (h3) 3 ≤ w ≤ m/2.

  Then ‖S(u\* − u_h)‖ₙ² ≤ C_MV²(w/n)⁵ ≤ ε_d²/4, and with n/w ≤ 2(4C_MV²/ε_d²)^{1/5}:

  c_{K′}λ²‖u_h‖₂² ≤ 3.144·λ²C_M²V²/(n⁴w) ≤ C_b·λ²V^{12/5}n^{−5}ε_d^{−2/5},  C_b := 6.288·4^{1/5}·C_M^{11/5}.

  Dividing by D and using ε_d² = λ^{−1/3}: **β = C_b·(Vλ/n^{5/2})^{12/5}**. With λε_d = λ^{5/6}, (h2) reads λ ≥ 102^{6/5}·n^{12/7}(log m)^{6/35}. For fixed V > 0, (h3) holds for n ≥ n₀(V) whenever λ → ∞ and λ ≤ a₂n^{5/2}/V.

**[Fix 6]** Remarks: (R0) has zero shift charge; (h2) implies L4q's column-increment condition; along (R2) w/n → 0, and at the oracle w grows at least like n^{5/6} for fixed V.

**Coverage.** (R1) covers every λ ≤ (β₀n³/V)^{3/4} ≍ n^{9/4}; (R2) covers n^{12/7}(log n)^{6/35} ≲ λ ≤ a₂n^{5/2}/V with β ≤ C_b·a₂^{12/5}. Since 12/7 < 9/4 the two ranges overlap: **every λ → ∞ with λ ≤ a₂n^{5/2}/V is β-admissible with β ≤ max{β₀, C_b·a₂^{12/5}}**, for n ≥ n₀(V, a₂, β₀).

---

## 8. Theorem LB — PROVED

### 8.1 Statement

Assume (A1) and the upper half of (A2) (constants L, f̄; C₁ = max(f̄/2, 1/L)). Let n ≥ 5, ω > 0, λ > 0, and let (θ\*, λ) be β-admissible (§7). Put

  **Σ := 100 + β + ω(1.44C₁ + 1) + c_ω,  c₀ := (932·Σ)^{−5},  D := nλ^{−1/3}.**

If **(32Σ)³ ≤ λ ≤ (n/42)³**, then

  **E₀Π(Δ²ₙ(θ − θ\*) ≤ c₀·λ^{−1/3} | y) ≤ 1.44/D + 8·D^{3/2}·exp{5 − (Σ + 1)·D}.**

In particular, along any sequence with λ_n → ∞ and λ_n = o(n³) (so D → ∞) for which β stays bounded, the left side → 0, uniformly over the laws with the given (L, f̄) and over the β-admissible truths. **[Fix 7]** For the uniform statement take one c₀ computed from a common upper bound β̄ ≥ β over the class; the lower restriction (32Σ)³ ≤ λ then holds eventually because λ_n → ∞. Since {‖δ‖²ₙ ≤ r²} ⊂ {Δ²ₙ(δ) ≤ r²}, the same holds for ‖θ − θ\*‖²ₙ.

No lower margin, no (EM), no moment condition, no condition σ ≥ σ̄.

### 8.2 Proof

Let r² := c₀λ^{−1/3}, so nr² = c₀D, (rλ)^{2/5} = c₀^{1/5}λ^{1/3} = λ^{1/3}/(932Σ), and x^{2/5} = n(rλ)^{−2/5} = 932Σ·D.

*Hypotheses of L3⁻ (Huber form).* 116.4(rλ)^{2/5} ≤ 116.4·n/(42·932Σ) ≤ n. r² ≤ λ^{−1/3}/168 because c₀ ≤ 93200^{−5}; r² ≤ 1/16 because λ ≥ 1. Also n/16 ≥ x^{2/5}/466 = 2ΣD iff λ^{1/3} ≥ 32Σ, which holds. So by §4.4,

  ν(ℋ_r) ≤ V₃R_c³·e^{−2ΣD},  R_c = max(√(c₀D), c₀D) ≤ D (as c₀ < 1 ≤ D; D ≥ 42 because λ ≤ (n/42)³).

*Numerator.* By Lemma N: E₀N_ω(ℋ_r) ≤ e^{c_ω c₀D}·V₃·D³·e^{−2ΣD} ≤ V₃D³·exp{−(2Σ − c_ω)D}.

*Denominator.* ε_d = λ^{−1/6} < 1. By (L6), β-admissibility and L3⁺, on an event Ω₆ with P₀(Ω₆ᶜ) ≤ 1.44/D:

  N_ω(ℝⁿ) ≥ 𝔏 := V₃(√D/2)³·exp{−(99 + β + ω(1.44C₁ + 1))D − 5}.

*Combine.* Π(ℋ_r | y) ≤ 1_{Ω₆ᶜ} + N_ω(ℋ_r)/𝔏, and 𝔏 is deterministic, so

  E₀Π(ℋ_r | y) ≤ 1.44/D + 8·D^{3/2}·exp{5 − [2Σ − c_ω − 99 − β − ω(1.44C₁ + 1)]·D}.

The prefactor is V₃D³/(V₃(√D/2)³) = 8D^{3/2}. The bracket equals 2Σ − (Σ − 1) = Σ + 1. ∎

### 8.3 Range of λ and of truths, exactly

- **Truths.** Any θ\* ∈ ℝⁿ enters the numerator (§4 has no condition on the centre). The truth enters only through β: quadratic truths (β = 0); truths with TV⁽³⁾(θ\*) ≤ V through (R1) or (R2).
- **λ.** (32Σ)³ ≤ λ ≤ (n/42)³ and β-admissibility. With §7's coverage: **all deterministic λ_n → ∞ with λ_n ≤ a₂n^{5/2}/V** (V > 0 fixed), and **all λ_n → ∞ with λ_n = o(n³)** for quadratic truths.
- **Above the oracle [Fix 7].** For λ ≫ n^{5/2}/V, β → ∞ and Σ grows with β, so **both** tuning restrictions, (32Σ)³ ≤ λ and λ ≤ (n/42)³, must be re-checked at the growing budget; they are not automatic. Example: with the (R2) budget β = C_b(Vλ/n^{5/2})^{12/5}, λ = n^{59/20} and V fixed give β ≍ n^{27/25}, while λ^{1/3} = n^{59/60}, so (32Σ)³ ≤ λ fails and the theorem certifies nothing there. Where both restrictions do hold, c₀ ≍ Σ^{−5} and the bound is far from the true (bias-dominated) rate; see §11.
- **σ.** Any fixed ω > 0. c₀ depends on ω through Σ.

### 8.4 Corollary: the exact rate at the oracle

Let a₁n^{5/2}/V ≤ λ ≤ a₂n^{5/2}/V. Then λ^{−1/3} ≥ (V/a₂)^{1/3}n^{−5/6} and, in P₀-probability,

  c₀·(V/a₂)^{1/3}·n^{−5/6} ≤ Δ²ₙ(θ − θ\*) ≤ M·(log n)^{1/6}·V^{1/3}·n^{−5/6}

with posterior mass → 1. The lower bound is Theorem LB (any fixed σ; (A1) and upper (A2) only). **[Fix 8]** The upper bound requires more:
- at a fixed σ in the (EM) range: Theorem B;
- at an arbitrary fixed σ: the fixed-scale steps C\*-3 and C\*-4 of `FABLE_A_n56.md` §2.2, applied on a compact ω-interval containing 1/σ, under full (A2), (A3) and the oracle tuning conditions;
- at the learned σ: Theorem C\* itself, which adds the scale-containment hypotheses of Lemma S.

So **under (A1) and upper (A2) alone only the lower conclusion is established.** The two-sided statement holds in Δ²ₙ, the loss of LB; since Δ²ₙ ≤ ‖·‖²ₙ, the upper bound transfers from ‖·‖²ₙ to Δ²ₙ, and the lower bound transfers from Δ²ₙ to ‖·‖²ₙ, so it holds in ‖·‖²ₙ as well. **The exponent 5/6 is exact; the gap is the factor (log n)^{1/6} on the upper side** (§11).

### 8.5 Remark: dependence of the constant on σ — SKETCH

c₀ ≈ 10^{−25} is crude (from 75, 466 and the choice ε_d² = λ^{−1/3}). Taking ε_d² = a·λ^{−1/3} and the ℓ₂ form, the exponent is −D[c^{−1/5}/117 − ω²c/8 − 99a^{−1/5} − β_a − ω(1.44C₁ + 1)a]; minimizing 99a^{−1/5} + Aa over a, A := ω(1.44C₁ + 1), gives the formal optimum a = (99/(5A))^{5/6} and cost 6(99/5)^{5/6}A^{1/6} ≈ 72.2·A^{1/6} **[Fix 12]**; if ω varies, the radius and tuning restrictions must be re-checked. So for β = 0 and small ω the admissible constant scales as **c ∝ ω^{−5/6}**, which reproduces the memo's spread law κ^{−5/6}λ^{−1/3}. For large ω the tilt term forces c ≲ ω^{−5/3}. Not written out.

---

## 9. Extensions

### 9.1 Uniform in σ on compacts — PROVED

Let 0 < ω₁ ≤ ω₂ < ∞ and define Σ, c₀ with ω := ω₂ (note c_ω is nondecreasing in ω). Then, under the hypotheses of Theorem LB,

  E₀ sup_{ω∈[ω₁,ω₂]}Π_ω(ℋ_r | y) ≤ 1.44/D + 16·D^{3/2}·exp{5 − (Σ + 1)D}.

*Proof.* For every real t, ω ↦ e^{−ωt} is convex, so N_ω(ℋ_r) ≤ N_{ω₁}(ℋ_r) + N_{ω₂}(ℋ_r); apply Lemma N at the two endpoints. L6's event is {∫ℛ dν_G ≤ (1.44C₁ + 1)nε_d²}, which does not involve ω, and on it N_ω(ℝⁿ) ≥ ν(G)e^{−ω(1.44C₁+1)nε_d²} ≥ 𝔏(ω₂) for every ω ≤ ω₂ (this ω-free form is the one used in the audited C1, Step 7). The supremum is measurable by continuity in ω: **[Fix 9]** use the uncentred likelihoods, which on [ω₁, ω₂] are dominated by the integrable likelihood at ω₁. ∎

### 9.2 σ learned, λ deterministic — PROVED from Lemma S §2

Model: σ ~ IG(a, b), penalty σ-free. Assume in addition the hypotheses of Lemma S §2 (row-average uniform integrability, σ₀,ₙ ≥ d, (A3) or a bounded truth, λ/log n → ∞), **and [Fix 9] those of Theorem LB used asymptotically: a bounded shift budget β, λ → ∞ and D → ∞ (λ = o(n³))**, or the eventual finite-window conditions with D → ∞. A bounded truth gives scale containment but no bounded shift budget by itself, and λ/log n → ∞ alone allows e.g. λ = n⁴, outside LB's window. Then there is a fixed interval I = [l, H₀] with sup_P E_P Π(σ ∉ I | y) → 0, and S §2 uses no trend localization. By the disintegration of S §3,

  Π(ℋ_r | y) ≤ sup_{s∈I}Π_s(ℋ_r | y) + Π(σ ∉ I | y),

and §9.1 with ω₁ = 1/H₀, ω₂ = 1/l gives E₀Π(Δ²ₙ ≤ c₀λ^{−1/3} | y) → 0, c₀ computed at ω₂ = 1/l. The constant is poor because l is crude; it can be replaced by the narrow interval of Theorem C\* where that theorem applies (not circular: C\* is proved independently of this note).

### 9.3 λ mixed — PROVED on {λ ≤ λ_max}; V0T with constant b₀

Let p be any prior on λ, ν̄ = ∫p(dℓ)ν_ℓ, N̄_ω(B) = ∫p(dℓ)N_{ω,ℓ}(B).

**Lemma LB-mix (numerator).** If 116.4(rλ_max)^{2/5} ≤ n and r² ≤ min{1/16, λ_max^{−1/3}/168}, then

  E₀∫_{ℓ≤λ_max}p(dℓ)N_{ω,ℓ}(ℋ_r) ≤ e^{c_ω nr²}·V₃R_c³·exp(−min{n/16, n(rλ_max)^{−2/5}/466}).

*Proof.* Lemma N does not involve the prior. For each ℓ ≤ λ_max the hypotheses of §4.4 hold at ℓ, and min{n/16, n(rℓ)^{−2/5}/466} is nonincreasing in ℓ. ∎

**Why a cap is needed.** As ℓ → ∞ the prior mass of every ball around a quadratic truth tends to 1. So without an upper control of λ the statement "not faster than Λ^{−1/3}" cannot be derived from prior mass, and for V = 0 it may be false. Whether the posterior exploits this was not examined.

**V0T with constant b₀ — PROVED; log-free after item 3 [Fix 11].** Prior: Gamma(1, b₀) truncated to [Λ₋, ∞), Λ₋ = κ₋n^{5/2}, σ ~ IG.
1. *λ sits at the floor.* For every u, s: ∫e^{−Q/s}dc ≤ C_k s³ (S §2's flat bound), so the uncentred joint evidence of {λ > 2Λ₋} is ≤ p_n(λ > 2Λ₋)·C_k·E_IG[s^{3−n}] = e^{−b₀Λ₋}·C_k·b^{3−n}Γ(n + a − 3)/Γ(a) = exp{−b₀κ₋n^{5/2} + O(n log n)}. The joint evidence is ≥ e^{−Cn} on the event of V2T Step 2(a). Hence **Π(λ > 2Λ₋ | y) → 0** in probability. (More precisely, λ ≤ Λ₋ + C′n log n/b₀.)
2. *Lower bound.* Π(ℋ_r | y) ≤ Π(λ > 2Λ₋ | y) + Π(σ ∉ I | y) + sup_{s∈I}Π_s(ℋ_r ∩ {λ ≤ 2Λ₋} | y). Numerator: Lemma LB-mix with λ_max = 2Λ₋, at the two endpoints of I. Denominator: V2T eq. (2), N̄_ω(ℝⁿ) ≥ V₃(ε̄√n/2)³p₀,ₙexp{−(3 + ω(1.25C₁ + 1))nε̄²} on Ω_D. With D₋ := nΛ₋^{−1/3} and r² = cΛ₋^{−1/3}: n(2rΛ₋)^{−2/5} = 2^{−2/5}c^{−1/5}D₋ and nε̄² = C_ε[(log m)^{1/6} + κ₋²V²]·D₋. So the ratio → 0 once

  c^{−1/5} ≥ 466·2^{2/5}·2·{c_{ω₂} + (3 + ω₂(1.25C₁ + 1))·C_ε·[(log m)^{1/6} + κ₋²V²]},

  i.e. for **c = c₁·(log n)^{−5/6}**. Result: Π(Δ²ₙ ≤ c₁(log n)^{−5/6}·Λ₋^{−1/3} | y) → 0 for Felipe's method with the floor. **[Fix 10]** Details: a mixed posterior probability uses the mixed denominator (V2T eq. (2)), not a fixed-ℓ one; on I use the two endpoint numerators and V2T's common event; the window mass 1 − e^{−b₀Λ₋} → 1. With c = c₁(log n)^{−5/6} the numerator exponent is of order D₋(log n)^{1/6} = o(n), so the n/16 cap is inactive, and the block-fit and radius restrictions hold eventually. Inherited hypotheses (state them): those of V2T, including the common uniform-integrability modulus and the positive lower bound on the scale σ₀,ₙ ≥ d.
3. *Removing the logarithm — PROVED [Fix 11]* (argument of the audit, verified by Theory). Fix κ₋ and V. Take ε² := Λ₋^{−1/3}, D₋ := nε², and the §7 mollified centre at that ε for every ℓ ∈ [Λ₋, 2Λ₋] (centre 0 if V = 0). The half-radius hypotheses hold eventually at the floor, hence on the window. L3⁺ costs ≤ 99D₋ + 5 throughout; the shift costs ≤ 4C_b(Vκ₋)^{12/5}D₋ by the upper endpoint 2Λ₋. The normalized mixture on V2T's good set has the same mean and variance bounds, so on an event of failure probability ≤ 1.25/D₋ the evidence is ≥ V₃(√D₋/2)³p₀,ₙexp(−5 − KD₋), K := 99 + 4C_b(Vκ₋)^{12/5} + ω₂(1.25C₁ + 1). Take a fixed 0 < c < min(1, 2^{−1/3}/168) so small that 2^{−2/5}c^{−1/5}/466 > K + c_{ω₂} + 1. With r² = cΛ₋^{−1/3}, the block-fit and n/16 restrictions hold eventually (Λ₋^{1/3} = o(n), D₋ = o(n)); the endpoint numerator ratio is O(D₋^{3/2}e^{−D₋}), and the scale and tuning tails vanish by item 1 and S §2. **Result: Π(Δ²ₙ ≤ c·Λ₋^{−1/3} | y) → 0, c a constant, for his method with the floor (constant b₀, fixed V, κ₋).**

For the scaled hyperprior (b_n ∝ n^{−5/2}) there is no upper containment of λ, and only the statement on {λ ≤ λ_max} is available.

---

## 10. The centre: supremum over centres versus a posterior-dependent centre

**What Theorem LB uses.** The bad set ℋ_r is a ball around the **truth**, a deterministic set. That is why Tonelli applies in §6 and no supremum over data-dependent sets is taken. Lemma L3⁻ is uniform over centres, and this uniformity is used once: to avoid any shift lemma, hence any condition on the truth, in the numerator.

**What uniformity over centres does not give.** For a data-dependent centre θ̂(y), E₀N_ω(B(θ̂(y), r)) cannot be computed by Tonelli, because the set depends on y. A bound sup_{θ₀}ν(B(θ₀, r)) ≤ e^{−φ_c} controls the prior mass of every ball, but the realized likelihood ratio on a data-chosen ball is not bounded by Lemma N.

**Partial result — PROVED.** Let θ̂ = θ̂(y) be any estimator (posterior mean, median, MAP, anything) and r² = c₀λ^{−1/3}. By the triangle inequality in ‖·‖ₙ, on the data event {‖θ̂ − θ\*‖ₙ ≤ r/2} the ball {‖θ − θ̂‖ₙ ≤ r/2} is contained in {‖θ − θ\*‖ₙ ≤ r}. Hence, by Theorem LB,

  **1{‖θ̂ − θ\*‖ₙ ≤ r/2}·Π(‖θ − θ̂‖ₙ ≤ r/2 | y) ≤ Π(‖θ − θ\*‖ₙ ≤ r | y) → 0 in P₀-probability.**

(The statement is made in ‖·‖ₙ because √Δ²ₙ is not a norm.)

Reading: the posterior cannot concentrate at scale r/2 around any centre that is itself within r/2 of the truth. In particular, no posterior summary can be both more accurate than r/2 and carry a posterior ball of radius r/2 with non-vanishing mass.

**The general spread statement — NEW LEMMA NEEDED.** "Π(‖θ − θ̂‖ₙ ≤ c·λ^{−1/6} | y) → 0 for every θ̂" (the posterior's own spread is at least λ^{−1/3}, whatever its centre) is not proved. Two routes were considered and neither closes:
- *Covering the localized body by deterministic balls and a union bound.* The entropy of {‖δ‖ₙ ≤ √M·ε, TV ≤ T₀} at scale √c·ε is of order c^{−1/6}n^{11/36} at the oracle (T₀ ≍ √n), which exceeds nε² ≍ n^{1/6}. This is the same loss as C1's "loss B".
- *Deterministic anti-concentration from the Lipschitz likelihood.* |Q(θ) − Q(θ′)| ≤ ‖θ − θ′‖₁ gives density-ratio bounds e^{−ω‖v‖₁} under a perturbation v; for a block bump of height r and width 4h this is e^{−ω·4hr} with hr ≍ n^{5/12} at the oracle, far too large.

What would be needed is a variance (Fisher-information-type) lower bound for the fixed-(σ, λ) log-concave posterior along the block functionals L_k, i.e. a lower bound on the posterior variance of each Λ_k of order h⁵/λ² up to constants, jointly over ≍ nε² blocks.

---

## 11. Gaps, and what would need new lemmas

1. **Posterior-dependent centre.** §10. NEW LEMMA NEEDED.
2. **Above the oracle (λ ≫ n^{5/2}/V).** Theorem LB holds but with c₀ ≍ (Vλ/n^{5/2})^{−12}, while the true rate there should be the bias V²λ^{5/3}n^{−5}. A sharp statement needs a **lower bound on the bias**: for truths with a genuine third-order kink, a non-centred small-ball upper bound Π_λ(u\* + B_r) ≤ exp{−φ(r) − c·λ²·dist²}, or a direct argument that the posterior mean over-smooths. NEW LEMMA NEEDED; it is a statement about specific truths, not the class.
3. **Upper-side logarithm.**
   - Theorem B (under (EM)) — SKETCH, **[Fix 12]**: J7's shift now consumes a fixed multiple of nε² depending on C and a₂, so C_pr must be enlarged accordingly. Substituting L3⁺ in join J5 gives the spread ratio 99·a₁^{−2/5}C^{−6/5} with ε² = C·V^{1/3}n^{−5/6}, so the log exponent c = 0 becomes admissible and the rate is exactly n^{−5/6} on both sides. SKETCH: a substitution into an audited proof (J5; J6 and R1 are unaffected because they are sufficient conditions); not re-audited.
   - Theorems C\*, V0T\* (any σ): the logarithm also enters C2's fine term through Σtⱼ² ≤ m·t_∞². Bounding Σtⱼ² by Markov (E Σtⱼ² ≤ ¼Σ‖w_j‖₂²) instead gives the rate M_n·λ^{−1/3} for every M_n → ∞. SKETCH; **[Fix 12]** a diverging Markov threshold and control of the largest fine score are still required.
4. **λ mixed without an upper cap** (scaled hyperprior, soft floors with small shape). The lower bound may fail for quadratic truths; see §9.3. An upper containment of λ would be the missing input.
5. **Constants.** c₀ is not sharp, and its dependence on ω is only sketched (§8.5).
6. **Suggested numerical checks (not run).** (i) L_k(Su) = Σw_h(j)u_{i_k+j} on random u, a few (n, h). (ii) −log Π_λ(B_r) for small n by Monte Carlo, against the two-sided bound min{n/8, x^{2/5}/117} ≤ φ(r) ≤ 75x^{2/5} + 5 **[Fix 12]** (not a universal interval for the ratio φ/x^{2/5}: the lower bound has a minimum, and dividing the upper bound by x^{2/5} adds 5/x^{2/5}); no log growth expected. (iii) The eigenvalue bound μ_q ≤ b·q^{−6} of §5 on simulated V.

## 12. Audit guide: the steps most worth a second reader

- §2(c): the operator identity and the index ranges (i + 3h ≤ n; largest u-index ≤ m).
- §3: the single-crossing argument, and that Λ_k is log-concave (all weights positive).
- §4.3: the count of clean blocks (nr² ≤ K/2) and the union over 4^g subsets.
- §5 Step 2: rank(P_JM) ≤ J and the Weyl step; Step 4: the choice J = ⌊q/2⌋.
- §6: mᵢ ≥ 0 without (A2), and the two-sided use of Hoeffding and the trivial bound.
- §7 (R2): the hypotheses (h1)–(h3) and the exponent 12/5.
- §8.2: the arithmetic (rλ)^{2/5} = λ^{1/3}/(932Σ) and the bracket 2Σ − (Σ − 1).

---

## Theory Department: cross-family audit response (Astra, `reviews/AUDIT_astra_LB.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES.** Eleven findings are CONFIRMED and one is PLAUSIBLE; Theory rules that all **HOLD**.
- **Core confirmed:**
  - innovation blocks and their independence;
  - the density bound at every centre and translations;
  - both small-ball upper bounds;
  - the log-free L3 via Lemma F;
  - the Tonelli step on the truth ball;
  - the denominator and shift costs;
  - the theorem constants and tuning range.
- **Scope fixes:**
  - (7, 8) Above-oracle claims keep the β-dependent tuning window. The oracle exponent 5/6 needs an applicable upper theorem (C\*, V0T\*, or B under (EM)).
  - (9) The learned-σ limit needs a bounded shift budget and D → ∞.
- **Improvement:** (11) the **log-free lower bound for constant-b₀ V0T is closed** by the audit.
- (12) The ancillary sketches stay sketches.

**Status: Theorem LB is PROVED and cross-family audited. Together with C\* / V0T\*, n^{−5/6} is the exact posterior rate at the oracle, up to the upper-side (log n)^{1/6}.**

### Fixes applied (Theory, 2026-11-23, before 18:00 CT)

Each finding was re-derived by Theory before the change was made.

| # | Finding | Ruling | Change in this file |
|---|---|---|---|
| 1 | Innovation blocks, independence (§2) | HOLDS (confirmation) | none needed |
| 2 | Density bound, translations (§3) | HOLDS (confirmation) | none needed |
| 3 | Both small-ball bounds (§4) | HOLDS (confirmation) | none needed |
| 4 | Rigorous rounding 19.24; cutoff > m | HOLDS (checked: 3110.4·846.81 = 2 633 917.8 < 19.24⁵ = 2 636 485.2) | §5 Step 6 "<" with the check; remark on the cutoff |
| 5 | Tonelli on a random-ball indicator; atom case | HOLDS | §6 remark; explains why the bad set is the truth ball |
| 6 | Shift costs; (h2) ⇒ column-increment; w/n → 0 | HOLDS | §7 remark |
| 7 | State λ → ∞ (eventually ≥ (32Σ)³) and D → ∞; one c₀ from a common β̄; above the oracle both restrictions must be kept (λ = n^{59/20} counterexample) | HOLDS (checked: β ≍ n^{27/25} > λ^{1/3} = n^{59/60}) | §0 claim, §8.1, §8.3 |
| 8 | Oracle corollary: correct upper citations; (A1)+(upper A2) gives the lower half only | HOLDS | §0, §8.4 rewritten; two-sided in Δ²ₙ and in ‖·‖²ₙ (Theory's addition: Δ²ₙ ≤ ‖·‖²ₙ transfers each side) |
| 9 | Measurability via dominated uncentred likelihoods; learned σ needs bounded β, λ → ∞, D → ∞ | HOLDS | §9.1, §9.2 |
| 10 | Mixed denominator; V2T hypotheses; n/16 cap inactive | HOLDS | §9.3 item 2 |
| 11 | Log-free V0T lower bound closes | HOLDS (argument re-derived: exponent 2^{−2/5}c^{−1/5}/466 beats K + c_ω₂ + 1 for small fixed c) | §9.3 item 3: SKETCH → PROVED; table row 9 |
| 12 | (PLAUSIBLE) ancillary sketches: optimum a, C_pr enlargement, Markov threshold, interval [1/117, 75] | HOLDS (checked a = (99/(5A))^{5/6}, cost 6(99/5)^{5/6}A^{1/6} = 72.2A^{1/6}) | §8.5, §11 items 3 and 6; sketches stay sketches |
