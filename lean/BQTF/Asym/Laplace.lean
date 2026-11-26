import BQTF.Basic

/-! Laplace exponential moments for the coordinate prior. -/

open MeasureTheory
open scoped ENNReal

namespace BQTF

private theorem lintegral_exp_mul_Iic {a : ℝ} (ha : 0 < a) :
    (∫⁻ x : ℝ in Set.Iic 0, ENNReal.ofReal (Real.exp (a * x))) = ENNReal.ofReal a⁻¹ := by
  rw [← ofReal_integral_eq_lintegral_ofReal (integrableOn_exp_mul_Iic ha 0)
    (Filter.Eventually.of_forall fun _ => (Real.exp_pos _).le), integral_exp_mul_Iic ha]
  simp

private theorem lintegral_exp_mul_Ioi {a : ℝ} (ha : a < 0) :
    (∫⁻ x : ℝ in Set.Ioi 0, ENNReal.ofReal (Real.exp (a * x))) = ENNReal.ofReal ((-a)⁻¹) := by
  rw [← ofReal_integral_eq_lintegral_ofReal (integrableOn_exp_mul_Ioi ha 0)
    (Filter.Eventually.of_forall fun _ => (Real.exp_pos _).le), integral_exp_mul_Ioi ha]
  simp [div_eq_mul_inv]

/-- The Laplace moment generating function for `|s| < lam`. -/
theorem laplace_lintegral_exp {lam s : ℝ} (hlam : 0 < lam) (hs : |s| < lam) :
    (∫⁻ x, ENNReal.ofReal (Real.exp (s * x)) ∂(laplace lam)) =
      ENNReal.ofReal ((1 - (s / lam) ^ 2)⁻¹) := by
  have h₁ : 0 < s + lam := by linarith [(abs_lt.mp hs).1]
  have h₂ : s - lam < 0 := by linarith [(abs_lt.mp hs).2]
  have hw : Measurable (fun x => ENNReal.ofReal (laplacePDF lam x)) := by
    unfold laplacePDF
    fun_prop
  unfold laplace
  rw [lintegral_withDensity_eq_lintegral_mul _ hw (by fun_prop)]
  have hfactor (x : ℝ) :
      laplacePDF lam x * Real.exp (s * x) =
        lam / 2 * Real.exp (s * x - lam * |x|) := by
    rw [laplacePDF, mul_assoc, ← Real.exp_add]
    congr 2
    ring
  calc
    _ = ENNReal.ofReal (lam / 2) *
        ∫⁻ x : ℝ, ENNReal.ofReal (Real.exp (s * x - lam * |x|)) := by
      rw [← lintegral_const_mul _ (by fun_prop)]
      apply lintegral_congr
      intro x
      change ENNReal.ofReal (laplacePDF lam x) * _ = _
      have h : 0 ≤ laplacePDF lam x := by unfold laplacePDF; positivity
      rw [← ENNReal.ofReal_mul h, hfactor, ENNReal.ofReal_mul (by positivity)]
    _ = ENNReal.ofReal (lam / 2) *
        (ENNReal.ofReal ((s + lam)⁻¹) + ENNReal.ofReal ((-(s - lam))⁻¹)) := by
      rw [← lintegral_add_compl _ (measurableSet_Iic (a := (0 : ℝ))), Set.compl_Iic]
      congr 1
      congr 1
      · rw [← lintegral_exp_mul_Iic h₁]
        apply setLIntegral_congr_fun measurableSet_Iic
        intro x hx
        dsimp
        rw [abs_of_nonpos (Set.mem_Iic.mp hx)]
        congr 2
        ring
      · rw [← lintegral_exp_mul_Ioi h₂]
        apply setLIntegral_congr_fun measurableSet_Ioi
        intro x hx
        dsimp
        rw [abs_of_nonneg (Set.mem_Ioi.mp hx).le]
        congr 2
        ring
    _ = _ := by
      have h₂' : 0 < -(s - lam) := neg_pos.mpr h₂
      rw [← ENNReal.ofReal_add (by positivity) (by positivity),
        ← ENNReal.ofReal_mul (by positivity)]
      congr 1
      rw [show 1 - (s / lam) ^ 2 = (s + lam) * (-(s - lam)) / lam ^ 2 by
        field_simp; ring]
      field_simp [h₁.ne', h₂.ne, h₂'.ne']
      ring

theorem laplace_probability {lam : ℝ} (hlam : 0 < lam) :
    IsProbabilityMeasure (laplace lam) := by
  constructor
  have h := laplace_lintegral_exp (s := 0) hlam (by simpa using hlam)
  simpa using h

/-- A product of nonnegative integrable functions can be integrated coordinatewise. -/
theorem lintegral_pi_ofReal_prod {n : ℕ} {μ : Fin n → Measure ℝ} [∀ i, SigmaFinite (μ i)]
    {f : Fin n → ℝ → ℝ} (hi : ∀ i, Integrable (f i) (μ i)) (hp : ∀ i x, 0 ≤ f i x) :
    (∫⁻ x : Fin n → ℝ, ENNReal.ofReal (∏ i, f i (x i)) ∂(Measure.pi μ)) =
      ∏ i, ∫⁻ x, ENNReal.ofReal (f i x) ∂(μ i) := by
  rw [← ofReal_integral_eq_lintegral_ofReal (Integrable.fintype_prod hi)
    (Filter.Eventually.of_forall fun _ => Finset.prod_nonneg fun _ _ => hp _ _),
    integral_fintype_prod_eq_prod]
  rw [ENNReal.ofReal_prod_of_nonneg]
  · apply Finset.prod_congr rfl
    intro i _
    exact ofReal_integral_eq_lintegral_ofReal (hi i) (Filter.Eventually.of_forall (hp i))
  · exact fun i _ => integral_nonneg (hp i)

/-- The exponential moment of a linear functional under the coordinate prior. -/
theorem Qlam_lintegral_exp_dot {m : ℕ} {lam : ℝ} (hlam : 0 < lam) (s : Fin m → ℝ)
    (hs : ∀ i, |s i| < lam) :
    (∫⁻ u, ENNReal.ofReal (Real.exp (dot s u)) ∂(Qlam m lam)) =
      ∏ i, ENNReal.ofReal ((1 - (s i / lam) ^ 2)⁻¹) := by
  have : IsProbabilityMeasure (laplace lam) := laplace_probability hlam
  have hi (i : Fin m) : Integrable (fun x => Real.exp (s i * x)) (laplace lam) := by
    refine ⟨(by fun_prop), ?_⟩
    change (∫⁻ x, ‖Real.exp (s i * x)‖ₑ ∂(laplace lam)) < ∞
    simp_rw [← ofReal_norm, Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    rw [laplace_lintegral_exp hlam (hs i)]
    exact ENNReal.ofReal_lt_top
  unfold Qlam dot
  simp_rw [Real.exp_sum]
  rw [lintegral_pi_ofReal_prod hi (fun _ _ => Real.exp_nonneg _)]
  apply Finset.prod_congr rfl
  intro i _
  exact laplace_lintegral_exp hlam (hs i)

end BQTF
