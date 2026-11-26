# Neon-A Theorem 2 Prep Notes (J1 `Joint/Product` and J2 `Joint/Conditioning`)

Date: 2026-11-25
Reference: `lean/PLAN.md` §5 / §5.5, `paper/sections/appendix_theory.tex` §`pf:sec:joint` (Lemma `pf:lem:cond`), `lean/BQTF/Spec.lean`.

Planning notes only (no Theorem 2 `.lean` files created).

---

## General observation (valid for both J1 and J2)

1. **General `σ : Fin J → ℝ` (`∀ j, 0 < σ j`) comes for free.** `Spec.lean`'s `postWeight`, `posterior`, `jointWeight`, and `jointPosterior`, as well as `Coord.lean`'s `lintegral_postWeight_pos_lt_top` and `posterior_isProbability`, are already parameterized by arbitrary `σ > 0`. Stating J1 and J2 for general `σ : Fin J → ℝ` (`∀ j, 0 < σ j`) covers both `JointStatement` (`σ = fun _ => 1`) and `JointStatementScale` (`σ = σ₀`) in one pass with no extra work.
2. **`1 ≤ n` suffices (hence `n > r`).** `Coord.lintegral_postWeight_pos_lt_top` and `Coord.posterior_isProbability` only require `1 ≤ n`, `0 < τ ∧ τ < 1`, `0 < σ`, `0 ≤ lam`. Thus J1 and J2 do not need `n > r` internally, and immediately specialize to `n > r` (or `n ≥ n₀ > r`).
3. **Degenerate `J = 0` and `J = 1` (D7).** For `J = 0`, `jointWeight = 1`, `orderSet 0 n = Set.univ`, and `volume (Set.univ : Set (Fin 0 → Fin n → ℝ)) = 1`, so `prodPosterior = jointPosterior` and all statements hold without needing `1 ≤ J` or `2 ≤ J`.

---

## J1: `BQTF/Joint/Product.lean` (§`pf:sec:joint` opening display, D5, measurability)

### Planned declarations
- `prodPosterior {J : ℕ} (τ σ lam : Fin J → ℝ) (k n : ℕ) (y : Fin n → ℝ) : Measure (Fin J → Fin n → ℝ) := Measure.pi fun j => posterior (τ j) (σ j) (lam j) k n y` (`Π^⊗(· | y)`).
- `measurableSet_orderSet (J n : ℕ) : MeasurableSet (orderSet J n)` — `orderSet J n = ⋂ i : Fin n, ⋂ j₁ : Fin J, ⋂ j₂ : Fin J, ⋂ (_ : j₁ ≤ j₂), {Θ | Θ j₁ i ≤ Θ j₂ i}` (finite intersection of closed sets).
- `prodPosterior_isProbability` — `IsProbabilityMeasure (prodPosterior τ σ lam k n y)` (direct from `Coord.posterior_isProbability` + `Measure.pi.instIsProbabilityMeasure`).
- `prodPosterior_eq_withDensity` — `prodPosterior τ σ lam k n y = (∏ j, ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ)⁻¹ • volume.withDensity (jointWeight τ σ lam k n y)`.
- `jointPosterior_eq_cond` (D5) — for every `B : Set (Fin J → Fin n → ℝ)`:
  `jointPosterior τ σ lam k n y B = (prodPosterior τ σ lam k n y (orderSet J n))⁻¹ * prodPosterior τ σ lam k n y (B ∩ orderSet J n)`.
- `measurable_jointPosterior_apply` (D8 / C-02) — for any `MeasurableSet B`, `Measurable (fun y => jointPosterior τ σ lam k n y B)`.

### Theorem-1 lemmas reused
| Declaration | Source | Use in J1 |
|---|---|---|
| `postWeight`, `posterior`, `orderSet`, `jointWeight`, `jointPosterior` | `BQTF/Spec.lean` | core definitions |
| `measurable_postWeight` | `BQTF/Coord.lean:536` | `θ`-measurability of per-level weight for `withDensity` / Tonelli |
| `lintegral_postWeight_pos_lt_top` | `BQTF/Coord.lean:552` | `0 < Z_j` and `Z_j < ∞` so `∏ Z_j ∈ (0, ∞)` cancels in `jointPosterior_eq_cond` |
| `posterior_isProbability` | `BQTF/Coord.lean:747` | `IsProbabilityMeasure` (hence `SigmaFinite`) of each factor `Π_j` in `Measure.pi` |
| `Scale/Posterior.lean` pattern (`measurable_postWeight`, `measurable_posterior_apply`) | `BQTF/Scale/Posterior.lean:77-98` | template for joint `(y, Θ)` measurability of `jointWeight` and `Measurable.lintegral_prod_right` |

### Missing helper statements / small gaps to build in J1
1. **Product of `withDensity` over vector-valued coordinates (`Fin J → (Fin n → ℝ)`):** `Coord.lean:463` proves `lintegral_fin_prod` only for `Fin m → ℝ` (scalar factors) and `Qlam_eq_withDensity` for `laplacePDF`. J1 needs the general finite-product version on `Fin J → E` (`E = Fin n → ℝ`, with `volume = Measure.pi fun _ => volume`):
   - `Measure.pi (fun j : Fin J => c j • μ j) = (∏ j, c j) • Measure.pi μ` (or `c j ≠ ∞` / `SigmaFinite` version);
   - `Measure.pi (fun j : Fin J => volume.withDensity (w j)) = volume.withDensity (fun Θ => ∏ j, w j (Θ j))` (proved cleanly via `Measure.pi_eq` + induction on `J` using `measurePreserving_piFinSuccAbove` + `lintegral_prod_mul`, ~30–40 lines).
2. **Joint measurability of `(y, Θ) ↦ jointWeight τ σ lam k n y Θ`:** `BQTF.Scale.Posterior.measurable_postWeight` (`Scale/Posterior.lean:77`) is currently `private`. Either promote it to public (with Sol-W2/head approval) or prove `measurable_jointWeight_uncurry` directly in ~10 lines in `Joint/Product.lean` via `Finset.measurable_prod` (no cross-owner edit required).
3. **`ENNReal` cancellation for `(∏ j, Z_j)⁻¹`:** With `0 < Z_j < ∞` from `lintegral_postWeight_pos_lt_top`, `0 < ∏ j, Z_j < ∞`, so `((∏ Z_j)⁻¹ * num) / ((∏ Z_j)⁻¹ * den)` cancels cleanly via `ENNReal.mul_inv` + `ENNReal.inv_mul_cancel` (note: this holds even before knowing `0 < den`, since `0⁻¹ * 0 = 0` and `(c * a)⁻¹ * (c * b) = a⁻¹ * b` for `c ∈ (0, ∞)`!).

---

## J2: `BQTF/Joint/Conditioning.lean` (Lemma `pf:lem:cond`)

### Planned declarations
- `volume_orderSet_pos (J n : ℕ) : 0 < volume (orderSet J n)` — via the explicit open product box `B_ord := Set.univ.pi fun j : Fin J => Set.univ.pi fun _ : Fin n => Set.Ioo (j.val : ℝ) ((j.val : ℝ) + 1) ⊆ orderSet J n`, whose Lebesgue measure is `∏ j, ∏ i, 1 = 1 > 0` by `Measure.pi_pi` + `Real.volume_Ioo` (no need for general open-set volume machinery, and works uniformly for `J = 0` too).
- `prodPosterior_orderSet_pos` — under `1 ≤ n`, `∀ j, 0 < τ j ∧ τ j < 1`, `∀ j, 0 < σ j`, `∀ j, 0 ≤ lam j`:
  `0 < prodPosterior τ σ lam k n y (orderSet J n)`.
- `jointPosterior_isProbability` — under the same hypotheses, `IsProbabilityMeasure (jointPosterior τ σ lam k n y)`.
- `jointPosterior_eval_le` (Lemma `pf:lem:cond` inequality) — for every `j : Fin J` and `A : Set (Fin n → ℝ)` (`MeasurableSet A`):
  `jointPosterior τ σ lam k n y {Θ | Θ j ∈ A} ≤ (prodPosterior τ σ lam k n y (orderSet J n))⁻¹ * posterior (τ j) (σ j) (lam j) k n y A`.

### Theorem-1 and J1 lemmas reused
| Declaration | Source | Use in J2 |
|---|---|---|
| `prodPosterior`, `measurableSet_orderSet`, `prodPosterior_isProbability`, `prodPosterior_eq_withDensity`, `jointPosterior_eq_cond` | J1 (`Joint/Product.lean`) | density form, conditioning identity, finiteness (`≤ 1`) |
| `lintegral_postWeight_pos_lt_top`, `posterior_isProbability` | `BQTF/Coord.lean` | `0 < ∏ Z_j < ∞` and `IsProbabilityMeasure` for `measurePreserving_eval` |
| `Real.exp_pos`, `ENNReal.ofReal_pos` | Mathlib | `0 < postWeight τ σ lam k n y θ` everywhere, hence `0 < jointWeight τ σ lam k n y Θ` everywhere |
| `MeasureTheory.measurePreserving_eval` | Mathlib | `prodPosterior τ σ lam k n y {Θ | Θ j ∈ A} = posterior (τ j) (σ j) (lam j) k n y A` |
| `MeasureTheory.lintegral_pos_iff_support` / `setLIntegral_pos_iff` | Mathlib | `0 < ∫⁻ Θ in orderSet J n, jointWeight ...` from `0 < volume (orderSet J n)` and everywhere-positivity of `jointWeight` |

### Missing helper statements / small gaps to build in J2
1. **Pointwise positivity of `postWeight` / `jointWeight`:** Two 3-line lemmas (`postWeight_pos` and `jointWeight_pos`) showing `0 < postWeight τ σ lam k n y θ` and `0 < jointWeight τ σ lam k n y Θ` for all `y, θ, Θ` (immediate from `Real.exp_pos` + `Finset.prod_pos`).
2. **Positivity of `∫⁻ Θ in orderSet J n, jointWeight ...`:** Combine `volume_orderSet_pos` (via `B_ord ⊆ orderSet J n`, `volume B_ord = 1`) with `jointWeight_pos` and `setLIntegral_pos_iff` (or `lintegral_pos_iff_support` on `volume.restrict (orderSet J n)`). Note that `jointWeight_pos` makes `{Θ | jointWeight ... Θ ≠ 0} = Set.univ`, so `volume (orderSet J n ∩ Set.univ) ≥ volume B_ord = 1 > 0`.
3. **One-line conditioning bound:** From `jointPosterior_eq_cond`,
   `jointPosterior ... {Θ | Θ j ∈ A} = (Π^⊗ 𝒞)⁻¹ * Π^⊗ ({Θ | Θ j ∈ A} ∩ 𝒞) ≤ (Π^⊗ 𝒞)⁻¹ * Π^⊗ {Θ | Θ j ∈ A} = (Π^⊗ 𝒞)⁻¹ * Π_j A`,
   using `measure_mono Set.inter_subset_left` and `(measurePreserving_eval _ j).measure_preimage hs.nullMeasurableSet`.

### Estimated size & risk
- **J1 (`Joint/Product.lean`):** ~160–240 lines; low risk (all primitives already proved in `Coord.lean` and `LaplaceMixture.lean`).
- **J2 (`Joint/Conditioning.lean`):** ~90–140 lines; very low risk (completely elementary once J1 is in place).
- **No upstream changes required** to any frozen Theorem-1 statement.
