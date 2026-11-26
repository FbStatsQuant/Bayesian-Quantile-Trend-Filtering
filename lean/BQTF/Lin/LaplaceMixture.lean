import BQTF.Basic

/-!
# Andrews–Mallows Gaussian scale mixture for the Laplace law

Helper module for `BQTF.SmallBall` (Lemma `pf:lem:sb`). Proves:
* `BQTF.Lin.laplace_eq_map_exp_gaussian`: if `V ~ Exp(λ²/2)` and `g ~ N(0, 1)` are independent,
  then `√V * g ~ Laplace(λ)` (Andrews & Mallows, 1974), proved via characteristic functions.
* `BQTF.Lin.Qlam_eq_map_exp_gaussian`: the `m`-fold i.i.d. product version for `Qlam m lam`.
* `BQTF.Lin.expMeasure_sum_le_markov`: under `V_1, …, V_m ~ i.i.d. Exp(λ²/2)`, the event
  `{∀ j, 0 ≤ V_j ∧ ∑_j V_j ≤ 4 m / λ²}` has probability at least `1 / 2`.
-/

open MeasureTheory ProbabilityTheory Complex
open scoped ENNReal NNReal

noncomputable section

namespace BQTF.Lin

private lemma measurable_laplacePDF (lam : ℝ) : Measurable (laplacePDF lam) := by
  unfold laplacePDF
  fun_prop

private lemma laplacePDF_nonneg {lam : ℝ} (hlam : 0 < lam) (x : ℝ) : 0 ≤ laplacePDF lam x := by
  unfold laplacePDF
  positivity

private lemma integrable_laplacePDF {lam : ℝ} (hlam : 0 < lam) :
    Integrable (laplacePDF lam) volume := by
  have hr : IntegrableOn (fun x : ℝ => Real.exp (-lam * x)) (Set.Ioi 0) volume := by
    have hc := integrableOn_exp_mul_complex_Ioi (a := -(lam : ℂ)) (by simpa using hlam) 0
    refine (hc.re).congr_fun (fun x _ => ?_) measurableSet_Ioi
    change (Complex.exp (-(lam : ℂ) * (x : ℂ))).re = Real.exp (-lam * x)
    rw [show -(lam : ℂ) * (x : ℂ) = ((-lam * x : ℝ) : ℂ) by push_cast; ring,
      ← Complex.ofReal_exp, Complex.ofReal_re]
  rw [← integrableOn_univ, ← Set.Iic_union_Ioi (a := (0 : ℝ)), integrableOn_union]
  constructor
  · have h1 : IntegrableOn (fun x : ℝ => Real.exp (lam * x)) (Set.Iic 0) volume := by
      have hcomp := (Measure.measurePreserving_neg volume).integrableOn_comp_preimage
        (MeasurableEquiv.neg ℝ).measurableEmbedding (s := Set.Ioi 0)
        (f := fun x : ℝ => Real.exp (-lam * x))
      have hpre : (Neg.neg ⁻¹' Set.Ioi (0 : ℝ)) = Set.Iio 0 := by
        ext x; simp
      rw [hpre] at hcomp
      have hIio : IntegrableOn (fun x : ℝ => Real.exp (lam * x)) (Set.Iio 0) volume := by
        refine (hcomp.mpr hr).congr_fun (fun x _ => ?_) measurableSet_Iio
        simp
      exact hIio.congr_set_ae Iio_ae_eq_Iic.symm
    have h1' : IntegrableOn (fun x : ℝ => (lam / 2) * Real.exp (lam * x)) (Set.Iic 0) volume :=
      h1.const_mul (lam / 2)
    refine h1'.congr_fun (fun x hx => ?_) measurableSet_Iic
    unfold laplacePDF
    rw [abs_of_nonpos hx]
    ring_nf
  · have hr' : IntegrableOn (fun x : ℝ => (lam / 2) * Real.exp (-lam * x)) (Set.Ioi 0) volume :=
      hr.const_mul (lam / 2)
    refine hr'.congr_fun (fun x hx => ?_) measurableSet_Ioi
    unfold laplacePDF
    rw [abs_of_pos hx]
    ring_nf

private lemma integral_laplacePDF {lam : ℝ} (hlam : 0 < lam) :
    ∫ x : ℝ, laplacePDF lam x = 1 := by
  have hint := integrable_laplacePDF hlam
  rw [← integral_add_compl measurableSet_Iic hint]
  have hcompl : (Set.Iic (0 : ℝ))ᶜ = Set.Ioi 0 := Set.compl_Iic
  rw [hcompl]
  have h1 : ∫ x in Set.Iic (0 : ℝ), laplacePDF lam x = 1 / 2 := by
    have hcongr : ∫ x in Set.Iic (0 : ℝ), laplacePDF lam x =
        ∫ x in Set.Iic (0 : ℝ), (lam / 2) * Real.exp (lam * x) := by
      refine setIntegral_congr_fun measurableSet_Iic fun x hx => ?_
      unfold laplacePDF
      rw [abs_of_nonpos hx]
      ring_nf
    rw [hcongr, integral_const_mul, integral_exp_mul_Iic hlam 0]
    simp only [mul_zero, Real.exp_zero]
    field_simp [hlam.ne']
  have h2 : ∫ x in Set.Ioi (0 : ℝ), laplacePDF lam x = 1 / 2 := by
    have hcongr : ∫ x in Set.Ioi (0 : ℝ), laplacePDF lam x =
        ∫ x in Set.Ioi (0 : ℝ), (lam / 2) * Real.exp ((-lam) * x) := by
      refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
      unfold laplacePDF
      rw [abs_of_pos hx]
      ring_nf
    rw [hcongr, integral_const_mul, integral_exp_mul_Ioi (by linarith) 0]
    simp only [mul_zero, Real.exp_zero]
    field_simp [hlam.ne']
  linarith

lemma isProbabilityMeasure_laplace {lam : ℝ} (hlam : 0 < lam) :
    IsProbabilityMeasure (laplace lam) := by
  constructor
  rw [laplace, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ]
  rw [← ofReal_integral_eq_lintegral_ofReal (integrable_laplacePDF hlam)
    (ae_of_all _ (laplacePDF_nonneg hlam)), integral_laplacePDF hlam, ENNReal.ofReal_one]

/-- Characteristic function of `Laplace(λ)`: `φ(t) = λ² / (λ² + t²)`. -/
lemma charFun_laplace {lam : ℝ} (hlam : 0 < lam) (t : ℝ) :
    charFun (laplace lam) t = (lam : ℂ) ^ 2 / ((lam : ℂ) ^ 2 + (t : ℂ) ^ 2) := by
  rw [charFun_apply_real, laplace]
  have hmeas_w : Measurable (fun x : ℝ => ENNReal.ofReal (laplacePDF lam x)) :=
    (measurable_laplacePDF lam).ennreal_ofReal
  have hlt : ∀ᵐ x ∂volume, ENNReal.ofReal (laplacePDF lam x) < ∞ :=
    ae_of_all _ fun _ => ENNReal.ofReal_lt_top
  rw [integral_withDensity_eq_integral_toReal_smul hmeas_w hlt]
  have hsimp : (fun x : ℝ => (ENNReal.ofReal (laplacePDF lam x)).toReal •
      Complex.exp ((t : ℂ) * (x : ℂ) * I)) =
      fun x : ℝ => (laplacePDF lam x : ℂ) * Complex.exp ((t : ℂ) * (x : ℂ) * I) := by
    ext x
    rw [ENNReal.toReal_ofReal (laplacePDF_nonneg hlam x), Complex.real_smul]
  rw [hsimp]
  have hmeas_int : Measurable (fun x : ℝ => (laplacePDF lam x : ℂ) *
      Complex.exp ((t : ℂ) * (x : ℂ) * I)) :=
    (Complex.continuous_ofReal.measurable.comp (measurable_laplacePDF lam)).mul
      (Complex.continuous_exp.measurable.comp
        ((measurable_const.mul Complex.continuous_ofReal.measurable).mul measurable_const))
  have hint : Integrable (fun x : ℝ => (laplacePDF lam x : ℂ) *
      Complex.exp ((t : ℂ) * (x : ℂ) * I)) volume := by
    refine (integrable_laplacePDF hlam).mono' hmeas_int.aestronglyMeasurable (ae_of_all _ fun x => ?_)
    rw [norm_mul, Complex.norm_real, Real.norm_of_nonneg (laplacePDF_nonneg hlam x)]
    have hnorm1 : ‖Complex.exp ((t : ℂ) * (x : ℂ) * I)‖ = 1 := by
      rw [Complex.norm_exp]
      have hre : ((t : ℂ) * (x : ℂ) * I).re = 0 := by simp
      rw [hre, Real.exp_zero]
    rw [hnorm1, mul_one]
  rw [← integral_add_compl measurableSet_Iic hint]
  have hcompl : (Set.Iic (0 : ℝ))ᶜ = Set.Ioi 0 := Set.compl_Iic
  rw [hcompl]
  have hIic : ∫ x in Set.Iic (0 : ℝ), (laplacePDF lam x : ℂ) *
      Complex.exp ((t : ℂ) * (x : ℂ) * I) =
      ((lam : ℂ) / 2) / ((lam : ℂ) + (t : ℂ) * I) := by
    have hcongr : ∫ x in Set.Iic (0 : ℝ), (laplacePDF lam x : ℂ) *
        Complex.exp ((t : ℂ) * (x : ℂ) * I) =
        ∫ x in Set.Iic (0 : ℝ), ((lam : ℂ) / 2) *
          Complex.exp (((lam : ℂ) + (t : ℂ) * I) * (x : ℂ)) := by
      refine setIntegral_congr_fun measurableSet_Iic fun x hx => ?_
      unfold laplacePDF
      rw [abs_of_nonpos hx]
      push_cast
      rw [mul_assoc, ← Complex.exp_add]
      congr 2
      ring
    rw [hcongr, integral_const_mul,
      integral_exp_mul_complex_Iic (a := (lam : ℂ) + (t : ℂ) * I) (by simpa using hlam) 0]
    simp only [Complex.ofReal_zero, mul_zero, Complex.exp_zero]
    ring
  have hIoi : ∫ x in Set.Ioi (0 : ℝ), (laplacePDF lam x : ℂ) *
      Complex.exp ((t : ℂ) * (x : ℂ) * I) =
      ((lam : ℂ) / 2) / ((lam : ℂ) - (t : ℂ) * I) := by
    have hcongr : ∫ x in Set.Ioi (0 : ℝ), (laplacePDF lam x : ℂ) *
        Complex.exp ((t : ℂ) * (x : ℂ) * I) =
        ∫ x in Set.Ioi (0 : ℝ), ((lam : ℂ) / 2) *
          Complex.exp ((-(lam : ℂ) + (t : ℂ) * I) * (x : ℂ)) := by
      refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
      unfold laplacePDF
      rw [abs_of_pos hx]
      push_cast
      rw [mul_assoc, ← Complex.exp_add]
      congr 2
      ring
    rw [hcongr, integral_const_mul,
      integral_exp_mul_complex_Ioi (a := -(lam : ℂ) + (t : ℂ) * I) (by simpa using hlam) 0]
    simp only [Complex.ofReal_zero, mul_zero, Complex.exp_zero]
    have hneg : -(lam : ℂ) + (t : ℂ) * I = -((lam : ℂ) - (t : ℂ) * I) := by ring
    rw [hneg, neg_div_neg_eq]
    ring
  rw [hIic, hIoi]
  have h1 : (lam : ℂ) + (t : ℂ) * I ≠ 0 := by
    intro h
    have hre := congrArg Complex.re h
    simp at hre
    linarith
  have h2 : (lam : ℂ) - (t : ℂ) * I ≠ 0 := by
    intro h
    have hre := congrArg Complex.re h
    simp at hre
    linarith
  have h3 : (lam : ℂ) ^ 2 + (t : ℂ) ^ 2 ≠ 0 := by
    intro h
    have hre := congrArg Complex.re h
    simp [sq] at hre
    nlinarith
  field_simp [h1, h2, h3]
  ring_nf
  simp only [I_sq]
  ring

/-- Characteristic function of `√V * g` where `V ~ Exp(λ²/2)` and `g ~ N(0, 1)`. -/
lemma charFun_exp_gaussian_scale {lam : ℝ} (hlam : 0 < lam) (t : ℝ) :
    charFun (((expMeasure (lam ^ 2 / 2)).prod (gaussianReal 0 1)).map
        (fun p : ℝ × ℝ => Real.sqrt p.1 * p.2)) t =
      (lam : ℂ) ^ 2 / ((lam : ℂ) ^ 2 + (t : ℂ) ^ 2) := by
  have hr : 0 < lam ^ 2 / 2 := by positivity
  have : IsProbabilityMeasure (expMeasure (lam ^ 2 / 2)) := isProbabilityMeasure_expMeasure hr
  have : IsProbabilityMeasure ((expMeasure (lam ^ 2 / 2)).prod (gaussianReal 0 1)) :=
    inferInstance
  have hφ : Measurable (fun p : ℝ × ℝ => Real.sqrt p.1 * p.2) := by fun_prop
  rw [charFun_apply_real, integral_map hφ.aemeasurable (by fun_prop)]
  have hint_prod : Integrable
      (fun p : ℝ × ℝ => Complex.exp ((t : ℂ) * ((Real.sqrt p.1 * p.2 : ℝ) : ℂ) * I))
      ((expMeasure (lam ^ 2 / 2)).prod (gaussianReal 0 1)) := by
    refine Integrable.of_bound (by fun_prop) 1 (ae_of_all _ fun p => ?_)
    rw [Complex.norm_exp]
    have hre : ((t : ℂ) * ((Real.sqrt p.1 * p.2 : ℝ) : ℂ) * I).re = 0 := by simp
    rw [hre, Real.exp_zero]
  rw [integral_prod _ hint_prod]
  have hinner : ∀ v : ℝ,
      ∫ g : ℝ, Complex.exp ((t : ℂ) * ((Real.sqrt v * g : ℝ) : ℂ) * I) ∂(gaussianReal 0 1) =
        ((Real.exp (-(t * Real.sqrt v) ^ 2 / 2) : ℝ) : ℂ) := by
    intro v
    have heq : (fun g : ℝ => Complex.exp ((t : ℂ) * ((Real.sqrt v * g : ℝ) : ℂ) * I)) =
        fun g : ℝ => Complex.exp (((t * Real.sqrt v : ℝ) : ℂ) * (g : ℂ) * I) := by
      ext g; push_cast; ring_nf
    rw [heq, ← charFun_apply_real, charFun_gaussianReal]
    simp only [Complex.ofReal_zero, mul_zero, zero_mul, NNReal.coe_one, Complex.ofReal_one,
      one_mul, zero_sub]
    rw [Complex.ofReal_exp]
    congr 1
    push_cast
    ring
  simp_rw [hinner]
  rw [integral_complex_ofReal]
  let r : ℝ := lam ^ 2 / 2
  have hr' : 0 < r := hr
  have hreal : ∫ v : ℝ, Real.exp (-(t * Real.sqrt v) ^ 2 / 2) ∂(expMeasure r) =
      lam ^ 2 / (lam ^ 2 + t ^ 2) := by
    rw [expMeasure, gammaMeasure]
    have hmeas_pdf : Measurable (gammaPDF 1 r) := (measurable_gammaPDFReal 1 r).ennreal_ofReal
    have hlt_pdf : ∀ᵐ v ∂volume, gammaPDF 1 r v < ∞ :=
      ae_of_all _ fun _ => ENNReal.ofReal_lt_top
    rw [integral_withDensity_eq_integral_toReal_smul hmeas_pdf hlt_pdf]
    have hcongr_all : (fun v : ℝ => (gammaPDF 1 r v).toReal •
        Real.exp (-(t * Real.sqrt v) ^ 2 / 2)) =
        fun v : ℝ => (if 0 ≤ v then r * Real.exp (-(r * v)) else 0) *
          Real.exp (-(t * Real.sqrt v) ^ 2 / 2) := by
      ext v
      have hpdf : gammaPDF 1 r v = exponentialPDF r v := rfl
      rw [hpdf, exponentialPDF_eq, smul_eq_mul, ENNReal.toReal_ofReal]
      split_ifs <;> positivity
    rw [hcongr_all]
    have hIoi_int : IntegrableOn (fun v : ℝ => r * Real.exp ((-(r + t ^ 2 / 2)) * v))
        (Set.Ioi 0) volume := by
      have ha : -(r + t ^ 2 / 2) < 0 := by linarith [sq_nonneg t, hr']
      have hc := integrableOn_exp_mul_complex_Ioi (a := ((-(r + t ^ 2 / 2) : ℝ) : ℂ))
        (by rw [Complex.ofReal_re]; exact ha) 0
      have hr_int : IntegrableOn (fun v : ℝ => Real.exp ((-(r + t ^ 2 / 2)) * v))
          (Set.Ioi 0) volume := by
        refine (hc.re).congr_fun (fun v _ => ?_) measurableSet_Ioi
        change (Complex.exp (((-(r + t ^ 2 / 2) : ℝ) : ℂ) * (v : ℂ))).re =
          Real.exp ((-(r + t ^ 2 / 2)) * v)
        rw [← Complex.ofReal_mul, ← Complex.ofReal_exp, Complex.ofReal_re]
      exact hr_int.const_mul r
    have hIoi_congr : IntegrableOn
        (fun v : ℝ => (if 0 ≤ v then r * Real.exp (-(r * v)) else 0) *
          Real.exp (-(t * Real.sqrt v) ^ 2 / 2)) (Set.Ioi 0) volume := by
      refine hIoi_int.congr_fun (fun v hv => ?_) measurableSet_Ioi
      have hv0 : 0 ≤ v := le_of_lt hv
      simp only [hv0, ↓reduceIte]
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      rw [mul_pow, Real.sq_sqrt hv0]
      ring
    have hIic_congr : IntegrableOn
        (fun v : ℝ => (if 0 ≤ v then r * Real.exp (-(r * v)) else 0) *
          Real.exp (-(t * Real.sqrt v) ^ 2 / 2)) (Set.Iic 0) volume := by
      have hIio : IntegrableOn
          (fun v : ℝ => (if 0 ≤ v then r * Real.exp (-(r * v)) else 0) *
            Real.exp (-(t * Real.sqrt v) ^ 2 / 2)) (Set.Iio 0) volume := by
        refine (integrableOn_zero (s := Set.Iio (0 : ℝ))).congr_fun (fun v hv => ?_)
          measurableSet_Iio
        have hnot : ¬ 0 ≤ v := not_le.mpr hv
        simp only [hnot, ↓reduceIte, zero_mul]
      exact hIio.congr_set_ae Iio_ae_eq_Iic.symm
    have hint_all : Integrable
        (fun v : ℝ => (if 0 ≤ v then r * Real.exp (-(r * v)) else 0) *
          Real.exp (-(t * Real.sqrt v) ^ 2 / 2)) volume := by
      rw [← integrableOn_univ, ← Set.Iic_union_Ioi (a := (0 : ℝ)), integrableOn_union]
      exact ⟨hIic_congr, hIoi_congr⟩
    rw [← integral_add_compl measurableSet_Iic hint_all]
    have hcompl : (Set.Iic (0 : ℝ))ᶜ = Set.Ioi 0 := Set.compl_Iic
    rw [hcompl]
    have hzero : ∫ v in Set.Iic (0 : ℝ),
        (if 0 ≤ v then r * Real.exp (-(r * v)) else 0) *
          Real.exp (-(t * Real.sqrt v) ^ 2 / 2) = 0 := by
      rw [← setIntegral_congr_set Iio_ae_eq_Iic]
      refine setIntegral_eq_zero_of_forall_eq_zero fun v hv => ?_
      have hnot : ¬ 0 ≤ v := not_le.mpr hv
      simp only [hnot, ↓reduceIte, zero_mul]
    rw [hzero, zero_add]
    have hpos_eq : ∫ v in Set.Ioi (0 : ℝ),
        (if 0 ≤ v then r * Real.exp (-(r * v)) else 0) *
          Real.exp (-(t * Real.sqrt v) ^ 2 / 2) =
        ∫ v in Set.Ioi (0 : ℝ), r * Real.exp ((-(r + t ^ 2 / 2)) * v) := by
      refine setIntegral_congr_fun measurableSet_Ioi fun v hv => ?_
      have hv0 : 0 ≤ v := le_of_lt hv
      simp only [hv0, ↓reduceIte]
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      rw [mul_pow, Real.sq_sqrt hv0]
      ring
    rw [hpos_eq, integral_const_mul, integral_exp_mul_Ioi (by linarith [sq_nonneg t, hr']) 0]
    simp only [mul_zero, Real.exp_zero]
    dsimp only [r]
    have hden : lam ^ 2 + t ^ 2 ≠ 0 := by positivity
    have hden2 : -(lam ^ 2 / 2 + t ^ 2 / 2) ≠ 0 := by linarith [sq_nonneg t, sq_pos_of_pos hlam]
    field_simp [hden, hden2]
  rw [hreal]
  push_cast
  rfl

/-- **Andrews–Mallows (1974):** `Laplace(λ)` is the law of `√V * g` for independent
`V ~ Exp(λ²/2)` and `g ~ N(0, 1)`. -/
theorem laplace_eq_map_exp_gaussian {lam : ℝ} (hlam : 0 < lam) :
    laplace lam =
      ((expMeasure (lam ^ 2 / 2)).prod (gaussianReal 0 1)).map
        (fun p : ℝ × ℝ => Real.sqrt p.1 * p.2) := by
  have hr : 0 < lam ^ 2 / 2 := by positivity
  have : IsProbabilityMeasure (laplace lam) := isProbabilityMeasure_laplace hlam
  have : IsProbabilityMeasure (expMeasure (lam ^ 2 / 2)) := isProbabilityMeasure_expMeasure hr
  have : IsProbabilityMeasure (((expMeasure (lam ^ 2 / 2)).prod (gaussianReal 0 1)).map
      (fun p : ℝ × ℝ => Real.sqrt p.1 * p.2)) :=
    ⟨by rw [Measure.map_apply (by fun_prop) MeasurableSet.univ, Set.preimage_univ, measure_univ]⟩
  apply Measure.ext_of_charFun
  ext t
  rw [charFun_laplace hlam t, charFun_exp_gaussian_scale hlam t]

/-- Product-space Tonelli identity for `ℝ≥0∞`-valued measurable functions on `Fin m → ℝ`. -/
private lemma lintegral_fin_prod_eq_prod {m : ℕ} {μ : Fin m → Measure ℝ}
    [∀ j, SigmaFinite (μ j)] (f : Fin m → ℝ → ℝ≥0∞) (hf : ∀ j, Measurable (f j)) :
    ∫⁻ x : Fin m → ℝ, (∏ j : Fin m, f j (x j)) ∂(Measure.pi μ) =
      ∏ j : Fin m, ∫⁻ t : ℝ, f j t ∂(μ j) := by
  induction m with
  | zero =>
    simp [Measure.pi_empty_univ]
  | succ m ih =>
    have hmp := (measurePreserving_piFinSuccAbove μ 0).symm
    rw [← hmp.lintegral_comp_emb (MeasurableEquiv.measurableEmbedding _)
      (fun x : Fin (m + 1) → ℝ => ∏ j : Fin (m + 1), f j (x j))]
    have hfun : (fun p : ℝ × (Fin m → ℝ) =>
        ∏ j : Fin (m + 1), f j ((MeasurableEquiv.piFinSuccAbove (fun _ => ℝ) 0).symm p j)) =
        fun p : ℝ × (Fin m → ℝ) => f 0 p.1 * ∏ j : Fin m, f j.succ (p.2 j) := by
      ext p
      rw [Fin.prod_univ_succ]
      simp [MeasurableEquiv.piFinSuccAbove_symm_apply, Fin.insertNthEquiv]
    rw [hfun]
    have hmeas_tail : Measurable (fun y : Fin m → ℝ => ∏ j : Fin m, f j.succ (y j)) :=
      Finset.measurable_prod _ fun j _ => (hf j.succ).comp (measurable_pi_apply j)
    rw [lintegral_prod_mul (hf 0).aemeasurable hmeas_tail.aemeasurable]
    rw [ih (fun j => f j.succ) (fun j => hf j.succ), Fin.prod_univ_succ]
    simp only [Fin.succAbove_zero]

/-- `m`-dimensional Andrews–Mallows representation for `Qlam m lam`. -/
theorem Qlam_eq_map_exp_gaussian (m : ℕ) {lam : ℝ} (hlam : 0 < lam) :
    Qlam m lam =
      ((Measure.pi fun _ : Fin m => expMeasure (lam ^ 2 / 2)).prod
        (Measure.pi fun _ : Fin m => gaussianReal 0 1)).map
        (fun vg : (Fin m → ℝ) × (Fin m → ℝ) => fun j => Real.sqrt (vg.1 j) * vg.2 j) := by
  have hr : 0 < lam ^ 2 / 2 := by positivity
  have : IsProbabilityMeasure (laplace lam) := isProbabilityMeasure_laplace hlam
  have : IsProbabilityMeasure (expMeasure (lam ^ 2 / 2)) := isProbabilityMeasure_expMeasure hr
  let μV : Measure (Fin m → ℝ) := Measure.pi fun _ : Fin m => expMeasure (lam ^ 2 / 2)
  let μG : Measure (Fin m → ℝ) := Measure.pi fun _ : Fin m => gaussianReal 0 1
  let F : (Fin m → ℝ) × (Fin m → ℝ) → (Fin m → ℝ) :=
    fun vg j => Real.sqrt (vg.1 j) * vg.2 j
  have hF : Measurable F := by
    refine Measurable.of_eval fun j => ?_
    exact (Real.continuous_sqrt.measurable.comp ((measurable_pi_apply j).comp measurable_fst)).mul
      ((measurable_pi_apply j).comp measurable_snd)
  show Measure.pi (fun _ : Fin m => laplace lam) = (μV.prod μG).map F
  refine Measure.pi_eq (μ := fun _ : Fin m => laplace lam) fun s hs => ?_
  rw [Measure.map_apply hF (MeasurableSet.univ_pi hs)]
  have hpre_meas : MeasurableSet (F ⁻¹' Set.univ.pi s) := hF (MeasurableSet.univ_pi hs)
  rw [Measure.prod_apply hpre_meas]
  have hslice : ∀ V : Fin m → ℝ,
      μG (Prod.mk V ⁻¹' (F ⁻¹' Set.univ.pi s)) =
        ∏ j : Fin m, gaussianReal 0 1 {x : ℝ | Real.sqrt (V j) * x ∈ s j} := by
    intro V
    have hset : Prod.mk V ⁻¹' (F ⁻¹' Set.univ.pi s) =
        Set.univ.pi fun j : Fin m => {x : ℝ | Real.sqrt (V j) * x ∈ s j} := by
      ext g
      simp [F]
    rw [hset, Measure.pi_pi]
  simp_rw [hslice]
  have hmeas_fac : ∀ j : Fin m,
      Measurable (fun v : ℝ => gaussianReal 0 1 {x : ℝ | Real.sqrt v * x ∈ s j}) := by
    intro j
    have hA : MeasurableSet {p : ℝ × ℝ | Real.sqrt p.1 * p.2 ∈ s j} :=
      (by fun_prop : Measurable (fun p : ℝ × ℝ => Real.sqrt p.1 * p.2)) (hs j)
    exact measurable_measure_prodMk_left hA
  rw [lintegral_fin_prod_eq_prod _ hmeas_fac]
  refine Finset.prod_congr rfl fun j _ => ?_
  rw [laplace_eq_map_exp_gaussian hlam, Measure.map_apply (by fun_prop) (hs j),
    Measure.prod_apply ((by fun_prop : Measurable (fun p : ℝ × ℝ => Real.sqrt p.1 * p.2)) (hs j))]
  rfl

/-- `Exp(r)` is supported on `[0, ∞)`. -/
lemma expMeasure_Ici_zero {r : ℝ} (hr : 0 < r) : expMeasure r (Set.Ici 0) = 1 := by
  have : IsProbabilityMeasure (expMeasure r) := isProbabilityMeasure_expMeasure hr
  have hIio : expMeasure r (Set.Iio 0) = 0 := by
    rw [expMeasure, gammaMeasure, withDensity_apply _ measurableSet_Iio]
    exact lintegral_exponentialPDF_of_nonpos (le_refl 0)
  have hcompl : (Set.Iio (0 : ℝ))ᶜ = Set.Ici 0 := Set.compl_Iio
  rw [← hcompl, measure_compl measurableSet_Iio (measure_ne_top _ _), measure_univ, hIio, tsub_zero]

/-- The mean of `Exp(r)` is `1 / r` (in `ℝ≥0∞`). -/
lemma lintegral_ofReal_id_expMeasure {r : ℝ} (hr : 0 < r) :
    ∫⁻ v : ℝ, ENNReal.ofReal v ∂(expMeasure r) = ENNReal.ofReal (1 / r) := by
  rw [expMeasure, gammaMeasure]
  have hmeas_pdf : Measurable (gammaPDF 1 r) := (measurable_gammaPDFReal 1 r).ennreal_ofReal
  have hmeas_ofReal : Measurable (fun v : ℝ => ENNReal.ofReal v) := by fun_prop
  rw [lintegral_withDensity_eq_lintegral_mul _ hmeas_pdf hmeas_ofReal]
  have hprod : ∀ v : ℝ, gammaPDF 1 r v * ENNReal.ofReal v =
      ENNReal.ofReal (if 0 < v then r * (v * Real.exp (-(r * v))) else 0) := by
    intro v
    have hpdf : gammaPDF 1 r v = exponentialPDF r v := rfl
    rw [hpdf, exponentialPDF_eq, ← ENNReal.ofReal_mul (by split_ifs <;> positivity)]
    by_cases hv : 0 < v
    · have hv0 : 0 ≤ v := le_of_lt hv
      simp only [hv, hv0, ↓reduceIte]
      ring_nf
    · simp only [hv, ↓reduceIte]
      by_cases hv0 : v = 0
      · subst hv0; simp
      · have hneg : ¬ 0 ≤ v := by push Not; exact lt_of_le_of_ne (not_lt.mp hv) hv0
        simp only [hneg, ↓reduceIte, zero_mul]
  simp_rw [Pi.mul_apply, hprod]
  have hint_pos : IntegrableOn (fun v : ℝ => r * (v * Real.exp (-(r * v)))) (Set.Ioi 0) volume := by
    have hdom : IntegrableOn (fun v : ℝ => 2 * Real.exp (-(r / 2) * v)) (Set.Ioi 0) volume := by
      have hc := integrableOn_exp_mul_complex_Ioi (a := ((-(r / 2) : ℝ) : ℂ))
        (by rw [Complex.ofReal_re]; linarith) 0
      have h1 : IntegrableOn (fun v : ℝ => Real.exp (-(r / 2) * v)) (Set.Ioi 0) volume := by
        refine (hc.re).congr_fun (fun v _ => ?_) measurableSet_Ioi
        change (Complex.exp (((-(r / 2) : ℝ) : ℂ) * (v : ℂ))).re = Real.exp (-(r / 2) * v)
        rw [← Complex.ofReal_mul, ← Complex.ofReal_exp, Complex.ofReal_re]
      exact h1.const_mul 2
    refine hdom.mono' (by fun_prop) ?_
    rw [ae_restrict_iff' measurableSet_Ioi]
    refine ae_of_all _ fun v hv => ?_
    have hv0 : 0 < v := hv
    rw [Real.norm_of_nonneg (by positivity)]
    have hexp_ge : r / 2 * v ≤ Real.exp (r / 2 * v) := by
      linarith [Real.add_one_le_exp (r / 2 * v)]
    have hsplit : Real.exp (-(r * v)) = Real.exp (-(r / 2 * v)) * Real.exp (-(r / 2) * v) := by
      rw [← Real.exp_add]; congr 1; ring
    have hprod_le : r / 2 * v * Real.exp (-(r / 2 * v)) ≤ 1 := by
      rw [Real.exp_neg, mul_inv_le_iff₀ (Real.exp_pos _), one_mul]
      exact hexp_ge
    calc r * (v * Real.exp (-(r * v)))
        = 2 * (r / 2 * v * Real.exp (-(r / 2 * v))) * Real.exp (-(r / 2) * v) := by
          rw [hsplit]; ring
      _ ≤ 2 * 1 * Real.exp (-(r / 2) * v) := by
          gcongr
      _ = 2 * Real.exp (-(r / 2) * v) := by ring
  have hint_all : Integrable
      (fun v : ℝ => if 0 < v then r * (v * Real.exp (-(r * v))) else 0) volume := by
    rw [← integrableOn_univ, ← Set.Iic_union_Ioi (a := (0 : ℝ)), integrableOn_union]
    refine ⟨?_, hint_pos.congr_fun (fun v hv => by
      have hv0 : 0 < v := hv
      simp only [hv0, ↓reduceIte]) measurableSet_Ioi⟩
    refine (integrableOn_zero (s := Set.Iic (0 : ℝ))).congr_fun (fun v hv => ?_) measurableSet_Iic
    have hnot : ¬ 0 < v := not_lt.mpr hv
    simp only [hnot, ↓reduceIte]
  have hnn : ∀ v : ℝ, 0 ≤ if 0 < v then r * (v * Real.exp (-(r * v))) else 0 := fun v => by
    split_ifs with hv
    · positivity
    · exact le_rfl
  rw [← ofReal_integral_eq_lintegral_ofReal hint_all (ae_of_all _ hnn)]
  congr 1
  rw [← integral_add_compl measurableSet_Iic hint_all]
  have hcompl : (Set.Iic (0 : ℝ))ᶜ = Set.Ioi 0 := Set.compl_Iic
  rw [hcompl]
  have hzero : ∫ v in Set.Iic (0 : ℝ),
      (if 0 < v then r * (v * Real.exp (-(r * v))) else 0) = 0 :=
    setIntegral_eq_zero_of_forall_eq_zero fun v hv => by
      have hnot : ¬ 0 < v := not_lt.mpr hv
      simp only [hnot, ↓reduceIte]
  rw [hzero, zero_add]
  have hpos_eq : ∫ v in Set.Ioi (0 : ℝ),
      (if 0 < v then r * (v * Real.exp (-(r * v))) else 0) =
      r * ∫ v in Set.Ioi (0 : ℝ), v ^ ((2 : ℝ) - 1) * Real.exp (-(r * v)) := by
    rw [← integral_const_mul]
    refine setIntegral_congr_fun measurableSet_Ioi fun v hv => ?_
    have hv0 : 0 < v := hv
    simp only [hv0, ↓reduceIte]
    norm_num
  rw [hpos_eq, Real.integral_rpow_mul_exp_neg_mul_Ioi (a := 2) (r := r) (by norm_num) hr]
  have hG2 : Real.Gamma 2 = 1 := by
    have h := Real.Gamma_nat_eq_factorial 1
    rw [Nat.cast_one, Nat.factorial_one, Nat.cast_one] at h
    norm_num at h ⊢
  rw [hG2, mul_one, show (2 : ℝ) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
  field_simp [hr.ne']

/-- Markov's inequality on `V_1, …, V_m ~ i.i.d. Exp(λ²/2)`:
`P(∀ j, 0 ≤ V_j ∧ ∑_j V_j ≤ 4 m / λ²) ≥ 1 / 2`. -/
theorem expMeasure_sum_le_markov (m : ℕ) {lam : ℝ} (hlam : 0 < lam) :
    (1 / 2 : ℝ≥0∞) ≤
      (Measure.pi fun _ : Fin m => expMeasure (lam ^ 2 / 2))
        {V : Fin m → ℝ | (∀ j, 0 ≤ V j) ∧ ∑ j, V j ≤ 4 * (m : ℝ) / lam ^ 2} := by
  have hr : 0 < lam ^ 2 / 2 := by positivity
  have : IsProbabilityMeasure (expMeasure (lam ^ 2 / 2)) := isProbabilityMeasure_expMeasure hr
  let μV : Measure (Fin m → ℝ) := Measure.pi fun _ : Fin m => expMeasure (lam ^ 2 / 2)
  have : IsProbabilityMeasure μV := inferInstance
  let Snn : Set (Fin m → ℝ) := {V | ∀ j, 0 ≤ V j}
  have hSnn_eq : Snn = Set.univ.pi fun _ : Fin m => Set.Ici (0 : ℝ) := by
    ext V; simp [Snn, Pi.le_def]
  have hSnn_meas : MeasurableSet Snn := by
    rw [hSnn_eq]; exact MeasurableSet.univ_pi fun _ => measurableSet_Ici
  have hSnn_one : μV Snn = 1 := by
    rw [hSnn_eq, Measure.pi_pi]
    simp [expMeasure_Ici_zero hr]
  by_cases hm : m = 0
  · subst hm
    have heq : {V : Fin 0 → ℝ | (∀ j, 0 ≤ V j) ∧ ∑ j, V j ≤ 4 * ((0 : ℕ) : ℝ) / lam ^ 2} =
        Set.univ := by
      ext V; simp
    rw [heq, measure_univ]
    norm_num
  have hm_pos : (0 : ℝ) < m := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hm)
  let c : ℝ := 4 * (m : ℝ) / lam ^ 2
  have hc_pos : 0 < c := by positivity
  let Sbd : Set (Fin m → ℝ) := {V | ∑ j, V j ≤ c}
  have hSbd_meas : MeasurableSet Sbd :=
    measurableSet_le (Finset.measurable_sum _ fun j _ => measurable_pi_apply j) measurable_const
  have hcompl_eq : Sbdᶜ = {V : Fin m → ℝ | c < ∑ j, V j} := by
    ext V; simp [Sbd]
  have hlint : ∫⁻ V : Fin m → ℝ, ENNReal.ofReal (∑ j, V j) ∂μV ≤
      ENNReal.ofReal (2 * (m : ℝ) / lam ^ 2) := by
    have hle_sum : ∀ V : Fin m → ℝ,
        ENNReal.ofReal (∑ j, V j) ≤ ∑ j : Fin m, ENNReal.ofReal (V j) := by
      intro V
      calc ENNReal.ofReal (∑ j, V j)
          ≤ ENNReal.ofReal (∑ j, max (V j) 0) :=
            ENNReal.ofReal_le_ofReal (Finset.sum_le_sum fun j _ => le_max_left _ _)
        _ = ∑ j, ENNReal.ofReal (max (V j) 0) :=
            ENNReal.ofReal_sum_of_nonneg fun j _ => le_max_right _ _
        _ = ∑ j, ENNReal.ofReal (V j) := by
            refine Finset.sum_congr rfl fun j _ => ?_
            by_cases hj : 0 ≤ V j
            · rw [max_eq_left hj]
            · rw [max_eq_right (le_of_not_ge hj), ENNReal.ofReal_zero,
                ENNReal.ofReal_of_nonpos (le_of_not_ge hj)]
    calc ∫⁻ V : Fin m → ℝ, ENNReal.ofReal (∑ j, V j) ∂μV
        ≤ ∫⁻ V : Fin m → ℝ, (∑ j : Fin m, ENNReal.ofReal (V j)) ∂μV :=
          lintegral_mono hle_sum
      _ = ∑ j : Fin m, ∫⁻ V : Fin m → ℝ, ENNReal.ofReal (V j) ∂μV :=
          lintegral_finsetSum _ fun j _ => (measurable_pi_apply j).ennreal_ofReal
      _ = ∑ _j : Fin m, ENNReal.ofReal (1 / (lam ^ 2 / 2)) := by
          refine Finset.sum_congr rfl fun j _ => ?_
          have hmp := measurePreserving_eval (fun _ : Fin m => expMeasure (lam ^ 2 / 2)) j
          have hcomp := hmp.lintegral_comp (by fun_prop : Measurable fun v : ℝ => ENNReal.ofReal v)
          exact hcomp.trans (lintegral_ofReal_id_expMeasure hr)
      _ = (m : ℝ≥0∞) * ENNReal.ofReal (2 / lam ^ 2) := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
          congr 2
          field_simp [hlam.ne']
      _ = ENNReal.ofReal (2 * (m : ℝ) / lam ^ 2) := by
          rw [← ENNReal.ofReal_natCast m, ← ENNReal.ofReal_mul (Nat.cast_nonneg m)]
          congr 1; ring
  have hmarkov : ENNReal.ofReal c * μV Sbdᶜ ≤ ENNReal.ofReal (2 * (m : ℝ) / lam ^ 2) := by
    have hsub : Sbdᶜ ⊆ {V : Fin m → ℝ | ENNReal.ofReal c ≤ ENNReal.ofReal (∑ j, V j)} := by
      intro V hV
      rw [hcompl_eq] at hV
      exact ENNReal.ofReal_le_ofReal (le_of_lt hV)
    calc ENNReal.ofReal c * μV Sbdᶜ
        ≤ ENNReal.ofReal c * μV {V | ENNReal.ofReal c ≤ ENNReal.ofReal (∑ j, V j)} :=
          mul_le_mul_of_nonneg_left (measure_mono hsub) zero_le
      _ ≤ ∫⁻ V, ENNReal.ofReal (∑ j, V j) ∂μV :=
          mul_meas_ge_le_lintegral₀
            ((Finset.measurable_sum _ fun j _ => measurable_pi_apply j).ennreal_ofReal.aemeasurable)
            (ENNReal.ofReal c)
      _ ≤ ENNReal.ofReal (2 * (m : ℝ) / lam ^ 2) := hlint
  have hhalf_eq : (1 / 2 : ℝ≥0∞) = ENNReal.ofReal (1 / 2) := by
    rw [ENNReal.ofReal_div_of_pos (by norm_num), ENNReal.ofReal_one, ENNReal.ofReal_ofNat]
  have hcompl_le : μV Sbdᶜ ≤ 1 / 2 := by
    have hc_ne0 : ENNReal.ofReal c ≠ 0 := (ENNReal.ofReal_pos.mpr hc_pos).ne'
    have hc_netop : ENNReal.ofReal c ≠ ∞ := ENNReal.ofReal_ne_top
    have h2eq : ENNReal.ofReal (2 * (m : ℝ) / lam ^ 2) = ENNReal.ofReal c * (1 / 2) := by
      rw [hhalf_eq, ← ENNReal.ofReal_mul hc_pos.le]
      congr 1; dsimp only [c]; ring
    rw [h2eq] at hmarkov
    calc μV Sbdᶜ = (ENNReal.ofReal c)⁻¹ * (ENNReal.ofReal c * μV Sbdᶜ) := by
          rw [← mul_assoc, ENNReal.inv_mul_cancel hc_ne0 hc_netop, one_mul]
      _ ≤ (ENNReal.ofReal c)⁻¹ * (ENNReal.ofReal c * (1 / 2)) :=
          mul_le_mul_of_nonneg_left hmarkov zero_le
      _ = 1 / 2 := by
          rw [← mul_assoc, ENNReal.inv_mul_cancel hc_ne0 hc_netop, one_mul]
  have hSbd_ge : (1 / 2 : ℝ≥0∞) ≤ μV Sbd := by
    have hadd := measure_add_measure_compl (μ := μV) hSbd_meas
    rw [measure_univ] at hadd
    have hsub : (1 : ℝ≥0∞) - (1 / 2 : ℝ≥0∞) = 1 / 2 := by
      rw [hhalf_eq, ← ENNReal.ofReal_one, ← ENNReal.ofReal_sub _ (by norm_num)]
      norm_num
    rw [← hsub]
    exact tsub_le_iff_right.mpr (hadd.symm.le.trans (add_le_add le_rfl hcompl_le))
  have hinter : μV (Snn ∩ Sbd) = μV Sbd := by
    have hnull : μV Snnᶜ = 0 := by
      rw [measure_compl hSnn_meas (measure_ne_top _ _), measure_univ, hSnn_one, tsub_self]
    have hsub : Sbd \ (Snn ∩ Sbd) ⊆ Snnᶜ := fun V hV => fun h => hV.2 ⟨h, hV.1⟩
    have hdiff0 : μV (Sbd \ (Snn ∩ Sbd)) = 0 := measure_mono_null hsub hnull
    have hle1 : μV (Snn ∩ Sbd) ≤ μV Sbd := measure_mono Set.inter_subset_right
    have hle2 : μV Sbd ≤ μV (Snn ∩ Sbd) := by
      calc μV Sbd ≤ μV ((Snn ∩ Sbd) ∪ (Sbd \ (Snn ∩ Sbd))) :=
            measure_mono fun V hV => by
              by_cases h : V ∈ Snn
              · exact Or.inl ⟨h, hV⟩
              · exact Or.inr ⟨hV, fun hc => h hc.1⟩
        _ ≤ μV (Snn ∩ Sbd) + μV (Sbd \ (Snn ∩ Sbd)) := measure_union_le _ _
        _ = μV (Snn ∩ Sbd) := by rw [hdiff0, add_zero]
    exact le_antisymm hle1 hle2
  have heq : {V : Fin m → ℝ | (∀ j, 0 ≤ V j) ∧ ∑ j, V j ≤ 4 * (m : ℝ) / lam ^ 2} =
      Snn ∩ Sbd := rfl
  rw [heq, hinter]
  exact hSbd_ge

end BQTF.Lin
