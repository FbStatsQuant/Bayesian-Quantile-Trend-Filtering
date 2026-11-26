import BQTF.Shift.LaplaceMeasure

open MeasureTheory Set
open scoped ENNReal Interval

noncomputable section

namespace BQTF

/-- The loss from translating a Laplace coordinate and averaging over the two signs. -/
def shiftExcess (h x : ℝ) : ℝ := max (|h| - |x|) 0

theorem continuous_shiftExcess (h : ℝ) : Continuous (shiftExcess h) := by
  unfold shiftExcess
  fun_prop

theorem shiftExcess_nonneg (h x : ℝ) : 0 ≤ shiftExcess h x := le_max_right _ _

theorem shiftExcess_le_abs (h x : ℝ) : shiftExcess h x ≤ |h| :=
  max_le (sub_le_self _ (abs_nonneg _)) (abs_nonneg _)

theorem abs_add_abs_sub_eq_excess (x h : ℝ) :
    |x + h| + |x - h| = 2 * (|x| + shiftExcess h x) := by
  simp only [shiftExcess, abs_eq_max_neg, max_def]
  split_ifs <;> linarith

private theorem integral_even_Icc {f : ℝ → ℝ} (hf : Continuous f)
    (he : ∀ x, f (-x) = f x) {R : ℝ} (hR : 0 ≤ R) :
    ∫ x in Icc (-R) R, f x = 2 * ∫ x in 0..R, f x := by
  rw [integral_Icc_eq_integral_Ioc, ← intervalIntegral.integral_of_le (by linarith : -R ≤ R),
    ← intervalIntegral.integral_add_adjacent_intervals (hf.intervalIntegrable (-R) 0)
      (hf.intervalIntegrable 0 R)]
  have h := intervalIntegral.integral_comp_neg (f := f) (a := 0) (b := R)
  simp only [he, neg_zero] at h
  rw [← h, two_mul]

/-- Area under the tent `(|h| - |x|)₊`. -/
theorem lintegral_shiftExcess (h : ℝ) :
    ∫⁻ x : ℝ, ENNReal.ofReal (shiftExcess h x) = ENNReal.ofReal (h ^ 2) := by
  let a := |h|
  let f : ℝ → ℝ := shiftExcess h
  have ha : 0 ≤ a := abs_nonneg _
  have hfc := continuous_shiftExcess h
  have hfe (x : ℝ) : f (-x) = f x := by simp [f, shiftExcess]
  have hfn (x : ℝ) : 0 ≤ f x := shiftExcess_nonneg _ _
  have hs : MeasurableSet (Icc (-a) a) := measurableSet_Icc
  have hins : IntegrableOn f (Icc (-a) a) := hfc.integrableOn_Icc
  have hsupport (x : ℝ) : (Icc (-a) a).indicator (fun x => ENNReal.ofReal (f x)) x =
      ENNReal.ofReal (f x) := by
    by_cases hx : x ∈ Icc (-a) a
    · exact indicator_of_mem hx _
    · have hx' : a ≤ |x| := le_of_lt (lt_of_not_ge fun h => hx (abs_le.mp h))
      rw [indicator_of_notMem hx]
      change 0 = ENNReal.ofReal (max (a - |x|) 0)
      rw [max_eq_right (sub_nonpos.mpr hx'), ENNReal.ofReal_zero]
  calc
    _ = ∫⁻ x, (Icc (-a) a).indicator (fun x => ENNReal.ofReal (f x)) x :=
      lintegral_congr fun x => (hsupport x).symm
    _ = ∫⁻ x in Icc (-a) a, ENNReal.ofReal (f x) := lintegral_indicator hs _
    _ = ENNReal.ofReal (∫ x in Icc (-a) a, f x) :=
      (ofReal_integral_eq_lintegral_ofReal hins (Filter.Eventually.of_forall hfn)).symm
    _ = _ := by
      rw [integral_even_Icc hfc hfe ha]
      have he : ∫ x in 0..a, f x = ∫ x in 0..a, a - x := by
        apply intervalIntegral.integral_congr
        intro x hx
        rw [uIcc_of_le ha] at hx
        have hxa : x ≤ a := hx.2
        change max (a - |x|) 0 = _
        rw [abs_of_nonneg hx.1, max_eq_left (sub_nonneg.mpr hxa)]
      have hsub := intervalIntegral.integral_sub
        ((continuous_const : Continuous (fun _ : ℝ => a)).intervalIntegrable (μ := volume) 0 a)
        ((continuous_id : Continuous (fun x : ℝ => x)).intervalIntegrable (μ := volume) 0 a)
      simp only [id_eq] at hsub
      rw [he, hsub, intervalIntegral.integral_const, integral_id]
      congr 1
      simp only [sub_zero, smul_eq_mul, zero_pow (by decide : (2 : ℕ) ≠ 0)]
      dsimp [a]
      nlinarith [sq_abs h]

/-- Integral of the density lower bound on the one-Laplace-scale band. -/
theorem lintegral_laplace_band {lam K : ℝ} (hlam : 0 < lam) (hK : 0 ≤ K) :
    ∫⁻ t in Icc (-lam⁻¹) lam⁻¹,
      ENNReal.ofReal (lam / 2 * Real.exp (-((2 + K) * lam * |t|))) =
        ENNReal.ofReal ((1 - Real.exp (-(2 + K))) / (2 + K)) := by
  let R := lam⁻¹
  let β := (2 + K) * lam
  let f (t : ℝ) := lam / 2 * Real.exp (-(β * |t|))
  have hR : 0 ≤ R := inv_nonneg.mpr hlam.le
  have hβ : 0 < β := by dsimp [β]; positivity
  have hf : Continuous f := by dsimp [f]; fun_prop
  have he (t : ℝ) : f (-t) = f t := by simp [f]
  have hn (t : ℝ) : 0 ≤ f t := by dsimp [f]; positivity
  rw [← ofReal_integral_eq_lintegral_ofReal hf.integrableOn_Icc (Filter.Eventually.of_forall hn),
    integral_even_Icc hf he hR]
  have hpos : ∫ t in 0..R, f t = lam / 2 * ∫ t in 0..R, Real.exp (-β * t) := by
    rw [← intervalIntegral.integral_const_mul]
    apply intervalIntegral.integral_congr
    intro t ht
    rw [uIcc_of_le hR] at ht
    simp [f, abs_of_nonneg ht.1, neg_mul]
  rw [hpos]
  have hint := intervalIntegral.mul_integral_comp_mul_left (f := Real.exp) (-β)
    (a := (0 : ℝ)) (b := R)
  simp only [mul_zero, integral_exp, Real.exp_zero] at hint
  have hprod : -β * R = -(2 + K) := by
    dsimp [β, R]
    field_simp
  rw [hprod] at hint
  congr 1
  have hsum : 0 < 2 + K := by positivity
  apply (eq_div_iff hsum.ne').mpr
  dsimp [β] at hint
  linarith

end BQTF
