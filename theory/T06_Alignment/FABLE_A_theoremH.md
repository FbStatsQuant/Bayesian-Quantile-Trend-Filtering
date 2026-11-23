# Theorem H: Huber-body localization for the λ-mixed posterior conditioned on λ ≥ Λ₋

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute; nothing is numerically verified. Reuses: Lemma F (`FABLE_lemmaF_C2.md` §1, audited), C1's structure (`C1_any_sigma.md`, audited), V2T Steps 1–4 (`FABLE_V2T_proof.md`, audited), L2–L6, L10-I's Christoffel constant, Lemma S. Written in one pass; **not audited**.*

**Labels.** PROVED = every line is written here and rests only on audited statements or elementary facts. SKETCH = argument given, a detail open.

## 0. Verdict

| Piece | Status |
|---|---|
| Lemma H1 (Huber margin, every x, moment-free) | **PROVED** (§2) |
| Lemma H2 (the Huber gauge: boundary, ℓ₁ control, cones) | **PROVED** (§3) |
| Lemma F′ (Lemma F for the end-trimmed knot set, constant still 2.85) | **PROVED** (§4.1), by Lemma F's own cases |
| Lemma Lev (leverage of the spline space ≤ 9/h) | **PROVED** (§4.2), from L10-I's Christoffel constant |
| Lemma WH (width of the Huber body) | **PROVED** (§4.3) |
| Event Ω_G by Markov (no envelope needed) | **PROVED** (§5) |
| Cones, denominator, combination: Theorem H at fixed σ, uniform on compacts | **PROVED** (§6) |
| Theorem H-σ (σ learned under IG) | **PROVED given** that V2T Step 2 holds for a general floor; its proof uses only two facts, both checked in §7 |
| Corollary P (plug-in for any lower-tail control of λ, no truncation) | **PROVED** (§8), an identity |
| High-probability version (replace 1/K_n by an exponential bound) | not done; SKETCH of why it is not immediate (§9) |

No step failed. Rate: Huber loss ≤ r², **r² = C_H·K_n^{12/7}·(T/Λ₋)^{2/7}·(log 2n)^{6/7}**, valid for K_n⁶(log n)³ ≪ Λ₋ ≤ n². The only place the result is weaker than C1 in kind: the multiplier must diverge ("for every M_n → ∞"), because the event has probability 1 − 1/K_n (Markov) instead of 1 − 1/n (Bousquet).

---

## 1. Setting and statement

**Model at fixed σ.** ω = 1/σ. Coordinates θ = Nc + Su (L5), δ := θ − θ\*, ℛ(δ) := Σᵢ Xᵢ(δᵢ), M := E₀ℛ, mᵢ := E Xᵢ. Let p be **any** probability law on [Λ₋, ∞) (for instance, any hyperprior conditioned on λ ≥ Λ₋). Π̄ := ∫p(dℓ)Π_ℓ, ν̄ := dc ⊗ Π̄, N̄_ω(B) := ∫_B e^{−ωℛ}dν̄, Π_ω(B | y) := N̄_ω(B)/N̄_ω(ℝⁿ). Window J₀ := [Λ₋, 2Λ₋], p₀ := p(J₀) > 0.

**Assumptions.** (A1); full (A2) in secant form, f|x| ≤ |Fᵢ(x) − Fᵢ(0)| ≤ f̄|x| for |x| ≤ L; (A3) with V. No moments, no (EM), no condition on σ.

**Huber function and body.**
- h_L(x) := x²/2 for |x| ≤ L, and L|x| − L²/2 for |x| > L. Convex, even, C¹. 𝐡(δ) := Σᵢh_L(δᵢ).
- TV(δ) := n²‖Dδ‖₁. Fix T ≥ 4 and put T₀ := T·n³/Λ₋.
- K_H := {δ : 𝐡(δ) ≤ n·r², TV(δ) ≤ T₀}, with gauge t(δ) := inf{s > 0 : δ/s ∈ K_H}.

**Constants.** C₁ = max(f̄/2, 1/L) (L2). For K ≥ 1:

  **r² := C_H·K^{12/7}·(T/Λ₋)^{2/7}·(log 2n)^{6/7},  C_H := (605/f)^{12/7}.**

  ε² := 21.5·Λ₋^{−1/3}·(log m)^{1/6},  c_D := 1 + ω₂(1.25C₁ + 1),  R_c := n(r² + L²/2)/L.

**Theorem H.** Let 0 < ω₁ ≤ ω₂ < ∞ and K ≥ 1 be fixed, and let n and Λ₋ satisfy (H1)–(H4) of §10 (in particular r ≤ L and 10⁴√(log m) ≤ Λ₋ ≤ n²). Then there are events Ω_G and Ω_D, free of ω, of ℓ and of p, with P₀(Ω_Gᶜ) ≤ 1/K and P₀(Ω_Dᶜ) ≤ 1.25/(nε²), such that on Ω_G ∩ Ω_D, for all ω ∈ [ω₁, ω₂] simultaneously,

  Π_ω(𝐡(θ − θ\*) > n·r² or TV(θ − θ\*) > T₀ | y) ≤ R_n^H,

  R_n^H := p₀⁻¹·e^{6+2V}·{ (8π/V₃)·(24L/(ω₁f·ε√n·r²))³·exp[−ω₁f·nr²/4 + c_D·nε²] + 6·(3L√n/ε)³·exp[−Tn/4 + c_D·nε²] }.

Consequently, for K = K_n → ∞ with K_n⁶(log n)³ = o(Λ₋), Λ₋ ≤ n² and −log p₀ = o(nr²):

  sup_P E_P sup_{ω∈[ω₁,ω₂]}Π_ω(𝐡(θ − θ\*)/n > r² or TV(θ − θ\*) > T₀ | y) ≤ R_n^H + 1/K_n + 1.25/(nε²) → 0.

**In words.** The Huber loss contracts at Λ₋^{−2/7}·polylog for every σ: n^{−3/14} at Λ₋ ≍ n^{3/4}, n^{−1/7} at n^{1/2}, n^{−4/7} at n². For fixed K the statement holds with limsup ≤ 1/K.

**Standard form.** Writing M_n := C_H·K_n^{12/7}, the conclusion reads: for **every** M_n → ∞ (with M_n^{7/2}(log n)³ = o(Λ₋)),

  sup_P E_P sup_{ω∈[ω₁,ω₂]}Π_ω(𝐡(θ − θ\*)/n > M_n·(T/Λ₋)^{2/7}(log 2n)^{6/7} | y) → 0.

This is the usual "every M_n → ∞" contraction statement. A fixed large M is not obtained, because Markov gives probability 1/K rather than a vanishing one.

**Translations of the loss** (on {𝐡(δ) ≤ nr²}; PROVED, one line each).
- Padilla's loss: n⁻¹Σmin(δᵢ², |δᵢ|) ≤ (2/min(L, 1))·r².
- Average absolute error: n⁻¹‖δ‖₁ ≤ √2·r + 2r²/L. Hence |Q(θ) − Q(θ\*)|/n ≤ √2·r + 2r²/L, which is hypothesis (H) of Lemma S §1.
- No sup-norm statement: L10-I gives nothing at this T₀.

---

## 2. Lemma H1: the Huber margin — PROVED

**Lemma H1.** Under (A1) and full (A2), for every i and **every** x ∈ ℝ: mᵢ(x) ≥ (f/2)·h_L(x). Hence M(δ) ≥ (f/2)·𝐡(δ) for every δ ∈ ℝⁿ.

*Proof.* mᵢ(x) = ∫₀ˣ(Fᵢ(s) − τ)ds and Fᵢ(0) = τ (L2 (iii), from upper (A2)).
- |x| ≤ L: the lower secant bound gives mᵢ(x) ≥ f·x²/2 = f·h_L(x) ≥ (f/2)h_L(x).
- |x| > L: mᵢ is convex (an expectation of convex functions) with mᵢ(0) = 0, so mᵢ(x) ≥ (|x|/L)·mᵢ(±L) ≥ (|x|/L)·fL²/2 = (f/2)·L|x| ≥ (f/2)(L|x| − L²/2) = (f/2)h_L(x). ∎

No moment of Zᵢ is used: |Xᵢ(x)| ≤ |x| makes mᵢ finite.

---

## 3. Lemma H2: the Huber gauge — PROVED

**Lemma H2.**
1. K_H is convex, symmetric, compact, and contains a neighbourhood of 0. For every δ ≠ 0, δ/t(δ) ∈ K_H, and {s > 0 : δ/s ∈ K_H} = [t(δ), ∞).
2. If t(δ) > 1 and δ₁ := δ/t(δ), then 𝐡(δ₁) ≤ nr², TV(δ₁) ≤ T₀, and **at least one is an equality**. Always t(δ) ≥ TV(δ)/T₀.
3. For δ ∈ K_H, with S₁ := {i : |δᵢ| ≤ L} and S₂ := {i : |δᵢ| > L}: Σ_{S₁}δᵢ² ≤ 2nr² and Σ_{S₂}|δᵢ| ≤ 2nr²/L.
4. For every δ: ‖δ‖₁ ≤ max(t(δ), 1)·R_c, with R_c = n(r² + L²/2)/L.
5. ℛ(δ) ≥ t·ℛ(δ/t) for every t ≥ 1 and every data vector.

*Proof.*
1. 𝐡 is convex, even and continuous; TV is a seminorm. 𝐡(δ) ≤ nr² bounds every coordinate, so K_H is compact. s ↦ 𝐡(δ/s) and s ↦ TV(δ/s) are nonincreasing and continuous on (0, ∞), which gives the half-line and its closed left end.
2. If both inequalities were strict at s = t(δ), continuity would keep δ/s ∈ K_H for some s < t(δ). TV(δ)/t(δ) = TV(δ₁) ≤ T₀.
3. h_L(x) = x²/2 on S₁. On S₂, h_L(x) = L|x| − L²/2 ≥ L|x|/2.
4. h_L(x) ≥ L|x| − L²/2 for every x (for |x| ≤ L this is (|x| − L)² ≥ 0). So for δ′ ∈ K_H: L‖δ′‖₁ − nL²/2 ≤ nr², i.e. ‖δ′‖₁ ≤ R_c. Apply to δ′ = δ/max(t, 1).
5. ℛ is convex with ℛ(0) = 0 (C1 Step 2). ∎

**Cones.** A₁ := {t(δ) > 1, 𝐡(δ₁) = nr²} and A₂ := {t(δ) > 1} ∖ A₁. On A₂, TV(δ₁) = T₀, so t(δ) = TV(δ)/T₀ = n²‖u − u\*‖₁/T₀, a function of u only. Both are Borel.

**What differs from C1's ℓ₂ body.** The gauge is not a norm ratio, so C1's "t ≥ ‖c − c̄(u)‖₂/(√n r)" is replaced by item 4, with the larger radius R_c ≍ nL in place of √n·r. This only changes polynomial prefactors.

---

## 4. The width of the Huber body

### 4.1 Lemma F′: end-trimmed knots — PROVED

The knot set 𝒦₀ of Lemma F may contain a knot within three indices of the end; then a coordinate vector lies in the spline space and its leverage is 1 (if J′h = m, then s_m = e_n). So the last knot is dropped.

**Definitions.** m = n − 3. h an integer with **3 ≤ h ≤ m/4**. J″ := ⌊m/h⌋ − 1 ≥ 3. 𝒦_H := {h, 2h, …, J″h}. V_H := V_{𝒦_H} = range N ⊕ span{s_k : k ∈ 𝒦_H}, of dimension J″ + 3 ≤ 2m/h. P_H := the orthogonal projector onto V_H; w_j := (I − P_H)s_j.

**Lemma F′.** max_{1≤j≤m}‖w_j‖₂ ≤ 2.85·h^{5/2}.

*Proof.* The three cases of Lemma F, with its facts (a) ‖s_j‖₂² ≤ (n − j)⁵/20 and (b) dist(s_j, range N)² ≤ (j + 2)⁵/20.
- *Interior, h ≤ j ≤ J″h.* Lemma F's Case 1 uses only three knots κ, κ + h, κ + 2h of the knot set with κ ≤ j ≤ κ + 2h. Take κ = ah, a := min(⌊j/h⌋, J″ − 2) ≥ 1. Bound: 2.85·h^{5/2}.
- *Left end, j ≤ h − 1.* By (b): (h + 1)⁵/20 ≤ (2h)⁵/20, so ≤ 1.27·h^{5/2}.
- *Right end, j ≥ J″h + 1.* n − j ≤ m + 2 − J″h ≤ 2h + 1 ≤ (7/3)h, since m − J″h ≤ 2h − 1 and h ≥ 3. By (a) and 0 ∈ V_H: ≤ ((7/3)⁵/20)^{1/2}h^{5/2} ≤ 1.86·h^{5/2}. ∎

### 4.2 Lemma Lev: leverage of the spline space — PROVED

**Lemma Lev.** max_{1≤i≤n}(P_H)ᵢᵢ ≤ 9/h. Equivalently ‖P_He_i‖₂ ≤ 3/√h for every i.

*Proof.*
1. *Cells.* Put C_l := {(l − 1)h + 1, …, lh} for 1 ≤ l ≤ J″ and C_{J″+1} := {J″h + 1, …, n}. They partition {1, …, n}; the first J″ have h points and the last has n − J″h ≥ h + 3 points.
2. *Every θ ∈ V_H is a quadratic polynomial in i on each cell.* (Dθ)_k = θ_{k+3} − 3θ_{k+2} + 3θ_{k+1} − θ_k vanishes for k ∉ 𝒦_H. If it vanishes for all k in a block {a, …, b}, then θ is a quadratic on {a, …, b + 3}. The blocks are {(l − 1)h + 1, …, lh − 1} for l ≤ J″ (nonempty since h ≥ 2), giving a quadratic on {(l − 1)h + 1, …, lh + 2} ⊃ C_l, and {J″h + 1, …, m}, giving a quadratic on {J″h + 1, …, n} = C_{J″+1}.
3. *Comparison.* Let W be the space of vectors that are quadratic on each cell. Then V_H ⊂ W. For any subspace U, (P_U)ᵢᵢ = ‖P_Ue_i‖₂² = sup{vᵢ² : v ∈ U, ‖v‖₂ = 1}. So (P_H)ᵢᵢ ≤ (P_W)ᵢᵢ.
4. *Christoffel constant.* W is an orthogonal direct sum over cells. For i in a cell of w ≥ 3 consecutive points, (P_W)ᵢᵢ = sup_q q(i)²/Σ_{k∈cell}q(k)² over quadratics q, which is ≤ C_eq(w)/w ≤ 9/w (L10-I: the discrete Christoffel constant for quadratics is exactly 9). Every cell has w ≥ h ≥ 3. ∎

### 4.3 Lemma WH: the width — PROVED

**Lemma WH.** Let ε₁, …, εₙ be independent, mean zero, |εᵢ| ≤ 1. For 3 ≤ h ≤ m/4:

  E sup_{δ∈K_H}⟨ε, δ⟩ ≤ (i) + (ii) + (iii),

  (i) := √(2n)·r·√(J″ + 3) ≤ 2n·r·h^{−1/2};  (ii) := (2nr²/L)·3·√(2 log(2n)/h);  (iii) := 2.85·√(2 log 2m)·T₀·n^{−2}·h^{5/2}.

If moreover r ≤ L and x := (rΛ₋/T)^{1/3} satisfies 3 ≤ x ≤ m/4, then with h := ⌊x⌋:

  **E sup_{δ∈K_H}⟨ε, δ⟩ ≤ 18.9·√(log 2n)·n·r^{5/6}·(T/Λ₋)^{1/6}.**

*Proof.*
1. *Decomposition (as W′).* δ = Nc + Su with u = Dδ, and (I − P_H)N = 0. So ⟨ε, δ⟩ = ⟨P_Hε, δ⟩ + Σⱼuⱼ⟨w_j, ε⟩.
2. *Head, split at L (new).* By Lemma H2.3 and Cauchy–Schwarz on S₁, Hölder on S₂:
   ⟨P_Hε, δ⟩ ≤ ‖P_Hε‖₂·√(2n)·r + ‖P_Hε‖∞·2nr²/L.
   - E‖P_Hε‖₂ ≤ √(tr P_H) = √(J″ + 3) ≤ √(2m/h). This gives (i).
   - (P_Hε)ᵢ = ⟨P_He_i, ε⟩ is sub-Gaussian with variance proxy ‖P_He_i‖₂² ≤ 9/h (Hoeffding's lemma; Lemma Lev). The maximal inequality over 2n variables gives E‖P_Hε‖∞ ≤ √(2 log(2n))·3/√h. This gives (ii).
3. *Tail (as W′ step 3).* |Σⱼuⱼ⟨w_j, ε⟩| ≤ ‖u‖₁·max_j|⟨w_j, ε⟩| ≤ (T₀/n²)·max_j|⟨w_j, ε⟩|, and E max_j|⟨w_j, ε⟩| ≤ √(2 log 2m)·2.85·h^{5/2} (Lemma F′). This gives (iii).
4. *Choice of h.* h ∈ [x/2, x], so h^{−1/2} ≤ √2·x^{−1/2} and h^{5/2} ≤ x^{5/2}. With T₀/n² = Tn/Λ₋ and T·x³/Λ₋ = r:
   - (i) ≤ 2.83·n·r·x^{−1/2};
   - (ii) ≤ (12/L)·√(log 2n)·n·r²·x^{−1/2} ≤ 12·√(log 2n)·n·r·x^{−1/2}, using r ≤ L;
   - (iii) ≤ 4.03·√(log 2m)·n·r·x^{−1/2}.

   Sum ≤ (2.83 + 12 + 4.03)·√(log 2n)·n·r·x^{−1/2} for log 2n ≥ 1, and x^{−1/2} = (T/(rΛ₋))^{1/6}. ∎

**Remark.** The split at L is what the Huber body needs and the ℓ₂ body does not: the large coordinates are controlled only in ℓ₁, and ℓ₁ pairs with ‖P_Hε‖∞, which is small exactly because the spline space has uniformly small leverage. With the SVD projector of Lemma W there is no such leverage bound, so Theorem H needs Lemma F's spline projector.

---

## 5. The event Ω_G: Markov in place of Bousquet — PROVED

Let G := sup_{δ∈K_H}|ℛ(δ) − M(δ)| and Ω_G := {G ≤ (f/8)·n·r²}.

**Lemma G.** Under (A1), with r as in §1 and the conditions of Lemma WH: E₀G ≤ (f/8)·n·r²/K, hence P₀(Ω_Gᶜ) ≤ 1/K. Ω_G does not depend on ω, ℓ or p.

*Proof.*
1. K_H is compact and |Xᵢ(δᵢ)| ≤ |δᵢ|, so G is a bounded random variable (no moment of Zᵢ is needed) and the supremum can be taken over a countable dense set.
2. Symmetrization, then the Ledoux–Talagrand contraction principle conditionally on the data (x ↦ Xᵢ(x) is 1-Lipschitz with Xᵢ(0) = 0), then symmetry of K_H: E₀G ≤ 2·E sup_{K_H}|ΣᵢεᵢXᵢ(δᵢ)| ≤ 4·E sup_{K_H}⟨ε, δ⟩. Neither step uses an envelope.
3. By Lemma WH, E₀G ≤ 75.6·√(log 2n)·n·r^{5/6}(T/Λ₋)^{1/6}. This is ≤ (f/8)nr²/K if and only if r^{7/6} ≥ (604.8·K/f)·√(log 2n)·(T/Λ₋)^{1/6}, i.e. r² ≥ (604.8·K/f)^{12/7}(log 2n)^{6/7}(T/Λ₋)^{2/7}, which holds by the definition of r.
4. Markov's inequality. ∎

**Why not Bousquet.** Its deviation term involves the envelope sup_{K_H}‖δ‖∞ and the weak variance sup_{K_H}Σδᵢ². On K_H neither is small: a single spike H·e_i lies in the body for every H ≤ min(Tn/(8Λ₋), nr²/L) (its TV is at most 8Hn²), which is unbounded when Λ₋ ≪ n, and Σ_{S₂}δᵢ² is bounded only by ‖δ‖∞·2nr²/L. Without sup-norm localization the deviation term is not o(nr²). The price of Markov is the probability 1/K instead of 1/n, and the factor K^{12/7} in r².

**Consequences on Ω_G** (Lemmas H1, H2).
- On A₁: ℛ(δ) ≥ t·ℛ(δ₁) ≥ t·[M(δ₁) − G] ≥ t·(f/2 − f/8)·nr² = 3t·(f/8)nr².
- On A₂: ℛ(δ) ≥ t·ℛ(δ₁) ≥ −t·G ≥ −t·(f/8)nr² (M ≥ 0).

---

## 6. Proof of Theorem H — PROVED

Write a := ω(f/8)·n·r².

### 6.1 Cone A₁

For fixed u, δ = N(c − c\*) + S(u − u\*) and ‖δ‖₂ ≥ ‖c − c̄(u)‖₂ with c̄(u) := c\* − NᵀS(u − u\*) (L5; N orthonormal). By Lemma H2.4, t ≥ ‖δ‖₁/R_c ≥ ‖δ‖₂/R_c ≥ ‖c − c̄(u)‖₂/R_c on {t > 1}. On Ω_G, e^{−ωℛ} ≤ e^{−3at} ≤ e^{−2a}·e^{−a‖c−c̄(u)‖₂/R_c}. Since ∫_{ℝ³}e^{−a|c|/R_c}dc = 8π(R_c/a)³ and Π_ℓ, p are probability measures:

  N̄_ω(A₁) ≤ 8π·(R_c/a)³·e^{−2a} ≤ 8π·(12L/(ω₁f·r²))³·e^{−ω₁f·nr²/4}  for all ω ≥ ω₁,  (1)

using R_c/a = 8(r² + L²/2)/(ωfL·r²) ≤ 12L/(ωf·r²) for r ≤ L.

### 6.2 Cone A₂

On A₂, t = n²‖u − u\*‖₁/T₀ ≤ n²‖u‖₁/T₀ + s₀, s₀ := V/T₀ = VΛ₋/(Tn³). For fixed u, the c-section of A₂ lies in {‖c − c̄(u)‖₂ ≤ t·R_c} (Lemma H2.4), of volume V₃(tR_c)³, and e^{−ωℛ} ≤ e^{at} on Ω_G. So ∫1_{A₂}e^{−ωℛ}dc ≤ V₃R_c³·t³e^{at}1{t > 1}, which is increasing in t.

Under Π_ℓ, Γ := ℓ‖u‖₁ ~ Gamma(m, 1), and for ℓ ≥ Λ₋: n²‖u‖₁/T₀ = (Λ₋/ℓ)·Γ/(Tn) ≤ Γ/(Tn) (V2T Step 4). With t³ ≤ 6eᵗ, 1{t > 1} ≤ e^{β(t−1)}, β := Tn/2 − a − 1 > 0, and E e^{Γ/2} = 2^m:

  N_{ω,ℓ}(A₂) ≤ 6V₃R_c³·exp{−Tn/2 + a + 1 + VΛ₋/(2n²) + m·log 2} ≤ 6V₃R_c³·e^{−Tn/4}

by (H4), for every ℓ ≥ Λ₋ and every ω ≤ ω₂. Integrating over p:

  N̄_ω(A₂) ≤ 6V₃R_c³·e^{−Tn/4}.  (2)

### 6.3 Denominator

Centre u_h := u\* (L4; no mollification, so no half-radius condition).
- L4 with shift u\* and C = B_{ε/2}, then L3 at radius ε/2 (valid for all λ > 0, decreasing in λ): for every ℓ ∈ J₀,

  −log Π_ℓ(u\* + B_{ε/2}) ≤ ℓ‖u\*‖₁ + 30·(2n^{5/2}/(ℓε))^{2/5}(log m)^{1/5} + 6 ≤ 2Λ₋V/n² + n·ε² + 6 ≤ 2V + nε² + 6.

  The middle step is 30·2^{2/5}·Λ₋^{−2/5}ε^{−2/5}(log m)^{1/5} ≤ ε², i.e. ε² ≥ (30·2^{2/5})^{5/6}Λ₋^{−1/3}(log m)^{1/6}, and (30·2^{2/5})^{5/6} ≤ 21.5. The last uses Λ₋ ≤ n².
- From here, V2T Step 3 line by line with this centre: G := {u ∈ u\* + B_{ε/2}, ‖N(c − c\*) + P_NS(u − u\*)‖ₙ ≤ ε/2}; ν̄₀ := ∫_{J₀}p(dℓ)ν_ℓ; g := ν̄₀(· ∩ G)/ν̄₀(G), deterministic; ν̄₀(G) ≥ V₃(ε√n/2)³·p₀·e^{−nε²−6−2V}; on G, ‖δ‖ₙ² ≤ ε²/2; 𝒯 := ∫ℛ dg has E₀𝒯 ≤ 1.25C₁nε² (L2 (iv)) and Var 𝒯 ≤ 1.25nε² (L2 (i), (A1)); Ω_D := {𝒯 ≤ (1.25C₁ + 1)nε²}, P₀(Ω_Dᶜ) ≤ 1.25/(nε²). Jensen gives, on Ω_D and for all ω > 0:

  N̄_ω(ℝⁿ) ≥ V₃(ε√n/2)³·p₀·exp{−(1 + ω(1.25C₁ + 1))·nε² − 6 − 2V}.  (3)

### 6.4 Combination

{𝐡(δ) > nr² or TV(δ) > T₀} = {t > 1} = A₁ ∪ A₂. Dividing (1) and (2) by (3), with ω ≤ ω₂ in the denominator exponent and R_c ≤ 1.5·nL:

  (8π/V₃)·(2/(ε√n))³·(12L/(ω₁f r²))³ = (8π/V₃)·(24L/(ω₁f·ε√n·r²))³,  6·(2R_c/(ε√n))³ ≤ 6·(3L√n/ε)³.

This is R_n^H. It tends to 0 because:
- nε² = o(nr²): r²/ε² ≥ (C_H/21.5)·K^{12/7}T^{2/7}·Λ₋^{1/21}·(log n)^{29/42} → ∞;
- nr² ≥ c·n^{3/7}, so the polynomial prefactors are negligible;
- nε² = o(n), since ε → 0.

The events: P₀(Ω_Gᶜ) ≤ 1/K (Lemma G) and P₀(Ω_Dᶜ) ≤ 1.25/(nε²). All bounds depend on the law only through (L, f, f̄, V), so the supremum over the class is free. Measurability of the supremum over ω is as in C1 (continuity in ω, integrable dominator). ∎

---

## 7. Theorem H-σ: σ learned — PROVED given V2T Step 2 for a general floor

**Model.** As above with σ ~ IG(a, b), a, b > 0 fixed, penalty σ-free; add Lemma S's assumptions (row-average uniform integrability of ρ_τ(Zᵢ), d ≤ σ₀,ₙ ≤ B).

**Statement.** If Λ₋/(K_n⁶(log n)³) → ∞, Λ₋ ≤ n² and −log p₀ = o(nr²), then for every η > 0:
1. sup_P E_P Π(𝐡(θ − θ\*)/n > r² or TV(θ − θ\*) > T₀ | y) → 0;
2. sup_P E_P Π(|σ/σ₀,ₙ − 1| > η | y) → 0.

*Proof.*
- *Disintegration* (V2T Step 1): Π(B | y) ≤ sup_{s∈I}Π_s(B | y) + Π(σ ∉ I | y), I = [l, H₀].
- *σ-containment* (V2T Step 2). Its proof uses the floor at exactly two places: (a) L3 at radius one, 30(n^{5/2}/Λ₋)^{2/5}(log m)^{1/5} + 6 ≤ n, true for Λ₋ ≥ 10⁴√(log m) and n ≥ 100; (b) the roughness cost 2^{n−3}e^{−Λ₋nd/8} against O(n log n), true when Λ₋/log n → ∞. Both hold here. Its evidence bound uses ‖P⊥θ\*‖ₙ ≤ V, which is λ-free.
- *Theorem H* on [1/H₀, 1/l] gives conclusion 1.
- *Scale* (Lemma S §1): hypothesis (H) holds by the average-absolute-error translation in §1; σ and λ are conditionally independent given (θ, y). ∎

I have not re-read V2T Step 2's audited text against this general-floor use beyond the two facts above; that is the only reason for the qualified label.

---

## 8. Corollary P: plug-in for any lower-tail control of λ — PROVED

**Model with no truncation.** σ ~ IG(a, b) and λ ~ p_n, any probability law on (0, ∞) (Gamma with n-dependent hyperparameters included). Let Λ₋ = Λ₋,ₙ with p_n([Λ₋, ∞)) > 0.

**Identity.** Conditioning the joint posterior on {λ ≥ Λ₋} gives exactly the posterior for the hyperprior p_n(· | λ ≥ Λ₋). Hence, for every event B and every data vector,

  **Π(B | y) ≤ Π(B | y, λ ≥ Λ₋) + Π(λ < Λ₋ | y).**

**Corollary P.** Suppose that for some sequence Λ₋,ₙ with K_n⁶(log n)³ ≪ Λ₋,ₙ ≤ n²:
- **(LT)** sup_P E_P Π(λ < Λ₋,ₙ | y) → 0 (lower-tail control, from any source);
- **(WM)** −log[p_n([Λ₋, 2Λ₋])/p_n([Λ₋, ∞))] = o(n·r²) (window mass of the conditioned hyperprior).

Then conclusions 1 and 2 of Theorem H-σ hold for the **untruncated** posterior, with r² = C_H·K_n^{12/7}(T/Λ₋,ₙ)^{2/7}(log 2n)^{6/7}.

*Proof.* Apply Theorem H-σ to p := p_n(· | λ ≥ Λ₋), for which p₀ is the ratio in (WM); add (LT). For conclusion 2, the identity is applied to B = {|σ/σ₀,ₙ − 1| > η}. ∎

**What the consumer of this corollary must supply.**
- (LT) at the largest Λ₋,ₙ available; the rate is Λ₋,ₙ^{−2/7}·polylog. Nothing else about the posterior of λ is needed, and no upper control.
- (WM). For a Gamma(1, b_n) hyperprior the ratio is exactly 1 − e^{−b_nΛ₋} (memoryless), so (WM) holds as soon as b_nΛ₋ ≥ e^{−o(nr²)}. For Gamma(a_n, b_n) with a_n ≠ 1 the ratio is not computed here and must be checked.
- If (LT) can be proved with Λ₋,ₙ above n² (inside C1's window, Λ₋ ≫ n^{23/11}), use V2T / V0T\* instead of Theorem H; the identity is the same.

---

## 9. What Theorem H does not give

- **No sup-norm, hence no C2 shells.** The remainder step of C2 needs ‖δ‖∞ ≤ s₀. So the rate stays at Λ₋^{−2/7}; the small-ball rate would be Λ₋^{−1/3}.
- **Probability 1/K_n, not 1/n — SKETCH of the obstacle.** A high-probability version needs a deviation bound for a supremum with unbounded envelope. The natural route is pathwise: for |x| > L, convexity gives Xᵢ(x) ≥ Xᵢ(±L) + (|x| − L)·ξᵢ^±, with ξᵢ⁺ := 1{Zᵢ ≤ L} − τ, ξᵢ⁻ := τ − 1{Zᵢ < −L} bounded and of mean ≥ fL. This reduces the unbounded part to a linear process in the weights (|δᵢ| − L)₊, but those weights are not in a third-order TV ball (clipping destroys it), so Lemma WH does not apply to them. Not resolved.
- **Λ₋ ≤ n².** Used for the L4 shift cost (2Λ₋V/n² ≤ 2V), for nε² → ∞, and for h ≤ m/4. Above it, C1's ℓ₂ body is available and better.
- **Constants are not optimized.** C_H = (605/f)^{12/7} carries 4 (symmetrization and contraction) × 18.9 (width) × 8 (margin slack).

---

## 10. Conditions (n₀)

For fixed (L, f, f̄, V, T ≥ 4, K ≥ 1, ω₁ ≤ ω₂):
- **(H1)** n ≥ 5, log 2n ≥ 1, and 10⁴·√(log m) ≤ Λ₋ ≤ n². (Gives ε < 1 and nε² ≥ 21.5·n^{1/3}.)
- **(H2)** r ≤ L, i.e. Λ₋ ≥ T·(C_H·K^{12/7}/L²)^{7/2}·(log 2n)³.
- **(H3)** x = (rΛ₋/T)^{1/3} ∈ [3, m/4]. (The upper bound is automatic for Λ₋ ≤ n² and r ≤ L once n ≥ n₀(L, T).)
- **(H4)** Tn/4 ≥ ω₂(f/8)·n·r² + 1 + VΛ₋/(2n²) + m·log 2. With T = 4 and Λ₋ ≤ n²: 0.306n + 2.08 ≥ ω₂(f/8)nr² + 1 + V/2.
- For Theorem H-σ: Lemma S's law-of-large-numbers events, which carry no explicit rate; and n ≥ 100 for §7 (a).

## 11. Not verified

- Internals of L3, L4, L5, L6, L10-I, Lemma S, V2T and Lemma F: used as stated in their audited files. From L10-I only the Christoffel inequality max_{k∈W}q(k)² ≤ 9·w⁻¹Σ_{k∈W}q(k)² (w ≥ 3) is used.
- The Ledoux–Talagrand contraction with absolute values (factor 2) is quoted, as in C1 Step 3.
- All constants (2.85, 9/h, 18.9, 605, 21.5) were computed by hand once.
- No numerical check of Lemma Lev or Lemma F′ (suggested: max_i(P_H)ᵢᵢ·h ≤ 9 and max_j‖w_j‖₂/h^{5/2} ≤ 2.85 for a few (n, h)).

---

## Theory Department: cross-family audit response (Astra, `reviews/AUDIT_astra_theoremH.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES.** All nine findings are CONFIRMED; Theory rules that they **HOLD**.
- **(1)–(4)** The margin, translations, cones, trimming and leverage bound, the width and Markov exponents (with one rounding correction that keeps the constant 18.9), and the cone integrals are all confirmed.
- **(5) Repair.** The denominator event Ω_D depended on the hyperprior p. Astra constructs a common event with the stated constants; adopted.
- **(6)** Asymptotics and conditioning are confirmed.
- **(7)** V2T Step 2 extends to a general floor, so **the learned-σ conclusion holds** under Lemma S's assumptions.
- **(8) Improvement.** L10-I gives sup-norm contraction on the part of the window where M_n²n³Λ₋^{−11/7}(log)… → 0.
- **(9) Improvement.** L10-I controls the envelope well enough for a **fixed-multiplier Bousquet bound**, i.e. a fixed large M rather than only M_n → ∞. To be written in the clean version.

**Status: Theorem H is PROVED and cross-family audited.**
