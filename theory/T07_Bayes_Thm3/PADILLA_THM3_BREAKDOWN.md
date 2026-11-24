# T07: Padilla–Chatterjee Theorem 3, broken down, and what a Bayesian version can keep

*Research sub-agent for Theory, 2026-11-24. Accepted by the Theory head 2026-11-24 (σ₀ generalization folded in). Reading task; no proof is written here. Source: `literature/Padilla_Risk Bounds for Quantile Trend Filtering.pdf` (Thm 3, §3, Appendices A–C). Equation and lemma numbers are Padilla's. The statement itself is in `T07a_statement.tex`.*

## 0. Verdict in five lines

1. Thm 3 is stated on the TV scale and proved on the raw scale. The two agree exactly: `λ_raw = n^{r−1}·λ_TV` (§2).
2. The proof uses Assumption A in one place only (Lemma 13). `V* = Θ(1)` and `c > c_{1,ε}` do the rest (§4).
3. **The target as posed (posterior contraction at Padilla's rate, σ = 1, λ at Padilla's order) is false.** The posterior is wider than its mode: its spread is ≍ λ_raw^{−1/r} = n^{−(2r−1)/(2r+1)}, against the target n^{−2r/(2r+1)}. For r = 3 this is n^{−5/7} against n^{−6/7}. Proved at r = 3 (project Theorem LB), heuristic at general r, and seen in E-06 (§6).
4. Owner's decision: the main theorem is the best rate at σ = 1, namely **n^{−(2r−1)/(2r)}·(log n)^{1/(2r)} at λ_raw = c·n^{(2r−1)/2}** (λ_TV = c·n^{1/2}). One new assumption is needed: the upper half of the margin.
5. Padilla's rate survives for the **posterior mode**, which is PQTF exactly. That is a corollary of his Thm 3 with nothing to prove.

## 1. (a) The exact statement

**Objects.**
- `D^{(1)}θ = (θ_2−θ_1, …, θ_n−θ_{n−1})`, `D^{(r)} = D^{(1)}D^{(r−1)}`, an (n−r)×n matrix.
- `TV^{(r)}(θ) = n^{r−1}‖D^{(r)}θ‖_1` (eq. (1)). `V* = TV^{(r)}(θ*)`.
- PQTF (eq. (3)): `θ̂_λ ∈ argmin_θ { Σ_i ρ_τ(y_i−θ_i) + λ·TV^{(r)}(θ) }`.
- Loss (eq. (4)): `Δ²_n(v) = (1/n) Σ_i min{|v_i|, v_i²}`. Also `Δ²(v) = n·Δ²_n(v)` (Definition 1). **The 1/n is inside Δ²_n; the proof works with the unnormalized Δ².**

**Assumption A.** There are constants L > 0, f > 0 such that for every n and every δ with ‖δ‖_∞ ≤ L: `|F_{y_i}(θ*_i+δ_i) − F_{y_i}(θ*_i)| ≥ f·|δ_i|` for all i.

**Theorem 3.** Let y_1, …, y_n be independent and satisfy Assumption A, with θ*_i the τ-quantile of y_i. Suppose `V* = Θ(1)`. Given ε ∈ (0,1) there is `c_{1,ε}`, depending only on ε and V*, such that if

  `λ = c·n^{1/(2r+1)}(log n)^{1/(2r+1)}`,  `c > c_{1,ε}`,

then `Δ²_n(θ̂_λ − θ*) ≤ c_{2,ε}·n^{−2r/(2r+1)}(log n)^{1/(2r+1)}` with probability at least 1−ε, where `c_{2,ε}` depends only on c, ε and V*.

Any fixed τ ∈ (0,1) and integer r ≥ 1. No moment condition.

## 2. The scaling, sorted out

The proof (App. C) starts from `θ̂ = argmin Σρ_τ(y_i−θ_i) + λ‖D^{(r)}θ‖_1`, a **raw** λ, and sets (eq. (44))

  `λ_raw = 3c_ε · n^{(2r−1)/(2r+1)} (log n)^{1/(2r+1)} · ‖D^{(r)}θ*‖_1^{−(2r−1)/(2r+1)}`.

With `‖D^{(r)}θ*‖_1 = V*·n^{1−r}`:

| Quantity | Raw scale (proof) | TV scale (statement) |
|---|---|---|
| Penalty | `λ_raw‖D^{(r)}θ‖_1` | `λ_TV·TV^{(r)}(θ)`, `λ_TV = λ_raw/n^{r−1}` |
| Padilla's λ | `3c_ε (V*)^{−(2r−1)/(2r+1)} · n^{r(2r−1)/(2r+1)} (log n)^{1/(2r+1)}` | `c·n^{1/(2r+1)}(log n)^{1/(2r+1)}`, `c = 3c_ε (V*)^{−(2r−1)/(2r+1)}` |
| r = 3 | `n^{15/7}(log n)^{1/7}` | `n^{1/7}(log n)^{1/7}` |
| Radius (eq. (46)) | `t² = c_ε² n^{1/(2r+1)}(log n)^{1/(2r+1)}` for Δ² | `t²/n = c_ε² n^{−2r/(2r+1)}(log n)^{1/(2r+1)}` for Δ²_n |
| Penalty at the truth | `λ_raw‖D^{(r)}θ*‖_1 = (3/c_ε)(V*)^{2/(2r+1)}·t²` | `λ_TV·V*`, the same number |

Check of the exponent: `(r−1) + 1/(2r+1) = (2r²−r)/(2r+1) = r(2r−1)/(2r+1)`. The brief's `n^{15/7}(log n)^{1/7}` at r = 3 is confirmed. So `c_{2,ε} = c_ε²`, and **the penalty at the truth is of the order of the rate t²**, which is the whole point of the choice of λ.

## 3. (a) Proof map, with numbers

Notation (Definition 2): `M̂(θ) = Σ[ρ_τ(y_i−θ_i) − ρ_τ(y_i−θ*_i)]`, `M = E M̂`. `R = row(D^{(r)})`, and `R^⊥` is the polynomials of degree ≤ r−1 on the grid (Lemma 16). `u_i = τ − 1{y_i ≤ θ*_i}`, independent, bounded, mean zero (eq. (35)).

| Step | What is shown | Tools | Where |
|---|---|---|---|
| 1. Restricted set | With prob. ≥ 1−ε/4, `κ(θ̂−θ*) ∈ A` for all κ ∈ [0,1], with `A` as in eq. (34): `‖D^{(r)}δ‖_1 ≤ C̃·max{V*/n^{r−1}, γΔ²(P_Rδ), γ^{1/2}Δ(P_Rδ), V*/n^{r−1} + A^{−1}u^⊤P_{R^⊥}δ}`, `γ = B²/A²` | Optimality and convexity give the basic inequality at θ̃ = θ* + κ(θ̂−θ*). Knight's identity (Belloni–Chernozhukov Lemma 3) gives eq. (38): `0 ≤ λ[‖Dθ*‖_1 − ‖Dθ̃‖_1] + (θ̃−θ*)^⊤u`. Split by P_R and P_{R^⊥} (eq. (39)). Noise bound eq. (37) from Lemma 24: `u^⊤x ≤ A + B·Δ(x)` on `{x ∈ R, ‖Dx‖_1 ≤ 1}`. Then **λ = 3A** and two cases, eqs. (41)–(42) | Prop. 3, C.2–C.3 |
| 1a. Noise bound | `sup (u^⊤x − A)/‖x‖ = O_pr(B̃)` with `A = C n^{(2r−1)/(2r+1)}(log n)^{1/(2r+1)}‖Dθ*‖_1^{−(2r−1)/(2r+1)}`, "C > 1 large enough" | Wang et al. (2016), proof of Cor. 7, quoted. ℓ₂ → Δ by Lemmas 17, 19 | Lemmas 23, 24 |
| 2. Null space | `Ω_2`: `u^⊤P_{R^⊥}x ≤ E·(Δ²(x)/√n + Δ(x))` for all x | Lemma 25, from Lemmas 18 (sup norm of unit polynomials ≤ b_r/√n) and 20 | eq. (43) |
| 3. Scaling to the shell | On `{Δ²(δ̂) > t²}`, some `δ̃ = uδ̂`, u ∈ [0,1], has `Δ²(δ̃) = t²` and still obeys the basic inequality. Hence `sup_{δ∈A, Δ²≤t²}[M − M̂ + λ(‖Dθ*‖_1 − ‖D(θ*+δ)‖_1)] ≥ M(θ*+δ̃) ≥ c_0 t²` | Convexity of M̂ as in Prop. 1; **Lemma 13** (Assumption A). The paper cites "Lemma 9" here; it means Lemma 13 | C.4, to eq. (45) |
| 4. TV of the shell is O(1) | On Ω_1∩Ω_2, δ ∈ A and Δ(δ) ≤ t give `‖D^{(r)}δ‖_1 ≤ C̃ n^{1−r} max{V*, (V*)^{4r/(2r+1)}}`, i.e. TV^{(r)}(δ) ≤ C | Lemma 22 (Δ(P_Rδ) ≤ C̃_r t), and the algebra `B²t²/A² ≲ (V*)^{4r/(2r+1)}/n^{r−1}` | eq. (47) |
| 5. Markov, symmetrization, width | `pr ≤ (2/(c_0t²))·RW(H(t)) + λ·sup_{H(t)}‖Dδ‖_1/(c_0t²) = O(1/c_ε) ≤ ε/2` | Lemmas 10 (symmetrization), 11 (contraction; ρ_τ is 1-Lipschitz), Prop. 2 (width of `{TV ≤ 2V, Δ² ≤ t²}`), which uses Lemmas 17, 19, 21, 22 to pass from Δ to ℓ₂ and then Guntuboyina et al. (2020) Lemma B.1 and Lemma 8 (RW ≤ √(π/2)·GW) | eqs. (48)–(49) |

**The two terms in Step 5.**
- Stochastic term: `RW(H(t))/t² ≍ t^{1−1/(2r)}·n^{1/(4r)}/t² = (log n)^{−1/(4r)}` at Padilla's t. It tends to zero, and only because of the logarithm.
- Bias term: `λ_raw·n^{1−r}·C/(c_0t²) = λ_TV·C/(c_0 t²) ≍ 1/c_ε`. This is the "penalty at the truth over the rate". The outline (C.1 Step 4) writes it as `λ‖D^{(r)}θ*‖_1/(c_0t²)`; the formal proof bounds `λ‖D^{(r)}δ‖_1` over H(t). Same order.

**Small defects in the paper, none affecting the result.** "Lemma 9" for Lemma 13 in C.4; "A as in Lemma 3" for Prop. 3; the exponent `(V*)^{4r/(4r+2)}` in H(t) against `(V*)^{4r/(2r+1)}` in eq. (47); `pr(Δ²(δ̂) ≥ t)` for `≥ t²` in C.1.

## 4. (a) Role of each hypothesis

**Independence.** Symmetrization (Lemma 10), and the sub-Gaussian noise bounds for u (Lemmas 23–25).

**θ*_i is the τ-quantile.** Makes θ* the minimizer of M and gives E u_i = 0.

**Assumption A.** Used once: Lemma 13, `M(θ*+δ) ≥ c_0Δ²(δ)`. This is also why the loss is Δ²_n and not the mean squared error.

**No moments.** `|M̂_i(θ_i)| ≤ |θ_i − θ*_i|` (Remark 11), so everything is bounded by the perturbation.

**V* = Θ(1).** Three uses.
- It turns eq. (44) into the stated λ. V* enters with the negative power −(2r−1)/(2r+1), which is why a *lower* bound on V* appears.
- It makes the penalty at the truth `λ_TV·V*` of order t² (Step 5, bias term). This needs the *upper* bound.
- It makes the constants in eq. (47), `max{V*, (V*)^{4r/(2r+1)}}`, constants. Remark 6 says the general dependence "is not simple to state".

**c > c_{1,ε}.** Two different things are folded into one constant.
- *Structural.* λ/3 = A must dominate the noise in the dual seminorm (Lemma 23, "C > 1 large enough"). This is the usual "λ at least the noise level", and it is where the logarithm in λ comes from.
- *Bookkeeping.* The proof ties the constant of t to the constant of λ (both are c_ε, eqs. (44), (46)), so that the final bound is O(1/c_ε) ≤ ε/2. That is why the threshold depends on ε. Reading eqs. (47)–(49) with the two constants untied suggests that a fixed c above the structural threshold gives an O_pr statement. I did not prove this.

## 5. (b) Assumption table

Statuses refer to the **main theorem** of `T07a_statement.tex` (σ = 1, λ_raw = c·n^{(2r−1)/2}). The corollary on the posterior mode keeps every Padilla hypothesis as is.

| Padilla assumption | Where used in proof | Our status | Reason |
|---|---|---|---|
| y_i independent | Lemma 10; Lemmas 23–25 | KEPT AS IS | Same use. |
| θ*_i is the τ-quantile of y_i | θ* minimizes M; E u_i = 0 | KEPT AS IS | It is also what makes the misspecified ALD posterior target θ*. |
| Assumption A (CDF grows at least linearly near θ*_i) | Lemma 13 only | KEPT AS IS | The posterior needs the same curvature to lose mass away from θ*. |
| No moment condition | Remark 11 | KEPT AS IS | The ALD log-likelihood ratio is bounded by ‖δ‖_1. |
| Loss Δ²_n | Lemma 13; throughout | KEPT AS IS | Same definition, eq. (4), 1/n included. |
| V* = Θ(1) | eq. (44); Step 5 bias term; eq. (47) | ADAPTED to V* = O(1) | Only the upper bound is used once λ no longer carries a negative power of V*. This is Padilla's own wording in Thm 4. |
| λ = c·n^{1/(2r+1)}(log n)^{1/(2r+1)} (TV scale) | Steps 1, 5 | ADAPTED to λ_TV = c·n^{1/2}, i.e. λ_raw = c·n^{(2r−1)/2} | λ is now the prior's rate, so it also sets the posterior's width λ_raw^{−1/r}. At Padilla's λ that width exceeds his rate (§6). |
| c > c_{1,ε} | Lemma 23; Step 5 | DROPPED: any constant c > 0 | At λ_TV ≍ n^{1/2} the prior rate is far above the noise level n^{1/(2r+1)}(log n)^{1/(2r+1)}, so there is no threshold. c enters the constant M only. |
| Conclusion "with probability ≥ 1−ε" | — | ADAPTED to: the expected posterior mass of {Δ²_n > Mε_n²} tends to 0 | The Bayesian object is a distribution, not a point. |
| Any r ≥ 1 | — | ADAPTED to r ≥ 2 | The project's route needs a sup-norm localization that degenerates at r = 1. The statement is expected to hold at r = 1. Flagged, see §7. |
| — | — | NEW (Assumption B): upper half of the margin, the CDF increment over [θ*_i, θ*_i+δ_i] is at most f̄ times the length of the interval, for ‖δ‖_∞ ≤ L | The evidence (the denominator) is bounded below by integrating the likelihood over a neighbourhood of θ*, and this needs the expected check loss to be at most quadratic there. An estimator has no denominator. |
| — | — | NEW: σ fixed at σ₀ > 0 (σ₀ = 1 in the build-up) | A simplification ("we assume σ = 1 for simplicity"); the theorem holds for any fixed σ₀ with constants depending on σ₀. The sampler learns σ, which concentrates at the average check loss σ̄ₙ = n⁻¹ΣE ρ_τ(y_i − θ*_i) (statement, Remark 2). |
| — | — | NEW: λ deterministic | A simplification. The sampler learns λ under a Gamma prior. |

**What replaces "c > c_{1,ε}".** In the main theorem, nothing: any c > 0. In the corollary on the mode it stays exactly as Padilla has it. The structural half of the condition (the prior rate above the noise level) holds automatically at λ_TV ≍ n^{1/2}.

**What replaces "the penalty at the truth is of order t²".** This is the one Padilla step that cannot be borrowed. At the main theorem's λ, `λ_TV·V* = cV*·n^{1/2}`, which is far above `nε_n² = n^{1/(2r)}(log n)^{1/(2r)}` for r ≥ 2. The Bayesian proof instead centres the prior at a smoothed truth and pays a quadratic cost (project lemmas L4q, L4q-M at order k).

## 6. Why the target as posed fails

**Target as posed.** σ = 1, λ at Padilla's order, and `E_{θ*}Π(Δ²_n(θ−θ*) > M n^{−2r/(2r+1)}(log n)^{1/(2r+1)} | y) → 0`.

**Spread.** A prior with raw rate λ on r-th differences behaves in the bulk like an (r−1)-fold integrated random walk with step 1/λ. Over a window of w indices it moves by w^{r−1/2}/λ, and the data pin a window average to w^{−1/2}. These balance at `w ≍ λ^{1/r}`. So the posterior is a local smoother with n/w effective parameters and

  `Δ²_n-spread ≍ 1/w = λ_raw^{−1/r}`.

At Padilla's λ this is `n^{−(2r−1)/(2r+1)}(log n)^{−1/(r(2r+1))}`, larger than his rate by the factor `n^{1/(2r+1)}` up to logarithms. I derived this independently before the manager's message; the two derivations agree.

**Bias.** Raising λ shrinks the spread and raises the smoothing bias, which is `≍ V²λ_raw^{(2r−1)/r}n^{−(2r−1)}` (window w/n in x-units, a truth of L₂-smoothness r−1/2). The two balance at `λ_raw = n^{r−1/2}/V`, with rate `V^{1/r}n^{−(2r−1)/(2r)}`. Heuristically no fixed λ at a fixed σ does better; proved only for λ ≲ n^{5/2} at r = 3 (Theorem LB). This rate is the minimax rate of *linear* estimators over bounded-variation classes (Donoho–Johnstone 1998; Tibshirani 2014, §5.1, with k = r−1).

**Side by side, r = 3.**

| | λ_raw | Rate of Δ²_n | Status |
|---|---|---|---|
| Padilla's PQTF (the mode) | n^{15/7}(log n)^{1/7} | n^{−6/7}(log n)^{1/7} | His Thm 3 |
| Full posterior at Padilla's λ | same | n^{−5/7} (spread-limited) | Lower bound PROVED (Theorem LB). Sharp upper bound not found in the index: C1 gives only n^{−23/49}(log n)^{40/49} at this λ |
| Full posterior at the best λ | c·n^{5/2} | n^{−5/6}(log n)^{1/6} | Upper and lower PROVED in the project (C2, LB) |

**Proved.** Project Theorem LB (`theory/T06_Alignment/FABLE_B_lowerbound.md` §8, audited), r = 3 only. Assumptions: independence, and only the upper half of the margin (`|F_i(θ*_i+δ) − F_i(θ*_i)| ≤ f̄|δ|` for |δ| ≤ L). No lower margin, no moments. Truth: TV^{(3)}(θ*) ≤ V. Any fixed σ > 0, with c_0 depending on σ. λ deterministic, λ → ∞, λ ≤ a_2n^{5/2}/V, which includes n^{15/7}(log n)^{1/7}. Conclusion: `E_0Π(Δ²_n(θ−θ*) ≤ c_0λ^{−1/3} | y) → 0`.

**Noise coverage.** All three noise families of the paper have bounded densities (Gaussian with s(u) ∈ [1/4, 1/2]; Beta(1, 11−10u) with density ≤ 11; the mixed normal), so Theorem LB covers all three, not only Gaussian noise. I checked this against `paper/sections/simulations.tex`.

**Heuristic.** The general-r spread law. The same phenomenon is proved for the Bayesian LASSO in Castillo, Schmidt-Hieber and van der Vaart (2015, Thm 7).

**Empirical (E-06).** Exact Gibbs sampler, σ and λ fixed, truths pq and sin, five noise laws, n from 1k to 32k, 20 seeds, r = 3. Seed-median slopes in log n of the posterior 95% radius, read from `engineering/E06_Rate_Validation/tables/e06_slopes_all.csv`:
- λσ ∝ n^{15/7}: rough part −0.736 to −0.775 over all 10 configurations (full Δ²_n: −0.77 to −0.81). Spread law: −5/7 ≈ −0.714. Padilla's exponent: −6/7 ≈ −0.857. No configuration comes near it.
- λσ ∝ n^{5/2}: rough part, median −0.844, range −0.80 to −0.89. Prediction: −5/6 ≈ −0.833.
- `paper_notes.md` attributes the 0.02–0.06 excess steepness to pre-asymptotic curvature of the spread exponent.

## 7. Open points for the manager

- **r = 1.** The main theorem is stated for r ≥ 2. `FABLE_B_general_k.md` records that the moment-free route (C1, C2) breaks at k = 0, while Theorem B holds for every k ≥ 0 under its condition (EM). If σ = 1 lies in the (EM) range for the noise at hand, r = 1 can be added.
- **Log power.** I state (log n)^{1/(2r)}, the project's upper-side power. Theorem LB is log-free, so the true rate lies between.
- **Constant c.** I state "any c > 0". Corollary 8.4 of the LB file uses a_1n^{5/2}/V ≤ λ ≤ a_2n^{5/2}/V, which supports this, but I did not read the upper proofs.
- **Upper bound at Padilla's λ.** Not located as an audited result. If the owner wants the n^{−5/7} line as a theorem, it needs its own check.
