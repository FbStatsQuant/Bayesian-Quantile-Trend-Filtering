import BQTF.Basic

/-!
# The Gram constant `g_r` (appendix, before Lemma `pf:lem:smooth`)

Owner: Neon-A. `G_w = w⁻¹ ∑_{k<w} b(k/w) b(k/w)ᵀ`, `b(x) = (1, x, …, x^{r−1})`,
`g_r = inf_{w ≥ r} λ_min(G_w) ∈ (0, 1]`, `C_s = 1 + r/g_r`.

The appendix asserts `g_r > 0` without proof; Theory's proof (theory/T10_gr_positivity/NOTE.md):
each `G_w` is positive definite (root counting), `G_w` is within `r/w` of the Hilbert matrix
`H = ∫_0^1 b bᵀ` in Frobenius norm (Riemann sums), and `H` is positive definite. `λ_min` is the
minimum of the quadratic form on unit vectors (`quadMin`).
-/

open Finset

noncomputable section

namespace BQTF

/-- `v ↦ vᵀ G_w v = w⁻¹ ∑_{k<w} (∑_a v_a (k/w)^a)²`. -/
def gramQuad (r w : ℕ) (v : Fin r → ℝ) : ℝ :=
  (∑ k ∈ range w, (∑ a : Fin r, v a * ((k : ℝ) / w) ^ (a : ℕ)) ^ 2) / w

/-- `λ_min(G_w) = min_{‖v‖₂ = 1} vᵀ G_w v`. -/
def quadMin (r w : ℕ) : ℝ := ⨅ v : {v : Fin r → ℝ // l2sq v = 1}, gramQuad r w v

/-- `g_r = inf_{w ≥ r} λ_min(G_w)`. -/
def gr (r : ℕ) : ℝ := ⨅ w : {w : ℕ // r ≤ w}, quadMin r w

/-- `C_s = 1 + r/g_r`. -/
def Cs (r : ℕ) : ℝ := 1 + r / gr r

private def polyOfVec (r : ℕ) (v : Fin r → ℝ) : Polynomial ℝ :=
  ∑ a : Fin r, Polynomial.C (v a) * Polynomial.X ^ (a : ℕ)

private lemma polyOfVec_eval (r : ℕ) (v : Fin r → ℝ) (x : ℝ) :
    (polyOfVec r v).eval x = ∑ a : Fin r, v a * x ^ (a : ℕ) := by
  simp [polyOfVec, Polynomial.eval_finsetSum]

private lemma polyOfVec_coeff_lt (r : ℕ) (v : Fin r → ℝ) (a : Fin r) :
    (polyOfVec r v).coeff (a : ℕ) = v a := by
  simp [polyOfVec, Polynomial.finsetSum_coeff, Fin.val_inj]

private lemma polyOfVec_coeff_ge (r : ℕ) (v : Fin r → ℝ) (k : ℕ) (hk : r ≤ k) :
    (polyOfVec r v).coeff k = 0 := by
  simp only [polyOfVec, Polynomial.finsetSum_coeff, Polynomial.coeff_C_mul_X_pow]
  apply Finset.sum_eq_zero
  intro a _
  simp [show k ≠ (a : ℕ) by omega]

private lemma polyOfVec_ne_zero (r : ℕ) (v : Fin r → ℝ) (hv : v ≠ 0) :
    polyOfVec r v ≠ 0 := by
  intro h
  apply hv
  ext a
  rw [← polyOfVec_coeff_lt r v a, h, Polynomial.coeff_zero, Pi.zero_apply]

private lemma polyOfVec_natDegree_lt (r : ℕ) (hr : 1 ≤ r) (v : Fin r → ℝ) :
    (polyOfVec r v).natDegree < r := by
  have hle : (polyOfVec r v).natDegree ≤ r - 1 :=
    Polynomial.natDegree_le_iff_coeff_eq_zero.mpr fun k hk =>
      polyOfVec_coeff_ge r v k (by omega)
  omega

/-- `gramQuad r w v ≥ 0` for all `v`. -/
lemma gramQuad_nonneg (r w : ℕ) (v : Fin r → ℝ) : 0 ≤ gramQuad r w v :=
  div_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (Nat.cast_nonneg w)

/-- Each Gram matrix `G_w` (`w ≥ r ≥ 1`) is positive definite, by polynomial root counting. -/
lemma gramQuad_pos (r w : ℕ) (hr : 1 ≤ r) (hw : r ≤ w) (v : Fin r → ℝ) (hv : v ≠ 0) :
    0 < gramQuad r w v := by
  have hw0 : (0 : ℝ) < w := Nat.cast_pos.mpr (by omega)
  unfold gramQuad
  apply div_pos _ hw0
  have hpne : polyOfVec r v ≠ 0 := polyOfVec_ne_zero r v hv
  have hex : ∃ k ∈ range w, (polyOfVec r v).eval ((k : ℝ) / w) ≠ 0 := by
    by_contra hall
    push Not at hall
    have hsub : (range w).image (fun k : ℕ => (k : ℝ) / w) ⊆ (polyOfVec r v).roots.toFinset := by
      intro x hx
      rcases Finset.mem_image.mp hx with ⟨k, hk, rfl⟩
      rw [Multiset.mem_toFinset, Polynomial.mem_roots hpne, Polynomial.IsRoot]
      exact hall k hk
    have hinj : Function.Injective (fun k : ℕ => (k : ℝ) / w) := fun k₁ k₂ h =>
      Nat.cast_injective ((div_left_inj' hw0.ne').mp h)
    have hcard_le : w ≤ (polyOfVec r v).roots.toFinset.card := by
      have := Finset.card_le_card hsub
      rwa [Finset.card_image_of_injective _ hinj, Finset.card_range] at this
    have hroots : (polyOfVec r v).roots.toFinset.card < r :=
      lt_of_le_of_lt ((Multiset.toFinset_card_le _).trans (Polynomial.card_roots' _))
        (polyOfVec_natDegree_lt r hr v)
    omega
  obtain ⟨k, hk, hne⟩ := hex
  refine Finset.sum_pos' (fun j _ => sq_nonneg _) ⟨k, hk, ?_⟩
  rw [← polyOfVec_eval]
  exact sq_pos_of_ne_zero hne

private lemma continuous_l2sq (r : ℕ) : Continuous (l2sq (n := r)) := by
  unfold l2sq
  fun_prop

private lemma isCompact_sphereSet (r : ℕ) : IsCompact {v : Fin r → ℝ | l2sq v = 1} := by
  refine Metric.isCompact_of_isClosed_isBounded
    (isClosed_eq (continuous_l2sq r) continuous_const) ?_
  refine (Metric.isBounded_closedBall (x := (0 : Fin r → ℝ)) (r := 1)).subset fun v hv => ?_
  rw [Metric.mem_closedBall, dist_zero_right, pi_norm_le_iff_of_nonneg zero_le_one]
  intro a
  rw [Real.norm_eq_abs, ← sq_le_one_iff_abs_le_one]
  calc v a ^ 2 ≤ ∑ b : Fin r, v b ^ 2 :=
        Finset.single_le_sum (fun b _ => sq_nonneg (v b)) (Finset.mem_univ a)
    _ = 1 := hv

private lemma nonempty_sphereSet (r : ℕ) (hr : 1 ≤ r) :
    ({v : Fin r → ℝ | l2sq v = 1}).Nonempty := by
  refine ⟨Pi.single (⟨0, hr⟩ : Fin r) (1 : ℝ), ?_⟩
  simp [l2sq, Pi.single_apply]

private lemma pos_iInf_sphere (r : ℕ) (hr : 1 ≤ r) (f : (Fin r → ℝ) → ℝ) (hf : Continuous f)
    (hpos : ∀ v, l2sq v = 1 → 0 < f v) :
    0 < ⨅ v : {v : Fin r → ℝ // l2sq v = 1}, f v := by
  have : Nonempty {v : Fin r → ℝ // l2sq v = 1} := (nonempty_sphereSet r hr).to_subtype
  obtain ⟨v₀, hv₀, hmin⟩ := (isCompact_sphereSet r).exists_isMinOn (nonempty_sphereSet r hr)
    hf.continuousOn
  exact lt_of_lt_of_le (hpos v₀ hv₀) (le_ciInf fun v => hmin v.2)

private lemma continuous_gramQuad (r w : ℕ) : Continuous (gramQuad r w) := by
  unfold gramQuad
  fun_prop

/-- `λ_min(G_w) > 0` for `w ≥ r ≥ 1`. -/
lemma quadMin_pos (r w : ℕ) (hr : 1 ≤ r) (hw : r ≤ w) : 0 < quadMin r w := by
  refine pos_iInf_sphere r hr (gramQuad r w) (continuous_gramQuad r w) fun v hv => ?_
  refine gramQuad_pos r w hr hw v fun hv0 => ?_
  simp [hv0, l2sq] at hv

/-- `λ_min(G_w) ≤ 1` for `w ≥ r ≥ 1` (evaluating at `e_0`). -/
lemma quadMin_le_one (r w : ℕ) (hr : 1 ≤ r) (hw : r ≤ w) : quadMin r w ≤ 1 := by
  have hbdd : BddBelow (Set.range fun v : {v : Fin r → ℝ // l2sq v = 1} => gramQuad r w v) :=
    ⟨0, by rintro _ ⟨v, rfl⟩; exact gramQuad_nonneg r w v⟩
  let e0 : {v : Fin r → ℝ // l2sq v = 1} :=
    ⟨Pi.single (⟨0, hr⟩ : Fin r) (1 : ℝ), by simp [l2sq, Pi.single_apply]⟩
  calc quadMin r w ≤ gramQuad r w e0 := ciInf_le hbdd e0
    _ = 1 := by
      have hw0 : (w : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
      simp [gramQuad, e0, Pi.single_apply, hw0]

/-- Quadratic form of the Hilbert matrix `H = ∫₀¹ b(x) b(x)ᵀ dx`. -/
private def hilbertQuad (r : ℕ) (v : Fin r → ℝ) : ℝ :=
  ∑ a : Fin r, ∑ b : Fin r, v a * v b / ((a : ℕ) + (b : ℕ) + 1 : ℝ)

private lemma hilbertQuad_eq_integral (r : ℕ) (v : Fin r → ℝ) :
    hilbertQuad r v = ∫ x in (0 : ℝ)..1, ((polyOfVec r v).eval x) ^ 2 := by
  have hsq : ∀ x : ℝ, ((polyOfVec r v).eval x) ^ 2 =
      ∑ a : Fin r, ∑ b : Fin r, (v a * v b) * x ^ ((a : ℕ) + (b : ℕ)) := by
    intro x
    rw [polyOfVec_eval, sq, Finset.sum_mul_sum]
    apply Finset.sum_congr rfl; intro a _
    apply Finset.sum_congr rfl; intro b _
    rw [pow_add]; ring
  simp_rw [hsq]
  rw [intervalIntegral.integral_finsetSum fun a _ =>
    (Continuous.intervalIntegrable (by fun_prop) 0 1)]
  apply Finset.sum_congr rfl; intro a _
  rw [intervalIntegral.integral_finsetSum fun b _ =>
    (Continuous.intervalIntegrable (by fun_prop) 0 1)]
  apply Finset.sum_congr rfl; intro b _
  rw [intervalIntegral.integral_const_mul, integral_pow]
  simp [div_eq_mul_inv]

private lemma hilbertQuad_pos (r : ℕ) (v : Fin r → ℝ) (hv : v ≠ 0) :
    0 < hilbertQuad r v := by
  rw [hilbertQuad_eq_integral]
  refine intervalIntegral.integral_pos zero_lt_one
    (((polyOfVec r v).continuous.pow 2).continuousOn)
    (fun x _ => sq_nonneg _) ?_
  have hinf : (Set.Ioo (0 : ℝ) 1 \ ((polyOfVec r v).roots.toFinset : Set ℝ)).Nonempty :=
    ((Set.Ioo_infinite zero_lt_one).sdiff (Finset.finite_toSet _)).nonempty
  obtain ⟨c, hcIoo, hcnot⟩ := hinf
  refine ⟨c, Set.Ioo_subset_Icc_self hcIoo, sq_pos_of_ne_zero ?_⟩
  intro hzero
  apply hcnot
  rw [Finset.mem_coe, Multiset.mem_toFinset, Polynomial.mem_roots (polyOfVec_ne_zero r v hv)]
  exact hzero

private lemma continuous_hilbertQuad (r : ℕ) : Continuous (hilbertQuad r) := by
  unfold hilbertQuad
  fun_prop

/-- Left Riemann sum error for `x^m` on `[0, 1]` with `w ≥ 1` points lies in `[0, 1/w]`. -/
private lemma riemann_pow_bounds (m w : ℕ) (hw : 1 ≤ w) :
    0 ≤ 1 / ((m : ℝ) + 1) - (∑ k ∈ range w, ((k : ℝ) / w) ^ m) / w ∧
    1 / ((m : ℝ) + 1) - (∑ k ∈ range w, ((k : ℝ) / w) ^ m) / w ≤ 1 / w := by
  have hw0 : (0 : ℝ) < w := Nat.cast_pos.mpr (by omega)
  let f : ℝ → ℝ := fun x => (x / (w : ℝ)) ^ m
  have hf : MonotoneOn f (Set.Icc (0 : ℝ) (0 + (w : ℕ))) := by
    intro x hx y hy hxy
    exact pow_le_pow_left₀ (div_nonneg hx.1 hw0.le) (div_le_div_of_nonneg_right hxy hw0.le) m
  have hint : ∫ x in (0 : ℝ)..(0 + (w : ℕ)), f x = (w : ℝ) / ((m : ℝ) + 1) := by
    simp only [zero_add, f]
    have hrew : ∀ x : ℝ, (x / (w : ℝ)) ^ m = ((w : ℝ) ^ m)⁻¹ * x ^ m := by
      intro x; rw [div_pow, div_eq_inv_mul]
    simp_rw [hrew]
    rw [intervalIntegral.integral_const_mul, integral_pow]
    simp only [zero_pow (Nat.succ_ne_zero m), sub_zero]
    rw [pow_succ']
    have hwm : (w : ℝ) ^ m ≠ 0 := pow_ne_zero m hw0.ne'
    field_simp [hwm]
  have hlo := hf.sum_le_integral
  have hhi := hf.integral_le_sum
  rw [hint] at hlo hhi
  simp only [zero_add, f] at hlo hhi
  have hshift : ∑ k ∈ range w, (((k + 1 : ℕ) : ℝ) / w) ^ m ≤
      (∑ k ∈ range w, ((k : ℝ) / w) ^ m) + 1 := by
    have h1 := Finset.sum_range_succ (fun k : ℕ => ((k : ℝ) / w) ^ m) w
    have h2 := Finset.sum_range_succ' (fun k : ℕ => ((k : ℝ) / w) ^ m) w
    have hfw : ((w : ℝ) / w) ^ m = 1 := by rw [div_self hw0.ne', one_pow]
    have hf0' : (0 : ℝ) ≤ (((0 : ℕ) : ℝ) / w) ^ m := by positivity
    linarith
  have hlo' : (∑ k ∈ range w, ((k : ℝ) / w) ^ m) / w ≤ 1 / ((m : ℝ) + 1) := by
    rw [div_le_iff₀ hw0]
    calc ∑ k ∈ range w, ((k : ℝ) / w) ^ m ≤ (w : ℝ) / ((m : ℝ) + 1) := hlo
      _ = 1 / ((m : ℝ) + 1) * w := by ring
  have hhi' : 1 / ((m : ℝ) + 1) - (∑ k ∈ range w, ((k : ℝ) / w) ^ m) / w ≤ 1 / w := by
    have hcomb : (w : ℝ) / ((m : ℝ) + 1) - ∑ k ∈ range w, ((k : ℝ) / w) ^ m ≤ 1 := by linarith
    have hdiv := div_le_div_of_nonneg_right hcomb hw0.le
    rw [sub_div, div_div, mul_comm ((m : ℝ) + 1) w, ← div_div, div_self hw0.ne'] at hdiv
    exact hdiv
  exact ⟨sub_nonneg.mpr hlo', hhi'⟩

private lemma hilbertQuad_sub_gramQuad_le (r w : ℕ) (hw : 1 ≤ w) (v : Fin r → ℝ)
    (hv : l2sq v = 1) :
    hilbertQuad r v - gramQuad r w v ≤ (r : ℝ) / w := by
  have hgram : gramQuad r w v =
      ∑ a : Fin r, ∑ b : Fin r,
        v a * v b * ((∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w) := by
    unfold gramQuad
    have hexp : ∀ k ∈ range w, (∑ a : Fin r, v a * ((k : ℝ) / w) ^ (a : ℕ)) ^ 2 =
        ∑ a : Fin r, ∑ b : Fin r, v a * v b * ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ)) := by
      intro k _
      rw [sq, Finset.sum_mul_sum]
      apply Finset.sum_congr rfl; intro a _
      apply Finset.sum_congr rfl; intro b _
      rw [pow_add]; ring
    rw [Finset.sum_congr rfl hexp, Finset.sum_comm, Finset.sum_div]
    apply Finset.sum_congr rfl; intro a _
    rw [Finset.sum_comm, Finset.sum_div]
    apply Finset.sum_congr rfl; intro b _
    rw [← Finset.mul_sum, mul_div_assoc]
  rw [hgram, hilbertQuad, ← Finset.sum_sub_distrib]
  have hstep1 : ∑ a : Fin r,
      ((∑ b : Fin r, v a * v b / ((a : ℕ) + (b : ℕ) + 1 : ℝ)) -
        ∑ b : Fin r, v a * v b * ((∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w)) ≤
      ∑ a : Fin r, ∑ b : Fin r, |v a| * |v b| * (1 / (w : ℝ)) := by
    apply Finset.sum_le_sum; intro a _
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_le_sum; intro b _
    have hrb := riemann_pow_bounds ((a : ℕ) + (b : ℕ)) w hw
    have hd : v a * v b / ((a : ℕ) + (b : ℕ) + 1 : ℝ) -
        v a * v b * ((∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w) =
        (v a * v b) * (1 / (((a : ℕ) + (b : ℕ) : ℕ) + 1 : ℝ) -
          (∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w) := by
      push_cast; ring
    rw [hd]
    calc (v a * v b) * (1 / (((a : ℕ) + (b : ℕ) : ℕ) + 1 : ℝ) -
            (∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w)
        ≤ |v a * v b| * (1 / (((a : ℕ) + (b : ℕ) : ℕ) + 1 : ℝ) -
            (∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w) :=
          mul_le_mul_of_nonneg_right (le_abs_self _) hrb.1
      _ = |v a| * |v b| * (1 / (((a : ℕ) + (b : ℕ) : ℕ) + 1 : ℝ) -
            (∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w) := by
          rw [abs_mul]
      _ ≤ |v a| * |v b| * (1 / (w : ℝ)) :=
          mul_le_mul_of_nonneg_left hrb.2 (mul_nonneg (abs_nonneg _) (abs_nonneg _))
  have hcs : (∑ a : Fin r, |v a|) ^ 2 ≤ (r : ℝ) := by
    have h1 := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin r))) (f := fun a => |v a|)
    simp only [Finset.card_univ, Fintype.card_fin, sq_abs] at h1
    rw [show ∑ i : Fin r, v i ^ 2 = 1 from hv, mul_one] at h1
    exact h1
  calc _ ≤ ∑ a : Fin r, ∑ b : Fin r, |v a| * |v b| * (1 / (w : ℝ)) := hstep1
    _ = (∑ a : Fin r, |v a|) ^ 2 / (w : ℝ) := by
        rw [sq, Finset.sum_mul_sum, Finset.sum_div]
        apply Finset.sum_congr rfl; intro a _
        rw [Finset.sum_div]
        apply Finset.sum_congr rfl; intro b _
        ring
    _ ≤ (r : ℝ) / (w : ℝ) := div_le_div_of_nonneg_right hcs (Nat.cast_nonneg w)

/-- `g_r ∈ (0, 1]` (stated in the appendix before Lemma `pf:lem:smooth`; proved in T10). -/
theorem gr_pos (r : ℕ) (hr : 1 ≤ r) : 0 < gr r ∧ gr r ≤ 1 := by
  have : Nonempty {v : Fin r → ℝ // l2sq v = 1} := (nonempty_sphereSet r hr).to_subtype
  have : Nonempty {w : ℕ // r ≤ w} := ⟨⟨r, le_refl r⟩⟩
  let hMin : ℝ := ⨅ v : {v : Fin r → ℝ // l2sq v = 1}, hilbertQuad r v
  have hhMin_pos : 0 < hMin := by
    refine pos_iInf_sphere r hr (hilbertQuad r) (continuous_hilbertQuad r) fun v hv => ?_
    refine hilbertQuad_pos r v fun hv0 => ?_
    simp [hv0, l2sq] at hv
  have hbdd_h : BddBelow (Set.range fun v : {v : Fin r → ℝ // l2sq v = 1} => hilbertQuad r v) :=
    ⟨0, by
      rintro _ ⟨v, rfl⟩
      dsimp only
      rw [hilbertQuad_eq_integral]
      exact intervalIntegral.integral_nonneg zero_le_one fun x _ => sq_nonneg _⟩
  have hquad_ge : ∀ w : ℕ, 1 ≤ w → hMin - (r : ℝ) / w ≤ quadMin r w := by
    intro w hw
    apply le_ciInf
    intro v
    have hv1 := ciInf_le hbdd_h v
    have hv2 := hilbertQuad_sub_gramQuad_le r w hw v.1 v.2
    linarith
  let W : ℕ := max r (Nat.ceil (2 * (r : ℝ) / hMin))
  let S : Finset ℕ := Finset.Ico r (W + 1)
  have hS : S.Nonempty := ⟨r, Finset.mem_Ico.mpr ⟨le_refl r, by omega⟩⟩
  let c : ℝ := min (hMin / 2) (S.inf' hS (fun w => quadMin r w))
  have hc_pos : 0 < c := by
    apply lt_min (half_pos hhMin_pos)
    rw [Finset.lt_inf'_iff]
    intro w hw
    exact quadMin_pos r w hr (Finset.mem_Ico.mp hw).1
  have hgr_ge : c ≤ gr r := by
    apply le_ciInf
    intro w
    by_cases hwW : w.1 ≤ W
    · exact (min_le_right _ _).trans
        (Finset.inf'_le (fun k => quadMin r k) (Finset.mem_Ico.mpr ⟨w.2, by omega⟩))
    · have hw_ge : 2 * (r : ℝ) / hMin ≤ (w.1 : ℝ) := by
        have h1 : (Nat.ceil (2 * (r : ℝ) / hMin) : ℝ) ≤ (W : ℝ) := Nat.cast_le.mpr (le_max_right _ _)
        have h2 : (W : ℝ) ≤ (w.1 : ℝ) := Nat.cast_le.mpr (by omega)
        exact (Nat.le_ceil _).trans (h1.trans h2)
      have hw0 : (0 : ℝ) < w.1 := Nat.cast_pos.mpr (by omega)
      have hrw : (r : ℝ) / w.1 ≤ hMin / 2 := by
        rw [div_le_iff₀ hw0]
        have hmul := (div_le_iff₀ hhMin_pos).mp hw_ge
        linarith
      exact (min_le_left _ _).trans (by linarith [hquad_ge w.1 (by omega)])
  have hgr_le : gr r ≤ 1 := by
    have hbdd_g : BddBelow (Set.range fun w : {w : ℕ // r ≤ w} => quadMin r w) :=
      ⟨0, by rintro _ ⟨w, rfl⟩; exact (quadMin_pos r w.1 hr w.2).le⟩
    exact (ciInf_le hbdd_g ⟨r, le_refl r⟩).trans (quadMin_le_one r r hr (le_refl r))
  exact ⟨lt_of_lt_of_le hc_pos hgr_ge, hgr_le⟩

/-- `g_r ≤ λ_min(G_w)` for every `w ≥ r`, as a bound on the quadratic form. -/
theorem gr_le_gramQuad (r w : ℕ) (hr : 1 ≤ r) (hw : r ≤ w) (v : Fin r → ℝ) :
    gr r * l2sq v ≤ gramQuad r w v := by
  by_cases hv : l2sq v = 0
  · rw [hv, mul_zero]
    exact gramQuad_nonneg r w v
  · have hv_pos : 0 < l2sq v :=
      lt_of_le_of_ne (Finset.sum_nonneg fun _ _ => sq_nonneg _) (Ne.symm hv)
    let s : ℝ := Real.sqrt (l2sq v)
    have hs_pos : 0 < s := Real.sqrt_pos.mpr hv_pos
    let u : Fin r → ℝ := fun a => v a / s
    have hu : l2sq u = 1 := by
      unfold l2sq u
      simp_rw [div_pow, ← Finset.sum_div]
      rw [Real.sq_sqrt hv_pos.le]
      exact div_self hv_pos.ne'
    have hbdd_g : BddBelow (Set.range fun k : {k : ℕ // r ≤ k} => quadMin r k) :=
      ⟨0, by rintro _ ⟨k, rfl⟩; exact (quadMin_pos r k.1 hr k.2).le⟩
    have hbdd_v : BddBelow (Set.range fun x : {x : Fin r → ℝ // l2sq x = 1} => gramQuad r w x) :=
      ⟨0, by rintro _ ⟨x, rfl⟩; exact gramQuad_nonneg r w x⟩
    have hgr_le : gr r ≤ gramQuad r w u :=
      (ciInf_le hbdd_g ⟨w, hw⟩).trans (ciInf_le hbdd_v ⟨u, hu⟩)
    have hscale : gramQuad r w v = l2sq v * gramQuad r w u := by
      unfold gramQuad u
      have hterm : ∀ k ∈ range w,
          (∑ a : Fin r, v a * ((k : ℝ) / w) ^ (a : ℕ)) ^ 2 =
            l2sq v * (∑ a : Fin r, (v a / s) * ((k : ℝ) / w) ^ (a : ℕ)) ^ 2 := by
        intro k _
        have hsum : ∑ a : Fin r, (v a / s) * ((k : ℝ) / w) ^ (a : ℕ) =
            (∑ a : Fin r, v a * ((k : ℝ) / w) ^ (a : ℕ)) / s := by
          rw [Finset.sum_div]
          apply Finset.sum_congr rfl; intro a _; ring
        rw [hsum, div_pow, Real.sq_sqrt hv_pos.le, mul_div_cancel₀ _ hv_pos.ne']
      rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum, mul_div_assoc]
    rw [hscale, mul_comm (l2sq v)]
    exact mul_le_mul_of_nonneg_right hgr_le hv_pos.le

end BQTF
