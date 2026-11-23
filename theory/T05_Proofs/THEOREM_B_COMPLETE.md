# Theorem B: complete proof, audit package

*BQTF Theory Department, 2026-11-22.*
- **Purpose.** This package collects the full chain for **Theorem B** (oracle posterior contraction in Δ²ₙ under a global MGF condition), so that an auditor can read it from top to bottom.
- **No new results.** Every statement below is quoted from an advisor-checked file. Each is given with its file, review and commit.
- **Version.** The chain is as of commit **5304e9d** (the version under end-to-end audit). The package itself was written afterwards; status lines changed in 250761e, with no mathematical change.
- **Hashes.** The commit hashes refer to the pre-rewrite history. After the E-03 history rewrite, translate them with `engineering/E03_Repo_Organization/hash_map.tsv`.

---

## 1. Exact statement

**Model (Stage A).**
- Observations y₁, …, yₙ are independent on the grid xᵢ = i/n. The target θ\* is the vector of true τ-quantiles (generalized inverse), and Zᵢ := yᵢ − θ\*ᵢ.
- D = D⁽³⁾ ∈ ℝ^{m×n}, with m = n − 3. Coordinates: θ = Nc + Su, where:
  - N ∈ ℝ^{n×3} is an orthonormal basis of the quadratics;
  - u = Dθ;
  - S = C³[:, 4:n], with DS = I;
  - θ\* = Nc\* + Su\* and u\* = Dθ\*.
- The prior is ν := dc ⊗ Π_λ, where Π_λ := Laplace(λ)^{⊗m} is a probability measure and dc is Lebesgue measure on ℝ³.
- σ and λ are fixed, and ω := 1/σ. With Xᵢ(δ) := ρ_τ(Zᵢ − δ) − ρ_τ(Zᵢ) and ℛ(θ) := Σᵢ Xᵢ(θᵢ − θ\*ᵢ),

  Πₙ(B | y) = N(B)/N(ℝⁿ),  N(B) := ∫_B e^{−ωℛ(θ)} ν(dθ).

- Loss: H(δ) := Σᵢ min(δᵢ², |δᵢ|) = nΔ²ₙ(δ).

**Constants fixed before the supremum.**
- ω > 0, b > 0 and τ ∈ (0, 1);
- the upper-margin constants (L, f̄);
- V > 0;
- the comparison constants of the chosen oracle tuning.

**Law class 𝒫ₙᴮ.** All independent laws on the grid satisfying:
- **(A1)** independence;
- **(A2, upper half)** |Fᵢ(θ\*ᵢ + δ) − Fᵢ(θ\*ᵢ)| ≤ f̄|δ| for |δ| ≤ L;
- **(A3)** ‖u\*‖₁ ≤ V n^{−2}, i.e. TV⁽³⁾(θ\*) ≤ V;
- **(EM)** for every i, every n and **every** δ ∈ ℝ: E exp{−ωXᵢ(δ)} ≤ exp{−bω·min(δ², |δ|)}, with the **same** b throughout.

**Tunings and rates.** λ is deterministic, with one of:
- **(primary)** λₙ ≍ n^{5/2}/V and **εₙ² = C(log n)^{1/6}V^{1/3}n^{−5/6}**;
- **(fallback)** λₙ ≍ (n³/V)^{3/4} and **εₙ² = C(log n)^{1/6}V^{1/4}n^{−3/4}**.

(More generally, (log n)^c with any c ≥ 1/6.)

**Theorem B.** For every M > (2/b)(1.44C₁ + 1 + C_pr/ω),

  sup_{P ∈ 𝒫ₙᴮ} E_P Πₙ( Δ²ₙ(θ − θ\*) > M εₙ² | y ) → 0  (n → ∞).

Here:
- C₁ := max(f̄/2, 1/L) (from L2);
- C_pr is the prior-mass constant of §3. It depends on V and the tuning constants only, not on P.
- No bound is uniform as b → 0.

**Sufficient conditions for (EM)** (proved, §2.9 and §2.10):
- **Proposition 1:** the envelope P(Zᵢ > t) ≤ (1−τ)e^{−b₊t} and P(Zᵢ < −t) ≤ τe^{−b₋t} for all t ≥ 0, with b₊ > ωτ and b₋ > ω(1−τ).
- **Proposition 2:** full (A2) with lower constant f, plus sup E e^{c|Zᵢ|} ≤ K, plus ω ≤ ω_B := min{c/2, c₀/C_V}.

**Scope.**
- Δ²ₙ only. No squared-loss corollary is claimed.
- (EM) implies the strict point-density threshold Fᵢ′(q) ≥ ωτ(1−τ) + 2b, so Gaussian noise at the paper's σ₀ is excluded. It also implies the tail bound P(Zᵢ > d) ≤ e^{−ω(τ+b)d} for d ≥ 1, so polynomial tails are excluded.
- (EM) does **not** imply Theorem A's secant condition. Uniform errors on [−1, 1], τ = ½, ω = 1 satisfy (EM) while A4's σ̄ = 2.

---

## 2. The lemmas, exactly as used

Each entry gives the statement in the form used, then: File · Review (verdict) · Commit of the checked version.

### 2.1 L2: increment identity, upper bound, variance

For δ > 0: Xᵢ(δ) = (1−τ)δ − clip(Zᵢ, 0, δ). For δ = −a < 0: Xᵢ = τa − clip(−Zᵢ, 0, a). Moreover:
- **(i)** |Xᵢ(δ)| ≤ |δ| a.s. (no moments);
- **(ii)** mᵢ(δ) := E Xᵢ(δ) = ∫₀^δ (Fᵢ(s) − τ) ds for δ > 0, and similarly for δ < 0;
- **(iii)** the upper half of (A2) forces Fᵢ(0−) = Fᵢ(0) = τ;
- **(iv)** mᵢ(δ) ≤ min{|δ|, C₁δ²}, with C₁ = max(f̄/2, 1/L);
- **(v)** Var Xᵢ(δ) ≤ δ²;
- **(vi)** under full (A2) with lower constant f: mᵢ(δ) ≥ c₀·min(|δ|, δ²), with c₀ = min(f/2, fL/4).

Used by: L6 (i, iii, iv, v); Proposition 2 (the identity, ii, vi).

`L2_excess_risk.md` · `reviews/ASTRA_L2_L4_L5.md` (ACCEPT WITH FIXES, applied) · 97a04c2

### 2.2 L5: normalization and the flat part

- (c, u) ↦ Nc + Su is a linear bijection with constant Jacobian.
- The posterior is proper for every finite data vector (n ≥ 4).
- For each u, the c-section of a set defined through δ is the corresponding set in ℝ³, translated by c₀(u) := c\* − NᵀS(u − u\*). This is because Nᵀδ = c − c₀(u) and ‖Nᵀδ‖₂ ≤ ‖δ‖₂.
- N(B) is measurable in the data.

`L5_normalization.md` · `reviews/ASTRA_L2_L4_L5.md` (ACCEPT) · 97a04c2

### 2.3 L3: centred small ball

For n ≥ 5, λ > 0 and ε > 0, with x := n^{5/2}/(λε) and φ(ε) := −log Π_λ(B_ε), where B_ε = {u : ‖n^{−1/2}P⊥Su‖₂ ≤ ε}:

  φ(ε) ≤ 30·x^{2/5}(log m)^{1/5} + 6.

`L3_small_ball.md` · `reviews/FABLE_L3_L8p.md` (ACCEPT) · 5304e9d · check: §5, C1

### 2.4 L4: ℓ₁ shift (fallback route)

For every measurable C ⊂ ℝᵐ and every x: Π_λ(x + C) ≥ e^{−λ‖x‖₁}Π_λ(C).

`L4_l1_shift.md` · `reviews/ASTRA_L2_L4_L5.md` (ACCEPT) · 97a04c2

### 2.5 L4q: quadratic shift, half-radius form (primary route)

Let A := n^{−1/2}P⊥S with columns aⱼ, and δ_A := maxⱼ‖a_{j+1} − aⱼ‖ ≤ n/√3. Let Φ(λr) := φ(r) and K(ρ) := 4δ_A·Φ(ρ/4)/ρ.

If δ_A ≤ λε/4, then for every h ∈ ℝᵐ:

  Π_λ(h + B_{ε/2}) ≥ Π_λ(B_{ε/2})·exp(−c_{K′}λ²‖h‖₂²),  with K′ := K(λε/2) and c_{K′} = e^{K′}/(1 − e^{−2}).

**Condition (C) at half radius:** K′ ≤ 1, which gives c_{K′} ≤ 3.144. It holds if
- **(R1, via L3)** λε ≥ 102·n^{10/7}(log m)^{1/7}, or
- **(R2, elementary)** λε ≥ 8n² log(2n).

`L4q_quadratic_shift.md` · `reviews/ASTRA_L4q.md` (L4q ACCEPT; R2 ACCEPT) · a759ee0
(Before the advisor check, an independent Fable adversarial check found "correct with fixable gaps"; all fixed.)

### 2.6 L4q-M: mollified truth

For 3 ≤ w ≤ m/2, the explicit signed local-quadratic kernel gives u_h with:
1. ‖u_h‖₂ ≤ C·V/(n²√w);
2. ‖S(u\* − u_h)‖ₙ² ≤ C·V²(w/n)⁵;
3. ‖u_h‖∞ ≤ C·V/(n²w).

C is absolute, and θ_h − θ\* = S(u_h − u\*).

`L4q_quadratic_shift.md` (Corollary L4q-M) · `reviews/ASTRA_L4q.md` (ACCEPT WITH FIXES, applied) · a759ee0

### 2.7 L6: evidence lower bound (any ω, moment-free)

Fix ε ∈ (0, 1) and a deterministic u_h with ‖P⊥S(u_h − u\*)‖ₙ ≤ ε/2. Let

  G := {(c, u) : u ∈ u_h + B_{ε/2}, ‖N(c − c\*) + P_N S(u − u\*)‖ₙ ≤ ε/2}.

Then

  P₀( N(ℝⁿ) ≥ ν(G)·exp{−ω(1.44C₁ + 1)nε²} ) ≥ 1 − 1.44/(nε²),  with ν(G) = V₃(ε√n/2)³·Π_λ(u_h + B_{ε/2}).

`L6_evidence_lower_bound.md` · `reviews/ASTRA_B_L6.md` (ACCEPT WITH FIXES, applied) · aa8c024

### 2.8 L8′(a): exact MGF identity (used by Proposition 1 only)

For δ > 0,

  E e^{−ωXᵢ(δ)} = e^{−ω(1−τ)δ}[1 + ω∫₀^δ e^{ωs}P(Zᵢ > s) ds],

with the mirror form for δ < 0. No margin assumption is needed.

`L8p_bounded_numerator.md` · `reviews/FABLE_L3_L8p.md` (ACCEPT WITH FIXES, applied; (a) verified by quadrature to 9.3e-11) · 5304e9d

### 2.9 Proposition 1: envelope ⇒ (EM)

Under the envelope with b₊ > ωτ and b₋ > ω(1−τ), (EM) holds with bω = a(ω, τ, b₊, b₋) > 0.

Proof outline:
1. Insert the envelope into 2.8 to get U(d) = e^{−αd}[1 + α∫₀^d e^{(ω−b₊)s} ds], with α = ω(1−τ).
2. U ≡ 1 at the critical rate b₊ = ωτ. U is strictly decreasing in b₊, so U(d) < 1 for d > 0.
3. Near 0: −log U ~ (α/2)(b₊ − ωτ)d². At infinity: a positive linear rate (three cases).
4. Compactness gives a positive infimum. Reflect for d < 0.

`B_light_tail.md` §Proposition 1 · `reviews/ASTRA_B_L6.md` (ACCEPT) · aa8c024

### 2.10 Proposition 2: ψ₁ bound + σ threshold ⇒ (EM)

Under full (A2) and sup E e^{c|Zᵢ|} ≤ K, put C_V := max{e^{c/2}, 16K/(ce)²}. If ω ≤ min{c/2, c₀/C_V}, then (EM) holds with b = c₀/2.

Proof outline:
1. log E e^{−ωX} ≤ −ωm(δ) + ½ω²E[W²e^{ωW}];
2. E[W²e^{ωW}] ≤ C_V·min(δ², δ);
3. apply L2 (vi).

`B_light_tail.md` §Proposition 2 · `reviews/ASTRA_B_L6.md` (ACCEPT) · aa8c024

---

## 3. Assembly

Let E := {H(δ) > Mnε²}, Ω := the L6 event, and L := its deterministic lower bound.

**Step 1 (expected numerator on all of ℝⁿ).** By Tonelli (a nonnegative integrand against the σ-finite ν) and independence (A1),

  E₀N(E) = ∫_E ∏ᵢ E e^{−ωXᵢ(δᵢ)} dν ≤ ∫_E e^{−bωH} dν ≤ e^{−bωMnε²/2}∫ e^{−bωH/2} dν,

using (EM).

**Step 2 (the flat part is bounded by a constant).**
- *Claim:* H(δ) ≥ min(‖δ‖₂², ‖δ‖₂). Let A = {|δᵢ| > 1}, p = Σ_{Aᶜ}δᵢ² and q = Σ_A δᵢ². Then H ≥ p + √q. If A = ∅, H = ‖δ‖₂²; otherwise q ≥ 1 and (p + √q)² ≥ p + q.
- *Reduction to c.* By L5, ‖δ‖₂ ≥ ‖c − c₀(u)‖₂. Since r ↦ min(r², r) is nondecreasing,

  ∫_{ℝ³} e^{−bωH/2} dc ≤ C₃(bω) := ∫_{ℝ³} e^{−(bω/2)min(|c|², |c|)} dc < ∞.

  C₃ is 4π times the sum of ∫₀¹ r²e^{−bωr²/2}dr and ∫₁^∞ r²e^{−bωr/2}dr.
- *Integrate over u.* Π_λ has mass 1. So ∫ e^{−bωH/2} dν ≤ C₃(bω), **free of n, λ, u and θ\***.

**Step 3 (denominator).** Apply L6 with the center for the route:
- *Primary:* u_h from L4q-M with w ≍ n(ε/V)^{2/5}, so that (2) gives ‖S(u\* − u_h)‖ₙ ≤ ε/2, hence ‖P⊥S(u_h − u\*)‖ₙ ≤ ε/2.
- *Fallback:* u_h = u\*.

The prior mass is

  −log Π_λ(u_h + B_{ε/2}) ≤ φ(ε/2) + [c_{K′}λ²‖u_h‖₂² (L4q, half radius) or λ‖u\*‖₁ ≤ λV/n² (L4)] ≤ C_pr·nε²,

as verified in the joins table (J5–J8).

**Step 4 (combine).** Πₙ(E | y) ≤ N(E)·1_Ω/L + 1_{Ωᶜ}. Taking E₀,

  E₀Πₙ(E | y) ≤ (C₃(bω)/V₃)·(2/(ε√n))³·exp{−[bM/2 − (1.44C₁ + 1) − C_pr/ω]·ωnε²} + 1.44/(nε²).

Since nε² → ∞, both terms → 0 when M > (2/b)(1.44C₁ + 1 + C_pr/ω). No independence between numerator and denominator is used. ∎

**Not used:** sieves, tests, entropy, sup-norm localization (L7, L9, L10), or any expected *remote* numerator beyond (EM).

---

## 4. Joins table

| # | From → To | What is passed | Value / condition | Checked where |
|---|---|---|---|---|
| J1 | L2 → L6 | Global upper risk bound mᵢ ≤ C₁δ² | C₁ = max(f̄/2, 1/L); needs upper (A2) and Fᵢ(0) = τ | L2 (iv), (iii); Astra B/L6 #6 ("B's weaker A2 suffices") |
| J2 | L2 → L6 | Variance and bounded increments | Var Xᵢ ≤ δᵢ²; \|Xᵢ\| ≤ \|δᵢ\| (Tonelli, no moments) | L2 (i), (v); Astra B/L6 #6 |
| J3 | L5 → L6, Step 2 | c-sections and translation | Section radius ε√n/2 (L6); ‖δ‖₂ ≥ ‖c − c₀(u)‖₂ (Step 2) | Astra B/L6 #6, #7 |
| J4 | L5 → Step 1 | ν σ-finite, posterior ratio | N(B) = ∫_B e^{−ωℛ}dν, same normalization in N(E) and N(ℝⁿ) | Astra L2/L4/L5, L5 #1–2 |
| J5 | L3 → Step 3 (spread) | φ(ε/2) ≤ C·nε² | Need ε² ≳ λ^{−1/3}(log m)^{1/6}, i.e. c ≥ 1/6. At primary λ^{−1/3} = V^{1/3}n^{−5/6}; at fallback V^{1/4}n^{−3/4} | Astra B/L6 #2; Fable L3 "fit with users" (exactly (log n)^{1/6}) |
| J6 | L3 → L4q (C) | Φ(ρ/4) ≤ 52.2·n(log m)^{1/5}ρ^{−2/5} + 6 | K(ρ) ≤ 1 for ρ ≥ 51·n^{10/7}(log m)^{1/7}; half radius 102 | Fable L3 (re-derived: K ≤ 0.49 + 0.15) |
| J7 | L4q-M → L4q → L6 (primary) | Shift h = u_h; charge c_{K′}λ²‖u_h‖₂² | ‖u_h‖₂² ≤ CV²/(n⁴w), w ≍ n(ε/V)^{2/5} ⇒ charge ≤ C·c_{K′}λ²V^{12/5}n^{−5}ε^{−2/5} ≤ nε² iff ε² ≥ (C c_{K′})^{5/6}V²λ^{5/3}n^{−5} = O(V^{1/3}n^{−5/6}) at primary | Astra L4q #5; Astra B/L6 #2 |
| J8 | L4q hypotheses at primary | δ_A ≤ λε/4, K′ ≤ 1, 3 ≤ w ≤ m/2 | λε ≍ n^{25/12}V^{−5/6}(log n)^{c/2} ≥ 102·n^{10/7}(log m)^{1/7} and ≥ 4n/√3 for n ≥ n₀(V); w → ∞, w/n → 0 | Astra B/L6 #2 ("admissible for large n") |
| J9 | L4 → L6 (fallback) | Shift cost λ‖u\*‖₁ | ≤ λV/n²; ≤ nε² iff ε² ≥ λVn^{−3} = V^{1/4}n^{−3/4} at fallback | Astra L2/L4/L5, L4 #1; Astra B/L6 #2 |
| J10 | L6 → Step 3/4 | Event and lower bound | P(Ω) ≥ 1 − 1.44/(nε²); L = V₃(ε√n/2)³Π_λ(u_h + B_{ε/2})e^{−ω(1.44C₁+1)nε²}; center deterministic | Astra B/L6 #6, #7 |
| J11 | Volume term | −log[V₃(ε√n/2)³] | O(log n), negligible vs nε²; kept exactly | Astra B/L6 #2 |
| J12 | L8′(a) → Prop 1 | Exact MGF identity | Holds without (A2); layer-cake, valid with atoms | Fable L8′ (a); Astra B/L6 #5 |
| J13 | L2 (vi) → Prop 2 | Margin c₀·min(δ², \|δ\|) | c₀ = min(f/2, fL/4); needs full (A2) | Astra B/L6 #5 |
| J14 | Props 1/2 → Step 1 | (EM) with a common b | Prop 1: b = a/ω; Prop 2: b = c₀/2. Uniform over the class | Astra B/L6 #1, #5 |
| J15 | Step 2 → Step 4 | C₃(bω), free of n, λ, u, θ\* | Polar formula above | Astra B/L6 #7 |
| J16 | Step 4 | Threshold on M | M > (2/b)(1.44C₁ + 1 + C_pr/ω); nε² → ∞; log(1/ε) = O(log n) | Astra B/L6 #1, #7 |

---

## 5. Index of numerical checks

| ID | Script | Run | Result | Role |
|---|---|---|---|---|
| C1 | `checks/l3_singular_values.py` | NOTS job 2857810 (output in `checks/l3_singular_values.out`); rerun by Fable on Owls | PASS: singular values of C_N to ≤ 4e-15; DS = I exactly; max σ_r(A)/(n^{5/2}r^{−3}) = 0.104, 0.121, 0.124 against the bound 91.2 | L3, Step 4 |
| C2 | `checks/l8p_mgf.py` | NOTS 2857877 (density-based f: 14 valid rows); after the Fable review, Owls rerun with secant f and 0.0321 (`checks/l8p_mgf.out`) | PASS 15/15 rows | L8′(b) (Theorem A). For B, only (a) is used; it was verified by Fable to 9.3e-11 |
| C3 | `checks/global_threshold.py` (8e2565b) | NOTS 2858270 | Gaussian, Laplace, logistic, uniform: ω_crit/ω_loc = 0.994–0.999; mixture σ_crit/σ₀ = 3.58, 6.22, 10.44 | Coverage remarks only (not used in the proof) |
| C4 | `checks/l10i_christoffel.py` | owls_run | PASS; now superseded by Astra's exact formula C = 9 | Theorem A only (appendix) |

## 6. Index of reviews

| File | Scope | Verdict |
|---|---|---|
| `reviews/ASTRA_L2_L4_L5.md` | L2, L4, L5 | L2 ACCEPT WITH FIXES; L4, L5 ACCEPT |
| `reviews/ASTRA_L4q.md` | L4q, L4q-M, (C) without L3 | L4q ACCEPT; L4q-M ACCEPT WITH FIXES; R2 ACCEPT |
| `reviews/FABLE_L3_L8p.md` | L3, L8′ | L3 ACCEPT; L8′ ACCEPT WITH FIXES |
| `reviews/ASTRA_B_L6.md` | Theorem B, Props 1–2, L6 | Assembly ACCEPT WITH FIXES; Props ACCEPT; L6 ACCEPT WITH FIXES |
| `../T03_Feasibility/reviews/LIGHT_TAIL_astra.md`, `LIGHT_TAIL_fable.md` | Design of the light-tail theorem | ADOPT WITH CHANGES (both) |
| Fable adversarial check of L4q (delegated task, before the advisor check) | L4q | Correct with fixable gaps (all fixed) |
| `reviews/AUDIT_astra_B.md`, `AUDIT_fable_B.md` | End-to-end audit of the B chain at 5304e9d | *In progress* |

All fixes requested in these reviews were applied. Each lemma file ends with a "Response to the advisor check" section.

---

## Appendix: finished pieces of Theorem A (status only; NOT part of Theorem B)

| Piece | Statement (short) | Status |
|---|---|---|
| L8′ (`L8p_bounded_numerator.md`) | Exact MGF; log E e^{−ωX} ≤ −B·ω·m(δ) on \|δ\| ≤ Δ ≤ Δ₀, with B ≥ η/2 for ω ≤ (1−η)ω̄; bounded-region numerator; SKELETON Step 2 closed given L6 | Advisor-checked (Fable), 5304e9d |
| L10-I (`L10I_interpolation.md`) | ‖δ‖∞ ≤ 6‖δ‖ₙ + 7.06‖δ‖ₙ^{4/5}TV⁽³⁾(δ)^{1/5} (exact Christoffel constant C = 9); Huber corollary; Stage 2 of L10 closes given Stage 1 for λ/n^{21/11} → ∞ | Advisor-checked (Astra), 3366adb |
| L10 Stage 1 | Posterior TV ball + Δ²ₙ ≲ λ^{−2/7}, moment-free | **Open; parked** at the checkpoint (`parked/L10_stage1_NOTES.md`) |
| L8-b (A⁺) | Realized numerator, any σ | Not started (plan only) |
