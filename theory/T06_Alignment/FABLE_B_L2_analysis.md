# L2 by analysis: (DC_γ) on the bounded range for Gaussian noise

*Fable, research sub-agent for Theory, 2026-11-23. By hand; constants evaluated with a calculator; no simulation. **Not audited.** Builds on `FABLE_B_DC.md` (statement and reductions §2.1–2.3), Lemma 2a of `FABLE_A_three_lemmas.md` (audited), L3 Step 1 (scale mixture), and Astra's evidence identity (audited).*

**Labels.** PROVED = every step is written here and rests on elementary facts or audited statements. SKETCH = argument given, a step not written. CONJECTURE = heuristic.

## 0. Verdict

**Part 1 closes for Gaussian noise.** (DC_γ) holds on [ℓ₁, ℓ₀] for an explicit constant ℓ₀, **uniformly in s > 0, with no difficulty in the band s ∈ [0.06/ℓ, 1/ℓ]**, for every truth θ\* (no smoothness is used) and every τ. The proof is a quenched density comparison against the true law of the data, not a certificate.

| # | Claim | Status |
|---|---|---|
| 1 | The evidence is a model density: Z(s, ℓ) = t^{−n}·p_{s,ℓ}(Qy) | PROVED (§2.1) |
| 2 | Quenched comparison: w.p. ≥ 1 − e^{−a}, p_{s,ℓ}(Qy) ≤ e^{a}·‖π_T‖∞·f(Qy)/f_T(Py) | PROVED (§2.2) |
| 3 | Sup-density of a linear image of a Laplace vector: ‖π_{Mu}‖∞ ≤ det(2v₁MMᵀ)^{−1/2} | PROVED (§2.3) |
| 4 | **Node bound:** n⁻¹log Z(s, ℓ) ≤ −log t − h̄ₙ − c_Λ·(ℓ·ς_max)^{−1/3} + η + o(1), c_Λ = 0.7497, for every s > 0 and every ℓ with 0.016 ≤ ℓς_max ≪ n³ | PROVED for Gaussian noise (§3) |
| 5 | **Theorem DC-G:** (DC_γ) on [ℓ₁, ℓ₀] whenever c_Λ(ℓ₀ς_max)^{−1/3} ≥ Δ_KL + γ + η + 2δ | PROVED (§4), using the reductions of `FABLE_B_DC.md` §2 |
| 6 | Paper's Gaussian design: ℓ₀ = **790** (τ = ½), **197** (τ = 0.25, 0.75), **12** (τ = 0.05, 0.95), **3.4** (τ = 0.01, 0.99), at total slack 0.03 | PROVED (arithmetic of item 5) |
| 7 | Beta and Mixed designs | SKETCH (§5): same proof with log-concave information-density concentration; estimated ranges given; **Beta at τ = 0.95 is not covered** |
| 8 | Why the method stops at a constant ℓ₀, and what it gives for L4a | PROVED limitation (§6): nothing beyond a constant |

**The idea in two lines.** In the orthonormal coordinates Qy of P⊥y the evidence is t^{−n} times the density of the model vector Q(Su + E). Its low-frequency part T = P(Su + E) has a density that is uniformly tiny, because the prior's third-difference innovations of size 1/ℓ make it enormously spread; the data, being noise, sit at a point where the true density of T is large. The ratio is e^{−c·nℓ^{−1/3}}, and the rest of the vector costs at most a factor e^{a} by Markov under the truth.

**The price.** The comparison is with the true density, so the bound is relative to the entropy of the noise, not to the benchmark b\*. The difference Δ_KL = 1 + log(σ₀/t) − h̄ > 0 is the per-observation Kullback gap between the noise and its best asymmetric-Laplace fit. It limits ℓ₀ to (c_Λ/Δ_KL)³/ς_max.

---

## 1. Setting

- Noise: εᵢ ~ N(0, ςᵢ²) independent, 0 < ς_min ≤ ςᵢ ≤ ς_max; y = θ\* + ε with **arbitrary** θ\* ∈ ℝⁿ. Σ := diag(ςᵢ²). h̄ₙ := n⁻¹Σᵢ½log(2πe·ςᵢ²) (mean differential entropy).
- Model at fixed (s, ℓ): θ = Nc + Su, c flat on ℝ³, u ~ Π_ℓ; working likelihood s^{−n}e^{−Q(θ)/s} = t^{−n}∏ᵢq_s(yᵢ − θᵢ), q_s(x) := t·s⁻¹e^{−ρ_τ(x)/s} a probability density.
- Q ∈ ℝ^{m×n}: orthonormal rows spanning (range N)^⊥. A₀ := P⊥S = D⁺. v₁ := 2/ℓ². μ₁ ≤ … ≤ μ_m the eigenvalues of DDᵀ; A₀A₀ᵀ = (DᵀD)⁺ has eigenvalues 1/μ_r with unit eigenvectors p_r ∈ (range N)^⊥.
- g_n(s, ℓ) := n⁻¹log Z(s, ℓ) (it differs from the g_n of `FABLE_B_DC.md` by O(log n/n)); b\* := −1 − log σ₀; (DC_γ): sup_{s>0, ℓ₁≤ℓ≤ℓ₀}g_n ≤ b\* − γ w.p. → 1.
- **Δ_KL := −log t − h̄ − b\* = 1 + log(σ₀/t) − h̄.** For the paper's Gaussian design (ς(u) = (1+u²)/4, σ₀ = φ(z_τ)/3, h̄ = 0.29659): Δ_KL = 0.0722, 0.1324, 0.3801, 0.5951 at τ = 0.5, 0.25, 0.05, 0.01. (Of this, 0.0237 is the cost of one common scale for heteroscedastic noise; the rest is KL(Gaussian ‖ best ALD_τ).)

---

## 2. Three lemmas — PROVED

### 2.1 Lemma E1: the evidence is a model density

Let u ~ Π_ℓ and E ~ q_s^{⊗n} be independent, and let p_{s,ℓ} be the density on ℝ^m of **Y_mod := Q(Su + E)**. Then for every y ∈ ℝⁿ:

  **Z(s, ℓ) = t^{−n}·p_{s,ℓ}(Qy).**

*Proof.* Let 𝔪(y) := ∫∫∏ᵢq_s(yᵢ − (Nc + Su)ᵢ)dc Π_ℓ(du) = tⁿZ(s, ℓ). Then 𝔪(y + Nb) = 𝔪(y) for b ∈ ℝ³ (shift c). For φ ≥ 0 on ℝ^m and a Borel set A ⊂ ℝ³ of finite measure |A|, by Tonelli and the substitution E = y − Nc − Su,

  ∫𝔪(y)φ(Qy)1{Nᵀy ∈ A}dy = ∫∫∫φ(Q(Su + E))·1{c + NᵀSu + NᵀE ∈ A}·∏q_s(Eᵢ)dE Π_ℓ(du) dc = |A|·𝔼φ(Y_mod),

because QN = 0 and the c-integral of the indicator is |A|. On the other hand y ↦ (Nᵀy, Qy) is orthogonal, so the left side is |A|·∫𝔪(Qᵀr)φ(r)dr. Hence r ↦ 𝔪(Qᵀr) is the density of Y_mod, and 𝔪(y) = 𝔪(QᵀQy). ∎

(This is Astra's identity in orthonormal coordinates: p_{s,ℓ}(Qy) = J_n·(density of u + DE at Dy).)

### 2.2 Lemma E2: quenched comparison with the truth

Split Q = [P; P′] with P ∈ ℝ^{d×n}, and write Y_mod = (T_mod, R_mod), with marginal density π_T of T_mod = P(Su + E). Let f be the true density of Qy = (Py, P′y) and f_T that of Py; assume f > 0 everywhere. Then for every a > 0, with P₀-probability ≥ 1 − e^{−a}:

  **p_{s,ℓ}(Qy) ≤ e^{a}·‖π_T‖∞·f(Qy)/f_T(Py).**

*Proof.* p_{s,ℓ}(τ, r) = π_T(τ)·p(r | τ) and f(τ, r) = f_T(τ)·f(r | τ). Under the truth, E₀[p(R | T)/f(R | T) | T] = ∫p(r | T)dr = 1. By Markov, P₀(p(R | T) > e^{a}f(R | T)) ≤ e^{−a}. On the complement, p_{s,ℓ}(Qy) ≤ π_T(Py)·e^{a}f(P′y | Py) ≤ e^{a}‖π_T‖∞·f(Qy)/f_T(Py). ∎

Only the T-part of the model is examined; the rest costs the factor e^{a}, whatever s and ℓ are. **No expectation of the likelihood ratio between two wrong models is taken**, which is why the failure of (EM) at σ₀ plays no role.

### 2.3 Lemma E3: sup-density of a linear image of a Laplace vector

Let u ∈ ℝ^m have i.i.d. Laplace(ℓ) coordinates and M ∈ ℝ^{d×m} have rank d. Then Mu has a density π_{Mu} with

  **‖π_{Mu}‖∞ ≤ det(2v₁·MMᵀ)^{−1/2},  v₁ = 2/ℓ².**

(For a Gaussian vector with the same covariance v₁I the sup-density is det(2πv₁MMᵀ)^{−1/2}; the Laplace law costs at most the factor π^{d/2}.)

*Proof.* By L3 Step 1, uⱼ = √Vⱼ·ξⱼ with Vⱼ i.i.d. exponential of mean v₁ and ξ standard normal. Given V, Mu ~ N(0, M·diag(V)·Mᵀ), whose density is ≤ (2π)^{−d/2}det(M diag(V) Mᵀ)^{−1/2}. By Cauchy–Binet, det(M diag(V)Mᵀ) = Σ_{|S|=d}det(M_S)²∏_{j∈S}Vⱼ and det(MMᵀ) = Σ_S det(M_S)². With weights a_S := det(M_S)²/det(MMᵀ) (they sum to 1), the weighted AM–GM inequality gives

  det(M diag(V)Mᵀ) ≥ det(MMᵀ)·∏_S(∏_{j∈S}Vⱼ)^{a_S} = det(MMᵀ)·∏ⱼVⱼ^{pⱼ},  pⱼ := Σ_{S∋j}a_S.

Here 0 ≤ pⱼ ≤ 1 and Σⱼpⱼ = d. By independence and E V^{−q} = v₁^{−q}Γ(1 − q) for q < 1:

  E det(M diag(V)Mᵀ)^{−1/2} ≤ det(MMᵀ)^{−1/2}·v₁^{−d/2}·∏ⱼΓ(1 − pⱼ/2).

log Γ is convex, log Γ(1) = 0 and log Γ(½) = ½log π, so log Γ(1 − x) ≤ x·log π on [0, ½]; hence ∏ⱼΓ(1 − pⱼ/2) ≤ π^{Σpⱼ/2} = π^{d/2}. Therefore ‖π_{Mu}‖∞ ≤ (2π)^{−d/2}·π^{d/2}·det(v₁MMᵀ)^{−1/2}. ∎

**Corollary E3′.** Take P with rows p₁ᵀ, …, p_dᵀ (the eigenvectors of A₀A₀ᵀ for its d largest eigenvalues 1/μ₁, …, 1/μ_d). Then T_mod = PA₀u + PE (PS = PA₀ since P = PP⊥), the two terms are independent, and convolution does not increase the sup-density, so for **every s > 0**:

  **log‖π_T‖∞ ≤ −½·Σ_{r≤d}log(4/(ℓ²μ_r)).**

(MMᵀ = PA₀A₀ᵀPᵀ = diag(1/μ_r)_{r≤d}.) The working likelihood, its scale s and its level τ do not enter.

---

## 3. The node bound — PROVED for Gaussian noise

**Proposition N.** Let c′ := 1 + log π = 2.1447, κ := (2/(ℓ²ς_max²))^{1/6}·n/π, x\* := κ·e^{−c′/6} and d := ⌊x\*⌋ − 3, and assume 6 ≤ x\* ≤ m. For every s > 0, a > 0 and x > 0, with P₀-probability ≥ 1 − e^{−a} − 2e^{−x}:

  **log Z(s, ℓ) ≤ −n·log t − n·h̄ₙ − c_Λ·n·(ℓ·ς_max)^{−1/3} + a + 2√(nx) + x + 12·log κ + C,**

with **c_Λ := 3·e^{−c′/6}·2^{1/6}/π = 0.7497** and C depending only on ς_max/ς_min. The two events of probability e^{−x} do not depend on s; one of them does not depend on ℓ.

*Proof.* By E1 and E2: log Z ≤ −n log t + a + log‖π_T‖∞ + log f(Qy) − log f_T(Py).

*(i) The full true density.* Qy ~ N(Qθ\*, QΣQᵀ), so log f(Qy) = −(m/2)log(2π) − ½log det(QΣQᵀ) − ½χ²_m, with χ²_m := (Qε)ᵀ(QΣQᵀ)^{−1}(Qε) exactly chi-square with m degrees of freedom. For the orthogonal matrix [N, Qᵀ], the Schur complement identity gives det(QΣQᵀ) = det(Σ)·det(NᵀΣ^{−1}N) ≥ det(Σ)·ς_max^{−6}. With χ²_m ≥ m − 2√(mx) off probability e^{−x}:

  log f(Qy) ≤ −½Σᵢlog(2πe·ςᵢ²) + √(mx) + C = −n·h̄ₙ + √(mx) + C.

*(ii) The true density of T.* Py ~ N(Pθ\*, PΣPᵀ) and PΣPᵀ ⪯ ς_max²I_d, so −log f_T(Py) ≤ (d/2)log(2πς_max²) + ½χ²_d, and χ²_d ≤ d + 2√(dx) + 2x off probability e^{−x}.

*(iii) The model's T.* By E3′, and with ϱ_r := 2/(ℓ²ς_max²μ_r):

  log‖π_T‖∞ + (d/2)log(2πς_max²) + d/2 = −½Σ_{r≤d}[log ϱ_r − log π − 1] = −½Σ_{r≤d}[log ϱ_r − c′].

*(iv) The spectral sum.* By Lemma 2a, μ_r ≤ (π(r+3)/n)⁶, so log ϱ_r ≥ 6·log(κ/(r+3)). Let ϕ(x) := 6log(κ/x) − c′, decreasing, zero at x\*. Since d + 3 = ⌊x\*⌋, every term is ≥ 0 and

  Σ_{r≤d}ϕ(r+3) ≥ ∫₄^{x\*}ϕ(x)dx − 6/x\* = 6x\* − 4·[6log(κ/4) + 6 − c′] − 6/x\* ≥ 6x\* − 24·log κ − 1,

using ∫ϕ = x[6log(κ/x) + 6 − c′]. Hence ½Σ ≥ 3x\* − 12log κ − ½, and 3x\* = 3e^{−c′/6}κ = c_Λ·n·(ℓς_max)^{−1/3}.

Adding (i)–(iv), with √(mx) + √(dx) ≤ 2√(nx). ∎

**Remarks.**
- The bound holds for all ℓ with 6 ≤ x\* ≤ m, i.e. from ℓ·ς_max ≥ 0.016 up to ℓ ≪ n³. It is the ℓ^{−1/3} law of the effective dimension, with constant 0.75 against 0.935 in the exact Gaussian computation ((5π/6)·κ/n).
- It is **uniform in s** because ‖π_T‖∞ was bounded by the prior part alone. This is what removes the band problem: no property of the working noise E is used.
- θ\* is arbitrary: the true densities are evaluated at the data, and their quadratic forms involve ε only.

---

## 4. Theorem DC-G — PROVED

**Theorem DC-G.** Let the noise be Gaussian as in §1, τ ∈ (0, 1), and assume σ₀,ₙ → σ₀, h̄ₙ → h̄, R_n → R in probability with **σ₀ < 2tR** (for independent Gaussian noise σ₀ = φ(z_τ)·mean(ς) and R = √20·√(2/π)·mean(ς), so the ratio σ₀/(2tR) is φ(z_τ)/(t·√(160/π)): 0.224, 0.237, 0.304, 0.377 at τ = 0.5, 0.25, 0.05, 0.01). Let γ, η, δ > 0 and ℓ₁ < ℓ₀ satisfy

  **c_Λ·(ℓ₀·ς_max)^{−1/3} ≥ Δ_KL + γ + η + 2δ.**

Then, with probability → 1, for every truth θ\*:

  **sup{g_n(s, ℓ) : s > 0, ℓ₁ ≤ ℓ ≤ ℓ₀} ≤ b\* − γ + o(1).**

Consequently (`FABLE_B_DC.md` §1) Π(ℓ₁ ≤ λ ≤ ℓ₀ | y) ≤ e^{−γn/2}, and with region (I) of `FABLE_A_Arule_lowertail.md` §2, **Π(λ ≤ ℓ₀ | y) → 0 exponentially fast.**

*Proof.*
1. *Large scales.* For s ≥ s_hi := e^{1+γ}σ₀: g_n ≤ −log s + o(1) ≤ b\* − γ (`FABLE_B_DC.md` §2.1).
2. *Small scales.* For s ≤ s_lo(ℓ): g_n ≤ log(ℓ/(2t)) − ℓR_n + log M_τ(8ℓs) ≤ b\* − γ (`FABLE_B_DC.md` §2.2). s_lo(ℓ) > 0 is bounded below on [ℓ₁, ℓ₀] because sup_ℓ[log(ℓ/(2t)) − ℓR] = −1 − log(2tR) < b\*, which is σ₀ < 2tR.
3. *The compact part.* On 𝒦 := {ℓ₁ ≤ ℓ ≤ ℓ₀, inf s_lo ≤ s ≤ s_hi} take the geometric grid of ratio e^{δ} of `FABLE_B_DC.md` §2.3; it has a finite number N of nodes, independent of n. Apply Proposition N at every node with a := ηn and x := (log n)². The total failure probability is ≤ N·e^{−ηn} + (number of ℓ-nodes + 1)·2e^{−(log n)²} → 0. At a node (s_a, ℓ_b), since ℓ_b ≤ ℓ₀:

  g_n(s_a, ℓ_b) ≤ −log t − h̄ₙ − c_Λ(ℓ₀ς_max)^{−1/3} + η + o(1) ≤ b\* − γ − 2δ + o(1),

  by the definition of Δ_KL and the hypothesis. The grid lemma extends this to every point of 𝒦 at a cost 2δ. ∎

**Values for the paper's Gaussian design** (ς_max = ½; total slack γ + η + 2δ = 0.03):

| τ | Δ_KL | ℓ₁ = 2t/(eσ₀) | **ℓ₀ = (c_Λ/(Δ_KL + 0.03))³/ς_max** | ℓ₀ at zero slack |
|---|---|---|---|---|
| 0.50 | 0.0722 | 1.38 | **790** | 2243 |
| 0.25, 0.75 | 0.1324 | 1.30 | **197** | 363 |
| 0.05, 0.95 | 0.3801 | 1.02 | **12.2** | 15.3 |
| 0.01, 0.99 | 0.5951 | 0.82 | **3.4** | 4.0 |

**What changes with the level.** Nothing in the proof: Proposition N does not involve τ except through −log t. Only Δ_KL changes. It grows towards the tails because an asymmetric Laplace density at an extreme level is a poor fit to a Gaussian, so the benchmark b\* sits further below the entropy bound and the covered range shrinks. At τ = 0.05 the range [1.02, 12] is short but non-empty.

**Two remarks on the hypotheses — PROVED.**
- *Truth.* Proposition N holds for every θ\* ∈ ℝⁿ. Step 2 of the proof uses R_n = ‖Dy‖₁/n ≥ ‖Dε‖₁/n − ‖Dθ\*‖₁/n, so the theorem needs ‖Dθ\*‖₁ = o(n). Under (A3) this is V/n².
- *The junction constant ℓ₀ of the chain can be taken equal to this note's ℓ₀.* In `FABLE_A_Arule_lowertail.md` §2, ℓ₀ was fixed by the crude form of (III-a) (with d/4), which gives a larger value at outer levels (of order 10²–10³ at τ = 0.05 by a hand estimate with d = B = σ₀, against 12 here). But (III-a) holds for **every** ℓ > 0 under the margin σ₀ < 2tR: on {Q(θ) < qn}, ‖Dθ‖₁ ≥ n(R_n − 8q/k), so the evidence of that region is ≤ J_n(ℓ/2)^m e^{−ℓn(R_n − 8q/k)}t^{−n} for every s, and sup_ℓ[log(ℓ/(2t)) − ℓR′] = −1 − log(2tR′) ≤ b\* − γ as soon as 2t(R_n − 8q/k) ≥ σ₀e^{γ}. With q := k(R − σ₀e^{2γ}/(2t))/8 > 0 this is true for large n. So interpolating fits are excluded at every tuning, and the split of the λ-axis into (II) and (III-c) may be made at any constant.

**Possible sharpening — SKETCH.** (a) Replace ς_max in (ii) by the actual det(PΣPᵀ); for smooth ς(·) the low-frequency eigenvectors average ς², which would put roughly the root-mean-square ς (0.35) in place of 0.5 and multiply ℓ₀ by about 1.4. (b) Keep part of the model noise in T, which helps for s of order σ₀. Neither removes Δ_KL.

---

## 5. The other two designs — SKETCH

Lemmas E1–E3 hold for every noise law. Proposition N used Gaussianity only in steps (i) and (ii), which need, for the true law:
- (i′) log f(Qy) ≤ −n·h̄ₙ + o(n) with probability → 1, where now h̄ₙ := n⁻¹Σᵢh(fᵢ);
- (ii′) −log f_T(Py) ≤ (d/2)·log(2πe·v_max) + o(n), with v_max the largest noise variance.

For independent **log-concave** noise both follow from two standard facts, not written out here: the Gaussian maximizes entropy at fixed covariance (so h(Pε) ≤ (d/2)log(2πe·v_max)), and the information density −log f(X) of a log-concave vector concentrates around its entropy at scale O(√dimension) (Bobkov–Madiman). The Beta(1, b) densities with b ≥ 1 and the two-component Gaussian mixture with separation 0.4 < 2·sd are log-concave. Step (i′) also needs that integrating out the three flat directions costs e^{o(n)}; for the Beta design, whose density jumps at 0, this needs care.

The theorem would then read exactly as DC-G with Δ_KL = 1 + log(σ₀/t) − h̄ and ς_max² replaced by v_max. **Hand estimates** (entropies: Beta design h̄ ≈ −0.878 from h(Beta(1, b)) = −log b + 1 − 1/b; Mixed h̄ ≈ 1.08; these were not machine-checked):

| Design, τ | Δ_KL (est.) | ℓ₁ | ℓ₀ (est., slack 0.03) |
|---|---|---|---|
| Mixed, 0.5 | ≈ 0.07 | 0.64 | ≈ 600 |
| Beta, 0.5 | ≈ 0.37 | 3.3 | ≈ 22 |
| Beta, 0.05 | ≈ 0.18 | 4.0 | ≈ 170 |
| **Beta, 0.95** | ≈ 0.90 | 2.0 | **≈ 1.8 — empty range** |

So for Beta at τ = 0.95 this argument gives nothing: the right-skewed Beta noise is far from any ALD at an upper level, and the entropy reference is too generous by 0.9 per observation. That cell would still need the certificate of `FABLE_B_DC.md` §4.

---

## 6. Why the method stops at a constant, and L4a

**PROVED limitation.** Lemma E2 compares the model with the **true** density. Whatever T is chosen, the bound cannot fall below −log t − h̄ − (gain), and the gain per observation is at most of order (ℓς)^{−1/3} (the effective dimension; the exact Gaussian value is 0.935·(ℓς)^{−1/3}). The benchmark is b\* = −log t − h̄ − Δ_KL. So this route proves the exclusion of ℓ only while c·(ℓς)^{−1/3} > Δ_KL, i.e. **for ℓ below a constant**, however the constants are sharpened. For noise that is exactly asymmetric-Laplace at the working level (Δ_KL = 0) it would cover every ℓ = o(n³), but that is the well-specified case.

**Consequence for L4a.** This note does **not** shrink the assumption Π(ℓ₀ ≤ λ ≤ n^{3/2}polylog | y) → 0, except by moving its lower end from an unspecified constant to an explicit one: for the Gaussian design at τ = ½ the assumption is now needed only on **[790, n^{3/2}polylog]** (L2 is a theorem below 790), and on [197, …], [12, …] at τ = 0.25 and 0.05.

**What would be needed to go further — SKETCH of the obstacle, no route.** To exclude growing ℓ one must recover the gap Δ_KL, i.e. use that the model's noise is Laplace in the n − d directions not examined. Doing that with a Markov step means taking the expectation, under the truth, of a likelihood ratio between two misspecified models, and that expectation exceeds 1 exactly when β > 1 (`FABLE_B_Arule_gauss.md` §2(b)). So the cheap argument of §2.2 has no extension to that range; one is back at the realized Gaussian-likelihood analysis of Theorem LO, which needs sup-norm localization. I did not find a way around this in the time available, so Part 2 has no new result beyond the explicit lower end above.

**A lead for L4a — CONJECTURE, exponent-level only.** A hybrid of the two mechanisms might give the sign without sup-norm localization: treat the d ≈ θκ lowest modes by the volume bound of Lemma E3 (prior too spread; gain ≈ ½Σ_{r≤d}[log ρ_r − c′]), and the remaining weak-signal modes by an expectation bound relative to the pure-noise model (loss ≈ ½(β − 1)Σ_{r>d}ρ_r ≈ (β − 1)κ/(10θ⁵)). At θ ≈ 0.7 the gain is ≈ 2.1κ and the loss ≈ 0.6(β − 1)κ, which would give the sign for β below about 4.5, at every ℓ. Two things are unproved and either could kill it: (i) the conditional structure (the expectation step must be taken for R given T, where the model's conditional law mixes signal and noise); (ii) the Laplace tails of the innovations, under which the annealed weak-mode factor can be dominated by sparse large kinks (prior cost e^{−ℓx} against an expected-likelihood gain that is also of order ℓ^{1/3} per kink). I have not checked whether (ii) is fatal.

---

## 7. Flags

- **New and unaudited:** Lemmas E1–E3 and Proposition N. The points most worth an auditor's time: E1's change of variables (the flat integral gives |A|, the orthonormal coordinates give no Jacobian); the conditional Markov step in E2; in E3, the weighted AM–GM with pⱼ ≤ 1, Σpⱼ = d, and the chord bound for log Γ; in Proposition N, the Schur identity for det(QΣQᵀ) and the integral comparison in (iv).
- **Constants:** c_Λ = 0.7497, Δ_KL and the table of §4 were evaluated with a calculator from the closed forms; the estimates of §5 by hand.
- **Asymptotic statement:** the o(1) terms are O(log n/√n); the number of grid nodes is a constant depending on (δ, ℓ₀, ℓ₁).
- **Dependence on `FABLE_B_DC.md` §2** (flat bound, corner bound, grid lemma): Theory verified the grid lemma's direction; the corner bound has not been audited.
- **Suggested check (not run):** at n = 500 and a few (s, ℓ) with ℓ ≤ 100, compare n⁻¹log Z from thermodynamic integration (`FABLE_B_DC.md` §4.4) with the bound −log t − h̄ − 0.75(ℓ/2)^{−1/3}; the bound should hold with visible room.

---

## Theory response (2026-11-23, 15:40 CT)

**Status: L2 is PROVED for Gaussian noise at every τ (one pass), UNAUDITED.** The Astra audit has been requested.
- Other designs: SKETCH.
- **Beta at τ = 0.95 is not covered.** The range is empty there.

**Checked by Theory: Lemma E3 in full.**
- Cauchy–Binet followed by weighted AM–GM gives det(M diag V Mᵀ) ≥ det(MMᵀ)∏Vⱼ^{pⱼ}.
- Since E V^{−q} = v₁^{−q}Γ(1 − q), and the chord bound log Γ(1 − x) ≤ x log π holds on [0, ½] by convexity, the result is (2π)^{−d/2}π^{d/2}det(v₁MMᵀ)^{−1/2} = det(2v₁MMᵀ)^{−1/2}. **Ruling: HOLDS.**

**Consequences for the chain:**
- L2 closes for the Gaussian design, if the audit passes.
- The L4a range gets an explicit lower end, ℓ₀ = 790 at τ = ½ and 12 at τ = 0.05/0.95. The constant ℓ₀ is a hard limit of this method; that limit is proved.

## Cross-family audit response (Astra, `reviews/AUDIT_astra_L2.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES for the bounded-range result at the tabulated Gaussian levels.** All eight findings are CONFIRMED, and Theory rules that they **HOLD**. Theory's own earlier response said "every τ"; that is **withdrawn** together with Fable B's claim.

| # | Fix (applied by reference; written in full in Tuesday's clean rewrite) |
|---|---|
| 1 | No repair needed (evidence identity) |
| 2 | Fix the quantifiers after Proposition N: the projection bound holds simultaneously; the Markov event is pointwise in ℓ until the grid argument |
| 3 | c_Λ = 0.7497255685… (the printed 0.7497 rounds safely). Keep 6 ≤ x\* ≤ n − 3 as a hypothesis; the lower-endpoint condition ℓ₁ς_max > (c_Λ/3)³ holds at all tabulated endpoints |
| 4 | Flat bound: take the supremum at s_hi (do not drop 3 log s/n). Grid: bound each point from the node with **larger s and smaller ℓ**. The three sets cover every s, including the band [0.06/ℓ, 1/ℓ] |
| 5 | **The "every τ" claim is withdrawn.** σ₀/(2tR) diverges as τ ↓ 0 (Mills), and the corner argument fails at extreme quantiles. State (DC-G) for a specified nonempty interval. The posterior consequence needs its own denominator bound, which uses (A3) with V |
| 6 | Endpoints at slack 0.03: **790 (τ = ½), 196 (0.25/0.75), 12 (0.05/0.95)**, and 3.4 (0.01/0.99). The join to region (I) uses the slack-adjusted ℓ₁ |
| 7 | Interpolating fits are excluded at every tuning under the strict corner margin σ₀e^{2γ} < 2tR (keep m = n − 3) |
| 8 | Part 2's limitation is restricted to *this* bound. Delete the Δ = 0 coverage assertion; the hybrid stays CONJECTURE |

**Status: L2 is PROVED and cross-family audited for the paper's Gaussian design at the levels τ ∈ {0.05, 0.25, 0.5, 0.75, 0.95}**, on [ℓ₁, ℓ₀] with the endpoints above, given (A3) for the denominator. Mixed and Beta: open (Fable B, in progress). Beta at τ = 0.95: not covered by this method.

---

## 8. L2 for general independent noise: the whitened theorem (Mixed, Beta, and a sharper Gaussian range)

*Appended 2026-11-23, about 15:45 CT, same author. Not audited. Design constants in §9 were computed by numerical quadrature (throw-away script, not in the repository). This section **supersedes §5** (its hand estimates and its reliance on log-concave concentration) and sharpening (a) of §4.*

### 8.0 What is new

- The Gaussian steps (i), (ii) of Proposition N are replaced by arguments valid for **any** independent noise with a few moments. **Log-concavity is not needed.** The lower bound on the true density of T uses a *reverse Markov* step against a Gaussian reference; the upper bound on the full true density uses the product structure.
- The data are **whitened** first. This replaces ς_max^{−1/3} by the average **Ā = ∫₀¹ς(u)^{−1/3}du**, which matters for the strongly heteroscedastic Beta design (s.d. from 0.077 to 0.289) and is what makes the Beta τ = 0.95 range non-empty.

| # | Claim | Status |
|---|---|---|
| 1 | Lemma E1-W (whitened evidence identity) | PROVED (§8.2) |
| 2 | Lemma E4 (integrating out the three flat directions costs a polynomial factor) | PROVED (§8.3) |
| 3 | Lemma E5 (reverse Markov lower bound for the true density of T) | PROVED (§8.4) |
| 4 | Weighted spectral sum for DΣDᵀ by block bracketing | PROVED (§8.5), using Lemma 2a per block |
| 5 | **Proposition N-W** and **Theorem DC-W**: (DC_γ) on [ℓ₁, ℓ₀] whenever c_Λ·ℓ₀^{−1/3}·Ā ≥ Δ_KL + slack | PROVED (§8.6) under (M1)–(M3) |
| 6 | (M1)–(M3) for the Mixed and Beta designs | PROVED (§8.7), the Mixed varentropy and envelope constants not made explicit |
| 7 | Ranges for all cells (§9) | PROVED arithmetic of item 5; the inputs are quadrature values |

### 8.1 Assumptions and notation

Noise: εᵢ = yᵢ − θ\*ᵢ independent with density fᵢ, mean mᵢ, variance vᵢ = ςᵢ².
- **(M1)** vᵢ = v(i/n) with v of bounded variation, 0 < v_min ≤ v ≤ v_max; standardized fourth moments E[(εᵢ − mᵢ)⁴]/vᵢ² ≤ m̃₄.
- **(M2)** −log fᵢ(εᵢ) has mean hᵢ (the differential entropy) and variance ≤ v_h. h̄ₙ := n⁻¹Σhᵢ → h̄.
- **(M3)** either the supports of the fᵢ are intervals of length ≤ S̄, or fᵢ(x) ≤ C₀e^{−c₀|x|} and E|εᵢ| ≤ C₁.

W := diag(1/ςᵢ); ε̃ := Wε (unit variances), ε̃_c := ε̃ − Eε̃, f̃ᵢ(x) := ςᵢfᵢ(ςᵢx). Ñ: orthonormal basis of range(WN); Q̃ ∈ ℝ^{m×n}: orthonormal rows spanning (range WN)^⊥; G := ÑᵀWN. μ̂₁ ≤ … ≤ μ̂_m: the eigenvalues of **DΣDᵀ**, Σ = diag(vᵢ). Ā_B := n⁻¹Σ_bn_b·(v_b⁺)^{−1/6} for a partition into B consecutive blocks, v_b⁺ := max_{i∈b}vᵢ; Ā := ∫₀¹v(u)^{−1/6}du; under (M1), 0 ≤ Ā − Ā_B ≤ TV(v^{−1/6})/B + O(B/n).

### 8.2 Lemma E1-W — PROVED

Let p̃_{s,ℓ} be the density on ℝ^m of Ỹ_mod := Q̃W(Su + E). Then for every y:

  **Z(s, ℓ) = t^{−n}·(det W/|det G|)·p̃_{s,ℓ}(Q̃Wy),  |det G| = det(NᵀΣ^{−1}N)^{1/2} ≥ v_max^{−3/2}.**

*Proof.* With 𝔪 as in E1 (so 𝔪(y + Nb) = 𝔪(y)), for φ ≥ 0 and Ã ⊂ ℝ³: by the substitution E = y − Nc − Su, and Q̃WN = 0, ÑᵀWNc = Gc,

  ∫𝔪(y)φ(Q̃Wy)1{ÑᵀWy ∈ Ã}dy = ∫∫∫φ(Q̃W(Su + E))1{Gc + ÑᵀW(Su + E) ∈ Ã}∏q_s(Eᵢ)dE Π_ℓ(du)dc = (|Ã|/|det G|)·𝔼φ(Ỹ_mod).

On the other side put ỹ = Wy = Ñã + Q̃ᵀr̃ (dy = det(W)^{−1}dã dr̃). W^{−1}Ñã ∈ range N, so 𝔪(y) = 𝔪(W^{−1}Q̃ᵀr̃), and the left side is det(W)^{−1}|Ã|∫𝔪(W^{−1}Q̃ᵀr̃)φ(r̃)dr̃. Compare. GᵀG = NᵀW(ÑÑᵀ)WN = NᵀW²N because ÑÑᵀ projects onto range(WN). ∎

Lemma E2 is unchanged (with Q̃ = [P̃; P̃′], the true density f̃ of Q̃Wy and f̃_T of P̃Wy; f̃ need not be positive everywhere: the conditional Markov step only needs E₀[p(R | T)/f̃(R | T) | T] ≤ 1).

**E3′-W.** P̃WS = P̃WA₀ (rows of P̃ are orthogonal to WN), so T̃_mod = M̃u + P̃WE with M̃ := P̃WA₀ and M̃M̃ᵀ = P̃·L̃⁺·P̃ᵀ, L̃ := Σ^{1/2}DᵀDΣ^{1/2} (Lemma W1(c) of `FABLE_B_averaged_beta.md`, with its W equal to Σ^{−1}); the nonzero eigenvalues of L̃ are the μ̂_r. Taking for P̃ the eigenvectors of L̃⁺ for 1/μ̂₁, …, 1/μ̂_d, Lemma E3 gives, for every s > 0:

  log‖π̃_T‖∞ ≤ −½Σ_{r≤d}log(4/(ℓ²μ̂_r)).

### 8.3 Lemma E4: the three flat directions — PROVED

Let f̃_Q be the density of Q̃ε̃. Under (M2), (M3), for K ≥ 1, with probability ≥ 1 − 3/K:

  **log f̃_Q(Q̃ε̃) ≤ Σᵢlog f̃ᵢ(ε̃ᵢ) + log(K·V₃·B_n³ + 1),  B_n = O(K·n).**

*Proof.* (ε̃ ↦ (Ñᵀε̃, Q̃ε̃) is orthogonal.) f̃_Q(Q̃ε̃) = ∫_{ℝ³}∏ᵢf̃ᵢ(ε̃ᵢ + (Ñb)ᵢ)db. Divide by ∏f̃ᵢ(ε̃ᵢ) > 0 (a.s.) and split at ‖b‖ = B_n.
- *Inside.* For a fixed shift vector w, E₀∏ᵢ[f̃ᵢ(ε̃ᵢ + wᵢ)/f̃ᵢ(ε̃ᵢ)] = ∏ᵢ∫f̃ᵢ(x + wᵢ)1{f̃ᵢ(x) > 0}dx ≤ 1. So the expectation of the inner integral is ≤ V₃B_n³, and by Markov it is ≤ K·V₃B_n³ off probability 1/K.
- *Outside, bounded supports.* The integrand vanishes unless |(Ñb)ᵢ| ≤ S̄/ς_min for all i, which forces ‖b‖₂ = ‖Ñb‖₂ ≤ √n·S̄/ς_min. Take B_n equal to this; the outer integral is 0.
- *Outside, envelope case.* ∏f̃ᵢ(ε̃ᵢ + wᵢ) ≤ C̃₀ⁿe^{c̃₀‖ε̃‖₁}e^{−c̃₀‖b‖₂} (as ‖w‖₁ ≥ ‖w‖₂ = ‖b‖₂). Off probability 2/K: ‖ε̃‖₁ ≤ K·n·C̃₁ (Markov) and −Σlog f̃ᵢ(ε̃ᵢ) ≤ n·|h̃̄| + √(nKv_h) (Chebyshev, (M2)). With B_n := (2/c̃₀)[n·log C̃₀ + c̃₀KnC̃₁ + n|h̃̄| + √(nKv_h)] + n, the outer integral divided by ∏f̃ᵢ(ε̃ᵢ) is ≤ 1 for large n. ∎

Since Σᵢlog f̃ᵢ(ε̃ᵢ) = Σᵢlog ςᵢ + Σᵢlog fᵢ(εᵢ) and log det W = −Σlog ςᵢ, Lemma E1-W, E4 and Chebyshev on (M2) give, off probability 4/K:

  **log(det W/|det G|) + log f̃(Q̃Wy) ≤ −n·h̄ₙ + √(nKv_h) + 3·log(Kn) + C.**

### 8.4 Lemma E5: reverse Markov for the true density of T — PROVED

For any random vector T with density f_T and **any** probability density g on the same space: P(f_T(T) < e^{−x}·g(T)) ≤ e^{−x}.

*Proof.* P(g(T)/f_T(T) > eˣ) ≤ e^{−x}·E[g(T)/f_T(T)] = e^{−x}∫_{f_T>0}g ≤ e^{−x}. ∎

Apply it to T = P̃Wy = P̃Wθ\* + P̃ε̃ with g := N(P̃Wθ\* + P̃Eε̃, I_d). Off probability e^{−x}: −log f̃_T(P̃Wy) ≤ x + (d/2)log(2π) + ½‖P̃ε̃_c‖². The coordinates of ε̃_c are independent, centred, of unit variance, and Π := P̃ᵀP̃ is a projector of rank d, so E‖P̃ε̃_c‖² = d and Var = ΣᵢΠᵢᵢ²(E ε̃_{c,i}⁴ − 1) + 2Σ_{i≠j}Πᵢⱼ² ≤ max(m̃₄, 2)·d. By Chebyshev, off probability 1/K:

  **−log f̃_T(P̃Wy) ≤ x + (d/2)·log(2πe) + ½√(K·max(m̃₄, 2)·d).**

No shape assumption on the noise is used; the mean of the noise (non-zero for skewed laws and τ ≠ ½) is absorbed in the centre of g.

### 8.5 The weighted spectral sum — PROVED

Let ϕ̂(μ) := log(2/(ℓ²μ)) − c′, decreasing. Take B blocks of lengths n_b, 𝒥_b and D_b as in Lemma W3 of `FABLE_B_averaged_beta.md`, κ_b := (2/(ℓ²v_b⁺))^{1/6}·n_b/π, x\*_b := κ_be^{−c′/6}, d_b := ⌊x\*_b⌋ − 3 (assume 6 ≤ x\*_b ≤ n_b − 3) and **d := Σ_bd_b**. Then

  **½·Σ_{r≤d}ϕ̂(μ̂_r) ≥ Σ_b[3x\*_b − 12·log κ_b − ½] = c_Λ·ℓ^{−1/3}·n·Ā_B − B·(12·log n + ½).**

*Proof.* The principal submatrix of DΣDᵀ on ∪_b𝒥_b is ⊕_bD_bΣ_bD_bᵀ ⪯ 𝒞 := ⊕_bv_b⁺·D_bD_bᵀ. By Cauchy interlacing and Weyl monotonicity μ̂_r ≤ λ_r(𝒞) for r ≤ Σ(n_b − 3). Since ϕ̂ decreases, Σ_{r≤d}ϕ̂(μ̂_r) ≥ Σ_{r≤d}ϕ̂(λ_r(𝒞)), and the sum of ϕ̂ over the d smallest eigenvalues of 𝒞 is at least its sum over any other d eigenvalues of 𝒞, in particular over {v_b⁺μ_r^{(b)} : r ≤ d_b, all b}. For each block, step (iv) of Proposition N with (n, ς_max²) replaced by (n_b, v_b⁺) gives Σ_{r≤d_b}ϕ̂(v_b⁺μ_r^{(b)}) ≥ 6x\*_b − 24·log κ_b − 1. Finally 3x\*_b = c_Λ·n_b·(ℓ²v_b⁺)^{−1/6}. ∎

### 8.6 Proposition N-W and Theorem DC-W — PROVED

**Proposition N-W.** Under (M1)–(M3), for every s > 0, a, x > 0, K ≥ 1 and every ℓ with 6 ≤ x\*_b ≤ n_b − 3 for all b, off probability e^{−a} + e^{−x} + 5/K:

  log Z(s, ℓ) ≤ −n·log t − n·h̄ₙ − c_Λ·n·ℓ^{−1/3}·Ā_B + a + x + C√(nK) + C·B·log(Kn).

*Proof.* By E1-W and E2: log Z ≤ −n log t + a + log‖π̃_T‖∞ + [log(det W/|det G|) + log f̃(Q̃Wy)] − log f̃_T(P̃Wy). Insert E3′-W, §8.3 and §8.4: the T-terms combine to −½Σ_{r≤d}[log(4/(ℓ²μ̂_r)) − log(2πe)] = −½Σ_{r≤d}ϕ̂(μ̂_r), and §8.5 applies. ∎

The events of probability 1/K do not depend on s; three of them do not depend on ℓ either.

**Theorem DC-W.** Assume (M1)–(M3), σ₀,ₙ → σ₀, R_n → R with σ₀ < 2tR, ‖Dθ\*‖₁ = o(n), and

  **c_Λ·ℓ₀^{−1/3}·Ā > Δ_KL + γ + η + 2δ,  Δ_KL = 1 + log(σ₀/t) − h̄.**

Then (DC_γ) holds on [ℓ₁, ℓ₀], i.e. sup{g_n(s, ℓ) : s > 0, ℓ₁ ≤ ℓ ≤ ℓ₀} ≤ b\* − γ + o(1) with probability → 1.

*Proof.* As Theorem DC-G: the flat bound and the corner bound of `FABLE_B_DC.md` §2.1–2.2 hold for every law; on the compact part use the grid lemma and Proposition N-W at the N nodes with a = ηn, x = (log n)², K = log n, and a fixed B so large that c_Λℓ₀^{−1/3}(Ā − Ā_B) is below the strict slack. The failure probability is ≤ N·e^{−ηn} + N_ℓ·(e^{−(log n)²} + 2/log n) + 3/log n → 0 (N, N_ℓ are constants), and the error terms are O(√(log n/n)). ∎

**So ℓ₀ = (c_Λ·Ā/(Δ_KL + slack))³.** Compared with §4, ς_max^{−1/3} is replaced by Ā = ∫ς^{−1/3}.

### 8.7 The two designs satisfy (M1)–(M3) — PROVED

**Beta design.** yᵢ ~ Beta(1, bᵢ), bᵢ = 11 − 10uᵢ ∈ [1, 11], density b(1 − y)^{b−1} on [0, 1]; εᵢ = yᵢ − q_τ(uᵢ).
- *Log-concavity (asked).* log f = log b + (b − 1)log(1 − y) is concave on [0, 1] for every b ≥ 1 (linear at b = 1, the uniform law). Extended by zero it is log-concave on ℝ. **But this is not used:** §8 needs no log-concavity.
- *Bounded support (asked).* It is handled in Lemma E4's first case (S̄ = 1): the flat-direction integral is over a ball of radius √n/ς_min, and the positivity of f̃ is not needed in E2. The jump of the density at y = 0 plays no role.
- (M1): v(u) = b/((1+b)²(2+b)), smooth and monotone in u, from 0.00588 (b = 11) to 1/12 (b = 1); all moments bounded.
- (M2): −log f(Y) = −log b + (b − 1)·X with X := −log(1 − Y) ~ Exponential(rate b) (because 1 − Y ~ Beta(b, 1)). So h = −log b + 1 − 1/b and **Var(−log f(Y)) = (b − 1)²/b² ≤ 1**. h̄ = ∫₀¹[−log(11 − 10u) + 1 − 1/(11 − 10u)]du = −0.87747.

**Mixed design.** yᵢ ~ uᵢ·N(−0.2, ½) + (1 − uᵢ)·N(0.2, ½) (variance ½ per component, as in `gap_ratio_check.py`).
- (M1): v(u) = 0.5 + 0.16·u(1 − u) ∈ [0.5, 0.54]; fourth moments bounded.
- (M2): |log f_u(x)| ≤ C + (|x| + 0.2)², so the variance of the information density is bounded uniformly in u (constant not made explicit). h̄ = 1.09820 (quadrature).
- (M3): f_u(x) ≤ π^{−1/2}exp{−(|x| − 0.2)₊²}, which gives the envelope after the shift by q_τ(u); E|ε| bounded.

For both designs R_n → R and σ₀,ₙ → σ₀ by the law of large numbers, and σ₀/(2tR) ∈ [0.18, 0.47] (`noFloor_necessary.out`).

---

## 9. Ranges for all paper cells (total slack 0.03)

Ā = ∫ς^{−1/3}: **1.4574** (Gaussian), **1.9806** (Beta), **1.1128** (Mixed). c_Λ = 0.7497. ℓ₁ = 2t/(eσ₀).

| Design | τ | σ₀ | Δ_KL | ℓ₁ | **ℓ₀ = (c_ΛĀ/(Δ_KL + 0.03))³** | with ς_max instead of Ā (§4 form) |
|---|---|---|---|---|---|---|
| Gaussian | 0.50 | 0.13298 | 0.0722 | 1.38 | **1224** | 791 |
| Gaussian | 0.25, 0.75 | 0.10593 | 0.1324 | 1.30 | **304** | 197 |
| Gaussian | 0.05, 0.95 | 0.03438 | 0.3802 | 1.02 | **18.9** | 12.2 |
| Mixed | 0.50 | 0.28954 | 0.0486 | 0.64 | **1195** | 1180 |
| Mixed | 0.25 | 0.23062 | 0.1088 | 0.60 | **217** | 215 |
| Mixed | 0.05, 0.95 | 0.07483 | 0.3563 | 0.47 | **10.1** | 9.9 |
| Beta | 0.05 | 0.00866 | 0.1755 | 4.04 | **378** | 168 |
| Beta | 0.25 | 0.03686 | 0.2508 | 3.74 | **148** | 66 |
| Beta | 0.50 | 0.05557 | 0.3737 | 3.31 | **49.8** | 22.2 |
| Beta | 0.75 | 0.05028 | 0.5613 | 2.74 | **15.8** | 7.1 |
| Beta | 0.95 | 0.01779 | 0.8954 | 1.96 | **4.1** | 1.8 (empty) |

(The Mixed values supersede the hand estimates of §5: h̄ is 1.098, not 1.08.)

**Beta at τ = 0.95.**
- *What fails in the §4 form.* Δ_KL = 0.895 is large: at the 0.95 level the asymmetric-Laplace density is a poor fit to Beta(1, b) noise (the truth has its mode at the left end of the support, with a hard edge, while ALD_{0.95} centred at the quantile has its mode at the quantile). So b\* lies 0.9 nats per observation below the entropy bound, and with ς_max = 0.289 the gain 0.75·(0.289ℓ)^{−1/3} exceeds 0.925 only for ℓ < 1.84 < ℓ₁.
- *The whitened variant helps.* The Beta design is strongly heteroscedastic, so Ā = 1.98 against ς_max^{−1/3} = 1.51. Theorem DC-W gives **ℓ₀ = 4.1 at slack 0.03 (4.6 at zero slack) > ℓ₁ = 1.96**. The range [1.96, 4.1] is non-empty but short, and the slack is thin: the certificate route of `FABLE_B_DC.md` remains the way to reach a larger ℓ₀ in this cell if one is wanted.
- *What cannot help.* Any refinement of this method keeps Δ_KL, so ℓ₀ ≤ (0.935·Ā/Δ_KL)³ ≈ 8.9 for this cell even with the exact Gaussian constant.

**Caveats.**
- ℓ₀ in the table is evaluated at Ā (B → ∞). For a fixed B the theorem needs the strict inequality with Ā_B; the difference is absorbed in the slack.
- The ranges at the outer levels are short (Gaussian and Mixed at 0.05/0.95: up to 19 and 10). They are still constants, which is all L2 requires.
- σ₀ and the worst-case checks are the values of `gap_ratio_check.out`; Ā, h̄ (Mixed) and the table arithmetic come from my quadrature and were not cross-checked by a second script.

**Alignment with the audit of §1–§7 (`reviews/AUDIT_astra_L2.md`).** §8–§9 were written before I saw the audit response above; its fixes carry over as follows.
- *Fix 2 (quantifiers), fix 4 (flat bound at s_hi; each point bounded from the node with larger s and smaller ℓ):* the proof of Theorem DC-W is that of DC-G and takes them unchanged.
- *Fix 3 (hypothesis on x\*):* here it reads 6 ≤ x\*_b ≤ n_b − 3 for every block, i.e. ℓ·ς_min > (c_Λ/3)³ = 0.0156 at the lower end. It holds in every cell of §9 (smallest value: Beta, ℓ₁ς_min = 1.96 × 0.0767 = 0.15).
- *Fix 5 (no "every τ"; the denominator needs (A3)):* Theorem DC-W is claimed only for the tabulated levels, where σ₀ < 2tR holds with the margins of `noFloor_necessary.out`; the posterior consequence needs the benchmark denominator, which uses (A3).
- *Fix 6 (slack-adjusted ℓ₁):* the bound of Proposition N-W is valid, and stronger, below ℓ₁, so the range may start at the slack-adjusted ℓ₁ without change. The Gaussian ς_max column above is the audited one (790, 196.7, 12.2).
- *Fix 7 (strict corner margin σ₀e^{2γ} < 2tR):* assumed in Theorem DC-W as in DC-G.
- *Fix 8:* nothing in §8–§9 uses the withdrawn Δ = 0 remark.

## Theory response to §8–§9 (2026-11-23)

**Status: Theorem DC-W (general independent noise, whitened) is PROVED (one pass), UNAUDITED.** If it holds, L2 covers Mixed and Beta. The audited Gaussian result above, with ℓ₀ = 790 / 196 / 12, stands independently.

**Checked by Theory:**
- **Ā (Gaussian).** ∫₀¹((1+u²)/4)^{−1/3}du = 1.45741, by quadrature.
- **ℓ₀ (Gaussian, τ = ½).** (c_Λ·Ā/(Δ_KL + 0.03))³ = 1223.7, which matches the table's 1224.
- **Not checked:** the Beta and Mixed constants Ā and the entropies; the varentropy and envelope constants for Mixed. Fable B flags these too.

**Beta at τ = 0.95:** the range is non-empty but short, ℓ ∈ [1.96, 4.1]. The method caps at ≈ 8.9 there, so the certificate route remains for larger ℓ₀.

**Next:** Astra cross-family audit of §8–§9 (Tuesday, or tonight if Codex is free).

## Cross-family audit response to §8–§9 (Astra, `reviews/AUDIT_astra_DCW.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES.** All eight findings are CONFIRMED, and Theory rules that they **HOLD**. Astra's independent quadrature reproduces Ā for Beta (1.980639) and for Mixed (1.112840), the Mixed entropy (1.098203), and Theory's Gaussian values.

**Fixes (applied by reference; written in full in Tuesday's clean rewrite):**
- **Hypothesis.** State γ < log(2tR/σ₀) as a hypothesis, together with fixed 0 < ℓ₁ < ℓ₀ and positive γ, η, δ.
- **Posterior conclusion.** It uses the denominator bound under (A3).
- **Table.** Replace the §9 table by the audit's full-precision table, with endpoints rounded strictly down. Use 1223 for Gaussian ½, 10.08 for the Mixed tails, 49.75 for Beta ½, and 378 for Beta 0.05 (conservative; formula 380.15). The unwhitened column is labelled approximate.
- **Beta τ = 0.95.** The range [1.96, 4.1] holds, with margin 0.0022. **The "cap ≈ 8.9" is unproved and is deleted.**

**Status: L2 is PROVED and cross-family audited for all three paper designs at τ ∈ {0.05, 0.25, 0.5, 0.75, 0.95}**, on [ℓ₁, ℓ₀] with ℓ₀ from the audit table, given (A3) for the denominator. Beta at τ = 0.95 has a short range only, which is still non-empty.
