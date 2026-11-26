# Theorem 2 Preparation: J3 (`Joint/Gap`) and J4 (`Joint/SupNorm`)

Author: Neon-B  
Date: 2026-11-26  
References inspected (read-only):
- `main` at `aaaedb4` (`lean/PLAN.md` §5 and §5.5, `lean/BQTF/Spec.lean`, `Basic.lean`, `CheckLoss.lean`, `Interp.lean`, `Denominator.lean`, `Localization.lean`, `Asym/Rates.lean`, `Main.lean`, `Scale/Data.lean`, `Scale/Posterior.lean`)
- `t3/sol-w1-assembly` at `e2ceac0` (via `git show` only: `lean/BQTF/Localization.lean`, `Denominator.lean`, `Asym/LocalRates.lean`, `Asym/LocalGeometry.lean`, `Asym/ShellRates.lean`, `Asym/Vector.lean`)
- `paper/sections/theory.tex` (§`sec:joint-result`, `thm:joint`) and `paper/sections/appendix_theory.tex` (§`pf:sec:joint`, Lemmas `pf:lem:gap` and `pf:lem:sup`)

No `.lean` files have been created or edited; this is preparation only ahead of the Theorem 2 trigger.

---

## J3: `BQTF/Joint/Gap.lean` (Lemma `pf:lem:gap`, separation of true quantile curves)

Target math statement (`appendix_theory.tex`, Lemma `pf:lem:gap`; `PLAN.md` §5.3 row J3 and §5.5 Note (a)):  
Given `L > 0`, `fl > 0`, `fu`, `gmin > 0`, levels `τ : Fin J → ℝ` in `(0, 1)` with adjacent spacing `τ_{j+1} - τ_j ≥ gmin`, and `DataHyp` (or `IsProbabilityMeasure`, `IsQuantile`, `AssumptionA`, `AssumptionB`) at every level with common `(L, fl, fu)`, we have `fl ≤ fu` (hence `0 < fu`) whenever `n ≥ 1`, and for all `i : Fin n` and adjacent `j, j + 1 : Fin J`,
$$\theta^*_{i, j+1} - \theta^*_{i, j} \ge g_0 := \min\bigl\{L,\; g_{\min}/\bar f\bigr\}$$
(and more generally `min L ((τ j₂ - τ j₁) / fu) ≤ θs j₂ i - θs j₁ i` for any `τ j₁ < τ j₂`).

### (a) Theorem-1 declarations reused (exact names on `main` @ `aaaedb4`)

| Exact declaration on `main` | File | Role in J3 |
|---|---|---|
| `BQTF.distFn` | `BQTF/Spec.lean:95` | `distFn μ t = (μ (Set.Iic t)).toReal` |
| `BQTF.IsQuantile` | `BQTF/Spec.lean:100` | Gives `τ (j+1) ≤ distFn (μ i) (θs (j+1) i)` directly from `.2` |
| `BQTF.AssumptionA` | `BQTF/Spec.lean:107` | Lower bound near quantile (needed with B to derive `fl ≤ fu`) |
| `BQTF.AssumptionB` | `BQTF/Spec.lean:112` | Upper bound near quantile (both for `distFn_quantile_eq` and `|d| ≤ L` case) |
| `BQTF.DataHyp` | `BQTF/Spec.lean:118` | Bundles `.prob`, `.quantile`, `.assA`, `.assB`, `.signal` |
| `BQTF.AssA1`, `BQTF.AssB1` | `BQTF/CheckLoss.lean:34, 38` | Coordinatewise forms of Assumptions A and B |
| `BQTF.assumptionA_iff`, `BQTF.assumptionB_iff` | `BQTF/CheckLoss.lean:41, 44` | Unpack `AssumptionA` / `AssumptionB` at coordinate `i` |
| `BQTF.CoordHyp` | `BQTF/CheckLoss.lean:51` | Bundles coordinatewise hypotheses for `CheckLoss` lemmas |
| `BQTF.CoordHyp.fl_le_fu` | `BQTF/CheckLoss.lean:68` | Derives `fl ≤ fu` from `AssA1` and `AssB1` at `t = L` (`0 < L`) |
| `BQTF.CoordHyp.hfu` | `BQTF/CheckLoss.lean:75` | Derives `0 < fu` from `0 < fl ≤ fu` |
| `BQTF.distFn_mono` | `BQTF/CheckLoss.lean:78` | `Monotone (distFn μ)` for `[IsFiniteMeasure μ]` |
| `BQTF.distFn_quantile_eq` | `BQTF/CheckLoss.lean:171` | `CoordHyp μ τ q L fl fu → distFn μ q = τ ∧ (μ (Set.Iio q)).toReal = τ` |
| `BQTF.orderSet` | `BQTF/Spec.lean:75` | Optional helper corollary for J6: `‖θ_l - θ*_l‖_∞ ≤ g0/2 ⇒ Θ ∈ orderSet J n` |

### (b) Missing public statements / interface points to watch

1. **Nothing is missing from Theorem 1 for J3.** Every needed lemma (`CoordHyp.fl_le_fu`, `CoordHyp.hfu`, `distFn_mono`, `distFn_quantile_eq`) is already **public** and proved (0 sorries) in `main:lean/BQTF/CheckLoss.lean`.
2. **Pre-`DataHyp` definition of `g0` (`fu` positivity before `n` is instantiated):**  
   `Spec.lean` does not assume `0 < fu`; `fl ≤ fu` (hence `0 < fu`) can only be derived once `n ≥ 1` and a `DataHyp` witness is in scope (via `CoordHyp.fl_le_fu` at coordinate `⟨0, _⟩`). When J7 chooses `n₀` *before* quantifying over `n, μ, θ*`, it needs a strictly positive gap constant `g0 > 0` depending only on `(L, fl, fu, gmin)`.  
   - **Recommended pattern** (matching Sol-W1's `s0 L fl (max fl fu)` in `Localization.lean`): define
     `gapRadius (L fl fu gmin : ℝ) : ℝ := min L (gmin / max fl fu)`
     which is unconditionally positive for `0 < L`, `0 < fl`, `0 < gmin`, and satisfies `gapRadius L fl fu gmin = min L (gmin / fu)` whenever `fl ≤ fu` (in particular for every `n ≥ 1` with `DataHyp`).
   - Alternatively, J3 can state its main separation lemma directly with `min L (gmin / fu)` (deriving `0 < fu` inside the lemma from `i : Fin n` + `DataHyp`), AND provide `gapRadius_eq` (`fl ≤ fu → min L (gmin / max fl fu) = min L (gmin / fu)`) so J7 can choose `n₀` cleanly.
3. **Optional J6 bridge lemma:** Providing the 5-line geometric corollary in `Joint/Gap.lean` (or `Joint/Transfer.lean`): if `∀ l, ∀ i, |θ l i - θs l i| ≤ g / 2` and `∀ j h i, g ≤ θs ⟨j+1, h⟩ i - θs ⟨j, _⟩ i`, then `θ ∈ orderSet J n` (via `Fin.monotone_iff_le_succ` or induction on indices). Not strictly required by J3, but very small and clean.

### (c) Step outline per lemma in `BQTF/Joint/Gap.lean`

1. **`gap_coord` (single-coordinate, two-level separation):**
   - *Inputs:* `μ : Measure ℝ`, `τ₁ < τ₂` (with `0 < τ₁`, `τ₁ < 1`), `q₁ q₂ L fl fu : ℝ`, `h₁ : CoordHyp μ τ₁ q₁ L fl fu`, `hq₂ : IsQuantile μ τ₂ q₂`.
   - *Conclusion:* `fl ≤ fu ∧ 0 < fu ∧ min L ((τ₂ - τ₁) / fu) ≤ q₂ - q₁`.
   - *Steps:*
     1. Obtain `hfl_fu : fl ≤ fu := h₁.fl_le_fu` and `hfu : 0 < fu := h₁.hfu`.
     2. From `distFn_quantile_eq h₁`, get `hF₁ : distFn μ q₁ = τ₁`.
     3. From `hq₂.2`, get `hF₂ : τ₂ ≤ distFn μ q₂`.
     4. Combine with `τ₁ < τ₂` to obtain `distFn μ q₁ < distFn μ q₂`.
     5. By contrapositive of `distFn_mono μ` (with `have := h₁.prob`), deduce `q₁ < q₂`, so `d := q₂ - q₁ > 0`.
     6. Split on `le_or_gt d L`:
        - If `L < d`: `min L ((τ₂ - τ₁) / fu) ≤ L ≤ d`.
        - If `d ≤ L`: since `|d| = d ≤ L`, `h₁.assB d` gives
          `τ₂ - τ₁ ≤ distFn μ q₂ - distFn μ q₁ = distFn μ (q₁ + d) - distFn μ q₁ ≤ |distFn μ (q₁ + d) - distFn μ q₁| ≤ fu * |d| = fu * d`.
          Divide by `hfu` via `div_le_iff₀` to get `(τ₂ - τ₁) / fu ≤ d`, hence `min L ((τ₂ - τ₁) / fu) ≤ d`.
2. **`gap_levels` (full `J`-level version under `DataHyp` + spacing `≥ gmin`):**
   - *Inputs:* `k n J : ℕ`, `L fl fu Vb gmin : ℝ`, `hL : 0 < L`, `hfl : 0 < fl`, `hgmin : 0 < gmin`, `τ : Fin J → ℝ`, `hτ : ∀ j, 0 < τ j ∧ τ j < 1`, `hgap : ∀ (j : ℕ) (h : j + 1 < J), gmin ≤ τ ⟨j + 1, h⟩ - τ ⟨j, by omega⟩`, `μ : Fin n → Measure ℝ`, `θs : Fin J → Fin n → ℝ`, `c : Fin J → ℝ` (not needed for `DataHyp`), `hdata : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb`.
   - *Conclusion:* For all `i : Fin n` and all `j : ℕ` with `h : j + 1 < J`,
     `min L (gmin / fu) ≤ θs ⟨j + 1, h⟩ i - θs ⟨j, by omega⟩ i`
     (and `fl ≤ fu`, `0 < fu`, plus `min L (gmin / max fl fu) = min L (gmin / fu)`).
   - *Steps:*
     1. Fix `i : Fin n` and `j` with `h : j + 1 < J`. Let `j₀ := ⟨j, by omega⟩`, `j₁ := ⟨j + 1, h⟩`.
     2. Construct `CoordHyp (μ i) (τ j₀) (θs j₀ i) L fl fu` directly from `hdata j₀`, `hτ j₀`, `hL`, `hfl`.
     3. Note `τ j₀ < τ j₁` from `0 < gmin ≤ τ j₁ - τ j₀`.
     4. Apply `gap_coord` to get `min L ((τ j₁ - τ j₀) / fu) ≤ θs j₁ i - θs j₀ i` and `0 < fu`.
     5. Use `div_le_div_of_nonneg_right (hgap j h) hfu.le` and `min_le_min_left L` to replace `(τ j₁ - τ j₀) / fu` by `gmin / fu`.
3. **`mem_orderSet_of_sup_le_half_gap` (helper for J6):**
   - *Inputs:* `g : ℝ`, `θ θs : Fin J → Fin n → ℝ`, `hsep : ∀ (j : ℕ) (h : j + 1 < J) i, g ≤ θs ⟨j + 1, h⟩ i - θs ⟨j, by omega⟩ i`, `hclose : ∀ l i, |θ l i - θs l i| ≤ g / 2`.
   - *Conclusion:* `θ ∈ orderSet J n`.
   - *Steps:* Unfold `orderSet`; fix `i : Fin n`. Show `Monotone (fun l : Fin J => θ l i)` via `Fin.monotone_iff_le_succ` (or `Nat.le_induction` on `l₁.val ≤ l₂.val`): for each step `j → j + 1`, `abs_le.mp (hclose ...)` gives `θ j i ≤ θs j i + g/2` and `θs (j+1) i - g/2 ≤ θ (j+1) i`, so `θ j i ≤ θ (j+1) i` by `linarith [hsep j h i]`.

---

## J4: `BQTF/Joint/SupNorm.lean` (Lemma `pf:lem:sup`, sup-norm posterior concentration at `σ = 1`)

Target math statement (`appendix_theory.tex`, Lemma `pf:lem:sup`; `PLAN.md` §5.3 row J4 and §5.5 items 1, 2, 5):  
For `k ≥ 1` (`r = k + 1 ≥ 2`), `c > 0`, `L > 0`, `fl > 0`, `fu`, `Vb`:
- Define
  $$s_n := C_I \Bigl\{\sqrt{\rho_n^2} + \bigl(\sqrt{\rho_n^2}\bigr)^{(2r-2)/(2r-1)} T_n^{1/(2r-1)}\Bigr\}, \qquad
  \eta_n := r!\,\Bigl(e^{-\underline f n \rho_n^2 / 16} + e^{-n/8}\Bigr),$$
  where `C_I` is the universal constant of `BQTF.interp (k + 1) (by omega)`, `ρ_n² = rhoSq (k + 1) n`, and `T_n = Tn (k + 1) n (lamSeq c k n)`.
  Notice `s_n` depends only on `(k, c)` and `η_n` depends only on `(k, fl)`.
- Prove `Tendsto (fun n => s_n) atTop (𝓝 0)` and `Tendsto (fun n => η_n) atTop (𝓝 0)`.
- Prove there exist `CE > 0` and `n₂ > k + 1` (depending only on `(k, c, L, fl, fu, Vb)`) such that for all `n ≥ n₂`, `τ ∈ (0, 1)`, `μ, θs` with `DataHyp k n τ μ θs L fl fu Vb`, setting `Ω := OmegaE k n τ (lamSeq c k n) θs CE ∩ OmegaG k n c τ fl μ θs`:
  1. For all `y ∈ Ω`,
     `posterior τ 1 (lamSeq c k n) k n y {θ | s_n < ‖θ - θs‖} ≤ ENNReal.ofReal (η_n)`
     (and equivalently with `{θ | ∃ i, s_n < |θ i - θs i|}`);
  2. `Measure.pi μ Ωᶜ ≤ ENNReal.ofReal ((5 / 4 + 64 / fl ^ 2) * massRate k n)`.

### (a) Theorem-1 declarations reused (exact names on `main` @ `aaaedb4`)

| Exact declaration on `main` | File | Status on `main` (`aaaedb4`) | Role in J4 |
|---|---|---|---|
| `BQTF.posterior` | `BQTF/Spec.lean:68` | Public def | Posterior measure in the sup-norm tail bound |
| `BQTF.DataHyp` | `BQTF/Spec.lean:118` | Public structure | Single-level data hypotheses |
| `BQTF.lamSeq` | `BQTF/Spec.lean:129` | Public def | `λ = c n^{(2k+1)/2}` |
| `BQTF.massRate` | `BQTF/Spec.lean:135` | Public def | `n^{-(1/(2k+2))} = n^{-1/(2r)}` |
| `BQTF.empNorm`, `BQTF.TVr`, `BQTF.Kset` | `BQTF/Basic.lean:34, 134, 137` | Public defs | Definition of `K_n = K(ρ_n, T_n)` |
| `BQTF.epsSq`, `BQTF.rhoSq`, `BQTF.Tn` | `BQTF/Basic.lean:125, 128, 131` | Public defs | Sequences in `s_n`, `η_n`, and rate comparisons |
| `BQTF.interp` | `BQTF/Interp.lean:16` | Public theorem (`sorry` on `main`, Neon-A) | Gives `CI > 0` and `|δ i| ≤ s_n` for `δ ∈ K_n`, `n > r` |
| `BQTF.OmegaE` | `BQTF/Denominator.lean:24` | Public def | Denominator good event `Ω_E` |
| `BQTF.denominator` | `BQTF/Denominator.lean:30` | Public theorem (`sorry` on `main`; proved on `t3/sol-w1-assembly`) | Produces `CE > 0`, `n₁ > k + 1`, and `P(Ω_Eᶜ) ≤ ofReal(5/4 / (n ε_n²))` |
| `BQTF.Kn`, `BQTF.OmegaG` | `BQTF/Localization.lean:20, 27` | Public defs | Localization set `K_n` and event `Ω_G` |
| `BQTF.localization` | `BQTF/Localization.lean:37` | Public theorem (`sorry` on `main`; proved on `t3/sol-w1-assembly`) | Takes `CE`, produces `n₂ > k + 1`, gives `P(Ω_Gᶜ) ≤ ofReal(64 / (fl² n ρ_n²))` and on `Ω_G ∩ Ω_E` gives `posterior ... {θ \| θ - θs ∉ Kn k n c} ≤ ofReal(η_n)` |
| `BQTF.Asym.massRate_eq_inv` | `BQTF/Asym/Rates.lean:25` | Public theorem (proved on `main`) | `massRate k n = (n * epsSq (k + 1) n)⁻¹` |
| `BQTF.Asym.mul_epsSq_le_mul_rhoSq` | `BQTF/Asym/Rates.lean:41` | Public theorem (proved on `main`) | `n * epsSq r n ≤ n * rhoSq r n` for `r ≥ 1`, `n ≥ 1`, `1 ≤ log n` |
| `BQTF.Asym.eventually_mul_epsSq_ge` | `BQTF/Asym/Rates.lean:54` | Public theorem (proved on `main`) | `∀ B, ∃ N, ∀ n ≥ N, 0 < n ∧ B ≤ n * epsSq r n` (used for `η_n → 0`) |
| `BQTF.Asym.eventually_log_ge_one` | `BQTF/Asym/Rates.lean:64` | Public theorem (proved on `main`) | `∃ N, ∀ n ≥ N, 1 ≤ Real.log n` |

**Additional public lemmas on Sol-W1's branch `t3/sol-w1-assembly` (`e2ceac0`) that J4 can reuse once merged:**

| Exact declaration on `t3/sol-w1-assembly` | File | Visibility | Role in J4 |
|---|---|---|---|
| `BQTF.Asym.interpolation_factor_tendsto_zero` | `BQTF/Asym/LocalRates.lean:39` | **Public** `theorem` | Proves `Tendsto (fun n => √(rhoSq r n) + √(rhoSq r n)^((2r-2)/(2r-1)) * Tn r n (lamSeq c k n)^(1/(2r-1))) atTop (𝓝 0)` — literally `s_n / C_I → 0`! |
| `BQTF.Asym.rhoSq_tendsto_zero` | `BQTF/Asym/LocalRates.lean:28` | **Public** `theorem` | `Tendsto (rhoSq r) atTop (𝓝 0)` |
| `BQTF.Asym.Tn_eq` | `BQTF/Asym/LocalRates.lean:11` | **Public** `theorem` | `Tn (k+1) n (lamSeq c k n) = (4 / c) * √n` |
| `BQTF.empNorm_nonneg`, `BQTF.TVr_nonneg` | `BQTF/Asym/LocalGeometry.lean:17, 20` | **Public** `theorem`s | Nonnegativity inputs to `Real.rpow_le_rpow` when bounding `|δ i| ≤ s_n` on `K_n` |

### (b) Audit of `t3/sol-w1-assembly` and what is missing as a public statement

1. **Public exposure check on `t3/sol-w1-assembly` (`e2ceac0`):**
   - `BQTF.localization` (`Localization.lean:608`) is **public** with the exact frozen signature from `main`: it exposes **both** the `Ω_G` probability tail `Measure.pi μ (OmegaG k n c τ fl μ θs)ᶜ ≤ ENNReal.ofReal (64 / (fl ^ 2 * n * rhoSq (k + 1) n))` **and** part (b)'s posterior bound on `OmegaG ∩ OmegaE` with explicit `Nat.factorial (k + 1) * (Real.exp (-(fl * n * rhoSq (k + 1) n / 16)) + Real.exp (-(n / 8 : ℝ)))`.
   - `BQTF.denominator` (`Denominator.lean:338`) is **public** with the exact frozen signature from `main`: it exposes `CE > 0`, `n₁ > k + 1`, and the `Ω_E` probability tail `Measure.pi μ (OmegaE k n τ (lamSeq c k n) θs CE)ᶜ ≤ ENNReal.ofReal (5 / 4 / (n * epsSq (k + 1) n))`.
   - The internal helper lemmas in `Localization.lean` (`local_event_probability`, `local_posterior_bound`, etc.) and `Denominator.lean` (`evidence_set_data`, `evidence_average_bounds`, `evidence_jensen`, etc.) are `private`, **and J4 does NOT need any of them**.
   - **Bonus:** `BQTF.Asym.interpolation_factor_tendsto_zero`, `BQTF.Asym.rhoSq_tendsto_zero`, `BQTF.empNorm_nonneg`, and `BQTF.TVr_nonneg` are already **public** on `t3/sol-w1-assembly` (`Asym/LocalRates.lean` and `Asym/LocalGeometry.lean`). Once `t3/sol-w1-assembly` merges, J4 gets `s_n → 0` in 2 lines by `const_mul CI`!
2. **Missing public statements (none require changing Theorem-1 frozen statements):**
   - **`η_n → 0` (`supMass_tendsto_zero`):** Neither `main` nor `t3/sol-w1-assembly` currently exposes `Tendsto (fun n => (n : ℝ) * rhoSq r n) atTop atTop` or `Tendsto (fun n => η_n) atTop (𝓝 0)`. This is ~15 lines in `Joint/SupNorm.lean` using `Asym.mul_epsSq_le_mul_rhoSq`, `Asym.eventually_mul_epsSq_ge`, `Asym.eventually_log_ge_one`, and `Real.tendsto_exp_atBot`.
   - **Measurability of `OmegaE` and `OmegaG`:** Neither `Denominator.lean` nor `Localization.lean` (on `main` or `t3/sol-w1-assembly`) proves `MeasurableSet (OmegaE ...)` or `MeasurableSet (OmegaG ...)`.
     - For **J4 itself**, measurability of `Ω_E` and `Ω_G` is **not needed**: `Set.compl_inter` + `MeasureTheory.measure_union_le` holds for outer measures on arbitrary sets.
     - For **J6 (`Joint/Transfer`)**: `Main.lean:304` handles the exact same situation via `toMeasurable P (...)` (measurable hull), as already planned in `PLAN.md` §5.3 row J6. If J6/J5 ever wants `MeasurableSet (OmegaG ...)` directly, `gk_measurable_and_bounded` already exists in `Concentration.lean:274` (currently `private`, trivial to make public if needed), whereas `toMeasurable` avoids needing `MeasurableSet (OmegaE ...)` altogether.
   - **Choice of `C_I` for `s_n`:** Because `BQTF.interp` is existential (`∃ CI, 0 < CI ∧ ...`), J4 should define a public `def interpConst (r : ℕ) (hr : 2 ≤ r) : ℝ := Classical.choose (interp r hr)` (or `supRad (k : ℕ) (hk : 1 ≤ k) (c : ℝ) (n : ℕ) : ℝ` directly using `Classical.choose (interp (k + 1) (by omega))`) so that `s_n` is an explicit function of `(k, c, n)` — making its `(c, k)`-only dependence manifest for J5 (`SupNormScale`) and J7 (`Main`).
   - **Sup-norm set form (`‖θ - θs‖` vs `∃ i, |θ i - θs i|`):** On `Fin n → ℝ`, Mathlib's `‖v‖` is the sup norm (`Pi.norm_def`). Since `0 ≤ s_n` for all `n` (note `Real.sqrt _ ≥ 0`, `Real.rpow _ _ ≥ 0`, `0 < CI`), `{θ | s_n < ‖θ - θs‖} = {θ | ∃ i, s_n < |θ i - θs i|}` holds for every `n : ℕ` (including `n = 0`, where both sets are empty). Exposing the sup-norm form (matching `appendix_theory.tex`) plus the coordinate equivalence lemma ensures clean compatibility with both J5 (which scales `‖·‖` by `σ₀`) and J6 (which uses coordinatewise `|θ l i - θs l i| ≤ g0 / 2` in `Gap`).

### (c) Step outline per lemma in `BQTF/Joint/SupNorm.lean`

1. **Definitions (`supRad`, `supMass`):**
   - `def interpConst (k : ℕ) (hk : 1 ≤ k) : ℝ := Classical.choose (interp (k + 1) (by omega))`
   - `lemma interpConst_spec (k : ℕ) (hk : 1 ≤ k)`: gives `0 < interpConst k hk` and the coordinatewise bound from `Classical.choose_spec`.
   - `def supRad (k : ℕ) (hk : 1 ≤ k) (c : ℝ) (n : ℕ) : ℝ := interpConst k hk * (Real.sqrt (rhoSq (k + 1) n) + Real.sqrt (rhoSq (k + 1) n) ^ ((2 * (k + 1) - 2 : ℝ) / (2 * (k + 1) - 1)) * Tn (k + 1) n (lamSeq c k n) ^ ((1 : ℝ) / (2 * (k + 1) - 1)))`
   - `def supMass (k : ℕ) (fl : ℝ) (n : ℕ) : ℝ := Nat.factorial (k + 1) * (Real.exp (-(fl * n * rhoSq (k + 1) n / 16)) + Real.exp (-(n / 8 : ℝ)))`
   - Trivial nonnegativity lemmas `supRad_nonneg` (for `0 < c`, or all `n` using `Real.rpow_nonneg`) and `supMass_nonneg`.
2. **`supRad_tendsto_zero` (`s_n → 0`):**
   - *Inputs:* `k : ℕ`, `hk : 1 ≤ k`, `c : ℝ`, `hc : 0 < c`.
   - *Conclusion:* `Tendsto (supRad k hk c) atTop (𝓝 0)`.
   - *Steps:* Apply `(Asym.interpolation_factor_tendsto_zero k hk c hc).const_mul (interpConst k hk)` and `simp only [mul_zero]`.
3. **`supMass_tendsto_zero` (`η_n → 0`):**
   - *Inputs:* `k : ℕ`, `hk : 1 ≤ k`, `fl : ℝ`, `hfl : 0 < fl`.
   - *Conclusion:* `Tendsto (supMass k fl) atTop (𝓝 0)`.
   - *Steps:*
     1. Show `Tendsto (fun n : ℕ => (n : ℝ) * rhoSq (k + 1) n) atTop atTop`: for any `B : ℝ`, combine `Asym.eventually_mul_epsSq_ge (k + 1) (by omega) B` with `Asym.eventually_log_ge_one` and `Asym.mul_epsSq_le_mul_rhoSq`.
     2. Deduce `Tendsto (fun n : ℕ => -(fl * n * rhoSq (k + 1) n / 16)) atTop atBot` (multiplying by `-fl / 16 < 0`), hence `Real.exp (...) → 0` via `Real.tendsto_exp_atBot.comp`.
     3. Similarly `-(n / 8 : ℝ) → atBot`, hence `Real.exp (-(n / 8 : ℝ)) → 0`.
     4. Add and multiply by `(k + 1)!` to conclude `Tendsto (supMass k fl) atTop (𝓝 0)`.
4. **`sup_le_supRad_of_mem_Kn` (interpolation step on `K_n`):**
   - *Inputs:* `hk : 1 ≤ k`, `hn : k + 1 < n`, `hc : 0 < c`, `δ ∈ Kn k n c`.
   - *Conclusion:* `∀ i : Fin n, |δ i| ≤ supRad k hk c n` (and `‖δ‖ ≤ supRad k hk c n`).
   - *Steps:*
     1. Apply `(interpConst_spec k hk).2 n hn δ i`.
     2. Unpack `hδ : empNorm δ ≤ Real.sqrt (rhoSq (k + 1) n) ∧ TVr (k + 1) n δ ≤ Tn (k + 1) n (lamSeq c k n)`.
     3. Apply `mul_le_mul_of_nonneg_left` (with `0 < interpConst k hk`), `add_le_add`, and `Real.rpow_le_rpow` using `empNorm_nonneg`, `TVr_nonneg`, and nonnegativity of the exponents `(2r - 2)/(2r - 1) ≥ 0` and `1/(2r - 1) > 0` for `r = k + 1 ≥ 2`.
     4. Deduce `‖δ‖ ≤ supRad k hk c n` via `pi_norm_le_iff_of_nonneg` (with `supRad_nonneg`).
5. **`supNorm_bad_event_bound` (combining `Ω_Eᶜ` and `Ω_Gᶜ` tails):**
   - *Inputs:* `hk : 1 ≤ k`, `hn : 1 ≤ n`, `hlog : 1 ≤ Real.log n`, `hfl : 0 < fl`,
     `hE : Measure.pi μ Eᶜ ≤ ENNReal.ofReal (5 / 4 / (n * epsSq (k + 1) n))`,
     `hG : Measure.pi μ Gᶜ ≤ ENNReal.ofReal (64 / (fl ^ 2 * n * rhoSq (k + 1) n))`.
   - *Conclusion:* `Measure.pi μ (E ∩ G)ᶜ ≤ ENNReal.ofReal ((5 / 4 + 64 / fl ^ 2) * massRate k n)`.
   - *Steps:*
     1. `Set.compl_inter` + `measure_union_le` gives `P (E ∩ G)ᶜ ≤ P Eᶜ + P Gᶜ ≤ ofReal (...) + ofReal (...) = ofReal (5 / 4 / (n * epsSq r n) + 64 / (fl ^ 2 * n * rhoSq r n))` (using `ENNReal.ofReal_add`).
     2. By `Asym.mul_epsSq_le_mul_rhoSq (k + 1) n (by omega) hn hlog`, `0 < n * epsSq (k + 1) n ≤ n * rhoSq (k + 1) n`, so
        `64 / (fl ^ 2 * n * rhoSq (k + 1) n) ≤ 64 / (fl ^ 2 * n * epsSq (k + 1) n)`.
     3. Rewrite `((n : ℝ) * epsSq (k + 1) n)⁻¹ = massRate k n` via `Asym.massRate_eq_inv k n (by omega)` and factor `(5 / 4 + 64 / fl ^ 2) * massRate k n`.
6. **`supNorm` (main Lemma `pf:lem:sup`):**
   - *Inputs:* `k : ℕ`, `hk : 1 ≤ k`, `c L fl fu Vb : ℝ`, `hc : 0 < c`, `hL : 0 < L`, `hfl : 0 < fl`.
   - *Conclusion:*
     `∃ CE : ℝ, ∃ n₂ : ℕ, 0 < CE ∧ k + 1 < n₂ ∧ ∀ n, n₂ ≤ n → ∀ τ : ℝ, 0 < τ → τ < 1 → ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →`
     `(∀ y ∈ OmegaE k n τ (lamSeq c k n) θs CE ∩ OmegaG k n c τ fl μ θs, posterior τ 1 (lamSeq c k n) k n y {θ | supRad k hk c n < ‖θ - θs‖} ≤ ENNReal.ofReal (supMass k fl n)) ∧`
     `Measure.pi μ (OmegaE k n τ (lamSeq c k n) θs CE ∩ OmegaG k n c τ fl μ θs)ᶜ ≤ ENNReal.ofReal ((5 / 4 + 64 / fl ^ 2) * massRate k n)`.
   - *Steps:*
     1. Obtain `⟨CE, n₁, hCE, hn₁, hdenom⟩ := denominator k hk c L fl fu Vb hc hL hfl`.
     2. Obtain `⟨n₂', hn₂', hloc⟩ := localization k hk c L fl fu Vb hc hL hfl CE`.
     3. Obtain `⟨nLog, hnLog⟩ := Asym.eventually_log_ge_one`.
     4. Set `n₂ := max n₁ (max n₂' nLog)`; clearly `k + 1 < n₂` from `hn₁`.
     5. For any `n ≥ n₂`, `τ ∈ (0, 1)`, `μ, θs`, `hdata`:
        - Instantiate `hdenom` and `hloc` to get `hE`, `hG`, and `hpost_Kn`.
        - For `y ∈ OmegaE ∩ OmegaG`, note `{θ | supRad k hk c n < ‖θ - θs‖} ⊆ {θ | θ - θs ∉ Kn k n c}` by contrapositive of `sup_le_supRad_of_mem_Kn`, apply `measure_mono`, and conclude by `hpost_Kn y ⟨hy.2, hy.1⟩`.
        - Apply `supNorm_bad_event_bound` using `hE`, `hG`, and `hnLog n (le_trans ... hn)` for the probability bound.
