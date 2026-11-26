import BQTF.Asym.Vector
import BQTF.Asym.CheckIntegrals

/-! Geometry of the localization set and bounds for the mean check loss. -/

open MeasureTheory

namespace BQTF

theorem l2sq_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ l2sq v :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem sq_empNorm {n : ℕ} (v : Fin n → ℝ) :
    empNorm v ^ 2 = l2sq v / n :=
  Real.sq_sqrt (div_nonneg (l2sq_nonneg v) (Nat.cast_nonneg n))

theorem empNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ empNorm v :=
  Real.sqrt_nonneg _

theorem TVr_nonneg {r n : ℕ} (v : Fin n → ℝ) : 0 ≤ TVr r n v := by
  exact mul_nonneg (by positivity) (Finset.sum_nonneg fun _ _ => abs_nonneg _)

theorem l2sq_le_of_empNorm_le {n : ℕ} (hn : 0 < n) {v : Fin n → ℝ} {ρ : ℝ}
    (hv : empNorm v ≤ ρ) : l2sq v ≤ n * ρ ^ 2 := by
  have h := pow_le_pow_left₀ (empNorm_nonneg v) hv 2
  rw [sq_empNorm] at h
  simpa [mul_comm] using (div_le_iff₀ (by exact_mod_cast hn : 0 < (n : ℝ))).mp h

theorem continuous_TVr (r n : ℕ) : Continuous (TVr r n) := by
  unfold TVr l1norm
  have h := continuous_diffOp r n
  fun_prop

theorem continuous_empNorm (n : ℕ) : Continuous (empNorm (n := n)) := by
  unfold empNorm
  have h := continuous_l2sq n
  fun_prop

theorem isClosed_Kset (r n : ℕ) (ρ T : ℝ) : IsClosed (Kset r n ρ T) := by
  exact (isClosed_le (continuous_empNorm n) continuous_const).inter
    (isClosed_le (continuous_TVr r n) continuous_const)

theorem isCompact_Kset (r n : ℕ) (hn : 0 < n) (ρ T : ℝ) (hρ : 0 ≤ ρ) :
    IsCompact (Kset r n ρ T) := by
  apply Metric.isCompact_of_isClosed_isBounded (isClosed_Kset r n ρ T)
  refine isBounded_iff_forall_norm_le.mpr ⟨Real.sqrt n * ρ, fun v hv => ?_⟩
  apply (pi_norm_le_iff_of_nonneg (by positivity)).2
  intro i
  rw [Real.norm_eq_abs, ← sq_le_sq₀ (abs_nonneg _) (by positivity),
    sq_abs, mul_pow, Real.sq_sqrt (Nat.cast_nonneg n)]
  exact (Finset.single_le_sum (fun j _ => sq_nonneg (v j)) (Finset.mem_univ i)).trans
    (l2sq_le_of_empNorm_le hn hv.1)

theorem diffOp_smul (r n : ℕ) (b : ℝ) (v : Fin n → ℝ) :
    diffOp r n (b • v) = b • diffOp r n v := by
  funext i
  simp only [diffOp, Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem TVr_smul (r n : ℕ) (b : ℝ) (v : Fin n → ℝ) :
    TVr r n (b • v) = |b| * TVr r n v := by
  rw [TVr, diffOp_smul]
  unfold TVr l1norm
  simp only [Pi.smul_apply, smul_eq_mul, abs_mul, ← Finset.mul_sum]
  ring

theorem empNorm_smul {n : ℕ} (b : ℝ) (v : Fin n → ℝ) :
    empNorm (b • v) = |b| * empNorm v := by
  apply (sq_eq_sq₀ (empNorm_nonneg _) (by positivity [empNorm_nonneg v])).mp
  rw [sq_empNorm, mul_pow, sq_abs, sq_empNorm]
  unfold l2sq
  simp only [Pi.smul_apply, smul_eq_mul, mul_pow, ← Finset.mul_sum]
  ring

theorem lossHat_ray {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (Z δ : Fin n → ℝ) {t : ℝ} (ht : 1 ≤ t) :
    t * lossHat τ Z (t⁻¹ • δ) ≤ lossHat τ Z δ := by
  have ht' : 0 < t := zero_lt_one.trans_le ht
  have h₁ : 0 ≤ t⁻¹ := inv_nonneg.mpr ht'.le
  have h₂ : 0 ≤ 1 - t⁻¹ := sub_nonneg.mpr (inv_le_one_of_one_le₀ ht)
  have hweights : t⁻¹ + (1 - t⁻¹) = 1 := by ring
  unfold lossHat
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  obtain ⟨hcv, h0, _, _⟩ := ell_props τ (Z i) hτ
  have h := hcv.2 (Set.mem_univ (δ i)) (Set.mem_univ (0 : ℝ)) h₁ h₂ hweights
  simp only [smul_eq_mul, mul_zero, add_zero, h0] at h
  change t * ell τ (t⁻¹ * δ i) (Z i) ≤ ell τ (δ i) (Z i)
  simpa only [← mul_assoc, mul_inv_cancel₀ ht'.ne', one_mul] using
    (mul_le_mul_of_nonneg_left h ht'.le)

theorem integrable_ell (τ t q : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Measure ℝ) [IsFiniteMeasure μ] : Integrable (fun y => ell τ t (y - q)) μ := by
  have hm : Measurable (fun y => ell τ t (y - q)) :=
    (measurable_ell τ t).comp (measurable_id.sub_const q)
  apply (integrable_const |t|).mono' hm.aestronglyMeasurable
  apply Filter.Eventually.of_forall
  intro y
  have hp := ell_props τ (y - q) hτ
  simpa [hp.2.1] using hp.2.2.1 t 0

theorem lossExp_eq_sum {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) (hμ : ∀ i, IsProbabilityMeasure (μ i))
    (θs δ : Fin n → ℝ) :
    lossExp τ μ θs δ = ∑ i, mFun τ (μ i) (θs i) (δ i) := by
  have hpres (i : Fin n) : MeasurePreserving (fun y : Fin n → ℝ => y i) (Measure.pi μ) (μ i) :=
    measurePreserving_eval μ i
  unfold lossExp
  change (∫ y, ∑ i, ell τ (δ i) (y i - θs i) ∂Measure.pi μ) = _
  rw [integral_finsetSum]
  · apply Finset.sum_congr rfl
    intro i _
    unfold mFun
    have hm : Measurable (fun y => ell τ (δ i) (y - θs i)) :=
      (measurable_ell τ (δ i)).comp (measurable_id.sub_const (θs i))
    rw [← (hpres i).map_eq, integral_map (hpres i).measurable.aemeasurable
      hm.aestronglyMeasurable]
  · intro i _
    exact (hpres i).integrable_comp_of_integrable (integrable_ell τ _ _ hτ (μ i))

theorem lossExp_nonneg {k n : ℕ} {τ L fl fu Vb : ℝ} {μ : Fin n → Measure ℝ}
    {θs : Fin n → ℝ} (h : DataHyp k n τ μ θs L fl fu Vb)
    (hτ : 0 < τ ∧ τ < 1) (hL : 0 < L) (hfl : 0 < fl) (δ : Fin n → ℝ) :
    0 ≤ lossExp τ μ θs δ := by
  rw [lossExp_eq_sum τ hτ μ h.prob]
  exact Finset.sum_nonneg fun i _ => (mFun_props (dataCoordHyp h hτ hL hfl i) (δ i)).2.2.1

theorem lossExp_quadratic_lower {k n : ℕ} {τ L fl fu Vb : ℝ} {μ : Fin n → Measure ℝ}
    {θs : Fin n → ℝ} (h : DataHyp k n τ μ θs L fl fu Vb)
    (hτ : 0 < τ ∧ τ < 1) (hL : 0 < L) (hfl : 0 < fl) (δ : Fin n → ℝ)
    (hδ : ∀ i, |δ i| ≤ L) :
    fl / 2 * l2sq δ ≤ lossExp τ μ θs δ := by
  rw [lossExp_eq_sum τ hτ μ h.prob, l2sq, Finset.mul_sum]
  exact Finset.sum_le_sum fun i _ =>
    ((mFun_props (dataCoordHyp h hτ hL hfl i) (δ i)).2.2.2.1 (hδ i)).1

end BQTF
