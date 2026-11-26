# Neon-B Questions & Classical Inputs Audit

Last updated: 2026-11-25

## Audit for `BQTF/Concentration.lean` (`concentration`, Lemma `pf:lem:conc`)

### Target statement (frozen in `lean/BQTF/Concentration.lean`)
For `τ ∈ (0, 1)`, probability measures `μ : Fin n → Measure ℝ`, `θs : Fin n → ℝ`, and a compact, symmetric, nonempty set `K ⊆ Fin n → ℝ`:
1. `Integrable (GK τ μ θs K) (Measure.pi μ)`,
2. `∫ y, GK τ μ θs K y ∂(Measure.pi μ) ≤ 4 * ∫ ξ, sSup ((fun δ => dot ξ δ) '' K) ∂(rademacher n)`,
3. `variance (GK τ μ θs K) (Measure.pi μ) ≤ sSup (l2sq '' K)`,

where `GK τ μ θs K y = sSup ((fun δ => |lossHat τ (y - θs) δ - lossExp τ μ θs δ|) '' K)`.

### Key simplification: reduction from compact `K` to finite subsets `T`
For every `y : Fin n → ℝ`, `δ ↦ |lossHat τ (y - θs) δ - lossExp τ μ θs δ|` is `2n`-Lipschitz in the sup norm (using `ell_props` from `CheckLoss.lean`) and uniformly bounded on compact `K` by `2 * n * sup_{δ ∈ K} ‖δ‖_∞`. Because `Fin n → ℝ` is second-countable, `K` has a countable nonempty symmetric dense subset `D = D₀ ∪ (-D₀)`, hence an increasing chain of nonempty finite symmetric subsets `T_m ⊆ K` with `GK_{T_m}(y) ↑ GK_K(y)` pointwise everywhere. By dominated convergence (`MeasureTheory.tendsto_integral_of_dominated_convergence`), both measurability/integrability of `GK` and the expectation bound (inputs 1 and 2) reduce cleanly to **finite index sets `T : Finset (Fin n → ℝ)`**.

For the variance bound (input 3), compactness + continuity directly gives a maximizer `δ̂(y) ∈ K` (`IsCompact.exists_isMaxOn`), so Efron–Stein applies directly to the bounded measurable function `f = GK τ μ θs K` on `Measure.pi μ`.

**Important note on the variance bound (why bounded differences is NOT sufficient):**
The paper's bound is `Var(G_K) ≤ sup_{δ ∈ K} ‖δ‖₂²`, not `∑_i (sup_{δ ∈ K} |δ_i|)²`. Ordinary McDiarmid/bounded-differences loses a factor up to `n` because it takes `sup_{δ ∈ K}` *inside* the sum over `i`. Keeping the maximizer `δ̂(y)` inside the sum requires the **one-sided Efron–Stein inequality**
`Var(f) ≤ ∑_i E[(f(y) - f(Function.update y i y'_i))_+^2]`,
using `GK(y) - GK(y^{(i)}) ≤ |δ̂(y) i|` (via `ell_props`, which bounds the oscillation of `z ↦ ell τ t z` by `|t|`), so `∑_i (GK(y) - GK(y^{(i)}))_+^2 ≤ l2sq (δ̂(y)) ≤ sSup (l2sq '' K)`.

---

### Input 1: Symmetrization for finite empirical processes (abs form; vdV–W Lemma 2.3.6)

- **(a) Exact statement needed:**
  Let `μ : Fin n → Measure ℝ` with `[∀ i, IsProbabilityMeasure (μ i)]`, `T : Finset α` with `T.Nonempty`, and `φ : Fin n → α → ℝ → ℝ` such that each `(t, x) ↦ φ i t x` is measurable and bounded (`∀ i t x, |φ i t x| ≤ M`). Let `m i t := ∫ x, φ i t x ∂(μ i)`. Then
  ```lean
  ∫ y, (T.sup' hT fun t => |∑ i, (φ i t (y i) - m i t)|) ∂(Measure.pi μ) ≤
    2 * ∫ y, (∫ ξ, (T.sup' hT fun t => |∑ i, ξ i * φ i t (y i)|) ∂(rademacher n)) ∂(Measure.pi μ)
  ```
  (Here `φ i δ x = ell τ (δ i) (x - θs i)` for `δ ∈ T ⊆ K`.)

- **(b) Nearest Mathlib results (pinned Mathlib `065356127b`):**
  - No symmetrization lemma exists in `Mathlib/Probability/`.
  - Direct building blocks already in Mathlib:
    - `MeasureTheory.measurePreserving_swap` (`Mathlib/MeasureTheory/Measure/Prod.lean:703`)
    - `MeasureTheory.measurePreserving_pi` (`Mathlib/MeasureTheory/Constructions/Pi.lean:907`) — gives coordinatewise swap invariance on `(Measure.pi μ).prod (Measure.pi μ)` for any fixed sign vector `ξ ∈ {-1, 1}^n`
    - `MeasureTheory.integral_integral_swap` (`Mathlib/MeasureTheory/Integral/Prod.lean:478`)
    - `abs_integral_le_integral_abs` and `integral_mono` (gives Jensen for `sup_{t ∈ T} |·|` directly in ~5 lines without `ConvexOn`)

- **(c) Cost estimate:**
  **0.2–0.3 days** (~120–160 lines in `BQTF/Prob/`). Completely elementary.

---

### Input 2: Ledoux–Talagrand Rademacher contraction principle (abs form, symmetric finite index set; Ledoux–Talagrand Theorem 4.12)

- **(a) Exact statement needed:**
  Let `T : Finset (Fin n → ℝ)` be nonempty and symmetric (`∀ δ ∈ T, -δ ∈ T`), and let `φ : Fin n → ℝ → ℝ` be 1-Lipschitz vanishing at `0` (`∀ i, φ i 0 = 0` and `∀ i u v, |φ i u - φ i v| ≤ |u - v|`). Then
  ```lean
  ∫ ξ, (T.sup' hT fun δ => |∑ i, ξ i * φ i (δ i)|) ∂(rademacher n) ≤
    2 * ∫ ξ, (T.sup' hT fun δ => dot ξ δ) ∂(rademacher n)
  ```
  Note on `0 ∉ T`: `K` is only assumed compact, symmetric, and nonempty (not convex, so `0` need not lie in `K` or `T`). The proof adjoins `0` (`T₀ := insert 0 T`) so that both `sup_{T₀} ∑ ξ_i φ_i(δ_i)` and `sup_{T₀} (-∑ ξ_i φ_i(δ_i))` are `≥ 0` (using `φ_i(0) = 0`), yielding `sup_T |·| ≤ sup_{T₀} (·) + sup_{T₀} (-·)`; then sign-flip invariance of `rademacher n` gives factor `2`, the standard 1-coordinate peeling induction (factor `1`) reduces `φ_i(δ_i)` to `δ_i` on `T₀`, and symmetry + nonemptiness of `T` gives `sup_{T₀} ⟨ξ, δ⟩ = sup_T ⟨ξ, δ⟩`.

- **(b) Nearest Mathlib results:**
  - No Rademacher contraction / Talagrand inequality exists in `Mathlib/Probability/` or `Mathlib/Analysis/` (`Mathlib/Analysis/Calculus/Rademacher.lean` is Rademacher's differentiation theorem, unrelated).
  - Direct building blocks already in Mathlib:
    - `MeasureTheory.measurePreserving_piFinSuccAbove` (`Mathlib/MeasureTheory/Constructions/Pi.lean:806`) for peeling one Rademacher coordinate at a time in the `Fin n` induction
    - `MeasureTheory.measurePreserving_pi` (`Mathlib/MeasureTheory/Constructions/Pi.lean:907`) for sign-flip invariance `ξ ↦ -ξ` of `rademacher n`
    - `Finset.exists_mem_eq_sup'` for choosing maximizers on finite nonempty `T₀`

- **(c) Cost estimate:**
  **0.2–0.3 days** (~150–200 lines in `BQTF/Prob/`). Completely elementary.

---

### Input 3: Efron–Stein inequality (one-sided / independent-copy form on `Measure.pi μ`; Boucheron–Lugosi–Massart Theorem 3.1)

- **(a) Exact statement needed:**
  Let `μ : Fin n → Measure ℝ` with `[∀ i, IsProbabilityMeasure (μ i)]`, and let `f : (Fin n → ℝ) → ℝ` be measurable and bounded (`∃ C, ∀ y, |f y| ≤ C`, or `MemLp f 2 (Measure.pi μ)`). Then
  ```lean
  variance f (Measure.pi μ) ≤
    ∑ i : Fin n, ∫ y, (∫ x, (max (f y - f (Function.update y i x)) 0) ^ 2 ∂(μ i)) ∂(Measure.pi μ)
  ```
  (Equivalently `variance f (Measure.pi μ) ≤ (1 / 2) * ∑ i, ∫ y, ∫ x, (f y - f (Function.update y i x)) ^ 2 ∂(μ i) ∂(Measure.pi μ)`, since the two forms are identical by swapping `y i` and `x` via `measurePreserving_swap`.)

- **(b) Nearest Mathlib results:**
  - No Efron–Stein, bounded-differences, or tensorization-of-variance theorem exists in `Mathlib/Probability/`.
  - Nearest related files in Mathlib:
    - `Mathlib/Probability/CondVar.lean:135` has the law of total variance `integral_condVar_add_variance_condExp` (`μ[Var[X; μ | m]] + Var[μ[X | m]; μ] = Var[X; μ]`).
    - `Mathlib/Probability/Moments/Variance.lean:157, 226` has `variance_eq_integral` and `variance_eq_sub`.
    - `Mathlib/MeasureTheory/Constructions/Pi.lean:714, 806` has `measurePreserving_piEquivPiSubtypeProd` and `measurePreserving_piFinSuccAbove`.
    - `Mathlib/MeasureTheory/Integral/Marginal.lean` has `lmarginal` (for `ℝ≥0∞`-valued functions only; its TODO notes Bochner marginals are not yet implemented).
    - `Mathlib/Analysis/Convex/Integral.lean:197` has Jensen's inequality `ConvexOn.map_integral_le` (for `sq` on `ℝ`).
  - Proof route avoiding heavy `condExp` / sub-σ-algebra boilerplate: define explicit Bochner partial expectations `g_k(y) = ∫ z, f (fun i => if i.val < k then y i else z i) ∂(Measure.pi μ)` for `k = 0, …, n`. Orthogonality of `Δ_k = g_{k+1} - g_k` follows directly from `measurePreserving_piEquivPiSubtypeProd` + Fubini; `E[Δ_k^2] ≤ E[(f(y) - E_{x_k} f(update y k x_k))^2]` follows from 1-D Jensen (`ConvexOn.map_integral_le`) + Fubini; and rewriting each 1-D variance as `(1/2) E[(f(y) - f(update y k x_k))^2] = E[(f(y) - f(update y k x_k))_+^2]` uses `measurePreserving_swap`.

- **(c) Cost estimate:**
  **0.3–0.5 days** (~200–280 lines in `BQTF/Prob/`).

---

### Input 4 (Non-classical glue): Compact-to-finite reduction & measurability/integrability of `GK`
- **(a) What is needed:** For compact nonempty symmetric `K ⊆ Fin n → ℝ`, construct an increasing chain of finite nonempty symmetric `T_m ⊆ K` with `⋃ T_m` dense in `K`, prove `GK_{T_m} ↑ GK_K` pointwise, deduce `Measurable (GK ...)` and `Integrable (GK ...)`, and pass `E[GK_{T_m}] ≤ 4 E[sup_{T_m} ⟨ξ, δ⟩]` to `K` via dominated convergence.
- **(b) Nearest Mathlib results:** `TopologicalSpace.exists_countable_dense_subset` (`Mathlib/Topology/Bases.lean:354`), `IsCompact.exists_isMaxOn`, `IsCompact.isBounded`, `MeasureTheory.tendsto_integral_of_dominated_convergence`.
- **(c) Cost estimate:** **0.1–0.2 days** (~100–130 lines directly in `BQTF/Concentration.lean`).

---

### Recommendation & question for Lean head
All three classical inputs are individually well under 1 day (**~0.8–1.2 days total**, ~500–650 lines combined in `BQTF/Prob/` plus ~150 lines in `Concentration.lean`). None requires heavy machinery (`condExp`, martingales, or general empirical-process measurability).

1. **Should I prove all three inputs directly in `BQTF/Prob/`** (so `Concentration.lean` lands completely sorry-free and hypothesis-free in one pass), or would you prefer any of them staged first as explicit hypotheses?
2. **Preferred file organization under `BQTF/Prob/`:** three focused files (`BQTF/Prob/Symmetrization.lean`, `BQTF/Prob/Contraction.lean`, `BQTF/Prob/EfronStein.lean`) or one combined file (`BQTF/Prob/EmpiricalProcess.lean`)?
