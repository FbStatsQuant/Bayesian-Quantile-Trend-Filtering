import BQTF.Basic

/-! Elementary vector identities for the appendix estimates. -/

open scoped InnerProductSpace

namespace BQTF

theorem diffOp_sub (r n : ℕ) (v w : Fin n → ℝ) :
    diffOp r n (v - w) = diffOp r n v - diffOp r n w := by
  funext i
  simp [diffOp, mul_sub, Finset.sum_sub_distrib]

theorem TVr_eq_TV (k n : ℕ) (v : Fin n → ℝ) : TVr (k + 1) n v = TV k n v := by
  simp [TVr, TV]

theorem continuous_diffOp (r n : ℕ) : Continuous (diffOp r n) := by
  apply continuous_pi
  intro i
  unfold diffOp
  fun_prop

theorem continuous_l2sq (n : ℕ) : Continuous (l2sq (n := n)) := by
  unfold l2sq
  fun_prop

theorem continuous_dot (n : ℕ) :
    Continuous (fun p : (Fin n → ℝ) × (Fin n → ℝ) => dot p.1 p.2) := by
  unfold dot
  fun_prop

theorem dot_eq_real_inner {n : ℕ} (v w : Fin n → ℝ) :
    dot v w = ⟪toE n v, toE n w⟫_ℝ := by
  simp [PiLp.inner_apply, dot, toE, mul_comm]

theorem norm_toE_eq_l2norm {n : ℕ} (v : Fin n → ℝ) : ‖toE n v‖ = l2norm v := by
  rw [← Real.sqrt_sq (norm_nonneg _), EuclideanSpace.real_norm_sq_eq]
  simp [toE, l2norm, l2sq]

theorem abs_dot_le {n : ℕ} (v w : Fin n → ℝ) : |dot v w| ≤ l2norm v * l2norm w := by
  rw [dot_eq_real_inner, ← norm_toE_eq_l2norm, ← norm_toE_eq_l2norm]
  exact abs_real_inner_le_norm _ _

theorem dot_orthProj {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (v w : Fin n → ℝ) :
    dot (orthProj V v) w = dot v (orthProj V w) := by
  simp only [dot_eq_real_inner, orthProj, LinearMap.comp_apply,
    ContinuousLinearMap.coe_coe, LinearEquiv.coe_coe, LinearEquiv.apply_symm_apply]
  exact Submodule.inner_starProjection_left_eq_right _ _ _

end BQTF
