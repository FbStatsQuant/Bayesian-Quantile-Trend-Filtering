import BQTF.Scale.Posterior

open MeasureTheory

namespace BQTF

/-- Marginal laws of the data divided by `σ`. -/
noncomputable def scaleData {n : ℕ} (σ : ℝ) (μ : Fin n → Measure ℝ) :
    Fin n → Measure ℝ := fun i => (μ i).map (σ⁻¹ * ·)

theorem scaleData_prob {n : ℕ} (σ : ℝ) {μ : Fin n → Measure ℝ}
    (hμ : ∀ i, IsProbabilityMeasure (μ i)) (i : Fin n) :
    IsProbabilityMeasure (scaleData σ μ i) := by
  let := hμ i
  exact (Measure.isProbabilityMeasure_map_iff (by fun_prop)).mpr inferInstance

theorem pi_scaleData {n : ℕ} (σ : ℝ) {μ : Fin n → Measure ℝ}
    (hμ : ∀ i, IsProbabilityMeasure (μ i)) :
    (Measure.pi μ).map (σ⁻¹ • ·) = Measure.pi (scaleData σ μ) := by
  let (i : Fin n) : IsProbabilityMeasure (scaleData σ μ i) := scaleData_prob σ hμ i
  exact Measure.pi_map_pi (f := fun _ => (σ⁻¹ * ·)) (fun _ => by fun_prop)

private theorem map_Iic_inv_mul (μ : Measure ℝ) {σ : ℝ} (hσ : 0 < σ) (x : ℝ) :
    μ.map (σ⁻¹ * ·) (Set.Iic x) = μ (Set.Iic (σ * x)) := by
  rw [Measure.map_apply (by fun_prop) measurableSet_Iic]
  congr 1
  ext t
  change σ⁻¹ * t ≤ x ↔ t ≤ σ * x
  rw [← div_eq_inv_mul, div_le_iff₀ hσ, mul_comm]

private theorem map_Iio_inv_mul (μ : Measure ℝ) {σ : ℝ} (hσ : 0 < σ) (x : ℝ) :
    μ.map (σ⁻¹ * ·) (Set.Iio x) = μ (Set.Iio (σ * x)) := by
  rw [Measure.map_apply (by fun_prop) measurableSet_Iio]
  congr 1
  ext t
  change σ⁻¹ * t < x ↔ t < σ * x
  rw [← div_eq_inv_mul, div_lt_iff₀ hσ, mul_comm]

theorem DataHyp.scale {k n : ℕ} {τ σ L fl fu Vb : ℝ}
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (h : DataHyp k n τ μ θs L fl fu Vb) (hσ : 0 < σ) :
    DataHyp k n τ (scaleData σ μ) (σ⁻¹ • θs)
      (L / σ) (σ * fl) (σ * fu) (Vb / σ) := by
  have hcoord (i : Fin n) : σ * (σ⁻¹ • θs) i = θs i := by
    simp [Pi.smul_apply, smul_eq_mul, mul_inv_cancel_left₀ hσ.ne']
  have hdist (i : Fin n) (x : ℝ) :
      distFn (scaleData σ μ i) x = distFn (μ i) (σ * x) := by
    unfold distFn scaleData
    rw [map_Iic_inv_mul _ hσ]
  have ht' (t : ℝ) (ht : |t| ≤ L / σ) : |σ * t| ≤ L := by
    rw [abs_mul, abs_of_pos hσ, mul_comm]
    exact (le_div_iff₀ hσ).mp ht
  have hinc (i : Fin n) (t : ℝ) :
      distFn (scaleData σ μ i) ((σ⁻¹ • θs) i + t) =
        distFn (μ i) (θs i + σ * t) := by
    rw [hdist, mul_add, hcoord]
  refine ⟨scaleData_prob σ h.prob, ?_, ?_, ?_, ?_⟩
  · intro i
    unfold IsQuantile
    rw [hdist, hcoord]
    change (((μ i).map (σ⁻¹ * ·)) (Set.Iio ((σ⁻¹ • θs) i))).toReal ≤ τ ∧ _
    rw [map_Iio_inv_mul _ hσ, hcoord]
    exact h.quantile i
  · intro i t ht
    rw [hinc, hdist, hcoord]
    have hA := h.assA i (σ * t) (ht' t ht)
    simpa only [abs_mul, abs_of_pos hσ, mul_left_comm fl σ, ← mul_assoc] using hA
  · intro i t ht
    rw [hinc, hdist, hcoord]
    have hB := h.assB i (σ * t) (ht' t ht)
    simpa only [abs_mul, abs_of_pos hσ, mul_left_comm fu σ, ← mul_assoc] using hB
  · unfold TV
    rw [l1norm_diffOp_smul (inv_nonneg.mpr hσ.le), mul_left_comm, div_eq_inv_mul]
    exact mul_le_mul_of_nonneg_left h.signal (inv_nonneg.mpr hσ.le)

end BQTF
