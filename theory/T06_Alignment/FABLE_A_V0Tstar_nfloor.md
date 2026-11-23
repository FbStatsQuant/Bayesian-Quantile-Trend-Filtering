# Link L7 (= H6): Theorem V0T\* with an n-dependent floor Λ₋,ₙ = κ₋,ₙ·n^{5/2}

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute. Re-derivation, line by line, of `FABLE_A_n56.md` §3 (V0T\*, audited: `reviews/AUDIT_astra_V0Tstar.md`) and of the parts of `FABLE_V2T_proof.md` it imports, with κ₋ replaced by a sequence κ₋,ₙ. Not audited.*

**Labels.** PROVED = every line is checked here against the audited statement it comes from, with κ₋,ₙ in place of κ₋. SKETCH = argument given, a detail open.

## 0. Verdict

**Theorem V0T\*-n is PROVED** (subject to audit) for every sequence with (log n)^{−A} ≤ κ₋,ₙ ≤ κ̄ (A, κ̄ fixed), in particular for κ₋,ₙ = c₋(log n)^{−1/2}. Nothing breaks and no constant degenerates.

| Question | Answer |
|---|---|
| Where does κ₋ enter? | Five places, listed in §2. In four of them the dependence is algebraic and holds for every κ₋ > 0; in the fifth (localization) it costs powers of log n only |
| C2-mix's mixed MGF at the floor | The constant C̄_fine is **exactly free of κ₋** for every κ₋ > 0: the factor κ₋^{−2} of the MGF is cancelled by the κ₋^{−1/3} in ε̄² |
| The denominator | V2T Step 3's two budget inequalities are identities in κ₋; only its side conditions (N6) need κ₋,ₙ ≥ n^{−c}, true here |
| Threshold M̄\* | free of κ₋ |
| Window mass (WM) for the conditioned A-rule | p₀,ₙ = 1 − e^{−c_bκ₋,ₙ}, so −log p₀,ₙ = O(log log n) = o(nε̄²) |
| Rate | M·ε̄ₙ² ≤ M·C_ε·c₋^{−1/3}·n^{−5/6}(log n)^{1/3}·(1 + o(1)): **n^{−5/6}(log n)^{1/3} is confirmed** |
| Sup-norm | (log n / n)^{7/30} |
| What degenerates as κ₋,ₙ → 0? | Nothing at a logarithmic rate. The rate constant grows like κ₋,ₙ^{−1/3} (that is the extra (log n)^{1/6}); the localization radius r and the TV radius T₀ grow by powers of log n; p₀,ₙ^{−1} ≍ (log n)^{1/2} is a prefactor. A polynomial decay κ₋,ₙ ≲ n^{−9/22} would break sup-norm localization (C1's window) |

---

## 1. Statement

**Model.** σ ~ IG(a, b) (a, b > 0 fixed); λ ~ p_n, any probability law on [Λ₋,ₙ, ∞), Λ₋,ₙ := κ₋,ₙ·n^{5/2}; J₀ := [Λ₋,ₙ, 2Λ₋,ₙ], p₀,ₙ := p_n(J₀). Assumptions of V0T\* (those of Theorem C\*; no relation between κ₋,ₙ and V).

**Sequence.** (log n)^{−A} ≤ κ₋,ₙ ≤ κ̄.

**Constants** (as in V0T\*, with κ₋,ₙ):
- Dₙ := n·ε̄ₙ², ε̄ₙ² := C_ε·n^{−5/6}·[κ₋,ₙ^{−1/3}(log m)^{1/6} + κ₋,ₙ^{5/3}V²], C_ε as in V2T Step 3;
- T ≥ 4, T₀,ₙ := (T/κ₋,ₙ)·√n, rₙ² := C_r(T/κ₋,ₙ)^{2/7}·n^{−4/7}(log n)^{6/7};
- C̄_fine := 16·C_F²·(256/f²)⁵/C_ε⁶;
- I = [(1 − η₁)d, (1 + η₁)B], ω₁, ω₂ its inverse endpoints; M ≥ 1 with ω₁(f/8 − γ)M > 3 + ω₂(1.25C₁ + 1) + C̄_fine·ω₂² (strict; gap g > 0).

**Theorem V0T\*-n.** If −log p₀,ₙ = o(Dₙ), then for every such M and every η > 0:
1. sup_P E_P Π(‖θ − θ\*‖ₙ² > M·ε̄ₙ² | y) → 0;
2. sup_P E_P Π(‖θ − θ\*‖∞ > 6√M·ε̄ₙ + 7.06(√M·ε̄ₙ)^{4/5}T₀,ₙ^{1/5} | y) → 0;
3. sup_P E_P Π(|σ/σ₀,ₙ − 1| > η | y) → 0.

**For κ₋,ₙ = c₋(log n)^{−1/2}:** ε̄ₙ² = C_ε·n^{−5/6}·[c₋^{−1/3}(log n)^{1/6}(log m)^{1/6} + c₋^{5/3}(log n)^{−5/6}V²] ≤ C_ε·c₋^{−1/3}·n^{−5/6}(log n)^{1/3}(1 + o(1)); the sup-norm radius is ≍ n^{−7/30}(log n)^{2/15}·(log n)^{1/10} = (log n/n)^{7/30}; Dₙ ≍ n^{1/6}(log n)^{1/3}.

**Corollary (the use in the chain).** For the untruncated A-rule λ ~ Gamma(1, b_n), b_n = c_bn^{−5/2}: the posterior conditioned on {λ ≥ Λ₋,ₙ} is this model with p_n the shifted exponential, p₀,ₙ = 1 − e^{−c_bκ₋,ₙ} (memoryless). Since Π(B | y) ≤ Π(B | y, λ ≥ Λ₋,ₙ) + Π(λ < Λ₋,ₙ | y), **(LT) at Λ₋,ₙ = c₋n^{5/2}(log n)^{−1/2} implies conclusions 1–3 for the untruncated posterior, at n^{−5/6}(log n)^{1/3}.** PROVED given (LT).

---

## 2. Where κ₋ enters, line by line

Notation: "algebraic" = an inequality that holds for every κ₋ > 0 with the constants as defined, with no limit taken.

### 2.1 V2T Step 2 and conclusion 3 (scale) — PROVED

- (a) L3 at radius one for ℓ ≥ Λ₋,ₙ: 30·κ₋,ₙ^{−2/5}(log m)^{1/5} + 6 ≤ n. With κ₋,ₙ ≥ (log n)^{−A} the left side is polylog. ✓
- (b) Roughness cost 2^{n−3}e^{−Λ₋,ₙnd/8} against O(n log n): needs Λ₋,ₙ/log n → ∞. ✓
- Lemma S's (l, H₀) depend on (k, d, B, V) only. κ₋-free.
- Conclusion 3 of V2T (σ/σ₀,ₙ → 1) is what supplies the interval I; it follows from V2T's conclusion 1 below.

### 2.2 V2T Step 4, the frozen body (localization) — PROVED

K′ₙ := {‖δ‖ₙ ≤ rₙ, TV(δ) ≤ T₀,ₙ}, C1's body at λ = Λ₋,ₙ.
- C1 (i): rₙ⁴T₀,ₙ = C_r²(T/κ₋,ₙ)^{11/7}·n^{−9/14}(log n)^{12/7} → 0. ✓ (extra factor κ₋,ₙ^{−11/7}, polylog)
- Sup-norm on the body: s_K,ₙ = 6rₙ + 7.06·rₙ^{4/5}T₀,ₙ^{1/5} ≍ (T/κ₋,ₙ)^{11/35}·n^{−9/70}(log n)^{12/35}. For κ₋,ₙ = c₋(log n)^{−1/2}: ≍ n^{−9/70}(log n)^{1/2} → 0. ✓ **This is the only place where a polynomially small κ₋,ₙ would fail:** s_K,ₙ → 0 needs κ₋,ₙ ≫ n^{−9/22}·polylog, which is C1's window Λ₋ ≫ n^{23/11}.
- C1 (i′): VΛ₋,ₙ = κ₋,ₙVn^{5/2} = o(n³). ✓
- C1's width step: the truncation level (T₀,ₙ√n/rₙ)^{1/3} ≤ n^{3/7}·polylog ≤ m. ✓ C_r depends on f only.
- Cone A₂: n²‖u‖₁/T₀,ₙ = (Λ₋,ₙ/ℓ)·Γ/(Tn) ≤ Γ/(Tn) for ℓ ≥ Λ₋,ₙ (no κ₋), and s₀ = V/T₀,ₙ = κ₋,ₙV/(T√n) → 0, faster than before. (N5): Tn/4 ≥ ω₂(f/4)n·rₙ² + 1 + κ₋,ₙV√n/2 + m·log 2. ✓ (rₙ → 0)
- Bousquet at level log n needs n·rₙ² ≫ log n. ✓

### 2.3 V2T Step 3, the mixed denominator — PROVED

One centre u_h for the window J₀, bandwidth w := ⌊n(ε̄ₙ²/(4C_MV²))^{1/5}⌋.
- *Spread.* For ℓ ≥ Λ₋,ₙ: φ_ℓ(ε̄ₙ/2) ≤ 30·(2/(κ₋,ₙε̄ₙ))^{2/5}(log m)^{1/5} + 6. This is ≤ Dₙ + 6 **iff** ε̄ₙ² ≥ (30·2^{2/5})^{5/6}·κ₋,ₙ^{−1/3}(log m)^{1/6}·n^{−5/6}, which is the first term of ε̄ₙ² (C_ε ≥ 39.6^{5/6}). **Algebraic.**
- *Shift.* For ℓ ≤ 2Λ₋,ₙ: c_{K′}ℓ²‖u_h‖₂² ≤ 3.144·4κ₋,ₙ²·n·C_M²V²/w ≤ 25.2·4^{1/5}C_M^{11/5}·κ₋,ₙ²V^{12/5}ε̄ₙ^{−2/5}. This is ≤ Dₙ **iff** ε̄ₙ² ≥ C·κ₋,ₙ^{5/3}V²n^{−5/6}, the second term. **Algebraic** (given w ≥ 1 for n/w ≤ 2n/x).
- *Side conditions (N6).* ε̄ₙ < 1 ✓; Dₙ ≥ 6 ✓; n/√3 ≤ Λ₋,ₙε̄ₙ/4 and (R1) Λ₋,ₙε̄ₙ ≥ 102·n^{10/7}(log m)^{1/7}: Λ₋,ₙε̄ₙ ≍ κ₋,ₙ^{5/6}·n^{25/12}(log n)^{1/12}, and 25/12 > 10/7, so both hold for κ₋,ₙ ≥ (log n)^{−A} ✓; 3 ≤ w ≤ m/2: w ≍ n·(ε̄ₙ/V)^{2/5} → ∞ and w/n → 0 ✓.
- *Result.* On Ω_D (ω-free; P₀(Ω_Dᶜ) ≤ 1.25/Dₙ), for all ω > 0: N̄_ω(ℝⁿ) ≥ V₃(ε̄ₙ√n/2)³·p₀,ₙ·exp{−(3 + ω(1.25C₁ + 1))Dₙ}. The constants 3 and 1.25C₁ + 1 are κ₋-free.

### 2.4 V2T conclusion 1 (n^{−4/7}-type localization) — PROVED

R_n → 0 needs Dₙ = o(n·rₙ²), ε̄ₙ·n·rₙ → ∞, Dₙ = o(n), −log p₀,ₙ = o(n·rₙ²). Here Dₙ ≍ n^{1/6}·polylog and n·rₙ² ≍ n^{3/7}·polylog. ✓ Hence V2T holds with κ₋,ₙ, and Lemma S §1 gives conclusion 3.

### 2.5 Lemma C2-mix at the floor — PROVED

J := ⌊(f²/128)·M·Dₙ⌋; t_∞ := C_F(n/J)^{5/2}√(2 log 2m); Ω_ψ as before (κ₋-free; P₀(Ω_ψᶜ) ≤ 4(J + 3)/(9(J − 1)²) + (2m)^{−3} → 0 since J ≍ Dₙ → ∞).
- (a) Knight and one Cauchy–Schwarz in ν̄: κ₋-free.
- (b) Remainder: κ₋-free (unit mass of Π̄; one Markov event per shell and endpoint).
- (c) Coarse score: κ₋-free.
- (d) **Mixed MGF at the floor.** Monotonicity in ℓ gives the product at Λ₋,ₙ. Condition (N9): 16ω₂²C_F²·log(2m) ≤ κ₋,ₙ²·J⁵. The right side is ≍ κ₋,ₙ²Dₙ⁵ ≥ c·κ₋,ₙ^{1/3}·n^{5/6}(log m)^{5/6} → ∞ ✓. Then (audit finding 4)

  ½·log-MGF ≤ 4ω²·m·t_∞²/Λ₋,ₙ² = 8ω²C_F²·m·log(2m)/(κ₋,ₙ²·J⁵) ≤ 16ω²C_F²(256/f²)⁵M^{−5}·[n·κ₋,ₙ^{−2}·log m]/Dₙ⁵ ≤ C̄_fine·ω²·Dₙ/M⁵,

  using J ≥ (f²/256)M·Dₙ (N8) and **Dₙ⁶ ≥ C_ε⁶·n·κ₋,ₙ^{−2}·log m** (first term of ε̄ₙ² only). **Algebraic: κ₋,ₙ cancels exactly, so C̄_fine does not move.**
- (e) Truth shift: ω·t_∞V/n² = ωC_F√(2 log 2m)·V·√n·J^{−5/2}, floor-free. With J ≍ n^{1/6}(log n)^{1/3}: ≍ V·n^{1/12}(log n)^{−1/3} = o(Dₙ). ✓ (smaller than at fixed κ₋)

### 2.6 Shell assembly — PROVED

- Shells a_k = 2^kM, k ≤ k_max := ⌈log₂(rₙ²/(Mε̄ₙ²))⌉ = O(log n).
- (N10): s_K,ₙ ≤ s₀ := min(L, 3f(1 − η₁)d/(4f̄)) ✓ eventually (§2.2).
- On the intersection of events, for all ω ∈ [ω₁, ω₂]:

  Π_s(‖δ‖ₙ² > Mε̄ₙ² | y) ≤ R_n + (2/p₀,ₙ)·Σ_k(8·2^kM)^{3/2}·exp{−[ω₁(f/8 − γ)2^kM − 3 − ω₂(1.25C₁ + 1) − C̄_fineω₂²/M⁵ − ζ̄_n]·Dₙ},

  with ζ̄_n := ω₂t_∞V/(n²Dₙ) → 0. With the audit's (N11) (shift cost and window cost each ≤ (g/4)·Dₙ), the k-th exponent is ≤ −2^k(g/2)Dₙ, and the sum → 0.
- **Window cost.** −log p₀,ₙ ≤ (g/4)Dₙ. For the conditioned A-rule: p₀,ₙ = 1 − e^{−c_bκ₋,ₙ} ≥ min(½, c_bκ₋,ₙ/2), so −log p₀,ₙ ≤ log 2 + log(1/(c_bc₋)) + ½·log log n = O(log log n). ✓ **(WM) holds.** The prefactor 2/p₀,ₙ ≍ (log n)^{1/2} is absorbed.
- Failure probability: 1/n + 1.25/Dₙ + 4(J + 3)/(9(J − 1)²) + (2m)^{−3} + 4e^{−2γω₁M·Dₙ} → 0.

### 2.7 Conclusions — PROVED

Conclusion 1: disintegration over I, §2.6, and conclusion 3 for the complement of I. Conclusion 2: L10-I at (√M·ε̄ₙ, T₀,ₙ) on the intersection with K′ₙ. Conclusion 3: §2.4. ∎

---

## 3. Summary of the κ₋ dependence

| Quantity | Dependence on κ₋ | At κ₋,ₙ = c₋(log n)^{−1/2} |
|---|---|---|
| ε̄ₙ² (rate) | κ₋^{−1/3}(log m)^{1/6} + κ₋^{5/3}V² | n^{−5/6}(log n)^{1/3}·c₋^{−1/3}C_ε |
| Dₙ = nε̄ₙ² | same | ≍ n^{1/6}(log n)^{1/3} |
| C̄_fine, M̄\*, C_r, C₁, (l, H₀) | none | unchanged |
| Mixed MGF condition (N9) | κ₋²J⁵ ≳ log n | κ₋²J⁵ ≍ n^{5/6}(log n)^{2/3} |
| Truth shift / Dₙ | ∝ J^{−5/2}/Dₙ | n^{−1/12}(log n)^{−2/3} |
| rₙ², T₀,ₙ | κ₋^{−2/7}, κ₋^{−1} | n^{−4/7}(log n)^{1}, √n(log n)^{1/2} |
| s_K,ₙ | κ₋^{−11/35} | n^{−9/70}(log n)^{1/2} |
| s₀ = V/T₀,ₙ | κ₋ | smaller |
| p₀,ₙ (conditioned A-rule) | 1 − e^{−c_bκ₋} | ≍ (log n)^{−1/2}; cost O(log log n) |
| Sup-norm radius | ε̄^{4/5}T₀^{1/5} ∝ κ₋^{−1/3} | (log n/n)^{7/30} |

**Admissible range of the sequence.** Every step above uses κ₋,ₙ only through: κ₋,ₙ ≥ n^{−c} for the side conditions (N6), (N9); Λ₋,ₙ/log n → ∞; and s_K,ₙ → 0, i.e. κ₋,ₙ ≫ n^{−9/22}·polylog. So the theorem holds on that whole range with the same proof; I state it for (log n)^{−A} ≤ κ₋,ₙ ≤ κ̄ because only that range was checked term by term. For polynomially small κ₋,ₙ the rate is n^{−5/6}κ₋,ₙ^{−1/3}, the floor-exponent statement of `FABLE_A_n56.md` §6 (still SKETCH there).

**The constant c₋ is not free in the chain.** It is fixed by (LT) (it must be small enough for the lower-tail comparison in `FABLE_A_Arule_lowertail.md` §4–5 and Theorem U). Here it appears only as c₋^{−1/3} in the rate constant.

## 4. n₀ conditions (with κ₋,ₙ)

- V2T's (N1)–(N7) with κ₋ → κ₋,ₙ: (N2) s_K,ₙ ≤ L; (N3) width truncation ≤ m and C_r(f); (N4) Bousquet; (N5) Tn/4 ≥ ω₂(f/4)n·rₙ² + 1 + κ₋,ₙV√n/2 + m·log 2; (N6) ε̄ₙ < 1, Dₙ ≥ 6, n/√3 ≤ Λ₋,ₙε̄ₙ/4, Λ₋,ₙε̄ₙ ≥ 102·n^{10/7}(log m)^{1/7}, 3 ≤ w ≤ m/2; (N7) 30κ₋,ₙ^{−2/5}(log m)^{1/5} + 6 ≤ n and the roughness inequality with Λ₋,ₙ.
- (N8) (f²/128)M·Dₙ ≥ 3, J ≤ m. (N9) 16ω₂²C_F²·log(2m) ≤ κ₋,ₙ²J⁵. (N10) s_K,ₙ ≤ min(L, 3f(1 − η₁)d/(4f̄)). (N11) ζ̄_n ≤ g/4, −log p₀,ₙ ≤ (g/4)Dₙ, 2γω₁M·Dₙ ≥ log 2.
- Lemma S's law-of-large-numbers events: no explicit rate, so no explicit overall n₀ (unchanged).

Each is monotone in n eventually for the stated sequence; none is uniform as c₋ ↓ 0.

## 5. Not verified

- I re-derived the κ₋ dependence from the statements as audited (the formulas quoted in `AUDIT_astra_V0Tstar.md` findings 4–7 and in V2T Steps 2–4). I did not re-open the internals of C1, L3, L4q, L4q-M, L6, L10-I or Lemma S.
- V2T's audit was for fixed κ₋; its fix list (statement of τ, σ₀,ₙ, the zero-truth convention V = 0) carries over unchanged and was not re-checked here.
- The numerical value of C_ε (through C_M) is still not looked up.
- The second-pass (law-dependent) constant of `FABLE_A_n56.md` §4 was not re-derived with κ₋,ₙ; it does not involve κ₋.

---

## Theory response (2026-11-23)

**Status: PROVED (one pass), UNAUDITED.** Astra audit requested (link L7 of the floor-free chain).

**Checked by Theory:**
- **Rate algebra.** κ₋,ₙ^{−1/3}·(log m)^{1/6} = c₋^{−1/3}(log n)^{1/6+1/6} = c₋^{−1/3}(log n)^{1/3}. The κ₋^{5/3}V² term is o of that.
- **(WM).** 1 − e^{−c_bκ₋,ₙ} ≍ c_bc₋(log n)^{−1/2}, so −log p₀,ₙ = O(log log n) = o(nε̄²).

**Scope.** The audited κ₋-free inputs are used as stated: C1, L3, L4q, L6, L10-I, Lemma S. The internals were not re-derived; the auditor should confirm κ₋ appears nowhere inside them.

## Cross-family audit response (Astra, `reviews/AUDIT_astra_V0T_nfloor.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES.** All eight findings are CONFIRMED, and Theory rules that they **HOLD**. All three conclusions hold for (log n)^{−A} ≤ κ₋,ₙ ≤ κ̄. At κ₋,ₙ = c₋(log n)^{−1/2} the rate is n^{−5/6}(log n)^{1/3}.

| # | Fix (written in full in Tuesday's clean rewrite) |
|---|---|
| 1 | The envelope is read eventually; any A > ½ admits the proposed schedule; fix (η₁, γ, the interior quantile) in the standalone statement |
| 2 | L3/L4q half-radius tests verified; specify the V = 0 branch (centre 0) |
| 3 | Frozen body at the lower endpoint: r⁴T₀ = o(1), VΛ = o(n³); radii as claimed |
| 4 | Lemma S uses the floor in exactly two estimates, both o(n); joint propriety via V2T's flat integral |
| 5 | The C2-mix cancellation is exact; state (N9) divided by log(2m) |
| 6 | One Markov event per shell and endpoint; truth shift and window cost absorbed once each |
| 7 | (WM): −log p₀,ₙ ≤ log 2 + [log(1/z)]₊. Corollary P's conditioning identity holds above n²; **transfer to the untruncated posterior is conditional on (LT) at the same floor** |
| 8 | **Replace "each is monotone" by "each holds eventually". Delete the polynomial-floor extrapolation** (the geometric condition is κ ≫ n^{−9/22}(log n)^{12/11}; not needed) |

**Status: link L7 is PROVED and cross-family audited.**
