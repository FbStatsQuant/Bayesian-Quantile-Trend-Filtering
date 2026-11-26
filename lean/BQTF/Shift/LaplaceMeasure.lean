import BQTF.Coord

open MeasureTheory Set
open scoped ENNReal

noncomputable section

namespace BQTF

theorem continuous_laplacePDF (lam : ℝ) : Continuous (laplacePDF lam) := by
  unfold laplacePDF
  fun_prop

theorem laplacePDF_nonneg {lam : ℝ} (hlam : 0 ≤ lam) (x : ℝ) :
    0 ≤ laplacePDF lam x := by unfold laplacePDF; positivity

/-- Product Laplace density with respect to Lebesgue measure. -/
abbrev laplaceWeight {d : ℕ} (lam : ℝ) (x : Fin d → ℝ) : ℝ :=
  (lam / 2) ^ d * Real.exp (-(lam * l1norm x))

theorem continuous_laplaceWeight {d : ℕ} (lam : ℝ) :
    Continuous (laplaceWeight (d := d) lam) := by
  unfold laplaceWeight l1norm
  fun_prop

theorem laplaceWeight_nonneg {d : ℕ} {lam : ℝ} (hlam : 0 ≤ lam) (x : Fin d → ℝ) :
    0 ≤ laplaceWeight lam x := by unfold laplaceWeight; positivity

/-- Translating a measurable event translates its argument in the density integral. -/
theorem Qlam_translate {d : ℕ} {lam : ℝ} (hlam : 0 < lam) (h : Fin d → ℝ)
    {S : Set (Fin d → ℝ)} (hS : MeasurableSet S) :
    Qlam d lam {x | x - h ∈ S} =
      ∫⁻ x in S, ENNReal.ofReal (laplaceWeight lam (x + h)) := by
  let T := (fun x : Fin d → ℝ => x - h) ⁻¹' S
  have hT : MeasurableSet T := hS.preimage (by fun_prop)
  have he : (fun x : Fin d → ℝ => x + h) ⁻¹' T = S := by ext x; simp [T]
  change Qlam d lam T = _
  rw [Qlam_eq_withDensity d lam hlam, withDensity_apply _ hT, ← he]
  have htrans := measurePreserving_add_right (volume : Measure (Fin d → ℝ)) h
  exact (htrans.setLIntegral_comp_preimage hT
    (continuous_laplaceWeight lam).measurable.ennreal_ofReal).symm

theorem Qlam_neg_preimage {d : ℕ} {lam : ℝ} (hlam : 0 < lam)
    {S : Set (Fin d → ℝ)} (hS : MeasurableSet S) :
    Qlam d lam ((fun x => -x) ⁻¹' S) = Qlam d lam S := by
  rw [Qlam_eq_withDensity d lam hlam, withDensity_apply _ (hS.preimage (by fun_prop)),
    withDensity_apply _ hS]
  simpa [laplaceWeight, l1norm] using
    (Measure.measurePreserving_neg (volume : Measure (Fin d → ℝ))).setLIntegral_comp_preimage
      hS (continuous_laplaceWeight lam).measurable.ennreal_ofReal

/-- Removing any one coordinate gives the Laplace product of the remaining coordinates. -/
theorem Qlam_lintegral_insertNth {d : ℕ} {lam : ℝ} (hlam : 0 < lam) (j : Fin (d + 1))
    {f : (Fin (d + 1) → ℝ) → ℝ≥0∞} (hf : Measurable f) :
    ∫⁻ x, f x ∂Qlam (d + 1) lam =
      ∫⁻ t, ∫⁻ x, f (j.insertNth t x) ∂Qlam d lam ∂laplace lam := by
  let : IsProbabilityMeasure (laplace lam) := laplace_isProbabilityMeasure lam hlam
  let : IsProbabilityMeasure (Qlam d lam) := Qlam_isProbabilityMeasure d lam hlam
  let e := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (d + 1) => ℝ) j
  have he : MeasurePreserving e (Qlam (d + 1) lam) ((laplace lam).prod (Qlam d lam)) :=
    measurePreserving_piFinSuccAbove (fun _ => laplace lam) j
  rw [← he.symm.lintegral_comp (f := f) hf]
  rw [lintegral_prod (fun z => f (e.symm z)) (hf.comp e.symm.measurable).aemeasurable]
  rfl

end BQTF
