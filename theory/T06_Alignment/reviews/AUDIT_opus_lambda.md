# Independent referee report on `astra_learned_lambda.md` (learned λ)

*Referee: Opus (independent), 2026-11-23. Read-only audit of `theory/T06_Alignment/astra_learned_lambda.md` against `T05_Proofs/THEOREM_B_COMPLETE.md` and `T05_Proofs/B_light_tail.md`. Line numbers refer to the audit target unless stated otherwise.*

## Verdicts

| Part | Verdict |
|---|---|
| (1) Fixed-small-σ counterexample (l. 5–24) | **ACCEPT WITH FIXES.** Every step and constant holds. The only fix is the wording of the "radial explanation" inference (#1). Two clarity fixes are optional (#2, #3). |
| (2) Mixed-prior contraction under (EM) (l. 26–45) | **ACCEPT WITH FIXES.** Both rates, the prior budget, the mixed denominator, the numerator and the H + H² conversion are correct. The fixes are citations, quantifiers and explicit constants only (#4, #5). |
| (3) One-sided λ control (l. 47) | **ACCEPT.** The constants are verified below. |
| (4) Joint decomposition (d3) (l. 51–60) | **ACCEPT WITH FIXES.** The inequality and the propriety argument are correct. The fixes are to name a canonical conditional version and to state the prior-independence structure as a hypothesis (#6, #7). The transfer paragraph (l. 62) is a SKETCH, and one point in it needs checking (#8). |

No mathematical gap was found. None of the findings changes a stated rate, exponent or threshold.

## Findings

1. **CONFIRMED: the radial explanation overstates what fails (l. 24).** The tail computation is correct (verified below). So is the statement that R = ‖u‖₁ has infinite positive exponential moments under the mixture. But the inference "so the prior exponential-moment estimate in C1's TV cone cannot be integrated over this hyperprior" is not accurate as worded.
   - C1's estimate (C1 l. 74, 110) uses the *λ-scaled* pivot Γ = λ‖u‖₁ ~ Gamma(m, 1). The pivot is free of λ, so it survives mixing exactly: λR = G_m in the representation on l. 24.
   - What fails is any **λ-free** TV radius. C1's radius T₀ = Tn³/λ becomes random under the mixture, and it is useful only if λ is bounded below by a diverging sequence. In the counterexample λ ≤ 16, so T₀ ≍ n³, which is vacuous.
   - **Fix.** Replace the sentence with: "The pivot λ‖u‖₁ ~ Gamma(m, 1) survives mixing, but C1's cone radius Tn³/λ then depends on λ. A λ-free radius would need exponential moments of ‖u‖₁, which are infinite under the mixture. The evidence comparison above shows that the conclusion itself fails."

2. **CONFIRMED (cosmetic): the Hadamard constant (l. 15).** Hadamard's inequality applied to DDᵀ gives J_n ≤ (1 + 9 + 9 + 1)^{m/2} = 20^{m/2} ≈ 4.47^m. The stated bound 8^m is valid but is not what "the stencil row norms" yield.
   - A numerical check (R, n = 6–80) gives log J_n / m = 1.15 → 0.20, against log √20 = 1.50. The determinant of the last-m-column block is exactly 1 at every n tested, as the triangularity argument says.
   - **Fix.** Write J_n ≤ 20^{m/2} ≤ 8^m. Nothing downstream changes: the lower tail on l. 22 keeps the factor (4a)^m.

3. **CONFIRMED (clarity): say explicitly that the counterexample violates (EM), and record the constants.** Parts (1) and (2) are consistent only because the counterexample's σ lies far outside (EM). The note never says so.
   - For the uniform law, F′(q) = ½. (EM) forces ½ ≥ ω/4 + 2b, so ω < 2. The counterexample has ω > 1/(5.87·10⁻⁵) ≈ 1.7·10⁴.
   - The constants, re-computed: K = 23.947; σ-threshold (q − h)/(2(K+1)) = 5.872·10⁻⁵; at σ = 0.99× threshold the lower-tail condition needs a < 3.5·10⁻¹²; the polar constant is ∫e^{−‖c‖/(4σ)}dc = 512πσ³.
   - **Fix.** Add one sentence after l. 13: "At this σ, (EM) fails (the point-density threshold needs ω < 2), so there is no conflict with the (EM) theorem below." Optionally add the numbers.

4. **CONFIRMED: complete the citations and quantifiers in the (EM) theorem (l. 28–37).**
   - (a) **Missing joins.** Case 1 needs J5 (spread), J7 (shift at the upper endpoint 2n^{5/2}/V, i.e. a₂ = 2), and **J8**. J8 supplies δ_A ≤ λε/4, K′ ≤ 1 and 3 ≤ w ≤ m/2. These are lower-endpoint conditions that are monotone in λ, so they hold on the whole window for n ≥ n₀(V). The text cites only "§§2.3–2.7 and join J7".
   - (b) **Quantifier on c.** The theorem statement (l. 30–32) drops the requirement c ∈ [c₋, c₊]. Uniformity of the window mass P(G_{a₀} ∈ [c/V, 2c/V]) needs it. **Fix:** restate it in the display.
   - (c) **Optional extension.** The same proof covers any b_n ≤ c₊n^{−5/2} with log(1/b_n) = o(n x_n), because the window's hyperprior mass is then only polynomially small. This is not needed now.

5. **CONFIRMED: write the denominator event and the M threshold explicitly (l. 43–45).** The argument is correct (verified below), but the constants should be visible.
   - Set Ω := {T ≤ (4C₁ + 1)n x_n}, so that P(Ωᶜ) ≤ 4/(n x_n).
   - On Ω, N ≥ V₃(ε√n/2)³·p_n(window)·e^{−C_w n x_n}·e^{−ω(4C₁+1)n x_n}. Here C_w is the window's prior-budget constant, i.e. C_pr for case 1, and 2b₀ + (case-2 L3/L4 constant) for case 2.
   - "Absorbing the flat volume" needs V₃(ε√n/2)³ ≥ 1, which holds once n x_n ≥ 4V₃^{−2/3}. Say so.
   - Then E Π(H > Mn x_n | y) ≤ C₃(v)·exp{−(vM/2 − C′)n x_n} + 4/(n x_n), with C′ = ω(4C₁ + 1) + C_w. This matches Theorem B's form M > (2/b)(1.44C₁ + 1 + C_pr/ω), with 4C₁ in place of 1.44C₁ because of the 2ε support radius. The support bound is actually 3ε/2, so 9C₁/4 would also do.

6. **CONFIRMED: use a canonical conditional version in (d3) (l. 53–58).** Π(σ ∉ I | y, λ = ℓ) is a regular conditional probability, defined only up to Π(dλ | y)-null sets. A supremum over ℓ ∈ J is meaningful only for a named version.
   - **Fix.** Define it for **every** ℓ > 0 as the explicit ratio of integrals at fixed λ = ℓ. This ratio is proper and positive for every ℓ, by the same bound J_n(ℓ/2)^m and the unit-mass AL integral as on l. 60.
   - Also note measurability. At fixed data, both suprema (over (s, ℓ) ∈ I × J, and over ℓ ∈ J) are suprema of functions that are continuous in (s, ℓ). Continuity follows by dominated convergence on compact subintervals, so a countable dense set suffices. The inequality itself is correct.

7. **CONFIRMED: hidden assumption about the prior structure in (d3) and l. 62.** Two steps rely on the joint prior factorizing as dc·Π_λ(du)·p_n(dλ)·π(ds), with the difference prior **not scaled by σ**:
   - the identification of the first term with the fixed-(s, ℓ) trend posterior Π_{s,ℓ};
   - the remark that "the IG conditional given θ … is unchanged" (Lemma S §1 transfer).

   This holds for BQTF: `engineering/E02_Rate_Sims/e02_lib.R` l. 5 has target ∝ exp{−Σρ_τ/σ − λ‖Dθ‖₁}. It fails for the σ-scaled Bayesian-lasso form used by Onizuka et al. (`T01_Prior_Art/REPORT.md` l. 42), which a referee may compare against.

   **Fix.** State the factorization as a standing hypothesis at the top of (d3).

8. **PLAUSIBLE: the sketch's "data events are common" claim needs one check (l. 62).** Lemma S §2 is uniform over deterministic schedules, i.e. the supremum sits **outside** the expectation. The third term of (d3) needs E sup_{ℓ∈J}.
   - The sketch asserts that Lemma S §2's data events are λ-free, and that both its L3 radius-one bound and its roughness cost are monotone in λ. In that case the lower endpoint inf J controls every ℓ ∈ J on one common event. My reading of Lemma S §2 (l. 38–47) is consistent with this: the radius-one ball is centered with no λ-dependent shift cost, and the roughness term e^{−λ‖u‖₁} is decreasing in λ.
   - The check has not been written out. **Fix:** when the sketch is promoted, state it as a lemma, "Lemma S §2 holds with sup_{ℓ ≥ ℓ_n} inside E_P whenever ℓ_n/log n → ∞", and prove the monotonicity explicitly.

## Verified calculations (no finding)

**Part (1).**
- *Jacobian.* The inverse map is θ ↦ (Nᵀ(I − SD)θ, Dθ). Adding NᵀS·(rows of D) to the top block gives the stacked matrix [Nᵀ; D]. Its row Gram matrix is diag(I₃, DDᵀ) because DN = 0. So J_n = √det(DDᵀ), and dc du = J_n dθ in the right direction.
- *Cauchy–Binet.* In the last m columns, row j has entry 1 at column j + 3 and entries only at earlier selected columns, so the block is unit lower-triangular. Its determinant is 1, and J_n ≥ 1.
- *Cube.* On the cube: Q ≤ nh/2; |θᵢ| ≤ 1 + h; ‖Dθ‖₁ ≤ 8m(1 + h); the Laplace density at λ ∈ [1, 2] is ≥ 2^{−m}e^{−16n(1+h)}; −log p_n([1, 2]) = (5/2)a₀ log n + O(1), uniformly in c ∈ [c₋, c₊] (or O(1) for a fixed rate).
- *Evidence bound.* Collecting terms: −log Z ≤ n[16(1 + h) + log(1/h) + h/(2σ)] − 3 log 2 + O(log n) − log J_n ≤ n(K + h/(2σ)) for large n. This is uniform over y ∈ [−1, 1]ⁿ.
- *Q ≥ qn.* We have Q ≥ ½‖y − θ‖₂ ≥ ½‖Nᵀ(y − θ)‖₂ = ½‖c − Nᵀ(y − Su)‖₂. The half-likelihood split gives ≤ 512πσ³e^{−qn/(2σ)}. The ratio is ≤ 512πσ³·exp{−n[(q − h)/(2σ) − K]} ≤ 512πσ³e^{−n} under the stated threshold (which uses K + 1).
- *Conclusion.* The LLN gives Q(0)/n → ¼. The Lipschitz step ‖θ‖₁ ≤ n‖θ‖ₙ gives ‖θ‖ₙ > 2(1/5 − 1/256) ≈ 0.392 > ¼.
- *Upper tail.* Each stencil has E|(Dy)_j| ≥ E|y| = ½ (conditional median argument). The stencils are 3-dependent and bounded by 8, so Chebyshev gives ‖Dy‖₁ ≥ n/4. The column sums of |D| are ≤ 8, so ‖u‖₁ ≥ n/4 − 16qn = 3n/16 ≥ n/8. The conditional λ | θ is Gamma(m + a₀, b_n + ‖u‖₁), so λ > 16 forces a Gamma(m + a₀, 1) variable above 2n, which has probability o(1) uniformly in θ. Splitting Π(λ > 16 | y) over {Q < qn} is valid.
- *Lower tail.* The density is ≤ J_n(a/2)^m ≤ (4a)^m, and ∫e^{−Q/σ}dθ = (4σ)ⁿ exactly. The ratio is ≤ (4a)^{−3}exp{n[log(16aσ) + K + h/(2σ)]} ≤ (4a)^{−3}e^{−n}.
- *Radial representation.* λR | λ ~ Gamma(m, 1) is free of λ, so G_m ⫫ G_{a₀}, and R = b_n G_m/G_{a₀}. The marginal density is ∝ (b_n + ‖u‖₁)^{−(m+a₀)}. Also x^{a₀}P(R > x) → b_n^{a₀}·Γ(m + a₀)/{Γ(m)Γ(a₀ + 1)}, using the bound F_{a₀}(z) ≤ z^{a₀}/Γ(a₀ + 1) and dominated convergence.

**Part (2).**
- *Case 1 window mass.* b_nλ ∈ [c/V, 2c/V], so the hyperprior mass of the window is bounded below on the compact c-range.
- *Case 2 window mass.* −log p_n([L_n, 2L_n]) ≤ 2b₀L_n + O(log n).
- *Case 2 shift.* The L4 charge is ≤ 2L_nV/n².
- *Case 2 spread.* L3 at radius ε/2 gives 30·2^{2/5}·n λ^{−2/5}x_n^{−1/5}(log m)^{1/5} + 6. With λ ≥ L_n = n x_n this is O(n x_n) iff n^{−2/5}(log n)^{1/5} ≲ x_n^{8/5}. Equality holds at x_n = n^{−1/4}(log n)^{1/8}: indeed (1/4)(8/5) = 2/5 and (1/8)(8/5) = 1/5. Balancing b₀L ≍ n x_n against the L3 term gives L = x_n^{−3} and x_n = n^{−1/4}, so this is the optimum of the method.
- *Case 1 rate.* x_n matches Theorem B's primary ε² with V fixed.
- *Mixed denominator.* The support has ‖δ‖ₙ ≤ 3ε/2 ≤ 2ε. E T ≤ C₁Σδᵢ² ≤ 4C₁n x_n by L2(iv). Var T = Σᵢ Var(∫Xᵢ dg) ≤ Σᵢ∫E Xᵢ² dg ≤ 4n x_n, by independence, Jensen and L2(i). Chebyshev at deviation n x_n gives failure probability ≤ 4/(n x_n). Jensen gives ∫e^{−ωℛ}dg ≥ e^{−ωT}. No fixed-λ L6 event is used, and this is correct.
- *Numerator.* Tonelli and (EM) give e^{−vMn x_n/2}∫e^{−vH/2}. The pointwise bound min(δᵢ², |δᵢ|) ≥ δᵢ²/max(1, ‖δ‖₂) gives H ≥ min(‖δ‖₂², ‖δ‖₂). Projection onto N then reduces the c-integral to C₃(v), free of n, λ and u.
- *Squared loss.* Σδᵢ² ≤ H + H². With H ≤ Mn x_n: case 1 gives ‖δ‖ₙ² ≤ Mx_n + M²n^{−2/3}(log n)^{1/3}, which is the stated rate. Case 2 gives n x_n² = n^{1/2}(log n)^{1/4} → ∞, so there is no squared-loss consistency, as stated.

**Part (3).**
- The numerator on {λ > KL_n} is ≤ C₃(2v)·p_n(λ > KL_n).
- E e^{b₀λ/2} = (1 − ½)^{−a₀} = 2^{a₀}, so p_n(λ > KL_n) ≤ 2^{a₀}e^{−b₀KL_n/2}.
- Combined with the case-2 denominator (L_n = n x_n), E Π(λ > KL_n | y) ≤ C·2^{a₀}e^{−(b₀K/2 − C′)L_n} + 4/(n x_n), so K > 2C′/b₀ suffices.
- This gives posterior λ ≲ n^{3/4}(log n)^{1/8}, uniformly over the class, under (EM) only.

**Part (4).**
- The union bound over the rectangle's complement and the bound of the integrated conditional tail by its supremum are correct.
- *Propriety.* The θ-density is ≤ J_n(λ/2)^m. Each AL factor integrates to exactly 1 in θᵢ for every s, so ∫ ≤ J_n2^{−m}Γ(m + a₀)/(Γ(a₀)b_n^m) < ∞, and the evidence is positive. This needs only *some* proper prior on s, not IG specifically.
