import BQTF.Basic
import BQTF.Shift.PrekopaLaplace.Slice
import BQTF.Shift.PrekopaLaplace.Tensor

/-!
# Prékopa–Leindler for Laplace slices

The mass of a Euclidean ball constraint under a product Laplace law is jointly
log-concave in its shift and radius. This is the classical input for the
quadratic shift lemma.
-/

open scoped ENNReal

noncomputable section

namespace BQTF

/-- Mass of the shifted ball constraint `‖A x + b‖₂ ≤ s`. -/
def laplaceSlice {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ))
    (lam : ℝ) (b : Fin p → ℝ) (s : ℝ) : ℝ≥0∞ :=
  Qlam d lam {x | l2norm (A x + b) ≤ s}

/-- Joint log-concavity in the shift and positive radius, in multiplicative form.
The real powers on `ℝ≥0∞` include zero-mass slices and the endpoint convention `0 ^ 0 = 1`. -/
theorem prekopa_laplace {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ))
    (lam : ℝ) (hlam : 0 < lam) (b₀ b₁ : Fin p → ℝ)
    (s₀ s₁ : ℝ) (hs₀ : 0 < s₀) (hs₁ : 0 < s₁) (t : ℝ) (ht₀ : 0 ≤ t) (ht₁ : t ≤ 1) :
    laplaceSlice A lam b₀ s₀ ^ (1 - t) * laplaceSlice A lam b₁ s₁ ^ t ≤
      laplaceSlice A lam ((1 - t) • b₀ + t • b₁) ((1 - t) * s₀ + t * s₁) := by
  rcases ht₀.eq_or_lt with rfl | ht0
  · simp
  rcases ht₁.eq_or_lt with rfl | ht1
  · simp
  have h1t : 0 < 1 - t := by linarith
  have hS := PL.measurableSet_slice A
  unfold laplaceSlice
  rw [← MeasureTheory.lintegral_indicator_one (hS b₀ s₀),
    ← MeasureTheory.lintegral_indicator_one (hS b₁ s₁),
    ← MeasureTheory.lintegral_indicator_one (hS _ _)]
  refine PL.plProp_Qlam hlam ht0 ht1 d _ _ _ (measurable_one.indicator (hS _ _))
    (measurable_one.indicator (hS _ _)) (measurable_one.indicator (hS _ _)) fun x y => ?_
  by_cases hx : x ∈ {x | l2norm (A x + b₀) ≤ s₀}
  · by_cases hy : y ∈ {x | l2norm (A x + b₁) ≤ s₁}
    · have hz : (1 - t) • x + t • y ∈
          {x | l2norm (A x + ((1 - t) • b₀ + t • b₁)) ≤ (1 - t) * s₀ + t * s₁} :=
        PL.slice_convex A ht0.le ht1.le hx hy
      simp [Set.indicator_of_mem hx, Set.indicator_of_mem hy, Set.indicator_of_mem hz]
    · rw [Set.indicator_of_notMem hy, ENNReal.zero_rpow_of_pos ht0, mul_zero]
      exact zero_le
  · rw [Set.indicator_of_notMem hx, ENNReal.zero_rpow_of_pos h1t, zero_mul]
    exact zero_le

end BQTF
