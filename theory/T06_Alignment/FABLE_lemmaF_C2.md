# Lemma F (fine-scale columns), the improved width bound W′, and a step check of Lemma C2

*Fable, research sub-agent for Theory, 2026-11-23. Pure mathematics; no compute was run, so nothing here is numerically verified. Notation as in `C1_any_sigma.md`, `W_width_lemma.md` and `../T05_Proofs/THEOREM_B_COMPLETE.md`. Not yet audited by a second reader.*

## 0. Verdicts

| Item | Status |
|---|---|
| Lemma F, column bound with explicit constants, all columns including the ends | **PROVED** (§1) |
| Lemma W′, width √n·ρ + √n·ρ^{5/6}T₀^{1/6}√(log n) | **PROVED** (§2) |
| C1 with W′: rate n^{−5/7}(log n)^{6/7}, window λ ≫ n^{21/11}(log n)^{12/11} | **PROVED by substitution into audited C1**; the substituted proof has not been re-audited (§2.3) |
| C2 item 1, Knight identity and its sign at atoms | **PROVED** |
| C2 item 2, E e^{−2ωRᵢ} ≤ e^{−ωmᵢ} for \|δᵢ\| ≤ 3f/(4ωf̄) | **PROVED** |
| C2 item 3, coarse score | **PROVED after one small repair** (the event and the "+3"; §3.3) |
| C2 item 4, Laplace MGF, condition 2ω‖t‖∞ < λ, truth shift | **PROVED**, with log-MGF ≤ C·ω²nε²/M⁵. The extra factor 1/log n claimed in the planning note is **SKETCH**; it is not needed (§3.4) |
| C2 item 5, dyadic-shell assembly, uniform in ω ∈ [ω₁, ω₂] | **PROVED** given C1 and L6 as audited (§3.5) |
| Resulting rate | ‖θ − θ\*‖²ₙ ≤ M·εₙ² with εₙ² = C(log n)^{1/6}V^{1/3}n^{−5/6}, fixed or compact-uniform ω, deterministic oracle λ. No step failed. |
| Learned σ on top of this (Lemma S, uniform integrability) | **Not checked here**; still CONJECTURE as in the planning note |

Two places where this note differs from `FABLE_rate_gap.md`:
1. The coarse event is {‖P_Jψ‖₂² ≤ J}, obtained from a variance bound on the quadratic form. Markov alone on ‖P_Jψ‖₂² ≤ J + 3 gives probability 3/4, not → 1, and J + 3 overshoots the budget by 3.
2. Σtⱼ² is bounded by m‖t‖²∞, which costs a factor 2 log(2m). The log-MGF is then C·ω²nε²/M⁵ instead of C·ω²nε²/(M⁵ log n). This is absorbed by M and changes no exponent.

---

## 1. Lemma F

### 1.1 Definitions

- m = n − 3. For 1 ≤ k ≤ m, s_k := S e_k, with s_k(i) = C(i − k − 1, 2)·1{i ≥ k + 3}, where C(t, 2) = t(t − 1)/2. Since C(t, 2) = 0 at t = 1, 2, also s_k(i) = p_i(k) for **every** i ≥ k + 1, where

  p_i(k) := (i − k − 1)(i − k − 2)/2.

  For fixed i, p_i is a polynomial of degree 2 in k. For fixed k, it is a quadratic in i.
- For a knot set 𝒦 ⊂ {1, …, m}: V_𝒦 := {θ ∈ ℝⁿ : (Dθ)_k = 0 for k ∉ 𝒦} = range N ⊕ span{s_k : k ∈ 𝒦}. This holds because θ = Nc + S·Dθ (L5) and DS = I. Its dimension is |𝒦| + 3, and it contains range N. It is the discrete analogue of C¹ quadratic splines: the second difference is piecewise linear and changes slope only at knots.
- **The space of the lemma.** Fix an integer 1 ≤ J ≤ m. Put

  h := ⌈m/J⌉,  J′ := ⌊m/h⌋,  𝒦₀ := {h, 2h, …, J′h}.

  Then 1 ≤ J′ ≤ J and m − J′h ≤ h − 1. Let 𝒦_J be **any** set with 𝒦₀ ⊂ 𝒦_J ⊂ {1, …, m} and |𝒦_J| = J. Put V_J := V_{𝒦_J} (dimension exactly J + 3) and let P_J be the orthogonal projector onto V_J. Extra knots only enlarge the space, so every bound below proved for V_{𝒦₀} holds for V_J.

### 1.2 Statement

**Lemma F.** For every n ≥ 4, every 1 ≤ J ≤ m and every 1 ≤ j ≤ m,

  ‖(I − P_J)Se_j‖₂ ≤ c_F·h^{5/2},  h = ⌈m/J⌉,

with c_F = 2.85 if J′ ≥ 3 (in particular whenever J ≥ 4 and m ≥ 9), and c_F = 5.13 in every case. Since h ≤ m/J + 1 ≤ 2m/J < 2n/J,

  **max_j ‖(I − P_J)Se_j‖₂ ≤ C_F·(n/J)^{5/2},  C_F = 16.2 (J′ ≥ 3),  C_F = 29.1 (always).**

Consequently ‖(I − P_J)S‖²_F ≤ m·C_F²·(n/J)⁵. If J divides m the constant is 2.85 in (m/J)^{5/2}; if J = o(m) it is 2.85(1 + J/m)^{5/2} → 2.85.

### 1.3 Proof

Throughout, ‖(I − P_J)s_j‖₂ = dist(s_j, V_J) ≤ ‖s_j − v‖₂ for any v ∈ V_{𝒦₀}.

**Sum bound (used four times).** For an integer T ≥ 2,

  Σ_{t=2}^{T} C(t, 2)² ≤ ¼Σ_{t=2}^{T} t⁴ ≤ ¼∫₂^{T+1} x⁴dx ≤ (T + 1)⁵/20.  (★)

**Two elementary distances to range N.** Let q_j(i) := p_i(j) for all 1 ≤ i ≤ n. It is a quadratic in i, so q_j ∈ range N ⊂ V_J.
- (a) s_j is supported on i = j + 3, …, n, where s_j(i) = C(t, 2) with t = i − j − 1 ∈ [2, n − j − 1]. By (★), ‖s_j‖₂² ≤ (n − j)⁵/20.
- (b) s_j − q_j = −q_j·1{i ≤ j}, because s_j = q_j for i ≥ j + 1. For i ≤ j, with t := j + 2 − i ∈ [2, j + 1], q_j(i) = (t − 1)t/2 = C(t, 2). By (★), ‖s_j − q_j‖₂² ≤ (j + 2)⁵/20.

**Case 1: J′ ≥ 3 and h ≤ j ≤ J′h (interior).** If j ∈ 𝒦₀ the distance is 0. Otherwise choose a ∈ {1, …, J′ − 2} with κ := ah ≤ j ≤ κ + 2h, and use the three knots κ_l := κ + lh, l = 0, 1, 2 (all ≤ J′h ≤ m).
- *Weights.* Let x := (j − κ)/h ∈ [0, 2] and take the Lagrange weights a₀ = (x − 1)(x − 2)/2, a₁ = x(2 − x), a₂ = x(x − 1)/2. Then Σ_l a_l g(κ_l) = g(j) for every polynomial g of degree ≤ 2. Also Σ_l|a_l| ≤ 5/4: for x ∈ [0, 1], a₀, a₁ ≥ 0 ≥ a₂, so Σ|a_l| = 1 − 2a₂ = 1 + x(1 − x) ≤ 5/4; the range x ∈ [1, 2] is symmetric.
- *Error vector.* e := s_j − Σ_l a_l s_{κ_l}, so s_j − e ∈ V_{𝒦₀}.
- *Support.* For i ≤ κ + 2, every term vanishes, because the four indices k ∈ {j, κ₀, κ₁, κ₂} are ≥ κ and s_k(i) = 0 for i ≤ k + 2. For i ≥ κ + 2h + 1, every such k satisfies i ≥ k + 1, so s_k(i) = p_i(k) and e(i) = p_i(j) − Σ_l a_l p_i(κ_l) = 0, by exactness of the weights on the quadratic k ↦ p_i(k). Hence supp e ⊂ {κ + 3, …, κ + 2h}.
- *Size.* On the support, 0 ≤ s_k(i) ≤ C(i − κ − 1, 2) for each of the four k (the map k ↦ s_k(i) is nonincreasing). Hence |e(i)| ≤ (1 + 5/4)·C(t, 2), with t = i − κ − 1 ∈ [2, 2h − 1].
- *Norm.* By (★) with T = 2h − 1: ‖e‖₂² ≤ (9/4)²·(2h)⁵/20 = 8.1·h⁵, so ‖e‖₂ ≤ 2.85·h^{5/2}.

**Case 2: j ≤ h − 1 (left end).** By (b), dist² ≤ (j + 2)⁵/20 ≤ (h + 1)⁵/20 ≤ (2h)⁵/20 = 1.6·h⁵. So dist ≤ 1.27·h^{5/2}.

**Case 3: j ≥ J′h + 1 (right end).** Then n − j ≤ m + 2 − J′h ≤ h + 1. By (a), dist² ≤ (h + 1)⁵/20 ≤ 1.6·h⁵. So dist ≤ 1.27·h^{5/2}.

Cases 1–3 cover every j when J′ ≥ 3, with constant 2.85.

**Case 4: J′ ≤ 2 (fewer than three knots fit).** Then m ≤ 3h − 1. By (a) and (b), dist² ≤ min(j + 2, n − j)⁵/20, and min(j + 2, n − j) ≤ (n + 2)/2 = (m + 5)/2 ≤ (3h + 4)/2 ≤ 3.5h. So dist² ≤ 3.5⁵h⁵/20 ≤ 26.3·h⁵ and dist ≤ 5.13·h^{5/2}.

**When J′ ≥ 3.** J′ ≥ 3 ⇔ 3⌈m/J⌉ ≤ m. For J ≥ 4, ⌈m/J⌉ ≤ ⌈m/4⌉ ≤ (m + 3)/4, and 3(m + 3)/4 ≤ m for m ≥ 9.

**Conversion.** J ≤ m gives h ≤ m/J + 1 ≤ 2m/J, so h^{5/2} ≤ 2^{5/2}(m/J)^{5/2} ≤ 5.66·(n/J)^{5/2}; 2.85 × 5.66 ≤ 16.2 and 5.13 × 5.66 ≤ 29.1. ∎

**Remarks.**
- Three knots are necessary in the interior. To the right of the window the error is a quadratic in i that must vanish, which is exactly the three moment conditions Σa_l = 1, Σa_lκ_l = j, Σa_lκ_l² = j². At the two ends the quadratics in range N do this job, so no extrapolation is used.
- The bound is uniform in j, which is what C2 needs. In W's normalization A = n^{−1/2}P⊥S it reads: each column of n^{−1/2}(I − P_J)S has squared norm ≤ C_F²n⁴J^{−5}, against the Frobenius bound n⁵k^{−5} used in W step 5.
- Equal spacing is used only for Σ|a_l| ≤ 5/4. For gaps g₁, g₂ the same proof gives Σ|a_l| ≤ 2·max(g₁, g₂)/min(g₁, g₂) + (g₁ + g₂)²/(4g₁g₂).

---

## 2. Lemma W′: the improved width bound

### 2.1 Statement

Let ε₁, …, εₙ be independent, mean zero, |εᵢ| ≤ 1, and K(ρ, T₀) = {‖δ‖ₙ ≤ ρ, n²‖Dδ‖₁ ≤ T₀}. For every integer 1 ≤ J ≤ m, with h = ⌈m/J⌉,

  E sup_{δ∈K(ρ,T₀)} ⟨ε, δ⟩ ≤ √n·ρ·√(J + 3) + c_F·√(2 log(2m))·T₀·n^{−2}·h^{5/2}
              ≤ √n·ρ·√(J + 3) + C_F·√(2 log(2m))·T₀·√n·J^{−5/2}.

Choosing J as in §2.2,

  **E sup_K ⟨ε, δ⟩ ≲ √n·ρ + √n·ρ^{5/6}·T₀^{1/6}·√(log n).**

### 2.2 Proof (what replaces W's steps 1–5)

**The projector.** P_J of §1.1 replaces **both** W's null-space projector P_N (step 2) and its SVD truncation P_k onto the top k left singular vectors of A = n^{−1/2}P⊥S (steps 3–4). No singular values are used, and L3 Step 4 is no longer an input.

1. **Decomposition.** δ = Nc + Su with u = Dδ. Since range N ⊂ V_J, (I − P_J)N = 0, so (I − P_J)δ = (I − P_J)Su and

   ⟨ε, δ⟩ = ⟨P_Jε, δ⟩ + ⟨Sᵀ(I − P_J)ε, u⟩.

2. **Head (dimension J + 3).** |⟨P_Jε, δ⟩| ≤ ‖P_Jε‖₂·√n ρ, and E‖P_Jε‖₂ ≤ (Σᵢ(P_J)ᵢᵢ·Eεᵢ²)^{1/2} ≤ √(tr P_J) = √(J + 3). The head is √n ρ·√(J + 3), in place of W's √n ρ·(√3 + √k).

3. **Tail (column bound instead of Frobenius).** Let w_j := (I − P_J)s_j. Then

   |⟨Sᵀ(I − P_J)ε, u⟩| ≤ ‖u‖₁·max_j|⟨w_j, ε⟩| ≤ (T₀/n²)·max_j|⟨w_j, ε⟩|.

   By Hoeffding's lemma, ⟨w_j, ε⟩ is sub-Gaussian with variance proxy ‖w_j‖₂² ≤ c_F²h⁵ (Lemma F). The maximal inequality over the 2m variables ±⟨w_j, ε⟩ gives E max_j|⟨w_j, ε⟩| ≤ √(2 log(2m))·c_F·h^{5/2}. The second form uses h^{5/2}c_F ≤ C_F(n/J)^{5/2} and n^{−2}(n/J)^{5/2} = √n·J^{−5/2}.

4. **Choice of J.** Put q := (T₀/ρ)^{1/3}.
   - If 1 ≤ q ≤ m: take J = ⌈q⌉ ∈ [q, 2q]. The head is ≤ √n ρ(√3 + √(2q)) and the tail is ≤ C_F√(2 log 2m)·T₀√n·q^{−5/2}. Both √n ρ·q^{1/2} and T₀√n·q^{−5/2} equal √n·ρ^{5/6}T₀^{1/6}.
   - If q < 1: take J = 1. The head is 2√n ρ. The tail is ≤ C_F√(2 log 2m)·√n·ρq³ ≤ C_F√(2 log 2m)·√n·ρq^{1/2}.
   - If q > m: take J = m. Then h = 1, 𝒦_J = {1, …, m}, V_J = ℝⁿ and the tail is 0. The head is √n ρ·√n ≤ √n ρ(√3 + √q).

   The displayed order bound holds in all three cases. ∎

**Remark (log power).** Balancing with the log, J ≍ (T₀√(log n)/ρ)^{1/3}, gives √n·ρ^{5/6}T₀^{1/6}(log n)^{1/12}. This is not used below.

### 2.3 Consequence for C1 (substitution only)

In C1 Step 3 replace the expectation bound by E G ≤ 4·E sup_{K′}⟨ε, δ⟩ ≤ C√n·r + C√n·r^{5/6}T₀^{1/6}√(log n).
- This is ≤ (f/8)n r² once r² ≥ C_r·n^{−6/7}T₀^{2/7}(log n)^{6/7} = **C_r·T^{2/7}·λ^{−2/7}·(log n)^{6/7}** (using T₀ = Tn³/λ) and r ≥ C/√n. The second condition is implied by the first for λ ≤ n³.
- Condition (i), r⁴T₀ → 0, becomes n³λ^{−11/7}(log n)^{12/7} → 0, i.e. **λ ≫ n^{21/11}(log n)^{12/11}**.
- The other uses of r in C1 are unaffected: Bousquet needs n r² ≫ log n (true for λ ≤ n³, since n r² ≥ n^{1/7}); Step 6 needs n r² = o(n); Step 8 needs nε² = o(n r²) and εnr → ∞.
- At λ ≍ n^{5/2}/V: r² ≍ V^{2/7}n^{−5/7}(log n)^{6/7}.

Status: each line above is a direct substitution into the audited proof; the resulting C1′ has not been audited as a whole.

---

## 3. Lemma C2, step by step

Setting: (A1); full (A2) in secant form, f|δ| ≤ |Fᵢ(δ) − Fᵢ(0)| ≤ f̄|δ| for |δ| ≤ L (Fᵢ the cdf of Zᵢ); (A3); a₁n^{5/2}/V ≤ λ ≤ a₂n^{5/2}/V; nε² = C(log n)^{1/6}V^{1/3}n^{1/6}, so that V²n = (nε²)⁶/(C⁶ log n).

### 3.1 Knight identity and the sign at atoms — PROVED

With ψᵢ := τ − 1{Zᵢ < 0} and Rᵢ(δ) := Xᵢ(δ) + δψᵢ, comparison with L2's closed form (Xᵢ(δ) = (1 − τ)δ − clip(Zᵢ, 0, δ) for δ > 0; Xᵢ(−a) = τa − clip(−Zᵢ, 0, a) for a > 0) gives, case by case:

  Rᵢ(δ) = (δ − Zᵢ)·1{0 ≤ Zᵢ ≤ δ} for δ > 0;  Rᵢ(δ) = (Zᵢ − δ)·1{δ ≤ Zᵢ < 0} for δ < 0.

- **Rᵢ ≥ 0 pointwise, for every data value, atoms included.** Equivalently, −ψᵢ is a subgradient of δ ↦ ρ_τ(Zᵢ − δ) at 0: the subdifferential is {−τ} for Zᵢ > 0, {1 − τ} for Zᵢ < 0 and [−τ, 1 − τ] for Zᵢ = 0.
- **The convention matters only at Zᵢ = 0.** With ψᵢ = τ − 1{Zᵢ < 0}, the remainder at Zᵢ = 0 is δ for δ > 0 and 0 for δ < 0. With ψᵢ = τ − 1{Zᵢ ≤ 0} it is the reverse. Either pair (ψ, R) is a valid identity with R ≥ 0. Mixing the ψ of one with the R of the other is wrong by |δ|·1{Zᵢ = 0}.
- **Mean zero.** E ψᵢ = τ − Fᵢ(0−) = 0, because upper (A2) forces Fᵢ(0−) = Fᵢ(0) = τ (L2 (iii)). So P(Zᵢ = 0) = 0 and the convention is immaterial almost surely. Atoms outside [−L, L] are allowed and cause no change. Hence E Rᵢ(δ) = mᵢ(δ).
- **Cauchy–Schwarz.** N(E_a) = ∫_{E_a}e^{ω⟨ψ,δ⟩}e^{−ωR}dν ≤ (∫_{E_a}e^{2ω⟨ψ,δ⟩}dν)^{1/2}(∫_{E_a}e^{−2ωR}dν)^{1/2}. Both factors are finite: ν(E_a) ≤ V₃(2a·nε²)^{3/2}, and the first is bounded in §3.3–3.4.

### 3.2 Remainder: E e^{−2ωRᵢ} ≤ e^{−ωmᵢ} for |δᵢ| ≤ min(L, 3f/(4ωf̄)) — PROVED

- *Second moment.* For 0 < δ ≤ L: E Rᵢ² = ∫_{[0,δ]}(δ − z)²dFᵢ(z) = ∫₀^δ 2(δ − z)(Fᵢ(z) − Fᵢ(0))dz ≤ 2f̄∫₀^δ(δ − z)z dz = f̄δ³/3. The integration by parts uses Fᵢ(0−) = Fᵢ(0). The case δ < 0 is symmetric. Only the upper secant bound is used.
- *Mean.* mᵢ(δ) = ∫₀^δ(Fᵢ(s) − τ)ds ≥ fδ²/2 for |δ| ≤ L (lower secant bound).
- *Exponential.* For x ≥ 0, e^{−x} ≤ 1 − x + x²/2. So E e^{−2ωRᵢ} ≤ 1 − 2ωmᵢ + 2ω²E Rᵢ². If 2ω²·f̄|δ|³/3 ≤ ω·fδ²/2, i.e. **|δ| ≤ 3f/(4ωf̄)**, then 2ω²E Rᵢ² ≤ ωmᵢ and E e^{−2ωRᵢ} ≤ 1 − ωmᵢ ≤ e^{−ωmᵢ}. The threshold in the planning note is exactly right. s₀ = min(L, 3f/(4ω₂f̄)) serves every ω ≤ ω₂.
- *Integration.* E_a is deterministic. By Tonelli and (A1), E₀∫_{E_a}e^{−2ωR}dν ≤ ∫_{E_a}e^{−ωM(δ)}dν ≤ ν(E_a)·e^{−ω(f/2)a·nε²}, since M(δ) ≥ (f/2)n‖δ‖²ₙ > (f/2)a·nε² on E_a. The c-section of E_a lies in the ball ‖c − c̄(u)‖₂ ≤ (2a·nε²)^{1/2} (L5), so ν(E_a) ≤ V₃(2a·nε²)^{3/2}.
- *Markov.* With probability ≥ 1 − e^{−2ηω·a·nε²}: (∫_{E_a}e^{−2ωR}dν)^{1/2} ≤ V₃^{1/2}(2a·nε²)^{3/4}·e^{−ω(f/4 − η)a·nε²}. Note that the square root halves f/2 to f/4.

### 3.3 Coarse score — PROVED after repair

P_J is the projector of §1.1, with J := ⌊(f²/128)·M·nε²⌋ (so 3 ≤ J ≤ m for n ≥ n₀).

- **Event.** Ω_ψ¹ := {‖P_Jψ‖₂² ≤ J}. Let Q := ψᵀP_Jψ and d := J + 3. Since the ψᵢ are independent, mean zero, with values in [τ − 1, τ]: Var ψᵢ ≤ ¼, Var(ψᵢ²) ≤ ¼, and the diagonal and off-diagonal parts of Q are uncorrelated. Hence E Q ≤ d/4 and Var Q = Σᵢ Pᵢᵢ²Var(ψᵢ²) + 2Σ_{i≠k}Pᵢₖ²Var ψᵢ·Var ψₖ ≤ ¼‖P_J‖²_F = d/4. Chebyshev gives

  P₀(Q > J) ≤ (d/4)/(J − d/4)² = 4(J + 3)/(9(J − 1)²) → 0.

  *Repair.* The planning note uses ‖P_Jψ‖₂² ≤ J + 3. Markov alone gives that event only probability ≥ 3/4, and J + 3 exceeds the budget (f²/128)M·nε² by up to 3. The event above fixes both.
- **Bound.** On Ω_ψ¹, for every a ≥ M and every δ ∈ E_a: |⟨P_Jψ, δ⟩| ≤ ‖P_Jψ‖₂‖δ‖₂ ≤ (J·2a·nε²)^{1/2} ≤ (f/8)·a·nε², because J ≤ (f²/128)·a·nε². No net and no chaining, as claimed. The event is free of ω and of a.

### 3.4 Fine score: exact Laplace MGF, truth shift — PROVED (without the 1/log n)

- **Identity.** δ = N(c − c\*) + S(u − u\*) and (I − P_J)N = 0, so ⟨(I − P_J)ψ, δ⟩ = ⟨t, u − u\*⟩ with t := Sᵀ(I − P_J)ψ, tⱼ = ⟨w_j, ψ⟩.
- **Event.** Ω_ψ² := {‖t‖∞ ≤ t_∞}, t_∞ := C_F(n/J)^{5/2}·√(2 log(2m)). Hoeffding (range of ψᵢ is 1) and Lemma F give P₀(|tⱼ| > x) ≤ 2exp(−2x²/‖w_j‖₂²), so P₀((Ω_ψ²)ᶜ) ≤ 2m·(2m)^{−4} = (2m)^{−3}. Uniform column control is essential here. Put Ω_ψ := Ω_ψ¹ ∩ Ω_ψ².
- **Order of operations.** On E_a the coarse factor is bounded by the constant e^{2ω(f/8)a·nε²}. The remaining integrand e^{2ω⟨t,u−u\*⟩} depends on u only. Integrate c over the section (volume ≤ V₃(2a·nε²)^{3/2}), then drop the indicator in u. This is a deterministic computation for each data vector; no Fubini over the data is involved.
- **Exact MGF.** For the Laplace(λ) density (λ/2)e^{−λ|x|}, E e^{sx} = (1 − s²/λ²)^{−1} for |s| < λ. So ∫e^{2ω⟨t,u⟩}dΠ_λ = ∏ⱼ(1 − 4ω²tⱼ²/λ²)^{−1}, **provided 2ω‖t‖∞ < λ**. On Ω_ψ², 2ωt_∞/λ ≤ 2ωC_F·V·√(2 log 2m)·J^{−5/2}/a₁ ≍ n^{−5/12}(log n)^{1/12} → 0. So 4ω²tⱼ²/λ² ≤ ½ for n ≥ n₀, and −log(1 − x) ≤ 2x on [0, ½] gives log-MGF ≤ 8ω²Σtⱼ²/λ².
- **Σtⱼ².** On Ω_ψ², Σtⱼ² ≤ m·t_∞² = 2 log(2m)·C_F²·m(n/J)⁵. Using λ ≥ a₁n^{5/2}/V, V²n = (nε²)⁶/(C⁶ log n) and J ≥ (f²/256)M·nε²:

  ½·log-MGF ≤ 8ω²C_F²·a₁^{−2}·V²n·J^{−5}·log(2m) ≤ C_fine·ω²·nε²/M⁵,  C_fine := 16·C_F²·(256/f²)⁵/(a₁²C⁶).

  V cancels, as claimed. The planning note's sharper Cω²nε²/(M⁵ log n) needs Σtⱼ² ≲ n(n/J)⁵ with probability → 1. In expectation this is true (E Σtⱼ² ≤ ¼Σ‖w_j‖₂²), and Markov gives the factor K_n/log n with probability ≥ 1 − 1/K_n for any K_n → ∞; with a fixed constant it needs Hanson–Wright plus an operator-norm bound on (I − P_J)S, which is **not proved**. It is not needed.
- **Truth shift.** |2ω⟨t, u\*⟩| ≤ 2ω·t_∞·‖u\*‖₁ ≤ 2ω·t_∞·V/n² = 2ωC_F√(2 log 2m)·V·√n·J^{−5/2} ≍ n^{1/12}(log n)^{1/12}V^{1/6} = o(nε²).

**Lemma C2 as proved.** For fixed ω ∈ (0, ω₂], M > 0, η > 0 and n ≥ n₀, on Ω_ψ (P₀(Ω_ψᶜ) → 0; Ω_ψ free of ω and a), for each a ≥ M, with probability ≥ 1 − e^{−2ηω·a·nε²}:

  N_ω(E_a) ≤ V₃(2a·nε²)^{3/2}·exp{ −ω(f/8 − η)·a·nε² + C_fine·ω²·nε²/M⁵ + ω·t_∞V/n² },

and the last term is o(nε²). The exponent f/8 = f/4 (remainder, after the square root) − f/8 (coarse score). This is the planning note's display with 1/(M⁵ log n) replaced by 1/M⁵.

### 3.5 Dyadic-shell assembly and uniformity in ω — PROVED given C1 and L6

- **Shells.** a_k := 2^kM, k = 0, …, k_max, with k_max ≤ log₂(r²/(Mε²)) = O(log n). On K′, ‖δ‖∞ ≤ s_K → 0 (C1 Step 1), so s_K ≤ s₀ for n ≥ n₀ and K′ ∩ {a_kε² < ‖δ‖²ₙ ≤ 2a_kε²} ⊂ E_{a_k}. Hence

  Πₙ,ω(‖δ‖²ₙ > Mε² | y) ≤ Πₙ,ω(K′ᶜ | y) + Σ_k N_ω(E_{a_k})/N_ω(ℝⁿ).

  The first term is C1 (uniform in ω ∈ [ω₁, ω₂]). C1 as audited suffices; W′ is not required for this step.
- **Uniformity in ω.** For every real x, ω ↦ e^{−ωx} is convex, so e^{−ωℛ(δ)} ≤ e^{−ω₁ℛ(δ)} + e^{−ω₂ℛ(δ)} pointwise, and N_ω(E_a) ≤ N_{ω₁}(E_a) + N_{ω₂}(E_a). Apply §3.4 at the two endpoints only (J, E_a and Ω_ψ are ω-free, and s₀ is defined with ω₂). Both endpoint bounds are ≤ V₃(2a·nε²)^{3/2}exp{−ω₁(f/8 − η)a·nε² + C_fine·ω₂²·nε²/M⁵ + o(nε²)}. The trick is valid as stated in the planning note.
- **Failure probability.** Σ_k 2e^{−2ηω₁·2^kM·nε²} → 0, since nε² → ∞.
- **Denominator.** On the ω-free event Ω₆ (L6): N_ω(ℝⁿ) ≥ V₃(ε√n/2)³·e^{−(ω₂(1.44C₁+1) + C_pr)nε²}.
- **Ratio.** (2a·nε²)^{3/2}/(nε²/4)^{3/2} = (8a)^{3/2}. So on the intersection of the events, uniformly in ω ∈ [ω₁, ω₂]:

  Σ_k N_ω(E_{a_k})/N_ω(ℝⁿ) ≤ 2Σ_k(8·2^kM)^{3/2}·exp{ −[ω₁(f/8 − η)·2^kM − ω₂(1.44C₁ + 1) − C_pr − C_fine·ω₂²/M⁵ − o(1)]·nε² } → 0

  as soon as **ω₁(f/8 − η)·M > ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂²/M⁵**. This is the planning note's condition plus the harmless last term.

**Resulting statement.** Under (A1), full (A2), (A3), deterministic λ ≍ n^{5/2}/V and C1's hypotheses at the oracle, for M above the threshold:

  sup_P E_P sup_{ω∈[ω₁,ω₂]} Πₙ,ω( ‖θ − θ\*‖²ₙ > M·εₙ² | y ) → 0,  εₙ² = C(log n)^{1/6}V^{1/3}n^{−5/6}.

No step of C2 fails. The rate n^{−5/6}(log n)^{1/6} holds for every fixed σ and uniformly on compact σ-intervals, moment-free, with no condition σ ≥ σ̄.

---

## 4. What remains open

1. **Audit.** Everything above was derived by hand in one sitting. The points most worth a second reader are: the support claim in Case 1 of Lemma F (i ≥ κ + 2h + 1 ⇒ all four truncations inactive); the variance formula for ψᵀP_Jψ; the constant bookkeeping in C_fine.
2. **Numerical check (not run; compute was out of scope).** max_j‖(I − P_J)s_j‖₂/h^{5/2} for a few (n, J), expected ≤ 2.85; and W′ against W.
3. **Learned σ.** The compact-uniform statement of §3.5 is the input the two-endpoint argument needs, but the combination with Lemma S (σ-concentration, uniform integrability) was not checked here. Target statement of the planning note stays CONJECTURE.
4. **Learned λ.** Out of scope: the exact Laplace MGF needs 2ω‖t‖∞ < λ for the realized λ, and the product form is lost under λ-mixing.
5. **The 1/log n in the fine log-MGF.** SKETCH; needs ‖(I − P_J)S‖_op. Not needed for the rate.
