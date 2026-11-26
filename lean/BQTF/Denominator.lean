import BQTF.Asym.LocalGeometry
import BQTF.Asym.LocalMass
import BQTF.PriorMass
import BQTF.CheckLoss

/-!
# Denominator (appendix, Lemma `pf:lem:evid`)

Owner: Neon-B. The event `Ω_E` is defined as the set where the denominator bound holds, for a
constant `C_E`; the lemma provides `C_E` and bounds `P(Ω_Eᶜ)`.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- The lower bound `V_r (√n ε_n / 2)^r e^{−C_E n ε_n²}` of Lemma `pf:lem:evid`. -/
def denomBound (k n : ℕ) (CE : ℝ) : ℝ≥0∞ :=
  Vr (k + 1) * ENNReal.ofReal ((Real.sqrt n * Real.sqrt (epsSq (k + 1) n) / 2) ^ (k + 1)) *
    ENNReal.ofReal (Real.exp (-(CE * n * epsSq (k + 1) n)))

/-- `Ω_E`: the data `y` for which `N(ℝⁿ) ≥ V_r (√n ε_n/2)^r e^{−C_E n ε_n²}`. -/
def OmegaE (k n : ℕ) (τ lam : ℝ) (θs : Fin n → ℝ) (CE : ℝ) : Set (Fin n → ℝ) :=
  {y | denomBound k n CE ≤ Nmass (k + 1) τ lam y θs Set.univ}

private theorem Smul_sub_evidence (r n : ℕ) (x y : Fin (n-r) → ℝ) :
    Smul r n (x-y) = Smul r n x - Smul r n y := by
  ext i
  simp [Smul, sub_mul, Finset.sum_sub_distrib]

private theorem l2norm_Asb_evidence (r n : ℕ) (hn : 0 < n) (u : Fin (n-r) → ℝ) :
    l2norm (Asb r n u) = empNorm (Pperp r n (Smul r n u)) := by
  let v := Pperp r n (Smul r n u)
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  change l2norm (((n : ℝ) ^ (-(1 / 2 : ℝ))) • v) = empNorm v
  rw [← norm_toE_eq_l2norm, map_smul, norm_smul, Real.norm_eq_abs,
    abs_of_pos (Real.rpow_pos_of_pos hn' _), norm_toE_eq_l2norm]
  rw [Real.rpow_neg hn'.le, ← Real.sqrt_eq_rpow]
  unfold l2norm empNorm
  rw [Real.sqrt_div (l2sq_nonneg _)]
  ring

private theorem empNorm_sub_evidence {n : ℕ} (v w : Fin n → ℝ) :
    empNorm (v-w) ≤ empNorm v + empNorm w := by
  have h (x : Fin n → ℝ) : empNorm x = ‖toE n x‖ / Real.sqrt n := by
    rw [norm_toE_eq_l2norm]
    exact Real.sqrt_div (l2sq_nonneg _) _
  rw [h, h, h, map_sub, ← add_div]
  exact div_le_div_of_nonneg_right (norm_sub_le _ _) (Real.sqrt_nonneg _)

private theorem evidence_set_data {k n : ℕ} (hn : k + 1 < n) {lam : ℝ} (hlam : 0 < lam)
    (θs : Fin n → ℝ) (u₀ : Fin (n-(k+1)) → ℝ)
    (hu : empNorm (Pperp (k + 1) n (Smul (k + 1) n (ustar (k + 1) n θs - u₀))) ≤
      Real.sqrt (epsSq (k+1) n) / 2) :
    let r := k + 1
    let ε := Real.sqrt (epsSq r n)
    let R := Real.sqrt n * ε / 2
    let U := {u | u - u₀ ∈ Bsb r n (ε / 2)}
    let S := {θ | l2norm (NT r n (θ - θs)) ≤ R} ∩ (diffOp r n) ⁻¹' U
    MeasurableSet S ∧ (∀ θ ∈ S, l2sq (θ - θs) ≤ 5 / 4 * n * epsSq r n) ∧
      nu r n lam S = Vr r * ENNReal.ofReal (R ^ r) * Qlam (n-r) lam U := by
  let r := k + 1
  let ε := Real.sqrt (epsSq r n)
  let R := Real.sqrt n * ε / 2
  let U := {u | u - u₀ ∈ Bsb r n (ε / 2)}
  let B := {θ | l2norm (NT r n (θ - θs)) ≤ R}
  let S := B ∩ (diffOp r n) ⁻¹' U
  change MeasurableSet S ∧ (∀ θ ∈ S, l2sq (θ - θs) ≤ 5 / 4 * n * epsSq r n) ∧
      nu r n lam S = Vr r * ENNReal.ofReal (R ^ r) * Qlam (n-r) lam U
  have hn₀ : 0 < n := by omega
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn₀
  have heps : 0 < epsSq r n := Real.rpow_pos_of_pos hn' _
  have hε : 0 ≤ ε := Real.sqrt_nonneg _
  have hR : 0 ≤ R := by dsimp [R]; positivity
  have hB : MeasurableSet B := measurableSet_le ((continuous_l2norm (n := r)).measurable.comp
    ((continuous_NT r n).measurable.comp (measurable_id.sub_const _))) measurable_const
  have hScont : Continuous (Smul r n) := by
    apply continuous_pi
    intro i
    unfold Smul
    fun_prop
  have hU : MeasurableSet U := by
    change MeasurableSet {u : Fin (n-r) → ℝ | l2norm (Asb r n (u - u₀)) ≤ ε / 2}
    apply measurableSet_le _ measurable_const
    have hsub : Continuous (fun u : Fin (n-r) → ℝ => u - u₀) :=
      continuous_id.sub continuous_const
    have hm := ((Pperp r n).continuous_of_finiteDimensional.comp hScont).comp hsub
    have hAsb : Continuous (fun u : Fin (n-r) → ℝ => Asb r n (u - u₀)) :=
      hm.const_smul ((n : ℝ) ^ (-(1 / 2 : ℝ)))
    exact (continuous_l2norm (n := n)).measurable.comp hAsb.measurable
  have hS : MeasurableSet S := hB.inter (hU.preimage (continuous_diffOp r n).measurable)
  have hSmass : nu r n lam S = Vr r * ENNReal.ofReal (R ^ r) * Qlam (n-r) lam U := by
    let H : (Fin (n-r) → ℝ) → ℝ≥0∞ := U.indicator (fun _ => 1)
    have hH : Measurable H := measurable_const.indicator hU
    rw [← lintegral_indicator_one hS]
    calc
      _ = ∫⁻ θ, B.indicator (fun θ => H (diffOp r n θ)) θ ∂nu r n lam := by
        apply lintegral_congr
        intro θ
        by_cases hθ : θ ∈ B <;> by_cases hθ' : diffOp r n θ ∈ U <;>
          simp [S, H, hθ, hθ']
      _ = Vr r * ∫⁻ u, ENNReal.ofReal (R ^ r) * H u ∂Qlam (n-r) lam :=
        vol_formula r n (by dsimp [r]; omega) hn lam hlam θs H hH
          (fun _ => R) measurable_const (fun _ => hR)
      _ = _ := by
        rw [lintegral_const_mul _ hH]
        unfold H
        rw [show (fun _ : Fin (n-r) → ℝ => (1 : ℝ≥0∞)) = 1 from rfl,
          lintegral_indicator_one hU, mul_assoc]
  refine ⟨hS, ?_, hSmass⟩
  intro θ hθ
  obtain ⟨⟨z,u⟩, rfl⟩ := (coordMap_bijective r n (by dsimp [r]; omega) hn).1.2 θ
  have hdu := (coordMap_bijective r n (by dsimp [r]; omega) hn).2 (z,u)
  have htail : empNorm (Pperp r n (Smul r n (u-u₀))) ≤ ε / 2 := by
    rw [← l2norm_Asb_evidence r n hn₀]
    have hh : diffOp r n (coordMap r n (z,u)) - u₀ ∈ Bsb r n (ε / 2) := hθ.2
    rwa [hdu] at hh
  have htv : empNorm (Pperp r n (Smul r n (u-ustar r n θs))) ≤ ε := by
    have hd : u - ustar r n θs = (u-u₀) - (ustar r n θs-u₀) := by abel
    rw [hd, Smul_sub_evidence, map_sub]
    exact (empNorm_sub_evidence _ _).trans (by linarith only [htail, hu])
  have htvSq := l2sq_le_of_empNorm_le hn₀ htv
  have hz : l2norm (z - cbar r n θs u) ≤ R := by
    rw [sub_cbar_eq r n (by dsimp [r]; omega) hn]
    exact hθ.1
  have hzSq := pow_le_pow_left₀ (Real.sqrt_nonneg _) hz 2
  change (Real.sqrt (l2sq (z - cbar r n θs u))) ^ 2 ≤ R ^ 2 at hzSq
  rw [Real.sq_sqrt (l2sq_nonneg _)] at hzSq
  have hR2 : R ^ 2 = (n : ℝ) * epsSq r n / 4 := by
    dsimp [R]
    rw [div_pow, mul_pow, Real.sq_sqrt hn'.le, show ε ^ 2 = epsSq r n from Real.sq_sqrt heps.le]
    ring
  rw [hR2] at hzSq
  rw [show ε ^ 2 = epsSq r n from Real.sq_sqrt heps.le] at htvSq
  rw [pythagoras r n (by dsimp [r]; omega) hn]
  linarith only [hzSq, htvSq]

private theorem evidence_ell_abs (τ : ℝ) (hτ : 0 < τ ∧ τ < 1) (t z : ℝ) :
    |ell τ t z| ≤ |t| := by
  have hp := ell_props τ z hτ
  simpa [hp.2.1] using hp.2.2.1 t 0

private theorem evidence_average_bounds {k n : ℕ} {τ L fl fu Vb B : ℝ} (hB : 0 ≤ B)
    (hL : 0 < L) (hfl : 0 < fl) {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (hτ : 0 < τ ∧ τ < 1) (hdata : DataHyp k n τ μ θs L fl fu Vb)
    (v : Measure (Fin n → ℝ)) [IsProbabilityMeasure v]
    (hball : ∀ᵐ θ ∂v, l2sq (θ - θs) ≤ B) :
    let X := fun y => ∫ θ, lossHat τ (y - θs) (θ - θs) ∂v
    MemLp X 2 (Measure.pi μ) ∧ (∫ y, X y ∂Measure.pi μ) ≤ C1 L fu * B ∧
      variance X (Measure.pi μ) ≤ B := by
  let X := fun y => ∫ θ, lossHat τ (y - θs) (θ - θs) ∂v
  let P := Measure.pi μ
  let g (i : Fin n) (z : ℝ) (θ : Fin n → ℝ) := ell τ (θ i - θs i) (z - θs i)
  let f (i : Fin n) (z : ℝ) := ∫ θ, g i z θ ∂v
  let d (i : Fin n) := ∫ θ, |θ i - θs i| ∂v
  let C := Real.sqrt B
  change MemLp X 2 P ∧ (∫ y, X y ∂P) ≤ C1 L fu * B ∧ variance X P ≤ B
  have hμ (i : Fin n) : IsProbabilityMeasure (μ i) := hdata.prob i
  have hgc (i : Fin n) : Measurable (fun p : ℝ × (Fin n → ℝ) => g i p.1 p.2) := by
    have h₁ : Measurable (fun p : ℝ × (Fin n → ℝ) => p.2 i - θs i) :=
      ((measurable_pi_apply i).comp measurable_snd).sub_const _
    have h₂ : Measurable (fun p : ℝ × (Fin n → ℝ) => p.1 - θs i) :=
      measurable_fst.sub_const _
    exact (measurable_ell_pair τ).comp (h₁.prodMk h₂)
  have hfm (i : Fin n) : Measurable (f i) :=
    (hgc i).stronglyMeasurable.integral_prod_right'.measurable
  have hdmeas (i : Fin n) : Measurable (fun θ : Fin n → ℝ => |θ i - θs i|) :=
    ((measurable_pi_apply i).sub_const _).abs
  have hcoord (i : Fin n) : ∀ᵐ θ ∂v, |θ i - θs i| ≤ C := by
    filter_upwards [hball] with θ hθ
    apply (sq_le_sq₀ (abs_nonneg _) (Real.sqrt_nonneg _)).mp
    rw [sq_abs, Real.sq_sqrt hB]
    exact (Finset.single_le_sum (fun j _ => sq_nonneg ((θ - θs) j)) (Finset.mem_univ i)).trans hθ
  have hbound (i : Fin n) (z : ℝ) (θ : Fin n → ℝ) : |g i z θ| ≤ |θ i - θs i| :=
    evidence_ell_abs τ hτ _ _
  have hdi (i : Fin n) : Integrable (fun θ => |θ i - θs i|) v := by
    apply (integrable_const C).mono' (hdmeas i).aestronglyMeasurable
    simpa only [Real.norm_eq_abs, abs_abs] using hcoord i
  have hgi (i : Fin n) (z : ℝ) : Integrable (g i z) v := by
    have hm : Measurable (g i z) := (hgc i).comp measurable_prodMk_left
    apply (hdi i).mono' hm.aestronglyMeasurable
    exact Filter.Eventually.of_forall fun θ => by simpa only [Real.norm_eq_abs, abs_abs] using hbound i z θ
  have hprod (i : Fin n) : Integrable (Function.uncurry (g i)) ((μ i).prod v) := by
    apply (integrable_const C).mono' (hgc i).aestronglyMeasurable
    have h := (measurePreserving_snd (μ := μ i) (ν := v)).quasiMeasurePreserving.ae (hcoord i)
    filter_upwards [h] with p hp
    exact (by simpa only [Real.norm_eq_abs] using hbound i p.1 p.2 : ‖g i p.1 p.2‖ ≤ _).trans hp
  have hfa (i : Fin n) (z : ℝ) : |f i z| ≤ d i := by
    have hbl : ∀ᵐ θ ∂v, ‖g i z θ‖ ≤ |θ i - θs i| :=
      Filter.Eventually.of_forall fun θ => by simpa only [Real.norm_eq_abs] using hbound i z θ
    have h := norm_integral_le_of_norm_le (hdi i) hbl
    simpa [f, d, Real.norm_eq_abs] using h
  have hf₂ (i : Fin n) : MemLp (f i) 2 (μ i) :=
    memLp_of_bounded (Filter.Eventually.of_forall fun z => abs_le.mp (hfa i z))
      (hfm i).aestronglyMeasurable 2
  have hX : X = (∑ i, fun y : Fin n → ℝ => f i (y i)) := by
    funext y
    change (∫ θ, ∑ i, g i (y i) θ ∂v) = _
    rw [integral_finsetSum _ (fun i _ => hgi i (y i)), Finset.sum_apply]
  have hX₂ : MemLp X 2 P := by
    rw [hX]
    exact memLp_finsetSum' _ (fun i _ => (hf₂ i).comp_measurePreserving (measurePreserving_eval _ i))
  have hsqI (i : Fin n) : Integrable (fun θ : Fin n → ℝ => (θ i - θs i) ^ 2) v := by
    have hm : Measurable (fun θ : Fin n → ℝ => (θ i - θs i) ^ 2) :=
      ((measurable_pi_apply i).sub_const _).pow_const _
    apply (integrable_const (C ^ 2)).mono' hm.aestronglyMeasurable
    filter_upwards [hcoord i] with θ hθ
    rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
    simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg _) hθ 2
  have hsI : Integrable (fun θ : Fin n → ℝ => l2sq (θ - θs)) v := by
    change Integrable (fun θ => ∑ i, (θ i - θs i) ^ 2) v
    exact integrable_finsetSum _ fun i _ => hsqI i
  have hInt : (∫ θ, l2sq (θ - θs) ∂v) ≤ B := by
    simpa [measureReal_def] using integral_mono_ae hsI (integrable_const B) hball
  refine ⟨hX₂, ?_, ?_⟩
  · have hi (i : Fin n) : (∫ y : Fin n → ℝ, f i (y i) ∂P) =
        ∫ θ, mFun τ (μ i) (θs i) (θ i - θs i) ∂v := by
      have hpre := measurePreserving_eval μ i
      calc
        _ = ∫ z, f i z ∂μ i := by
          rw [← hpre.map_eq, integral_map hpre.measurable.aemeasurable
            (hfm i).aestronglyMeasurable]
        _ = _ := integral_integral_swap (hprod i)
    have hmi (i : Fin n) :
        Integrable (fun θ => mFun τ (μ i) (θs i) (θ i - θs i)) v :=
      (hprod i).integral_prod_right
    have hC : 0 ≤ C1 L fu := (by positivity : 0 ≤ 1 / L).trans (le_max_right _ _)
    have hfi (i : Fin n) : Integrable (fun y : Fin n → ℝ => f i (y i)) P :=
      ((hf₂ i).comp_measurePreserving (measurePreserving_eval _ i)).integrable (by norm_num)
    rw [hX]
    simp_rw [Finset.sum_apply]
    rw [integral_finsetSum _ (fun i _ => hfi i)]
    simp_rw [hi]
    rw [← integral_finsetSum _ (fun i _ => hmi i)]
    calc
      _ ≤ ∫ θ, C1 L fu * l2sq (θ - θs) ∂v := by
        apply integral_mono (integrable_finsetSum _ (fun i _ => hmi i)) (hsI.const_mul _)
        intro θ
        change (∑ i, mFun τ (μ i) (θs i) (θ i - θs i)) ≤ C1 L fu * ∑ i, (θ i - θs i) ^ 2
        rw [Finset.mul_sum]
        exact Finset.sum_le_sum fun i _ =>
          (mFun_props (dataCoordHyp hdata hτ hL hfl i) (θ i - θs i)).2.2.2.2
      _ ≤ _ := by
        rw [integral_const_mul]
        exact mul_le_mul_of_nonneg_left hInt hC
  · rw [hX, variance_sum_pi hf₂]
    calc
      _ ≤ ∑ i, ∫ θ, (θ i - θs i) ^ 2 ∂v := by
        apply Finset.sum_le_sum
        intro i _
        have hbox : ∀ᵐ z ∂μ i, f i z ∈ Set.Icc (-d i) (d i) :=
          Filter.Eventually.of_forall fun z => abs_le.mp (hfa i z)
        have hv := variance_le_sq_of_bounded hbox (hfm i).aemeasurable
        have hv' : variance (f i) (μ i) ≤ d i ^ 2 := hv.trans_eq (by ring)
        have hc : ConvexOn ℝ Set.univ (fun x : ℝ => x ^ 2) := Even.convexOn_pow (by decide)
        have hA : Integrable (fun θ : Fin n → ℝ => |θ i - θs i| ^ 2) v := by
          simpa only [sq_abs] using hsqI i
        apply hv'.trans
        simpa only [sq_abs] using hc.map_integral_le (by fun_prop) isClosed_univ
          (Filter.Eventually.of_forall fun _ => Set.mem_univ _) (hdi i) hA
      _ = ∫ θ, l2sq (θ - θs) ∂v := by
        change _ = ∫ θ, ∑ i, (θ i - θs i) ^ 2 ∂v
        rw [integral_finsetSum _ (fun i _ => hsqI i)]
      _ ≤ _ := hInt

private theorem evidence_jensen {r n : ℕ} {τ lam B : ℝ} {S : Set (Fin n → ℝ)}
    (hτ : 0 < τ ∧ τ < 1) (hB : 0 ≤ B) (hS : MeasurableSet S)
    (hm : nu r n lam S ≠ 0) (hmt : nu r n lam S ≠ ∞)
    (y θs : Fin n → ℝ) (hball : ∀ θ ∈ S, l2sq (θ - θs) ≤ B) :
    let v := (nu r n lam S)⁻¹ • (nu r n lam).restrict S
    nu r n lam S * ENNReal.ofReal (Real.exp (-(∫ θ, lossHat τ (y - θs) (θ - θs) ∂v))) ≤
      Nmass r τ lam y θs Set.univ := by
  let ν := nu r n lam
  let m := ν S
  let v := m⁻¹ • ν.restrict S
  let F (θ : Fin n → ℝ) := lossHat τ (y - θs) (θ - θs)
  let C := (n : ℝ) * Real.sqrt B
  change m * ENNReal.ofReal (Real.exp (-(∫ θ, F θ ∂v))) ≤ _
  have hv : IsProbabilityMeasure v := by
    constructor
    rw [show v = m⁻¹ • ν.restrict S from rfl, Measure.smul_apply, Measure.restrict_apply_univ,
      smul_eq_mul]
    exact ENNReal.inv_mul_cancel hm hmt
  have hFm : Measurable F := by
    change Measurable (fun θ : Fin n → ℝ => ∑ i, ell τ (θ i - θs i) (y i - θs i))
    apply Finset.measurable_sum
    intro i _
    have hm : Measurable (fun θ : Fin n → ℝ => θ i - θs i) :=
      (measurable_pi_apply i).sub_const _
    exact (measurable_ell_pair τ).comp (hm.prodMk
      (measurable_const (a := y i - θs i)))
  have hb (θ : Fin n → ℝ) (hθ : θ ∈ S) : |F θ| ≤ C := by
    have hi (i : Fin n) : |θ i - θs i| ≤ Real.sqrt B := by
      apply (sq_le_sq₀ (abs_nonneg _) (Real.sqrt_nonneg _)).mp
      rw [sq_abs, Real.sq_sqrt hB]
      exact (Finset.single_le_sum (fun j _ => sq_nonneg ((θ - θs) j)) (Finset.mem_univ i)).trans (hball θ hθ)
    change |∑ i, ell τ (θ i - θs i) (y i - θs i)| ≤ _
    calc
      _ ≤ ∑ i, |ell τ (θ i - θs i) (y i - θs i)| :=
        Finset.abs_sum_le_sum_abs ..
      _ ≤ ∑ _i : Fin n, Real.sqrt B :=
        Finset.sum_le_sum fun i _ => (evidence_ell_abs τ hτ _ _).trans (hi i)
      _ = _ := by simp [C, nsmul_eq_mul]
  have hs : ∀ᵐ θ ∂v, θ ∈ S := Measure.ae_smul_measure (ae_restrict_mem hS) _
  have hFi : Integrable F v := by
    apply (integrable_const C).mono' hFm.aestronglyMeasurable
    filter_upwards [hs] with θ hθ
    simpa only [Real.norm_eq_abs] using hb θ hθ
  have hEi : Integrable (fun θ => Real.exp (-F θ)) v := by
    have hm : Measurable (fun θ => Real.exp (-F θ)) := Real.measurable_exp.comp hFm.neg
    apply (integrable_const (Real.exp C)).mono' hm.aestronglyMeasurable
    filter_upwards [hs] with θ hθ
    rw [Real.norm_eq_abs, abs_of_nonneg (Real.exp_nonneg _)]
    exact Real.exp_le_exp.mpr (by linarith only [(abs_le.mp (hb θ hθ)).1])
  have hj : Real.exp (-(∫ θ, F θ ∂v)) ≤ ∫ θ, Real.exp (-F θ) ∂v := by
    rw [← integral_neg]
    exact convexOn_exp.map_integral_le Real.continuous_exp.continuousOn isClosed_univ
      (Filter.Eventually.of_forall fun _ => Set.mem_univ _) hFi.neg hEi
  calc
    _ ≤ m * ENNReal.ofReal (∫ θ, Real.exp (-F θ) ∂v) :=
      mul_le_mul_right (ENNReal.ofReal_le_ofReal hj) _
    _ = ∫⁻ θ in S, ENNReal.ofReal (Real.exp (-F θ)) ∂ν := by
      rw [ofReal_integral_eq_lintegral_ofReal hEi
        (Filter.Eventually.of_forall fun _ => Real.exp_nonneg _)]
      unfold v
      rw [lintegral_smul_measure, smul_eq_mul, ← mul_assoc, ENNReal.mul_inv_cancel hm hmt, one_mul]
    _ ≤ _ := by
      unfold Nmass
      simp only [Measure.restrict_univ]
      exact setLIntegral_le_lintegral _ _

/-- Lemma `pf:lem:evid`: there are `C_E` and `n₁` (the paper's `C_E = (5/4) C_1 + 1 + C_pr`;
existential here, with the dependence on `(c, k, L, f̲, f̄, V̄)`) such that for `n ≥ n₁`,
`P(Ω_Eᶜ) ≤ (5/4)(n ε_n²)⁻¹`. -/
theorem denominator (k : ℕ) (hk : 1 ≤ k) (c L fl fu Vb : ℝ) (hc : 0 < c) (hL : 0 < L)
    (hfl : 0 < fl) :
    ∃ CE : ℝ, ∃ n₁ : ℕ, 0 < CE ∧ k + 1 < n₁ ∧ ∀ n, n₁ ≤ n → ∀ τ : ℝ, 0 < τ → τ < 1 →
      ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
        Measure.pi μ (OmegaE k n τ (lamSeq c k n) θs CE)ᶜ
          ≤ ENNReal.ofReal (5 / 4 / (n * epsSq (k + 1) n)) := by
  obtain ⟨Cpr, N, hCpr, hN, hprior⟩ := prior_mass k hk c Vb hc
  let C0 := 5 / 4 * C1 L fu + 1
  let CE := C0 + Cpr
  have hC1 : 0 < C1 L fu := (by positivity : 0 < 1 / L).trans_le (le_max_right _ _)
  have hCE : 0 < CE := by dsimp [CE, C0]; positivity
  refine ⟨CE, N, hCE, hN, ?_⟩
  intro n hn τ hτ₀ hτ₁ μ θs hdata
  let r := k + 1
  let ε := Real.sqrt (epsSq r n)
  let R := Real.sqrt n * ε / 2
  let x := (n : ℝ) * epsSq r n
  let lam := lamSeq c k n
  let P := Measure.pi μ
  let ν := nu r n lam
  have hτ : 0 < τ ∧ τ < 1 := ⟨hτ₀, hτ₁⟩
  have hn' : k + 1 < n := hN.trans_le hn
  have hn0 : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have hεsq : 0 < epsSq r n := Real.rpow_pos_of_pos hn0 _
  have hε : 0 < ε := Real.sqrt_pos.mpr hεsq
  have hR : 0 < R := by dsimp [R]; positivity
  have hx : 0 < x := mul_pos hn0 hεsq
  have hlam : 0 < lam := mul_pos hc (Real.rpow_pos_of_pos hn0 _)
  have hμ (i : Fin n) : IsProbabilityMeasure (μ i) := hdata.prob i
  have : IsProbabilityMeasure (laplace lam) := laplace_probability hlam
  have : IsProbabilityMeasure (Qlam (n-r) lam) := by unfold Qlam; infer_instance
  obtain ⟨u₀, hu₀, hprob⟩ := hprior n hn θs (by rw [TVr_eq_TV]; exact hdata.signal)
  let U := {u | u - u₀ ∈ Bsb r n (ε / 2)}
  let S := {θ | l2norm (NT r n (θ - θs)) ≤ R} ∩ (diffOp r n) ⁻¹' U
  obtain ⟨hS, hball, hmass⟩ := evidence_set_data hn' hlam θs u₀ hu₀
  change MeasurableSet S at hS
  change ∀ θ ∈ S, l2sq (θ - θs) ≤ 5 / 4 * n * epsSq r n at hball
  have hSm : ν S = Vr r * ENNReal.ofReal (R ^ r) * Qlam (n-r) lam U := hmass
  let M := Vr r * ENNReal.ofReal (R ^ r)
  let v := (ν S)⁻¹ • ν.restrict S
  have hpriorMass : M * ENNReal.ofReal (Real.exp (-(Cpr * x))) ≤ ν S := by
    rw [hSm]
    apply mul_le_mul_right
    have he : -(Cpr * x) = -(Cpr * n * epsSq r n) := by dsimp [x]; ring
    rw [he]
    exact hprob
  have hSm₀ : ν S ≠ 0 := by
    have hVol : 0 < Vr r := Metric.measure_ball_pos _ _ one_pos
    have hp : M * ENNReal.ofReal (Real.exp (-(Cpr * x))) ≠ 0 :=
      mul_ne_zero (mul_ne_zero hVol.ne' (ENNReal.ofReal_pos.mpr (by positivity)).ne')
        (ENNReal.ofReal_pos.mpr (Real.exp_pos _)).ne'
    exact ((pos_iff_ne_zero.mpr hp).trans_le hpriorMass).ne'
  have hSmTop : ν S ≠ ∞ := by
    rw [hSm]
    exact ENNReal.mul_ne_top (ENNReal.mul_ne_top measure_ball_ne_top ENNReal.ofReal_ne_top)
      (measure_ne_top _ _)
  have : IsProbabilityMeasure v := by
    constructor
    change ((ν S)⁻¹ • ν.restrict S) Set.univ = 1
    rw [Measure.smul_apply, Measure.restrict_apply_univ, smul_eq_mul,
      ENNReal.inv_mul_cancel hSm₀ hSmTop]
  let X := fun y => ∫ θ, lossHat τ (y - θs) (θ - θs) ∂v
  have hball_ae : ∀ᵐ θ ∂v, l2sq (θ - θs) ≤ (5 / 4) * x :=
    Measure.ae_smul_measure ((ae_restrict_mem hS).mono fun θ hθ =>
      by simpa only [x, mul_assoc] using hball θ hθ) _
  obtain ⟨hX, hmean, hvar⟩ := evidence_average_bounds (B := 5 / 4 * x) (by positivity)
    hL hfl hτ hdata v hball_ae
  have hmean' : (∫ y, X y ∂P) ≤ (C0 - 1) * x := by
    apply hmean.trans_eq
    dsimp [C0]
    ring
  have hE (y : Fin n → ℝ) (hy : X y ≤ C0 * x) : y ∈ OmegaE k n τ lam θs CE := by
    have hJ := evidence_jensen hτ (B := 5 / 4 * x) (by positivity) hS hSm₀ hSmTop
      y θs (fun θ hθ => by simpa only [x, mul_assoc] using hball θ hθ)
    change denomBound k n CE ≤ _
    apply le_trans _ hJ
    calc
      _ = (M * ENNReal.ofReal (Real.exp (-(Cpr * x)))) *
          ENNReal.ofReal (Real.exp (-(C0 * x))) := by
        have he : -(CE * n * epsSq r n) = -(Cpr * x) + -(C0 * x) := by dsimp [CE, x]; ring
        change M * ENNReal.ofReal (Real.exp (-(CE * n * epsSq r n))) = _
        rw [he, Real.exp_add, ENNReal.ofReal_mul (Real.exp_nonneg _), mul_assoc M]
      _ ≤ ν S * ENNReal.ofReal (Real.exp (-(X y))) :=
        mul_le_mul' hpriorMass (ENNReal.ofReal_le_ofReal (Real.exp_le_exp.mpr (neg_le_neg hy)))
  calc
    _ ≤ P {y | x ≤ |X y - ∫ z, X z ∂P|} := by
      apply measure_mono
      intro y hy
      have hlt : C0 * x < X y := lt_of_not_ge (fun h => hy (hE y h))
      change x ≤ |X y - ∫ z, X z ∂P|
      exact (by linarith only [hmean', hlt] : x ≤ X y - ∫ z, X z ∂P).trans (le_abs_self _)
    _ ≤ ENNReal.ofReal (variance X P / x ^ 2) := meas_ge_le_variance_div_sq hX hx
    _ ≤ _ := by
      apply ENNReal.ofReal_le_ofReal
      apply (div_le_div_of_nonneg_right hvar (sq_nonneg x)).trans_eq
      change (5 / 4 * x) / x ^ 2 = 5 / 4 / x
      field_simp

end BQTF
