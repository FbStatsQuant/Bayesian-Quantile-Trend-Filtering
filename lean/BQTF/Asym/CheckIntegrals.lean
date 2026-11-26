import BQTF.CheckLoss
import BQTF.Asym.Laplace
import BQTF.Asym.Vector

/-! Measurability and product integration of the coordinate check-loss terms. -/

open MeasureTheory
open scoped ENNReal

namespace BQTF

theorem dataCoordHyp {k n : ℕ} {τ L fl fu Vb : ℝ}
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (h : DataHyp k n τ μ θs L fl fu Vb) (hτ : 0 < τ ∧ τ < 1)
    (hL : 0 < L) (hfl : 0 < fl) (i : Fin n) :
    CoordHyp (μ i) τ (θs i) L fl fu :=
  ⟨h.prob i, hτ, h.quantile i, hL, hfl, h.assA i, h.assB i⟩

/-- Joint measurability of the check-loss increment in the displacement and observation. -/
theorem measurable_ell_pair (τ : ℝ) : Measurable (fun p : ℝ × ℝ => ell τ p.1 p.2) := by
  unfold ell
  exact ((measurable_checkLoss τ).comp (measurable_snd.sub measurable_fst)).sub
    ((measurable_checkLoss τ).comp measurable_snd)

/-- Joint measurability of Knight's remainder, for integration over both data and parameters. -/
theorem measurable_remK_pair (τ : ℝ) : Measurable (fun p : ℝ × ℝ => remK p.1 p.2) := by
  have he (p : ℝ × ℝ) : remK p.1 p.2 = ell τ p.1 p.2 + p.1 * scoreZ τ p.2 := by
    rw [(knight τ p.1 p.2).1]
    ring
  simp_rw [he]
  exact (measurable_ell_pair τ).add (measurable_fst.mul ((measurable_scoreZ τ).comp measurable_snd))

theorem lintegral_exp_remK_le {k n : ℕ} {τ L fl fu Vb : ℝ} {μ : Fin n → Measure ℝ}
    {θs δ : Fin n → ℝ} (h : DataHyp k n τ μ θs L fl fu Vb)
    (hτ : 0 < τ ∧ τ < 1) (hL : 0 < L) (hfl : 0 < fl)
    (hδ : ∀ i, |δ i| ≤ min L (3 * fl / (4 * fu))) :
    (∫⁻ y, ENNReal.ofReal (Real.exp (-2 * ∑ i, remK (δ i) (y i - θs i))) ∂Measure.pi μ)
      ≤ ENNReal.ofReal (Real.exp (-(fl / 2 * l2sq δ))) := by
  have (i : Fin n) : IsProbabilityMeasure (μ i) := h.prob i
  let f (i : Fin n) (x : ℝ) := Real.exp (-2 * remK (δ i) (x - θs i))
  have hp (i : Fin n) (x : ℝ) : 0 ≤ f i x := Real.exp_nonneg _
  have hi (i : Fin n) : Integrable (f i) (μ i) := by
    have hm : Measurable (f i) := by
      dsimp [f]
      exact Real.measurable_exp.comp (measurable_const.mul
        ((measurable_remK (δ i)).comp (measurable_id.sub_const _)))
    apply (integrable_const (1 : ℝ)).mono' hm.aestronglyMeasurable
    apply Filter.Eventually.of_forall
    intro x
    rw [Real.norm_eq_abs, abs_of_nonneg (hp i x)]
    exact Real.exp_le_one_iff.mpr (by
      linarith [(knight τ (δ i) (x - θs i)).2.1])
  simp_rw [Finset.mul_sum, Real.exp_sum]
  rw [lintegral_pi_ofReal_prod hi hp]
  have hterm (i : Fin n) : (∫⁻ x, ENNReal.ofReal (f i x) ∂μ i) ≤
      ENNReal.ofReal (Real.exp (-(fl / 2 * (δ i) ^ 2))) := by
    have hcoord := dataCoordHyp h hτ hL hfl i
    rw [← ofReal_integral_eq_lintegral_ofReal (hi i) (Filter.Eventually.of_forall (hp i))]
    apply ENNReal.ofReal_le_ofReal
    exact ((remK_moments hcoord (δ i)).2 (hδ i)).trans
      (Real.exp_le_exp.mpr (neg_le_neg ((mFun_props hcoord (δ i)).2.2.2.1
        ((hδ i).trans (min_le_left _ _))).1))
  calc
    _ ≤ ∏ i, ENNReal.ofReal (Real.exp (-(fl / 2 * (δ i) ^ 2))) :=
      Finset.prod_le_prod fun i _ => hterm i
    _ = _ := by
      rw [← ENNReal.ofReal_prod_of_nonneg (fun _ _ => Real.exp_nonneg _), ← Real.exp_sum]
      unfold l2sq
      simp [Finset.mul_sum, Finset.sum_neg_distrib]

end BQTF
