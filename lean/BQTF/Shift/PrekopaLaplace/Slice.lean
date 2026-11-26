import BQTF.Basic

/-!
# Geometry of the slice sets `{x | ‖A x + b‖₂ ≤ s}`

Triangle inequality and homogeneity of `l2norm`, closedness of the slice sets, and the
convex-combination step used by `prekopa_laplace`.
-/

open MeasureTheory Set

noncomputable section

namespace BQTF.PL

lemma l2norm_eq_norm_toE {n : ℕ} (v : Fin n → ℝ) : l2norm v = ‖toE n v‖ := by
  rw [EuclideanSpace.norm_eq, l2norm, l2sq]
  change Real.sqrt (∑ i, v i ^ 2) = Real.sqrt (∑ i, ‖v i‖ ^ 2)
  simp only [Real.norm_eq_abs, sq_abs]

lemma l2norm_add_le {n : ℕ} (u v : Fin n → ℝ) : l2norm (u + v) ≤ l2norm u + l2norm v := by
  rw [l2norm_eq_norm_toE, l2norm_eq_norm_toE, l2norm_eq_norm_toE, map_add]
  exact norm_add_le _ _

lemma l2norm_smul {n : ℕ} (c : ℝ) (u : Fin n → ℝ) : l2norm (c • u) = |c| * l2norm u := by
  rw [l2norm_eq_norm_toE, l2norm_eq_norm_toE, map_smul, norm_smul, Real.norm_eq_abs]

lemma continuous_l2norm_affine {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ)) (b : Fin p → ℝ) :
    Continuous fun x => l2norm (A x + b) := by
  have hA : Continuous A := A.continuous_of_finiteDimensional
  unfold l2norm l2sq
  exact Real.continuous_sqrt.comp
    (continuous_finsetSum _ fun i _ => ((continuous_apply i).comp (hA.add continuous_const)).pow 2)

lemma measurableSet_slice {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ)) (b : Fin p → ℝ)
    (s : ℝ) : MeasurableSet {x : Fin d → ℝ | l2norm (A x + b) ≤ s} :=
  measurableSet_le (continuous_l2norm_affine A b).measurable measurable_const

/-- The feasible set of triples `(x, b, s)` with `‖A x + b‖₂ ≤ s` is convex: the `(1 − t, t)`
combination of two feasible triples is feasible. -/
lemma slice_convex {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ)) {t : ℝ} (ht0 : 0 ≤ t)
    (ht1 : t ≤ 1) {b₀ b₁ : Fin p → ℝ} {s₀ s₁ : ℝ} {x y : Fin d → ℝ}
    (hx : l2norm (A x + b₀) ≤ s₀) (hy : l2norm (A y + b₁) ≤ s₁) :
    l2norm (A ((1 - t) • x + t • y) + ((1 - t) • b₀ + t • b₁)) ≤ (1 - t) * s₀ + t * s₁ := by
  have h1t : 0 ≤ 1 - t := by linarith
  have e : A ((1 - t) • x + t • y) + ((1 - t) • b₀ + t • b₁) =
      (1 - t) • (A x + b₀) + t • (A y + b₁) := by
    rw [map_add, map_smul, map_smul, smul_add, smul_add]
    abel
  rw [e]
  calc _ ≤ l2norm ((1 - t) • (A x + b₀)) + l2norm (t • (A y + b₁)) := l2norm_add_le _ _
    _ = (1 - t) * l2norm (A x + b₀) + t * l2norm (A y + b₁) := by
        rw [l2norm_smul, l2norm_smul, abs_of_nonneg h1t, abs_of_nonneg ht0]
    _ ≤ (1 - t) * s₀ + t * s₁ := by gcongr

end BQTF.PL
