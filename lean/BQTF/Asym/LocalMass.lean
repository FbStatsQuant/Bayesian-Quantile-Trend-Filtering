import BQTF.Coord
import BQTF.Asym.Laplace
import BQTF.Asym.Vector
import BQTF.Shift.SliceBounds

/-! Radial integrals and the exponential moment of the Laplace total variation. -/

open MeasureTheory
open scoped ENNReal

namespace BQTF

theorem continuous_coordMap (r n : ℕ) : Continuous (coordMap r n) := by
  apply continuous_pi
  intro i
  change Continuous (fun p : (Fin r → ℝ) × (Fin (n-r) → ℝ) => Nmul r n p.1 i + Smul r n p.2 i)
  unfold Nmul Smul
  fun_prop

theorem continuous_NT (r n : ℕ) : Continuous (NT r n) := by
  apply continuous_pi
  intro i
  unfold NT dot
  fun_prop

private theorem radial_exp_integral (r : ℕ) (hr : 0 < r) (κ : ℝ) (hκ : 0 < κ) :
    (∫⁻ v : EuclideanSpace ℝ (Fin r), ENNReal.ofReal (Real.exp (-(κ * ‖v‖)))) =
      Vr r * ENNReal.ofReal ((r.factorial : ℝ) * (κ⁻¹) ^ r) := by
  let E := EuclideanSpace ℝ (Fin r)
  have : Nonempty (Fin r) := ⟨⟨0, hr⟩⟩
  have hd : Module.finrank ℝ E = r := by simp [E]
  have hi : Integrable (fun v : E => Real.exp (-(κ * ‖v‖))) := by
    apply (integrable_fun_norm_addHaar (volume : Measure E)
      (f := fun x : ℝ => Real.exp (-(κ * x)))).mpr
    rw [hd]
    simp_rw [smul_eq_mul, ← Real.rpow_natCast]
    simpa only [Real.rpow_one, neg_mul] using
      (integrableOn_rpow_mul_exp_neg_mul_rpow (p := 1)
        (s := (r - 1 : ℕ)) (by linarith [show (0 : ℝ) ≤ (r - 1 : ℕ) by positivity])
        one_pos hκ)
  rw [← ofReal_integral_eq_lintegral_ofReal hi (Filter.Eventually.of_forall fun _ => Real.exp_nonneg _)]
  rw [integral_fun_norm_addHaar (volume : Measure E) (fun x => Real.exp (-(κ * x))), hd]
  simp only [nsmul_eq_mul, smul_eq_mul]
  have hin : (∫ y : ℝ in Set.Ioi 0, y ^ (r - 1) * Real.exp (-(κ * y))) =
      (κ⁻¹) ^ r * ((r - 1).factorial : ℝ) := by
    have hr' : (0 : ℝ) < r := by exact_mod_cast hr
    have h := Real.integral_rpow_mul_exp_neg_mul_Ioi (a := (r : ℝ)) hr' hκ
    have hsub : ((r - 1 : ℕ) : ℝ) = (r : ℝ) - 1 := by
      rw [Nat.cast_sub (by omega : 1 ≤ r), Nat.cast_one]
    have hΓ : Real.Gamma (r : ℝ) = ((r - 1).factorial : ℝ) := by
      rw [← Real.Gamma_nat_eq_factorial, hsub]
      ring_nf
    rw [← hsub, hΓ, Real.rpow_natCast, one_div] at h
    simpa only [Real.rpow_natCast] using h
  rw [hin]
  have hfac : (r : ℝ) * ((r - 1).factorial : ℝ) = (r.factorial : ℝ) := by
    exact_mod_cast (by
      conv_rhs => rw [show r = (r - 1) + 1 by omega, Nat.factorial_succ]
      congr 1
      omega : r * (r - 1).factorial = r.factorial)
  have hVol : ENNReal.ofReal ((volume : Measure E).real (Metric.ball 0 1)) = Vr r :=
    ENNReal.ofReal_toReal measure_ball_ne_top
  rw [show (r : ℝ) * ((volume : Measure E).real (Metric.ball 0 1) *
      (κ⁻¹ ^ r * ((r - 1).factorial : ℝ))) = (volume : Measure E).real (Metric.ball 0 1) *
        ((r * ((r - 1).factorial : ℝ)) * κ⁻¹ ^ r) by ring,
    hfac, ENNReal.ofReal_mul (measureReal_nonneg), hVol]

/-- Integrating the polynomial-coordinate radial envelope over the coordinate prior. -/
theorem nu_lintegral_exp_NT (r n : ℕ) (hr : 0 < r) (hn : r < n)
    (lam κ : ℝ) (hlam : 0 < lam) (hκ : 0 < κ) (θs : Fin n → ℝ) :
    (∫⁻ θ, ENNReal.ofReal (Real.exp (-(κ * l2norm (NT r n (θ - θs))))) ∂nu r n lam) =
      Vr r * ENNReal.ofReal ((r.factorial : ℝ) * (κ⁻¹) ^ r) := by
  have : IsProbabilityMeasure (laplace lam) := laplace_probability hlam
  have : IsProbabilityMeasure (Qlam (n - r) lam) := by unfold Qlam; infer_instance
  let f (v : Fin r → ℝ) := ENNReal.ofReal (Real.exp (-(κ * l2norm v)))
  have hf : Measurable f :=
    (Real.measurable_exp.comp
      ((measurable_const.mul (continuous_l2norm (n := r)).measurable).neg)).ennreal_ofReal
  have hNT : Measurable (fun θ : Fin n → ℝ => NT r n (θ - θs)) :=
    (continuous_NT r n).measurable.comp (measurable_id.sub_const _)
  change (∫⁻ θ, f (NT r n (θ - θs)) ∂nu r n lam) = _
  unfold nu
  have hF : Measurable (fun θ : Fin n → ℝ => f (NT r n (θ - θs))) := hf.comp hNT
  have hFc : Measurable (fun p : (Fin r → ℝ) × (Fin (n-r) → ℝ) =>
      f (NT r n (coordMap r n p - θs))) := hF.comp (continuous_coordMap r n).measurable
  rw [lintegral_map hF (continuous_coordMap r n).measurable, lintegral_prod_symm' _ hFc]
  simp_rw [← sub_cbar_eq r n hr hn]
  have hshift (u : Fin (n - r) → ℝ) : (∫⁻ c, f (c - cbar r n θs u)) = ∫⁻ c, f c := by
    exact lintegral_sub_right_eq_self f (cbar r n θs u)
  simp_rw [hshift, lintegral_const]
  have hQ : Qlam (n - r) lam Set.univ = 1 := by unfold Qlam; exact measure_univ
  rw [hQ, mul_one]
  have he : (∫⁻ c, f c) =
      ∫⁻ v : EuclideanSpace ℝ (Fin r), ENNReal.ofReal (Real.exp (-(κ * ‖v‖))) := by
    have hp := (PiLp.volume_preserving_toLp (Fin r)).lintegral_comp
      (f := fun v : EuclideanSpace ℝ (Fin r) => ENNReal.ofReal (Real.exp (-(κ * ‖v‖))))
      (by fun_prop)
    simpa only [show ∀ v : Fin r → ℝ, ‖WithLp.toLp 2 v‖ = l2norm v from norm_toE_eq_l2norm,
      f] using hp
  rw [he, radial_exp_integral r hr κ hκ]

private theorem laplace_lintegral_exp_abs {lam s : ℝ} (hlam : 0 < lam) (hs : s < lam) :
    (∫⁻ x, ENNReal.ofReal (Real.exp (s * |x|)) ∂laplace lam) =
      ENNReal.ofReal (lam / (lam - s)) := by
  have h₁ : 0 < lam - s := sub_pos.2 hs
  have h₂ : s - lam < 0 := sub_neg.2 hs
  have hw : Measurable (fun x => ENNReal.ofReal (laplacePDF lam x)) := by
    unfold laplacePDF
    fun_prop
  unfold laplace
  rw [lintegral_withDensity_eq_lintegral_mul _ hw (by fun_prop)]
  let f (x : ℝ) := ENNReal.ofReal (Real.exp ((s-lam) * |x|))
  have hf : Measurable f := by dsimp [f]; fun_prop
  have hfac (x : ℝ) :
      ENNReal.ofReal (laplacePDF lam x) * ENNReal.ofReal (Real.exp (s * |x|)) =
        ENNReal.ofReal (lam / 2) * f x := by
    have h : 0 ≤ laplacePDF lam x := by unfold laplacePDF; positivity
    rw [← ENNReal.ofReal_mul h]
    dsimp [f]
    rw [← ENNReal.ofReal_mul (by positivity), laplacePDF, mul_assoc, ← Real.exp_add]
    congr 3
    ring
  have hi₁ : (∫⁻ x in Set.Iic (0 : ℝ), f x) = ENNReal.ofReal (lam - s)⁻¹ := by
    calc
      _ = ∫⁻ x in Set.Iic (0 : ℝ), ENNReal.ofReal (Real.exp ((lam - s) * x)) := by
        apply setLIntegral_congr_fun measurableSet_Iic
        intro x hx
        dsimp [f]
        rw [abs_of_nonpos (Set.mem_Iic.mp hx)]
        congr 2
        ring
      _ = _ := by
        rw [← ofReal_integral_eq_lintegral_ofReal (integrableOn_exp_mul_Iic h₁ 0)
          (Filter.Eventually.of_forall fun _ => Real.exp_nonneg _), integral_exp_mul_Iic h₁]
        simp
  have hi₂ : (∫⁻ x in Set.Ioi (0 : ℝ), f x) = ENNReal.ofReal (lam - s)⁻¹ := by
    calc
      _ = ∫⁻ x in Set.Ioi (0 : ℝ), ENNReal.ofReal (Real.exp ((s - lam) * x)) := by
        apply setLIntegral_congr_fun measurableSet_Ioi
        intro x hx
        dsimp [f]
        rw [abs_of_nonneg (Set.mem_Ioi.mp hx).le]
      _ = _ := by
        rw [← ofReal_integral_eq_lintegral_ofReal (integrableOn_exp_mul_Ioi h₂ 0)
          (Filter.Eventually.of_forall fun _ => Real.exp_nonneg _), integral_exp_mul_Ioi h₂]
        simp only [mul_zero, Real.exp_zero]
        rw [← div_neg_eq_neg_div', neg_sub, one_div]
  change (∫⁻ x, ENNReal.ofReal (laplacePDF lam x) * ENNReal.ofReal (Real.exp (s * |x|))) = _
  simp_rw [hfac]
  rw [lintegral_const_mul _ hf, ← lintegral_add_compl f (measurableSet_Iic (a := (0 : ℝ))),
    Set.compl_Iic, hi₁, hi₂, ← ENNReal.ofReal_add (by positivity) (by positivity),
    ← ENNReal.ofReal_mul (by positivity)]
  congr 1
  ring

/-- Exponential moment of `λ ‖u‖₁` under the independent Laplace law. -/
theorem Qlam_lintegral_exp_l1 (m : ℕ) {lam b : ℝ} (hlam : 0 < lam) (hb : b < 1) :
    (∫⁻ u, ENNReal.ofReal (Real.exp (b * (lam * l1norm u))) ∂Qlam m lam) =
      ENNReal.ofReal ((1 - b)⁻¹ ^ m) := by
  have : IsProbabilityMeasure (laplace lam) := laplace_probability hlam
  have hs : b * lam < lam := by nlinarith only [mul_lt_mul_of_pos_right hb hlam]
  let f (x : ℝ) := Real.exp ((b * lam) * |x|)
  have hmoment : (∫⁻ x, ENNReal.ofReal (f x) ∂laplace lam) = ENNReal.ofReal (1 - b)⁻¹ := by
    dsimp [f]
    rw [laplace_lintegral_exp_abs hlam hs]
    congr 1
    rw [show lam - b * lam = lam * (1 - b) by ring]
    field_simp
  have hi : Integrable f (laplace lam) := by
    refine ⟨(by dsimp [f]; fun_prop), ?_⟩
    change (∫⁻ x, ‖f x‖ₑ ∂laplace lam) < ∞
    have he (x : ℝ) : ‖f x‖ₑ = ENNReal.ofReal (f x) := by
      rw [← ofReal_norm, Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    simp_rw [he]
    rw [hmoment]
    exact ENNReal.ofReal_lt_top
  unfold Qlam l1norm
  simp_rw [← mul_assoc, Finset.mul_sum, Real.exp_sum]
  rw [lintegral_pi_ofReal_prod (fun _ => hi) (fun _ _ => Real.exp_nonneg _)]
  simp_rw [hmoment]
  rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin, ENNReal.ofReal_pow (by positivity)]

end BQTF
