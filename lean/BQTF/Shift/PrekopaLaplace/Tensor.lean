import BQTF.Basic
import BQTF.Shift.PrekopaLaplace.OneDim

/-!
# Tensorization of Prékopa–Leindler

`PLProp μ t`: the Prékopa–Leindler inequality at weight `t` for the measure `μ`.
It holds for Lebesgue measure on `ℝ` (`pl_one`), is stable under products,
measure-preserving linear equivalences and log-concave densities, hence holds for
`Qlam d lam = Measure.pi (fun _ => laplace lam)`.
-/

open MeasureTheory Set
open scoped ENNReal

noncomputable section

namespace BQTF.PL

/-- The Prékopa–Leindler inequality for `μ` at weight `t`. -/
def PLProp {E : Type*} [MeasurableSpace E] [AddCommGroup E] [Module ℝ E] (μ : Measure E)
    (t : ℝ) : Prop :=
  ∀ f g h : E → ℝ≥0∞, Measurable f → Measurable g → Measurable h →
    (∀ x y, f x ^ (1 - t) * g y ^ t ≤ h ((1 - t) • x + t • y)) →
    (∫⁻ x, f x ∂μ) ^ (1 - t) * (∫⁻ x, g x ∂μ) ^ t ≤ ∫⁻ x, h x ∂μ

theorem plProp_volume_real {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) :
    PLProp (volume : Measure ℝ) t :=
  fun _ _ _ hf hg hh hfgh =>
    pl_one ht0 ht1 hf hg hh fun x y => by simpa only [smul_eq_mul] using hfgh x y

section Stability

variable {E F : Type*} [MeasurableSpace E] [AddCommGroup E] [Module ℝ E]
  [MeasurableSpace F] [AddCommGroup F] [Module ℝ F]

/-- Products (Tonelli, then the property on each factor). -/
theorem PLProp.prod {μ : Measure E} {ν : Measure F} [SFinite ν] {t : ℝ}
    (hμ : PLProp μ t) (hν : PLProp ν t) : PLProp (μ.prod ν) t := by
  intro f g h hf hg hh hfgh
  rw [lintegral_prod _ hf.aemeasurable, lintegral_prod _ hg.aemeasurable,
    lintegral_prod _ hh.aemeasurable]
  refine hμ _ _ _ hf.lintegral_prod_right' hg.lintegral_prod_right' hh.lintegral_prod_right'
    fun x₁ x₂ => ?_
  refine hν (fun y => f (x₁, y)) (fun y => g (x₂, y)) (fun y => h ((1 - t) • x₁ + t • x₂, y))
    (hf.comp measurable_prodMk_left) (hg.comp measurable_prodMk_left)
    (hh.comp measurable_prodMk_left) fun y₁ y₂ => ?_
  have := hfgh (x₁, y₁) (x₂, y₂)
  simpa only [Prod.smul_mk, Prod.mk_add_mk] using this

/-- Transfer along a measure-preserving equivalence that commutes with convex combinations. -/
theorem PLProp.of_measurePreserving {μ : Measure E} {ν : Measure F} {t : ℝ} (e : E ≃ᵐ F)
    (he : MeasurePreserving e μ ν)
    (hlin : ∀ x y : E, e ((1 - t) • x + t • y) = (1 - t) • e x + t • e y)
    (hμ : PLProp μ t) : PLProp ν t := by
  intro f g h hf hg hh hfgh
  rw [← he.lintegral_comp_emb e.measurableEmbedding f,
    ← he.lintegral_comp_emb e.measurableEmbedding g,
    ← he.lintegral_comp_emb e.measurableEmbedding h]
  exact hμ _ _ _ (hf.comp e.measurable) (hg.comp e.measurable) (hh.comp e.measurable)
    fun x y => by rw [hlin]; exact hfgh _ _

/-- Log-concave densities. -/
theorem PLProp.withDensity {μ : Measure E} {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    {ρ : E → ℝ≥0∞} (hρ : Measurable ρ)
    (hlc : ∀ x y, ρ x ^ (1 - t) * ρ y ^ t ≤ ρ ((1 - t) • x + t • y))
    (hμ : PLProp μ t) : PLProp (μ.withDensity ρ) t := by
  have h1t : 0 ≤ 1 - t := by linarith
  intro f g h hf hg hh hfgh
  rw [lintegral_withDensity_eq_lintegral_mul _ hρ hf,
    lintegral_withDensity_eq_lintegral_mul _ hρ hg,
    lintegral_withDensity_eq_lintegral_mul _ hρ hh]
  refine hμ _ _ _ (hρ.mul hf) (hρ.mul hg) (hρ.mul hh) fun x y => ?_
  simp only [Pi.mul_apply]
  rw [ENNReal.mul_rpow_of_nonneg _ _ h1t, ENNReal.mul_rpow_of_nonneg _ _ ht0]
  calc ρ x ^ (1 - t) * f x ^ (1 - t) * (ρ y ^ t * g y ^ t)
      = (ρ x ^ (1 - t) * ρ y ^ t) * (f x ^ (1 - t) * g y ^ t) := by ring
    _ ≤ _ := mul_le_mul' (hlc x y) (hfgh x y)

end Stability

/-- Finite products of copies of a one-dimensional measure, by induction on the dimension. -/
theorem plProp_pi {μ : Measure ℝ} [SigmaFinite μ] {t : ℝ} (hμ : PLProp μ t) :
    ∀ d : ℕ, PLProp (Measure.pi fun _ : Fin d => μ) t
  | 0 => by
    intro f g h hf hg hh hfgh
    have hpi : Measure.pi (fun _ : Fin 0 => μ) = Measure.dirac (fun i => Fin.elim0 i) :=
      Measure.pi_of_empty _ _
    rw [hpi, lintegral_dirac' _ hf, lintegral_dirac' _ hg, lintegral_dirac' _ hh]
    have := hfgh (fun i => Fin.elim0 i) (fun i => Fin.elim0 i)
    rwa [Subsingleton.elim ((1 - t) • (fun i => Fin.elim0 i : Fin 0 → ℝ) + t • fun i => Fin.elim0 i)
      (fun i => Fin.elim0 i)] at this
  | d + 1 => by
    have hprod := hμ.prod (plProp_pi hμ d)
    refine PLProp.of_measurePreserving
      (MeasurableEquiv.piFinSuccAbove (fun _ : Fin (d + 1) => ℝ) 0).symm
      ((measurePreserving_piFinSuccAbove (fun _ : Fin (d + 1) => μ) 0).symm _) ?_ hprod
    intro p q
    funext i
    refine Fin.cases ?_ (fun j => ?_) i <;>
      simp [MeasurableEquiv.piFinSuccAbove_symm_apply]

/-- The Laplace density is log-concave. -/
lemma laplace_logconcave {lam : ℝ} (hlam : 0 < lam) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (x y : ℝ) :
    ENNReal.ofReal (laplacePDF lam x) ^ (1 - t) * ENNReal.ofReal (laplacePDF lam y) ^ t ≤
      ENNReal.ofReal (laplacePDF lam ((1 - t) • x + t • y)) := by
  have h1t : 0 ≤ 1 - t := by linarith
  have hpos : ∀ z, 0 ≤ laplacePDF lam z := fun z => by unfold laplacePDF; positivity
  rw [ENNReal.ofReal_rpow_of_nonneg (hpos x) h1t, ENNReal.ofReal_rpow_of_nonneg (hpos y) ht0,
    ← ENNReal.ofReal_mul (by have := hpos x; positivity)]
  apply ENNReal.ofReal_le_ofReal
  unfold laplacePDF
  rw [smul_eq_mul, smul_eq_mul, Real.mul_rpow (by positivity) (by positivity),
    Real.mul_rpow (by positivity) (by positivity), ← Real.exp_mul, ← Real.exp_mul]
  have hc : (lam / 2) ^ (1 - t) * (lam / 2) ^ t = lam / 2 := by
    rw [← Real.rpow_add (by positivity)]
    simp
  have htri := abs_add_le ((1 - t) * x) (t * y)
  rw [abs_mul, abs_mul, abs_of_nonneg h1t, abs_of_nonneg ht0] at htri
  have hl := mul_le_mul_of_nonneg_left htri hlam.le
  calc (lam / 2) ^ (1 - t) * Real.exp (-(lam * |x|) * (1 - t)) *
        ((lam / 2) ^ t * Real.exp (-(lam * |y|) * t))
      = lam / 2 * Real.exp (-(lam * |x|) * (1 - t) + -(lam * |y|) * t) := by
        rw [Real.exp_add, mul_mul_mul_comm, hc]
    _ ≤ lam / 2 * Real.exp (-(lam * |(1 - t) * x + t * y|)) := by
        gcongr
        nlinarith

instance laplace_sigmaFinite (lam : ℝ) : SigmaFinite (laplace lam) := by
  unfold laplace
  infer_instance

theorem plProp_laplace {lam : ℝ} (hlam : 0 < lam) {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) :
    PLProp (laplace lam) t := by
  unfold laplace
  refine (plProp_volume_real ht0 ht1).withDensity ht0.le ht1.le ?_
    (laplace_logconcave hlam ht0.le ht1.le)
  refine ENNReal.measurable_ofReal.comp ?_
  unfold laplacePDF
  fun_prop

theorem plProp_Qlam {lam : ℝ} (hlam : 0 < lam) {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) (d : ℕ) :
    PLProp (Qlam d lam) t :=
  plProp_pi (plProp_laplace hlam ht0 ht1) d

end BQTF.PL
