import BQTF.SplineApprox
import BQTF.CheckLoss

/-!
# Score events (appendix, Lemma `pf:lem:score`)

Owner: Neon-B. `t = Sᵀ(I − P_J)ζ`, i.e. `t_j = ⟨(I − P_J) s_j, ζ⟩`, and the event `Ω_ζ(J)`.
Classical inputs: Hoeffding (in Mathlib: `measure_sum_ge_le_of_iIndepFun`), Chebyshev.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `t_j = ⟨(I − P_J) s_j, ζ⟩`. -/
def tScore (r n J : ℕ) (ζ : Fin n → ℝ) : Fin (n - r) → ℝ :=
  fun j => dot (sCol r n j - PJ r n J (sCol r n j)) ζ

/-- `Ω_ζ(J) = {‖P_J ζ‖₂² ≤ J + r, ‖t‖_∞ ≤ c_F h^{r−1/2} √(log 2n), ‖t‖₂² ≤ c_F² m h^{2r−1}}`,
with `ζ = τ − 1(y − θ* < 0)`. -/
def OmegaZeta (r n J : ℕ) (τ : ℝ) (θs : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {y | l2sq (PJ r n J (score τ (y - θs))) ≤ J + r ∧
       (∀ j, |tScore r n J (score τ (y - θs)) j| ≤
          cF r * (hJ (n - r) J : ℝ) ^ ((r : ℝ) - 1 / 2) * Real.sqrt (Real.log (2 * n))) ∧
       l2sq (tScore r n J (score τ (y - θs))) ≤
          cF r ^ 2 * (n - r : ℕ) * (hJ (n - r) J : ℝ) ^ (2 * r - 1)}

/-! ### Linear algebra for `orthProj` -/

private def projMat {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (i j : Fin n) : ℝ :=
  orthProj V (Pi.single j 1) i

private lemma toE_inner {n : ℕ} (u v : Fin n → ℝ) :
    @inner ℝ _ _ (toE n u) (toE n v) = dot u v := by
  simp [toE, dot, EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm]

private lemma orthProj_isProj {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) :
    LinearMap.IsProj V (orthProj V) := by
  let W := V.map (toE n).toLinearMap
  constructor
  · intro x
    have hmem : W.starProjection (toE n x) ∈ W := Submodule.starProjection_apply_mem W (toE n x)
    rcases hmem with ⟨v, hv, hveq⟩
    have heq : orthProj V x = v := by
      simp only [orthProj, LinearMap.comp_apply, ContinuousLinearMap.coe_coe,
        LinearEquiv.coe_coe]
      change (toE n).symm (W.starProjection (toE n x)) = v
      rw [← hveq]
      exact (toE n).symm_apply_apply v
    rwa [heq]
  · intro x hx
    have hmem : toE n x ∈ W := ⟨x, hx, rfl⟩
    simp only [orthProj, LinearMap.comp_apply, ContinuousLinearMap.coe_coe,
      LinearEquiv.coe_coe]
    change (toE n).symm (W.starProjection (toE n x)) = x
    rw [Submodule.starProjection_eq_self_iff.mpr hmem, LinearEquiv.symm_apply_apply]

private lemma orthProj_apply_eq_sum {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (v : Fin n → ℝ)
    (i : Fin n) :
    orthProj V v i = ∑ j, projMat V i j * v j := by
  have hv : v = ∑ j : Fin n, v j • Pi.single j (1 : ℝ) := by
    ext k
    simp [Finset.sum_apply, Pi.single_apply]
  conv_lhs => rw [hv]
  rw [map_sum]
  simp only [Finset.sum_apply, map_smul, Pi.smul_apply, smul_eq_mul, projMat, mul_comm]

private lemma orthProj_symm {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (u v : Fin n → ℝ) :
    dot (orthProj V u) v = dot u (orthProj V v) := by
  let W := V.map (toE n).toLinearMap
  have hPu : toE n (orthProj V u) = W.starProjection (toE n u) := by
    simp [orthProj, W]
  have hPv : toE n (orthProj V v) = W.starProjection (toE n v) := by
    simp [orthProj, W]
  have h1 : @inner ℝ _ _ (W.starProjection (toE n u)) (toE n v - W.starProjection (toE n v)) = 0 := by
    rw [real_inner_comm]
    exact Submodule.starProjection_inner_eq_zero (toE n v) _
      (Submodule.starProjection_apply_mem W (toE n u))
  have h2 : @inner ℝ _ _ (toE n u - W.starProjection (toE n u)) (W.starProjection (toE n v)) = 0 :=
    Submodule.starProjection_inner_eq_zero (toE n u) _
      (Submodule.starProjection_apply_mem W (toE n v))
  rw [inner_sub_right, sub_eq_zero] at h1
  rw [inner_sub_left, sub_eq_zero] at h2
  rw [← toE_inner, ← toE_inner, hPu, hPv, h1, h2]

private lemma projMat_symm {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (i j : Fin n) :
    projMat V i j = projMat V j i := by
  have h1 : dot (Pi.single i (1 : ℝ)) (orthProj V (Pi.single j 1)) = projMat V i j := by
    simp [dot, projMat, Pi.single_apply]
  have h2 : dot (orthProj V (Pi.single i 1)) (Pi.single j (1 : ℝ)) = projMat V j i := by
    simp [dot, projMat, Pi.single_apply]
  rw [← h1, ← h2, orthProj_symm]

private lemma projMat_sq_sum {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (i : Fin n) :
    ∑ j, projMat V i j ^ 2 = projMat V i i := by
  have h1 : dot (orthProj V (Pi.single i 1)) (orthProj V (Pi.single i 1)) =
      ∑ j, projMat V i j ^ 2 := by
    simp only [dot, sq]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [show orthProj V (Pi.single i 1) j = projMat V j i from rfl, projMat_symm]
  have h2 : dot (orthProj V (Pi.single i 1)) (orthProj V (Pi.single i 1)) = projMat V i i := by
    rw [orthProj_symm]
    have hidem : orthProj V (orthProj V (Pi.single i 1)) = orthProj V (Pi.single i 1) :=
      (orthProj_isProj V).2 _ ((orthProj_isProj V).1 _)
    rw [hidem]
    simp [dot, projMat, Pi.single_apply]
  linarith

private lemma l2sq_orthProj_eq_quadForm {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (v : Fin n → ℝ) :
    l2sq (orthProj V v) = ∑ i, ∑ j, projMat V i j * v i * v j := by
  have h1 : l2sq (orthProj V v) = dot (orthProj V v) (orthProj V v) := by
    simp [l2sq, dot, sq]
  rw [h1, orthProj_symm, (orthProj_isProj V).2 _ ((orthProj_isProj V).1 _)]
  simp only [dot, orthProj_apply_eq_sum, Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring

private lemma sum_projMat_diag {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) :
    ∑ i, projMat V i i = (Module.finrank ℝ V : ℝ) := by
  have htr1 : LinearMap.trace ℝ (Fin n → ℝ) (orthProj V) = (Module.finrank ℝ V : ℝ) :=
    (orthProj_isProj V).trace
  have htr2 : LinearMap.trace ℝ (Fin n → ℝ) (orthProj V) = ∑ i, projMat V i i := by
    rw [LinearMap.trace_eq_matrix_trace ℝ (Pi.basisFun ℝ (Fin n)) (orthProj V)]
    simp only [Matrix.trace, Matrix.diag, LinearMap.toMatrix_apply, Pi.basisFun_apply,
      Pi.basisFun_repr, projMat]
  linarith

/-! ### Product-measure integrals and quadratic forms of independent scores -/

private lemma integral_pi_eval {n : ℕ} {μ : Fin n → Measure ℝ}
    [∀ i, IsProbabilityMeasure (μ i)] (i : Fin n) (g : ℝ → ℝ) :
    ∫ y, g (y i) ∂(Measure.pi μ) = ∫ x, g x ∂(μ i) := by
  let f : Fin n → ℝ → ℝ := fun m x => if m = i then g x else 1
  have hrew : (fun y : Fin n → ℝ => g (y i)) = fun y => ∏ m : Fin n, f m (y m) := by
    ext y
    simp [f]
  rw [hrew, MeasureTheory.integral_fintype_prod_eq_prod]
  have hprod : ∀ m : Fin n,
      (∫ x, f m x ∂(μ m)) = if m = i then ∫ x, g x ∂(μ i) else 1 := by
    intro m
    by_cases hm : m = i
    · subst hm; simp [f]
    · simp [f, hm]
  simp_rw [hprod]
  simp

private lemma integral_pi_mul_two {n : ℕ} {μ : Fin n → Measure ℝ}
    [∀ i, IsProbabilityMeasure (μ i)] {i j : Fin n} (hij : i ≠ j) (g₁ g₂ : ℝ → ℝ) :
    ∫ y, g₁ (y i) * g₂ (y j) ∂(Measure.pi μ) =
      (∫ x, g₁ x ∂(μ i)) * (∫ x, g₂ x ∂(μ j)) := by
  let f : Fin n → ℝ → ℝ := fun m x => (if m = i then g₁ x else 1) * (if m = j then g₂ x else 1)
  have hrew : (fun y : Fin n → ℝ => g₁ (y i) * g₂ (y j)) = fun y => ∏ m : Fin n, f m (y m) := by
    ext y
    simp only [f]
    rw [Finset.prod_mul_distrib]
    simp
  rw [hrew, MeasureTheory.integral_fintype_prod_eq_prod]
  have hprod : ∀ m : Fin n,
      (∫ x, f m x ∂(μ m)) =
        (if m = i then ∫ x, g₁ x ∂(μ i) else 1) * (if m = j then ∫ x, g₂ x ∂(μ j) else 1) := by
    intro m
    by_cases hmi : m = i
    · subst hmi; simp [f, hij]
    · by_cases hmj : m = j
      · subst hmj; simp [f, hmi]
      · simp [f, hmi, hmj]
  simp_rw [hprod]
  rw [Finset.prod_mul_distrib]
  simp

private lemma integral_pi_mul_three_zero {n : ℕ} {μ : Fin n → Measure ℝ}
    [∀ i, IsProbabilityMeasure (μ i)] {i a b : Fin n} (hai : a ≠ i) (hab : a ≠ b)
    (g₁ g₂ g₃ : ℝ → ℝ) (h0 : ∫ x, g₂ x ∂(μ a) = 0) :
    ∫ y, g₁ (y i) * g₂ (y a) * g₃ (y b) ∂(Measure.pi μ) = 0 := by
  let f : Fin n → ℝ → ℝ := fun m x =>
    (if m = i then g₁ x else 1) * (if m = a then g₂ x else 1) * (if m = b then g₃ x else 1)
  have hrew : (fun y : Fin n → ℝ => g₁ (y i) * g₂ (y a) * g₃ (y b)) =
      fun y => ∏ m : Fin n, f m (y m) := by
    ext y
    simp only [f]
    rw [Finset.prod_mul_distrib, Finset.prod_mul_distrib]
    simp
  rw [hrew, MeasureTheory.integral_fintype_prod_eq_prod]
  refine Finset.prod_eq_zero (Finset.mem_univ a) ?_
  have hfa : f a = g₂ := by
    ext x; simp [f, hai, hab]
  rw [hfa, h0]

private lemma integral_pi_mul_four_zero {n : ℕ} {μ : Fin n → Measure ℝ}
    [∀ i, IsProbabilityMeasure (μ i)] {i j a b : Fin n} (hai : a ≠ i) (haj : a ≠ j) (hab : a ≠ b)
    (g₁ g₂ g₃ g₄ : ℝ → ℝ) (h0 : ∫ x, g₃ x ∂(μ a) = 0) :
    ∫ y, g₁ (y i) * g₂ (y j) * g₃ (y a) * g₄ (y b) ∂(Measure.pi μ) = 0 := by
  let f : Fin n → ℝ → ℝ := fun m x =>
    (if m = i then g₁ x else 1) * (if m = j then g₂ x else 1) *
    (if m = a then g₃ x else 1) * (if m = b then g₄ x else 1)
  have hrew : (fun y : Fin n → ℝ => g₁ (y i) * g₂ (y j) * g₃ (y a) * g₄ (y b)) =
      fun y => ∏ m : Fin n, f m (y m) := by
    ext y
    simp only [f]
    rw [Finset.prod_mul_distrib, Finset.prod_mul_distrib, Finset.prod_mul_distrib]
    simp
  rw [hrew, MeasureTheory.integral_fintype_prod_eq_prod]
  refine Finset.prod_eq_zero (Finset.mem_univ a) ?_
  have hfa : f a = g₃ := by
    ext x; simp [f, hai, haj, hab]
  rw [hfa, h0]

private lemma scoreZ_abs_le_one {τ : ℝ} (hτ : 0 < τ ∧ τ < 1) (z : ℝ) : |scoreZ τ z| ≤ 1 := by
  unfold scoreZ
  split_ifs <;> rw [abs_le] <;> constructor <;> linarith

private lemma measurable_score_coord {n : ℕ} (τ : ℝ) (θs : Fin n → ℝ) (i : Fin n) :
    Measurable (fun y : Fin n → ℝ => score τ (y - θs) i) :=
  (measurable_scoreZ τ).comp ((measurable_pi_apply i).sub measurable_const)

private lemma integrable_of_bounded_measurable {n : ℕ} {μ : Fin n → Measure ℝ}
    [∀ i, IsProbabilityMeasure (μ i)] {f : (Fin n → ℝ) → ℝ} (hf : Measurable f)
    {C : ℝ} (hC : ∀ y, |f y| ≤ C) :
    Integrable f (Measure.pi μ) :=
  Integrable.of_bound hf.aestronglyMeasurable C (Filter.Eventually.of_forall fun y => by
    rw [Real.norm_eq_abs]; exact hC y)

private lemma quadForm_mean_and_var {n : ℕ} {τ L fl fu : ℝ} (hτ : 0 < τ ∧ τ < 1)
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (hc : ∀ i, CoordHyp (μ i) τ (θs i) L fl fu)
    (Q : Fin n → Fin n → ℝ) (hQsymm : ∀ i j, Q i j = Q j i) :
    let X : (Fin n → ℝ) → ℝ := fun y => ∑ i, ∑ j, Q i j * score τ (y - θs) i * score τ (y - θs) j
    MemLp X 2 (Measure.pi μ) ∧
    (∫ y, X y ∂(Measure.pi μ)) = τ * (1 - τ) * ∑ i, Q i i ∧
    variance X (Measure.pi μ) ≤ (1 / 4 : ℝ) * ∑ i, ∑ j, Q i j ^ 2 := by
  have hprob : ∀ i, IsProbabilityMeasure (μ i) := fun i => (hc i).prob
  let P := Measure.pi μ
  let ζ : (Fin n → ℝ) → Fin n → ℝ := fun y => score τ (y - θs)
  let v : ℝ := τ * (1 - τ)
  let X : (Fin n → ℝ) → ℝ := fun y => ∑ i, ∑ j, Q i j * ζ y i * ζ y j
  have hζ_le : ∀ y i, |ζ y i| ≤ 1 := fun y i => scoreZ_abs_le_one hτ (y i - θs i)
  have hζ_sq_sub : ∀ y i, |ζ y i ^ 2 - v| ≤ 1 + |v| := fun y i => by
    have h1 := hζ_le y i
    have h0 := abs_nonneg (ζ y i)
    calc |ζ y i ^ 2 - v| ≤ |ζ y i ^ 2| + |v| := abs_sub _ _
      _ = |ζ y i| ^ 2 + |v| := by rw [abs_pow]
      _ ≤ 1 + |v| := by nlinarith
  have hXmeas : Measurable X := by
    refine Finset.measurable_sum _ fun i _ => Finset.measurable_sum _ fun j _ => ?_
    exact (measurable_const.mul (measurable_score_coord τ θs i)).mul
      (measurable_score_coord τ θs j)
  have hXmem : MemLp X 2 P := by
    refine MemLp.of_bound hXmeas.aestronglyMeasurable (∑ i, ∑ j, |Q i j|)
      (Filter.Eventually.of_forall fun y => ?_)
    rw [Real.norm_eq_abs]
    calc |∑ i, ∑ j, Q i j * ζ y i * ζ y j|
        ≤ ∑ i, |∑ j, Q i j * ζ y i * ζ y j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, ∑ j, |Q i j * ζ y i * ζ y j| :=
          Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, ∑ j, |Q i j| := by
          refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
          rw [abs_mul, abs_mul]
          have h1 := hζ_le y i
          have h2 := hζ_le y j
          have h3 : |ζ y i| * |ζ y j| ≤ 1 := by nlinarith [abs_nonneg (ζ y i), abs_nonneg (ζ y j)]
          nlinarith [abs_nonneg (Q i j)]
  have hmean_term : ∀ i j : Fin n,
      ∫ y, Q i j * ζ y i * ζ y j ∂P = if i = j then Q i i * v else 0 := by
    intro i j
    have hrew : (fun y : Fin n → ℝ => Q i j * ζ y i * ζ y j) =
        fun y => Q i j * (ζ y i * ζ y j) := by ext y; ring
    rw [hrew, integral_const_mul]
    by_cases hij : i = j
    · subst hij
      have hsq : (fun y : Fin n → ℝ => ζ y i * ζ y i) =
          fun y => scoreZ τ (y i - θs i) ^ 2 := by ext y; simp [ζ, score, scoreZ, sq]
      rw [hsq, integral_pi_eval i (fun x => scoreZ τ (x - θs i) ^ 2), integral_scoreZ_sq (hc i)]
      simp [v]
    · have hprod := integral_pi_mul_two (μ := μ) hij
        (fun x => scoreZ τ (x - θs i)) (fun x => scoreZ τ (x - θs j))
      change Q i j * (∫ y, scoreZ τ (y i - θs i) * scoreZ τ (y j - θs j) ∂P) = _
      rw [hprod, integral_scoreZ_eq_zero (hc i), zero_mul, mul_zero]
      simp [hij]
  have hmean : ∫ y, X y ∂P = v * ∑ i, Q i i := by
    have hint : ∀ i j, Integrable (fun y => Q i j * ζ y i * ζ y j) P := fun i j =>
      integrable_of_bounded_measurable
        ((measurable_const.mul (measurable_score_coord τ θs i)).mul (measurable_score_coord τ θs j))
        (C := |Q i j|) fun y => by
          rw [abs_mul, abs_mul]
          have h1 := hζ_le y i
          have h2 := hζ_le y j
          have h3 : |ζ y i| * |ζ y j| ≤ 1 := by nlinarith [abs_nonneg (ζ y i), abs_nonneg (ζ y j)]
          nlinarith [abs_nonneg (Q i j)]
    have h1 : ∫ y, X y ∂P = ∑ i, ∑ j, ∫ y, Q i j * ζ y i * ζ y j ∂P := by
      simp only [X]
      rw [integral_finsetSum _ fun i _ => integrable_finsetSum _ fun j _ => hint i j]
      refine Finset.sum_congr rfl fun i _ => integral_finsetSum _ fun j _ => hint i j
    rw [h1]
    simp_rw [hmean_term]
    simp [Finset.mul_sum, mul_comm]
  -- Variance computation: split `X - E[X] = D + O`
  let D : (Fin n → ℝ) → ℝ := fun y => ∑ i, Q i i * (ζ y i ^ 2 - v)
  let O : (Fin n → ℝ) → ℝ := fun y => ∑ i, ∑ j ∈ Finset.univ.erase i, Q i j * (ζ y i * ζ y j)
  have hsplit : ∀ y, X y - ∫ z, X z ∂P = D y + O y := by
    intro y
    rw [hmean]
    simp only [X, D, O, Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    have herase := Finset.add_sum_erase Finset.univ (fun j => Q i j * ζ y i * ζ y j)
      (Finset.mem_univ i)
    rw [← herase]
    have hoff : ∑ j ∈ Finset.univ.erase i, Q i j * ζ y i * ζ y j =
        ∑ j ∈ Finset.univ.erase i, Q i j * (ζ y i * ζ y j) :=
      Finset.sum_congr rfl fun j _ => by ring
    rw [hoff]
    ring
  have hDmeas : Measurable D := Finset.measurable_sum _ fun i _ =>
    measurable_const.mul (((measurable_score_coord τ θs i).pow_const 2).sub measurable_const)
  have hOmeas : Measurable O := Finset.measurable_sum _ fun i _ =>
    Finset.measurable_sum _ fun j _ =>
      measurable_const.mul ((measurable_score_coord τ θs i).mul (measurable_score_coord τ θs j))
  have hD_bound : ∀ y, |D y| ≤ ∑ i, |Q i i| * (1 + |v|) := fun y => by
    calc |∑ i, Q i i * (ζ y i ^ 2 - v)|
        ≤ ∑ i, |Q i i * (ζ y i ^ 2 - v)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, |Q i i| * (1 + |v|) := by
          refine Finset.sum_le_sum fun i _ => ?_
          rw [abs_mul]
          exact mul_le_mul_of_nonneg_left (hζ_sq_sub y i) (abs_nonneg _)
  have hO_bound : ∀ y, |O y| ≤ ∑ i, ∑ j ∈ Finset.univ.erase i, |Q i j| := fun y => by
    calc |∑ i, ∑ j ∈ Finset.univ.erase i, Q i j * (ζ y i * ζ y j)|
        ≤ ∑ i, |∑ j ∈ Finset.univ.erase i, Q i j * (ζ y i * ζ y j)| :=
          Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, ∑ j ∈ Finset.univ.erase i, |Q i j * (ζ y i * ζ y j)| :=
          Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, ∑ j ∈ Finset.univ.erase i, |Q i j| := by
          refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
          rw [abs_mul, abs_mul]
          have h1 := hζ_le y i
          have h2 := hζ_le y j
          have h3 : |ζ y i| * |ζ y j| ≤ 1 := by nlinarith [abs_nonneg (ζ y i), abs_nonneg (ζ y j)]
          nlinarith [abs_nonneg (Q i j)]
  have hD2_int : Integrable (fun y => D y ^ 2) P :=
    integrable_of_bounded_measurable (hDmeas.pow_const 2)
      (C := (∑ i, |Q i i| * (1 + |v|)) ^ 2) fun y => by
        rw [abs_of_nonneg (sq_nonneg _), ← sq_abs (D y)]
        exact pow_le_pow_left₀ (abs_nonneg _) (hD_bound y) 2
  have hO2_int : Integrable (fun y => O y ^ 2) P :=
    integrable_of_bounded_measurable (hOmeas.pow_const 2)
      (C := (∑ i, ∑ j ∈ Finset.univ.erase i, |Q i j|) ^ 2) fun y => by
        rw [abs_of_nonneg (sq_nonneg _), ← sq_abs (O y)]
        exact pow_le_pow_left₀ (abs_nonneg _) (hO_bound y) 2
  have hDO_int : Integrable (fun y => 2 * D y * O y) P :=
    integrable_of_bounded_measurable ((measurable_const.mul hDmeas).mul hOmeas)
      (C := 2 * (∑ i, |Q i i| * (1 + |v|)) * (∑ i, ∑ j ∈ Finset.univ.erase i, |Q i j|)) fun y => by
        rw [abs_mul, abs_mul, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2)]
        have h1 : 0 ≤ ∑ i, |Q i i| * (1 + |v|) := Finset.sum_nonneg fun i _ => by positivity
        have h2 : 0 ≤ ∑ i, ∑ j ∈ Finset.univ.erase i, |Q i j| :=
          Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => abs_nonneg _
        have hDb := hD_bound y
        have hOb := hO_bound y
        nlinarith [abs_nonneg (D y), abs_nonneg (O y)]
  -- 1) E[D^2] = v * (1 - 4 * v) * ∑ i, Q i i ^ 2
  have hED2 : ∫ y, D y ^ 2 ∂P = v * (1 - 4 * v) * ∑ i, Q i i ^ 2 := by
    have hexp : (fun y => D y ^ 2) =
        fun y => ∑ i, ∑ k, Q i i * Q k k * ((ζ y i ^ 2 - v) * (ζ y k ^ 2 - v)) := by
      ext y
      simp only [D, sq, Finset.sum_mul, Finset.mul_sum]
      refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun k _ => by ring
    have hint_ik : ∀ i k, Integrable (fun y => Q i i * Q k k * ((ζ y i ^ 2 - v) * (ζ y k ^ 2 - v))) P :=
      fun i k => integrable_of_bounded_measurable
        (measurable_const.mul
          ((((measurable_score_coord τ θs i).pow_const 2).sub measurable_const).mul
           (((measurable_score_coord τ θs k).pow_const 2).sub measurable_const)))
        (C := |Q i i * Q k k| * (1 + |v|) ^ 2) fun y => by
          rw [abs_mul (Q i i * Q k k), abs_mul (ζ y i ^ 2 - v)]
          have hi := hζ_sq_sub y i
          have hk := hζ_sq_sub y k
          have hik : |ζ y i ^ 2 - v| * |ζ y k ^ 2 - v| ≤ (1 + |v|) ^ 2 := by
            nlinarith [abs_nonneg (ζ y i ^ 2 - v), abs_nonneg (ζ y k ^ 2 - v), abs_nonneg v]
          exact mul_le_mul_of_nonneg_left hik (abs_nonneg _)
    rw [hexp, integral_finsetSum _ fun i _ => integrable_finsetSum _ fun k _ => hint_ik i k]
    have hterm : ∀ i k,
        ∫ y, Q i i * Q k k * ((ζ y i ^ 2 - v) * (ζ y k ^ 2 - v)) ∂P =
          if i = k then v * (1 - 4 * v) * Q i i ^ 2 else 0 := by
      intro i k
      rw [integral_const_mul]
      by_cases hik : i = k
      · subst hik
        have hrew : (fun y : Fin n → ℝ => (ζ y i ^ 2 - v) * (ζ y i ^ 2 - v)) =
            fun y => (scoreZ τ (y i - θs i) ^ 2 - v) ^ 2 := by
          ext y; simp [ζ, score, scoreZ, Pi.sub_apply, sq]
        rw [hrew, integral_pi_eval i (fun x => (scoreZ τ (x - θs i) ^ 2 - v) ^ 2)]
        have h1 : (fun x : ℝ => (scoreZ τ (x - θs i) ^ 2 - v) ^ 2) =
            fun x => scoreZ τ (x - θs i) ^ 4 - 2 * v * scoreZ τ (x - θs i) ^ 2 + v ^ 2 := by
          ext x; ring
        have hprob_i := (hc i).prob
        have hint4 : Integrable (fun x : ℝ => scoreZ τ (x - θs i) ^ 4) (μ i) :=
          Integrable.of_bound
            ((((measurable_scoreZ τ).comp (measurable_id.sub measurable_const)).pow_const 4).aestronglyMeasurable)
            1 (Filter.Eventually.of_forall fun x => by
              rw [Real.norm_eq_abs, abs_pow]
              exact pow_le_one₀ (abs_nonneg _) (scoreZ_abs_le_one hτ (x - θs i)))
        have hint2 : Integrable (fun x : ℝ => 2 * v * scoreZ τ (x - θs i) ^ 2) (μ i) :=
          (Integrable.of_bound
            ((((measurable_scoreZ τ).comp (measurable_id.sub measurable_const)).pow_const 2).aestronglyMeasurable)
            1 (Filter.Eventually.of_forall fun x => by
              rw [Real.norm_eq_abs, abs_pow]
              exact pow_le_one₀ (abs_nonneg _) (scoreZ_abs_le_one hτ (x - θs i)))).const_mul (2 * v)
        have hint42 : Integrable (fun x : ℝ =>
            scoreZ τ (x - θs i) ^ 4 - 2 * v * scoreZ τ (x - θs i) ^ 2) (μ i) :=
          hint4.sub hint2
        rw [h1, integral_add hint42 (integrable_const _), integral_sub hint4 hint2,
          integral_const_mul, integral_scoreZ_pow_four (hc i), integral_scoreZ_sq (hc i)]
        simp only [integral_const, smul_eq_mul, Measure.real, measure_univ, ENNReal.toReal_one,
          one_mul, ↓reduceIte]
        change Q i i * Q i i * (v * (1 - 3 * v) - 2 * v * v + v ^ 2) = v * (1 - 4 * v) * Q i i ^ 2
        ring
      · have hprod := integral_pi_mul_two (μ := μ) hik
          (fun x => scoreZ τ (x - θs i) ^ 2 - v) (fun x => scoreZ τ (x - θs k) ^ 2 - v)
        have hprob_i := (hc i).prob
        have hint2 : Integrable (fun x : ℝ => scoreZ τ (x - θs i) ^ 2) (μ i) :=
          Integrable.of_bound
            ((((measurable_scoreZ τ).comp (measurable_id.sub measurable_const)).pow_const 2).aestronglyMeasurable)
            1 (Filter.Eventually.of_forall fun x => by
              rw [Real.norm_eq_abs, abs_pow]
              have hle := scoreZ_abs_le_one hτ (x - θs i)
              have h0 := abs_nonneg (scoreZ τ (x - θs i))
              nlinarith)
        have hzero : ∫ x, (scoreZ τ (x - θs i) ^ 2 - v) ∂(μ i) = 0 := by
          rw [integral_sub hint2 (integrable_const _), integral_scoreZ_sq (hc i)]
          simp [v, Measure.real]
        change Q i i * Q k k *
          (∫ y, (scoreZ τ (y i - θs i) ^ 2 - v) * (scoreZ τ (y k - θs k) ^ 2 - v) ∂P) = _
        rw [hprod, hzero, zero_mul, mul_zero]
        simp [hik]
    calc ∑ i, ∫ y, ∑ k, Q i i * Q k k * ((ζ y i ^ 2 - v) * (ζ y k ^ 2 - v)) ∂P
        = ∑ i, ∑ k, ∫ y, Q i i * Q k k * ((ζ y i ^ 2 - v) * (ζ y k ^ 2 - v)) ∂P :=
          Finset.sum_congr rfl fun i _ => integral_finsetSum _ fun k _ => hint_ik i k
      _ = ∑ i, ∑ k, (if i = k then v * (1 - 4 * v) * Q i i ^ 2 else 0) :=
          Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun k _ => hterm i k
      _ = v * (1 - 4 * v) * ∑ i, Q i i ^ 2 := by simp [Finset.mul_sum]
  -- 2) E[2 * D * O] = 0
  have hEDO : ∫ y, 2 * D y * O y ∂P = 0 := by
    have hexp : (fun y => 2 * D y * O y) =
        fun y => ∑ i, ∑ a, ∑ b ∈ Finset.univ.erase a,
          (2 * Q i i * Q a b) * ((ζ y i ^ 2 - v) * ζ y a * ζ y b) := by
      ext y
      simp only [D, O]
      rw [Finset.mul_sum (a := (2 : ℝ)), Finset.sum_mul]
      refine Finset.sum_congr rfl fun i _ => ?_
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl fun a _ => ?_
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl fun b _ => by ring
    have hint_iab : ∀ i a b, Integrable (fun y =>
        (2 * Q i i * Q a b) * ((ζ y i ^ 2 - v) * ζ y a * ζ y b)) P := fun i a b =>
      integrable_of_bounded_measurable
        (measurable_const.mul
          (((((measurable_score_coord τ θs i).pow_const 2).sub measurable_const).mul
            (measurable_score_coord τ θs a)).mul (measurable_score_coord τ θs b)))
        (C := |2 * Q i i * Q a b| * (1 + |v|)) fun y => by
          rw [abs_mul (2 * Q i i * Q a b), abs_mul ((ζ y i ^ 2 - v) * ζ y a),
            abs_mul (ζ y i ^ 2 - v)]
          have hi := hζ_sq_sub y i
          have ha := hζ_le y a
          have hb := hζ_le y b
          have hab : |ζ y a| * |ζ y b| ≤ 1 := by nlinarith [abs_nonneg (ζ y a), abs_nonneg (ζ y b)]
          have h1 : |ζ y i ^ 2 - v| * |ζ y a| * |ζ y b| ≤ 1 + |v| := by
            rw [mul_assoc]
            nlinarith [abs_nonneg (ζ y i ^ 2 - v), abs_nonneg (|ζ y a| * |ζ y b|), abs_nonneg v]
          exact mul_le_mul_of_nonneg_left h1 (abs_nonneg _)
    rw [hexp, integral_finsetSum _ fun i _ => integrable_finsetSum _ fun a _ =>
      integrable_finsetSum _ fun b _ => hint_iab i a b]
    refine Finset.sum_eq_zero fun i _ => ?_
    rw [integral_finsetSum _ fun a _ => integrable_finsetSum _ fun b _ => hint_iab i a b]
    refine Finset.sum_eq_zero fun a _ => ?_
    rw [integral_finsetSum _ fun b _ => hint_iab i a b]
    refine Finset.sum_eq_zero fun b hb => ?_
    have hba : b ≠ a := Finset.ne_of_mem_erase hb
    rw [integral_const_mul]
    by_cases hai : a ≠ i
    · have hzero := integral_pi_mul_three_zero (μ := μ) hai hba.symm
        (fun x => scoreZ τ (x - θs i) ^ 2 - v)
        (fun x => scoreZ τ (x - θs a))
        (fun x => scoreZ τ (x - θs b))
        (integral_scoreZ_eq_zero (hc a))
      change (2 * Q i i * Q a b) *
        (∫ y, (scoreZ τ (y i - θs i) ^ 2 - v) * scoreZ τ (y a - θs a) * scoreZ τ (y b - θs b) ∂P) = 0
      rw [hzero, mul_zero]
    · push Not at hai
      have hbi : b ≠ i := hai ▸ hba
      have hzero := integral_pi_mul_three_zero (μ := μ) hbi hba
        (fun x => scoreZ τ (x - θs i) ^ 2 - v)
        (fun x => scoreZ τ (x - θs b))
        (fun x => scoreZ τ (x - θs a))
        (integral_scoreZ_eq_zero (hc b))
      have hcomm : (fun y : Fin n → ℝ => (ζ y i ^ 2 - v) * ζ y a * ζ y b) =
          fun y => (scoreZ τ (y i - θs i) ^ 2 - v) * scoreZ τ (y b - θs b) * scoreZ τ (y a - θs a) := by
        ext y; simp only [ζ, score, scoreZ, Pi.sub_apply]; ring
      rw [hcomm, hzero, mul_zero]
  -- 3) E[O^2] = 2 * v^2 * ∑ i, ∑ j ∈ univ.erase i, Q i j ^ 2
  have hEO2 : ∫ y, O y ^ 2 ∂P = 2 * v ^ 2 * ∑ i, ∑ j ∈ Finset.univ.erase i, Q i j ^ 2 := by
    have hexp : (fun y => O y ^ 2) =
        fun y => ∑ i, ∑ j ∈ Finset.univ.erase i, ∑ a, ∑ b ∈ Finset.univ.erase a,
          (Q i j * Q a b) * (ζ y i * ζ y j * ζ y a * ζ y b) := by
      ext y
      simp only [O, sq, Finset.sum_mul, Finset.mul_sum]
      refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ =>
        Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => by ring
    have hint_ijab : ∀ i j a b, Integrable (fun y =>
        (Q i j * Q a b) * (ζ y i * ζ y j * ζ y a * ζ y b)) P := fun i j a b =>
      integrable_of_bounded_measurable
        (measurable_const.mul
          ((((measurable_score_coord τ θs i).mul (measurable_score_coord τ θs j)).mul
            (measurable_score_coord τ θs a)).mul (measurable_score_coord τ θs b)))
        (C := |Q i j * Q a b|) fun y => by
          rw [abs_mul (Q i j * Q a b), abs_mul (ζ y i * ζ y j * ζ y a),
            abs_mul (ζ y i * ζ y j), abs_mul (ζ y i)]
          have h1 := hζ_le y i
          have h2 := hζ_le y j
          have h3 := hζ_le y a
          have h4 := hζ_le y b
          have h12 : |ζ y i| * |ζ y j| ≤ 1 := by nlinarith [abs_nonneg (ζ y i), abs_nonneg (ζ y j)]
          have h34 : |ζ y a| * |ζ y b| ≤ 1 := by nlinarith [abs_nonneg (ζ y a), abs_nonneg (ζ y b)]
          have h1234 : |ζ y i| * |ζ y j| * |ζ y a| * |ζ y b| ≤ 1 := by
            rw [mul_assoc (|ζ y i| * |ζ y j|)]
            nlinarith [mul_nonneg (abs_nonneg (ζ y i)) (abs_nonneg (ζ y j)),
              mul_nonneg (abs_nonneg (ζ y a)) (abs_nonneg (ζ y b))]
          nlinarith [abs_nonneg (Q i j * Q a b)]
    rw [hexp, integral_finsetSum _ fun i _ => integrable_finsetSum _ fun j _ =>
      integrable_finsetSum _ fun a _ => integrable_finsetSum _ fun b _ => hint_ijab i j a b]
    have hinner : ∀ i (j : Fin n) (hj : j ∈ Finset.univ.erase i),
        ∑ a, ∑ b ∈ Finset.univ.erase a,
          ∫ y, (Q i j * Q a b) * (ζ y i * ζ y j * ζ y a * ζ y b) ∂P =
          2 * v ^ 2 * Q i j ^ 2 := by
      intro i j hj
      have hji : j ≠ i := Finset.ne_of_mem_erase hj
      have hterm : ∀ a (b : Fin n) (hb : b ∈ Finset.univ.erase a),
          ∫ y, (Q i j * Q a b) * (ζ y i * ζ y j * ζ y a * ζ y b) ∂P =
            if (a = i ∧ b = j) ∨ (a = j ∧ b = i) then v ^ 2 * Q i j ^ 2 else 0 := by
        intro a b hb
        have hba : b ≠ a := Finset.ne_of_mem_erase hb
        rw [integral_const_mul]
        by_cases hcond : (a = i ∧ b = j) ∨ (a = j ∧ b = i)
        · simp only [hcond, ↓reduceIte]
          rcases hcond with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
          · have hrew : (fun y : Fin n → ℝ => ζ y a * ζ y b * ζ y a * ζ y b) =
                fun y => scoreZ τ (y a - θs a) ^ 2 * scoreZ τ (y b - θs b) ^ 2 := by
              ext y; simp only [ζ, score, scoreZ, Pi.sub_apply]; ring
            rw [hrew, integral_pi_mul_two (μ := μ) hba.symm
              (fun x => scoreZ τ (x - θs a) ^ 2) (fun x => scoreZ τ (x - θs b) ^ 2),
              integral_scoreZ_sq (hc a), integral_scoreZ_sq (hc b)]
            change Q a b * Q a b * (v * v) = v ^ 2 * Q a b ^ 2
            ring
          · have hrew : (fun y : Fin n → ℝ => ζ y b * ζ y a * ζ y a * ζ y b) =
                fun y => scoreZ τ (y b - θs b) ^ 2 * scoreZ τ (y a - θs a) ^ 2 := by
              ext y; simp only [ζ, score, scoreZ, Pi.sub_apply]; ring
            rw [hrew, integral_pi_mul_two (μ := μ) hba
              (fun x => scoreZ τ (x - θs b) ^ 2) (fun x => scoreZ τ (x - θs a) ^ 2),
              integral_scoreZ_sq (hc b), integral_scoreZ_sq (hc a), hQsymm a b]
            change Q b a * Q b a * (v * v) = v ^ 2 * Q b a ^ 2
            ring
        · simp only [hcond, ↓reduceIte]
          by_cases ha : a ≠ i ∧ a ≠ j
          · have hzero := integral_pi_mul_four_zero (μ := μ) ha.1 ha.2 hba.symm
              (fun x => scoreZ τ (x - θs i)) (fun x => scoreZ τ (x - θs j))
              (fun x => scoreZ τ (x - θs a)) (fun x => scoreZ τ (x - θs b))
              (integral_scoreZ_eq_zero (hc a))
            change (Q i j * Q a b) *
              (∫ y, scoreZ τ (y i - θs i) * scoreZ τ (y j - θs j) * scoreZ τ (y a - θs a) *
                scoreZ τ (y b - θs b) ∂P) = 0
            rw [hzero, mul_zero]
          · have hb_ne : b ≠ i ∧ b ≠ j := by
              constructor
              · intro hbi; apply hcond
                by_cases hai : a = i
                · exact absurd (hbi.trans hai.symm) hba
                · have haj : a = j := by tauto
                  exact Or.inr ⟨haj, hbi⟩
              · intro hbj; apply hcond
                by_cases haj : a = j
                · exact absurd (hbj.trans haj.symm) hba
                · have hai : a = i := by tauto
                  exact Or.inl ⟨hai, hbj⟩
            have hzero := integral_pi_mul_four_zero (μ := μ) hb_ne.1 hb_ne.2 hba
              (fun x => scoreZ τ (x - θs i)) (fun x => scoreZ τ (x - θs j))
              (fun x => scoreZ τ (x - θs b)) (fun x => scoreZ τ (x - θs a))
              (integral_scoreZ_eq_zero (hc b))
            have hcomm : (fun y : Fin n → ℝ => ζ y i * ζ y j * ζ y a * ζ y b) =
                fun y => scoreZ τ (y i - θs i) * scoreZ τ (y j - θs j) *
                  scoreZ τ (y b - θs b) * scoreZ τ (y a - θs a) := by
              ext y; simp only [ζ, score, scoreZ, Pi.sub_apply]; ring
            rw [hcomm, hzero, mul_zero]
      have hsum : ∑ a, ∑ b ∈ Finset.univ.erase a,
          ∫ y, (Q i j * Q a b) * (ζ y i * ζ y j * ζ y a * ζ y b) ∂P =
          ∑ a, ∑ b ∈ Finset.univ.erase a,
            if (a = i ∧ b = j) ∨ (a = j ∧ b = i) then v ^ 2 * Q i j ^ 2 else 0 :=
        Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b hb => hterm a b hb
      rw [hsum]
      have hsplit_a : ∀ a : Fin n,
          (∑ b ∈ Finset.univ.erase a,
            if (a = i ∧ b = j) ∨ (a = j ∧ b = i) then v ^ 2 * Q i j ^ 2 else 0) =
          (if a = i then v ^ 2 * Q i j ^ 2 else 0) + (if a = j then v ^ 2 * Q i j ^ 2 else 0) := by
        intro a
        by_cases hai : a = i
        · subst hai
          have h1 : ∀ b ∈ Finset.univ.erase a,
              (if (a = a ∧ b = j) ∨ (a = j ∧ b = a) then v ^ 2 * Q a j ^ 2 else 0) =
              if b = j then v ^ 2 * Q a j ^ 2 else 0 := by
            intro b _
            simp [hji.symm]
          rw [Finset.sum_congr rfl h1]
          simp [hji.symm, hj]
        · by_cases haj : a = j
          · subst haj
            have hi_mem : i ∈ Finset.univ.erase a := Finset.mem_erase.mpr ⟨hji.symm, Finset.mem_univ _⟩
            have h1 : ∀ b ∈ Finset.univ.erase a,
                (if (a = i ∧ b = a) ∨ (a = a ∧ b = i) then v ^ 2 * Q i a ^ 2 else 0) =
                if b = i then v ^ 2 * Q i a ^ 2 else 0 := by
              intro b _
              simp [hai]
            rw [Finset.sum_congr rfl h1]
            simp [hai, hi_mem]
          · have h1 : ∀ b ∈ Finset.univ.erase a,
                (if (a = i ∧ b = j) ∨ (a = j ∧ b = i) then v ^ 2 * Q i j ^ 2 else 0) = 0 := by
              intro b _; simp [hai, haj]
            rw [Finset.sum_congr rfl h1]
            simp [hai, haj]
      simp_rw [hsplit_a, Finset.sum_add_distrib]
      simp
      ring
    calc ∑ i, ∫ y, ∑ j ∈ Finset.univ.erase i, ∑ a, ∑ b ∈ Finset.univ.erase a,
          (Q i j * Q a b) * (ζ y i * ζ y j * ζ y a * ζ y b) ∂P
        = ∑ i, ∑ j ∈ Finset.univ.erase i, ∑ a, ∑ b ∈ Finset.univ.erase a,
            ∫ y, (Q i j * Q a b) * (ζ y i * ζ y j * ζ y a * ζ y b) ∂P := by
          refine Finset.sum_congr rfl fun i _ => ?_
          rw [integral_finsetSum _ fun j _ => integrable_finsetSum _ fun a _ =>
            integrable_finsetSum _ fun b _ => hint_ijab i j a b]
          refine Finset.sum_congr rfl fun j _ => ?_
          rw [integral_finsetSum _ fun a _ => integrable_finsetSum _ fun b _ => hint_ijab i j a b]
          exact Finset.sum_congr rfl fun a _ => integral_finsetSum _ fun b _ => hint_ijab i j a b
      _ = ∑ i, ∑ j ∈ Finset.univ.erase i, 2 * v ^ 2 * Q i j ^ 2 :=
          Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j hj => hinner i j hj
      _ = 2 * v ^ 2 * ∑ i, ∑ j ∈ Finset.univ.erase i, Q i j ^ 2 := by
          rw [Finset.mul_sum]
          refine Finset.sum_congr rfl fun i _ => ?_
          rw [Finset.mul_sum]
  -- Combine variance bound
  have hvar : variance X P ≤ (1 / 4 : ℝ) * ∑ i, ∑ j, Q i j ^ 2 := by
    rw [variance_eq_integral hXmeas.aemeasurable]
    have hsq_eq : (fun y => (X y - ∫ z, X z ∂P) ^ 2) =
        fun y => D y ^ 2 + 2 * D y * O y + O y ^ 2 := by
      ext y; rw [hsplit y]; ring
    have hint_D_DO : Integrable (fun y => D y ^ 2 + 2 * D y * O y) P := hD2_int.add hDO_int
    rw [hsq_eq, integral_add hint_D_DO hO2_int, integral_add hD2_int hDO_int,
      hED2, hEDO, hEO2, add_zero]
    have hv0 : 0 < v := mul_pos hτ.1 (sub_pos.mpr hτ.2)
    have hv4 : v ≤ 1 / 4 := by
      have : (τ - 1 / 2) ^ 2 ≥ 0 := sq_nonneg _
      change τ * (1 - τ) ≤ 1 / 4
      linarith
    have hc1 : v * (1 - 4 * v) ≤ 1 / 4 := by
      have : (v - 1 / 8) ^ 2 ≥ 0 := sq_nonneg _
      nlinarith
    have hc2 : 2 * v ^ 2 ≤ 1 / 4 := by nlinarith
    have hdiag_nonneg : 0 ≤ ∑ i, Q i i ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
    have hoff_nonneg : 0 ≤ ∑ i, ∑ j ∈ Finset.univ.erase i, Q i j ^ 2 :=
      Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _
    have hfrob : (∑ i, Q i i ^ 2) + (∑ i, ∑ j ∈ Finset.univ.erase i, Q i j ^ 2) =
        ∑ i, ∑ j, Q i j ^ 2 := by
      rw [← Finset.sum_add_distrib]
      refine Finset.sum_congr rfl fun i _ => Finset.add_sum_erase Finset.univ (fun j => Q i j ^ 2)
        (Finset.mem_univ i)
    calc v * (1 - 4 * v) * (∑ i, Q i i ^ 2) +
          2 * v ^ 2 * (∑ i, ∑ j ∈ Finset.univ.erase i, Q i j ^ 2)
        ≤ (1 / 4 : ℝ) * (∑ i, Q i i ^ 2) +
          (1 / 4 : ℝ) * (∑ i, ∑ j ∈ Finset.univ.erase i, Q i j ^ 2) := by
          gcongr
      _ = (1 / 4 : ℝ) * ∑ i, ∑ j, Q i j ^ 2 := by rw [← mul_add, hfrob]
  exact ⟨hXmem, hmean, hvar⟩

/-! ### Hoeffding bound for a linear combination of independent scores -/

private lemma hoeffding_linear_score {n : ℕ} {τ L fl fu : ℝ}
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (hc : ∀ i, CoordHyp (μ i) τ (θs i) L fl fu)
    (w : Fin n → ℝ) {ε : ℝ} (hε : 0 ≤ ε) :
    Measure.pi μ {y | ε < |dot w (score τ (y - θs))|} ≤
      ENNReal.ofReal (if l2sq w = 0 then 0 else 2 * Real.exp (-2 * ε ^ 2 / l2sq w)) := by
  have hprob : ∀ i, IsProbabilityMeasure (μ i) := fun i => (hc i).prob
  let P := Measure.pi μ
  by_cases hw : l2sq w = 0
  · simp only [hw, ↓reduceIte]
    have hw0 : ∀ i, w i = 0 := by
      intro i
      have hle : w i ^ 2 ≤ l2sq w :=
        Finset.single_le_sum (fun j _ => sq_nonneg (w j)) (Finset.mem_univ i)
      have hsq0 : w i ^ 2 = 0 := le_antisymm (hw ▸ hle) (sq_nonneg _)
      exact sq_eq_zero_iff.mp hsq0
    have hempty : {y : Fin n → ℝ | ε < |dot w (score τ (y - θs))|} = ∅ := by
      ext y
      simp only [Set.mem_ofPred_eq, Set.mem_empty_iff_false, iff_false, not_lt]
      have hd0 : dot w (score τ (y - θs)) = 0 := by
        simp [dot, hw0]
      rw [hd0, abs_zero]
      exact hε
    simp [hempty]
  · simp only [hw, ↓reduceIte]
    have hw_pos : 0 < l2sq w := lt_of_le_of_ne (Finset.sum_nonneg fun i _ => sq_nonneg _) (Ne.symm hw)
    have hone_side : ∀ a : Fin n → ℝ, l2sq a = l2sq w →
        P.real {y | ε ≤ ∑ i, a i * score τ (y - θs) i} ≤
          Real.exp (-2 * ε ^ 2 / l2sq w) := by
      intro a ha_sq
      let X : Fin n → (Fin n → ℝ) → ℝ := fun i y => a i * score τ (y - θs) i
      have hindep : iIndepFun X P :=
        iIndepFun_pi (X := fun i x => a i * scoreZ τ (x - θs i))
          (fun i => (measurable_const.mul
            ((measurable_scoreZ τ).comp (measurable_id.sub measurable_const))).aemeasurable)
      let c : Fin n → NNReal := fun i => ⟨a i ^ 2 / 4, by positivity⟩
      have hsubG : ∀ i ∈ Finset.univ, HasSubgaussianMGF (X i) (c i) P := by
        intro i _
        have hXmeas : AEMeasurable (X i) P :=
          (measurable_const.mul (measurable_score_coord τ θs i)).aemeasurable
        have hmean0 : P[X i] = 0 := by
          change ∫ y, a i * scoreZ τ (y i - θs i) ∂P = 0
          rw [integral_const_mul, integral_pi_eval i (fun x => scoreZ τ (x - θs i)),
            integral_scoreZ_eq_zero (hc i), mul_zero]
        have hmem : ∀ᵐ y ∂P, X i y ∈ Set.Icc (min (a i * (τ - 1)) (a i * τ))
            (max (a i * (τ - 1)) (a i * τ)) := by
          refine Filter.Eventually.of_forall fun y => ?_
          simp only [X, score, Set.mem_Icc]
          split_ifs
          · exact ⟨min_le_left _ _, le_max_left _ _⟩
          · rw [sub_zero]; exact ⟨min_le_right _ _, le_max_right _ _⟩
        have hsg := hasSubgaussianMGF_of_mem_Icc_of_integral_eq_zero hXmeas hmem hmean0
        have hc_eq : (‖max (a i * (τ - 1)) (a i * τ) - min (a i * (τ - 1)) (a i * τ)‖₊ / 2) ^ 2 =
            c i := by
          ext
          simp only [NNReal.coe_pow, NNReal.coe_div, NNReal.coe_ofNat, coe_nnnorm,
            Real.norm_eq_abs, c]
          have hdiff : max (a i * (τ - 1)) (a i * τ) - min (a i * (τ - 1)) (a i * τ) = |a i| := by
            rcases le_total 0 (a i) with ha0 | ha0
            · rw [max_eq_right (by nlinarith), min_eq_left (by nlinarith), abs_of_nonneg ha0]; ring
            · rw [max_eq_left (by nlinarith), min_eq_right (by nlinarith), abs_of_nonpos ha0]; ring
          rw [hdiff, abs_abs, div_pow, sq_abs]
          change a i ^ 2 / 2 ^ 2 = a i ^ 2 / 4
          ring
        rwa [hc_eq] at hsg
      have hhoeff := HasSubgaussianMGF.measure_sum_ge_le_of_iIndepFun hindep hsubG hε
      have hcsum : (2 : ℝ) * ((∑ i : Fin n, c i : NNReal) : ℝ) = l2sq w / 2 := by
        rw [NNReal.coe_sum]
        have hsum_eq : (∑ i : Fin n, (c i : ℝ)) = l2sq a / 4 := by
          change ∑ i : Fin n, a i ^ 2 / 4 = (∑ i : Fin n, a i ^ 2) / 4
          rw [Finset.sum_div]
        rw [hsum_eq, ha_sq]
        ring
      have harg : -ε ^ 2 / (2 * ((∑ i : Fin n, c i : NNReal) : ℝ)) = -2 * ε ^ 2 / l2sq w := by
        rw [hcsum]; field_simp
      rw [harg] at hhoeff
      exact hhoeff
    have hpos_bound := hone_side w rfl
    have hneg_bound := hone_side (-w) (by simp [l2sq])
    have hsub : {y : Fin n → ℝ | ε < |dot w (score τ (y - θs))|} ⊆
        {y | ε ≤ ∑ i, w i * score τ (y - θs) i} ∪
        {y | ε ≤ ∑ i, (-w) i * score τ (y - θs) i} := by
      intro y hy
      simp only [Set.mem_ofPred_eq, dot] at hy
      simp only [Set.mem_union, Set.mem_ofPred_eq, Pi.neg_apply, neg_mul, Finset.sum_neg_distrib]
      rcases le_total 0 (∑ i, w i * score τ (y - θs) i) with h0 | h0
      · left; rw [abs_of_nonneg h0] at hy; exact hy.le
      · right; rw [abs_of_nonpos h0] at hy; exact hy.le
    calc P {y | ε < |dot w (score τ (y - θs))|}
        ≤ P ({y | ε ≤ ∑ i, w i * score τ (y - θs) i} ∪
            {y | ε ≤ ∑ i, (-w) i * score τ (y - θs) i}) := measure_mono hsub
      _ ≤ P {y | ε ≤ ∑ i, w i * score τ (y - θs) i} +
          P {y | ε ≤ ∑ i, (-w) i * score τ (y - θs) i} := measure_union_le _ _
      _ = ENNReal.ofReal (P.real {y | ε ≤ ∑ i, w i * score τ (y - θs) i}) +
          ENNReal.ofReal (P.real {y | ε ≤ ∑ i, (-w) i * score τ (y - θs) i}) := by
          simp only [Measure.real]
          rw [ENNReal.ofReal_toReal (measure_ne_top P _),
            ENNReal.ofReal_toReal (measure_ne_top P _)]
      _ ≤ ENNReal.ofReal (Real.exp (-2 * ε ^ 2 / l2sq w)) +
          ENNReal.ofReal (Real.exp (-2 * ε ^ 2 / l2sq w)) :=
          add_le_add (ENNReal.ofReal_le_ofReal hpos_bound) (ENNReal.ofReal_le_ofReal hneg_bound)
      _ = ENNReal.ofReal (2 * Real.exp (-2 * ε ^ 2 / l2sq w)) := by
          rw [← ENNReal.ofReal_add (Real.exp_nonneg _) (Real.exp_nonneg _), two_mul]

/-! ### Main theorem -/

/-- Lemma `pf:lem:score`: for every `1 ≤ J ≤ m`,
`P(Ω_ζ(J)ᶜ) ≤ 4/(9(J + r)) + 1/(2n) + 8r/(3J)`. -/
theorem score_events (k : ℕ) (hk : 1 ≤ k) (n : ℕ) (hn : k + 1 < n) (J : ℕ) (hJpos : 1 ≤ J)
    (hJm : J ≤ n - (k + 1)) (τ L fl fu Vb : ℝ) (hτ : 0 < τ ∧ τ < 1) (hL : 0 < L) (hfl : 0 < fl)
    (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (h : DataHyp k n τ μ θs L fl fu Vb) :
    Measure.pi μ (OmegaZeta (k + 1) n J τ θs)ᶜ ≤
      ENNReal.ofReal (4 / (9 * (J + (k + 1 : ℝ))) + 1 / (2 * n) + 8 * (k + 1 : ℝ) / (3 * J)) := by
  have hprob : ∀ i, IsProbabilityMeasure (μ i) := h.prob
  let r : ℕ := k + 1
  have hr2 : 2 ≤ r := by omega
  have hr1 : 1 ≤ r := by omega
  have hr_pos : (0 : ℝ) < r := by positivity
  let m : ℕ := n - r
  have hm_pos : 1 ≤ m := by omega
  have hm_posR : (0 : ℝ) < m := by positivity
  have hn_posR : (0 : ℝ) < n := by exact_mod_cast (by omega : 0 < n)
  have hJ_posR : (0 : ℝ) < J := by positivity
  let hval : ℕ := hJ m J
  have hh_ge1 : 1 ≤ hval := Nat.div_pos (by omega) (by omega)
  have hh_posR : (0 : ℝ) < hval := by positivity
  have hh_le_2m : (hval : ℝ) ≤ 2 * (m : ℝ) / (J : ℝ) := by
    have hnat : hval * J ≤ 2 * m := by
      have h1 : hval * J ≤ m + J - 1 := Nat.div_mul_le_self (m + J - 1) J
      omega
    have hreal : (hval : ℝ) * (J : ℝ) ≤ 2 * (m : ℝ) := by exact_mod_cast hnat
    exact (le_div_iff₀ hJ_posR).mpr hreal
  have hcoord : ∀ i, CoordHyp (μ i) τ (θs i) L fl fu := fun i =>
    ⟨h.prob i, hτ, h.quantile i, hL, hfl, h.assA i, h.assB i⟩
  have hJ_info := hJ_le r n J hn hJpos hJm
  have hsp := spline_approx r n J hr2 hn hJpos hJm
  have hcInf_pos : 0 < cInf r := by
    unfold cInf
    exact div_pos (mul_pos (by positivity) (pow_pos (by positivity) _))
      (Nat.cast_pos.mpr (Nat.factorial_pos _))
  have hcF_pos : 0 < cF r := by
    unfold cF
    exact mul_pos (Real.sqrt_pos.mpr hr_pos) hcInf_pos
  have hv_le : τ * (1 - τ) ≤ 1 / 4 := by
    have : (τ - 1 / 2) ^ 2 ≥ 0 := sq_nonneg _
    linarith
  have hv_nonneg : 0 ≤ τ * (1 - τ) := mul_nonneg hτ.1.le (sub_nonneg.mpr hτ.2.le)
  have hrpow_sq : ((hval : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 = (hval : ℝ) ^ (2 * r - 1 : ℕ) := by
    rw [← Real.rpow_natCast ((hval : ℝ) ^ ((r : ℝ) - 1 / 2)) 2, ← Real.rpow_mul hh_posR.le]
    have hexp : ((r : ℝ) - 1 / 2) * (2 : ℕ) = ((2 * r - 1 : ℕ) : ℝ) := by
      rw [Nat.cast_sub (by omega : 1 ≤ 2 * r)]
      push_cast; ring
    rw [hexp, Real.rpow_natCast]
  -- Split `OmegaZetaᶜ` into three bad events
  let E1 : Set (Fin n → ℝ) := {y | (J + r : ℝ) < l2sq (PJ r n J (score τ (y - θs)))}
  let E2 : Set (Fin n → ℝ) := {y | ∃ j : Fin m,
    cF r * (hval : ℝ) ^ ((r : ℝ) - 1 / 2) * Real.sqrt (Real.log (2 * n)) <
      |tScore r n J (score τ (y - θs)) j|}
  let E3 : Set (Fin n → ℝ) := {y |
    cF r ^ 2 * (m : ℝ) * (hval : ℝ) ^ (2 * r - 1) < l2sq (tScore r n J (score τ (y - θs)))}
  have hsub_union : (OmegaZeta r n J τ θs)ᶜ ⊆ E1 ∪ E2 ∪ E3 := by
    intro y hy
    simp only [Set.mem_compl_iff, OmegaZeta, Set.mem_ofPred_eq, not_and_or, not_le, not_forall] at hy
    rcases hy with h1 | h2 | h3
    · exact Or.inl (Or.inl h1)
    · exact Or.inl (Or.inr h2)
    · exact Or.inr h3
  -- Bound 1: P(E1) ≤ 4 / (9 * (J + r))
  have hE1 : Measure.pi μ E1 ≤ ENNReal.ofReal (4 / (9 * (J + (r : ℝ)))) := by
    let Q : Fin n → Fin n → ℝ := projMat (VJ r n J)
    have hQsymm : ∀ i j, Q i j = Q j i := projMat_symm (VJ r n J)
    have hq := quadForm_mean_and_var hτ hcoord Q hQsymm
    let X : (Fin n → ℝ) → ℝ := fun y => ∑ i, ∑ j, Q i j * score τ (y - θs) i * score τ (y - θs) j
    have hX_eq : ∀ y, l2sq (PJ r n J (score τ (y - θs))) = X y := fun y =>
      l2sq_orthProj_eq_quadForm (VJ r n J) (score τ (y - θs))
    have htr : ∑ i, Q i i = (Module.finrank ℝ (VJ r n J) : ℝ) := sum_projMat_diag (VJ r n J)
    have htr_le : ∑ i, Q i i ≤ (J + r : ℝ) := by
      rw [htr]; exact_mod_cast hJ_info.2.2
    have htr_nonneg : 0 ≤ ∑ i, Q i i := by rw [htr]; positivity
    have hfrob : ∑ i, ∑ j, Q i j ^ 2 = ∑ i, Q i i :=
      Finset.sum_congr rfl fun i _ => projMat_sq_sum (VJ r n J) i
    have hmean_le : ∫ y, X y ∂(Measure.pi μ) ≤ (1 / 4 : ℝ) * (J + r : ℝ) := by
      rw [hq.2.1]
      nlinarith
    have hvar_le : variance X (Measure.pi μ) ≤ (1 / 4 : ℝ) * (J + r : ℝ) := by
      calc variance X (Measure.pi μ) ≤ (1 / 4 : ℝ) * ∑ i, ∑ j, Q i j ^ 2 := hq.2.2
        _ = (1 / 4 : ℝ) * ∑ i, Q i i := by rw [hfrob]
        _ ≤ (1 / 4 : ℝ) * (J + r : ℝ) := by linarith
    have hc_pos : 0 < (3 / 4 : ℝ) * (J + r : ℝ) := by positivity
    have hsub1 : E1 ⊆ {y | (3 / 4 : ℝ) * (J + r : ℝ) ≤ |X y - (Measure.pi μ)[X]|} := by
      intro y hy
      simp only [E1, Set.mem_ofPred_eq, hX_eq y] at hy
      simp only [Set.mem_ofPred_eq]
      exact le_trans (by linarith) (le_abs_self _)
    calc Measure.pi μ E1
        ≤ Measure.pi μ {y | (3 / 4 : ℝ) * (J + r : ℝ) ≤ |X y - (Measure.pi μ)[X]|} :=
          measure_mono hsub1
      _ ≤ ENNReal.ofReal (variance X (Measure.pi μ) / ((3 / 4 : ℝ) * (J + r : ℝ)) ^ 2) :=
          meas_ge_le_variance_div_sq hq.1 hc_pos
      _ ≤ ENNReal.ofReal (4 / (9 * (J + (r : ℝ)))) := by
          apply ENNReal.ofReal_le_ofReal
          have hJr_pos : (0 : ℝ) < (J : ℝ) + (r : ℝ) := by positivity
          calc variance X (Measure.pi μ) / ((3 / 4 : ℝ) * (J + r : ℝ)) ^ 2
              ≤ ((1 / 4 : ℝ) * (J + r : ℝ)) / ((3 / 4 : ℝ) * (J + r : ℝ)) ^ 2 :=
                div_le_div_of_nonneg_right hvar_le (sq_nonneg _)
            _ = 4 / (9 * (J + (r : ℝ))) := by field_simp; ring
  -- Bound 2: P(E2) ≤ 1 / (2 * n)
  have hE2 : Measure.pi μ E2 ≤ ENNReal.ofReal (1 / (2 * (n : ℝ))) := by
    let ε : ℝ := cF r * (hval : ℝ) ^ ((r : ℝ) - 1 / 2) * Real.sqrt (Real.log (2 * n))
    have h2n_ge1 : (1 : ℝ) ≤ 2 * (n : ℝ) := by
      have : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : 1 ≤ n)
      linarith
    have hlog_nonneg : 0 ≤ Real.log (2 * (n : ℝ)) := Real.log_nonneg h2n_ge1
    have hε_nonneg : 0 ≤ ε := by positivity
    have hE2_eq : E2 = ⋃ j : Fin m, {y | ε < |tScore r n J (score τ (y - θs)) j|} := by
      ext y; simp [E2, ε]
    have hper_j : ∀ j : Fin m,
        Measure.pi μ {y | ε < |tScore r n J (score τ (y - θs)) j|} ≤
          ENNReal.ofReal (1 / (2 * (n : ℝ) ^ 2)) := by
      intro j
      let w : Fin n → ℝ := sCol r n j - PJ r n J (sCol r n j)
      have hhoeff := hoeffding_linear_score hcoord w hε_nonneg
      refine le_trans hhoeff (ENNReal.ofReal_le_ofReal ?_)
      split_ifs with hw0
      · positivity
      · have hw_pos : 0 < l2sq w :=
          lt_of_le_of_ne (Finset.sum_nonneg fun i _ => sq_nonneg _) (Ne.symm hw0)
        have hnorm_le : l2norm w ≤ cF r * (hval : ℝ) ^ ((r : ℝ) - 1 / 2) := hsp.1 j
        have hsq_le : l2sq w ≤ (cF r * (hval : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 := by
          have h1 := pow_le_pow_left₀ (Real.sqrt_nonneg _) hnorm_le 2
          rwa [Real.sq_sqrt (show 0 ≤ l2sq w from Finset.sum_nonneg fun i _ => sq_nonneg _)] at h1
        have hε_sq : ε ^ 2 = (cF r * (hval : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 * Real.log (2 * n) := by
          simp only [ε, mul_pow, Real.sq_sqrt hlog_nonneg]
        have hratio : 2 * Real.log (2 * (n : ℝ)) ≤ 2 * ε ^ 2 / l2sq w := by
          rw [le_div_iff₀ hw_pos, hε_sq]
          calc 2 * Real.log (2 * (n : ℝ)) * l2sq w
              ≤ 2 * Real.log (2 * (n : ℝ)) * (cF r * (hval : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 := by
                gcongr
            _ = 2 * ((cF r * (hval : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 * Real.log (2 * (n : ℝ))) := by
                ring
        have hexp_le : Real.exp (-2 * ε ^ 2 / l2sq w) ≤ 1 / (4 * (n : ℝ) ^ 2) := by
          have h1 : -2 * ε ^ 2 / l2sq w ≤ -(2 * Real.log (2 * (n : ℝ))) := by
            rw [neg_mul, neg_div]
            linarith
          calc Real.exp (-2 * ε ^ 2 / l2sq w)
              ≤ Real.exp (-(2 * Real.log (2 * (n : ℝ)))) := Real.exp_le_exp.mpr h1
            _ = (Real.exp (Real.log (2 * (n : ℝ)))) ^ (-(2 : ℤ)) := by
                rw [Real.exp_neg, zpow_neg, zpow_ofNat, ← Real.exp_nat_mul]; norm_num
            _ = (2 * (n : ℝ)) ^ (-(2 : ℤ)) := by rw [Real.exp_log (by positivity)]
            _ = 1 / (4 * (n : ℝ) ^ 2) := by
                rw [zpow_neg, zpow_ofNat, one_div]; ring
        calc 2 * Real.exp (-2 * ε ^ 2 / l2sq w)
            ≤ 2 * (1 / (4 * (n : ℝ) ^ 2)) := by linarith
          _ = 1 / (2 * (n : ℝ) ^ 2) := by ring
    rw [hE2_eq]
    calc Measure.pi μ (⋃ j : Fin m, {y | ε < |tScore r n J (score τ (y - θs)) j|})
        ≤ ∑ j : Fin m, Measure.pi μ {y | ε < |tScore r n J (score τ (y - θs)) j|} :=
          measure_iUnion_fintype_le _ _
      _ ≤ ∑ _j : Fin m, ENNReal.ofReal (1 / (2 * (n : ℝ) ^ 2)) :=
          Finset.sum_le_sum fun j _ => hper_j j
      _ = ENNReal.ofReal ((m : ℝ) * (1 / (2 * (n : ℝ) ^ 2))) := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
            ENNReal.ofReal_mul (Nat.cast_nonneg _), ENNReal.ofReal_natCast]
      _ ≤ ENNReal.ofReal (1 / (2 * (n : ℝ))) := by
          apply ENNReal.ofReal_le_ofReal
          have hmn : (m : ℝ) ≤ (n : ℝ) := by exact_mod_cast (Nat.sub_le n r)
          calc (m : ℝ) * (1 / (2 * (n : ℝ) ^ 2))
              ≤ (n : ℝ) * (1 / (2 * (n : ℝ) ^ 2)) := by gcongr
            _ = 1 / (2 * (n : ℝ)) := by field_simp
  -- Bound 3: P(E3) ≤ 8 * r / (3 * J)
  have hE3 : Measure.pi μ E3 ≤ ENNReal.ofReal (8 * (r : ℝ) / (3 * (J : ℝ))) := by
    let w : Fin m → Fin n → ℝ := fun j => sCol r n j - PJ r n J (sCol r n j)
    let Q : Fin n → Fin n → ℝ := fun i i' => ∑ j : Fin m, w j i * w j i'
    have hQsymm : ∀ i i', Q i i' = Q i' i := fun i i' =>
      Finset.sum_congr rfl fun j _ => mul_comm _ _
    have hq := quadForm_mean_and_var hτ hcoord Q hQsymm
    let X : (Fin n → ℝ) → ℝ := fun y => ∑ i, ∑ i', Q i i' * score τ (y - θs) i * score τ (y - θs) i'
    have hX_eq : ∀ y, l2sq (tScore r n J (score τ (y - θs))) = X y := by
      intro y
      simp only [l2sq, tScore, dot, sq, X, Q, w]
      calc ∑ j : Fin m, (∑ i, (sCol r n j - PJ r n J (sCol r n j)) i * score τ (y - θs) i) *
            (∑ i', (sCol r n j - PJ r n J (sCol r n j)) i' * score τ (y - θs) i')
          = ∑ j : Fin m, ∑ i, ∑ i',
              ((sCol r n j - PJ r n J (sCol r n j)) i * (sCol r n j - PJ r n J (sCol r n j)) i') *
                score τ (y - θs) i * score τ (y - θs) i' := by
            refine Finset.sum_congr rfl fun j _ => ?_
            simp only [Finset.sum_mul, Finset.mul_sum]
            refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun i' _ => by ring
        _ = ∑ i, ∑ i', ∑ j : Fin m,
              ((sCol r n j - PJ r n J (sCol r n j)) i * (sCol r n j - PJ r n J (sCol r n j)) i') *
                score τ (y - θs) i * score τ (y - θs) i' := by
            rw [Finset.sum_comm]
            refine Finset.sum_congr rfl fun i _ => Finset.sum_comm
        _ = ∑ i, ∑ i', (∑ j : Fin m,
              (sCol r n j - PJ r n J (sCol r n j)) i * (sCol r n j - PJ r n J (sCol r n j)) i') *
              score τ (y - θs) i * score τ (y - θs) i' := by
            refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun i' _ => ?_
            simp only [Finset.sum_mul]
    let b : ℝ := cF r ^ 2 * (m : ℝ) * (hval : ℝ) ^ (2 * r - 1)
    have hb_pos : 0 < b := by positivity
    have htr_le : ∑ i, Q i i ≤ b := by
      have hswap : ∑ i, Q i i = ∑ j : Fin m, l2sq (w j) := by
        simp only [Q, l2sq, sq]
        rw [Finset.sum_comm]
      rw [hswap]
      have hper : ∀ j : Fin m, l2sq (w j) ≤ cF r ^ 2 * (hval : ℝ) ^ (2 * r - 1) := by
        intro j
        have h1 := pow_le_pow_left₀ (Real.sqrt_nonneg _) (hsp.1 j) 2
        rw [Real.sq_sqrt (show 0 ≤ l2sq (w j) from Finset.sum_nonneg fun i _ => sq_nonneg _),
          mul_pow, hrpow_sq] at h1
        exact h1
      calc ∑ j : Fin m, l2sq (w j)
          ≤ ∑ _j : Fin m, (cF r ^ 2 * (hval : ℝ) ^ (2 * r - 1)) :=
            Finset.sum_le_sum fun j _ => hper j
        _ = b := by simp [b]; ring
    have htr_nonneg : 0 ≤ ∑ i, Q i i :=
      Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_self_nonneg _
    have hfrob_le : ∑ i, ∑ i', Q i i' ^ 2 ≤ (cOp r * (hval : ℝ) ^ r) ^ 2 * b := by
      have hrow : ∀ i : Fin n,
          ∑ i', Q i i' ^ 2 ≤ (cOp r * (hval : ℝ) ^ r) ^ 2 * Q i i := by
        intro i
        let u : Fin m → ℝ := fun j => w j i
        have hWu : ∀ i', (Smul r n u - PJ r n J (Smul r n u)) i' = Q i i' := by
          intro i'
          have hSmul : Smul r n u = ∑ j : Fin m, u j • sCol r n j := by
            ext l; simp [Smul, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]; rfl
          rw [hSmul, map_sum]
          simp only [Pi.sub_apply, Finset.sum_apply, map_smul, Pi.smul_apply, smul_eq_mul, Q, u, w]
          rw [← Finset.sum_sub_distrib]
          refine Finset.sum_congr rfl fun j _ => by ring
        have hop := pow_le_pow_left₀ (Real.sqrt_nonneg _) (hsp.2 u) 2
        rw [Real.sq_sqrt (show 0 ≤ l2sq (Smul r n u - PJ r n J (Smul r n u)) from
            Finset.sum_nonneg fun l _ => sq_nonneg _), mul_pow] at hop
        have hlu : l2norm u ^ 2 = l2sq u :=
          Real.sq_sqrt (show 0 ≤ l2sq u from Finset.sum_nonneg fun j _ => sq_nonneg _)
        rw [hlu] at hop
        have hlhs : l2sq (Smul r n u - PJ r n J (Smul r n u)) = ∑ i', Q i i' ^ 2 := by
          simp only [l2sq]; exact Finset.sum_congr rfl fun i' _ => by rw [hWu i']
        have hrhs : l2sq u = Q i i := by
          simp only [l2sq, Q, u, sq]
        rwa [hlhs, hrhs] at hop
      calc ∑ i, ∑ i', Q i i' ^ 2
          ≤ ∑ i, (cOp r * (hval : ℝ) ^ r) ^ 2 * Q i i := Finset.sum_le_sum fun i _ => hrow i
        _ = (cOp r * (hval : ℝ) ^ r) ^ 2 * ∑ i, Q i i := by rw [← Finset.mul_sum]
        _ ≤ (cOp r * (hval : ℝ) ^ r) ^ 2 * b := by
            exact mul_le_mul_of_nonneg_left htr_le (sq_nonneg _)
    have hmean_le : ∫ y, X y ∂(Measure.pi μ) ≤ (1 / 4 : ℝ) * b := by
      rw [hq.2.1]; nlinarith
    have hvar_le : variance X (Measure.pi μ) ≤ (1 / 4 : ℝ) * (cOp r * (hval : ℝ) ^ r) ^ 2 * b := by
      calc variance X (Measure.pi μ)
          ≤ (1 / 4 : ℝ) * ∑ i, ∑ i', Q i i' ^ 2 := hq.2.2
        _ ≤ (1 / 4 : ℝ) * ((cOp r * (hval : ℝ) ^ r) ^ 2 * b) := by gcongr
        _ = (1 / 4 : ℝ) * (cOp r * (hval : ℝ) ^ r) ^ 2 * b := by ring
    have hc_pos : 0 < (3 / 4 : ℝ) * b := by positivity
    have hsub3 : E3 ⊆ {y | (3 / 4 : ℝ) * b ≤ |X y - (Measure.pi μ)[X]|} := by
      intro y hy
      simp only [E3, Set.mem_ofPred_eq, hX_eq y] at hy
      simp only [Set.mem_ofPred_eq]
      exact le_trans (by linarith) (le_abs_self _)
    calc Measure.pi μ E3
        ≤ Measure.pi μ {y | (3 / 4 : ℝ) * b ≤ |X y - (Measure.pi μ)[X]|} := measure_mono hsub3
      _ ≤ ENNReal.ofReal (variance X (Measure.pi μ) / ((3 / 4 : ℝ) * b) ^ 2) :=
          meas_ge_le_variance_div_sq hq.1 hc_pos
      _ ≤ ENNReal.ofReal (8 * (r : ℝ) / (3 * (J : ℝ))) := by
          apply ENNReal.ofReal_le_ofReal
          have hcOp_sq : cOp r ^ 2 = 3 * (r : ℝ) ^ 2 * cInf r ^ 2 := by
            unfold cOp; rw [mul_pow, mul_pow, Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 3)]
          have hcF_sq : cF r ^ 2 = (r : ℝ) * cInf r ^ 2 := by
            unfold cF; rw [mul_pow, Real.sq_sqrt hr_pos.le]
          have hh_pow : (hval : ℝ) ^ (2 * r - 1) * (hval : ℝ) = ((hval : ℝ) ^ r) ^ 2 := by
            rw [← pow_succ, ← pow_mul]
            congr 1; omega
          have hsimp : ((1 / 4 : ℝ) * (cOp r * (hval : ℝ) ^ r) ^ 2 * b) / ((3 / 4 : ℝ) * b) ^ 2 =
              4 * (r : ℝ) * (hval : ℝ) / (3 * (m : ℝ)) := by
            have h1 : ((1 / 4 : ℝ) * (cOp r * (hval : ℝ) ^ r) ^ 2 * b) / ((3 / 4 : ℝ) * b) ^ 2 =
                4 * (cOp r ^ 2 * ((hval : ℝ) ^ r) ^ 2) / (9 * b) := by
              rw [mul_pow]; field_simp; ring
            rw [h1, hcOp_sq, ← hh_pow]
            simp only [b, hcF_sq]
            have hh_pow_ne : (hval : ℝ) ^ (2 * r - 1) ≠ 0 := pow_ne_zero _ hh_posR.ne'
            field_simp [hcInf_pos.ne', hr_pos.ne', hm_posR.ne', hh_pow_ne]
            ring
          calc variance X (Measure.pi μ) / ((3 / 4 : ℝ) * b) ^ 2
              ≤ ((1 / 4 : ℝ) * (cOp r * (hval : ℝ) ^ r) ^ 2 * b) / ((3 / 4 : ℝ) * b) ^ 2 :=
                div_le_div_of_nonneg_right hvar_le (sq_nonneg _)
            _ = 4 * (r : ℝ) * (hval : ℝ) / (3 * (m : ℝ)) := hsimp
            _ ≤ 4 * (r : ℝ) * (2 * (m : ℝ) / (J : ℝ)) / (3 * (m : ℝ)) := by gcongr
            _ = 8 * (r : ℝ) / (3 * (J : ℝ)) := by field_simp; ring
  -- Final union bound
  have hnn1 : 0 ≤ 4 / (9 * (J + (r : ℝ))) := by positivity
  have hnn2 : 0 ≤ 1 / (2 * (n : ℝ)) := by positivity
  have hnn3 : 0 ≤ 8 * (r : ℝ) / (3 * (J : ℝ)) := by positivity
  have hr_cast : (r : ℝ) = (k + 1 : ℝ) := by simp [r]
  calc Measure.pi μ (OmegaZeta (k + 1) n J τ θs)ᶜ
      ≤ Measure.pi μ (E1 ∪ E2 ∪ E3) := measure_mono hsub_union
    _ ≤ Measure.pi μ (E1 ∪ E2) + Measure.pi μ E3 := measure_union_le _ _
    _ ≤ Measure.pi μ E1 + Measure.pi μ E2 + Measure.pi μ E3 :=
        add_le_add (measure_union_le _ _) le_rfl
    _ ≤ ENNReal.ofReal (4 / (9 * (J + (r : ℝ)))) + ENNReal.ofReal (1 / (2 * (n : ℝ))) +
          ENNReal.ofReal (8 * (r : ℝ) / (3 * (J : ℝ))) :=
        add_le_add (add_le_add hE1 hE2) hE3
    _ = ENNReal.ofReal (4 / (9 * (J + (k + 1 : ℝ))) + 1 / (2 * n) + 8 * (k + 1 : ℝ) / (3 * J)) := by
        rw [← ENNReal.ofReal_add hnn1 hnn2, ← ENNReal.ofReal_add (add_nonneg hnn1 hnn2) hnn3,
          hr_cast]

end BQTF
