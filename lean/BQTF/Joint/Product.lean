import BQTF.Coord
import BQTF.Scale.Posterior

/-!
# Joint posterior as a conditioned product (appendix §`pf:sec:joint`, opening display; docs D5)

Owner: Neon-A.

`Π^⊗(· ∣ y)` is the product of the individual posteriors `Π_1, …, Π_J`. The paper's opening
display of §`pf:sec:joint` is `Π_𝒞(B ∣ y) = Π^⊗(B ∩ 𝒞 ∣ y) / Π^⊗(𝒞 ∣ y)`; here it is the lemma
`jointPosterior_eq_cond`, which also discharges D5 (the Spec definition cancels the per-level
normalizers).

Nonvacuity: the level hypotheses (`τ_j ∈ (0,1)`, `σ_j > 0`, `λ_j ≥ 0`, `n ≥ 1`) hold for
`J = 2`, `τ = (1/4, 3/4)`, `σ = 1`, `λ_j = lamSeq 1 k n`, any `n ≥ 1` and any `y`.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- The product posterior `Π^⊗(· ∣ y) = ⊗_j Π_j(· ∣ y)` on `(ℝⁿ)^J`, with `Π_j` the posterior at
`(τ_j, σ_j, λ_j)`. -/
def prodPosterior {J : ℕ} (τ σ lam : Fin J → ℝ) (k n : ℕ) (y : Fin n → ℝ) :
    Measure (Fin J → Fin n → ℝ) :=
  Measure.pi fun j => posterior (τ j) (σ j) (lam j) k n y

/-- `𝒞` is measurable (it is closed). -/
theorem measurableSet_orderSet (J n : ℕ) : MeasurableSet (orderSet J n) := by
  have heq : orderSet J n =
      ⋂ i : Fin n, ⋂ j₁ : Fin J, ⋂ j₂ : Fin J, ⋂ (_ : j₁ ≤ j₂),
        {Θ : Fin J → Fin n → ℝ | Θ j₁ i ≤ Θ j₂ i} := by
    ext Θ
    simp [orderSet, Monotone]
  rw [heq]
  refine MeasurableSet.iInter fun i => MeasurableSet.iInter fun j₁ =>
    MeasurableSet.iInter fun j₂ => MeasurableSet.iInter fun _ => ?_
  exact measurableSet_le
    ((measurable_pi_apply i).comp (measurable_pi_apply j₁))
    ((measurable_pi_apply i).comp (measurable_pi_apply j₂))

/-- `U_M` is measurable. -/
theorem measurableSet_jointFarSet {J n : ℕ} (k : ℕ) (θs : Fin J → Fin n → ℝ) (M : ℝ) :
    MeasurableSet (jointFarSet k θs M) := by
  have heq : jointFarSet k θs M = ⋃ j, {Θ | Θ j ∈ farSet k (θs j) M} := by
    ext Θ
    simp [jointFarSet, farSet]
  rw [heq]
  refine MeasurableSet.iUnion fun j => ?_
  have hfar : MeasurableSet (farSet k (θs j) M) := by
    unfold farSet lossΔ
    have hcont : Continuous (fun θ : Fin n → ℝ =>
        (∑ i : Fin n, min |(θ - θs j) i| ((θ - θs j) i ^ 2)) / (n : ℝ)) := by
      refine (continuous_finsetSum _ fun i _ => ?_).div_const _
      have hcoord : Continuous (fun θ : Fin n → ℝ => θ i - θs j i) :=
        (continuous_apply i).sub continuous_const
      exact hcoord.abs.min (hcoord.pow 2)
    exact measurableSet_lt measurable_const hcont.measurable
  exact measurable_pi_apply j hfar

/-- `U_M = ⋃_j {Θ : θ_j ∈ A_j}` with `A_j = farSet k θ*_j M` (the paper's `U`, proof of
`thm:joint`, "Transfer"). Definitional unfolding. -/
theorem jointFarSet_eq_iUnion {J n : ℕ} (k : ℕ) (θs : Fin J → Fin n → ℝ) (M : ℝ) :
    jointFarSet k θs M = ⋃ j, {Θ | Θ j ∈ farSet k (θs j) M} := by
  ext Θ
  simp [jointFarSet, farSet]

/-- `Π^⊗(· ∣ y)` is a probability measure (each factor is, by `posterior_isProbability`). -/
theorem prodPosterior_isProbability (k n : ℕ) (hn : 1 ≤ n) {J : ℕ} (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (y : Fin n → ℝ) :
    IsProbabilityMeasure (prodPosterior τ σ lam k n y) := by
  have : ∀ j, IsProbabilityMeasure (posterior (τ j) (σ j) (lam j) k n y) :=
    fun j => posterior_isProbability k n hn (τ j) (σ j) (lam j) (hτ j) (hσ j) (hlam j) y
  unfold prodPosterior
  infer_instance

/-- The marginal of `Π^⊗` at level `j` is `Π_j`: `Π^⊗(θ_j ∈ A ∣ y) = Π_j(A ∣ y)` (used in the
proof of Lemma `pf:lem:cond`). -/
theorem prodPosterior_level (k n : ℕ) (hn : 1 ≤ n) {J : ℕ} (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (y : Fin n → ℝ) (j : Fin J) {A : Set (Fin n → ℝ)} (hA : MeasurableSet A) :
    prodPosterior τ σ lam k n y {Θ | Θ j ∈ A} = posterior (τ j) (σ j) (lam j) k n y A := by
  have : ∀ l, IsProbabilityMeasure (posterior (τ l) (σ l) (lam l) k n y) :=
    fun l => posterior_isProbability k n hn (τ l) (σ l) (lam l) (hτ l) (hσ l) (hlam l) y
  exact (measurePreserving_eval (fun l => posterior (τ l) (σ l) (lam l) k n y) j).measure_preimage
    hA.nullMeasurableSet

/-! ## Private Tonelli and density helpers -/

/-- Product-space Tonelli identity for `ℝ≥0∞`-valued measurable functions on `Fin J → Fin n → ℝ`. -/
private lemma lintegral_fin_prod_vec {J n : ℕ} (f : Fin J → (Fin n → ℝ) → ℝ≥0∞)
    (hf : ∀ j, Measurable (f j)) :
    ∫⁻ Θ : Fin J → Fin n → ℝ, (∏ j : Fin J, f j (Θ j)) ∂volume =
      ∏ j : Fin J, ∫⁻ θ : Fin n → ℝ, f j θ ∂volume := by
  induction J with
  | zero =>
    change ∫⁻ Θ : Fin 0 → Fin n → ℝ, (1 : ℝ≥0∞) ∂(Measure.pi fun _ => volume) = 1
    simp [Measure.pi_empty_univ]
  | succ J ih =>
    have hmp := (measurePreserving_piFinSuccAbove (fun _ : Fin (J + 1) => (volume : Measure (Fin n → ℝ))) 0).symm
    change ∫⁻ Θ : Fin (J + 1) → Fin n → ℝ, (∏ j : Fin (J + 1), f j (Θ j))
        ∂(Measure.pi fun _ => volume) = _
    rw [← hmp.lintegral_comp_emb (MeasurableEquiv.measurableEmbedding _)
      (fun Θ : Fin (J + 1) → Fin n → ℝ => ∏ j : Fin (J + 1), f j (Θ j))]
    have hfun : (fun p : (Fin n → ℝ) × (Fin J → Fin n → ℝ) =>
        ∏ j : Fin (J + 1), f j ((MeasurableEquiv.piFinSuccAbove (fun _ => Fin n → ℝ) 0).symm p j)) =
        fun p : (Fin n → ℝ) × (Fin J → Fin n → ℝ) => f 0 p.1 * ∏ j : Fin J, f j.succ (p.2 j) := by
      ext p
      rw [Fin.prod_univ_succ]
      simp [MeasurableEquiv.piFinSuccAbove_symm_apply, Fin.insertNthEquiv]
    rw [hfun]
    have hmeas_tail : Measurable (fun y : Fin J → Fin n → ℝ => ∏ j : Fin J, f j.succ (y j)) :=
      Finset.measurable_prod _ fun j _ => (hf j.succ).comp (measurable_pi_apply j)
    rw [lintegral_prod_mul (hf 0).aemeasurable hmeas_tail.aemeasurable]
    change (∫⁻ x : Fin n → ℝ, f 0 x ∂volume) *
        (∫⁻ y : Fin J → Fin n → ℝ, (∏ j : Fin J, f j.succ (y j)) ∂volume) = _
    rw [ih (fun j => f j.succ) (fun j => hf j.succ), Fin.prod_univ_succ]

/-- Product of inverse normalizers equals inverse of product of normalizers when each factor is
in `(0, ∞)`. -/
private lemma prod_inv_eq_inv_prod {J : ℕ} (z : Fin J → ℝ≥0∞)
    (hz0 : ∀ j, z j ≠ 0) (hztop : ∀ j, z j ≠ ∞) :
    (∏ j : Fin J, (z j)⁻¹) = (∏ j : Fin J, z j)⁻¹ := by
  induction J with
  | zero => simp
  | succ J ih =>
    rw [Fin.prod_univ_succ, Fin.prod_univ_succ,
      ih (fun j => z j.succ) (fun j => hz0 j.succ) (fun j => hztop j.succ)]
    rw [ENNReal.mul_inv (Or.inl (hz0 0)) (Or.inl (hztop 0))]

/-- Density representation of `prodPosterior`:
`Π^⊗(· ∣ y) = (∏_j Z_j)⁻¹ • volume.withDensity (jointWeight …)`. -/
private lemma prodPosterior_eq_withDensity (k n : ℕ) (hn : 1 ≤ n) {J : ℕ} (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (y : Fin n → ℝ) :
    prodPosterior τ σ lam k n y =
      (∏ j : Fin J, ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ)⁻¹ •
        volume.withDensity (jointWeight τ σ lam k n y) := by
  have hprob : ∀ j, IsProbabilityMeasure (posterior (τ j) (σ j) (lam j) k n y) :=
    fun j => posterior_isProbability k n hn (τ j) (σ j) (lam j) (hτ j) (hσ j) (hlam j) y
  have hZ : ∀ j, 0 < ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ ∧
      ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ < ∞ :=
    fun j => lintegral_postWeight_pos_lt_top k n (τ j) (σ j) (lam j) (hτ j) (hσ j) (hlam j) y
  unfold prodPosterior
  refine Measure.pi_eq (μ := fun j => posterior (τ j) (σ j) (lam j) k n y) fun s hs => ?_
  rw [Measure.smul_apply, withDensity_apply _ (MeasurableSet.univ_pi hs), smul_eq_mul]
  have hind : ∫⁻ Θ in Set.univ.pi s, jointWeight τ σ lam k n y Θ ∂volume =
      ∫⁻ Θ : Fin J → Fin n → ℝ,
        (∏ j : Fin J, (s j).indicator (postWeight (τ j) (σ j) (lam j) k n y) (Θ j)) ∂volume := by
    rw [← lintegral_indicator (MeasurableSet.univ_pi hs)]
    congr 1
    ext Θ
    by_cases hΘ : Θ ∈ Set.univ.pi s
    · rw [Set.indicator_of_mem hΘ]
      unfold jointWeight
      refine Finset.prod_congr rfl fun j _ => ?_
      rw [Set.indicator_of_mem (hΘ j (Set.mem_univ j))]
    · rw [Set.indicator_of_notMem hΘ]
      simp only [Set.mem_univ_pi, not_forall] at hΘ
      rcases hΘ with ⟨j₀, hj₀⟩
      symm
      exact Finset.prod_eq_zero (Finset.mem_univ j₀) (Set.indicator_of_notMem hj₀ _)
  rw [hind, lintegral_fin_prod_vec _ fun j =>
    (measurable_postWeight (τ j) (σ j) (lam j) k n y).indicator (hs j)]
  have hfac : ∀ j : Fin J,
      ∫⁻ θ : Fin n → ℝ, (s j).indicator (postWeight (τ j) (σ j) (lam j) k n y) θ ∂volume =
        ∫⁻ θ in s j, postWeight (τ j) (σ j) (lam j) k n y θ ∂volume :=
    fun j => lintegral_indicator (hs j) _
  simp_rw [hfac]
  rw [← prod_inv_eq_inv_prod (fun j => ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ)
    (fun j => (hZ j).1.ne') (fun j => (hZ j).2.ne), ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun j _ => ?_
  rw [posterior, Measure.smul_apply, withDensity_apply _ (hs j), smul_eq_mul]

/-- Joint measurability of `(y, Θ) ↦ jointWeight τ σ lam k n y Θ`. -/
private lemma measurable_jointWeight_uncurry {J : ℕ} (τ σ lam : Fin J → ℝ) (k n : ℕ) :
    Measurable (fun p : (Fin n → ℝ) × (Fin J → Fin n → ℝ) =>
      jointWeight τ σ lam k n p.1 p.2) := by
  unfold jointWeight
  refine Finset.measurable_prod _ fun j _ => ?_
  have hcheck : Measurable (checkLoss (τ j)) := by
    unfold checkLoss
    exact measurable_id.mul
      (measurable_const.sub (Measurable.ite
        (measurableSet_lt measurable_id measurable_const) measurable_const measurable_const))
  unfold postWeight l1norm diffOp
  have h1 : Measurable (fun p : (Fin n → ℝ) × (Fin J → Fin n → ℝ) =>
      ∑ i : Fin n, checkLoss (τ j) (p.1 i - p.2 j i)) :=
    Finset.measurable_sum _ fun i _ =>
      hcheck.comp (((measurable_pi_apply i).comp measurable_fst).sub
        ((measurable_pi_apply i).comp ((measurable_pi_apply j).comp measurable_snd)))
  have h2 : Measurable (fun p : (Fin n → ℝ) × (Fin J → Fin n → ℝ) =>
      ∑ i : Fin (n - (k + 1)),
        |∑ l : Fin (k + 1 + 1), (-1 : ℝ) ^ (k + 1 - l.val) * ((k + 1).choose l.val : ℝ) *
          p.2 j ⟨i.val + l.val, by have := i.isLt; have := l.isLt; omega⟩|) :=
    Finset.measurable_sum _ fun i _ =>
      (Finset.measurable_sum _ fun l _ =>
        measurable_const.mul
          ((measurable_pi_apply (⟨i.val + l.val, by have := i.isLt; have := l.isLt; omega⟩ : Fin n)).comp
            ((measurable_pi_apply j).comp measurable_snd))).abs
  exact (Real.continuous_exp.measurable.comp
    ((h1.neg.div_const (σ j)).sub (measurable_const.mul h2))).ennreal_ofReal

/-! ## Main conditioning identity and measurability -/

/-- §`pf:sec:joint`, opening display (and docs D5): for measurable `B`,
`Π_𝒞(B ∣ y) = Π^⊗(B ∩ 𝒞 ∣ y) / Π^⊗(𝒞 ∣ y)`. (If `Π^⊗(𝒞 ∣ y) = 0` both sides are `0`; Lemma
`pf:lem:cond` excludes that case.) -/
theorem jointPosterior_eq_cond (k n : ℕ) (hn : 1 ≤ n) {J : ℕ} (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (y : Fin n → ℝ) {B : Set (Fin J → Fin n → ℝ)} (hB : MeasurableSet B) :
    jointPosterior τ σ lam k n y B =
      prodPosterior τ σ lam k n y (B ∩ orderSet J n) / prodPosterior τ σ lam k n y (orderSet J n) := by
  have hC := prodPosterior_eq_withDensity k n hn τ σ lam hτ hσ hlam y
  have hZ : ∀ j, 0 < ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ ∧
      ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ < ∞ :=
    fun j => lintegral_postWeight_pos_lt_top k n (τ j) (σ j) (lam j) (hτ j) (hσ j) (hlam j) y
  let Zprod : ℝ≥0∞ := ∏ j : Fin J, ∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ
  have hZ0 : Zprod ≠ 0 := Finset.prod_ne_zero_iff.mpr fun j _ => (hZ j).1.ne'
  have hZtop : Zprod ≠ ∞ := ENNReal.prod_ne_top fun j _ => (hZ j).2.ne
  have hZinv0 : Zprod⁻¹ ≠ 0 := ENNReal.inv_ne_zero.mpr hZtop
  have hZinvtop : Zprod⁻¹ ≠ ∞ := ENNReal.inv_ne_top.mpr hZ0
  have hCmeas : MeasurableSet (orderSet J n) := measurableSet_orderSet J n
  rw [hC, Measure.smul_apply, Measure.smul_apply,
    withDensity_apply _ (hB.inter hCmeas), withDensity_apply _ hCmeas,
    smul_eq_mul, smul_eq_mul]
  change jointPosterior τ σ lam k n y B =
    (Zprod⁻¹ * ∫⁻ Θ in B ∩ orderSet J n, jointWeight τ σ lam k n y Θ ∂volume) /
      (Zprod⁻¹ * ∫⁻ Θ in orderSet J n, jointWeight τ σ lam k n y Θ ∂volume)
  rw [ENNReal.mul_div_mul_left _ _ hZinv0 hZinvtop]
  rw [jointPosterior, Measure.smul_apply, withDensity_apply _ hB,
    Measure.restrict_restrict hB, smul_eq_mul, div_eq_mul_inv, mul_comm]

/-- Measurability of `y ↦ Π_𝒞(B ∣ y)` for measurable `B` (docs D8; Theory 2026-11-25 item 3:
Tonelli, the integrands are jointly measurable in `(Θ, y)`). No level hypotheses are needed:
the definition is a ratio of two measurable `ℝ≥0∞`-valued functions of `y`. -/
theorem measurable_jointPosterior_apply {J : ℕ} (τ σ lam : Fin J → ℝ) (k n : ℕ)
    {B : Set (Fin J → Fin n → ℝ)} (hB : MeasurableSet B) :
    Measurable (fun y => jointPosterior τ σ lam k n y B) := by
  have hw := measurable_jointWeight_uncurry τ σ lam k n
  have hden : Measurable (fun y => ∫⁻ Θ in orderSet J n, jointWeight τ σ lam k n y Θ) :=
    Measurable.lintegral_prod_right (ν := volume.restrict (orderSet J n)) hw
  have hnum : Measurable (fun y =>
      ∫⁻ Θ in B, jointWeight τ σ lam k n y Θ ∂(volume.restrict (orderSet J n))) :=
    Measurable.lintegral_prod_right (ν := (volume.restrict (orderSet J n)).restrict B) hw
  simpa only [jointPosterior, Measure.smul_apply, withDensity_apply _ hB, smul_eq_mul]
    using hden.fun_inv.fun_mul hnum

end BQTF
