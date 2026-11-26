# BQTF Lean formalization: plan

BQTF Lean Department, 2026-11-25.

**Status:** GO received on 2026-11-25, and Gemini Neon is connected. **Theorem 1 comes first.** Theorem 2 starts only when Theorem 1 is done, or when Felipe says so. Step 2 below is therefore postponed until after step 3.

## Goal

Formalize in Lean 4 + Mathlib the two posterior-contraction theorems of the paper:

- **Theorem 1** (`thm:main`): a single quantile level.
- **Theorem 2** (`thm:joint`): the non-crossing joint posterior at all levels at once (the max_j display).

The end state has no `sorry`, and its only axioms are `propext`, `Classical.choice` and `Quot.sound`.

**Sources** (repo at e36c20d or later):
- `paper/sections/theory.tex`: the statements;
- `paper/sections/appendix_theory.tex`: the proofs;
- `theory/T09_Joint_Theorem/`: the audit record of Theorem 2;
- `paper/main.pdf`.

The paper is authoritative where it differs from T09. The paper states the simultaneous `max_j` form; T09's STATEMENT.tex has the per-level form, which follows from it.

**Precedent.** We copy the layout of `/home/fb31/Large-Prior-Official-Repo/lean/` (read-only):
- `Spec.lean` holds the statements;
- `AxiomCheck.lean` pins each theorem to its exact type and prints its axioms;
- `docs/statements.md` gives plain-math versions;
- `SHA256SUMS.txt`;
- the README has a section "Differences from the paper".

Every difference must make our result **weaker than or equal to the paper's, never stronger**: any hypothesis we add must be one the paper also assumes or implies, and any conclusion we change must be at least as strong as the paper's. Classical inputs may first enter as explicit hypotheses and be proved later. The **final** Theorem 1 and Theorem 2 statements must carry none.

## Toolchain

The pin is the same as Large Prior's:
- toolchain `leanprover/lean4:v4.35.0-rc2`;
- Mathlib at `v4.35.0-rc2` = `065356127b1dc0016f66b7283ce0ce2c4055aa55`, with `lake-manifest.json` copied verbatim and only the package name changed.

`lake exe cache get` works with this pin: see the "Cache check" section at the end.

Builds run on Owls only through `owls_run`:
- at most 2–3 concurrent Lean builds, each `-j 2`–`4`;
- keep ≥ 15 GB RAM free;
- long builds run as systemd user units.

Each prover worktree needs its own `.lake`: about 5–6 GB on disk and roughly 4–8 GB of RAM per build. `.lake/` is gitignored.

## 1. Statements (step 1): what `BQTF/Spec.lean` will contain

Everything is on vectors `Fin n → ℝ`, with `r = k + 1` and `m = n − r`.

| Lean name (planned) | Paper object |
|---|---|
| `checkLoss τ u` | ρ_τ(u) = u(τ − 1{u<0}) |
| `diffOp k n : Matrix (Fin (n-(k+1))) (Fin n) ℝ` | D = D^{(k+1)}, the (k+1)-th forward difference |
| `TV k θ` | n^k ‖Dθ‖₁ |
| `lossΔ v` | Δ²_n(v) = n⁻¹ Σ min{\|vᵢ\|, vᵢ²} |
| `postDensity τ k λ σ y θ` | exp{−Σ ρ_τ(yᵢ−θᵢ)/σ − λ‖Dθ‖₁} (from eq. (ald) and (prior_theta); the factor τ(1−τ)/σ and λ^m cancel in the ratio) |
| `posterior τ k λ σ y` | eq. (post-fixed): Lebesgue `withDensity`, normalized; an `ℝ≥0∞`-valued measure, no `toReal` |
| `orderSet n J` | 𝒞 = {Θ : θ_{i1} ≤ ⋯ ≤ θ_{iJ} ∀i} (weak inequalities, as in eq. (joint_order)) |
| `jointPosterior` | eq. (joint-fixed): `Measure.pi` of the J posteriors, restricted to 𝒞 and normalized |
| `IsQuantile μ τ q` | μ(−∞,q) ≤ τ ≤ μ(−∞,q] |
| `AssumptionA μ θ* L f̲`, `AssumptionB μ θ* L f̄` | the per-coordinate forms of Assumptions A and B (equivalent to the ‖δ‖_∞ ≤ L forms) |
| data law | `Measure.pi μ`, with `μ : Fin n → Measure ℝ` arbitrary probability measures (independent, not identically distributed, no moments) |

**`MainStatement` (Theorem 1, σ = 1).**

∀ k ≥ 1, c > 0, L > 0, f̲ > 0, f̄, V̄ ≥ 0, ∃ M, C > 0 and n₀ such that:
- for all n ≥ n₀, all τ ∈ (0,1), all laws μ and all θ*, where each θ*ᵢ is a τ-quantile of μᵢ, A and B hold, and TV(θ*) ≤ V̄,
- with λ = c n^{(2k+1)/2},
- `Measurable (y ↦ Π_λ(B_M | y))` holds, and
- ∫⁻ Π_λ(Δ²_n(θ−θ*) > M n^{−(2k+1)/(2k+2)} | y) d(⊗μᵢ) ≤ C n^{−1/(2k+2)}.

**`MainStatementScale`** is the same with any σ₀ > 0, and the constants may also depend on σ₀.

**`JointStatement` / `JointStatementScale` (Theorem 2).** They have the same shape, with:
- J ≥ 2 and 0 < τ₁ < ⋯ < τ_J < 1;
- c_j > 0, and λ_j = c_j n^{(2k+1)/2};
- A and B at every level with common (L, f̲, f̄);
- V*_j ≤ V̄ for every j;
- the event {max_j Δ²_n(θ_j−θ*_j) > M n^{−(2k+1)/(2k+2)}};
- constants M, C, n₀ that depend on (c_j), k, L, f̲, f̄, V̄, J and the minimum spacing. In Lean, the spacing is a lower bound `γ > 0` on τ_{j+1} − τ_j, quantified before the ∃.

**Fidelity points for the Astra audit (step 1):**

1. **Quantifier order.** "Uniform over all laws" means the ∃ M C n₀ must come before ∀ n, μ, θ*. The constants of Theorem 1 do not depend on τ: the paper's list omits τ, and the proof uses only τ(1−τ) ≤ ¼. So τ is quantified after the ∃. This is the paper's claim; if the proof turns out to need τ, we move τ before the ∃ and record that as a (weaker) difference.
2. **Measurability.** Mathlib's `∫⁻` of a non-measurable function is the *lower* integral, so a bound on it alone would be weaker than the paper. The statement therefore includes measurability of y ↦ Π(B|y).
3. **θ\* as a hypothesis.** θ* enters as a hypothesis `IsQuantile`, not as a chosen quantile function. Under A and B the τ-quantile is unique, so this is equivalent.
4. **Propriety.** n₀ > k+1, so propriety (Lemma coord) is available. The normalized posterior is a probability measure; this is proved as a lemma, not assumed.
5. **D.** D's sign/row convention does not affect ‖Dθ‖₁. The statement fixes one convention and documents it.
6. **σ convention.** The σ₀ versions are stated from the posterior at scale σ₀ itself (paper eq. (ald) + (prior_theta)), not from the paper's reduction. The reduction is a proof step.

## 2. Module breakdown

Namespace `BQTF`. The labels are the appendix's.

### Statements and checks

| Module | Content |
|---|---|
| `Spec` | definitions above, plus `MainStatement`, `MainStatementScale`, `JointStatement`, `JointStatementScale` |
| `NonVacuity` | a law satisfying every hypothesis (e.g. yᵢ = θ*ᵢ + uniform or Cauchy noise, θ* = 0), so that the hypotheses are not contradictory |
| `Sanity` | small unit checks of the definitions (D on polynomials, Δ² on small vectors, 𝒞 membership) |
| `AxiomCheck.lean` | `example : MainStatement := main_theorem` etc., plus `#print axioms` |

### Theorem 1

| Appendix item | Module | Main content | Mathlib status |
|---|---|---|---|
| Pascal / b_p(t) (eq. pascal) | `Falling` | b_p(t) = C(t,p)·1{t≥0}, Pascal rule, the r-fold difference of s_j is e_j | `Nat.choose`, `descPochhammer`, `fwdDiff`, `fwdDiff_iter_eq_sum_shift` exist; glue only |
| Lemma coord (a)–(c) | `Coord` | DS = I, ker D = 𝒫, θ = Nc + Su bijection, ν = Leb_r ⊗ Q_λ, ratio form, propriety, Pythagoras (pyth), Fubini volume formula (vol), ν{‖δ‖ ≤ ϱ} ≤ V_r ϱ^r | linear maps, `map_linearMap_addHaar_eq_smul_addHaar`, `volume_ball` (`EuclideanSpace`), `Measure.pi` exist; orthonormal basis N of 𝒫 via Gram–Schmidt. **Friction:** `Fin n → ℝ` has the sup norm, so work in `EuclideanSpace ℝ (Fin n)` or with explicit sums. |
| Lemma check (a)–(e) | `CheckLoss` | Knight identity, m_i(t) = ∫₀ᵗ (F_i − τ), quadratic bounds, E R², E e^{−2R} ≤ e^{−m} | `intervalIntegral`, CDFs (`ProbabilityTheory.cdf`) exist; elementary |
| Laplace prior Q_λ | `Laplace` | density, mgf (1 − s²/λ²)⁻¹, Γ = λ‖u‖₁ mgf (1−ϑ)^{−m} (product of mgfs; the Gamma law itself is not needed), scale mixture √V·g | `exponentialPDF`, `gaussianReal`, `mgf`, independence → product exist; the scale-mixture identity must be built (one integral) |
| Lemma F (spline approximation) | `SplineApprox` | V_J, P_J, the e_j construction (three cases), c_∞, Lagrange weights \|a_l\| ≤ C(r−1,l), Schur test | `Lagrange.basis` exists; orthogonal projector (`orthogonalProjection`) exists; **Schur test must be built** (~100 lines) |
| g_r, local polynomial kernel | `Gram` | G_w ≻ 0 for w ≥ r, g_r = inf_{w≥r} λ_min(G_w) > 0, kernel K^{(j)} reproducing polynomials, ‖K^{(j)}‖₂ ≤ r/(g_r√w), max_W\|p\| ≤ (C₀/w)^{1/2}‖p‖ | Rayleigh quotient exists (`Analysis/InnerProductSpace/Rayleigh`). **g_r > 0 uniformly in w is asserted, not proved, in the paper** (see Risks). |
| Lemma smooth | `Smooth` | u_w with the two bounds | after `Gram`, `Falling` |
| Lemma sb (small ball) | `SmallBall` | Laplace = Gaussian scale mixture; conditional Gaussian; eigenvalue tail via Eckart–Young; Gaussian small-ball with head/tail split | `stdGaussian` / `multivariateGaussian` / `IsGaussian` exist, so check rotation invariance; `LinearMap.singularValues` exists (new), **Eckart–Young / Ky Fan tail bound does not exist**; Markov exists |
| Lemma qshift | `QuadShift` | symmetrization of the shift, f_j(0) ≤ c_K λ via log-concavity | **Prékopa (log-concave marginals) and Borell (concavity of Λ) do not exist**; Jensen (`ConvexOn.map_integral_le`) exists |
| Prop prior | `PriorMass` | choice of w, u°, combination | after the above |
| Lemma evid | `Denominator` | Jensen lower bound, Chebyshev | `meas_ge_le_variance_div_sq`, `IndepFun.variance_sum`, Jensen exist |
| Lemma width | `Width` | Rademacher width of K(ρ,T); E max of 2m sub-Gaussians ≤ σ√(2 log 2m) | `HasSubgaussianMGF` exists; **finite-max sub-Gaussian bound must be built** (~150 lines); Rademacher variables are built by hand |
| Lemma interp | `Interp` | ‖δ‖_∞ ≤ C_I{‖δ‖_n + ‖δ‖_n^{(2r−2)/(2r−1)} TV^{1/(2r−1)}}: windowed `Coord`, polynomial sup/ℓ₂ comparison, case split on w | elementary, heavy on rpow algebra; depends on `Coord` (on a window), `Gram` |
| Lemma conc | `Concentration` | E G_K ≤ 4 E sup⟨ξ,δ⟩; Var G_K ≤ sup‖δ‖² | **symmetrization (abs form), Ledoux–Talagrand contraction (abs form) and Efron–Stein do not exist**. Measurability of sup over compact K: via a countable dense subset and continuity in δ. |
| Prop local | `Localization` | ρ_n, T_n, K_n; Ω_G; rays/convexity; masses of A₁, A₂; division by Lemma evid | `integral_fun_norm_addHaar` gives ∫e^{−κ‖c‖} = r! V_r κ^{−r}; rest is assembly |
| Lemma score | `Score` | Chebyshev for quadratic forms (E ζᵀQζ, Var ≤ ¼‖Q‖²_F); Hoeffding for t_j; Ω_ζ(J) | Hoeffding = `measure_sum_ge_le_of_iIndepFun` exists; quadratic-form variance must be built (short) |
| Prop shell | `Shells` | Cauchy–Schwarz in L²(ν), remainder via Tonelli, score via the Laplace mgf | `Laplace`, `CheckLoss`, `Coord` |
| Thm main assembly | `Main` | constants M, C, the peeling sum over a_k = 2^k M, the final bound | assembly, plus `Asymptotics` |
| Reduction to σ = 1 | `Reduction` | θ = σ₀θ′ change of variables; rescaled A, B; Δ²(σ₀v) ≤ max{σ₀,σ₀²}Δ²(v) | `map_linearMap_addHaar_eq_smul_addHaar`, positive homogeneity |
| thresholds n₁, n₂, n₃ | `Asymptotics` | every "for n ≥ n_i" fact (rpow/log comparisons, n ε_n² = n^{1/(2r)}, ρ_n vs ε_n) as explicit ∃ n₀ lemmas | `Real.rpow`, `isLittleO_log_rpow_atTop` exist; tedious |

### Theorem 2

*(Superseded by Section 5, the draft module map of 2026-11-25. This table is kept for history.)*

| Appendix item | Module | Content | Status |
|---|---|---|---|
| Lemma cond | `Conditioning` | Π^⊗(𝒞\|y) > 0 (positive density, 𝒞 ⊇ a nonempty open set); Π_𝒞(θ_j ∈ A) ≤ Π_j(A)/Π^⊗(𝒞) | `Measure.pi`, open sets have positive measure: exist |
| Lemma gap | `Gap` | θ*_{i,j+1} − θ*_{ij} ≥ g₀ = min{L, min_j (τ_{j+1}−τ_j)/f̄} | elementary (CDF monotonicity) |
| Lemma sup | `SupNorm` | Π_λ(‖θ−θ*‖_∞ > s_n) ≤ η_n on Ω_E ∩ Ω_G; s_n, η_n → 0; P((Ω_E∩Ω_G)ᶜ) ≤ (5/4 + 64/f̲²) n^{−1/(2r)} | from `Interp`, `Localization`, `Denominator` |
| Thm joint, σ_j = 1 and general σ_{0j} | `Joint` | constraint step (Π^⊗(𝒞ᶜ) ≤ Jη_n ≤ ½), transfer, union bound, max_j form, general scales via `Reduction` | assembly |

**Step 2 (Theorem 2 conditional on Theorem 1).** `JointFromSingle` proves `JointStatement` from two explicit hypotheses:
- `SingleLevelBound`: the conclusion of `MainStatement` at each level;
- `SupNormLocalization`: the statement of Lemma sup, with the good event Ω packaged as an `∃ Ω, P(Ωᶜ) ≤ …, ∀ y ∈ Ω, Π(‖·‖_∞ > s_n | y) ≤ η_n`, and s_n → 0, η_n → 0.

The step-2 deliverable is `JointFromSingle : SingleLevelBound → SupNormLocalization → JointStatement`, with no `sorry`. Both hypotheses are then discharged in step 3, by `main_theorem` and by `SupNorm`. Expected size is about 600–1,000 lines: `Conditioning`, `Gap`, the transfer, the scale step and the measurability of the joint posterior.

### Probability library (`BQTF/Prob/`)

These are classical inputs. Each is first allowed as an explicit hypothesis, stated at least as generally as the paper uses it, and is then proved:

| Input | Used by | Plan | Size estimate |
|---|---|---|---|
| Symmetrization (abs form, independent processes; vdV–W Lemma 2.3.6) | `Concentration` | prove; finite-dimensional, countable-sup version | 300–500 |
| Contraction principle (abs form; Ledoux–Talagrand Thm 4.12) | `Concentration` | prove (induction on coordinates, comparison per coordinate) | 400–700 |
| Efron–Stein | `Concentration` | prove (tensorization of variance over `Measure.pi`) | 300–500 |
| Prékopa: marginals of log-concave densities are log-concave; Borell: s ↦ log Q{‖Av‖ ≤ s} is concave | `QuadShift` | via 1-D Prékopa–Leindler + induction on dimension. **Hardest library item.** Alternative: rework qshift's f_j(0) bound to avoid it (look for this first). | 1,000–2,000 |
| Eckart–Young (Frobenius tail of eigenvalues ≤ error of any rank-J approximation) | `SmallBall` | Ky Fan / Courant–Fischer from `Rayleigh` + `singularValues` | 400–800 |
| Rotation invariance of the standard Gaussian; Gaussian small-ball P(\|γ\| ≤ t) ≥ 0.48 min{t,1} | `SmallBall` | check `stdGaussian`/`IsGaussian` first; the 0.48 bound is a numeric estimate of the normal density | 200–400 |
| Max of N sub-Gaussians | `Width` | from `HasSubgaussianMGF` mgf bound + log-sum-exp | 150 |
| Laplace = √(Exp)·N(0,1) (Andrews–Mallows) | `SmallBall`, `Laplace` | direct integral identity | 200–300 |

## 3. Risks

1. **Statement fidelity (largest risk, step 1).** The quantifier order (uniformity, the absent τ-dependence), measurability, the σ convention and the max_j form all need care. Mitigation: Astra audits `Spec.lean` against theory.tex line by line before any proof work. No proof starts on an unaudited statement.
2. **Prékopa/Borell in Lemma qshift.** This is not in Mathlib and is nontrivial in n dimensions. Fallbacks:
   - (a) a more elementary bound on f_j(0) for this specific A;
   - (b) carry it as a named classical hypothesis during step 3 and prove it last.

   The final Theorem 1 must not carry it.
3. **Lemma sb (small ball without a log factor).** It needs Eckart–Young and Gaussian rotation invariance. A cruder box argument loses a log and would change the rate, so it is not an option.
4. **Lemma conc.** Symmetrization, contraction and Efron–Stein are all new. Each is standard but long, and measurability of the supremum over K_n adds friction.
5. **g_r > 0.** The appendix defines g_r = inf_{w≥r} λ_min(G_w) ∈ (0,1] and uses it as a constant, but gives no proof that the infimum is positive. It is true (G_w → the Hilbert-type Gram matrix ∫₀¹ b bᵀ, which is ≻ 0, and each G_w ≻ 0 for w ≥ r), but it needs a proof. We may find a short route with an explicit lower bound. **Flag to HQ/Theory as a paper gap**: one sentence is probably needed in the appendix.
6. **The `Fin n → ℝ` sup norm.** All ℓ₂ geometry must be explicit (as in Large Prior's `empNorm`) or done in `EuclideanSpace`. Mixing the two causes build friction.
7. **"For n ≥ n_i" bookkeeping.** The proof has about 15 eventual inequalities with rpow and log. They are tedious but low-risk: Large Prior's `CorSeq` (~600 lines) is the model.
8. **Team availability.** Gemini Neon (main prover) is not connected yet. Until it is, the plan's prover column is empty. Hard tactics fall back to Codex sol, per the team design.

## 4. Order of work and estimate

| Step | Work | Calendar | Lines (est.) |
|---|---|---|---|
| 1 | `Spec.lean`, `docs/statements.md`, `NonVacuity`, `Sanity`; Astra fidelity audit (2 rounds) | 2–3 days | 600–900 |
| 2 | `Conditioning`, `Gap`, `JointFromSingle` (Thm 2 conditional) | 2–3 days | 600–1,000 |
| 3a | `Falling`, `Coord`, `CheckLoss`, `Laplace`, `SplineApprox`, `Gram`, `Interp`, `Asymptotics` | 5–7 days | 3,500–5,000 |
| 3b | `Width`, `Score`, `Denominator`, `Shells`, `Localization`, `Main`, `Reduction`, `SupNorm` (with Prob inputs as hypotheses) | 5–7 days | 3,000–4,500 |
| 3c | `Smooth`, `SmallBall`, `QuadShift`, `PriorMass` | 4–6 days | 2,000–3,500 |
| 3d | Discharge the Prob inputs (symmetrization, contraction, Efron–Stein, Prékopa/Borell, Eckart–Young, Gaussian pieces) | 6–10 days | 3,000–5,000 |
| 4 | AxiomCheck, README with Differences, statements.md final, SHA256SUMS, clean build | 1–2 days | — |

**Total:** roughly **12,000–20,000 lines over 4–5 weeks** of calendar time. This is 1.3–2× Large Prior's 9,400 lines / 12 days, because Theorem 1 needs empirical-process and log-concavity machinery that Large Prior's Gaussian-likelihood proof did not.

The schedule is driven by 3c/3d. Steps 3a and 3b can run in parallel worktrees, and so can 3c and 3d.

**Compute:**
- Lean builds only, all on Owls; no NOTS.
- A single-module rebuild against cached Mathlib takes 1–5 min at `-j 2`.
- A full project build should be 10–30 min (Large Prior: about 15 min).
- Peak use is 2–3 concurrent builds × `-j 2`–`4`, about 6–12 cores and 15–25 GB RAM.
- Disk is about 6 GB per worktree `.lake`.

## Cache check (2026-11-25)

The command was `owls_run -j 2 -- lake exe cache get`, run in `lean/`:
- Mathlib `065356127b` and its dependencies were cloned.
- The `cache` executable was built.
- All 8,723 Mathlib `.ltar` files were already in `~/.cache/mathlib`, left there by the Large Prior work, so nothing was downloaded. Decompression took about 6 minutes, and the whole run took 10m39s.
- `.lake` is 7.5 GB.

Smoke tests:
- `lake env lean` on a file importing Mathlib analysis passed.
- `BQTF/Spec.lean`, which imports all of Mathlib, type-checks in about 2 minutes with no warnings.

No full build has been run.

## Team and workflow (from HQ's GO, 2026-11-25)

The maximum effort for every agent is "high". Fable is not on this team.

| Role | Agent | Use |
|---|---|---|
| Orchestrator and verifier | Lean head (Claude Opus 5.5) | assigns, integrates, checks every finding, builds, commits (explicit paths, no push) |
| Main provers | 2 × Gemini Neon (`antigravity` / `gemini-4-neon`, `thought_level=high`) | Theorem 1, split by module so they never edit the same file |
| Statement-fidelity auditor | Astra (`gpt-6.2-astra`, high), a fresh one per round | `Spec.lean` and `docs/statements.md` against the paper |
| Code reviewers | Sol (`gpt-6.2-sol`, high), a fresh one per module merge | checks that each lemma matches PLAN and the paper, with no hidden weakening or strengthening, no `sorry`/`admit`/`axiom`/`native_decide`, and no vacuous hypotheses; checks conventions; checks that the module builds. Findings go in `notes/reviews/<module>_<date>.md`. |
| Tactic workers | Sol (`gpt-6.2-sol`, high) | hard tactic blocks |
| Support | Claude Sonnet / Haiku | Sonnet: Mathlib search and build fixes. Haiku: routine build checks. |

**Gate.** No proof work starts until the Theorem 1 statement passes the Astra audit. Every finding is checked by the head, and only the findings that hold lead to changes.

**Assignment of Theorem 1** (final; launched 2026-11-25 on the skeleton at aa70682, one worktree per prover):
- **Neon-A:** `Falling`, `Coord`, `Gram` (g_r > 0, by Theory's T10 proof), `SplineApprox`, `Smooth`, `Interp`, `SmallBall`, plus helper files under `BQTF/Lin/`.
- **Neon-B:** `CheckLoss`, `Score`, `Concentration`, plus helper files under `BQTF/Prob/`. On 2026-11-25, `Denominator`, `Localization` and `Shells` moved to Sol-W1, and `QuadShift` and `Width` moved to Sol-W2, to balance the load; Neon-B was told first both times.
- **Sol-W1** (gpt-6.2-sol, high; HQ authorization of 2026-11-25): `Main`, plus helpers under `BQTF/Asym/`. It proves the assembly against the frozen statements, as an early test that the interfaces suffice. `Main` was proved on 2026-11-25 (8b10d87, now under Sol review). Since 2026-11-25 Sol-W1 also owns `Shells`, `Localization` and `Denominator`, on branch `t3/sol-w1-assembly`.
- **Sol-W2** (gpt-6.2-sol, high): `Reduction`, then `PriorMass` (both proved on 2026-11-25, 7265e3e, under review), plus helpers under `BQTF/Scale/` and `BQTF/Prior/`. Since 2026-11-25 it also owns `QuadShift` and `Width` (helpers under `BQTF/Shift/`), on branch `t3/sol-w2-shift-width`.
- **Opus worker** (Claude Opus 5.5 via `antigravity`; HQ authorization of 2026-11-25): at most 1, spawned only when needed. Not spawned yet.
- **Claude Personal workers** (Opus 5.5 high, owner directive 2026-11-25: via Claude Personal only, never antigravity), carved out after telling the previous owner:
  - CP-Opus1: `Prob/EfronStein.lean`, `efronStein_oneSided` (taken from Neon-B's Prob/).
  - CP-Opus2: `Prob/Contraction.lean` plus helpers. **Merged b9dd763.**
  - CP-Opus3: `Lin/EckartYoung.lean`, `eckartYoung_tail` (taken from Neon-A's Lin/). Proved at 84f23e3; in review.
  - CP-Opus4: `Shift/PrekopaLaplace.lean` plus `Shift/PrekopaLaplace/`, `prekopa_laplace` (frozen at Sol-W2 8ebfb2f; taken from Sol-W2).
  - Neon-B keeps `Prob/Symmetrization.lean` and the Concentration glue. Neon-A keeps the SmallBall helpers (Andrews–Mallows, Gaussian small ball, rotation glue). Sol-W2 keeps QuadShift and the Shift/ slice consequences.
- The head proves no lemmas. A file never has two owners at once.

Every module merge gets a fresh Sol review, written to `notes/reviews/<module>_<date>.md`. The head rules on each finding before merging.

**Skeleton first.** Before the provers start, the head writes every module's lemma *statements* with `sorry` proofs, following the appendix. This fixes the interfaces. Each prover then owns a disjoint set of files and replaces the `sorry`s in them. A statement in the skeleton changes only with the head's sign-off.

## Classical inputs still assumed (tracker)

Each row is an explicit, documented hypothesis until it is proved. It also appears in `docs/statements.md` ("Differences") while open. The final `MainStatement` carries none of them.

**HQ rule (2026-11-25).** Hypothesis-first is a staging step only: state the input as an explicit lemma, use it, and prove it in parallel. Theorem 1 is **not** done while any input is still a hypothesis or an extra argument. The final `#print axioms main_theorem` must show only the 3 standard axioms, with no hypotheses beyond the frozen `MainStatement`. Any input that looks multi-week, or that we would want to leave as a stated assumption, goes to HQ with its inventory (statement, nearest Mathlib result, cost). The head does not decide that alone.

| Input | Where it enters | Status |
|---|---|---|
| (none yet) | | |

## 5. Theorem 2 module map (draft, 2026-11-25; planning only)

**Trigger (HQ, 2026-11-25).** Theorem 2 work starts only when Theorem 1 is **done and checked**:
- every Theorem 1 module is merged;
- `#print axioms main_theorem` on main shows only `propext`, `Classical.choice` and `Quot.sound`, with no extra hypotheses;
- every Sol review has been ruled on;
- the corrections packets have gone out.

Until then this section is a plan only. The skeleton goes on a branch once Theorem 1 has a few modules left and is merged at the trigger. The paper-corrections policy applies to Theorem 2 unchanged.

**Source.** The statement is `thm:joint` (`paper/sections/theory.tex`, eq. `joint-fixed`, with 𝒞 from eq. `joint_order` in `methodology.tex`: weak order θ_{i1} ≤ ⋯ ≤ θ_{iJ}, matching `orderSet`). The proof is in `paper/sections/appendix_theory.tex`, §`pf:sec:joint`, and has four steps: Lemma `pf:lem:cond` (truncation), Lemma `pf:lem:gap` (separation), Lemma `pf:lem:sup` (sup-norm concentration), then the transfer and union bound in the proof of the theorem, including the "General scales" paragraph.

### 5.1 Key structural finding: no joint version of any Theorem 1 module is needed

The paper's proof works **one level at a time** and combines the levels only through a finite union bound over j = 1, …, J. A shared θ across levels never enters a Theorem 1 argument: the coupling happens only through 𝒞, and Lemma `cond` removes it at the cost of the factor 1/Π^⊗(𝒞 | y) ≤ 2 on the good event. So:
- **J does not enter any Theorem 1 rate or threshold.** It enters only Theorem 2's own constants:
  - M = max_l M^{(l)};
  - C = 2 Σ_l C^{(l)} + J(5/4 + 64/f̲²);
  - n₀, through J η_n ≤ 1/2 and max_l s_{n,l} ≤ g₀/2.
- The spacing min_j(τ_{j+1} − τ_j) enters **n₀ only**, through g₀ = min{L, spacing/f̄} (Lemma `gap`). M and C are free of it.
- Each Theorem 1 interface is applied J times, at (τ, c) = (τ_l, c_l), with the same (L, f̲, f̄, V̄).

| Theorem 1 piece | Reused in Theorem 2 as | Change needed |
|---|---|---|
| `main_theorem` (`Main`) | the bound E Π_l(A_l \| y) ≤ C^{(l)} n^{−1/(2r)} at each level | none (as-is) |
| `main_theorem_scale` (`Reduction`) | the same at scale σ_{0l} | none (as-is) |
| `posterior_isProbability`, `posterior_eq_ratio` (`Coord`) | each Π_l is a probability measure with an everywhere-positive density, for Lemma `cond`; D5 | none |
| `interp` (`Interp`) | δ ∈ K_n ⇒ ‖δ‖_∞ ≤ s_n, for Lemma `sup` | none |
| `localization` (`Localization`), part (b) and the Ω_G bound | Π(θ − θ* ∉ K_n \| y) ≤ η_n on Ω_E ∩ Ω_G, for Lemma `sup` | none |
| `denominator` (`Denominator`) | P(Ω_Eᶜ) ≤ (5/4)/(n ε_n²), for Lemma `sup` | none |
| `Scale/Posterior`, `Scale/Data` (Sol-W2's helpers) | push-forward of Π_l under θ ↦ θ/σ_{0l}; rescaled A, B, TV, for "General scales" | possibly promote private lemmas to public |
| `Asym/Rates` | n ε_n² = n^{1/(2r)}, ρ_n vs ε_n, the eventual thresholds | add s_n → 0, η_n → 0 (new, in Lemma `sup`) |

**Interface risk to check at the trigger.** The paper's proof uses only Lemma `sup`'s *conclusions*, and those follow from the frozen `localization` + `interp` + `denominator` statements. I checked the frozen `localization` (Ω_G, s0, the posterior bound on Ω_G ∩ Ω_E): it exposes what Lemma `sup` needs. If a frozen Theorem 1 statement turns out too weak for Lemma `sup`, that is a statement change: a new Astra check and a report to HQ.

### 5.2 New statements (Spec additions; Astra statement gate first)

| Lean name | Paper | Content |
|---|---|---|
| `JointConclusion` | eq. `joint-fixed`, `thm:joint` display | Measurability of y ↦ Π_𝒞(U_M \| y), and E Π_𝒞(U_M \| y) ≤ ofReal(C n^{−1/(2k+2)}), where U_M = {Θ : ∃ j, Δ²_n(Θ_j − θ*_j) > M n^{−(2k+1)/(2k+2)}} (= "max_j > M rate"). |
| `JointStatement` | `thm:joint`, σ_j = 1 | ∀ k ≥ 1, ∀ J, ∀ c : Fin J → ℝ (all > 0), ∀ L f̲ f̄ V̄ (L, f̲ > 0), ∀ gmin > 0, ∃ M C n₀ > 0 such that ∀ n ≥ n₀, ∀ τ : Fin J → ℝ strictly increasing in (0,1) with τ_{j+1} − τ_j ≥ gmin, ∀ μ, ∀ θ* : Fin J → Fin n → ℝ with `DataHyp` at every level (same L, f̲, f̄, V̄), `JointConclusion` holds for `jointPosterior τ 1 (lamSeq c_j)`. |
| `JointStatementScale` | `thm:joint`, last sentence | The same, with σ₀ : Fin J → ℝ (all > 0) quantified before ∃. |

Planned **Differences**, for `docs/statements.md`:
- **D5** (already listed): normalizers cancelled; equivalent once `jointPosterior_eq_cond` is proved.
- **D6**: "constants depend on the smallest spacing" is encoded as a lower bound gmin on the spacing, quantified before ∃. This is safe: take gmin equal to the actual smallest spacing.
- **D7**: J ranges over all ℕ. J = 0 and J = 1 are degenerate and allowed (J = 1 is Theorem 1 with 𝒞 = everything). The paper has J ≥ 2, so the Lean statement is safe or equivalent.
- **D8**: measurability is part of the conclusion, as in D3.

To decide at the gate: whether τ is quantified after ∃ (as in Theorem 1's D-reading, where the constants are free of τ beyond the spacing). The paper's dependence list has the spacing but not τ itself, so the plan is yes.

### 5.3 New modules (files under `BQTF/Joint/`)

| # | Module | Paper label | Lean content | Est. lines |
|---|---|---|---|---|
| J0 | `Joint/Spec` additions in `Spec.lean` + `docs/statements.md` §3 | `thm:joint` | statements above; head-owned; Astra gate | 100–200 |
| J1 | `Joint/Product` | §`pf:sec:joint` opening display; D5 | Π^⊗ := `Measure.pi` of the Π_l; `jointPosterior_eq_cond`: Π_𝒞(B) = Π^⊗(B ∩ 𝒞)/Π^⊗(𝒞); measurability of y ↦ Π_𝒞(B \| y) for measurable B; `orderSet` measurable | 250–450 |
| J2 | `Joint/Conditioning` | Lemma `pf:lem:cond` | Π^⊗(𝒞 \| y) > 0 for n > r (𝒞 ⊇ a nonempty open set; positive density); Π_𝒞(θ_j ∈ A) ≤ Π_j(A)/Π^⊗(𝒞); Π_𝒞 is a probability measure | 150–300 |
| J3 | `Joint/Gap` | Lemma `pf:lem:gap` | θ*_{i,j+1} − θ*_{ij} ≥ g₀ = min{L, min_j(τ_{j+1}−τ_j)/f̄}, from B + quantile; reuses `distFn_quantile_eq` (CheckLoss) | 80–150 |
| J4 | `Joint/SupNorm` | Lemma `pf:lem:sup` | s_n, η_n; s_n → 0 (dependence (c, r)), η_n → 0 (dependence (f̲, r)); for n ≥ n₂, Π(‖θ−θ*‖_∞ > s_n) ≤ η_n on Ω_E ∩ Ω_G; P((Ω_E∩Ω_G)ᶜ) ≤ (5/4 + 64/f̲²) n^{−1/(2r)} | 200–350 |
| J5 | `Joint/SupNormScale` | `thm:joint` proof, "General scales" | Lemma `sup` at scale σ₀ via the reduction: s′, η′, Ω with P(Ωᶜ) ≤ {5/4 + 64/(σ₀f̲)²} n^{−1/(2r)} | 200–400 |
| J6 | `Joint/Transfer` | `thm:joint` proof, "The constraint" and "Transfer" | on Ω: Π^⊗(𝒞ᶜ) ≤ J η_n ≤ 1/2; Π_𝒞(U) ≤ 2 Σ_j Π_j(A_j); then E-bound assembly with the bad-event split (measurable hull, as in `Main`) | 250–450 |
| J7 | `Joint/Main` | `thm:joint` | `joint_theorem : JointStatement` (σ = 1), `joint_theorem_scale : JointStatementScale`; constant choice M = max, C = 2ΣC^{(l)} + Σ(5/4 + 64/(σ₀f̲)²), n₀ | 200–400 |

**Total about 1,450–2,700 lines.** This replaces the earlier 600–1,000 estimate, which predates the scale step and the measurability work.

**Dependency order:**

```
J0 (statement gate) ─┬─ J1 ── J2 ─┐
                     ├─ J3 ───────┤
                     ├─ J4 ── J5 ─┼─ J6 ── J7
                     └────────────┘   (J7 also uses main_theorem, main_theorem_scale)
```

J1, J3 and J4 can start in parallel right after the gate. J6 can be proved against the frozen J2–J5 statements while they are still `sorry`, which tests that the interfaces suffice, as `Main` did for Theorem 1.

**Proposed assignment at the trigger** (to confirm with HQ at the time):
- **Neon-A:** J1 `Product` + J2 `Conditioning` (measure theory on products; Neon-A did `Coord`).
- **Neon-B:** J3 `Gap` + J4 `SupNorm`. Neon-B did `CheckLoss`, which J3 reuses.
- **Sol-W2:** J5 `SupNormScale` + the scale half of J7, reusing its own `Scale/`.
- **Sol-W1:** J6 `Transfer` + J7 `Main`, the assembly against frozen interfaces, as for Theorem 1.
- **Opus worker:** reserve.

**Estimate:** about 1–1.5 weeks after the trigger, with 4 provers. The gate (Astra plus head rulings) takes about half a day.

### 5.4 Points for Theory to confirm (sent 2026-11-25)

1. The statement list and the dependency order above, including that no Theorem 1 lemma needs a joint or union-bound version.
2. **Lemma `sup` at general scales.** The paper's "General scales" paragraph applies Lemma `sup` to the rescaled problem with (L/σ₀, σ₀f̲, σ₀f̄, V̄/σ₀) and c replaced by σ₀c. Confirm that s′_n, η′_n and n₂ then depend only on the allowed constants including σ₀, and that s_{n,l} in original units is σ_{0l} s′_{n,l}.
3. **Measurability of y ↦ Π_𝒞(U \| y).** As with C-02, the paper takes E_{θ*} Π_𝒞(U \| y) without stating measurability. This will likely be a candidate correction for Theorem 2, and I propose to fold it into the C-02 text.
4. **Quantifier order for τ.** Confirm that τ may be chosen after (M, C, n₀), given a spacing lower bound, so that the constants depend on the spacing but not on τ otherwise.
5. **Lemma `cond` positivity.** Π^⊗(𝒞 \| y) > 0 needs n > r (properness via Lemma `coord`) and that 𝒞 contains the nonempty open set of strictly ordered vectors. The theorem only needs n ≥ n₀ > r. Confirm there is no other use of n > r.

### 5.5 Theory's answers (received 2026-11-25): plan CONFIRMED

1. **Statement list and order: confirmed.** No Theorem 1 lemma needs a joint or union-bound version; the levels are combined only in J6. J1 is close to definitional, because eq:joint-fixed is already the ratio of the product measure restricted to 𝒞.
   - **J4 uses Theorem 1 internals:** the Ω_G tail and part (b) of `localization`, `interp`, and the Ω_E tail from `denominator`.
   - Head check, 2026-11-25: all three are public `theorem`s in the frozen skeleton. `localization` exposes the explicit tail `r!(e^{−f̲nρ²/16} + e^{−n/8})`, which settles Theory's pre-trigger risk (c). Re-check that they are still public, with unchanged statements, at the trigger.
   - J6 and J7 produce the max_j / ∃j form (U_M) directly, as in the paper's display.
2. **General scales: yes.** The rescaled constants are as follows:
   - `s′_n = C_I{ρ_n + (ρ_n^{2r−2}T′_n)^{1/(2r−1)}}`, with T_n taken at c → σ₀c. It depends on (σ₀c, r).
   - `η′_n = r!{e^{−σ₀f̲nρ²/16} + e^{−n/8}}`. It depends on (σ₀f̲, r).
   - `n₂′` depends on (σ₀c, r, L/σ₀, σ₀f̲, σ₀f̄, V̄/σ₀).
   - In original units, `s_{n,l} = σ_{0l}s′_{n,l}`. This uses the quantile of y/σ₀ being θ*/σ₀, the pushforward under θ ↦ θ/σ₀, and ‖·‖_∞ scaling by σ₀.
   - `P(Ω_lᶜ) ≤ {5/4 + 64/(σ_{0l}f̲)²} n^{−1/(2r)}`, as in J5.
3. **Measurability: agreed.** One Tonelli sentence covers both C-02 and Theorem 2: the integrands are jointly continuous in (Θ, y), and the normalizers are measurable and positive for n > r, so y ↦ Π_𝒞(U | y) is a ratio of measurable functions. Fold this into the C-02 text when the Theorem 2 packet goes out. Measurability of Ω_G belongs to Theorem 1, via a countable dense subset.
4. **τ quantifier order: confirmed.** Spec.lean:160–174 already puts τ after ∃ M C n₀. In Theorem 2, τ enters only through the spacing, and only into n₀. `∀ gmin > 0, ∃ M C n₀, ∀ n ≥ n₀, ∀ τ with spacing ≥ gmin` is faithful, so D6 stands.
5. **Conditions on n:** none beyond n ≥ n₀ (n > r for Lemma cond). The others, including n ≥ n₂^{(l)}, log n ≥ 1 and n ≥ n₀^{(l)}, are absorbed into n₀.
   - **Caveat:** s_n is not monotone. State `max_l s_{n,l} ≤ g0/2` and `J·max_l η_{n,l} ≤ 1/2` as eventual conditions (`∀ᶠ n in atTop`), never as checks at a single n.

**Notes for the provers (no statement change):**
- (a) In J3, derive f̄ ≥ f̲ > 0 from A and B at t = L for n ≥ 1, since Spec does not assume `0 < fu`. Take `g0 = min{L, gmin/f̄}`. Monotonicity of F_i rules out θ*_{j+1} < θ*_j − L, and B handles |d| ≤ L.
- (b) D7: for J ≤ 1 the spacing condition is vacuous, and J = 0 is vacuous too. Keep the plan as written.
- THEOREM_INDEX.md: no change needed.
