# Link L4b: λ ∈ [n^{3/2}, C·n^{99/43}] — proved down to n^{9/5}; one constant-level hypothesis left between n^{26/17} and n^{9/5}

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute. Builds on `FABLE_A_three_lemmas.md` (Theorem LO, audited), `FABLE_A_uniformity.md` (Theorem U), `FABLE_A_gap4.md`, `FABLE_A_theoremH.md`. Not audited. Min-density version throughout; the weighted version of `FABLE_B_averaged_beta.md` is addressed in a remark only (§3.7).*

**Labels.** PROVED = written here in full from audited statements, elementary linear algebra, or the standard facts listed in §8. SKETCH = argument given, details open. CONJECTURE = heuristic only.

## 0. Verdict

**L4b is proved here (unaudited) down to n^{9/5} = n^{1.80}, and reduced to one constant-level hypothesis, (SN) or the weaker (XS), between n^{26/17} ≈ n^{1.53} and n^{1.80}.** Two new exact tools do the work: the precision-side form of the mixture (§3) and a layer-cake bound for the remainder (§4), which replaces Lemma 1 and removes the amplitude problem.

| # | Claim | Status |
|---|---|---|
| 1 | **Lemma 2b′ (resolvent trace).** tr((I + ϱA₀A₀ᵀ)^{−1}𝒟) ≤ (2/π³)w²n⁴/κ³; no eigenvector information | **PROVED** (§1) |
| 2 | With it alone, LO / U / U-σ hold for ℓ ≥ C·n^{54/25}·polylog | PROVED by substitution into the audited §4.5 (§2) |
| 3 | **Precision-side form.** With T := DDᵀ, H_V := T + a·diag(V): det(I + aΣ_V) = det H_V/det T and zᵀ(I + aΣ_V)^{−1}z = (Dz)ᵀH_V^{−1}(Dz) | **PROVED** (§3.1) |
| 4 | **Lemma 2b″ (form sandwich)** for H_V, subtraction-free, constant 6 kept; the mixture part of Theorem LO holds for **ℓ ≥ C·n^{26/17}·polylog** (≈ n^{1.53}) | **PROVED** (§3.2–3.6) |
| 5 | **Lemma CA (layer-cake remainder bound).** On one event, for **every** δ with ‖δ‖∞ ≤ L: R(δ) ≥ (1 − η)M(δ) − (3 log n/η)·(TV₁(δ) + 2L), TV₁ the first-order total variation. No body, no chaining, no smallness of the amplitude | **PROVED** (§4.1) |
| 6 | **Lemma LK.** TV₁(δ) ≤ C[‖δ‖₁^{2/3}‖Dδ‖₁^{1/3} + ‖δ‖₁/n + ‖Dδ‖₁]; on the localization bodies TV₁ ≤ C·r^{2/3}·k = o(k/log n) | PROVED with an unnamed absolute constant (§4.2) |
| 7 | **Theorem LO′.** The LO bound (β < 6, same exponent) holds for **ℓ ≥ C·n^{21/11}·polylog** using C1 with W′, and for ℓ ≥ C·n^{23/11}·polylog using only audited C1. Lemma 1 and its window n^{54/25} are no longer needed. Theorems U and U-σ inherit the window | PROVED given 4–6, by the same substitution as before (§4.4) |
| 8 | **Conditional Theorem LO-low.** For n^{26/17}polylog ≤ ℓ ≤ n²: the LO bound holds at (ω, ℓ) if **(SN): Π_{ω,ℓ}(‖θ − θ\*‖∞ > L | y) ≤ ¼**, or under the weaker **(XS)**: the excess of the fit above amplitude L has ℓ₁-mass plus energy ≤ ηk with posterior probability ≥ ¾ (clip inequality, §4.5) | PROVED given 4–6, the halving lemma and Theorem H (§4.3–4.5) |
| 9 | **Theorem H-sharp.** The fixed-tuning posterior contracts in Huber loss at the small-ball rate ℓ^{−1/3}(log n)^{1/6}, for every scale and every ℓ ≥ polylog (Theorem H gave ℓ^{−2/7}). **Corollary:** (SN) holds for ℓ ≥ C·n^{9/5}·polylog; hence **Theorem LO″: the LO bound holds for ℓ ≥ C·n^{9/5}·polylog** | PROVED, one pass (§4.6) |
| 10 | Further tools toward (SN) below n^{9/5}: the translation lemma and **Corollary T1** (no plateau above level s longer than ≍ (ℓ/s)^{1/3}), PROVED; Lemma WA, identity PROVED; (SN) follows from maxᵢ[δᵢ²] ≤ L²/(3 log n)², PROVED | §5 |
| 11 | (SN) or (XS) for n^{26/17} ≤ ℓ < n^{9/5} | **OPEN**; a constant-level statement about the fixed-tuning posterior, measurable from fixed-λ chains |

**Where L4b stands.**

| Range of ℓ | Status |
|---|---|
| [n^{21/11}polylog, n^{5/2}] | LO′ / U / U-σ unconditional (n^{23/11} if C1-with-W′ is not used) |
| [n^{9/5}polylog, n^{21/11}] | LO″ unconditional at fixed (ω, ℓ); the uniform version (U, U-σ) is SKETCH (§4.6) |
| [n^{26/17}polylog, n^{9/5}] | LO **conditional on (SN)** (or on the weaker (XS)) |
| [n^{3/2}, n^{26/17}] | a sliver; needs the cutoff on the largest mixing variance reduced from k^{6/5} to log n (SKETCH, §3.7) |

**What happened to the amplitude lemma of the gap-4 note.** It is no longer needed. Lemma CA controls the remainder by the first-order total variation of the fit, which is small on the whole localization body. The only place the size of the fit still matters is the quadratic margin M(δ) ≥ (f/2)‖δ‖₂², which needs ‖δ‖∞ ≤ L, a constant.

---

## 1. Lemma 2b′: the resolvent trace of the block perturbation — PROVED

Notation of the three-lemmas note: A₀ = P⊥S = D⁺; a_j = A₀e_j; blocks b of consecutive indices with w ≤ |b| < 2w; ā_b the block mean; d_j = a_j − ā_b; 𝒟 = Σⱼd_jd_jᵀ.

**Lemma 2b′.** For ϱ > 0 with κ := ϱ^{1/6}·n/π ≥ 12: tr((I + ϱA₀A₀ᵀ)^{−1}𝒟) ≤ 2m·w²·ϱ^{−1/2} ≤ (2/π³)·w²·n⁴/κ³.

*Proof.*
1. d_j = A₀g_j with g_j := e_j − ē_b ∈ ℝᵐ. By the push-through identity and A₀ᵀA₀ = T^{−1} (T := DDᵀ): d_jᵀ(I + ϱA₀A₀ᵀ)^{−1}d_j = g_jᵀ(T + ϱI)^{−1}g_j.
2. With 𝖱 := (T + ϱI)^{−1}: Σ_{j∈b}g_jᵀ𝖱g_j = (2|b|)^{−1}Σ_{j,j′∈b}(e_j − e_j′)ᵀ𝖱(e_j − e_j′).
3. T + ϱI is the leading m×m block of C_n + ϱI (Lemma 2a). The inverse of a principal block of a positive definite matrix is dominated by the block of the inverse (Schur complement): xᵀ𝖱x ≤ xᵀ(C_n + ϱI)^{−1}x.
4. With Δ := |j − j′|, g(θ) = (2 sin(θ/2))⁶: (e_j − e_j′)ᵀ(C_n + ϱI)^{−1}(e_j − e_j′) = n^{−1}Σ_q 4 sin²(πqΔ/n)/(g(2πq/n) + ϱ) ≤ (Δ²/π)∫₀^∞θ²dθ/((2θ/π)⁶ + ϱ) + O(Δ²ϱ^{−2/3}/n) = (π³/48)Δ²ϱ^{−1/2}(1 + O(1/κ)) ≤ Δ²ϱ^{−1/2}.
5. Δ < 2w inside a block: each block contributes ≤ 2|b|w²ϱ^{−1/2}; ϱ^{−1/2} = (n/(πκ))³. ∎

## 2. First consequence — PROVED by substitution

In §4.5 of the three-lemmas note, 𝒟 enters through two terms. Gain: tr M₊ ≤ tr M(X₊) + tr((I + aX₊)^{−1}E′), and by Lemma 2b′ the error is ≤ C·γ^{−1}β′c₀w²κ³/n², fine when κ^{28/5} ≲ n². Cost: if N := a(I + aΣ₋)^{−1/2}E(I + aΣ₋)^{−1/2} has tr N ≤ ½, then logdet(I + aΣ_V) ≥ logdet(I + aΣ₋) − 2 tr N; tr N ≤ C·γ^{−1}c₀w²κ³/n² ≤ ½ when κ^{33/5} ≲ n², i.e. ℓ ≳ n^{23/11}. So with Lemma 2b′ alone the block window is n^{23/11} and Theorem LO, U, U-σ hold for ℓ ≥ C·n^{54/25}·polylog (Lemma 1's condition). §3–4 supersede this; it is kept as the shortest independent check.

---

## 3. The precision-side form of the mixture step

### 3.1 Two identities — PROVED

Let T := DDᵀ, V := diag(Vⱼ), **H_V := T + a·V**. Recall A₀ = DᵀT^{−1}, P⊥ = DᵀT^{−1}D, Σ_V = A₀VA₀ᵀ.

- **Determinant.** det(I_n + aΣ_V) = det(I_m + aVT^{−1}) = **det H_V/det T**.
- **Resolvent.** For z ∈ range P⊥: zᵀ(I + aΣ_V)^{−1}z = **(Dz)ᵀH_V^{−1}(Dz)**. (On range P⊥, I + aΣ_V = DᵀT^{−1}H_VT^{−1}D, and DᵀT^{−1}H_VT^{−1}D·DᵀH_V^{−1}D = P⊥.)

Hence the exact formula of the three-lemmas note §4.2 reads

  𝒵 = (2π/a)^{3/2}·e^{(ω/(2f′))‖ψ‖₂²}·E_V[(det T/det H_V)^{1/2}·exp{−(a/2)·(Dz)ᵀH_V^{−1}(Dz)}],  Dz = u\* + Dψ/f′.

Both factors are monotone in H_V (Loewner order). So **any fixed pair H₋ ⪯ H_V ⪯ H₊ gives a fixed upper bound**, with the eigenvalues of H₋ in the cost and the quadratic form of H₊^{−1} in the gain.

### 3.2 Form bounds for the random potential — PROVED

Blocks b of consecutive indices in {1, …, m}, w ≤ |b| < 2w, w ≥ 3. For x ∈ ℝᵐ and a block b: d_b := the third differences of x inside b, q̃_b := the quadratic through the first three entries of x_b, ẽ_b := x_b − q̃_b.

**(P) Local remainder.** ẽ_b = S_bd_b, S_b the local triple-sum matrix, rows of squared norm ≤ 8w⁵. With V̄_b := Σ_{j∈b}Vⱼ:

  ‖ẽ_b‖₂² ≤ 16w⁶‖d_b‖₂²,  Σ_{j∈b}Vⱼẽ_j² ≤ 8w⁵·V̄_b·‖d_b‖₂²,  Σ_b‖d_b‖₂² ≤ ‖Dᵀx‖₂² = xᵀTx.

**(L) Local law of large numbers.** Ω_L := {for every block and every quadratic q on it, (1 − η)v₁‖q‖₂² ≤ Σ_{j∈b}Vⱼq_j² ≤ (1 + η)v₁‖q‖₂²}. P(Ω_Lᶜ) ≤ C(m/w)e^{−cη²w}. *Proof.* For a unit q the weights q_j² are ≤ 9/|b| (Christoffel constant) and sum to 1; Bernstein for sub-exponential sums, a net of the three-dimensional unit sphere, union over blocks. ∎ On Ω_L: V̄_b ≤ 2|b|v₁.

**(B_t) Block sums.** Ω^{(t)} := {V̄_b ≤ t|b|v₁ ∀b}, t ≥ 2. P((Ω^{(t)})ᶜ) ≤ (m/w)e^{−wt/8}. On Ω^{(t)}: Σ_{j∈b}Vⱼq_j² ≤ 9t·v₁‖q‖₂² (leverage).

**Consequences** (Young inequalities with γ ∈ (0, ½], on x_b = q̃_b + ẽ_b, summed over blocks).
- On Ω_L: (1 − γ)²(1 − η)v₁‖x‖² − 48γ^{−1}w⁶v₁·xᵀTx ≤ ΣⱼVⱼxⱼ² ≤ (1 + γ)²(1 + η)v₁‖x‖² + 110γ^{−1}w⁶v₁·xᵀTx.
- On Ω^{(t)}: ΣⱼVⱼxⱼ² ≤ 36t·v₁‖x‖² + 610t·w⁶v₁·xᵀTx.
- Always: ΣⱼVⱼxⱼ² ≤ (maxⱼVⱼ)‖x‖².

### 3.3 Lemma 2b″: the sandwich for H_V — PROVED

ϱ := a·v₁ (κ := ϱ^{1/6}n/π is k_\*), c₋ := (1 − γ)²(1 − η), c₊ := (1 + γ)²(1 + η), **ε := 110γ^{−1}ϱw⁶ = 110γ^{−1}(πκw/n)⁶** < 1, θ ∈ (0, ½), cutoff c₀ ≥ 1.

**Lemma 2b″.** On Ω_L ∩ {maxⱼVⱼ ≤ c₀v₁}:

  **H₋ := (1 − ε)T + ϱc₋I ⪯ H_V ⪯ T + E₊ =: H₊,  E₊ := [(1 − θ)(ϱc₊I + εT)^{−1} + θ(c₀ϱ)^{−1}I]^{−1}.**

Also T ⪯ H_V always. *Proof.* Lower bound: §3.2. Upper: a·V ⪯ A := ϱc₊I + εT and a·V ⪯ B := c₀ϱI; inversion reverses the order, so (aV)^{−1} ⪰ (1 − θ)A^{−1} + θB^{−1}; invert again. ∎

E₊ has eigenvalues e_r ≤ min((ϱc₊ + εμ_r)/(1 − θ), c₀ϱ/θ): sharp on the low modes, bounded on the high ones. The cutoff c₀ enters only through c₀^{1/6}.

### 3.4 Cost and gain — PROVED

ρ_r := ϱc₋/μ_r, ρ′_r := ϱc₊/((1 − θ)μ_r), κ₋ := c₋^{1/6}κ, κ₊ := (c₊/(1 − θ))^{1/6}κ.

**Cost.** By Weyl's monotonicity (T and H₋ share eigenvectors and ordering), λ_r(H_V) ≥ max(μ_r, (1 − ε)μ_r + ϱc₋), so

  log det H_V − log det T ≥ Σ_r log max(1, 1 − ε + ρ_r) ≥ Σ_r log(1 + ρ_r) − Cκε^{5/6} ≥ 2πκ₋ − 24 log κ₋ − 24 − Cκε^{5/6}

(#{ρ_r ≥ ε} ≤ 2 + (π/2)κε^{−1/6}, Σ_{ρ_r<ε}ρ_r ≤ 2κε^{5/6}, Lemma 2a).

**Gain.** a·M₊ := P⊥ − DᵀH₊^{−1}D is a spectral function of T with eigenvalues e_r/(μ_r + e_r). Splitting at r\* ≍ κ(c₀/(θε))^{1/6}:

  d₊ := tr(aM₊) ≤ (π/3)κ₊/(1 − η²/2) + 2 + Cκε^{5/6}(c₀/θ)^{1/6}.

The score events (Hanson–Wright, Hoeffding) apply to the fixed M₊ and B₊ = DᵀH₊^{−1}D ⪯ I as in Theorem U §3.

**Requirements.** ε ≤ cη^{6/5} and ε^{5/6}(c₀/θ)^{1/6} ≤ cη. Then

  log(integrand) ≤ −(π/6)κ[6c₋^{1/6} − β′(1 + η)(c₊/(1 − θ))^{1/6}/(1 − η²/2)] + 3ηκ + C log n,

and the bracket tends to 6 − β as γ, η, θ ↓ 0.

### 3.5 Atypical variances — PROVED

On each class H_V ⪯ (a fixed matrix) and det H_V ≥ det T.

| Class | Fixed upper envelope | Gain bound | Probability |
|---|---|---|---|
| maxⱼVⱼ ∈ (2^{i−1}, 2^i]v₁, 2^i > c₀ | T + a2^iv₁I | C₂κ2^{i/6} | ≤ m·e^{−2^{i−1}} |
| max ≤ c₀v₁, Ω_L fails, Ω^{(2)} holds | Lemma 2b″ with (72, 1220) for (c₊, 110γ^{−1}) | Cκ | ≤ C(m/w)e^{−cη²w} |
| max ≤ c₀v₁, Ω^{(2^{i−1})} fails, Ω^{(2^i)} holds, i ≥ 2, 2^iε < 1 | the same with (36·2^i, 610·2^i) | Cκ2^{5i/6} | ≤ (m/w)e^{−w2^i/16} |
| max ≤ c₀v₁, Ω^{(2^{i−1})} fails with 2^iε ≥ 1 | T + ac₀v₁I | C₂κc₀^{1/6} | ≤ (m/w)e^{−w/(16ε)} |

Each class contributes ≤ e^{−2πκ} times the flat prefactor provided c₀ ≥ max{(4C₂κ)^{6/5}, 8πκ + 4 log 2m} and **w ≥ C(κ + log n)/η²** (the fourth row then follows from the gain requirement).

### 3.6 The window — PROVED given §3.2–3.5

w ≥ C(κ + log n)/η² and, from the gain requirement with c₀ ≍ κ^{6/5}, w ≤ c·(n/κ)·c₀^{−1/30} ≍ n·κ^{−26/25}. Compatible iff κ^{51/25} ≲ n:

  **ℓ ≥ C·n^{26/17}·polylog  (≈ n^{1.529}).**

### 3.7 Remarks

- *The sliver [n^{3/2}, n^{26/17}] — SKETCH.* The only loss against κ² ≲ n is c₀^{1/30} with c₀ ≍ κ^{6/5}. Variances above C·log n·v₁ are sparse and act as a finite-rank change of H_V; treating them so should give c₀ ≍ log n and ℓ ≳ n^{3/2}polylog. Not written.
- *Below n^{3/2}.* κ² > n: a block long enough for the variances to average is longer than a wavelength. This route stops.
- *Weighted version.* With DW^{−1}Dᵀ in place of T, (P), (L), (B_t) are local and survive with constants depending on max fᵢ/min fᵢ; the spectral input is Fable B's block-bracketed lemma. Not rewritten.

---

## 4. The remainder without localization

### 4.1 Lemma CA: a layer-cake bound — PROVED

Recall (C2 §3.1) Rᵢ(x) = (x − Zᵢ)₊1{Zᵢ ≥ 0} for x ≥ 0 and (Zᵢ − x)₊1{Zᵢ < 0} for x ≤ 0. Write TV₁(δ) := Σᵢ|δ_{i+1} − δᵢ|.

**Lemma CA.** Assume (A1) and the upper secant bound on [−L, L]. There is an event Ω_CA, free of ω and ℓ, with P₀(Ω_CAᶜ) ≤ 3/n, on which (for n ≥ n₀(f̄, L)) for **every** δ ∈ ℝⁿ with ‖δ‖∞ ≤ L and every η ∈ (0, 1]:

  **R(δ) ≥ (1 − η)·M(δ) − (3 log n/η)·(TV₁(δ) + 2L).**

*Proof.*
1. *Layer cake.* For t ∈ (0, L] put B⁺ᵢ(t) := 1{0 ≤ Zᵢ ≤ t}, B⁻ᵢ(t) := 1{−t ≤ Zᵢ < 0}, with means p^±ᵢ(t) ≤ f̄t. Then Rᵢ(x) = ∫₀^{|x|}B^±ᵢ(t)dt (sign of x), so

   R(δ) = ∫₀^L[Σ_{i:δᵢ≥t}B⁺ᵢ(t) + Σ_{i:δᵢ≤−t}B⁻ᵢ(t)]dt,  M(δ) = the same with p^±ᵢ(t).

2. *Runs.* For each t the set {i : δᵢ ≥ t} is a disjoint union of maximal intervals ("runs") J; likewise {δᵢ ≤ −t}. So R(δ) − M(δ) = ∫₀^LΣ_{runs J}S^±_J(t)dt, with S^±_J(t) := Σ_{i∈J}(B^±ᵢ(t) − p^±ᵢ(t)).
3. *One event for all intervals and levels.* For a fixed interval J and level t, S_J(t) is a centred sum of independent [0, 1]-valued variables with Σ E B² ≤ P_J(t) := Σ_{i∈J}pᵢ(t); the lower-tail Bernstein bound (no range term) gives P(S_J(t) ≤ −√(10·P_J(t)·log n)) ≤ n^{−5}. Let Ω_CA be this event for all ≤ n² intervals, both signs, and all grid levels t_g = gL/n², 0 ≤ g ≤ n². For t ∈ [t_g, t_{g+1}), since Bᵢ and pᵢ are nondecreasing in t: S_J(t) ≥ S_J(t_g) − Σ_{i∈J}(pᵢ(t_{g+1}−) − pᵢ(t_g)) ≥ −√(10·P_J(t)·log n) − Σ_{i∈J}(pᵢ(t_{g+1}−) − pᵢ(t_g)). No continuity of pᵢ is used: after integration in t the last terms total at most (L/n²)·Σᵢpᵢ(L) ≤ f̄L²/n, because each index lies in at most one run at each level.
4. *Absorb.* √(10·P·log n) ≤ ηP + (5 log n)/(2η). Hence R(δ) − M(δ) ≥ −η·M(δ) − ((5 log n)/(2η))·∫₀^LN(δ; t)dt − f̄L²/n, where N(δ; t) is the number of runs of {δ ≥ t} plus that of {δ ≤ −t}.
5. *Counting runs.* The number of runs of {δ ≥ t} is 1{δ₁ ≥ t} + #{i : δᵢ < t ≤ δ_{i+1}}; integrating in t gives ≤ L + Σᵢ(δ_{i+1} − δᵢ)₊. Same for the negative side. So ∫₀^LN(δ; t)dt ≤ TV₁(δ) + 2L. ∎

**Why this works where Lemma 1 needed ‖δ‖∞ → 0.** The remainder depends on δ only through its super-level sets. Their complexity is the number of runs, which integrates to the first-order total variation. The uniform bound is over intervals, not over a function class, so there is no chaining and no loss at the critical shell. The lemma holds for every tuning and needs no body.

### 4.2 Lemma LK: first-order variation from ℓ₁ size and third-order variation — PROVED (unnamed constant)

**Lemma LK.** There is an absolute constant C_LK with, for every δ ∈ ℝⁿ: TV₁(δ) ≤ C_LK·[‖δ‖₁^{2/3}·‖Dδ‖₁^{1/3} + ‖δ‖₁/n + ‖Dδ‖₁].

*Proof.* Cover {1, …, n} by windows of w + 1 consecutive indices overlapping in one point (3 ≤ w ≤ n). On a window write δ = q̃ + ẽ, q̃ the quadratic through the first three values, ẽ the triple sum of the window's third differences d: |ẽᵢ| ≤ (w²/2)‖d‖₁ and |ẽ_{i+1} − ẽᵢ| ≤ w‖d‖₁. For a quadratic on w + 1 ≥ 4 equispaced points, Σ|q̃_{i+1} − q̃ᵢ| ≤ (C₀/w)·Σ|q̃ᵢ| (norm equivalence on a three-dimensional space, with the scaling in w). So the window's variation is ≤ (C₀/w)Σ_W|δᵢ| + (C₀ + 1)w²‖d‖₁. Sum over windows (each index and each third difference in at most two): TV₁ ≤ (2C₀/w)‖δ‖₁ + 2(C₀ + 1)w²‖Dδ‖₁. Take w := the integer part of (‖δ‖₁/‖Dδ‖₁)^{1/3}, clipped to [3, n]. ∎

**On the bodies.** On K′ (C1) or K_H (Theorem H) intersected with {‖δ‖∞ ≤ L}: ‖δ‖₁ ≤ 3n·r and ‖Dδ‖₁ ≤ T₀/n² = Tn/ℓ, so with k = nℓ^{−1/3}:

  **TV₁(δ) ≤ 3C_LK·T^{1/3}·r^{2/3}·k**  (n large).

### 4.3 Halving lemma — PROVED

Let Π_{ω,ℓ}(· | y) be the posterior at fixed scale and tuning, and 𝒢 any set. If Π_{ω,ℓ}(𝒢ᶜ | y) ≤ ½ and −ωℛ(δ) ≤ ω⟨ψ, δ⟩ − (a/2)‖δ‖₂² + c on 𝒢, then **Z̃_ω(ℓ) ≤ 2·N_{ω,ℓ}(𝒢) ≤ 2e^{c}·𝒵_ω(ℓ).** (Z̃ = N(𝒢) + N(𝒢ᶜ) and N(𝒢ᶜ) = Π(𝒢ᶜ | y)·Z̃.)

### 4.4 Theorem LO′ and Theorem LO-low — PROVED given the inputs named

Let β < 6, η small, and let 𝓑 be a localization body at level ℓ (K′ of C1, or K_H of Theorem H) with radius r satisfying

  **(R)** 9C_LK·T^{1/3}·r^{2/3}·log n ≤ η²  and  6L·log n ≤ η²·k.

On Ω_CA, for δ ∈ 𝒢 := 𝓑 ∩ {‖δ‖∞ ≤ L}: by Lemmas CA and LK and M(δ) ≥ (f/2)‖δ‖₂²,

  R(δ) ≥ (1 − η)(f/2)‖δ‖₂² − 2η·k,  hence −ωℛ(δ) ≤ ω⟨ψ, δ⟩ − (a/2)‖δ‖₂² + 2ωη·k,  a = ω(1 − η)f.

(R) holds for every ℓ ≥ polylog on both bodies (r² ≍ ℓ^{−2/7}·polylog).

**Theorem LO′ (unconditional).** For ℓ ≥ C·n^{21/11}·polylog, C1's body with W′ has s_K ≤ L, so 𝒢 = K′ and, as in the three-lemmas note §4.1, Z̃_ω(ℓ) ≤ e^{2ωηk}𝒵_ω(ℓ) + N_ℓ(K′ᶜ). §3 bounds 𝒵 (its window n^{26/17} is below). Hence the bound of Theorem LO holds on **ℓ ≥ C·n^{21/11}·polylog**; using only audited C1 (Lemma W), on ℓ ≥ C·n^{23/11}·polylog. Lemma 1 is not used. Theorems U and U-σ hold on the same window: in Theorem U §2.3, "Lemma 1 on a panel" is replaced by the single event Ω_CA and the deterministic bound of Lemma LK on each frozen body.

**Theorem LO-low (conditional).** For C·n^{26/17}·polylog ≤ ℓ ≤ n², on the events of Lemma CA, of Theorem H at the point mass λ = ℓ, and of the score bounds: **if (SN) Π_{ω,ℓ}(‖δ‖∞ > L | y) ≤ ¼**, then Π(𝒢ᶜ | y) ≤ ½ with 𝒢 = K_H ∩ {‖δ‖∞ ≤ L}, and by §4.3 and §3:

  Z̃_ω(ℓ) ≤ n^{C}·exp{−(1 − ε)(π/6)(6 − β)·k_\*}.

### 4.5 A weaker hypothesis than (SN): the clip inequality — PROVED

The same layer-cake computation, applied to the whole loss above the level L, shows that the part of the fit above L is a pure penalty.

**Clip inequality.** Write δ^c := clip_L(δ) and v := δ − δ^c (the excess of the fit above amplitude L). There is an event Ω_clip, free of ω and ℓ, with P₀(Ω_clipᶜ) ≤ 2/n, on which for every δ with ‖δ‖∞ ≤ n and every η ∈ (0, 1]:

  **ℛ(δ) ≥ ℛ(δ^c) + (1 − η)·f·L·‖v‖₁ − (log n/(η·f·L))·(TV₁(δ) + ‖δ‖∞) − 1/n.**

*Proof.* Xᵢ(x) = ∫₀ˣ(1{Zᵢ ≤ t} − τ)dt, so ℛ(δ) − ℛ(δ^c) = ∫_L^∞Σ_{i:δᵢ≥t}(1{Zᵢ ≤ t} − τ)dt + ∫_L^∞Σ_{i:δᵢ≤−t}(τ − 1{Zᵢ < −t})dt. For t ≥ L the mean of each term is ≥ Fᵢ(L) − τ ≥ fL. On a run J of {δ ≥ t}: Σ_{i∈J}(1{Zᵢ ≤ t} − Fᵢ(t)) ≥ −√(3|J|·log n) for all intervals and all levels of a grid of mesh n^{−2} on [L, n] (Hoeffding and a union bound; between grid points by monotonicity, at a total cost ≤ 1/n after integration). Then √(3|J| log n) ≤ η·fL·|J| + 3 log n/(4η·fL), and the number of runs integrates to ≤ TV₁(δ) + ‖δ‖∞ as in Lemma CA. ∎

**Consequence.** On K_H (where TV₁(δ) + ‖δ‖∞ = o(k/log n) by Lemma LK) and on Ω_CA ∩ Ω_clip, applying Lemma CA to δ^c (‖δ^c‖∞ ≤ L, TV₁(δ^c) ≤ TV₁(δ)):

  −ωℛ(δ) ≤ ω⟨ψ, δ^c⟩ − (a/2)‖δ^c‖₂² − a·L·‖v‖₁ + 3ωη·k.

Comparing with the Gaussian integrand at δ itself, ω⟨ψ, δ⟩ − (a/2)‖δ‖₂² = ω⟨ψ, δ^c⟩ − (a/2)‖δ^c‖₂² + ω⟨ψ, v⟩ − aL‖v‖₁ − (a/2)‖v‖₂², the terms aL‖v‖₁ cancel and

  **−ωℛ(δ) ≤ ω⟨ψ, δ⟩ − (a/2)‖δ‖₂² + ω‖v‖₁ + (a/2)‖v‖₂² + 3ωη·k  for every δ ∈ K_H.**

So Theorem LO-low holds under the weaker hypothesis

  **(XS): Π_{ω,ℓ}(‖v‖₁ + (f/2)‖v‖₂² > η·k | y) ≤ ¼,  v = (|δ| − L)₊·sign(δ),**

with 𝒢 := K_H ∩ {‖v‖₁ + (f/2)‖v‖₂² ≤ ηk} in the halving lemma. (SN) is the case v = 0. (XS) allows the fit to exceed L, as long as the total excess above L is a small multiple of k.

### 4.6 Theorem H-sharp, and (SN) for ℓ ≥ n^{9/5} — PROVED (one pass)

Lemma CA and the clip inequality also remove the sup-norm requirement from C2's shells. This gives the sharp-order rate for the fixed-tuning posterior, and with it (SN) on a larger range.

**Theorem H-sharp.** Fix ω and let ℓ be in Theorem H's range (polylog ≤ ℓ ≤ n²), k′ := n·ε², ε² = 21.5·ℓ^{−1/3}(log m)^{1/6}. There is M₀ (depending on ω, f, f̄, L, C₁) such that for M ≥ M₀, on events of probability ≥ 1 − C/K − o(1):

  **Π_{ω,ℓ}(𝐡(θ − θ\*) > 2M·k′ | y) → 0,**

i.e. the Huber loss of the fixed-tuning posterior contracts at **ℓ^{−1/3}(log n)^{1/6}**, the small-ball rate, for every scale and every ℓ ≥ polylog. (Theorem H gave ℓ^{−2/7}.)

*Proof.* Work on K_H (Theorem H gives Π_{ω,ℓ}(K_Hᶜ | y) → 0) and on Ω_CA ∩ Ω_clip. Let J := ⌊(f²/32)·M·k′⌋, h ≈ m/J, and P_H, t = Sᵀ(I − P_H)ψ as in Theorem H and C2.
1. *Pathwise lower bound.* By the clip inequality and Lemma CA applied to δ^c, and (f/2)‖δ^c‖² + fL‖v‖₁ = f·𝐡(δ): **ℛ(δ) ≥ −⟨ψ, δ^c⟩ + (1 − η)·f·𝐡(δ) − o(k)** for all δ ∈ K_H.
2. *Score on the excess.* ⟨ψ, v⟩ = ∫_L^∞[Σ_{δᵢ≥t}ψᵢ − Σ_{δᵢ≤−t}ψᵢ]dt and |Σ_{i∈J′}ψᵢ| ≤ √(3|J′| log n) for all intervals J′ (Hoeffding, n² events). As in §4.5: |⟨ψ, v⟩| ≤ η·fL‖v‖₁ + (C log n/(ηfL))(TV₁(δ) + ‖δ‖∞) = η·fL‖v‖₁ + o(k).
3. *Coarse score.* ⟨ψ, δ⟩ = ⟨P_Hψ, δ⟩ + ⟨t, u − u\*⟩, and as in Lemma WH, |⟨P_Hψ, δ⟩| ≤ ‖P_Hψ‖₂·(2𝐡)^{1/2} + ‖P_Hψ‖∞·2𝐡/L ≤ (2J𝐡)^{1/2} + η·f·𝐡 on the events {‖P_Hψ‖₂² ≤ J} (C2 §3.3) and {‖P_Hψ‖∞ ≤ 3(2 log(2n)/h)^{1/2}} (Hoeffding and Lemma Lev; the last is ≤ ηfL/2 since h → ∞ faster than log n).
4. *Shell.* Combining 1–3 with ⟨ψ, δ^c⟩ = ⟨ψ, δ⟩ − ⟨ψ, v⟩: on the shell 𝐡(δ) ∈ (a·k′, 2a·k′], a ≥ M,

   −ωℛ(δ) ≤ ω⟨t, u − u\*⟩ + ω(4J·a·k′)^{1/2} − ω(1 − 3η)f·a·k′ + o(k) ≤ ω⟨t, u − u\*⟩ − ω(f/2)·a·k′ + o(k),

   since (4J·a·k′)^{1/2} ≤ (f/2.8)·a·k′ for a ≥ M. No Cauchy–Schwarz is needed, because the remainder is controlled pathwise.
5. *Fine score.* Integrate c over the section (polynomial volume) and u against Π_ℓ: the exact Laplace MGF gives ∏ⱼ(1 − ω²tⱼ²/ℓ²)^{−1}, with log ≤ 2ω²·m·t_∞²/ℓ² ≤ C·ω²·k′/M⁵ on {‖t‖∞ ≤ t_∞ = 2.85h^{5/2}(2 log 2m)^{1/2}} (Lemma F′), and ω·t_∞/ℓ ≍ ℓ^{−1/6}(log n)^{1/2} → 0. The truth shift is ≤ ω·t_∞V/n² = o(k′) for ℓ ≤ n².
6. *Denominator.* Theorem H §6.3 at the point mass: Z̃_ω(ℓ) ≥ V₃(ε√n/2)³exp{−(1 + ω(1.25C₁ + 1))k′ − 6 − 2V} on Ω_D.
7. *Sum over dyadic shells* a = 2^jM up to the body's level: the ratio is ≤ Σ_j poly(n)·exp{−[ω(f/2)2^jM − 1 − ω(1.25C₁ + 1) − Cω²/M⁵ − o(1)]k′} → 0 for M ≥ M₀. ∎

**Corollary (sup-norm of the fixed-tuning posterior).** On {𝐡(δ) ≤ 2Mk′, TV(δ) ≤ T₀}, the Huber form of L10-I gives ‖δ‖∞ ≤ 6η_H^{1/2} + 7.06·η_H^{2/5}T₀^{1/5} with η_H ≤ C·M·ℓ^{−1/3}(log n)^{1/6}, provided η_H^{2/3}T₀^{1/3} ≍ n·ℓ^{−5/9}·polylog is small. Hence

  **for ℓ ≥ C·n^{9/5}·polylog: Π_{ω,ℓ}(‖θ − θ\*‖∞ > s_n | y) → 0 with s_n ≍ n^{3/5}ℓ^{−1/3}·polylog → 0. In particular (SN) holds.**

**Consequence: Theorem LO″.** By Theorem LO-low, the LO bound (β < 6) holds for every **ℓ ≥ C·n^{9/5}·polylog** (≈ n^{1.80}), with Theorem H as the localizer for ℓ ≤ n² and C1 above (C1 with W′ on (n², n^{23/11}), audited C1 beyond; alternatively Theorem H extends to ℓ ≤ c·n^{9/4}, where its L4 shift cost 2ℓV/n² is still o(k); not rewritten). Lemma 1 and C1's sup-norm window are no longer the binding conditions; the Huber-form interpolation inequality is.

**Uniformity on the new range — SKETCH.** Theorem LO″ is a fixed-(ω, ℓ) statement. To extend Theorem U (and U-σ) from n^{21/11} down to n^{9/5}, the node events of Theorem H-sharp must fail with probability n^{−c}, not 1/J or 1/k′: use Hanson–Wright for ‖P_Hψ‖₂² (in place of Chebyshev) and Bernstein for the Jensen variable of the denominator (in place of Chebyshev; its summands are bounded by the sup-norm of the good set, which gives e^{−c√k′}); Theorem H's Markov event is taken on dyadic panels with K_n ≫ log n as in Theorem U. Not written out.

*Checks made.* The identity (f/2)(x^c)² + fL|x − x^c| = f·h_L(x); the cancellation in step 4 (the score on v is absorbed by η·fL‖v‖₁, the score on δ^c is split as in C2); the exponent in the corollary: η_H^{2/5}T₀^{1/5} = ℓ^{−2/15}·(Tn³/ℓ)^{1/5} = T^{1/5}n^{3/5}ℓ^{−1/3}. *Not re-derived:* the constant in the MGF bound of step 5 (it follows C2 §3.4 with λ ≥ a₁n^{5/2}/V replaced by the fixed ℓ and Dₙ by k′), and Theorem H's cones, which are used as audited.

---

## 5. The remaining hypothesis (SN), and tools toward it

**(SN)** at (ω, ℓ): Π_{ω,ℓ}(‖θ − θ\*‖∞ > L | y) ≤ ¼, L the constant of (A2). By §4.6 it holds for ℓ ≥ C·n^{9/5}·polylog; it is open only for n^{26/17} ≤ ℓ < n^{9/5}, where even the sharp-rate body does not bound the sup-norm. It is used in one place: the quadratic margin M(δ) ≥ (f/2)‖δ‖₂². It is a statement about the fixed-tuning posterior, at a **constant** level; the typical size of the fit there is ℓ^{−1/6}.

### 5.1 A sufficient condition by log-concavity — PROVED

At fixed (ω, ℓ) the posterior density of θ is ∝ exp{−ωQ(θ) − ℓ‖Dθ‖₁}, log-concave on ℝⁿ; its one-dimensional marginals are log-concave (Prékopa), and a log-concave real X with mean μ and standard deviation ς has P(|X − μ| > tς) ≤ e^{1−t}. Hence, with [·] the posterior mean:

  **if maxᵢ[δᵢ²] ≤ L²/(3 log n)², then Π_{ω,ℓ}(‖δ‖∞ > L | y) ≤ e²·n^{−2}.**

(P(|δᵢ| > L) ≤ e²·e^{−L/√m̄} with m̄ the bound on [δᵢ²]; union over i.) So (SN) follows from a pointwise posterior second-moment bound at the level 1/(log n)², against a typical value ℓ^{−1/3}.

### 5.2 Translation, and "no long plateaus" — PROVED

Write the posterior as ∝ e^{−Φ(δ)}dδ, Φ(δ) := ωℛ(δ) + ℓ‖D(θ\* + δ)‖₁.

**Translation lemma.** For every data vector, every fixed b ∈ ℝⁿ and g > 0: **Π_{ω,ℓ}(Φ(δ) − Φ(δ − b) ≥ g | y) ≤ e^{−g}.** (∫1{Φ(δ) − Φ(δ − b) ≥ g}e^{−Φ(δ)}dδ ≤ e^{−g}∫e^{−Φ(δ−b)}dδ.)

For a finite family of templates, a posterior draw cannot be improved by more than g by subtracting any of them, except with probability |family|·e^{−g}. No body and no entropy are involved.

**Corollary T1.** Let 0 < s ≤ L and w an integer with w³ ≥ 16C_β·ℓ/(ωf·s) and s√w ≥ (8/f)√(log(4n²)). On a data event of probability ≥ 1 − 1/n:

  **Π_{ω,ℓ}(some run of 5w/4 consecutive indices has δ ≥ s throughout, or δ ≤ −s throughout | y) ≤ 8·e^{−ωf·s²w/32}.**

*Proof.* Intervals I of length w on a grid of step ⌈w/4⌉; b_I := (s/2)β_I with β_I a fixed smooth bump (1 on the middle half of I, 0 outside, ‖Dβ_I‖₁ ≤ C_β/w²). If δ ≥ s on I, then δ − b_I ≥ s/2 on I, and by convexity of each Xᵢ: ℛ(δ) − ℛ(δ − b_I) ≥ Σᵢb_{I,i}(1{Zᵢ < s/2} − τ) ≥ (f·s/2)‖b_I‖₁ − |⟨ζ, b_I⟩|, ζᵢ := 1{Zᵢ < s/2} − Fᵢ(s/2) a fixed centred bounded vector. ‖b_I‖₁ ≥ sw/4; by Hoeffding and a union over the ≤ 8n/w templates, |⟨ζ, b_I⟩| ≤ f·s²w/16. The prior part is ≥ −ℓ‖Db_I‖₁ ≥ −ωf·s²w/32. So Φ(δ) − Φ(δ − b_I) ≥ ωf·s²w/32; apply the translation lemma. ∎

**Reading.** Draws do not stay above a level s for longer than ≍ (ℓ/s)^{1/3}, for every s ≥ C(log n)^{3/5}ℓ^{−1/5}, at every tuning. At s = L/2: no plateau above L/2 longer than ≍ ℓ^{1/3}.

### 5.3 What (SN) still needs — OPEN

By T1, a coordinate with |δᵢ| > L sits in a peak above L/2 of width ≲ ℓ^{1/3}, the wavelength. To exclude such peaks:
- *Narrow peaks (width ≲ c(ℓL)^{1/3}) — SKETCH.* Their own third-difference mass exceeds the background in the window, so subtracting a matching template lowers the prior term (‖u‖₁ − ‖u − Db‖₁ ≥ ‖Db‖₁ − 2‖(u − Db)_W‖₁), by more than the entropy of a net of peak shapes when w³ ≲ ℓL. With the translation lemma this should exclude them.
- *The remaining band of widths* between c(ℓL)^{1/3} and C(ℓ/L)^{1/3} is a constant factor (times a power of log n) wide at constant level L. Both gains (likelihood and prior) are of the same order there; a template family at the wavelength scale using both is the natural attempt. Not done.
- *Alternative:* the pointwise second-moment bound of §5.1, e.g. by a maximum principle across windows (boundary layer of length ≍ ℓ^{1/3}); or Lemma WA below plus control of sub-wavelength fluctuations.
- *A route through the Gaussian comparison measure — SKETCH.* By §4.5, on K_H the true integrand is at most e^{3ωηk} times the "Huber" integrand exp{ω⟨ψ, δ^c⟩ − (a/2)‖δ^c‖² − aL‖v‖₁}, which coincides with the Gaussian integrand wherever ‖δ‖∞ ≤ L. Under the Gaussian comparison measure (the explicit scale mixture of §3.1), conditionally on typical variances, δ is Gaussian with covariance C_V = a^{−1}(I − DᵀH_V^{−1}D). Two facts are within reach: the pointwise variance is (C_V)ᵢᵢ ≤ C·c₀^{1/6}·k/(a·n) (posterior variance ≤ risk of a local quadratic fit over a window of the wavelength, in the dominating homogeneous model), and the pointwise mean is small by |eᵢᵀC_Vψ| ≤ ((C_V)ᵢᵢ·ψᵀC_Vψ)^{1/2} with the fixed quadratic form of §3.4. So one coordinate exceeds L with comparison-probability ≲ exp{−c·n/k^{6/5}}, while the evidence ratio to be beaten is only e^{Ck}. This wins when k^{11/5} ≪ n, i.e. **ℓ ≳ n^{18/11}** (≈ n^{1.64}). What is not done: the sum over sets of exceeding coordinates (a cluster expansion; long runs must be handled by the run-averaged margin of §4.5, not coordinate by coordinate). If completed, this would give (XS) unconditionally on [n^{18/11}, n^{21/11}].

- *The cleanest target: local versions of the two body bounds — SKETCH.* The corollary of §4.6 loses because it uses the global third-order variation T₀ in one window. If, uniformly over windows W of length w ≍ ℓ^{1/3}·polylog, the posterior had (i) Huber energy ≤ C·(w/n)·k′ on W and (ii) third-difference mass ‖u_W‖₁ ≤ C·w/ℓ (both are the typical values), then L10-I applied on each window (rescaled) would give ‖δ‖∞ ≲ w^{3/5}·ℓ^{−1/3}·polylog = ℓ^{−2/15}·polylog → 0 **for every ℓ**, hence (SN) on the whole range. So (SN) below n^{9/5} is equivalent, in practice, to making Theorem H-sharp and the roughness bound local.

**Lemma WA (window averages) — identity PROVED.** If the densities are bounded by f̄₊ everywhere, then for every v ∈ ℝⁿ, with Gᵢ := Fᵢ − τ, Ỹ_v := ΣvᵢGᵢ(δᵢ), ξ_v := Σvᵢ(1{Zᵢ < δᵢ} − Fᵢ(δᵢ)):

  [Ỹ_v²]^{1/2} ≤ [ξ_v²]^{1/2} + ℓ‖Dv‖₁/ω + (f̄₊/ω)^{1/2}‖v‖₂.

(Integration by parts of e^{−Φ} in the direction v against Ỹ_v: [∂_vΦ·Ỹ_v] = [Σvᵢ²pᵢ(δᵢ)], ∂_vΦ = ω(Ỹ_v + ξ_v) + ℓ⟨sign(u), Dv⟩.) For a bump of width w the prior's pull ℓ/(ωw³) is small once w ≫ ℓ^{1/3}; the term [ξ_v²] needs an entropy bound for indicator classes that is not in-house (SKETCH).

**(SN) is measurable.** maxᵢ|θᵢ − θ\*ᵢ| over draws at fixed λ, or maxᵢ E[(θᵢ − θ\*ᵢ)² | y], are by-products of the fixed-λ chains used for κ̂. UNTESTED.

---

## 6. Recommendation

1. **Audit Lemma CA and Lemma LK first** (§4.1–4.2; one page). With them alone Theorem LO no longer needs Lemma 1, and Theorems U / U-σ move from n^{99/43} to n^{23/11} (audited C1) or n^{21/11} (C1 with W′).
2. **Audit §3** (Lemma 2b″ and the classes of §3.5). It is what allows the window to go below n^{23/11} at all; above n^{23/11}, §1–2 suffice.
3. **Audit §4.5–4.6** (clip inequality, Theorem H-sharp, the sup-norm corollary). With them the unconditional window is **n^{9/5}**. Theorem H-sharp is also of independent use: it is the sharp-order contraction rate at fixed tuning, at every scale, with no (EM).
4. **L4b in the plan:** on [n^{26/17}, n^{9/5}] replace "the sign is assumed" by "(SN) or (XS) is assumed": a constant-level bound on the fit's excursions for the fixed-tuning posterior, checkable from the κ̂ chains. On the sliver [n^{3/2}, n^{26/17}] the sign stays the named assumption.
5. **Next lemma to attempt:** (XS) below n^{9/5}, by the Gaussian-comparison route or the translation method of §5.3.

## 7. What changed against my gap-4 note

- The amplitude lemma and Lemma 1′ of the gap-4 note are **not needed**: Lemma CA bounds the remainder by the first-order total variation, uniformly over all δ with ‖δ‖∞ ≤ L.
- Obstruction (O1) there (the margin above amplitude s cannot be credited uniformly over the body) was an artefact of bounding the remainder through a function-class supremum. Organized by super-level sets, it can.
- Obstruction (O2) was overstated: with the precision-side form the sandwich reaches n^{26/17} without any eigenvector smoothness. The structural limit n^{3/2} stands.

## 8. Not verified

- Standard facts quoted: lower-tail Bernstein for sums of independent [0, 1]-valued variables; Bernstein for sub-exponential sums and the three-dimensional net; Cramér's bound for exponential sums; Weyl's monotonicity; antitonicity of the inverse; Schur-complement domination; Prékopa's theorem and the tail bound for log-concave real variables; Hanson–Wright and Hoeffding (as in Theorem U); Lemma 2a and the Christoffel constant 9 (audited).
- Lemma LK's constant C₀ (norm equivalence for quadratics on w + 1 points, uniformly in w) is asserted, not computed. Condition (R) is stated with it.
- §2, §3.5–3.6 and §4.4 are substitutions into the audited §4.1 and §4.5 of the three-lemmas note and into Theorem U §2.3 and §3. I checked where the remainder and the mixing variances enter; I did not re-read the audited texts after their fixes. In particular the claim "Theorems U and U-σ hold on the same window" was checked at the level of which events are needed (Ω_CA is ω- and ℓ-free, so no panels are needed for it), not line by line.
- §3.2: the constants 48, 110, 36, 610 were computed once by hand and are not tight. §3.4–3.5: unnamed constants C, C₂.
- Lemma CA: the grid step and the union bound (2n⁴ events at level n^{−5}) are as written; the case of an atom of Zᵢ exactly at a grid level is covered by monotonicity. I did not treat levels t > L (not needed when ‖δ‖∞ ≤ L).
- §3.7, the weighted version, and §5.3 are sketches.
- No numerics. Cheap checks: Lemma CA on simulated data (R against (1 − η)M − (3 log n/η)(TV₁ + 2L) for smooth and for wiggly δ); the identities of §3.1 on a small example; Lemma 2b′.

---

## Theory response (2026-11-23, 16:15 CT)

**Status: L4b is PROVED (one pass), UNAUDITED, down to n^{9/5}.** It is reduced to one constant-level hypothesis, (SN)/(XS), on [n^{26/17}, n^{9/5}]. The sliver [n^{3/2}, n^{26/17}] is SKETCH only. Uniformity is by substitution from n^{21/11}; on [n^{9/5}, n^{21/11}] it is SKETCH. Everything uses the min-density β. The averaged-β̄ version is to be checked against `FABLE_B_averaged_beta.md` §7.

**Checked by Theory: Lemma CA (§4.1) in full.**
- Layer-cake representation of Rᵢ.
- Decomposition into runs of super-level sets.
- The lower-tail bound for sums of independent nonnegative variables has no range term (Maurer-type). At x = √(10·P·log n) it gives n^{−5}, and the union over ≤ 2n⁴ (interval, level, sign) triples gives ≤ 2/n.
- AM–GM: √(10P log n) ≤ ηP + (5/2)log n/η.
- Runs integrate to ≤ TV₁ + 2L.

**Ruling: HOLDS.** This is the key new tool. It removes the need for sup-norm localization in the remainder.

**Not checked:** the precision-side sandwich (§3), Lemma LK's unnamed constant (§4.2), and Theorem H-sharp (§4.6). An Astra audit is requested, in Fable A's suggested order.

## Cross-family audit response (Astra, `reviews/AUDIT_astra_L4b.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES.** All eleven findings are CONFIRMED, and Theory rules that they **HOLD**.

**What is now established (audited):**
- **Fixed-pair LO (β < 6), unconditional.** It holds for ℓ ≥ n^{9/5}, up to logs, at a fixed inverse scale with a strict common lower-secant margin.
- **Conditional extension.** Under (SN) or (XS) it extends down to n^{26/17}, up to logs.
- **Uniform U / U-σ (the posterior band statement).** These now hold down to **n^{21/11}** (with W′) up to logs, improved from n^{99/43}. **Below n^{21/11} only the fixed-pair result holds.** The posterior band exclusion on [n^{9/5}, n^{21/11}] is therefore still open.
- **Lemma CA** holds as stated. **Lemma LK** holds with C₀ = 36, C_LK = 256.

**Fixes (applied by reference; written in full in Tuesday's clean rewrite):**
- **H-sharp is narrowed (finding 8).** It is valid for ℓ/[K⁶(log n)^{27/2}] → ∞, ℓ ≤ n²; the claim "throughout Theorem H's range" is OPEN. This does not affect any polynomial window.
- **Findings 1–7, 9 and 10:** specifications of constants and quantifiers.
  - The sup-norm consequence holds for ℓ/[n^{9/5}(log n)^{1/5}] → ∞.
  - Use C1's numerator cones in the uniform substitution.
- **Finding 11:** the plateau claim (§5.2) needs a template-count condition, g ≥ 2 log(C(n/w + 1)). It does not enter the Occam proof.

**Status of L4b after the audit:**

| Range | Fixed-pair Occam bound | Posterior band exclusion |
|---|---|---|
| [n^{21/11}, n^{99/43}] | AUDITED | **AUDITED (uniform U / U-σ)** |
| [n^{9/5}, n^{21/11}] | AUDITED | OPEN (uniformity) |
| [n^{26/17}, n^{9/5}] | AUDITED conditional on (SN)/(XS) | OPEN |
| [n^{3/2}, n^{26/17}] | SKETCH | OPEN |

All rows are in the min-density version; the averaged-β̄ version is still to be done.

---

## 9. (XS) on [n^{26/17}, n^{9/5}]: two reductions, a net-free comparison lemma, the stopping point

*Appended 2026-11-23, 16:15–16:50 CT, Fable A. Not audited. Read for this section: `FABLE_B_supnorm.md` §11–§13 (Lemmas B1, B3–B7, unaudited). Notation of §4–§5; h := (ℓ/ω)^{1/3} (bandwidth), k = n·ℓ^{−1/3}, k′ = 21.5·(log m)^{1/6}·k, a = ω(1 − η)f, 𝐡 = Σᵢh_L(δᵢ) the Huber loss at level L, v = (|δ| − L)₊sign(δ). "Body" := K_H ∩ {𝐡 ≤ 2Mk′}; its posterior probability → 1 by Theorem H and Theorem H-sharp (audited range).*

### 9.0 Outcome

**(XS) is not proved.** The combination asked for (block spike lemma + translation + no-plateau + H-sharp) stops at an arithmetic obstruction, stated in §9.2. What is new:

| # | Claim | Status |
|---|---|---|
| 1 | The ℓ₁ half of (XS) is free: on the body, the score on the excess is o(k). (XS) reduces to **(XE): Π((f/2)‖v‖₂² > ηk \| y) ≤ ¼** | PROVED given H-sharp (§9.1) |
| 2 | On the body the number of excursion clusters (runs above θL that reach L) is ≤ TV₁(δ)/((1 − θ)L) + 1 = k·ℓ^{−2/21}·polylog. Their entropy is o(k) | PROVED (§9.2) |
| 3 | Block spike + counting + no-plateau + H-sharp bound the widths and the number of excursions, never their height; the count misses the target by the factor M·(log n)^{1/6}/η. They do not give (XE) | PROVED obstruction (arithmetic) (§9.2) |
| 4 | **Deletion lemma:** for any affine projection A of co-rank d, Φ(δ) − Φ(Aδ) is dominated by Gamma(d, 1) under the posterior. No net, no data event. It reproduces Lemma B1 with halved constants and extends the block comparison to every block length | PROVED (§9.3) |
| 5 | **Sparse-shift comparison:** the Huber integrand is a mixture of shifted Gaussian integrands, at a cost of one factor C_x(a, L) per cluster coordinate. C_x < 1 iff **(ML): a·L² > 2/π**. Under (ML), LO-low would hold on [n^{26/17}, n^{9/5}] **with no hypothesis** | pointwise inequality and Gaussian algebra PROVED; assembly SKETCH (§9.4) |
| 6 | Without (ML) the hypothesis becomes a **count**: (XN) the number of coordinates above θL is ≤ ηk/log C_x. The height of excursions no longer matters | SKETCH, same assembly (§9.4) |

### 9.1 The ℓ₁ half of (XS) is free — PROVED given Theorem H-sharp

On the body, L‖v‖₁ ≤ 𝐡(δ) ≤ 2Mk′. In §4.5 the score on the excess was bounded crudely, |⟨ψ, v⟩| ≤ ‖v‖₁. Use instead step 2 of the proof of H-sharp: on the Hoeffding event for interval sums of ψ, for every η₁ ∈ (0, 1],

  |⟨ψ, v⟩| ≤ η₁·fL‖v‖₁ + (C log n/(η₁fL))·(TV₁(δ) + ‖δ‖∞).

Take η₁ := η/(43·f·M·(log m)^{1/6}). The first term is ≤ η₁·f·2Mk′ = ηk. The second is C′(log n)^{7/6}·(TV₁ + ‖δ‖∞) = o(k), because on K_H both TV₁ and ‖δ‖∞ are smaller than k by a power of n (Lemma LK on bodies; L10-I in Huber form). With (a/2)‖δ^c‖₂² + aL‖v‖₁ = a·𝐡(δ), the consequence of §4.5 becomes, for every δ in the body:

  **−ωℛ(δ) ≤ ω⟨ψ, δ⟩ − a·𝐡(δ) + 4ωη·k + o(k) = ω⟨ψ, δ⟩ − (a/2)‖δ‖₂² + (a/2)‖v‖₂² + 4ωη·k + o(k).**

So Theorem LO-low holds under **(XE): Π_{ω,ℓ}((f/2)‖v‖₂² > ηk | y) ≤ ¼**, with 𝒢 := body ∩ {(f/2)‖v‖₂² ≤ ηk} in the halving lemma. On the body #{i : |δᵢ| > L} ≤ 4Mk′/L², so (f/2)‖v‖₂² ≤ (f/2)‖v‖∞²·4Mk′/L², and (XE) follows from the sup-norm bound ‖δ‖∞ ≤ L + ϑₙ, ϑₙ := L·(η/(43·f·M·(log m)^{1/6}))^{1/2}, with posterior probability ≥ ¾. (XE) cannot be weakened inside the Gaussian comparison: the true integrand e^{−a𝐡} is **larger** than the Gaussian one e^{−(a/2)‖δ‖²} wherever |δᵢ| > L. §9.4 changes the comparison instead.

### 9.2 What the block spike lemma, the no-plateau lemma and H-sharp give together

All statements are for δ in the body, on the data events already named.

(a) **Count — PROVED.** #{i : |δᵢ| > L/2} ≤ 16Mk′/L².

(b) **Clusters — PROVED.** Fix θ ∈ [½, 1). A *cluster* is a maximal run of indices with δᵢ > θL (or < −θL) that contains an index with |δᵢ| > L. Each interior cluster rises by (1 − θ)L and falls by (1 − θ)L on disjoint edges, so

  **R(δ) := #clusters ≤ TV₁(δ)/((1 − θ)L) + 1 ≤ C·T^{1/3}r^{2/3}·k/((1 − θ)L) = k·ℓ^{−2/21}·polylog** (Lemma LK on K_H).

The number of sign-labelled unions of ≤ R intervals is ≤ (2en)^{2R} = e^{o(k)}. So **the positions of the excursions cost nothing; only the coordinates inside them do.**

(c) **Width — PROVED (T1, with the audit's template-count condition).** With posterior probability → 1 no cluster at θ = ½ is longer than (5/4)·w_T, w_T := (32C_β·ℓ/(ωfL))^{1/3} = C_T·h.

(d) **Shape on most blocks — PROVED, deterministic.** For a block I of length g and the quadratic q_I through the three points to its left, Newton's formula (Fable B, Lemma B1, step 1) gives pathwise max_{i∈I}|θᵢ − q_{I,i}| ≤ ((g + 1)²/2)·‖(Dθ)_{𝒥_I}‖₁. With Lemma B6 (counting on Theorem H's body): all but a fraction 2T/K₂ of the blocks of length g = εh have |δ − (quadratic)| ≤ (K₂/2 + o(1))·ε³/ω on the block. This needs no conditional statement. Lemma B1 adds the conditional tail given the boundary, which matters only for the exceptional blocks.

(e) **Why this does not give (XE) — PROVED arithmetic.**
- *Energy bounds counts, not heights.* By (a) there are at most 16Mk′/(L²w) clusters of width ≥ w at θ = ½. For w ≍ h that is a fraction ≍ M(log n)^{1/6}/(L²h) of the bandwidth windows. Each may carry excess energy (height − L)²·w, and none of the four tools bounds the height (K_H bounds it by a power of n only).
- *If the heights were ≤ A·L:* ‖v‖₂² ≤ (A − 1)²L²·#{|δᵢ| > L} ≤ 4(A − 1)²Mk′. This is ≤ 2ηk/f only for A − 1 ≲ (η/(M(log n)^{1/6}))^{1/2}. So (XE) is in practice the sup-norm statement at level L(1 + c(log n)^{−1/12}); it is not weaker than (SN) in kind.
- *Translation is blind to the height.* Removing a matching template of height H − L and width w from a peak gains ω·f·L·(H − L)·w in the likelihood (the loss is linear above L) and costs at most ℓ·C_β(H − L)/w² in the prior. The height cancels: the exclusion holds iff w³ ≥ C·ℓ/(ωfL), which is T1. A taller peak of the same width is not less likely by this argument.
- *The block spike lemma* bounds the deviation from the minimal-roughness interpolant given the boundary cost. The height of the interpolant is not bounded (Fable B's F1), and the roughness budget T·n/ℓ allows a fraction ≍ T/(ωL) of the bandwidth windows to carry a peak of height L and width h. That fraction is a constant.
- *The band.* T1 excludes widths > C_T·h. The prior excludes widths < c·(ℓL)^{1/3} only given the boundary cost. On [c(ℓL)^{1/3}, C_T·h], a constant factor wide in units of h, the likelihood and prior terms have the same order.

So the count of excursion coordinates is within the factor M·(log n)^{1/6}/η of what is needed, and the heights are not controlled at all. §9.4 removes the heights from the problem.

### 9.3 The deletion lemma — PROVED

Φ is the convex potential of §5.2 (in δ or, equivalently, in θ).

**Lemma D (deletion).** Let A be an affine map of ℝⁿ with A∘A = A, and d := n − dim(fixed space of A). For every data vector and every λ ∈ [0, 1):

  **E[e^{λ(Φ(δ) − Φ(Aδ))} | y] ≤ (1 − λ)^{−d},  hence  Π_{ω,ℓ}(Φ(δ) − Φ(Aδ) ≥ 2d + t | y) ≤ e^{−t/2}.**

*Proof.* T_λ := (1 − λ)I + λA is affine; its linear part has eigenvalue 1 on a space of dimension n − d and 1 − λ on a complement, so |det| = (1 − λ)^d. By convexity Φ(T_λδ) ≤ (1 − λ)Φ(δ) + λΦ(Aδ), i.e. λ(Φ(δ) − Φ(Aδ)) ≤ Φ(δ) − Φ(T_λδ). And E[e^{Φ(δ) − Φ(T_λδ)} | y] = ∫e^{−Φ(T_λδ)}dδ/∫e^{−Φ} = (1 − λ)^{−d}. Take λ = ½: the probability is ≤ 2^d·e^{−d − t/2} ≤ e^{−t/2}. ∎

*Variants, same proof.* (i) Conditional: if A changes only the coordinates in W and, for each value of θ_{Wᶜ}, is an affine idempotent in θ_W (for instance θ_W ↦ any measurable function of θ_{Wᶜ}), the bound holds conditionally on θ_{Wᶜ}, with d ≤ |W|. (ii) Cutoff: for χ ∈ [0, 1]ⁿ, Φ(δ) − Φ((1 − χ)δ) is dominated in the same sense with d replaced by ‖χ‖₁ (since ∏(1 − λχᵢ) ≥ (1 − λ)^{‖χ‖₁}).

*Against the translation lemma.* The translation lemma compares δ with δ − b for one fixed b, and a family of templates costs its cardinality. Lemma D compares δ with its image under a projection, simultaneously for all δ, and costs the co-rank. The amplitude of the deleted component is free.

**Corollary D1 (blocks of every length).** For every block W of length g, with θ′_W a minimal-roughness interpolant of the outside, F_W and ρ_W as in Lemma B1, and Q_W the loss on W: conditionally on θ_{Wᶜ}, with probability ≥ 1 − e^{−t/2},

  **ω[Q_W(θ_W) − Q_W(θ′_W)] + ℓ[F_W(θ_W) − ρ_W] ≤ 2g + t.**

- For **any** g: the draw's loss on the block exceeds the interpolant's by at most (2g + t)/ω. There is no restriction to sub-bandwidth blocks and no factor e^{2ℓρ}.
- For g(g + 1)² ≤ ℓ/(ωk̄): with N := ‖𝖣(θ_W − θ′_W)‖₁ ≤ F_W + ρ_W and ωk̄‖θ_W − θ′_W‖₁ ≤ (ℓ/2)N, the display gives ℓN ≤ 4ℓρ_W + 4g + 2t, hence **‖θ_W − θ′_W‖∞ ≤ (g + 1)²·(2ρ_W + (2g + t)/ℓ)** with conditional probability ≥ 1 − e^{−t/2}. This is Lemma B1 with its constants halved (B1 at the same probability gives (g + 1)²(4ρ_W + (3.6g + t)/ℓ)). It is an independent proof of B1.

**Corollary D2 (low rank).** For a linear projection P of rank d: Π(Φ(δ) − Φ(δ − Pδ) ≥ 2d + t | y) ≤ e^{−t/2}. With P the projection onto splines of knot spacing K·h supported in a window W (d ≈ |W|/(Kh)), this is the **local** analogue of the evidence comparison in Theorem H-sharp, with cost 2d + t in place of the global denominator bound e^{−Ck′}. That is what target (i) of §5.3 (local Huber energy ≤ C(|W|/n)k′) needs. What is missing to conclude is the pathwise lower bound Φ(δ) − Φ(δ − Pδ) ≥ c·ω·f‖Pδ‖₂² − (score and roughness terms) on the window. It needs a two-sided form of Lemma CA for the difference ℛ(δ) − ℛ(δ − Pδ) and the quadratic regime on W. Not done.

### 9.4 The sparse-shift comparison — inequality PROVED, assembly SKETCH

**Pointwise inequality — PROVED.** For θ ∈ [½, 1), x ≥ θL and c_θ := ∫₀^∞e^{−a((1−θ)L·z + z²/2)}dz = a^{−1/2}·𝗆((1 − θ)L√a), 𝗆 the Mills ratio:

  **e^{−a·h_L(x)} ≤ c_θ^{−1}·∫₀^∞e^{−(a/2)(x − z)² − aL·z}dz.**

(For x > L put z = x − L + s: the exponent is a·h_L(x) + a·s²/2, and ∫_{s ≥ −(x−L)}e^{−as²/2}ds ≥ (π/(2a))^{1/2} ≥ c_θ. For θL ≤ x ≤ L: (x − z)²/2 + Lz = x²/2 + z(L − x) + z²/2 ≤ x²/2 + (1 − θ)L·z + z²/2.) Symmetrically for x ≤ −θL with z ≤ 0.

**Consequence — PROVED.** Outside the clusters |δᵢ| ≤ L, so h_L(δᵢ) = δᵢ²/2 there. For δ with cluster set S(δ) (level θ) and cluster signs: e^{−a𝐡(δ)} ≤ c_θ^{−|S|}∫e^{−(a/2)‖δ − z‖₂² − aL‖z‖₁}dz_S, the integral over z supported on S with the cluster signs. Summing over the admissible sets (≤ (2en)^{2R} of them, §9.2(b)) removes the dependence of S on δ.

**Shifted Gaussian integral — PROVED algebra.** The prior is centred at the truth as in §3 (cost e^{ℓ‖Dθ\*‖₁} = e^{o(k)}), so the comparison measure has no offset. For fixed variances V, with C_V = a^{−1}(I − DᵀH_V^{−1}D) (0 ⪯ C_V ⪯ a^{−1}I) the comparison covariance of §5.3 and m_V := ω·C_Vψ its mean:

  ∫e^{ω⟨ψ,δ⟩ − (a/2)‖δ − z‖²}dN_V(δ) = [the same at z = 0]·exp{a⟨z, m_V⟩ + (a²/2)zᵀC_Vz − (a/2)‖z‖²} ≤ [the same at z = 0]·e^{a‖z‖₁·‖m_V‖∞}.

So if ‖m_V‖∞ ≤ m̄ < L, the z-integral over each cluster coordinate is ≤ 1/(a(L − m̄)), and each cluster coordinate costs the factor

  **C_x := [c_θ·a·(L − m̄)]^{−1} = [√a·(L − m̄)·𝗆((1 − θ)L√a)]^{−1}.**

As θ → 1 and m̄ → 0 this is (2/(π·a·L²))^{1/2}. **C_x ≤ 1 iff (ML): a·L² > 2/π ≈ 0.64** (with θₙ = 1 − 1/log n the cluster count of §9.2(b) is still o(k/log n)).

**What this would give — SKETCH.** On the body, by §9.1 and the two displays:

  Z̃ restricted to the body ≤ e^{4ωηk + o(k)}·(2en)^{2R}·max(1, C_x)^{N}·[the Gaussian comparison integral of §3],

N the largest number of cluster coordinates on the good set. Hence:
- **Under (ML): no hypothesis.** Theorem LO-low would hold on [C·n^{26/17}polylog, n^{9/5}] for every ω with β < 6 and ω(1 − η)f·L² > 2/π, for any admissible pair (L, f) of (A2). T1 and (XE) are not used.
- **Without (ML):** the hypothesis is **(XN): Π_{ω,ℓ}(#{cluster coordinates at level θ} > ηk/log C_x | y) ≤ ¼**. It is implied by an **average pointwise** bound, (1/n)·ΣᵢΠ(|δᵢ| > θL | y) ≤ η·ℓ^{−1/3}/(8 log C_x) (Markov). On the body the count is ≤ 4Mk′/L² = 86M(log m)^{1/6}·k/L² (§9.2(a)): the same factor M(log n)^{1/6}/η as in §9.2(e), but now for a **count**, with no sup-norm and no height.

**Unverified steps of the assembly.**
1. ‖m_V‖∞ ≤ m̄ → 0 on every variance class of §3.5. On each class H_V ⪯ (fixed envelope), so (C_V)ᵢᵢ and ψᵀC_Vψ are bounded by fixed quantities and |m_{V,i}| ≤ ω((C_V)ᵢᵢ·ψᵀC_Vψ)^{1/2}. On the typical class, with item 2 and the gain bound ψᵀC_Vψ ≤ C·κ/ω² of §3.4, this is ≲ k/√(a·n) → 0 for ℓ ≫ n^{3/2}. On the max-variance classes (2^i > c₀ ≍ κ^{6/5}) the same bound is ≲ κ·2^{i/6}/√n, which is not small below ℓ ≈ n^{7/4}; there the z-integrals must be truncated (‖z‖₁ ≤ C·k′ on the body) and the cost e^{C·k′·κ·2^{i/6}/√n} set against the class probability e^{−2^{i−1}}. The exponents compare correctly when k′ ≪ √n (true on the window). On those classes the truncated z-integral is bounded by its volume, at most e^{C·k′·log n}, which the class probability e^{−κ^{6/5}/2} also absorbs. The classes of rows 2–3 of §3.5 have probability only e^{−C·κ}, so there the mean bound itself is needed, with the envelope constants 2^{i/6}. Not written.
2. The pointwise variance — SKETCH, constant not computed. (C_V)ᵢᵢ is the posterior variance of δᵢ in the Gaussian model with noise variance 1/a and prior variances V on Dδ, so it is at most the Bayes risk of any linear estimator that is exact on quadratics. The local quadratic fit on a window of length w′ gives (C_V)ᵢᵢ ≤ 9/(a·w′) + C·w′⁴·Σ_{j∈window}Vⱼ (Lemma Lev for the noise part; Newton's formula for the bias, with coefficients ≤ C·w′²). On the local-sum events of §3.2, Σ_{window}Vⱼ ≤ c₊·w′·v₁, and w′ ≍ h gives (C_V)ᵢᵢ ≲ k/(a·n). This must be done directly, as here: the operator envelope of Lemma 2b″ would add a term of order ε/a to the diagonal, which is too large.
3. That shifting the score leaves the determinant factors of §3 unchanged is exact; that the gain bounds of §3.4 are used only through ψᵀC_Vψ was checked from the statement, not line by line.

**Hand example, unchecked (Gaussian noise, τ = ½, unit scale).** L = 1: f = 0.341, (ML) reads ω > 1.9, and β < 6 reads ω < 8.2. L = 3: 0.43 < ω < 4.0. L = 0.45: 8.2 < ω < 9.3. So admissible pairs (L, f) cover ω up to about 9.3, against the min-density threshold 9.6. Small ω is covered by large L.

### 9.5 The precise stopping point

1. **(XS) ⇐ (XE)** (§9.1, PROVED): only the energy of the excess above L is at stake.
2. **B1 + T1 + translation + H-sharp do not give (XE)** (§9.2, PROVED arithmetic): they bound the widths and the number of excursions, not their heights, and the count is off by M(log n)^{1/6}/η. The gap is the band of widths [c(ℓL)^{1/3}, C_T·h], where the prior and the likelihood terms have the same order and both are linear in the height.
3. **The first open step is step 1 of the assembly in §9.4**: the sup-norm of the comparison mean m_V on the atypical variance classes, with truncated shifts. If it holds, L4b on [n^{26/17}, n^{9/5}] is unconditional for a·L² > 2/π and conditional on the count (XN) otherwise.
4. **For (XN) without (ML), or for (XE)**, a localization at the bandwidth scale is needed. I state it as a hypothesis and do not attempt it (Fable B's parallel piece):

   **(FG) forgetting in probability.** For all but a fraction η·ℓ^{−1/3}·(log n)^{−C} of the coordinates i, the posterior mean and standard deviation of δᵢ satisfy |[δᵢ]| ≤ L/4 and sd(δᵢ) ≤ L/(8 log n).

   **(FG) ⇒ (XN) — PROVED** (log-concave marginals, §5.1: Π(|δᵢ| > θL | y) ≤ e²·n^{−2} on those coordinates; Markov on the rest). The second-moment bound in expectation that H-sharp suggests gives (FG) with (log n)^{+C} in place of (log n)^{−C}. Lemma D (Corollary D2) is the tool I would use for the local energy half; Fable B's B3–B5 for the level.

### 9.6 Flags

- Lemma D and Corollaries D1–D2 are new and short. Check: the determinant of T_λ, and that the conditional variant needs only log-concavity of the conditional density.
- §9.1 uses Theorem H-sharp in its audited (narrowed) range.
- §9.4 is the item to audit first. The pointwise inequality and the Gaussian algebra are elementary; the assembly is a sketch and the (ML) threshold 2/π depends on m̄ → 0.
- The hand example in §9.4 and all constants in §9.2(e) are by hand, once.
- **UNTESTED.** No numerics. Cheap checks from fixed-λ draws: the cluster count R and the number of cluster coordinates N against k (for (XN)); the Gamma(d, 1) domination of Corollary D1 on a few blocks (an exact sampler check); the largest posterior mean |[δᵢ]| and sd for (FG). Pilot cost: one fixed-λ chain per ℓ on the existing κ̂ runs.

## Theory response to §9 (2026-11-23). Fable A's final status today.

**Status: (XS) on [n^{26/17}, n^{9/5}] is OPEN. §9 is UNAUDITED.**

**PROVED (unaudited):**
- (XS) reduces to (XE), an energy bound on the excess. This uses the H-sharp body, which the audit restricted to its corrected polylog floor.
- An obstruction: the existing tools bound widths and counts, never heights.
- **Lemma D (deletion).** Φ(δ) − Φ(Aδ) is dominated by Gamma(d, 1), with no net and no data event.

**SKETCH:** a sparse-shift comparison. It would make L4b unconditional on this range when a·L² > 2/π.

**Stopping point:** the sup-norm of the comparison mean on the atypical variance classes. (FG), forgetting in probability, is the shared missing input with Fable B's sup-norm program (`FABLE_B_supnorm.md` §§12–16).

**Fable A final status today:** L4b is cross-family audited, and the posterior band exclusion reaches n^{21/11} (1af9f8b). The fixed-pair Occam bound holds to n^{9/5}. §9 is committed and unaudited.

---

## 10. Assembly of the sparse-shift comparison

*Appended 2026-11-23, 16:33–16:50 CT, Fable A. Not audited. Notation of §3 and §9: f′ = (1 − η)f, a = ωf′, ϱ = a·v₁, κ = ϱ^{1/6}n/π, G_V := I − DᵀH_V^{−1}D = a·C_V (0 ⪯ G_V ⪯ I), μ_V := G_Vψ/f′ the comparison mean of δ given V, shift vector s (called z in §9.4), B_n the sup-norm bound of the body, B_n ≍ n^{3/5}ℓ^{−1/3}·polylog (corollary of §4.6).*

### 10.0 Outcome

| # | Claim | Status |
|---|---|---|
| 1 | Exact shift identity in the precision-side formula of §3.1; per-V ratio ≤ e^{a⟨s, μ_V⟩} | PROVED (§10.1) |
| 2 | Pointwise variance without eigenvectors: (G_V)ᵢᵢ ≤ 9/w′ + 4a·w′⁴·Σ_{j∈window}Vⱼ for every V and every window length w′ | PROVED (§10.2) |
| 3 | On the typical class (and row 2 of §3.5): ‖μ_V‖∞ ≤ C·κ/(f′√n) → 0 for ℓ ≫ n^{3/2} | PROVED given the score events of §3.4 (§10.3) |
| 4 | Truncated pointwise inequality (shifts in [0, 2B_n]) with the same constant c_θ(1 − o(1)) | PROVED (§10.4) |
| 5 | **Atypical classes close by truncation iff k′·κ·B_n ≪ n, i.e. ℓ ≫ n^{8/5}·polylog** | SKETCH: every inequality is written; exponents done once by hand (§10.4) |
| 6 | **Conclusion:** under (ML) a·L² > 2/π (strict), Theorem LO-low holds on **[C·n^{8/5}·polylog, n^{9/5}] with no hypothesis**. With §4.6 the fixed-pair LO bound is then unconditional for ℓ ≥ n^{8/5} | SKETCH (rests on 5) |
| 7 | **The inequality that fails on [n^{26/17}, n^{8/5}]:** k′·κ·B_n ≤ n^{1−c}. It is a truncation cost on the atypical classes only | named (§10.5) |
| 8 | (ML) holds in the paper's Gaussian cells at τ = 0.5 and τ = 0.25 / 0.75, at the learned scale, for a range of admissible L | hand-computed, UNTESTED (§10.6) |

### 10.1 The exact shift identity — PROVED

Centre the prior at the truth (e^{−ℓ‖u‖₁} ≤ e^{ℓ‖u\*‖₁}e^{−ℓ‖u − u\*‖₁}; cost e^{ℓV/n²} = e^{o(k)}), so that Dz = Dψ/f′ in §3.1. Since ω = a/f′,

  ω⟨ψ, δ⟩ − (a/2)‖δ − s‖² = −(a/2)‖δ − ζ_s‖² + (ω/(2f′))‖ψ‖² + ω⟨ψ, s⟩,  ζ_s := ψ/f′ + s.

So the shifted comparison integral is the formula of §3.1 with pseudo-data ζ_s and the extra factor e^{ω⟨ψ,s⟩}:

  𝒵(s) = (2π/a)^{3/2}e^{(ω/(2f′))‖ψ‖²}·E_V[(det T/det H_V)^{1/2}·exp{−(a/2)(Dψ/f′)ᵀH_V^{−1}(Dψ/f′)}·exp{a⟨s, μ_V⟩ − (a/2)(Ds)ᵀH_V^{−1}(Ds)}].

(The cross term is −ω·sᵀDᵀH_V^{−1}Dψ, and ω⟨s, ψ − DᵀH_V^{−1}Dψ⟩ = a⟨s, μ_V⟩.) The last quadratic is ≤ 0. Hence, V by V, **the integrand of 𝒵(s) is at most the integrand of 𝒵(0) times e^{a‖s‖₁‖μ_V‖∞}.** The determinant and the gain are untouched.

### 10.2 Pointwise variance — PROVED

**Lemma PV.** Let V > 0 and i ∈ {1, …, n}. If c ∈ ℝⁿ and κ ∈ ℝᵐ satisfy eᵢ = c − Dᵀκ, then **(G_V)ᵢᵢ ≤ ‖c‖₂² + a·κᵀVκ.**

*Proof.* G_V = a(aI + DᵀV^{−1}D)^{−1} (Woodbury). eᵢᵀ(aI + DᵀV^{−1}D)^{−1}eᵢ = sup_x[2⟨eᵢ, x⟩ − a‖x‖² − (Dx)ᵀV^{−1}(Dx)] = sup_x[2⟨c, x⟩ − a‖x‖² − 2⟨κ, Dx⟩ − (Dx)ᵀV^{−1}(Dx)] ≤ ‖c‖²/a + κᵀVκ. ∎

**Choice.** c := the weights of the local quadratic fit at i on a window W ∋ i of length w′: ‖c‖₂² ≤ 9/w′ (Christoffel constant), ‖c‖₁ ≤ 3. The functional ⟨c − eᵢ, ·⟩ vanishes on quadratics and lives on W, so by Newton's formula it equals ⟨κ, D·⟩ with κ supported on the stencils inside W and |κⱼ| ≤ (‖c‖₁ + 1)·w′²/2 = 2w′². Hence

  **(G_V)ᵢᵢ ≤ 9/w′ + 4a·w′⁴·Σ_{j∈W}Vⱼ.**

- On Ω^{(t)} (block sums ≤ t|b|v₁, blocks of length ≥ w), for w′ ≥ 4w: Σ_{j∈W}Vⱼ ≤ t(w′ + 4w)v₁ ≤ 2t·w′·v₁, and w′ := (tϱ)^{−1/6} gives **(G_V)ᵢᵢ ≤ 17·t^{1/6}·ϱ^{1/6} = 17π·t^{1/6}·κ/n.**
- On {maxⱼVⱼ ≤ 2^iv₁}, with no block event: (G_V)ᵢᵢ ≤ 13π·2^{i/6}·κ/n.

No eigenvector of T is used. The operator envelope H₊ of Lemma 2b″ would give only ε on the diagonal.

### 10.3 The comparison mean on the typical class — PROVED given §3.4's score events

|μ_{V,i}| = |eᵢᵀG_Vψ|/f′ ≤ ((G_V)ᵢᵢ·ψᵀG_Vψ)^{1/2}/f′, and G_V ⪯ G₊ := I − DᵀH₊^{−1}D on each class (H_V ⪯ H₊). ψᵀG₊ψ = ψᵀ(I − P⊥)ψ + ψᵀ(aM₊)ψ ≤ C log n + C·d₊ ≤ C·κ on the score events of §3.4 (fixed matrices). With §10.2 at t = 2:

  **‖μ_V‖∞ ≤ C·κ/(f′·√n) on Ω^{(2)} ∩ {max Vⱼ ≤ c₀v₁}**, which covers the typical class and row 2 of §3.5.

This → 0 iff κ = o(√n), i.e. ℓ ≫ n^{3/2}. On these classes each cluster coordinate costs C_x of §9.4 with m̄ → 0, which is ≤ 1 under (ML) with a strict margin.

### 10.4 Atypical classes: truncation — SKETCH (inequalities complete, exponents by hand)

**Truncated pointwise inequality — PROVED.** On the body |δᵢ| ≤ B_n. For θL ≤ x ≤ B_n: e^{−a·h_L(x)} ≤ c_θ^{−1}(1 − e^{−aB_n²/2})^{−1}∫₀^{2B_n}e^{−(a/2)(x − z)² − aLz}dz (the proof of §9.4 with s ∈ [0, B_n] retained). So all shifts have ‖s‖∞ ≤ 2B_n, and the admissible sets have |S| ≤ N₀ := 16Mk′/L² (§9.2(a)).

**Brute-force bound on a class with ‖μ_V‖∞ ≤ μ_c.** ∫_{[0,2B_n]^S}e^{−aL‖s‖₁ + aμ_c‖s‖₁}ds ≤ (2B_n)^{|S|}·e^{2a·B_n·μ_c·|S|}. So the class pays at most **exp{N₀·[log(2B_n/c_θ) + 2a·B_n·μ_c]}** more than in §3.5, with μ_c ≤ C(τ_c^{1/6}·κ·g_c/n)^{1/2} from §10.2–10.3 (τ_c the variance level of the class, g_c its gain bound in the table of §3.5).

| Class of §3.5 | μ_c | Extra cost exponent | Probability exponent | Closes when |
|---|---|---|---|---|
| Row 1, max ∈ (2^{i−1}, 2^i]v₁, 2^i > c₀ | C·κ·2^{i/6}/√n | C·k′[log n + B_nκ2^{i/6}/√n] | 2^{i−1} | c₀ ≥ C·k′ log n and c₀^{5/6} ≥ C·k′B_nκ/√n |
| Row 3, 2^i ≤ c·n/κ² | C·κ·2^{i/2}/√n ≤ C√c, below the (ML) margin for c small | none (mean bound; factor C_x ≤ 1) | — | always |
| Row 3, 2^i > c·n/κ² | C·κ·2^{i/2}/√n | C·k′ log n + C·(k′κB_n/n)·κ2^i | w·2^i/16 | k′κB_n ≤ c·n and w ≥ C·κ |
| Row 4 | C·κ·c₀^{1/6}/√n | C·k′[log n + B_nκc₀^{1/6}/√n] | w/(16ε) | w/ε ≥ C·k′B_nκc₀^{1/6}/√n |

The cutoff c₀ is free upward as long as ε^{5/6}(c₀/θ)^{1/6} ≤ cη (§3.4), i.e. c₀ ≤ c·(n/(κw))^{30}. With ℓ = n^x, κ ≍ n^{1−x/3}, B_n ≍ n^{3/5−x/3}, w ≍ κ·polylog:
- k′κB_n/n ≍ n^{8/5 − x}·polylog. This is the binding condition: **x > 8/5.**
- Row 1 then needs c₀ ≥ n^{3/5}·polylog, allowed since (n/κ²)^{30} = n^{20x−30} ≥ n² at x = 8/5.
- Row 4: w/ε ≍ n^{11x/3 − 5} ≥ n^{0.86}, against a cost ≤ n^{0.6}·polylog.

**Proposition SS — SKETCH.** Let (ML) hold strictly, β < 6, and C·n^{8/5}·polylog ≤ ℓ ≤ n^{9/5}. On the events of §3–§4 and of H-sharp: Z̃_ω(ℓ) ≤ 2·e^{4ωηk + o(k)}·[bound of §3.6], with no hypothesis (XS), (XE) or (XN). *Assembly:* halving lemma with 𝒢 = body; §9.1; the cluster sum of §9.4 with at most (2en)^{2R} = e^{o(k)} sets; §10.1 inside E_V; §10.3 on the typical classes (factor C_x^{|S|} ≤ 1); the table on the others.

### 10.5 The exact inequality that fails below n^{8/5}

**k′·κ·B_n ≤ n^{1−c}**, with B_n the a priori sup-norm bound on the body. It enters only in the brute-force bound e^{2a·B_n·μ_c·|S|} on the atypical classes: shifts as large as B_n, on up to N₀ ≍ k′ coordinates, against a comparison mean of size κ2^{i/2}/√n. Three ways to lower the threshold, none done:
1. Keep the discarded term −(a/2)(Ds)ᵀH_V^{−1}(Ds) of §10.1. For a shift supported on short clusters it is ≈ −(a/2)‖s‖², which makes the s-integral Gaussian and removes B_n from the cost.
2. A better B_n (any improvement of the body's sup-norm bound moves the threshold: the condition is n^{13/5}/ℓ ≪ n with the present B_n).
3. A sharper μ_c on rows 3–4 (the Cauchy–Schwarz step of §10.3 is crude there).

The typical-class part needs only ℓ ≫ n^{3/2}. So the sparse-shift route has no obstruction of principle down to the mixture window n^{26/17}.

### 10.6 (ML) in the paper's designs — hand-computed, UNTESTED

Design (from `FABLE_B_Arule_gauss.md` §1): εᵢ ~ N(0, s(uᵢ)²), s(u) = (1 + u²)/4 ∈ [¼, ½]; learned scale σ₀ = φ(z_τ)/3, ω₀ = 1/σ₀. L is the level of (A2) and is **free**; f is the common lower-secant slope at that level, attained at s = ½ on the tail side: f(L) = [τ − Φ(z_τ − 2L)]/L for τ ≤ ½. Then a = ω(1 − η)f(L).

| τ | ω₀ | Admissible L (both β < 6 and a·L² > 2/π at ω₀) | Example |
|---|---|---|---|
| 0.5 | 7.52 | 0.35 ≲ L ≲ 1.59 | L = 1: f = 0.477, a = 3.59, a·L² = 3.59, β = 3.94. L = 0.35: f = 0.737, a = 5.54, a·L² = 0.68, β = 2.55 |
| 0.25 / 0.75 | 9.44 | 0.40 ≲ L ≲ 0.8 | L = 0.4: f = 0.450, a = 4.24, a·L² = 0.68, β = 3.94 |
| 0.05 / 0.95 | 29.1 | none in the min-density version | β ≥ 6.70 > 6 for every L already (density at the quantile, s = ½). (ML) is not the binding condition; this cell needs the averaged-β̄ version |
| 0.01 / 0.99 | 112.6 | none | β ≥ 13.9, outside LO |

So in the cells where the min-density LO bound applies at all (τ = 0.5, 0.25, 0.75, Gaussian), **(ML) holds at the learned scale with room**, and for every ω in a compact interval around ω₀ after adjusting L within the range shown. The price is that β is evaluated with the secant slope f(L), not the density at the quantile: 2.55–3.94 instead of 2.36 at τ = 0.5. The Beta(1, 11) cells are **not checked**. No numerics; all values from normal tables by hand.

### 10.7 Flags

- New and short: Lemma PV (§10.2) and the shift identity (§10.1). Both are two-line proofs; audit them first.
- §10.3 uses the score events of §3.4 as stated there (ψᵀ(aM₊)ψ ≤ C·d₊); I did not re-read their constants.
- §10.4's table is exponent arithmetic done once. The gain bounds g_c are those of the table in §3.5; I used ψᵀG₊ψ ≤ C·g_c on each class without re-deriving it for rows 3–4.
- Proposition SS is fixed-(ω, ℓ). Uniformity is not addressed.
- (ML) changes the statement of the theorem: β must be computed with the secant slope at a level L satisfying a·L² > 2/π. UNTESTED against the simulation cells; pilot cost nil (a table of f(L) per cell).

## Theory response to §10 (2026-11-23). Fable A's final status today.

**Status: UNAUDITED.**

**PROVED:**
- **§10.1–10.2:** the shift identity and Lemma PV, the pointwise variance bound. Each is a two-line proof; the audit should read them first.
- **§10.3, given §3.4's score events:** ‖μ_V‖∞ → 0 on the typical class.

**SKETCH:** Proposition SS. LO-low holds on [n^{8/5}, n^{9/5}] with **no hypothesis**, when a·L² > 2/π.

**Failing inequality on [n^{26/17}, n^{8/5}]:** k′κB_n ≤ n^{1−c}. This is only a truncation cost.

**Design check (§10.6), hand-computed and UNTESTED:**
- Gaussian τ = 0.5 and 0.25/0.75 admit an L with both β < 6 and a·L² > 2/π.
- τ = 0.05/0.95 does not admit one in the min-density form; it needs the averaged-β̄ version.
- Beta was not checked.

**Tuesday:**
- Astra audits §9–§10, with §10.1–10.2 first.
- Then the averaged-β̄ version of §10.6.
- Then the truncation fix in §10.5.
