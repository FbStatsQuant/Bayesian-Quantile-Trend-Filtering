import BQTF.Spec

open MeasureTheory
open scoped ENNReal

namespace BQTF

private theorem checkLoss_mul (τ : ℝ) {a : ℝ} (ha : 0 < a) (u : ℝ) :
    checkLoss τ (a * u) = a * checkLoss τ u := by
  have hsign : a * u < 0 ↔ u < 0 := by
    simpa only [mul_zero] using (mul_lt_mul_iff_right₀ ha : a * u < a * 0 ↔ u < 0)
  simp only [checkLoss, hsign, mul_assoc]

theorem l1norm_diffOp_smul {a : ℝ} (ha : 0 ≤ a) (r n : ℕ) (θ : Fin n → ℝ) :
    l1norm (diffOp r n (a • θ)) = a * l1norm (diffOp r n θ) := by
  have h i : diffOp r n (a • θ) i = a * diffOp r n θ i := by
    simp only [diffOp, Finset.mul_sum, Pi.smul_apply, smul_eq_mul]
    exact Finset.sum_congr rfl fun _ _ => by ring
  simp only [l1norm, h, abs_mul, abs_of_nonneg ha, Finset.mul_sum]

private theorem postWeight_scale (τ lam : ℝ) {σ : ℝ} (hσ : 0 < σ)
    (k n : ℕ) (y θ : Fin n → ℝ) :
    postWeight τ σ lam k n y θ =
      postWeight τ 1 (σ * lam) k n (σ⁻¹ • y) (σ⁻¹ • θ) := by
  have scale_back (v : Fin n → ℝ) : σ • (σ⁻¹ • v) = v :=
    smul_inv_smul₀ hσ.ne' v
  have hl (i : Fin n) :
      checkLoss τ (y i - θ i) =
        σ * checkLoss τ ((σ⁻¹ • y) i - (σ⁻¹ • θ) i) := by
    rw [← checkLoss_mul τ hσ]
    congr 1
    calc
      y i - θ i = (σ • (σ⁻¹ • y)) i - (σ • (σ⁻¹ • θ)) i := by
        rw [scale_back, scale_back]
      _ = _ := by simp only [Pi.smul_apply, smul_eq_mul, mul_sub]
  have hd : l1norm (diffOp (k + 1) n θ) =
      σ * l1norm (diffOp (k + 1) n (σ⁻¹ • θ)) := by
    conv_lhs => rw [← scale_back θ]
    exact l1norm_diffOp_smul hσ.le _ _ _
  unfold postWeight
  rw [hd]
  simp_rw [hl, ← Finset.mul_sum, div_one]
  congr 2
  field_simp

/-- Dividing the parameter and the data by the working scale gives the unit-scale posterior. -/
theorem posterior_map_inv_smul (τ lam : ℝ) {σ : ℝ} (hσ : 0 < σ)
    (k n : ℕ) (y : Fin n → ℝ) :
    (posterior τ σ lam k n y).map (σ⁻¹ • ·) =
      posterior τ 1 (σ * lam) k n (σ⁻¹ • y) := by
  let e : (Fin n → ℝ) ≃ᵐ (Fin n → ℝ) :=
    (Homeomorph.smul (isUnit_iff_ne_zero.mpr (inv_ne_zero hσ.ne')).unit).toMeasurableEquiv
  let v : Measure (Fin n → ℝ) := volume
  let J : ℝ≥0∞ := ENNReal.ofReal |((σ⁻¹) ^ Module.finrank ℝ (Fin n → ℝ))⁻¹|
  let w := postWeight τ 1 (σ * lam) k n (σ⁻¹ • y)
  have hv : v.map e = J • v := Measure.map_addHaar_smul v (inv_ne_zero hσ.ne')
  have hJ₀ : J ≠ 0 := by
    apply (ENNReal.ofReal_pos.mpr _).ne'
    exact abs_pos.mpr (inv_ne_zero (pow_ne_zero _ (inv_ne_zero hσ.ne')))
  have hJtop : J ≠ ∞ := ENNReal.ofReal_ne_top
  have hw : postWeight τ σ lam k n y = fun x => w (e x) :=
    funext (postWeight_scale τ lam hσ k n y)
  have hmap : (v.withDensity (fun x => w (e x))).map e = J • v.withDensity w := by
    ext s hs
    rw [Measure.map_apply e.measurable hs, withDensity_apply _ (e.measurable hs),
      ← lintegral_map_equiv w e, ← e.restrict_map, hv, setLIntegral_smul_measure,
      Measure.smul_apply, withDensity_apply _ hs]
  change (posterior τ σ lam k n y).map e = _
  unfold posterior
  rw [hw, Measure.map_smul _ e.measurable.aemeasurable, hmap,
    ← lintegral_map_equiv w e, hv, lintegral_smul_measure, smul_smul, smul_eq_mul,
    ENNReal.mul_inv (Or.inl hJ₀) (Or.inl hJtop)]
  rw [mul_comm J⁻¹, mul_assoc, ENNReal.inv_mul_cancel hJ₀ hJtop, mul_one]

private theorem measurable_postWeight (τ σ lam : ℝ) (k n : ℕ) :
    Measurable (fun p : (Fin n → ℝ) × (Fin n → ℝ) =>
      postWeight τ σ lam k n p.1 p.2) := by
  have hcheck : Measurable (checkLoss τ) := by
    unfold checkLoss
    exact measurable_id.mul
      (measurable_const.sub (Measurable.ite
        (measurableSet_lt measurable_id measurable_const) measurable_const measurable_const))
  unfold postWeight l1norm diffOp
  fun_prop

/-- The posterior of each fixed measurable set is a measurable function of the data. -/
theorem measurable_posterior_apply (τ σ lam : ℝ) (k n : ℕ)
    {s : Set (Fin n → ℝ)} (hs : MeasurableSet s) :
    Measurable (fun y => posterior τ σ lam k n y s) := by
  have hw := measurable_postWeight τ σ lam k n
  have hden : Measurable (fun y => ∫⁻ θ, postWeight τ σ lam k n y θ) :=
    Measurable.lintegral_prod_right (ν := volume) hw
  have hnum : Measurable (fun y => ∫⁻ θ in s, postWeight τ σ lam k n y θ) :=
    Measurable.lintegral_prod_right (ν := volume.restrict s) hw
  simpa only [posterior, Measure.smul_apply, withDensity_apply _ hs, smul_eq_mul]
    using hden.fun_inv.fun_mul hnum

end BQTF
