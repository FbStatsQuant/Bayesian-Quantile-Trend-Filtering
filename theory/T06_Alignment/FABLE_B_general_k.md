# Task B: the chain at general order k (D = D⁽ᵏ⁺¹⁾, flat prior on polynomials of degree ≤ k)

*Fable, research sub-agent for Theory, 2026-11-23. Pure mathematics, derived by hand; **no compute was run and nothing here is audited**. Sources read in full: `L3_small_ball.md`, `L4q_quadratic_shift.md`, `L10I_interpolation.md`, `W_width_lemma.md`, `C1_any_sigma.md`, `astra_sigma_concentration.md` (Lemma S), `FABLE_V2T_proof.md`, `FABLE_lemmaF_C2.md`, `THEOREM_B_COMPLETE.md`. `L5_normalization.md` and the proof of `L6_evidence_lower_bound.md` were also read. L2 was used through the package's statement.*

**Labels.**
- **PROVED** = every line that changes with k is derived in this file, and the remaining lines of the audited k = 2 proof do not involve the order (checked against the file text).
- **SKETCH** = exponent-level, or a step is cited but not rewritten.
- "Verbatim" = the k = 2 proof with 2 → k, 3 → k + 1 and new constants; no new idea.

## 0. Answer in one table

Notation for general k ≥ 0: m = n − k − 1; N = orthonormal basis of polynomials of degree ≤ k (dimension k + 1); S = C^{k+1}[:, k+2:n], with columns

  sⱼ(i) = C(i − j − 1, k)·1{i ≥ j + k + 1},  DS = I;

(A3) reads TV⁽ᵏ⁺¹⁾(θ\*) = nᵏ‖Dθ\*‖₁ ≤ V, i.e. ‖u\*‖₁ ≤ V n^{−k}. A_k := n^{−1/2}P⊥S.

| Piece | General-k form | k = 2 | Generalizes? | Status |
|---|---|---|---|---|
| L3 singular values | σ_r(A_k) ≤ (1.5(k+1))^{k+1}·n^{k+1/2}·r^{−(k+1)} | 91.2·n^{5/2}r^{−3} | verbatim | PROVED (§1) |
| L3 small ball | φ(ε) ≤ C_k·x^{2/(2k+1)}(log m)^{1/(2k+1)} + C′_k, x = n^{k+1/2}/(λε) | x^{2/5}(log m)^{1/5} | verbatim | PROVED (§1) |
| Spread budget | ε² ≳ λ^{−1/(k+1)}(log m)^{1/(2k+2)} | λ^{−1/3}(log)^{1/6} | arithmetic | PROVED (§1) |
| L4q shift lemma | unchanged; δ_A ≤ n^{k−1}/((k−1)!√(2k−1)) for k ≥ 1, δ_A ≤ n^{−1/2} for k = 0 | n/√3 | verbatim | PROVED (§2) |
| Condition (C), R1 | λε ≥ C·n^{k(2k+1)/(2k+3)}(log m)^{1/(2k+3)} (k ≥ 1); n^{1/6}(log m)^{1/3} (k = 0) | n^{10/7}(log)^{1/7} | verbatim | PROVED (§2) |
| Condition (C), R2 | λε ≥ 8nᵏ log(2n) (k ≥ 1) | 8n² log(2n) | verbatim | PROVED (§2) |
| L4q-M | degree-k reproducing kernel; ‖u_h‖₂ ≤ CV/(nᵏ√w), ‖S(u\* − u_h)‖ₙ² ≤ CV²(w/n)^{2k+1}, ‖u_h‖∞ ≤ CV/(nᵏw) | (w/n)⁵ | verbatim | PROVED (§2) |
| Bias term | **V²·λ^{(2k+1)/(k+1)}·n^{−(2k+1)}** | V²λ^{5/3}n^{−5} | arithmetic | PROVED (§2) |
| **Oracle λ_{k,n}** | **n^{k+1/2}/V** | n^{5/2}/V | — | PROVED (§3) |
| **Rate r_k** | **εₙ² = C(log n)^{1/(2k+2)}·V^{1/(k+1)}·n^{−(2k+1)/(2k+2)}**: yes, (2k+1)/(2k+2) | n^{−5/6} | — | PROVED (§3) |
| Fallback (L4) | λ = (n^{k+1}/V)^{(k+1)/(k+2)}, ε² ≍ V^{1/(k+2)}n^{−(k+1)/(k+2)} | n^{−3/4} | verbatim | PROVED (§3) |
| L10-I | ‖δ‖∞ ≤ 2√C_k·a + K_k·a^{2k/(2k+1)}T^{1/(2k+1)}, T = nᵏ‖Dδ‖₁ | a^{4/5}T^{1/5} | verbatim for k ≥ 1; **degenerate at k = 0** | PROVED with C_k finite (§4); the value C_k = (k+1)² is proved for k ≤ 2 and SKETCH for k ≥ 3 |
| Lemma F | max_j‖(I − P_J)Seⱼ‖₂ ≤ c_{F,k}·h^{k+1/2}, P_J onto degree-k discrete splines, dim J + k + 1 | 2.85·h^{5/2} | verbatim (k + 1 knots) | PROVED (§5) |
| Lemma W′ | √n·ρ + √n·ρ^{(2k+1)/(2k+2)}T₀^{1/(2k+2)}√(log n) | ρ^{5/6}T₀^{1/6} | verbatim | PROVED (§5) |
| C1 | r² ≍ T^{2/(2k+3)}λ^{−2/(2k+3)}(log n)^{(2k+2)/(2k+3)} with W′; window λ ≫ n^{(k+1)(2k+3)/(4k+3)}(log n)^{2k(k+1)/(4k+3)} | λ^{−2/7}; n^{21/11} | verbatim for k ≥ 2; **k = 1 needs W′**; **k = 0 breaks** | PROVED for k ≥ 1 by substitution (§6) |
| C2 | J ≍ nε² ≍ n^{1/(2k+2)}; fine log-MGF ≤ C·ω²nε²/M^{2k+1}; rate n^{−(2k+1)/(2k+2)} | n^{−5/6} | verbatim for k ≥ 1; inherits C1's failure at k = 0 | PROVED for k ≥ 1 by substitution (§7) |
| Lemma S | §§1–3 with 8 → 2^{k+1}, 3 → k + 1 | — | verbatim, every k ≥ 0 | PROVED (§8); hypothesis U needs C1, so k ≥ 1 |
| V0T floor | Λ₋ = κ₋n^{k+1/2}; T₀ = (T/κ₋)√n for every k | κ₋n^{5/2} | verbatim for k ≥ 2; **k = 1 needs W′ in Step 4**; k = 0 breaks | PROVED for k ≥ 1 by substitution (§9) |

**Where something breaks.**
- **k = 0.** L3, L4q, L4q-M, F, W′, Lemma S §§1–2 and Theorem B all go through. C1, C2, V0T and hypothesis U do **not**: the interpolation exponent 2k/(2k+1) is 0, so ‖δ‖∞ ≲ a + T with T₀ ≍ √n, and sup-norm localization is impossible by this route. A new idea is needed (§6.3).
- **k = 1.** Everything goes through, but only with Lemma F. With the audited Lemma W the C1 window is λ ≫ n^{11/7}, which excludes the oracle and the floor n^{3/2}. With W′ the window is λ ≫ n^{10/7}(log n)^{4/7}; the margin is n^{1/14} and s_K ≍ n^{−1/30}.
- **k ≥ 2.** Nothing breaks. Only constants change, and they grow fast in k (§10).

---

## 1. L3 at order k — PROVED

Steps 1–3, 5 of L3 (scale mixture, Anderson, truncation at v₀ = 2 log(m)/λ², rotation to the weighted χ² series) do not involve the order. They need m ≥ 2, i.e. n ≥ k + 3.

**Step 4 (singular values).**
- σ_q(C_n) ≤ 1.5n/q, as in L3.
- Horn for k + 1 factors: σ_{i₁+…+i_{k+1}−k}(X₁⋯X_{k+1}) ≤ ∏σ_{i_l}(X_l). With all indices equal to q: σ_{(k+1)q−k}(C^{k+1}) ≤ σ_q(C)^{k+1}.
- Take q := ⌊(r + k)/(k + 1)⌋. Then (k+1)q − k ≤ r and q ≥ r/(k + 1). By monotonicity, σ_r(C^{k+1}) ≤ (1.5(k+1)n/r)^{k+1}.
- S is a column-submatrix of C^{k+1} (column j + k + 1 of C^{k+1} has entries C(i − j − 1, k) for i ≥ j + k + 1), and P⊥ is a contraction. Hence

  **σ_r(A_k) ≤ c_k·n^{k+1/2}·r^{−(k+1)},  c_k := (1.5(k+1))^{k+1}.**

  (k = 2: 4.5³ = 91.125. k = 1: 9. k = 0: 1.5. k = 3: 1296.)

**Step 6 (series Σ b·r^{−(2k+2)}ξ_r² ≤ ε², b := v₀c_k²n^{2k+1}).** Let K := ⌈(8b/((2k+1)ε²))^{1/(2k+1)}⌉.
- *Tail.* Σ_{r>K} b·r^{−(2k+2)} ≤ b/((2k+1)K^{2k+1}) ≤ ε²/8, so Markov gives probability ≤ 1/4 of exceeding ε²/2. The series converges for every k ≥ 0.
- *Head.* With t_r := ε·r^{k+1}/√(2Kb): 2Kb ≤ ((2k+1)/4)ε²K^{2k+2}, so t_r ≥ (2/√(2k+1))·(r/K)^{k+1}. Using P(|ξ| ≤ t) ≥ 0.48·min(t, 1) and K! ≥ (K/e)^K:

  log P(head) ≥ K·log(0.48·min(1, 2/√(2k+1))) + (k+1)·log(K!/K^K) ≥ −β_k·K,  β_k := k + 1 + log(max(1, √(2k+1)/2)/0.48).

  (k = 2: β₂ = 3 + log(1.118/0.48) = 3.85, as in L3.)
- *K.* 8b/((2k+1)ε²) = 16c_k²·log(m)·x²/(2k+1), with x := n^{k+1/2}/(λε).

**Result.** For n ≥ k + 3, λ > 0, ε > 0:

  **φ(ε) ≤ log(16/3) + β_k·[1 + (16c_k²/(2k+1))^{1/(2k+1)}·(log m)^{1/(2k+1)}·x^{2/(2k+1)}].**

This is the claimed φ(ε) ≲ (n^{k+1/2}/(λε))^{2/(2k+1)} up to (log m)^{1/(2k+1)}.

**Spread budget.** φ(ε/2) ≤ C·nε² ⇔ n·(λε)^{−2/(2k+1)}(log m)^{1/(2k+1)} ≲ nε² ⇔ ε^{(4k+4)/(2k+1)} ≳ λ^{−2/(2k+1)}(log m)^{1/(2k+1)} ⇔

  **ε² ≳ λ^{−1/(k+1)}·(log m)^{1/(2k+2)}.**

---

## 2. L4q and L4q-M at order k — PROVED

### 2.1 The shift lemma

The proof of L4q (symmetrization, Jensen, Prékopa, neighbour compensation, Borell) uses A only through δ_A := max_j‖a_{j+1} − aⱼ‖₂ and φ. It is order-free. Only δ_A and the check of (C) change.

**δ_A.** By Pascal's rule, for k ≥ 1, sⱼ(i) − s_{j+1}(i) = C(i − j − 2, k − 1)·1{i ≥ j + k + 1}, with entries ≤ n^{k−1}/(k−1)!. Summing squares over at most n rows (as (★) in §5):

  **δ_A ≤ n^{k−1}/((k−1)!·√(2k−1))  (k ≥ 1).**

(k = 2: n/√3. k = 1: δ_A ≤ 1.) For **k = 0**, sⱼ − s_{j+1} = e_{j+1}, so δ_A ≤ n^{−1/2}; the formula above does not apply.

**Condition (C): K(ρ) = 4δ_A·Φ(ρ/4)/ρ ≤ 1.**
- *(R1) via §1.* Φ(ρ/4) ≤ C_k·n·ρ^{−2/(2k+1)}(log m)^{1/(2k+1)} + C′_k, because (n^{k+1/2})^{2/(2k+1)} = n. For k ≥ 1, K(ρ) ≤ C·nᵏ·ρ^{−(2k+3)/(2k+1)}(log m)^{1/(2k+1)} + C·n^{k−1}/ρ, so K ≤ 1 once

  **ρ ≥ C_k·n^{k(2k+1)/(2k+3)}·(log m)^{1/(2k+3)}.**

  (k = 2: n^{10/7}(log m)^{1/7}. k = 1: n^{3/5}(log m)^{1/5}. k = 3: n^{7/3}(log m)^{1/9}.) For k = 0: K(ρ) ≲ n^{1/2}ρ^{−3}log m, so ρ ≥ C·n^{1/6}(log m)^{1/3}.
- *(R2) elementary, k ≥ 1.* a_max ≤ n^{−1/2}‖sⱼ‖₂ ≤ nᵏ. On {max_j|λuⱼ| ≤ 1/n}, ‖Aλu‖₂ ≤ nᵏ, and the event has probability ≥ (2n)^{−m}. So Φ(ρ/4) ≤ m·log(2n) for ρ ≥ 4nᵏ, and K(ρ) ≤ 4nᵏlog(2n)/ρ. Hence λε ≥ 8nᵏlog(2n) gives K′ ≤ 1.
- *At the oracle* (§3): λε ≍ λ^{(2k+1)/(2k+2)} = n^{(2k+1)²/(4k+4)} up to V and logs. Against R1: (2k+1)/(4k+4) > k/(2k+3) ⇔ 4k² + 8k + 3 > 4k² + 4k, always true. Against R2: (2k+1)²/(4k+4) − k = 1/(4k+4) > 0, so R2 needs n^{1/(4k+4)} ≳ V^{(2k+1)/(2k+2)}log n (asymptotic only, as at k = 2 where it is n^{1/12}). The hypothesis δ_A ≤ λε/4 holds with room: (2k+1)²/(4k+4) − (k − 1) = (4k+5)/(4k+4).
- *Growing V under R1:* V ≲ n^{(4k+3)/(4k+6)} up to logs (k = 2: n^{11/14}).

### 2.2 L4q-M (mollified truth)

**Kernel.** For k + 1 ≤ w ≤ m/2 and each j, let Wⱼ ∋ j be a window of w consecutive indices (shifted inward at the boundary), x_l := (l − min Wⱼ)/(w − 1), b(x) := (1, x, …, xᵏ)ᵀ, G_w := w⁻¹Σ_{l∈Wⱼ}b(x_l)b(x_l)ᵀ, and

  K⁽ʲ⁾(l) := w⁻¹·b(xⱼ)ᵀG_w⁻¹b(x_l) on Wⱼ, 0 elsewhere.

- *Reproduction.* Σ_l K⁽ʲ⁾(l)g(l) = g(j) for every polynomial g of degree ≤ k. (Σ_l K⁽ʲ⁾(l)b(x_l)ᵀ = b(xⱼ)ᵀG_w⁻¹G_w.)
- *Size.* G_w is positive definite for w ≥ k + 1 (a nonzero polynomial of degree ≤ k cannot vanish at k + 1 nodes) and converges to the moment matrix of the uniform law on [0, 1], which is positive definite. So sup_{w≥k+1}‖G_w⁻¹‖ < ∞ and |K⁽ʲ⁾(l)| ≤ C_k/w.

**Localization.** For fixed i, l ↦ p_i(l) := C(i − l − 1, k) is a polynomial of degree k in l, and s_l(i) = p_i(l) whenever i ≥ l + 1 (the binomial vanishes for i − l − 1 ∈ {0, …, k − 1}).
- Rows i ≥ max Wⱼ + 1: every l ∈ Wⱼ has i ≥ l + 1, so Σ_l K⁽ʲ⁾(l)s_l(i) = p_i(j) = sⱼ(i).
- Rows i ≤ min Wⱼ + k: every s_l(i) with l ∈ Wⱼ vanishes, and so does sⱼ(i).
- So S(eⱼ − K⁽ʲ⁾) is supported on at most w rows, with entries ≤ (1 + C_k)·wᵏ/k!. Hence ‖S(eⱼ − K⁽ʲ⁾)‖ₙ ≤ C·w^{k+1/2}/√n.

**Minkowski over the atoms of u\*** (‖u\*‖₁ ≤ Vn^{−k}), with u_h := Σⱼu\*ⱼK⁽ʲ⁾:
1. ‖u_h‖₂ ≤ C·V/(nᵏ√w);
2. **‖S(u\* − u_h)‖ₙ² ≤ C·V²·(w/n)^{2k+1}**;
3. ‖u_h‖∞ ≤ C·V/(nᵏw).

**Bias.** Choose w ≍ n(ε/V)^{2/(2k+1)}, so that (2) is ≤ ε²/4. The half-radius shift charge is

  c_{K′}λ²‖u_h‖₂² ≤ C·λ²V²n^{−2k}w^{−1} = C·λ²·V^{(4k+4)/(2k+1)}·n^{−(2k+1)}·ε^{−2/(2k+1)}.

It is ≤ nε² iff ε^{(4k+4)/(2k+1)} ≥ C·λ²V^{(4k+4)/(2k+1)}n^{−(2k+2)}, i.e.

  **ε² ≥ C^{(2k+1)/(2k+2)}·V²·λ^{(2k+1)/(k+1)}·n^{−(2k+1)}.**

- The kernel must be signed for k ≥ 2 (a nonnegative kernel has a nonzero second moment). For k = 1 a symmetric nonnegative kernel works in the interior but not at the boundary; the Gram kernel above handles both. For k = 0 the box kernel is nonnegative.
- Range of w at the oracle: w ≍ n^{(2k+1)/(2k+2)}V^{−1/(k+1)}, so w → ∞ and w/n → 0 for every k ≥ 0.
- λ‖u_h‖∞ ≲ √n/w ≍ n^{−k/(2k+2)}V^{1/(k+1)} at the oracle: o(1) for k ≥ 1, O(1) for k = 0. The proof does not use it.

---

## 3. Oracle tuning and rate — PROVED

**Balance.** λ^{−1/(k+1)} = V²λ^{(2k+1)/(k+1)}n^{−(2k+1)} ⇔ λ² = n^{2k+1}/V². So

  **λ_{k,n} = n^{k+1/2}/V,  εₙ² = C·(log n)^{1/(2k+2)}·V^{1/(k+1)}·n^{−(2k+1)/(2k+2)}.**

The rate exponent is (2k+1)/(2k+2): 1/2, 3/4, 5/6, 7/8 for k = 0, 1, 2, 3. It is the rate n^{−2β/(2β+1)} at smoothness β = k + 1/2, which is the L₂ smoothness both of a BVᵏ truth and of a k-fold integrated walk. For comparison, the frequentist order-k trend-filtering rate is n^{−(2k+2)/(2k+3)} (quoted from memory, not rechecked); the gap is n^{1/((2k+2)(2k+3))}, i.e. n^{1/42} at k = 2.

**V-, n- and log-exponents of the prior budget** (the analogue of J5–J7), at λ = a·n^{k+1/2}/V:
- spread ratio φ(ε/2)/(nε²) ∝ V^{2/(2k+1)}ε^{−2/(2k+1)}(log m)^{1/(2k+1)}/(nε²). The exponents are: V: 2/(2k+1) − 1/((k+1)(2k+1)) − 1/(k+1) = 0; n: 0; log: 1/(2k+1) − 1/((2k+1)(2k+2)) − 1/(2k+2) = 0. So C_pr is free of V and n, as at k = 2, and the log power 1/(2k+2) is exactly what L3 costs;
- shift ratio: same V- and n-exponents (0), log exponent −1/(2k+1), so it → 0.

**Fallback (L4, u_h = u\*).** L4 is order-free. Cost λ‖u\*‖₁ ≤ λVn^{−k} ≤ nε² iff ε² ≥ λVn^{−(k+1)}. Balance: λ = (n^{k+1}/V)^{(k+1)/(k+2)} and ε² ≍ V^{1/(k+2)}n^{−(k+1)/(k+2)} (k = 2: (n³/V)^{3/4}, n^{−3/4}).
- At **k = 0** the two routes have the same n-exponent (λ ≍ n^{1/2}, ε² ≍ n^{−1/2}), and the fallback has the better V-dependence (V^{1/2} against V). So L4q and L4q-M are not needed at k = 0.

**Theorem B at order k.** The assembly (§3 of the package) uses the order only through:
- the dimension of the flat part: C₃ → C_{k+1}(bω) := ∫_{ℝ^{k+1}}e^{−(bω/2)min(|c|²,|c|)}dc < ∞, and V₃(ε√n/2)³ → V_{k+1}(ε√n/2)^{k+1};
- the prior budget above.

L2, (EM) and Propositions 1–2 are coordinatewise and order-free. I read the proofs of L5 and L6 for this:
- **L5.** Propriety uses only coercivity of the check loss; parametrization-independence and equivariance use only that the shift is in the null space of D. With N a basis of polynomials of degree ≤ k, every line holds with ℝ³ → ℝ^{k+1}.
- **L6.** Step 1 (orthogonal split; the c-section is a Euclidean ball of radius ε√n/2, now in ℝ^{k+1}), Step 2 (Jensen), Step 3 (mean ≤ 1.44C₁nε², variance ≤ 1.44nε², from L2) and Step 4 (Chebyshev) do not involve the order. Only ν(G) = V_{k+1}(ε√n/2)^{k+1}·Π_λ(u_h + B_{ε/2}) changes.

So Theorem B holds for every k ≥ 0 with the rate above and M > (2/b)(1.44C₁ + 1 + C_pr/ω). L2 was used through the package's statement only (it is a statement about one coordinate).

**Squared-loss corollary range** (flagged, not claimed, as at k = 2): ηᵏT₀ → 0 with η ≍ λ^{−1/(k+1)} and T₀ = n^{k+1}/λ gives λ ≫ n^{(k+1)²/(2k+1)} (k = 2: n^{9/5}). The oracle qualifies iff 2k² > 1, i.e. k ≥ 1.

---

## 4. L10-I at order k + 1 — PROVED with C_k finite; the value of C_k is SKETCH

**Statement.** For n ≥ k + 2 and δ ∈ ℝⁿ, a := ‖δ‖ₙ, T := nᵏ‖D⁽ᵏ⁺¹⁾δ‖₁, and k ≥ 1:

  **‖δ‖∞ ≤ 2√C_k·a + K_k·a^{2k/(2k+1)}·T^{1/(2k+1)}**,

where C_k := sup_{w≥k+1}C_eq(w) is the discrete Christoffel constant for degree k.

**Proof (changes only).**
- *Christoffel.* C_eq(w) := max_{l∈W}b(x_l)ᵀG_w⁻¹b(x_l), so max_W q² ≤ C_eq(w)·w⁻¹Σ_W q² for q of degree ≤ k. C_k < ∞ by the argument of §2.2 (G_w positive definite, convergent to a positive definite limit, b bounded on [0, 1]).
- *Newton.* On a window W of w ≥ k + 1 points starting at l₀: δ_l = q(l) + r(l), with q of degree ≤ k and r(l) = Σ_{j=l₀}^{l−k−1}C(l − j − 1, k)(Δ^{k+1}δ)ⱼ. Hence |r(l)| ≤ (wᵏ/k!)·Σ_W|Dδ| ≤ ρ_w := wᵏT/(k!·nᵏ).
- *Local mass.* If ρ_w ≤ s/(4√C_k), with s = ‖δ‖∞, then n a² ≥ w·s²/(4C_k), exactly as (★) in L10-I.
- *Choice of w.* w\* := n·(k!·s/(4√C_k·T))^{1/k}, so that ρ_{w\*} = s/(4√C_k).
  - w\* ≥ n: take w = n; s ≤ 2√C_k·a.
  - k + 1 ≤ w\* < n: take w = ⌊w\*⌋ ≥ ((k+1)/(k+2))w\*. Then a² ≥ c·s²(s/T)^{1/k}, i.e. s^{(2k+1)/k} ≤ C·a²T^{1/k}, i.e. s ≤ K·a^{2k/(2k+1)}T^{1/(2k+1)}.
  - w\* < k + 1: s < 4√C_k(k+1)ᵏT/(k!·nᵏ), and n a² ≥ s². Then a^{2k/(2k+1)}T^{1/(2k+1)} ≥ (s/√n)^{2k/(2k+1)}(c·s·nᵏ)^{1/(2k+1)} = c′·s·n^{(k − k)/(2k+1)} = c′s. ∎
- *Scale check.* A bump of height H and width r grid points has a ≍ H(r/n)^{1/2} and T ≍ H(n/r)ᵏ, so a^{2k/(2k+1)}T^{1/(2k+1)} ≍ H.

**Huber corollary.** If Δ²ₙ(δ) ≤ η and T ≤ T₀ with 16C_kη < 1 and (2K_k)^{(2k+1)/(k+1)}η^{k/(k+1)}T₀^{1/(k+1)} < 1, then ‖δ‖∞ ≤ 2√C_k·η^{1/2} + K_k·η^{k/(2k+1)}T₀^{1/(2k+1)}. Same self-bounding proof. The smallness condition is **ηᵏT₀ → 0** (k = 2: η²T₀).

**Value of C_k — SKETCH.** In the discrete Chebyshev (Gram) basis t_p on w nodes, with the classical formulas Σ_x t_p(x)² = (w+p)!/((2p+1)(w−p−1)!) and t_p(w−1) = (w−1)!/(w−p−1)! (quoted from memory), the Christoffel function at an endpoint is

  Σ_{p=0}^{k}(2p+1)·∏_{i=1}^{p}(w − i)/(w + i),

which reproduces Astra's F(β) at k = 2 and increases to (k+1)². If the maximum over nodes is at the endpoint, then **C_k = (k+1)²**: 4, 9, 16 for k = 1, 2, 3.
- k = 1: proved. In centred nodes the Christoffel function is 1 + t²/μ with μ = (w²−1)/12, increasing in |t|, so C_eq(w) = 1 + 3(w−1)/(w+1) and C₁ = 4.
- k = 2: proved (Astra's convexity argument).
- k ≥ 3: the endpoint maximum is classical for Legendre polynomials; I did not prove the discrete statement.

The lemma needs only C_k < ∞.

**k = 0.** The remainder bound is |r| ≤ T for every window, so there is no optimization in w: ‖δ‖∞ ≤ 2a + 4T (C₀ = 1; if T ≤ s/4 take w = n, otherwise s < 4T). This is the formula with exponents (0, 1). It gives no gain from a small ℓ₂ norm.

---

## 5. Lemma F and Lemma W′ with degree-k splines — PROVED

### 5.1 Lemma F

**Space.** For a knot set 𝒦 ⊂ {1, …, m}, V_𝒦 := {θ : (D⁽ᵏ⁺¹⁾θ)_l = 0 for l ∉ 𝒦} = range N ⊕ span{s_κ : κ ∈ 𝒦}, of dimension |𝒦| + k + 1: discrete splines of degree k. With h := ⌈m/J⌉, J′ := ⌊m/h⌋, 𝒦₀ := {h, 2h, …, J′h}, and 𝒦_J ⊃ 𝒦₀ any knot set of size J, P_J is the projector onto V_{𝒦_J} (dimension J + k + 1).

**Statement.** For k ≥ 1, n ≥ k + 2, 1 ≤ J ≤ m and every j:

  **‖(I − P_J)Seⱼ‖₂ ≤ c_{F,k}·h^{k+1/2} ≤ c_{F,k}·2^{k+1/2}·(n/J)^{k+1/2}**,

- c_{F,k} = (1 + Λ_k)·k^{k+1/2}/(k!·√(2k+1)) if J′ ≥ k + 1, where Λ_k ≤ 2ᵏ is the Lebesgue constant of k + 1 equispaced nodes;
- c_{F,k} = max{that, ((3k+1)/2)^{k+1/2}/(k!√(2k+1))} in every case.

(k = 2, Λ₂ = 5/4: 2.846 and 5.13, as in `FABLE_lemmaF_C2.md`. k = 1, Λ₁ = 1: 1.155.) For k = 0: ‖(I − P_J)Seⱼ‖₂ ≤ √h.

**Proof.** Sum bound: Σ_{t=k}^{T}C(t, k)² ≤ (k!)^{−2}Σ_{t≤T}t^{2k} ≤ (T + 1)^{2k+1}/((k!)²(2k+1)). (★)
- *(a)* ‖sⱼ‖₂² ≤ (n − j)^{2k+1}/((k!)²(2k+1)), by (★) with t = i − j − 1 ≤ n − j − 1.
- *(b)* q_j(i) := C(i − j − 1, k), as a polynomial of degree k in i, lies in range N, and sⱼ − q_j = −q_j·1{i ≤ j}. For i ≤ j, |C(i − j − 1, k)| = C(j − i + k, k). So ‖sⱼ − q_j‖₂² ≤ (j + k)^{2k+1}/((k!)²(2k+1)).
- *Interior (J′ ≥ k + 1, h ≤ j ≤ J′h).* Choose a ∈ {1, …, J′ − k} with κ := ah ≤ j ≤ κ + kh, knots κ_l := κ + lh (l = 0, …, k), and Lagrange weights a_l at x = (j − κ)/h ∈ [0, k]. They are exact on polynomials of degree ≤ k in the knot index. Let e := sⱼ − Σ_l a_l s_{κ_l}.
  - For i ≤ κ + k every term vanishes. For i ≥ κ + kh + 1 every index l′ ∈ {j, κ₀, …, κ_k} has i ≥ l′ + 1, so s_{l′}(i) = p_i(l′) and e(i) = p_i(j) − Σ_l a_l p_i(κ_l) = 0.
  - On the support, 0 ≤ s_{l′}(i) ≤ C(i − κ − 1, k), so |e(i)| ≤ (1 + Λ_k)·C(t, k) with t = i − κ − 1 ∈ [k, kh − 1]. By (★), ‖e‖₂² ≤ (1 + Λ_k)²(kh)^{2k+1}/((k!)²(2k+1)).
  - Λ_k ≤ 2ᵏ: for x ∈ [0, k], the sorted distances from x to the nodes satisfy d₍ᵢ₎ ≤ i − 1 for i ≥ 2, so ∏_{i≠l}|x − i| ≤ k!, and |ℓ_l(x)| ≤ k!/(l!(k − l)!) = C(k, l).
- *Left end (j ≤ h − 1).* By (b), dist² ≤ (h + k − 1)^{2k+1}/(…) ≤ (kh)^{2k+1}/(…), since (k − 1)(h − 1) ≥ 0.
- *Right end (j ≥ J′h + 1).* n − j ≤ m + k − J′h ≤ h + k − 1 ≤ kh, and (a) applies.
- *Fewer than k + 1 knots fit (m ≤ (k+1)h − 1).* min(j + k, n − j) ≤ (n + k)/2 = (m + 2k + 1)/2 ≤ (3k + 1)h/2; use (a) or (b).
- *k = 0.* V_J is the piecewise constants with jumps at the knots; sⱼ = 1{i ≥ j + 1}; with κ the largest knot ≤ j, s_κ − sⱼ = 1{κ < i ≤ j}, of norm ≤ √(h − 1); at the left end use sⱼ − 1. ∎

### 5.2 Lemma W′

For K(ρ, T₀) := {‖δ‖ₙ ≤ ρ, nᵏ‖Dδ‖₁ ≤ T₀} and bounded mean-zero independent εᵢ:

  E sup_K⟨ε, δ⟩ ≤ √n·ρ·√(J + k + 1) + c_{F,k}·√(2 log(2m))·T₀·n^{−k}·h^{k+1/2}
        ≤ √n·ρ·√(J + k + 1) + C_{F,k}·√(2 log(2m))·T₀·√n·J^{−(k+1/2)}.

The proof is that of W′ line by line: (I − P_J)N = 0; head by tr P_J = J + k + 1; tail by ‖u‖₁ ≤ T₀n^{−k}, Hoeffding and the maximal inequality over the columns of Lemma F; n^{−k}(n/J)^{k+1/2} = √n·J^{−(k+1/2)}. Balancing at J ≍ (T₀/ρ)^{1/(k+1)}:

  **E sup_K⟨ε, δ⟩ ≲ √n·ρ + √n·ρ^{(2k+1)/(2k+2)}·T₀^{1/(2k+2)}·√(log n).**

This is the Dudley width for entropy exponent 1/(k+1). (k = 0: √n·ρ^{1/2}T₀^{1/2}.)

**Old Lemma W at order k** (SVD truncation, Frobenius tail): tail T₀·n·q^{−(k+1/2)}, width n^{1/2+1/(4k+4)}ρ^{(2k+1)/(2k+2)}T₀^{1/(2k+2)}√(log n). The loss is n^{1/(4k+4)} (k = 2: n^{1/12}).

---

## 6. C1 at order k — PROVED for k ≥ 1 by substitution into the audited proof

### 6.1 What changes

- **T₀ := T·n^{k+1}/λ**, since prior draws have nᵏ‖u‖₁ ≈ nᵏm/λ. At the oracle, **T₀ = TV√n for every k**.
- **Radius.** (f/8)n r² ≥ C√n·r^{(2k+1)/(2k+2)}T₀^{1/(2k+2)}√(log n) ⇔ r^{(2k+3)/(2k+2)} ≥ C·n^{−1/2}T₀^{1/(2k+2)}√(log n) ⇔

  **r² = C_r·n^{−(2k+2)/(2k+3)}·T₀^{2/(2k+3)}·(log n)^{(2k+2)/(2k+3)} = C_r·T^{2/(2k+3)}·λ^{−2/(2k+3)}·(log n)^{(2k+2)/(2k+3)}.**

  At the oracle: r² ≍ V^{2/(2k+3)}n^{−(2k+1)/(2k+3)} (3/5, 5/7, 7/9 for k = 1, 2, 3). With the old Lemma W: r² ≍ T^{2/(2k+3)}n^{1/(2k+3)}λ^{−2/(2k+3)}, at the oracle n^{−2k/(2k+3)} (2/5, 4/7, 2/3).
- **(i) sup-norm condition.** s_K = 2√C_k·r + K_k·r^{2k/(2k+1)}T₀^{1/(2k+1)} → 0 ⇔ r^{2k}T₀ → 0.
  - With W′: r^{2k}T₀ ≍ n^{k+1}λ^{−(4k+3)/(2k+3)}(log n)^{2k(k+1)/(2k+3)}, so

    **λ ≫ n^{(k+1)(2k+3)/(4k+3)}·(log n)^{2k(k+1)/(4k+3)}.**

    (k = 2: n^{21/11}(log n)^{12/11}. k = 1: n^{10/7}(log n)^{4/7}. k = 3: n^{12/5}(log n)^{8/5}.)
  - With old W: λ ≫ n^{(2k²+6k+3)/(4k+3)} up to logs (k = 2: n^{23/11}; k = 1: n^{11/7}; k = 3: n^{13/5}).
- **(i′)** Vλ = o(n^{k+1}); s₀ = V/T₀ = Vλ/(Tn^{k+1}), which is n^{−1/2}/T at the oracle.
- **(ii)** from §§1–3.
- **Steps 5, 6, 8.** ℝ³ → ℝ^{k+1}: ∫_{ℝ^{k+1}}e^{−(a/2)‖c‖/(√n r)}dc = c_{k+1}(2√n r/a)^{k+1}; section volume V_{k+1}(√n r t)^{k+1}; t^{k+1} ≤ (k+1)!·eᵗ. The Chernoff step is unchanged: nᵏ‖u‖₁/T₀ = Γ/(Tn) with Γ = λ‖u‖₁ ~ Gamma(m, 1), E e^{Γ/2} = 2^m, and T ≥ 4 works for every k.
- Steps 0, 2, 3 (Bousquet), 4, 7 and the uniformity in ω are order-free. The side conditions hold for k ≥ 1: n r² ≍ n^{2/(2k+3)} ≫ log n, n r² = o(n), nε² ≍ n^{1/(2k+2)} = o(n r²), εnr → ∞.

### 6.2 Is the oracle inside the window?

- With W′: (k+1)(2k+3)/(4k+3) < k + 1/2 ⇔ 4k² > 3 ⇔ **k ≥ 1**.
- With old W: (2k²+6k+3)/(4k+3) < k + 1/2 ⇔ 4k² − 2k − 3 > 0 ⇔ **k ≥ 2**.

So:
- **k ≥ 2:** the audited C1 (with W) generalizes verbatim; W′ improves the rate.
- **k = 1:** the audited proof with W **fails** at the oracle (r²T₀ ≍ n^{1/10} → ∞). With W′ it holds: r² ≍ n^{−3/5}(log n)^{4/5}, r²T₀ ≍ n^{−1/10}(log n)^{4/5}, s_K ≍ n^{−1/30}(log n)^{4/15}. Lemma F is therefore a required input at k = 1, not an upgrade.
- **k = 0:** fails with either width.

### 6.3 k = 0 — needs a new idea

- T₀ ≍ √n does not tend to 0 and L10-I has no ℓ₂ gain, so Step 1 (‖δ‖∞ ≤ L on the body, hence the quadratic margin) is unavailable.
- Even the contraction part fails as written: Step 3 needs sup-norm for the margin; with the Huber margin L2 (vi) instead, the body would have to be a Δ²ₙ-ball, which is not a gauge body, so the ray argument of Step 2 does not apply as is.
- Possible routes — CONJECTURE, not examined: (a) a C1 in the loss H = nΔ²ₙ using H(δ/t) ≥ H(δ)/t² and the width of {H ≤ nr², TV ≤ T₀}; (b) a probabilistic sup-norm bound for the posterior instead of the deterministic interpolation.
- Theorem B (which uses no localization) still covers k = 0 under (EM).

---

## 7. C2 at order k — PROVED for k ≥ 1 by substitution

With nε² = C(log n)^{1/(2k+2)}V^{1/(k+1)}n^{1/(2k+2)}, so that **(nε²)^{2k+2} = C^{2k+2}·V²·n·log n**, and J := ⌊c·M·nε²⌋:

- **Knight, remainder (threshold 3f/(4ωf̄)), Cauchy–Schwarz:** coordinatewise, order-free.
- **Coarse score:** d = J + k + 1; E Q ≤ d/4, Var Q ≤ d/4; Chebyshev on {‖P_Jψ‖₂² ≤ J} gives probability ≤ (d/4)/(J − d/4)² → 0. Volume factor V_{k+1}(2a·nε²)^{(k+1)/2}.
- **Fine score:** t := Sᵀ(I − P_J)ψ, ‖t‖∞ ≤ t_∞ := C_{F,k}(n/J)^{k+1/2}√(2 log 2m) on an event of probability ≥ 1 − (2m)^{−3} (Lemma F at order k; uniform columns are essential).
  - *MGF condition.* 2ωt_∞/λ ≍ ωV√(log n)·J^{−(k+1/2)} ≍ **n^{−(2k+1)/(4k+4)}** → 0 (k = 2: n^{−5/12}).
  - *Log-MGF.* ≤ 8ω²·m·t_∞²/λ² ≲ ω²·V²·n·log(n)·J^{−(2k+1)} = C·ω²·(nε²)^{2k+2}/(cM·nε²)^{2k+1} = **C_fine·ω²·nε²/M^{2k+1}**. V cancels.
  - *Truth shift.* 2ωt_∞‖u\*‖₁ ≤ 2ωt_∞Vn^{−k} ≍ V√n·J^{−(k+1/2)}√(log n) ≍ **n^{1/(4k+4)}** = o(nε²) (k = 2: n^{1/12} against n^{1/6}).
- **Shells and endpoints:** order-free; O(log n) shells; threshold ω₁(f/8 − η)M > ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂²/M^{2k+1}.

**Result.** For k ≥ 1 (k = 1 with W′ inside C1): sup_ω∈[ω₁,ω₂] Πₙ,ω(‖θ − θ\*‖²ₙ > Mεₙ²) → 0 with εₙ² as in §3. The exponents of the C2 step itself are fine for k = 0 too; C2 fails there only because it imports ‖δ‖∞ ≤ s₀ from C1.

---

## 8. Lemma S at order k — PROVED (verbatim, every k ≥ 0)

- **§1** (conditional scale consistency): no difference operator appears.
- **§2** (compact containment). Changes, with k_τ := min(τ, 1 − τ):
  - *Roughness.* T_j := |(D⁽ᵏ⁺¹⁾y)ⱼ|; the endpoint coefficient of the stencil is ±1, so E T_j ≥ E W_j as before. T_j ≤ V/nᵏ + 2^{k+1}max_{j≤i≤j+k+1}|Zᵢ| (the absolute stencil sum is 2^{k+1}; 8 at k = 2). Terms more than k + 1 apart are independent. ‖Dθ‖₁ ≥ ‖Dy‖₁ − 2^{k+1}Q(θ)/k_τ ≥ nd/4 for Q(θ) < qn, **q = k_τd/2^{k+3}** (k = 2: k_τd/32).
  - *Evidence.* L3 at radius one: C_k(n^{k+1/2}/λ)^{2/(2k+1)}(log m)^{1/(2k+1)} = C_k·n·(log(m)/λ²)^{1/(2k+1)} ≤ n once λ ≥ C√(log m). The entries of S are ≤ nᵏ/k!, so ‖Su\*‖ₙ ≤ V.
  - *Tails.* ∫e^{−Q/(2s)}dc ≤ C·s^{k+1}; H₀^{k+1−n}; roughness cost 2^m e^{−λnd/8} against the IG moment b^{k+1−n}Γ(n + a − k − 1)/Γ(a) = e^{O(n log n)}. Needs only **λ/log n → ∞**.
- **§3** (transfer): order-free.
- **Hypothesis U** must come from C1, so the learned-σ conclusion needs k ≥ 1 (W′ at k = 1).

---

## 9. V0T / V2T with the floor Λ₋ = κ₋n^{k+1/2} — PROVED for k ≥ 1 by substitution

- **Floor and hyperprior.** Λ₋ := κ₋n^{k+1/2}; scaled hyperprior b_n ∝ n^{−(k+1/2)} keeps p_n([Λ₋, 2Λ₋]) = 1 − e^{−b_nΛ₋} constant; Felipe's constant b₀ gives → 1. Only −log p₀,ₙ = o(n r²) is used.
- **Body.** T₀ = T·n^{k+1}/Λ₋ = **(T/κ₋)√n for every k**. r² = C_r(T/κ₋)^{2/(2k+3)}·n^{−(2k+1)/(2k+3)}(log n)^{(2k+2)/(2k+3)} with W′; n^{−2k/(2k+3)} with old W.
- **Step 2 (σ containment):** §8 plus the two monotonicity remarks (L3 bound and e^{−λnd/8} both improve with λ). Verbatim.
- **Step 3 (mixed denominator on [Λ₋, 2Λ₋]):**

  ε² := C_ε·n^{−(2k+1)/(2k+2)}·[κ₋^{−1/(k+1)}(log m)^{1/(2k+2)} + κ₋^{(2k+1)/(k+1)}V²].

  First term: spread at ℓ ≥ Λ₋. Second term: bias at ℓ ≤ 2Λ₋, since V²Λ₋^{(2k+1)/(k+1)}n^{−(2k+1)} = V²κ₋^{(2k+1)/(k+1)}n^{−(2k+1)/(2k+2)}. One centre u_h (bandwidth w from §2.2) serves the whole window; (C) holds by R1 for n ≥ n₀ (§2.1). Verbatim.
- **Step 4 (frozen body):** C1 Steps 0–6 at λ = Λ₋. The key inequality nᵏ‖u‖₁/T₀ = (Λ₋/ℓ)·Γ/(Tn) ≤ Γ/(Tn) is order-free. (i′): VΛ₋ = κ₋Vn^{k+1/2} = o(n^{k+1}). **(i) is the binding point:**
  - old W: r^{2k}T₀ ≍ n^{−(4k²−2k−3)/(2(2k+3))}; → 0 iff k ≥ 2 (k = 2: n^{−9/14}; s_K ≍ n^{−9/70}; k = 3: s_K ≍ n^{−3/14});
  - W′: r^{2k}T₀ ≍ n^{−(4k²−3)/(2(2k+3))}; → 0 iff k ≥ 1 (k = 1: n^{−1/10}, s_K ≍ n^{−1/30}; k = 2: n^{−13/14}, s_K ≍ n^{−13/70}).
- **Step 5 and conclusion 3:** order-free.
- **Rates.** As proved for V0T (C1 only): n^{−2k/(2k+3)} with W (k ≥ 2), n^{−(2k+1)/(2k+3)} with W′ (k ≥ 1). The C2 upgrade to n^{−(2k+1)/(2k+2)} is uniform in ℓ ≥ Λ₋ for the same reason as at k = 2 (the fine term ω²n^{2k+2}J^{−(2k+1)}ℓ^{−2} decreases in ℓ; the truth shift is ℓ-free) — SKETCH, as in `FABLE_V2T_proof.md`.
- **Upper window for other floors (old W) — SKETCH:** bias below r² needs Λ₋ ≪ n^{4(k+1)³/(4k²+10k+5)} up to V and logs (k = 2: n^{108/41}).
- **Sampler.** λ | θ is Gamma with shape m + 1 = n − k and rate b_n + ‖D⁽ᵏ⁺¹⁾θ‖₁, truncated to [κ₋n^{k+1/2}, ∞).

---

## 10. Exponent table

| | k = 0 | k = 1 | k = 2 | k = 3 |
|---|---|---|---|---|
| Oracle λ | n^{1/2}/V | n^{3/2}/V | n^{5/2}/V | n^{7/2}/V |
| Rate ε² (n; log; V) | −1/2; 1/2; 1 | −3/4; 1/4; 1/2 | −5/6; 1/6; 1/3 | −7/8; 1/8; 1/4 |
| Small-ball exponent in x | 2 | 2/3 | 2/5 | 2/7 |
| Bias V²λ^α n^{−β} | λ¹n^{−1} | λ^{3/2}n^{−3} | λ^{5/3}n^{−5} | λ^{7/4}n^{−7} |
| Fallback λ; rate | n^{1/2}; n^{−1/2} | n^{4/3}; n^{−2/3} | n^{9/4}; n^{−3/4} | n^{16/5}; n^{−4/5} |
| (C) threshold R1 for λε | n^{1/6} | n^{3/5} | n^{10/7} | n^{7/3} |
| Oracle λε | n^{1/4} | n^{9/8} | n^{25/12} | n^{49/16} |
| L10-I exponents (a, T) | (0, 1) | (2/3, 1/3) | (4/5, 1/5) | (6/7, 1/7) |
| Christoffel C_k (SKETCH for k ≥ 3) | 1 | 4 | 9 | 16 |
| F column bound | h^{1/2} | h^{3/2} | h^{5/2} | h^{7/2} |
| W′ width (ρ, T₀) | (1/2, 1/2) | (3/4, 1/4) | (5/6, 1/6) | (7/8, 1/8) |
| C1 rate at oracle, W′ / W | n^{−1/3} / n⁰ (not valid) | n^{−3/5} / fails | n^{−5/7} / n^{−4/7} | n^{−7/9} / n^{−2/3} |
| C1 lower window, W′ / W | n¹ (oracle outside) | n^{10/7} / n^{11/7} | n^{21/11} / n^{23/11} | n^{12/5} / n^{13/5} |
| C2: J; MGF ratio; truth shift | n^{1/2}; n^{−1/4}; n^{1/4} | n^{1/4}; n^{−3/8}; n^{1/8} | n^{1/6}; n^{−5/12}; n^{1/12} | n^{1/8}; n^{−7/16}; n^{1/16} |
| V0T floor; T₀ | κ₋n^{1/2}; √n | κ₋n^{3/2}; √n | κ₋n^{5/2}; √n | κ₋n^{7/2}; √n |

**Constants that grow with k** (no exponent depends on them): c_k = (1.5(k+1))^{k+1} in L3 (9, 91.2, 1296 for k = 1, 2, 3); Λ_k ≤ 2ᵏ in F; C_k ≈ (k+1)² in L10-I; ‖G_w⁻¹‖ in L4q-M (the conditioning of a Hilbert-type matrix, exponential in k). For fixed k these only move n₀ and the multiplicative constants.

## 11. What I did not do

1. **No numerics.** Suggested checks, all cheap: σ_r(A_k)/(n^{k+1/2}r^{−(k+1)}) for k = 1, 3; max_j‖(I − P_J)sⱼ‖₂/h^{k+1/2} for k = 1, 3; the Christoffel maximum for k = 1, 3 against (k+1)².
2. **L2** was used through the package's statement, not its file. L5 and L6 were read and checked (§3).
3. **C1, C2, V0T at order k** are substitutions into proofs audited at k = 2. The substituted proofs have not been audited as wholes. The k = 1 case sits close to the edge (margin n^{1/14} in λ, s_K ≍ n^{−1/30}), so its n₀ will be very large.
4. **k = 0** beyond Theorem B: open (§6.3).
5. **Learned λ without a floor** at general k: not examined.
6. The frequentist comparison rate in §3 and the Gram-polynomial formulas in §4 are from memory.

---

## Theory Department: cross-family audit response (Astra, `reviews/AUDIT_astra_general_k.md`, 2026-11-23)

**Verdict: ACCEPT WITH FIXES.** All eleven findings are CONFIRMED; Theory rules that they **HOLD**. They agree with Theory's own exponent check (spread and bias balance at λ = n^{k+1/2}/V, giving n^{−(2k+1)/(2k+2)}).

Key outcomes:
- **The Christoffel constant C_k = (k+1)² is now PROVED for every degree** (Astra #5), closing the gap that had been proved only for k ≤ 2.
- L3 constant: exactly (3d/2)^d with d = k+1 (91.125 at k = 2).
- The k = 1 window margin is n^{1/14}(log n)^{−4/7}, which suffices.
- **k = 0:** a single spike of height √n·r defeats localization on the proposed body. Only Theorem B (under (EM)) survives at k = 0.

Fixes, editorial:
- restore the log factor in the fallback rate;
- state the stronger hyperprior window-mass bound needed by the sharp mixed-posterior rate (both named priors satisfy it).

**Status: the general-k extension (k ≥ 1) is PROVED and cross-family audited.**
