# VP review of L3 (small ball) and L8′ (bounded numerator)

*Fable (VP / senior advisor), 2026-11-22. Files reviewed in full: `L3_small_ball.md`, `L8p_bounded_numerator.md`, both check scripts, and their uses in `SKELETON.md`, `L6_evidence_lower_bound.md`, `L4q_quadratic_shift.md` (R1), `B_light_tail.md` and `STATEMENT_DRAFT.md` v3.1.*

| Lemma | Verdict |
|---|---|
| **L3** (φ(ε) ≤ 30x^{2/5}(log m)^{1/5} + 6) | **ACCEPT** |
| **L8′** ((a)–(e), Step 2 of Theorem A) | **ACCEPT WITH FIXES** |

Neither proof has a mathematical gap. Every step and every constant was re-derived by hand, and both numerical checks were re-run by me (Owls, single thread). The L8′ fixes concern the numerical-check section and three statements that are worded more loosely than the proof; none changes the result.

**What was not checked.** The Monte Carlo agreement quoted in L8′ (line 118) was not re-run; I replaced it by a deterministic quadrature check of identity (a) (finding 4). The NOTS job logs 2857810 and 2857877 are not in the repo, so I could not compare against them; my reruns reproduce the quoted L3 numbers.

---

## L3: ACCEPT

### What was verified

- **Step 1.** Laplace(λ) = √V·ξ with V ~ Exp(rate λ²/2): the characteristic function is λ²/(λ² + t²). Anderson's direction is right (Σ₁ ⪯ Σ₂ gives more mass under Σ₁ on a symmetric convex set), and B_ε is symmetric convex.
- **Step 2.** (1 − 1/m)^m ≥ 1/4 for m ≥ 2. This is why n ≥ 5 is needed.
- **Step 4.** C⁻ᵀC⁻¹ = tridiag(−1, 2, −1) with last diagonal entry 1, eigenvalues 4 sin²((2k−1)π/(4N+2)). Horn applied twice gives the index i + j + l − 2. With k = ⌊(r+2)/3⌋: 3k − 2 ≤ r, k ≥ r/3 and k ≥ 1, so monotonicity runs the right way. This is the fix I asked for in the v3 review, and it is applied correctly (line 43).
- **Step 6.** Tail: Σ_{r>K} r^{−6} ≤ 1/(5K⁵), then Markov, 1/4. Head: 2φ(1) = 0.4839, t₁ ≥ 0.8944·K^{−3}, per-factor bound 0.4291·(r/K)³, and K!/K^K ≥ e^{−K} give −3.85K. **No log K term**, as claimed.
- **Step 7.** log 4 + log(4/3) + 3.85 = 5.52 ≤ 6. (1.6·91.125²·2)^{1/5} = 7.672 ≤ 7.7. 3.85·7.7 = 29.65 ≤ 30.
- **Polylog power.** (log m)^{1/5} in φ is right and comes only from v₀ = 2 log m/λ².

### Fit with its users

- **L6 / SKELETON Step 1.** They need φ(ε/2) ≤ C·nε². L3 gives φ(ε/2) ≤ 39.6·x^{2/5}(log m)^{1/5} + 6. Against the budget κnε², at ε² = (log n)^c κ^{−5/6}λ^{−1/3}, the ratio is 39.6·(log n)^{1/5 − 6c/5}. So **L3 costs exactly (log n)^{1/6} in ε²: any c ≥ 1/6 closes the spread term**, and the resulting C_pr/ω is free of σ, as the statement claims.
- **L4q (R1).** 30·4^{2/5} = 52.2, and at ρ = 51·n^{10/7}(log m)^{1/7} I get K ≤ 0.49 + 0.15 < 1 for every n ≥ 5. The thresholds 51 and (half radius) 102 quoted in `L4q` and `B_light_tail.md` line 120 are correct.
- **Theorem B.** Uses L3 only through L6 and R1. Consistent.
- The statement matches the L3 row of `STATEMENT_DRAFT.md` (line 147) exactly.

### Numerical rerun (mine)

- Singular values of C_N against the closed form: relative error ≤ 3.0e-15 (N = 5, 50, 400).
- max_r σ_r(A)/(n^{5/2}r^{−3}) = **0.1040, 0.1213, 0.1241** at n = 50, 300, 1200. This matches lines 82–84.
- Extra: σ_r(C³) ≤ σ_k(C)³ with k = ⌊(r+2)/3⌋ holds for every r at all three n.
- Extra: direct Monte Carlo of φ(ε) at n = 6–40 gives φ = 0.7–6.2 where the bound gives 290–850. The bound is valid and loose by about two orders of magnitude at these sizes, as expected from the factor 730 in Step 4.

### Findings

1. **CONFIRMED (editorial, no effect on the result).** Lines 40, 45, 47, 64: 4.5³ = 91.125, so "(4.5n/r)³ = 91.1·…" rounds an upper bound downward. The claim σ_r(A) ≤ 91.1·n^{5/2}r^{−3} is still true, because (2n+1)/2 ≤ 1.5n has slack, but as written the step does not prove it. *Fix:* write 91.2 (or 91.125). Steps 6–7 are unchanged: 7.672 ≤ 7.7.
2. **CONFIRMED (evidence trail).** `checks/l3_singular_values.out` is still the Owls refusal message, not the output of job 2857810. Line 3 and lines 81–84 cite numbers that are nowhere in the repo. *Fix:* commit the job output over that file. My rerun confirms the numbers.
3. **CONFIRMED (editorial).** Line 16, "There is an absolute constant C such that", is left over; the statement has explicit constants and no C. Delete it. The L3 row of `STATEMENT_DRAFT.md` line 147 still says "numerical check pending".

---

## L8′: ACCEPT WITH FIXES

### What was verified

- **(a)** Both signs. For δ > 0, X = (1−τ)δ − clip(Z, 0, δ), and the layer-cake step gives the formula. For δ = −a < 0 the swap τ ↔ 1−τ, prefactor e^{−ωτa} and integrand τ − Fᵢ(−s) are right. The identity itself needs no margin assumption, which is what Proposition 1 of Theorem B relies on.
- **(b)** Each of the four steps. log(h − a) ≤ log h − a/h; Hoeffding h ≤ e^{t²/8}; ψ″(0) = τ(1−τ); sup|ψ‴| = 1/(6√3), attained at q(1−q) = 1/6; 1/(36√3) = 0.016038 ≤ 0.01604; 2·0.01604 ≤ 0.0321. The inequality holds for B of either sign. The δ < 0 case is symmetric because every bound used is invariant under τ ↔ 1−τ.
- **"In particular".** B ≥ η − ω̄Δ(1 + ω̄Δ/8 + 0.0321/(τ(1−τ))) ≥ η/2 on Δ ≤ Δ₀. Correct.
- **(d)** Tonelli and independence; Σmᵢ ≥ (f/2)n‖δ‖ₙ²; the c-section lies in a ball of radius √n·Δ, so ν(E₁) ≤ V₃(√nΔ)³.
- **(e)** The ratio (2Δ/ε)³, the exponent [BfM/2 − (1.44C₁ + 1) − C_pr/ω]·ωnε² and the threshold on M all follow from (d) and L6 as stated. Step 2 closes given L6.

### (c) of the brief: the margin condition and the slack

- **The margin used is the right one.** The proof uses (A2) only through mᵢ(δ) ≥ fδ²/2 on |δ| ≤ L and Fᵢ(0) = τ. So f is the **secant** constant of (A2), and ω̄ = f/(τ(1−τ)) is exactly the ω̄ of (A4).
- **The slack matches (A4) as written**, ω ≤ (1−η)ω̄, i.e. σ ≥ σ̄/(1−η). It matches "σ ≥ (1+η)σ̄" only after relabelling: σ ≥ (1+η′)σ̄ is the lemma's hypothesis with η = η′/(1+η′), which gives **B ≥ η′/(2(1+η′))**, not η′/2, and Δ₀ computed from η′/(1+η′). Anyone quoting the lemma in the σ-form must carry that factor (finding 5).

### Numerical rerun (mine)

I re-ran inequality (b) with f set to the **secant** constant inf_{0<|δ|≤L}|F(q+δ) − τ|/|δ|, L = 0.5, on η ∈ {0.02, 0.1, 0.3}, Δ ∈ {0.005, …, 0.5}, 40 values of δ per cell, with the lemma's constant 0.0321.

- **(b) holds at every grid point in all 18 rows**: Normal, Cauchy, Laplace, t₂, lognormal(1.5) and Uniform(−1, 1), each at τ ∈ {0.05, 0.5, 0.9}.
- **The excluded row passes.** Lognormal, τ = 0.05: secant f = 0.1000, ω̄ = 2.105; the bound holds at all 720 points (smallest lhs/rhs over B > 0 is 3.15, where ≥ 1 means "holds").
- **The bound is not vacuous.** B > 0 on 280–560 of 720 points per row. Tightest case: Uniform, τ = ½, η = 0.02, lhs/rhs = 1.026.
- **Sharpness (c).** At 1.05× the point-density threshold, log E e^{−ωX} > 0 at δ = ±0.05 and 0.01 (Normal and Uniform, τ = ½); at 0.98× it is negative.
- **Identity (a)** in its stated form agrees with direct quadrature of E exp(−ω[ρ_τ(Z−δ) − ρ_τ(Z)]) to 9.3e-11 over 180 cases (four laws, three τ, three ω, δ ∈ {−2, −0.3, 0.05, 0.3, 3}).

### Findings

4. **CONFIRMED. The excluded row is inside the lemma's hypotheses; the stated reason for excluding it is wrong** (line 119; `checks/l8p_mgf.py`, the line `f = dist.pdf(q+ss).min()`).
   - (A2) is a secant condition (`STATEMENT_DRAFT.md` line 33 says so explicitly). For lognormal(1.5) at τ = 0.05, q = 0.0848 and L = 0.5: on the left |F(q+δ) − τ|/|δ| falls to 0.05/0.5 = 0.1 at δ = −0.5, and on the right it stays above 0.6. So **(A2) holds with f = 0.1**, although the density vanishes on part of the window.
   - The script's f is the minimum density. That is a valid but stricter surrogate; it is zero here, so the script cannot test this row. That is a limitation of the script, not a failure of (A2).
   - This matters for the stated result because it is the only row where the secant and the density differ in kind (a flat piece of F inside the window), which is exactly the case the secant formulation of (A2) exists to cover.
   - *Fix:* compute f as the secant constant in the script, rerun, and replace line 119 by the result. With that change the row passes (above), and so do two more flat-piece rows, Uniform at τ = 0.9 and 0.05. Also change the script's 0.0322 to the lemma's 0.0321; as written it tests a slightly weaker inequality than the one stated.
   - The job output is not in the repo. Commit it next to the script.
5. **CONFIRMED. Stale non-strict slack.** `L8p` line 5 says "Theorem A (σ ≥ σ̄)" and `SKELETON.md` line 7 says "Theorem A (milestone, σ ≥ σ̄ = τ(1−τ)/f)". The equality case is false (Astra's uniform example; my rerun shows the cubic gain at ω = ω̄). *Fix:* both should read ω ≤ (1−η)ω̄, i.e. σ ≥ σ̄/(1−η). If the σ-form "σ ≥ (1+η)σ̄" is used anywhere, state B ≥ η/(2(1+η)). `SKELETON.md` lines 3, 16, 37, 43, 55 and 61 still cite statement v2.1 and call Step 2 "to be written".
6. **CONFIRMED. (c) uses two different f.** Line 35 says "if Fᵢ has density f at 0 and ω > ω̄". With ω̄ as defined in the Setting (secant f), this is false for any law whose point density fᵢ(0) exceeds the secant constant: for ω̄ < ω < fᵢ(0)/(τ(1−τ)) the log-MGF is negative near 0. The proof (lines 81–85) proves the point-density version. *Fix:* state (c) as "if Fᵢ has density fᵢ(0) at 0 and ω > fᵢ(0)/(τ(1−τ)), then …; hence ω̄ cannot be improved uniformly over 𝒫ₙ, since the class contains laws with fᵢ(0) = f." `B_light_tail.md` line 22 already uses the point-density form.
7. **CONFIRMED (one-word fix). (d) needs B ≥ 0.** Line 91 passes from exp{−BωΣmᵢ} to exp{−Bω(f/2)n‖δ‖ₙ²}; that direction requires B ≥ 0, while (b) and the definition of B allow any sign. *Fix:* add "if B = B(ω, Δ) ≥ 0" to (d) at line 37. (e) is unaffected, since it is used with B ≥ η/2.
8. **PLAUSIBLE (wording only).** (e), line 45: "tends to 0 whenever nε² → ∞ faster than log n" also needs log(1/ε) = O(log n), which the proof assumes at line 99. True at every tuning in the theorem. Put the condition in the statement.

### Fit with its users

- **SKELETON Step 2 / Theorem A.** (d)–(e) deliver more than the skeleton asks: an explicit B in place of η′, and f/2 in place of c₀. B does not depend on f̄, so the skeleton's "η′(η, Δ, f, f̄)" can drop f̄. On E₁ with Δ ≤ min(1, L) the two losses coincide, so the skeleton's Δ²ₙ form and the lemma's ‖·‖ₙ² form are the same event.
- **Constants.** With B ≥ η/2, M > (4/(ηf))·[1.44C₁ + 2 + C_pr/ω]. Since C_pr/ω is free of σ (see L3 above) and Δ₀ depends on (η, ω̄, τ, L) only, M is free of σ, as `STATEMENT_DRAFT.md` line 73 claims.
- **Theorem B.** Proposition 1 uses the intermediate form of (a) (line 51), which holds without (A2). The "Local" constraint uses (c) in the point-density form. Proposition 2's optional remark uses (b) as stated. All consistent.
- **Row in `STATEMENT_DRAFT.md`** (line 160): matches (b) and (e).

---

## Summary for HQ

- **L3: ACCEPT.** Proof, constants and the (log m)^{1/5} power are correct; the floor index and full-product head bound are applied correctly. It costs (log n)^{1/6} in ε², so c ≥ 1/6. Three editorial items (91.1 → 91.2, commit the real job output, delete a leftover clause).
- **L8′: ACCEPT WITH FIXES.** The proof of (a)–(e) is correct and Step 2 closes given L6. The margin is the secant f of (A2) and the slack is (A4)'s ω ≤ (1−η)ω̄. Fixes: (4) the excluded lognormal row is **inside** (A2) with secant f = 0.1 and passes when tested properly, so the check should use the secant constant and count 15 of 15 rows; (5) remove the stale non-strict "σ ≥ σ̄" in L8′ and the skeleton; (6) state (c) with the point density; (7) add B ≥ 0 to (d).
