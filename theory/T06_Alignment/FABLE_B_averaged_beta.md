# Gap 2: the averaged Occam condition (position-dependent densities in Theorem LO)

*Fable, research sub-agent for Theory, 2026-11-23. By hand. The design values in §1.3 were computed by numerical quadrature (a throw-away script using the definitions of `../T05_Proofs/checks/gap_ratio_check.py`; not in the repository). No simulation. **Not audited.** Inputs: `FABLE_A_three_lemmas.md` (Theorem LO, Lemmas 1, 2a, 2b, §4) and `reviews/AUDIT_astra_LO.md` (finding 9).*

**Labels.** PROVED = fully written here from Fable A's audited lemmas and elementary facts. SKETCH = argument given, a step not rewritten. CONJECTURE = heuristic.

## 0. Verdict

| # | Claim | Status |
|---|---|---|
| 1 | **The averaged condition is β̄ < 6**, with β̄ := ω·t·Σᵢfᵢ^{−5/6}/Σᵢfᵢ^{1/6}: the average of the local ratio β_i = ωt/fᵢ with weights fᵢ^{1/6} (the local mode density) | Identified; the leading-order comparison is PROVED (§4–5) |
| 2 | β̄ ≤ plain average of β_i ≤ max β_i | PROVED (§1.2) |
| 3 | Values at σ = σ₀: Gaussian τ = 0.05/0.95: **4.43**; Beta τ = 0.95: **5.12**, τ = 0.05: 1.27; Mixed τ = 0.05/0.95: **4.46**. All three designs cross 6 between τ = 0.96 and 0.97 | Computed (§1.3) |
| 4 | Exact weighted formula for the Gaussian-likelihood integral: the homogeneous structure survives with A₀A₀ᵀ replaced by L⁺, L = W^{−1/2}DᵀDW^{−1/2} | PROVED (§2) |
| 5 | The mixture sandwich (Lemma 2b) needs **no change**: it is conjugated by P̃⊥W^{1/2} | PROVED (§3) |
| 6 | **Weighted spectral inequality** (replaces Lemma 2a): cost and gain bounds for DW^{−1}Dᵀ by block bracketing, with the sharp constants 2π and π/3 | PROVED (§4) |
| 7 | Resulting determinant/gain comparison: −(π/6)·k̄_\*·(6 − β̄)·(1 − o(1)) | PROVED (§5.1) |
| 8 | **Theorem LO with β̄ in place of β** (fixed (ω, ℓ), same window) | SKETCH (§5.2): the remaining steps of Fable A's §4.4–4.5 go through with constants depending on max fᵢ/min fᵢ; not rewritten |

**In one sentence.** The min-density loss in Theorem LO is not in the mixture step at all; it is only in the spectral input. Replacing Lemma 2a by a block-bracketed version for the weighted matrix DW^{−1}Dᵀ gives the averaged condition β̄ < 6, which holds for all three paper designs at τ = 0.05 and 0.95 and fails at 0.97, as in the κ̂ pilot.

---

## 1. The condition

### 1.1 Definition

Let fᵢ > 0 be the lower secant slope of Fᵢ at the quantile on [−s_K, s_K] (audit finding 9; it tends to the point density as s_K → 0), t = τ(1−τ), ω = 1/σ. Put

  **S₊ := Σᵢfᵢ^{1/6},  S₋ := Σᵢfᵢ^{−5/6},  β̄ := ω·t·S₋/S₊,  k̄_\* := (2ω(1−η))^{1/6}·ℓ^{−1/3}·S₊/π.**

For fᵢ ≡ f these are β = ωt/f and Fable A's k_\*. In the limit fᵢ = f(i/n): β̄ = (t/σ)·∫₀¹f^{−5/6}/∫₀¹f^{1/6}.

**Reading.** At position u the local number of fitted modes per unit length is ∝ (ωf(u))^{1/6}, each costing ½·2π in the determinant, and the local score gain per mode is ∝ β(u) = ωt/f(u). So the evidence exponent is −(π/6)∫(6 − β(u))·k_loc(u)du, and its sign is that of 6 − β̄. This is the weighted average proposed in `FABLE_B_Arule_gauss.md` §6, now with the weight identified as f^{1/6}.

### 1.2 Ordering — PROVED

β̄ = ωt·Σᵢ(1/fᵢ)·fᵢ^{1/6}/Σᵢfᵢ^{1/6} is a weighted mean of 1/fᵢ with weights decreasing in 1/fᵢ. By Chebyshev's sum inequality, β̄ ≤ ωt·n⁻¹Σᵢ1/fᵢ (the plain average) ≤ ωt/minᵢfᵢ (Theorem LO's β). The weight f^{1/6} varies little, so β̄ is close to the plain average.

### 1.3 Values for the paper's designs (σ = σ₀)

For the Gaussian design, f(u) = φ(z_τ)/s(u) and σ₀ = φ(z_τ)·∫s, so in closed form

  **β̄ = [τ(1−τ)/φ(z_τ)²]·ρ_s,  ρ_s := ∫s^{5/6}/(∫s·∫s^{−1/6}) = 0.9921 for s(u) = (1+u²)/4.**

| Design | τ | worst case t/(σ₀·min f) (Theorem LO) | plain average | **β̄** | β̄ < 6 ? |
|---|---|---|---|---|---|
| Gaussian | 0.05, 0.95 | 6.70 | 4.47 | **4.43** | yes |
| Gaussian | 0.25, 0.75 | 2.79 | 1.86 | 1.84 | yes |
| Gaussian | 0.50 | 2.36 | 1.57 | 1.56 | yes |
| Gaussian | 0.96 / 0.97 | 7.76 / 9.43 | 5.17 / 6.29 | **5.13 / 6.24** | yes / **no** |
| Beta | 0.05 | 5.49 | 1.36 | **1.27** | yes |
| Beta | 0.95 | 6.56 | 5.15 | **5.12** | yes |
| Beta | 0.96 / 0.97 | 7.35 / 8.61 | 5.88 / 7.01 | **5.85 / 6.97** | yes / **no** |
| Mixed | 0.05, 0.95 | 4.53 | 4.46 | **4.46** | yes |
| Mixed | 0.96 / 0.97 | 5.24 / 6.37 | 5.17 / 6.28 | **5.17 / 6.28** | yes / **no** |

(Also: Gaussian 0.99: 13.8; Beta 0.01: 1.25, 0.99: 14.2; Mixed 0.99: 13.9.)

- Both cells excluded by the min-density form (Gaussian 0.05/0.95, Beta 0.95) are **inside** the averaged condition, with margins 1 − β̄/6 = 0.26 and 0.15.
- All three designs cross between τ = 0.96 and 0.97. The pilot lost the sign at τ = 0.97, n = 2000.
- For the Gaussian design ωf(u) does not depend on τ at σ = σ₀ (both σ₀ and f scale with φ(z_τ)), so k̄_\* is τ-free and the predicted ratio κ(0.05)/κ(0.5) is (6 − 4.43)/(6 − 1.56) = **0.35**. The pilot found 0.4–0.5 in mid-range and a steeper slope (−0.43): same sign and order, not the same number. The proxy constant is not confirmed at τ = 0.05.

---

## 2. The weighted Gaussian-likelihood integral — PROVED

After Lemma 1 the likelihood is bounded on K′ by a Gaussian one. With position-dependent slopes this reads (see §5.2 for the adaptation of Lemma 1)

  −ωℛ(δ) ≤ ω⟨ψ, δ⟩ − ½δᵀWδ + const,  **W := diag(wᵢ), wᵢ := ω(1−η)fᵢ.**

Let 𝒵_W := ∫exp{ω⟨ψ, δ⟩ − ½δᵀWδ}dg Π_ℓ(du), δ = Ng + (y − y\*), y = A₀u, as in Fable A §4.2.

**Notation.** P̃ := the orthogonal projector onto range(W^{1/2}N), P̃⊥ := I − P̃; ψ̃ := ω·W^{−1/2}ψ; ỹ\* := P̃⊥W^{1/2}y\*; Γ_V := P̃⊥W^{1/2}Σ_VW^{1/2}P̃⊥; **L := W^{−1/2}DᵀDW^{−1/2}**.

**Lemma W1.**
(a) 𝒵_W = (2π)^{3/2}det(NᵀWN)^{−1/2}·e^{½‖ψ̃‖²}·E_V[det(I + Γ_V)^{−1/2}·exp{−½z̃ᵀ(I + Γ_V)^{−1}z̃}], z̃ := ỹ\* + P̃⊥ψ̃.
(b) The V-dependent factors are monotone in Σ_V exactly as in Fable A §4.3. For a fixed Γ₊ ⪰ Γ_V, with B̃₊ := (I + Γ₊)^{−1} and M̃₊ := Γ₊(I + Γ₊)^{−1}:

  ½‖ψ̃‖² − ½z̃ᵀB̃₊z̃ = ½‖P̃ψ̃‖² + **½ψ̃ᵀM̃₊ψ̃** − [⟨B̃₊ỹ\*, ψ̃⟩ + ½‖B̃₊^{1/2}ỹ\*‖²].

(c) P̃⊥W^{1/2}A₀A₀ᵀW^{1/2}P̃⊥ = **L⁺** (Moore–Penrose). Its nonzero eigenvalues are 1/μ̃_r, with μ̃₁ ≤ … ≤ μ̃_m the eigenvalues of the m×m matrix **DW^{−1}Dᵀ**.
(d) For Γ = ϱL⁺: log det(I + Γ) = Σ_r log(1 + ϱ/μ̃_r), and tr(W^{−1/2}·Γ(I + Γ)^{−1}·W^{−1/2}) ≤ **tr((W + ϱ^{−1}DᵀD)^{−1})**.

*Proof.*
(a) ω⟨ψ, δ⟩ − ½δᵀWδ = ½‖ψ̃‖² − ½‖W^{1/2}δ − ψ̃‖². Integrating g over ℝ³: ∫exp{−½‖W^{1/2}Ng + v‖²}dg = (2π)^{3/2}det(NᵀWN)^{−1/2}e^{−½‖P̃⊥v‖²}, with v = W^{1/2}(y − y\*) − ψ̃. Given V, Y := P̃⊥W^{1/2}y ~ N(0, Γ_V), and E e^{−½‖Y − z̃‖²} = det(I + Γ_V)^{−1/2}e^{−½z̃ᵀ(I+Γ_V)^{−1}z̃}.
(b) Γ_V is a congruence of Σ_V, so Loewner order is preserved. The expansion is that of Fable A §4.3, using I − B̃₊ = M̃₊ and M̃₊ = P̃⊥M̃₊P̃⊥.
(c) A₀A₀ᵀ = (DᵀD)⁺. Put G := W^{1/2}(DᵀD)⁺W^{1/2} and X := P̃⊥GP̃⊥. X is symmetric and vanishes on range P̃ = null L. For x ∈ range P̃⊥: LXx = LGx (since LP̃ = 0) = W^{−1/2}P⊥W^{1/2}x = x − W^{−1/2}P_NW^{1/2}x = x, because x ⊥ W^{1/2}N. So X = L⁺. The nonzero spectra of L = (DW^{−1/2})ᵀ(DW^{−1/2}) and of DW^{−1}Dᵀ coincide.
(d) On range P̃⊥, ϱL⁺(I + ϱL⁺)^{−1} = (I + L/ϱ)^{−1}, so ϱL⁺(I + ϱL⁺)^{−1} = (I + L/ϱ)^{−1} − P̃, and W^{−1/2}(I + L/ϱ)^{−1}W^{−1/2} = (W + ϱ^{−1}DᵀD)^{−1}. Drop the nonnegative term tr(W^{−1/2}P̃W^{−1/2}). ∎

**Consequence.** The cost is ½Σlog(1 + ϱ₋/μ̃_r) and the expected main gain is (ω²t/2)·tr(W^{−1/2}M̃₊W^{−1/2}) ≤ (ω²t/2)·tr((W + ϱ₊^{−1}DᵀD)^{−1}) (E ψ̃ᵀQψ̃ = ω²t·tr(W^{−1/2}QW^{−1/2})). Both are functions of W through the single matrix DW^{−1}Dᵀ, resp. W + ϱ^{−1}DᵀD.

---

## 3. The mixture sandwich with weights — PROVED (no new work)

Lemma 2b is a statement about Σ_V = ΣⱼVⱼa_ja_jᵀ only: on its event, c₋v₁A₀A₀ᵀ − E ⪯ Σ_V ⪯ c₊v₁A₀A₀ᵀ + E′, with E = γ^{−1}(v₁ + v̄)𝒟 and E′ = (1 + γ^{−1})v̄𝒟. Conjugating by P̃⊥W^{1/2}:

  **c₋v₁·L⁺ − Ẽ ⪯ Γ_V ⪯ c₊v₁·L⁺ + Ẽ′,  Ẽ := P̃⊥W^{1/2}EW^{1/2}P̃⊥,  tr Ẽ ≤ w_max·tr E,**

and likewise for Ẽ′. So "the sandwich against diag(fᵢ)" is the homogeneous sandwich, conjugated; the weights cost only the factor w_max in the trace errors (and w_max/w_min after the gain is multiplied by W^{−1}). The probability statements of Lemma 2b are unchanged.

---

## 4. Lemma W3: weighted spectral inequality by block bracketing — PROVED

**Setting.** Partition {1, …, n} into consecutive blocks b of lengths n_b ≥ 8. Let w_b⁻ := min_{i∈b}wᵢ, D_b the third-difference matrix of the block ((n_b − 3)×n_b), and for ϱ > 0, κ_b := (ϱw_b⁻)^{1/6}n_b/π. Assume κ_b ≥ 4 for all b, and let η ∈ (0, 1).

**Lemma W3.**
- **(cost)** Σ_{r≤m}log(1 + ϱ/μ̃_r) ≥ Σ_b[2π·κ_b − 24·log κ_b − 24 − κ_b⁶/(5(n_b − 3)⁵)].
- **(gain)** tr((W + ϱ^{−1}DᵀD)^{−1}) ≤ Σ_b(w_b⁻)^{−1}·[(π/3)·κ_b/(1 − η²/2) + 4 + (πκ_b/2)⁶/(5(ηn_b)⁵)].

*Proof.* Let 𝒥_b := {j : {j, …, j+3} ⊂ b} (the rows of D whose stencil lies inside block b; |𝒥_b| = n_b − 3) and 𝒥 := ∪_b𝒥_b.

*(cost)* Consider the principal submatrix of DW^{−1}Dᵀ on 𝒥. For j ∈ 𝒥_b and k ∈ 𝒥_{b′} with b ≠ b′ the stencils are disjoint, so the entry Σᵢ D_{ji}D_{ki}/wᵢ vanishes. Within a block the submatrix is D_bW_b^{−1}D_bᵀ ⪯ (w_b⁻)^{−1}D_bD_bᵀ. By Cauchy interlacing and Weyl monotonicity, the r-th smallest eigenvalue of DW^{−1}Dᵀ is at most the r-th smallest eigenvalue of ⊕_b(w_b⁻)^{−1}D_bD_bᵀ, for r ≤ |𝒥|. Since x ↦ log(1 + ϱ/x) is decreasing and the remaining terms are ≥ 0,

  Σ_{r≤m}log(1 + ϱ/μ̃_r) ≥ Σ_bΣ_{r≤n_b−3}log(1 + ϱw_b⁻/μ_r^{(b)}),

with μ_r^{(b)} the eigenvalues of D_bD_bᵀ. Apply Lemma 2a (cost) to each block, with n → n_b and ϱ → ϱw_b⁻.

*(gain)* DᵀD = Σⱼd_jd_jᵀ (rows d_j of D) ⪰ Σ_{j∈𝒥}d_jd_jᵀ = ⊕_bD_bᵀD_b, and W ⪰ ⊕_bw_b⁻I. The inverse is antitone, so

  tr((W + ϱ^{−1}DᵀD)^{−1}) ≤ Σ_b tr((w_b⁻I + ϱ^{−1}D_bᵀD_b)^{−1}) = Σ_b(w_b⁻)^{−1}[3 + Σ_{r≤n_b−3}(ϱw_b⁻/μ_r^{(b)})/(1 + ϱw_b⁻/μ_r^{(b)})],

because D_bᵀD_b has the eigenvalue 0 three times and otherwise the μ_r^{(b)}. Apply Lemma 2a (gain) to each block. ∎

**Remarks.**
- Both bounds use the **lower** block weight, and both go the right way: dropping the rows of D that cross block boundaries decouples the blocks, which only adds small eigenvalues (more cost counted) and only enlarges the resolvent trace (more gain counted).
- The constants 2π and π/3 are those of Lemma 2a, untouched. Nothing is lost at leading order except the within-block variation of w.
- **Riemann sums.** If wᵢ = w(i/n) with w of bounded variation and w_min ≤ w ≤ w_max, and all n_b ≤ n̄: Σ_bn_b(w_b⁻)^{1/6} ≥ Σᵢwᵢ^{1/6} − n̄·TV(w^{1/6}) and Σ_bn_b(w_b⁻)^{−5/6} ≤ Σᵢwᵢ^{−5/6} + n̄·TV(w^{−5/6}). With B equal blocks the relative errors are O(1/B). **A regularity condition on i ↦ fᵢ is therefore needed** (bounded variation suffices); for arbitrary non-identical fᵢ only the min-density form is available by this route.

---

## 5. The comparison, and what remains

### 5.1 Determinant/gain comparison — PROVED

Take wᵢ = ω(1−η)fᵢ, ϱ_± = c_±v₁ = 2c_±/ℓ², B equal blocks, and f of bounded variation with f_min ≤ f ≤ f_max. Then (ϱw)^{1/6} = (2ω(1−η))^{1/6}c^{1/6}ℓ^{−1/3}f^{1/6} and ω²t·w^{−5/6}ϱ^{1/6} = (2ω(1−η))^{1/6}c^{1/6}ℓ^{−1/3}·(ωt/(1−η))·f^{−5/6}. Lemma W3 gives, with ε_B := C(f_max/f_min)·TV(f)/(f_min·B) and β̄′ := β̄/(1−η):

  **−½·Σ_r log(1 + ϱ₋/μ̃_r) + ½·(1+η)·ω²t·tr((W + ϱ₊^{−1}DᵀD)^{−1})
   ≤ −(π/6)·k̄_\*·[6·c₋^{1/6}(1 − ε_B) − β̄′·(1+η)·c₊^{1/6}(1 + ε_B)/(1 − η²/2)] + C·B·(log k̄_\* + ω²t/w_min) + (tail terms).**

As γ, η ↓ 0 and B → ∞ with B·log k̄_\* = o(k̄_\*), the bracket tends to **6 − β̄**. The tail terms sum to ≍ k̄_\*⁶/n⁵ (cost) and k̄_\*⁶/(ηn)⁵ (gain), since κ_b ≍ k̄_\*/B and n_b = n/B; they are o(k̄_\*) under Lemma 2a's own condition κ⁶ = o(n⁵η⁵). This is Fable A's §4.6 display with (k_\*, β) replaced by (k̄_\*, β̄).

### 5.2 Theorem LO with the averaged condition — SKETCH

**Statement (to be proved in full).** Under the hypotheses of Theorem LO, with fᵢ = f(i/n), f of bounded variation and bounded away from 0 and ∞, and **β̄ < 6**: Z̃_ω(ℓ) ≤ n^{C}e^{CK}·exp{−(1 − ε)(π/6)(6 − β̄)·k̄_\*}, on the same window in ℓ, with constants depending also on f_max/f_min and TV(f).

**What is already in place.** §2 (exact formula and monotone structure), §3 (mixture sandwich), §4–5.1 (cost and gain with sharp constants).

**What must still be rewritten, and why I expect no obstacle.**
1. *Lemma 1.* Its conclusion |R − M| ≤ ηM + η(f/4)k holds as stated (f there is only a normalizing constant in the additive term). Then use M(δ) ≥ ½Σᵢfᵢδᵢ² coordinate-wise instead of (f/2)‖δ‖². One line.
2. *Score events (Q1)–(Q4).* Chebyshev for ψᵀQψ with the fixed matrix Q = ω²W^{−1/2}M̃₊W^{−1/2}: E = t·tr Q and Var ≤ ¼‖Q‖²_F ≤ (ω²/(4w_min))·tr Q. Same as before with a → w_min.
3. *Flat part and shift.* ½‖P̃ψ̃‖² is a three-dimensional quadratic form with mean ≤ 3ω²t/w_min; the shift bracket is ≤ sup_x[√K·(ω√t/√w_min)·x − x²/2], a constant. det(NᵀWN)^{−1/2} is a constant.
4. *Atypical V and the dyadic family.* The crude gain bound is needed for Σ^{(i)}; use tr((W + ϱ^{−1}DᵀD)^{−1}) ≤ tr((w_minI + ϱ^{−1}DᵀD)^{−1}) and Lemma 2a's crude gain. The window for the block width w of Lemma 2b changes by factors of w_max/w_min only.
5. *Trace errors.* tr Ẽ ≤ w_max·tr E (§3) and, for the gain, M̃(X + Ẽ′) ⪯ M̃(X) + Ẽ′.

None of these uses the homogeneity of f beyond constants. I have not rewritten them, so the theorem is a SKETCH; the new mathematics (§2–§5.1) is proved.

**Matching lower bound — SKETCH.** The reverse bracketing (keeping the boundary rows, w_b⁺ in place of w_b⁻; a finite-rank perturbation of rank 3 per block boundary) should give the same leading terms from the other side, so that β̄ = 6 is the exact threshold of the Gaussian-likelihood integral. Not written.

---

## 6. Flags

- **Regularity is required.** The averaged condition is proved (at the level of §5.1) for densities that vary with bounded variation along the design. This covers the paper's three designs. It does not cover arbitrary independent non-identical laws; there the min-density condition stays.
- **Min f still enters the constants** (error terms, score variances, Lemma 1's additive term), not the threshold.
- **β̄ is evaluated at the point densities;** the theorem uses lower secant slopes on [−s_K, s_K], which converge to them. A strict margin is needed, as in audit finding 9.
- **Pilot comparison.** Sign: consistent in all cells, including the crossing between 0.96 and 0.97 and the two cells that the min-density form excluded. Magnitude at τ = 0.05: predicted ratio 0.35 against 0.4–0.5 observed, and the observed slope −0.43 is steeper than −1/3. One seed. The proxy constants are therefore supported in sign, not confirmed in size, at τ = 0.05.
- **Uniformity in (σ, ℓ)** remains open exactly as for Theorem LO (audit finding 10); nothing here addresses it.
- **Not verified:** the numbers of §1.3 beyond the script's own agreement with `gap_ratio_check.out` on σ₀ and the worst-case column (they agree to the digits shown); Fable A's Lemma 2a is used as audited.

---

## Theory response (2026-11-23)

**Status: the averaged condition and the key inequality are PROVED (one pass), UNAUDITED. Theorem LO with β̄ is SKETCH.**

**Checked by Theory:**
- **β̄ ≤ plain average ≤ min-density β.** By Chebyshev's sum inequality (f^{1/6} and 1/f are oppositely ordered).
- **Gaussian design factor 0.9921.** By quadrature: avg(s^{5/6})/(avg(s)·avg(s^{−1/6})) = 0.99208, s(u) = (1+u²)/4.
- **β̄ at Gaussian τ = 0.05:** t/φ(z_τ)²·0.9921 = 4.466·0.9921 = 4.43.

**Consequence.** The two cells excluded by the min-density form are inside, if the SKETCH closes: Gaussian τ = 0.05/0.95 at 4.43, and Beta τ = 0.95 at 5.12. So the **whole paper grid τ ∈ [0.05, 0.95]** would be covered.

**The crossing.** All three designs cross 6 between τ = 0.96 and 0.97, which is consistent with the κ̂ pilot's sign loss at 0.97.

**Tuesday.** Gap 2 becomes: rewrite LO's remaining steps with weights fᵢ (constants in max f/min f), under the regularity fᵢ = f(i/n) with f of bounded variation. Then audit (Astra).

---

## 7. Theorem LO-β̄: the weighted proof, step by step

*Appended 2026-11-23, about 15:20 CT, by the same author. Not audited. It rewrites Fable A's §4.1–4.6 with weights, including the fixes of `reviews/AUDIT_astra_LO.md`, findings 1–4. "LO §x" refers to `FABLE_A_three_lemmas.md`.*

### 7.0 Statement and status

**Regularity (REG).** fᵢ = f(i/n), where fᵢ is the lower secant slope of Fᵢ on [−s_K, s_K] (finding 9), with 0 < f_min ≤ f ≤ f_max and TV(f) ≤ V_f. Write Θ := f_max/f_min.

**Notation.** wᵢ = ω(1−η)fᵢ, w_min, w_max; β′_max := ω²t/w_min = ωt/((1−η)f_min); k := nℓ^{−1/3}; k_\*^{min}, k_\*^{max} := Fable A's k_\* evaluated at f_min, f_max; S_±, β̄, k̄_\* as in §1.1, so k_\*^{min} ≤ k̄_\* ≤ k_\*^{max} ≤ Θ^{1/6}k_\*^{min}.

**Theorem LO-β̄.** Assume the hypotheses of Theorem LO and (REG), and **β̄ < 6**. There are ε ∈ (0, 1), C and K₀, depending on 6 − β̄, Θ, V_f/f_min and the class constants, such that for K ≥ K₀ and every ℓ in Theorem LO's window (lower constant depending also on Θ), with probability ≥ 1 − C/K − C/k_\*^{min} − P₀(Ω_Gᶜ):

  **Z̃_ω(ℓ) ≤ n^{C}·e^{CK}·exp{−(1 − ε)·(π/6)·(6 − β̄)·k̄_\*}.**

| Step | Content | Status |
|---|---|---|
| 7.1 | Reduction to the weighted Gaussian likelihood (Lemma 1) | PROVED |
| 7.2 | Exact formula and monotone envelope (finding 1) | PROVED (§2) |
| 7.3 | Score events with weights (findings 1–2) | PROVED |
| 7.4 | Atypical V: dyadic family and split (findings 2–3) | PROVED |
| 7.5 | Typical V: trace errors, block window (finding 3) | PROVED |
| 7.6 | Coefficient and endpoint (finding 4) | PROVED |
| Whole theorem | Assembly of 7.1–7.6 | **PROVED by substitution into the audited LO proof**; every changed line is written below, the unchanged lines are cited. Not audited as a whole |

**The step most likely to break** was 7.5–7.6: whether the leading constants survive when the gain is weighted by W^{−1} while the mixture errors are not. They do, because every error enters through a trace and costs only the factor w_max/w_min (7.5), and the block number B of Lemma W3 can be taken **fixed** (7.6). No step broke.

### 7.1 Reduction — PROVED

Lemma 1 (with finding 5's fixes) is applied with f := f_min: on its event, for all δ ∈ K′, R(δ) ≥ (1 − η)M(δ) − η(f_min/4)k. Its proof uses f only in step 6, as a common lower bound for M(δ) ≥ (f/2)‖δ‖₂², so nothing changes. On K′, ‖δ‖∞ ≤ s_K, and mᵢ(δᵢ) = ∫₀^{δᵢ}(Fᵢ(s) − τ)ds ≥ fᵢδᵢ²/2 by the definition of fᵢ. Hence

  −ωℛ(δ) ≤ ω⟨ψ, δ⟩ − ½δᵀWδ + ωη(f_min/4)k  on K′,

and Z̃_ω(ℓ) ≤ e^{ωη(f_min/4)k}·𝒵_W + N_ℓ(K′ᶜ), with 𝒵_W of §2 (the indicator of K′ is dropped, as in LO §4.1). ωη(f_min/4)k ≤ C·η·k̄_\*.

### 7.2 Envelope — PROVED

By Lemma W1 and monotonicity: if Γ₋ − Ẽ ⪯ Γ_V ⪯ Γ₊ for **fixed** matrices supported on range P̃⊥, the conditional integrand is at most

  C_W·exp{−½log det(I + Γ₋) + ½tr Ẽ}·exp{½‖P̃ψ̃‖² + ½ψ̃ᵀM̃₊ψ̃ − ⟨B̃₊ỹ\*, ψ̃⟩ − ½‖B̃₊^{1/2}ỹ\*‖²},  C_W := (2π)^{3/2}det(NᵀWN)^{−1/2}.

Both shift terms carry a minus sign, and B̃₊ is fixed before any score event is used (finding 1). The determinant uses the lower envelope and the tangent bound log det(I + Γ_V + Ẽ) ≤ log det(I + Γ_V) + tr Ẽ.

### 7.3 Score events — PROVED

ψ has independent mean-zero coordinates with variance t and values in [τ − 1, τ]; for fixed symmetric Q, E ψᵀQψ = t·tr Q and Var ≤ ¼‖Q‖²_F.

- **(Q1-W) main gain.** Q := ω²W^{−1/2}M̃₊W^{−1/2}, so ½ψ̃ᵀM̃₊ψ̃ = ½ψᵀQψ. ‖Q‖_op ≤ ω²/w_min, hence ‖Q‖²_F ≤ (ω²/w_min)·tr Q and P(ψᵀQψ > (1 + η)t·tr Q) ≤ ω²/(4η²t²·w_min·tr Q). Lower bound for tr Q (finding 2): M̃ is monotone, so tr Q ≥ (ω²/w_max)·tr M̃(c₊v₁L⁺) = (ω²/w_max)·Σ_r(ϱ₊/μ̃_r)/(1 + ϱ₊/μ̃_r). Since DW^{−1}Dᵀ ⪯ w_min^{−1}DDᵀ, μ̃_r ≤ μ_r/w_min, and by Lemma 2a at least min(m, ⌊k_\*^{min}c₊^{1/6}⌋ − 3) terms are ≥ ½. So the failure probability is ≤ C·Θ/(η²t²·k_\*^{min}).
- **(Q2-W) shift.** ⟨B̃₊ỹ\*, ψ̃⟩ = ω⟨W^{−1/2}B̃₊ỹ\*, ψ⟩ has variance ≤ (ω²t/w_min)‖B̃₊ỹ\*‖² ≤ (ω²t/w_min)·x², x := ‖B̃₊^{1/2}ỹ\*‖ (B̃₊² ⪯ B̃₊). With probability ≥ 1 − 1/H: −⟨B̃₊ỹ\*, ψ̃⟩ − ½x² ≤ sup_{x≥0}[√(H·ω²t/w_min)·x − x²/2] = **H·β′_max/2**. A constant, for every truth.
- **(Q3-W) flat part.** ‖P̃ψ̃‖² = ω²ψᵀW^{−1/2}P̃W^{−1/2}ψ has mean ω²t·tr(W^{−1/2}P̃W^{−1/2}) ≤ 3ω²t/w_min. With probability ≥ 1 − 1/K: ½‖P̃ψ̃‖² ≤ 3Kβ′_max/2. Counted once, in C_ψ := C_W·e^{3Kβ′_max/2} (finding 2). C_W ≤ (2π/w_min)^{3/2}.

### 7.4 Atypical V — PROVED

Dyadic family Γ^{(i)} := 2^iv₁L⁺, i ≥ 0; q_i := 2^{i/6}k_\*^{min}.
- *Crude gain.* By Lemma W1(d) and W ⪰ w_minI: tr(W^{−1/2}M̃^{(i)}W^{−1/2}) ≤ tr((w_minI + (2^iv₁)^{−1}DᵀD)^{−1}) = w_min^{−1}[3 + Σ_r(2^iv₁w_min/μ_r)/(1 + 2^iv₁w_min/μ_r)] ≤ w_min^{−1}[(π²/6)q_i + 4] (Lemma 2a, crude gain).
- *Events.* For 4 ≤ q_i ≤ n: (Q1-W) with factor 2; by the lower bound of 7.3 with q_i in place of k_\*^{min}, the failures sum to ≤ CΘ/k_\*^{min}. For q_i > n: deterministically ½ψ̃ᵀM̃^{(i)}ψ̃ ≤ ½‖ψ̃‖² ≤ ω²n/(2w_min). Shift: (Q2-W) with H_i := K·2^{i/6}; failures sum to < 9.2/K; cost β′_max·H_i/2 (finding 2).
- *Result.* On these events, for all i, the non-flat score and shift exponent with Γ₊ = Γ^{(i)} is ≤ **C₂·q_i**, where C₂ is LO §4.4's constant with β′ replaced by β′_max and the additive "+1" of the crude gain replaced by "+4" (I did not re-add its terms; it is a constant depending on K, t and β′_max only).
- *Split* (LO §4.5, with Cramér restricted to η ≤ ½, finding 3). Let c₀ := the least power of 2 above max{(4C₂k_\*^{min})^{6/5}, 8π·k_\*^{max} + 4 log 2m}, v̄ := c₀v₁.
  - max Vⱼ ∈ (2^{i−1}v₁, 2^iv₁], 2^i > c₀: Σ_V ⪯ 2^iv₁A₀A₀ᵀ gives Γ_V ⪯ Γ^{(i)}; det^{−1/2} ≤ 1; probability ≤ m·e^{−2^{i−1}}. Since 2^{5i/6} ≥ 4C₂k_\*^{min}, the total is ≤ C_ψ·2m·e^{−c₀/4} ≤ C_ψ·e^{−2π·k_\*^{max}}.
  - bounded maximum, some block sum off by more than η: integrand ≤ C_ψe^{C₂k_\*^{min}c₀^{1/6}}, probability ≤ (2m/w)e^{−wη²/3}; total ≤ C_ψe^{−2πk_\*^{max}} when w ≥ 3(C₂k_\*^{min}c₀^{1/6} + 2πk_\*^{max} + log 2m)/η².

  Both are ≤ C_ψ·e^{−2π·k̄_\*}, below the typical term.

### 7.5 Typical V — PROVED

On Lemma 2b's event, by §3: Γ₋ := c₋v₁L⁺, Ẽ = P̃⊥W^{1/2}EW^{1/2}P̃⊥, Γ₊ := c₊v₁L⁺ + Ẽ′.
- *Determinant error.* ½tr Ẽ ≤ ½w_max·γ^{−1}(v₁ + v̄)·tr 𝒟.
- *Gain error.* From (I + X + Ẽ′)^{−1} ⪰ (I + X)^{−1} − (I + X)^{−1}Ẽ′(I + X)^{−1}: M̃(X + Ẽ′) ⪯ M̃(X) + BẼ′B with B = (I + X)^{−1}, B² ⪯ I. So tr(W^{−1/2}M̃₊W^{−1/2}) ≤ tr(W^{−1/2}M̃(c₊v₁L⁺)W^{−1/2}) + w_min^{−1}·tr Ẽ′, and the gain error is ≤ ½(1 + η)·ω²t·Θ·(1 + γ^{−1})·v̄·tr 𝒟.
- *Block width.* With tr 𝒟 ≤ (4/3)w²n⁴, v₁ = 2/ℓ², v̄ = c₀v₁, both errors are ≤ η·k̄_\* when

  w ≤ [3γη·k̄_\*·ℓ²/(8·(w_max + ω²tΘ(1 + η))·(c₀ + 1)·n⁴)]^{1/2}.

  With the lower bound on w from 7.4 and c₀ ≍ q^{6/5} + log m (q = k_\*^{min}), finding 3's calculation applies with constants multiplied by powers of Θ: it suffices that ℓ/n² ≳ (q^{6/5} + log 2m)^{3/2}/√q, i.e. **ℓ ≥ C(Θ)·n^{99/43}** up to the logarithm. Same window exponent.
- *Leading terms.* By (Q1-W), Lemma W1(d) and Lemma W3 with a **fixed** number B of equal blocks:

  log(integrand/C_ψ) ≤ −½Σ_r log(1 + ϱ₋/μ̃_r) + ½(1 + η)ω²t·tr((W + ϱ₊^{−1}DᵀD)^{−1}) + K·β′_max/2 + 2η·k̄_\*
            ≤ −(π/6)·k̄_\*·[6c₋^{1/6}(1 − ε_B⁺) − β̄′(1 + η)c₊^{1/6}(1 + ε_B⁻)/(1 − η²/2)] + K·β′_max/2 + 2ηk̄_\* + C·B·(log k̄_\* + β′_max) + (tails),

  with, under (REG), **ε_B⁺ ≤ V_f/(6f_min·B)** and **ε_B⁻ ≤ (5/6)·Θ^{5/6}·V_f/(f_min·B)** (from TV(f^{1/6}) ≤ f_min^{−5/6}V_f/6, TV(f^{−5/6}) ≤ (5/6)f_min^{−11/6}V_f, and block length ⌈n/B⌉). Lemma W3 needs κ_b ≥ 4, i.e. k_\*^{min} ≥ 4πB·c₋^{−1/6}, ensured by K₀ (see 7.6). The tails are O(k̄_\*⁶/n⁵) = o(1) on the window.

### 7.6 Coefficient and endpoint — PROVED

- *Order of choices (finding 4).* Fix the margin 6 − β̄ > 0. Choose B so large that ε_B^± are small against it; then γ, η small (c_± → 1, β̄′ → β̄); the bracket is then ≥ (1 − ε/2)(6 − β̄). The terms 2ηk̄_\* and ωη(f_min/4)k are O(η)·k̄_\*. The remaining terms K·β′_max/2 + 3Kβ′_max/2 + C·B·(log k̄_\* + β′_max) + log C_W are O(K) + O(log n): they go into n^{C}e^{CK}, outside the decaying exponential.
- *No growth is assumed.* Instead of "q → ∞": require k_\*^{min} ≥ q₀(B, γ, η), a numerical lower bound, ensured by the window through K₀ (the upper endpoint ℓ ≤ n³/(TVK) gives k ≥ (TVK)^{1/3}).
- *Upper endpoint.* N_ℓ(K′ᶜ) is bounded by C1's finite numerator inequality exactly as in finding 4 (it needs ωf_min·nr²/4 + 1 + m log 2 + Vℓ/(2n²) ≤ Tn/4); the weights do not enter the cones.
- *Sum.* Typical term + two atypical terms (each ≤ C_ψe^{−2πk̄_\*}) + N_ℓ(K′ᶜ), times e^{ωη(f_min/4)k}. This is the theorem. ∎

**What was not rewritten:** Lemma 1's internal proof, C1's cones, Lemma 2a and Lemma 2b; they are used as audited. C₂'s exact value is as in LO §4.4 with the replacements stated (I did not re-add its terms).

---

## 8. Does Theorem U carry over to β̄?

Read: `FABLE_A_uniformity.md` §0–§5 and `reviews/AUDIT_astra_U.md` (ACCEPT WITH FIXES; findings 1–9).

**Answer: yes, with the node estimate replaced by its weighted form; the three reductions are untouched.** Status: **PROVED by substitution for U1–U3 and the assembly; the weighted node estimate is PROVED as far as §7 plus the three tail replacements below.** Not audited.

| Step of U | Where f or β enters | With weights |
|---|---|---|
| U1 (ω, log-convexity) | nowhere | verbatim |
| U2 (ℓ-grid, ratio 1 + 1/n) | nowhere | verbatim |
| U3 (frozen bodies, Lemma 1 on panels) | f as a lower bound in C1's cone A₁ and in Lemma 1's additive term | verbatim with f := f_min; display (1) becomes Z̃_ω(ℓ) ≤ e^{ωη(f_min/4)k(ℓ)}·𝒵_{W,ω}(ℓ) + cones (7.1) |
| N (node estimate) | **the only place β enters** | Theorem LO-β̄ with strong tails, below |
| A (union, denominator) | κ_min | κ_min := min_j(1 − ε)(6 − β̄(ω_j))·k̄_\*(ω_j, ℓ)/(6k(ℓ)); β̄(ω) = ω·tS₋/S₊ is increasing in ω, so the condition is **β̄(ω₂) < 6** |

**Tail replacements at a node.**
- (Q1′-W) Hanson–Wright for Q = ω²W^{−1/2}M̃₊W^{−1/2}: ‖Q‖_op ≤ ω²/w_min and ‖Q‖²_F ≤ (ω²/w_min)·tr Q, so the deviation is ≤ (ω²/w_min)·[(4d·log n/c_HW)^{1/2} + 4 log n/c_HW] with d := (w_min/ω²)·tr Q ≤ C·Θ·k̄_\*; this is ≤ η·k̄_\* for n ≥ n₀, off probability 2n^{−4}.
- (Q2′-W) Hoeffding for b = ωW^{−1/2}B̃₊ỹ\*, ‖b‖ ≤ (ω/√w_min)·x: cost sup_x[(ω/√w_min)√(2 log n)·x − x²/2] = (ω²/w_min)·log n.
- (Q3′-W) flat part, one event for all nodes: range P̃ = range(diag(fᵢ)^{1/2}N) does **not depend on ω or ℓ**. Hoeffding on three orthonormal directions e of it, with ‖W^{−1/2}e‖ ≤ w_min^{−1/2}: ‖P̃ψ̃‖² ≤ 6ω² log n/w_min.
- (Q4′-W) as (Q4′) with the crude gain of 7.4 and β′ → β′_max.

Node proposition with weights: log 𝒵_{W,ω}(ℓ) ≤ −(1 − ε/2)(π/6)(6 − β̄(ω))·k̄_\* + C·log n, off probability C·log n·n^{−4}. The rest of U (§4–§6 there) uses only this bound, k(ℓ) ≥ c·n^{1/6}(log n)^{1/6} on the band, and V2T's denominator; so

  sup_P E_P sup_{ω∈I}Π_ω(L_n ≤ λ < c₋n^{5/2}(log n)^{−1/2} | y) → 0  **under β̄(ω₂) < 6 and (REG)**,

and U-σ holds under t·S₋/(S₊·(1 − ϵ)d) < 6. **For the paper's designs this now includes Gaussian τ = 0.05/0.95 and Beta τ = 0.95** (β̄ = 4.43 and 5.12 at σ₀; the interval I must keep β̄(ω₂) < 6, i.e. σ ≥ 0.74σ₀ and σ ≥ 0.86σ₀ respectively).

**Caveats.**
- **U's audit fixes carry over unchanged.** None of them touches the place where β enters: (1) dominate the whole negative square with the fixed upper envelope before expanding, and apply Hanson–Wright to the original score vector (here Q = ω²W^{−1/2}M̃₊W^{−1/2} acts on ψ itself, and M̃₊P̃ = 0 plays the role of QP_N = 0); (2) the shift parameter H_i = (2 log n + i)/t, with cost β′_max·H_i/2; (3) C₂′ in both the cutoff and the block length; (4) the frozen-body radius with W′; (7) the denominator bound "for all ω ∈ I"; (8)–(9) the learned-scale part, which uses f only as f_min in the cones. I checked these by reading, not by re-deriving the audit.
- (REG) is a new hypothesis of both theorems.
- The lower end of the band (n^{99/43}) and everything below it are unchanged: weights do not help there.

## Theory response to §7–§8 (2026-11-23)

**Status: Theorem LO and Theorem U with β̄ are PROVED by substitution (one pass), UNAUDITED.** A cross-family audit by Astra has been requested.

**Checked by Theory: the scale margins.** β̄ ∝ 1/σ, so β̄(σ) < 6 ⇔ σ > σ₀·β̄(σ₀)/6.
- Gaussian τ = 0.05/0.95: 4.43/6 = 0.738.
- Beta τ = 0.95: 5.12/6 = 0.853.

These match §8. Lemma S's learned σ concentrates at σ₀ (σ/σ₀ → 1), so U-σ's near-scale interval |s/σ₀ − 1| < ϵ fits inside the margin for ϵ < 0.14.

**New hypothesis:** fᵢ = f(i/n), with f of bounded variation and bounded away from 0 and ∞. It holds for the paper's three designs.

## Cross-family audit response (Astra, `reviews/AUDIT_astra_avgbeta.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES.** The fixed-pair LO and the U / U-σ band conclusions hold with the averaged condition β̄ < 6. Nine findings are CONFIRMED and one is PLAUSIBLE. Theory rules that all **HOLD**.

Theory's checks:
- Astra's independent quadrature reproduces the design values: Gaussian 4.43021, Beta 5.12268, Mixed 4.46339.
- These agree with Theory's own Gaussian factor of 0.99208.

| # | Fix (applied by reference; written in full in Tuesday's clean rewrite) |
|---|---|
| 1 | Fix the upper envelope before expanding; lower envelope only for the determinant. The resolvent trace drops a term ≤ 3/w_min. |
| 2 | Correct the first Remark in §4: the retained block cost *underestimates* the full cost. Use integer gain-tail cutoffs J_b = ⌊ηn_b⌋. |
| 3 | The BV error is h/n with h = ⌈n/B⌉ (not 1/B), using balanced blocks. Order of choices: slack → B → η, γ → K₀. |
| 4 | **Delete the false Loewner bound M(X+E) ≤ M(X)+E in §5.2 item 5.** Use BEB and the inverse-tangent inequality (§7's version is correct). |
| 5 | m_i ≥ f_iδ_i²/2 throughout the body; keep full (A2) for the inherited cones; rank-three flat event counted once. |
| 6 | Explicit C₂ = β′_max(π²/6 + 4 + K/2 + 1/(2t)); η ≤ ½; finite cone inequality at the endpoint. |
| 7 | **(REG) must be stated as a deterministic secant profile valid on all frozen panel bodies**, with **a class-uniform margin inf(6 − β̄(ω₂)) > 0**; one common F gives one flat-score event. For the paper designs a valid profile is (1 − o(1)) × the point-density profile. |
| 8 | Restore the missing π in §8's κ_min. U-σ inherits U's audit fixes 8–9; the reciprocal near-scale interval must lie strictly inside the margin. |
| 9 | Update the status lines in §§0, 5, 6. **The crossing at τ ≈ 0.96–0.97 concerns the sufficient comparison, not evidence behaviour beyond 6.** |
| 10 | (PLAUSIBLE) The matching converse stays CONJECTURE; LO and U do not need it. |

**Status: LO and U / U-σ with the averaged β̄ < 6 are PROVED and cross-family audited**, under the uniform-profile hypothesis (REG). On the paper's designs β̄ ≤ 5.12 at every τ ∈ [0.05, 0.95]. **So the middle-band exclusion covers the whole paper grid τ ∈ [0.05, 0.95].**
