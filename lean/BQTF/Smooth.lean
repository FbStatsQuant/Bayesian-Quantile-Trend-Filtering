import BQTF.Gram
import BQTF.Coord

/-!
# The smoothed truth (appendix, Lemma `pf:lem:smooth`)

Owner: Neon-A. A local polynomial smoother of `u* = Dθ*` with windows of `w` points.
-/

open Finset

noncomputable section

namespace BQTF

/-- Monomial feature vector `b(x) = (1, x, …, x^{r−1})`. -/
private def bVec (r : ℕ) (x : ℝ) : Fin r → ℝ := fun a => x ^ (a : ℕ)

/-- Gram matrix `G_w = w⁻¹ ∑_{k<w} b(k/w) b(k/w)ᵀ`. -/
private def gramMat (r w : ℕ) : Matrix (Fin r) (Fin r) ℝ :=
  Matrix.of fun a b => (∑ k ∈ range w, ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ))) / w

private lemma gramMat_symm (r w : ℕ) (a b : Fin r) : gramMat r w a b = gramMat r w b a := by
  simp only [gramMat, Matrix.of_apply, add_comm]

private lemma dot_gramMat_mulVec (r w : ℕ) (u v : Fin r → ℝ) :
    dot u ((gramMat r w).mulVec v) =
      (∑ k ∈ range w, dot u (bVec r ((k : ℝ) / w)) * dot v (bVec r ((k : ℝ) / w))) / w := by
  unfold dot gramMat bVec
  simp only [Matrix.mulVec, dotProduct, Matrix.of_apply]
  have hrhs : ∀ k ∈ range w,
      (∑ a : Fin r, u a * ((k : ℝ) / w) ^ (a : ℕ)) *
        (∑ b : Fin r, v b * ((k : ℝ) / w) ^ (b : ℕ)) =
      ∑ a : Fin r, ∑ b : Fin r, u a * v b * ((k : ℝ) / w) ^ ((a : ℕ) + (b : ℕ)) := by
    intro k _
    rw [Finset.sum_mul_sum]
    apply Finset.sum_congr rfl; intro a _
    apply Finset.sum_congr rfl; intro b _
    rw [pow_add]; ring
  rw [Finset.sum_congr rfl hrhs, Finset.sum_comm, Finset.sum_div]
  apply Finset.sum_congr rfl; intro a _
  rw [Finset.sum_comm, Finset.sum_div, Finset.mul_sum]
  apply Finset.sum_congr rfl; intro b _
  rw [← Finset.mul_sum]
  ring

private lemma dot_gramMat_mulVec_self (r w : ℕ) (v : Fin r → ℝ) :
    dot v ((gramMat r w).mulVec v) = gramQuad r w v := by
  rw [dot_gramMat_mulVec]
  unfold gramQuad bVec dot
  congr 1
  apply Finset.sum_congr rfl; intro k _
  rw [sq]

private lemma dot_gramMat_comm (r w : ℕ) (u v : Fin r → ℝ) :
    dot u ((gramMat r w).mulVec v) = dot ((gramMat r w).mulVec u) v := by
  rw [dot_gramMat_mulVec]
  have hsym : dot ((gramMat r w).mulVec u) v = dot v ((gramMat r w).mulVec u) := by
    unfold dot; apply Finset.sum_congr rfl; intro a _; ring
  rw [hsym, dot_gramMat_mulVec]
  congr 1; apply Finset.sum_congr rfl; intro k _; ring

/-- For `w ≥ r ≥ 1`, `G_w` is surjective (invertible) as a linear map on `ℝ^r`. -/
private lemma gramMat_mulVec_surjective (r w : ℕ) (hr : 1 ≤ r) (hw : r ≤ w) :
    Function.Surjective (gramMat r w).mulVecLin := by
  rw [← LinearMap.injective_iff_surjective]
  intro u v huv
  have hsub : (gramMat r w).mulVec (u - v) = 0 := by
    change (gramMat r w).mulVecLin (u - v) = 0
    rw [map_sub, huv, sub_self]
  have hq : gramQuad r w (u - v) = 0 := by
    rw [← dot_gramMat_mulVec_self, hsub]
    simp [dot]
  have hle := gr_le_gramQuad r w hr hw (u - v)
  rw [hq] at hle
  have hgr_pos := (gr_pos r hr).1
  have hl2_le : l2sq (u - v) ≤ 0 := nonpos_of_mul_nonpos_right hle hgr_pos
  have hl2_eq : l2sq (u - v) = 0 :=
    le_antisymm hl2_le (Finset.sum_nonneg fun _ _ => sq_nonneg _)
  have huv0 : u - v = 0 := by
    ext a
    have ha : (u - v) a ^ 2 ≤ l2sq (u - v) :=
      Finset.single_le_sum (fun b _ => sq_nonneg ((u - v) b)) (Finset.mem_univ a)
    rw [hl2_eq] at ha
    exact sq_eq_zero_iff.mp (le_antisymm ha (sq_nonneg _))
  exact sub_eq_zero.mp huv0

private lemma l2norm_bVec_le (r : ℕ) (x : ℝ) (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    l2norm (bVec r x) ≤ Real.sqrt r := by
  apply Real.sqrt_le_sqrt
  unfold l2sq bVec
  calc ∑ a : Fin r, (x ^ (a : ℕ)) ^ 2
      ≤ ∑ _a : Fin r, (1 : ℝ) := by
        apply Finset.sum_le_sum; intro a _
        have h1 : x ^ (a : ℕ) ≤ 1 := pow_le_one₀ hx0 hx1
        have h0 : 0 ≤ x ^ (a : ℕ) := pow_nonneg hx0 _
        nlinarith
    _ = (r : ℝ) := by simp

/-- Triangle inequality for `l2norm` of a weighted sum. -/
private lemma l2norm_sum_smul_le {ι n : ℕ} (α : Fin ι → ℝ) (v : Fin ι → Fin n → ℝ) :
    l2norm (∑ j : Fin ι, α j • v j) ≤ ∑ j : Fin ι, |α j| * l2norm (v j) := by
  rw [← norm_toE, map_sum]
  calc ‖∑ j : Fin ι, toE n (α j • v j)‖
      ≤ ∑ j : Fin ι, ‖toE n (α j • v j)‖ := norm_sum_le _ _
    _ = ∑ j : Fin ι, |α j| * l2norm (v j) := by
        apply Finset.sum_congr rfl; intro j _
        rw [map_smul, norm_smul, Real.norm_eq_abs, norm_toE]

/-- `bfun p t` agrees with the falling binomial polynomial when `t ≥ 0`. -/
private lemma bfun_eq_desc_eval (p : ℕ) (t : ℤ) (ht : 0 ≤ t) :
    bfun p t = (∏ k ∈ range p, ((t : ℝ) - (k : ℝ))) / (p.factorial : ℝ) := by
  rw [bfun]
  simp only [ht, ↓reduceIte]
  obtain ⟨m, rfl⟩ := Int.eq_ofNat_of_zero_le ht
  simp only [Int.cast_natCast, Int.toNat_natCast]
  have hprod : ∏ k ∈ range p, ((m : ℝ) - (k : ℝ)) = (m.descFactorial p : ℝ) := by
    induction p with
    | zero => simp
    | succ p ih =>
      rw [Finset.prod_range_succ, ih, Nat.descFactorial_succ]
      by_cases hmp : p ≤ m
      · rw [Nat.cast_mul, Nat.cast_sub hmp]; ring
      · have hlt : m < p := Nat.lt_of_not_ge hmp
        rw [Nat.descFactorial_eq_zero_iff_lt.mpr hlt]
        simp
  rw [hprod, Nat.descFactorial_eq_factorial_mul_choose, Nat.cast_mul]
  have hfac : (p.factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero p)
  field_simp [hfac]

/-- `bfun p t ≤ (t.toNat : ℝ)^p` for `0 ≤ t`. -/
private lemma bfun_le_pow (p : ℕ) (t : ℤ) (ht : 0 ≤ t) :
    bfun p t ≤ (t.toNat : ℝ) ^ p := by
  rw [bfun]
  simp only [ht, ↓reduceIte]
  have hnat : t.toNat.choose p ≤ t.toNat ^ p :=
    (Nat.choose_le_descFactorial t.toNat p).trans (Nat.descFactorial_le_pow t.toNat p)
  exact_mod_cast hnat

/-- Lemma `pf:lem:smooth`: for every integer `r ≤ w ≤ m` there is `u_w ∈ ℝ^m` with
`‖u_w‖₂ ≤ C_s V* / (n^{r−1} √w)` and `‖S(u* − u_w)‖_n ≤ C_s V* (w/n)^{r−1/2}`, where
`V* = TV^{(r)}(θ*)`. -/
theorem smoothed_truth (r n : ℕ) (hr : 2 ≤ r) (hn : r < n) (θs : Fin n → ℝ) (w : ℕ)
    (hw : r ≤ w) (hwm : w ≤ n - r) :
    ∃ uw : Fin (n - r) → ℝ,
      l2norm uw ≤ Cs r * TVr r n θs / ((n : ℝ) ^ (r - 1) * Real.sqrt w) ∧
      empNorm (Smul r n (ustar r n θs - uw)) ≤
        Cs r * TVr r n θs * ((w : ℝ) / n) ^ ((r : ℝ) - 1 / 2) := by
  let m := n - r
  have hr1 : 1 ≤ r := by omega
  have hw0 : (0 : ℝ) < w := Nat.cast_pos.mpr (by omega)
  have hn0 : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
  have hgr_pos : 0 < gr r := (gr_pos r hr1).1
  have hgr_le1 : gr r ≤ 1 := (gr_pos r hr1).2
  have hCs_ge : (r : ℝ) / gr r ≤ Cs r := by unfold Cs; linarith
  have hCs_pos : 0 < Cs r := by unfold Cs; positivity
  -- Window left endpoint `a_j` for each `j : Fin m`
  let aj : Fin m → ℕ := fun j => min j.val (m - w)
  have haj_le_j : ∀ j : Fin m, aj j ≤ j.val := fun j => min_le_left _ _
  have hj_lt_ajw : ∀ j : Fin m, j.val < aj j + w := fun j => by
    dsimp only [aj]
    by_cases h : j.val ≤ m - w
    · rw [min_eq_left h]; omega
    · rw [min_eq_right (by omega)]; have := j.isLt; omega
  have haj_add_le : ∀ j : Fin m, aj j + w ≤ m := fun j => by
    have : aj j ≤ m - w := min_le_right _ _
    omega
  -- Solve `G_w c_j = b((j - a_j)/w)` for each `j : Fin m`
  have hsurj := gramMat_mulVec_surjective r w hr1 hw
  choose cj hcj using fun j : Fin m =>
    hsurj (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ)))
  -- Local polynomial reproducing kernel `K j : Fin m → ℝ`
  let K : Fin m → Fin m → ℝ := fun j l =>
    if aj j ≤ l.val ∧ l.val < aj j + w then
      dot (cj j) (bVec r (((l.val - aj j : ℕ) : ℝ) / (w : ℝ))) / (w : ℝ)
    else 0
  -- Sum over `l : Fin m` of `K j l * f l` reduces to `k : Fin w`
  have hsum_K : ∀ (j : Fin m) (f : Fin m → ℝ),
      ∑ l : Fin m, K j l * f l =
        (∑ k : Fin w, dot (cj j) (bVec r ((k.val : ℝ) / (w : ℝ))) *
          f ⟨aj j + k.val, by have := k.isLt; have := haj_add_le j; omega⟩) / (w : ℝ) := by
    intro j f
    let S := Finset.univ.filter fun l : Fin m => aj j ≤ l.val ∧ l.val < aj j + w
    have hsub : ∑ l : Fin m, K j l * f l = ∑ l ∈ S,
        (dot (cj j) (bVec r (((l.val - aj j : ℕ) : ℝ) / (w : ℝ))) * f l) / (w : ℝ) := by
      calc ∑ l : Fin m, K j l * f l
          = ∑ l ∈ S, K j l * f l := by
            symm
            apply Finset.sum_subset (Finset.subset_univ S)
            intro l _ hl
            simp only [S, Finset.mem_filter, Finset.mem_univ, true_and] at hl
            simp [K, hl]
        _ = ∑ l ∈ S, (dot (cj j) (bVec r (((l.val - aj j : ℕ) : ℝ) / (w : ℝ))) * f l) / (w : ℝ) := by
            apply Finset.sum_congr rfl; intro l hl
            simp only [S, Finset.mem_filter, Finset.mem_univ, true_and] at hl
            simp [K, hl, div_mul_eq_mul_div]
    rw [hsub, ← Finset.sum_div]
    congr 1
    refine Finset.sum_bij (fun l hl => ⟨l.val - aj j, by
        simp only [S, Finset.mem_filter, Finset.mem_univ, true_and] at hl; omega⟩) ?_ ?_ ?_ ?_
    · intro l _; exact Finset.mem_univ _
    · intro l₁ hl₁ l₂ hl₂ heq
      simp only [S, Finset.mem_filter, Finset.mem_univ, true_and] at hl₁ hl₂
      have hval : l₁.val - aj j = l₂.val - aj j := congrArg Fin.val heq
      ext; omega
    · intro k _
      refine ⟨⟨aj j + k.val, by have := k.isLt; have := haj_add_le j; omega⟩, ?_, ?_⟩
      · simp only [S, Finset.mem_filter, Finset.mem_univ, true_and]
        have := k.isLt; omega
      · ext; simp
    · intro l hl
      simp only [S, Finset.mem_filter, Finset.mem_univ, true_and] at hl
      congr 2
      ext; simp; omega
  have hl2_nn : ∀ {d : ℕ} (v : Fin d → ℝ), 0 ≤ l2sq v :=
    fun v => Finset.sum_nonneg fun _ _ => sq_nonneg _
  -- Bound on `‖K j‖₂` and `‖K j‖₁`
  have hK_l2 : ∀ j : Fin m, l2norm (K j) ≤ (r : ℝ) / (gr r * Real.sqrt w) := by
    intro j
    have hK_sq : l2sq (K j) = gramQuad r w (cj j) / (w : ℝ) := by
      have h1 := hsum_K j (K j)
      have hlhs : ∑ l : Fin m, K j l * K j l = l2sq (K j) := by simp [l2sq, sq]
      rw [hlhs] at h1
      rw [h1]
      have hterm : ∀ k : Fin w,
          dot (cj j) (bVec r ((k.val : ℝ) / (w : ℝ))) *
            K j ⟨aj j + k.val, by have := k.isLt; have := haj_add_le j; omega⟩ =
          (dot (cj j) (bVec r ((k.val : ℝ) / (w : ℝ)))) ^ 2 / (w : ℝ) := by
        intro k
        have hklt : k.val < w := k.isLt
        have hcond : aj j ≤ aj j + k.val ∧ aj j + k.val < aj j + w := by omega
        dsimp only [K]
        simp only [hcond, and_self, ↓reduceIte, Nat.add_sub_cancel_left]
        ring
      rw [Finset.sum_congr rfl fun k _ => hterm k, ← Finset.sum_div,
        Fin.sum_univ_eq_sum_range (fun k => (dot (cj j) (bVec r ((k : ℝ) / (w : ℝ)))) ^ 2) w]
      unfold gramQuad bVec dot
      ring
    -- `gramQuad r w (cj j) = dot (cj j) (b(x_j)) ≤ √r * l2norm (cj j)`
    have hxj0 : 0 ≤ ((j.val - aj j : ℕ) : ℝ) / (w : ℝ) := by positivity
    have hxj1 : ((j.val - aj j : ℕ) : ℝ) / (w : ℝ) ≤ 1 := by
      rw [div_le_one hw0]
      have := hj_lt_ajw j
      exact_mod_cast (by omega : j.val - aj j ≤ w)
    have hb_norm : l2norm (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ))) ≤ Real.sqrt r :=
      l2norm_bVec_le r _ hxj0 hxj1
    have hq_eq : gramQuad r w (cj j) =
        dot (cj j) (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ))) := by
      rw [← dot_gramMat_mulVec_self]
      have hcj' : (gramMat r w).mulVec (cj j) = bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ)) :=
        hcj j
      rw [hcj']
    have hdot_le : dot (cj j) (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ))) ≤
        l2norm (cj j) * Real.sqrt r := by
      have hcs : dot (cj j) (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ))) ≤
          l2norm (cj j) * l2norm (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ))) := by
        rw [← inner_toE, ← norm_toE, ← norm_toE]
        exact real_inner_le_norm _ _
      exact hcs.trans (mul_le_mul_of_nonneg_left hb_norm (Real.sqrt_nonneg _))
    have hq_le : gramQuad r w (cj j) ≤ (r : ℝ) / gr r := by
      have hgr_cj := gr_le_gramQuad r w hr1 hw (cj j)
      have hcj_norm : gr r * l2norm (cj j) ≤ Real.sqrt r := by
        by_cases hc0 : l2norm (cj j) = 0
        · rw [hc0, mul_zero]; positivity
        · have hc_pos : 0 < l2norm (cj j) :=
            lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm hc0)
          have hsq_eq : l2sq (cj j) = l2norm (cj j) * l2norm (cj j) := by
            unfold l2norm; rw [Real.mul_self_sqrt (hl2_nn _)]
          rw [hsq_eq] at hgr_cj
          have h1 : gr r * l2norm (cj j) * l2norm (cj j) ≤ Real.sqrt r * l2norm (cj j) := by
            linarith
          exact le_of_mul_le_mul_right h1 hc_pos
      have hcj_le : l2norm (cj j) ≤ Real.sqrt r / gr r := (le_div_iff₀ hgr_pos).mpr (by linarith)
      calc gramQuad r w (cj j)
          ≤ l2norm (cj j) * Real.sqrt r := by linarith
        _ ≤ (Real.sqrt r / gr r) * Real.sqrt r :=
            mul_le_mul_of_nonneg_right hcj_le (Real.sqrt_nonneg _)
        _ = (r : ℝ) / gr r := by
            rw [div_mul_eq_mul_div, Real.mul_self_sqrt (Nat.cast_nonneg r)]
    have hratio_ge1 : (1 : ℝ) ≤ (r : ℝ) / gr r := by
      rw [one_le_div hgr_pos]
      exact hgr_le1.trans (by exact_mod_cast hr1)
    have hratio_sq : (r : ℝ) / gr r ≤ ((r : ℝ) / gr r) ^ 2 := by nlinarith
    have hK_sq_le : l2sq (K j) ≤ ((r : ℝ) / (gr r * Real.sqrt w)) ^ 2 := by
      rw [hK_sq, div_pow, mul_pow, Real.sq_sqrt hw0.le, ← div_div, ← div_pow]
      exact div_le_div_of_nonneg_right (hq_le.trans hratio_sq) hw0.le
    unfold l2norm
    exact (Real.sqrt_le_sqrt hK_sq_le).trans_eq (Real.sqrt_sq (by positivity))
  have hK_l1 : ∀ j : Fin m, l1norm (K j) ≤ (r : ℝ) / gr r := by
    intro j
    let S := Finset.univ.filter fun l : Fin m => aj j ≤ l.val ∧ l.val < aj j + w
    have hcard_S : S.card ≤ w := by
      have hsub : S.image Fin.val ⊆ Finset.Ico (aj j) (aj j + w) := by
        intro idx hidx
        rcases Finset.mem_image.mp hidx with ⟨l, hl, rfl⟩
        simp only [S, Finset.mem_filter, Finset.mem_univ, true_and] at hl
        exact Finset.mem_Ico.mpr hl
      have h1 := Finset.card_le_card hsub
      rw [Finset.card_image_of_injective _ Fin.val_injective, Nat.card_Ico] at h1
      simpa using h1
    have hl1_eq : l1norm (K j) = ∑ l ∈ S, |K j l| := by
      unfold l1norm
      symm
      apply Finset.sum_subset (Finset.subset_univ S)
      intro l _ hl
      simp only [S, Finset.mem_filter, Finset.mem_univ, true_and] at hl
      simp [K, hl]
    have hcs : (l1norm (K j)) ^ 2 ≤ (w : ℝ) * l2sq (K j) := by
      rw [hl1_eq]
      have h1 := sq_sum_le_card_mul_sum_sq (s := S) (f := fun l => |K j l|)
      have hsum_le : ∑ l ∈ S, |K j l| ^ 2 ≤ l2sq (K j) := by
        simp_rw [sq_abs]
        exact Finset.sum_le_univ_sum_of_nonneg fun _ => sq_nonneg _
      exact h1.trans (mul_le_mul (by exact_mod_cast hcard_S) hsum_le
        (Finset.sum_nonneg fun _ _ => sq_nonneg _) hw0.le)
    have hsq_le : (l1norm (K j)) ^ 2 ≤ ((r : ℝ) / gr r) ^ 2 := by
      have hK2 : l2sq (K j) ≤ ((r : ℝ) / (gr r * Real.sqrt w)) ^ 2 := by
        have h1 := hK_l2 j
        have h2 := pow_le_pow_left₀ (Real.sqrt_nonneg _) h1 2
        unfold l2norm at h2
        rwa [Real.sq_sqrt (hl2_nn _)] at h2
      calc (l1norm (K j)) ^ 2 ≤ (w : ℝ) * l2sq (K j) := hcs
        _ ≤ (w : ℝ) * ((r : ℝ) / (gr r * Real.sqrt w)) ^ 2 :=
            mul_le_mul_of_nonneg_left hK2 hw0.le
        _ = ((r : ℝ) / gr r) ^ 2 := by
            rw [div_pow, mul_pow, Real.sq_sqrt hw0.le]
            field_simp [hw0.ne', hgr_pos.ne']
    have hnn : 0 ≤ l1norm (K j) := Finset.sum_nonneg fun _ _ => abs_nonneg _
    nlinarith [div_nonneg (Nat.cast_nonneg r) hgr_pos.le]
  -- Polynomial reproduction by `K j` for `s_l(i)` when `i ≥ a_j + w`
  have hreprod : ∀ (j : Fin m) (i : Fin n), aj j + w ≤ i.val →
      ∑ l : Fin m, K j l * sCol r n l.val i = sCol r n j.val i := by
    intro j i hi
    let P : Polynomial ℝ :=
      Polynomial.C ((i.val : ℝ) - (aj j : ℝ) - 1) - Polynomial.C (w : ℝ) * Polynomial.X
    let F : Polynomial ℝ :=
      (∏ t ∈ range (r - 1), (P - Polynomial.C (t : ℝ))) *
        Polynomial.C ((((r - 1).factorial : ℝ))⁻¹)
    have hPdeg : P.degree ≤ 1 := by
      refine (Polynomial.degree_sub_le _ _).trans (max_le (Polynomial.degree_C_le.trans (by decide)) ?_)
      calc (Polynomial.C (w : ℝ) * Polynomial.X).degree
          ≤ (Polynomial.C (w : ℝ)).degree + Polynomial.X.degree := Polynomial.degree_mul_le _ _
        _ ≤ 0 + 1 := add_le_add Polynomial.degree_C_le (by rw [Polynomial.degree_X])
        _ = 1 := by simp
    have hFdeg : F.degree < (r : WithBot ℕ) := by
      have h1 : (∏ t ∈ range (r - 1), (P - Polynomial.C (t : ℝ))).degree ≤ ((r - 1 : ℕ) : WithBot ℕ) := by
        calc (∏ t ∈ range (r - 1), (P - Polynomial.C (t : ℝ))).degree
            ≤ ∑ t ∈ range (r - 1), (P - Polynomial.C (t : ℝ)).degree := Polynomial.degree_prod_le _ _
          _ ≤ ∑ _t ∈ range (r - 1), (1 : WithBot ℕ) := by
              apply Finset.sum_le_sum; intro t _
              exact (Polynomial.degree_sub_le _ _).trans
                (max_le hPdeg (Polynomial.degree_C_le.trans (by decide)))
          _ = ((r - 1 : ℕ) : WithBot ℕ) := by simp
      have h2 : F.degree ≤ ((r - 1 : ℕ) : WithBot ℕ) := by
        calc F.degree
            ≤ (∏ t ∈ range (r - 1), (P - Polynomial.C (t : ℝ))).degree +
                (Polynomial.C ((((r - 1).factorial : ℝ))⁻¹)).degree := Polynomial.degree_mul_le _ _
          _ ≤ ((r - 1 : ℕ) : WithBot ℕ) + 0 := add_le_add h1 Polynomial.degree_C_le
          _ = ((r - 1 : ℕ) : WithBot ℕ) := by simp
      exact h2.trans_lt (by exact_mod_cast (by omega : r - 1 < r))
    let α : Fin r → ℝ := fun a => F.coeff a.val
    have hFeval_dot : ∀ x : ℝ, F.eval x = dot α (bVec r x) := by
      intro x
      by_cases hF0 : F = 0
      · simp [hF0, α, dot]
      · have hnat : F.natDegree < r := by
          rw [Polynomial.degree_eq_natDegree hF0] at hFdeg
          exact WithBot.coe_lt_coe.mp hFdeg
        rw [Polynomial.eval_eq_sum_range' hnat x,
          ← Fin.sum_univ_eq_sum_range (fun k => F.coeff k * x ^ k) r]
        rfl
    have hFeval_sCol : ∀ k : ℕ, k < w →
        F.eval ((k : ℝ) / (w : ℝ)) = sCol r n (aj j + k) i := by
      intro k hk
      have hPeval : P.eval ((k : ℝ) / (w : ℝ)) = (((i.val : ℤ) - ((aj j + k : ℕ) : ℤ) - 1) : ℝ) := by
        simp only [P, Polynomial.eval_sub, Polynomial.eval_C, Polynomial.eval_mul, Polynomial.eval_X]
        rw [mul_div_cancel₀ _ hw0.ne']
        push_cast; ring
      have hFcalc : F.eval ((k : ℝ) / (w : ℝ)) =
          (∏ t ∈ range (r - 1), (P.eval ((k : ℝ) / (w : ℝ)) - (t : ℝ))) / ((r - 1).factorial : ℝ) := by
        simp [F, Polynomial.eval_prod, div_eq_mul_inv]
      rw [hFcalc, hPeval]
      unfold sCol
      rw [bfun_eq_desc_eval (r - 1) ((i : ℤ) - ((aj j + k : ℕ) : ℤ) - 1) (by omega)]
      push_cast
      rfl
    rw [hsum_K j (fun l => sCol r n l.val i)]
    have hcongr : ∀ k : Fin w,
        dot (cj j) (bVec r ((k.val : ℝ) / (w : ℝ))) * sCol r n (aj j + k.val) i =
        dot (cj j) (bVec r ((k.val : ℝ) / (w : ℝ))) * dot α (bVec r ((k.val : ℝ) / (w : ℝ))) := by
      intro k
      rw [← hFeval_dot, hFeval_sCol k.val k.isLt]
    rw [Finset.sum_congr rfl fun k _ => hcongr k,
      Fin.sum_univ_eq_sum_range (fun k => dot (cj j) (bVec r ((k : ℝ) / (w : ℝ))) *
        dot α (bVec r ((k : ℝ) / (w : ℝ)))) w,
      ← dot_gramMat_mulVec, dot_gramMat_comm]
    have hcj' : (gramMat r w).mulVec (cj j) = bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ)) :=
      hcj j
    rw [hcj']
    have hsym : dot (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ))) α =
        dot α (bVec r (((j.val - aj j : ℕ) : ℝ) / (w : ℝ))) := by
      unfold dot; apply Finset.sum_congr rfl; intro a _; ring
    rw [hsym, ← hFeval_dot]
    have hjk_lt : j.val - aj j < w := by have := hj_lt_ajw j; omega
    have hjk_add : aj j + (j.val - aj j) = j.val := Nat.add_sub_of_le (haj_le_j j)
    rw [hFeval_sCol (j.val - aj j) hjk_lt, hjk_add]
  -- Localized error vector `d j = s_j - ∑_l K j l • s_l`
  let d : Fin m → Fin n → ℝ := fun j => sCol r n j.val - ∑ l : Fin m, K j l • sCol r n l.val
  have hd_l2 : ∀ j : Fin m, l2norm (d j) ≤ Cs r * (w : ℝ) ^ ((r : ℝ) - 1 / 2) := by
    intro j
    have hd_zero_le : ∀ i : Fin n, i.val ≤ aj j → d j i = 0 := by
      intro i hi
      have hsj : sCol r n j.val i = 0 := by
        unfold sCol bfun
        have := haj_le_j j
        have hneg : ¬ (0 : ℤ) ≤ (i : ℤ) - (j.val : ℤ) - 1 := by omega
        simp only [hneg, ↓reduceIte]
      have hsk : ∀ l : Fin m, K j l * sCol r n l.val i = 0 := by
        intro l
        by_cases hl : aj j ≤ l.val ∧ l.val < aj j + w
        · have hsl : sCol r n l.val i = 0 := by
            unfold sCol bfun
            have hneg : ¬ (0 : ℤ) ≤ (i : ℤ) - (l.val : ℤ) - 1 := by omega
            simp only [hneg, ↓reduceIte]
          rw [hsl, mul_zero]
        · simp [K, hl]
      dsimp only [d]
      rw [Pi.sub_apply, Finset.sum_apply, hsj]
      simp [hsk]
    have hd_zero_ge : ∀ i : Fin n, aj j + w ≤ i.val → d j i = 0 := by
      intro i hi
      dsimp only [d]
      rw [Pi.sub_apply, Finset.sum_apply]
      have hsum : ∑ l : Fin m, (K j l • sCol r n l.val) i = ∑ l : Fin m, K j l * sCol r n l.val i := by
        apply Finset.sum_congr rfl; intro l _; simp
      rw [hsum, hreprod j i hi, sub_self]
    have hd_inf : ∀ i : Fin n, |d j i| ≤ Cs r * (w : ℝ) ^ (r - 1) := by
      intro i
      by_cases hi1 : i.val ≤ aj j
      · rw [hd_zero_le i hi1, abs_zero]; positivity
      · by_cases hi2 : aj j + w ≤ i.val
        · rw [hd_zero_ge i hi2, abs_zero]; positivity
        · have hsCol_le : ∀ l : ℕ, aj j ≤ l → |sCol r n l i| ≤ (w : ℝ) ^ (r - 1) := by
            intro l hl
            unfold sCol
            by_cases ht : 0 ≤ (i : ℤ) - (l : ℤ) - 1
            · have hnn : 0 ≤ bfun (r - 1) ((i : ℤ) - (l : ℤ) - 1) := by
                unfold bfun; simp only [ht, ↓reduceIte]; positivity
              rw [abs_of_nonneg hnn]
              refine (bfun_le_pow (r - 1) _ ht).trans ?_
              have hle_w : ((i : ℤ) - (l : ℤ) - 1).toNat ≤ w := by omega
              exact pow_le_pow_left₀ (Nat.cast_nonneg _) (by exact_mod_cast hle_w) (r - 1)
            · unfold bfun; simp only [ht, ↓reduceIte, abs_zero]; positivity
          dsimp only [d]
          rw [Pi.sub_apply, Finset.sum_apply]
          calc |sCol r n j.val i - ∑ l : Fin m, (K j l • sCol r n l.val) i|
              ≤ |sCol r n j.val i| + |∑ l : Fin m, (K j l • sCol r n l.val) i| := abs_sub _ _
            _ ≤ |sCol r n j.val i| + ∑ l : Fin m, |K j l| * |sCol r n l.val i| := by
                have htri : |∑ l : Fin m, (K j l • sCol r n l.val) i| ≤
                    ∑ l : Fin m, |K j l| * |sCol r n l.val i| := by
                  simpa only [Pi.smul_apply, smul_eq_mul, abs_mul] using
                    Finset.abs_sum_le_sum_abs (fun l => (K j l • sCol r n l.val) i) Finset.univ
                exact add_le_add le_rfl htri
            _ ≤ (w : ℝ) ^ (r - 1) + ∑ l : Fin m, |K j l| * (w : ℝ) ^ (r - 1) := by
                apply add_le_add (hsCol_le j.val (haj_le_j j))
                apply Finset.sum_le_sum; intro l _
                by_cases hl : aj j ≤ l.val ∧ l.val < aj j + w
                · exact mul_le_mul_of_nonneg_left (hsCol_le l.val hl.1) (abs_nonneg _)
                · simp [K, hl]
            _ = (1 + l1norm (K j)) * (w : ℝ) ^ (r - 1) := by
                unfold l1norm; rw [← Finset.sum_mul]; ring
            _ ≤ Cs r * (w : ℝ) ^ (r - 1) := by
                unfold Cs
                exact mul_le_mul_of_nonneg_right (add_le_add le_rfl (hK_l1 j)) (by positivity)
    let S := Finset.univ.filter fun i : Fin n => d j i ≠ 0
    have hcard_S : S.card ≤ w := by
      have hsub : S.image Fin.val ⊆ Finset.Ico (aj j) (aj j + w) := by
        intro idx hidx
        rcases Finset.mem_image.mp hidx with ⟨i, hi, rfl⟩
        rw [Finset.mem_filter] at hi
        rw [Finset.mem_Ico]
        refine ⟨?_, ?_⟩
        · by_contra hlt; exact hi.2 (hd_zero_le i (by omega))
        · by_contra hge; exact hi.2 (hd_zero_ge i (by omega))
      have h1 := Finset.card_le_card hsub
      rw [Finset.card_image_of_injective _ Fin.val_injective, Nat.card_Ico] at h1
      simpa using h1
    have hsq : l2sq (d j) ≤ (Cs r * (w : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 := by
      unfold l2sq
      have hsum_eq : ∑ i : Fin n, (d j i) ^ 2 = ∑ i ∈ S, (d j i) ^ 2 := by
        symm
        apply Finset.sum_subset (Finset.subset_univ S)
        intro i _ hi
        simp only [S, Finset.mem_filter, Finset.mem_univ, true_and, not_not] at hi
        rw [hi, zero_pow two_ne_zero]
      rw [hsum_eq]
      have hwsq : ((w : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 = (w : ℝ) * ((w : ℝ) ^ (r - 1)) ^ 2 := by
        rw [← Real.rpow_natCast, ← Real.rpow_mul hw0.le, ← pow_mul, ← pow_succ']
        have hexp : ((r : ℝ) - 1 / 2) * (2 : ℕ) = ((2 * r - 1 : ℕ) : ℝ) := by
          rw [Nat.cast_sub (by omega : 1 ≤ 2 * r)]; push_cast; ring
        rw [hexp, Real.rpow_natCast]
        congr 1; omega
      calc ∑ i ∈ S, (d j i) ^ 2
          ≤ ∑ _i ∈ S, (Cs r * (w : ℝ) ^ (r - 1)) ^ 2 := by
            apply Finset.sum_le_sum; intro i _
            rw [← sq_abs (d j i)]
            exact pow_le_pow_left₀ (abs_nonneg _) (hd_inf i) 2
        _ = (S.card : ℝ) * (Cs r * (w : ℝ) ^ (r - 1)) ^ 2 := by simp
        _ ≤ (w : ℝ) * (Cs r * (w : ℝ) ^ (r - 1)) ^ 2 :=
            mul_le_mul_of_nonneg_right (by exact_mod_cast hcard_S) (sq_nonneg _)
        _ = (Cs r * (w : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 := by
            rw [mul_pow, mul_pow, hwsq]; ring
    unfold l2norm
    exact (Real.sqrt_le_sqrt hsq).trans_eq (Real.sqrt_sq (by positivity))
  -- Define `u_w = ∑_j u*_j K^{(j)}`
  let us := ustar r n θs
  let uw : Fin m → ℝ := ∑ j : Fin m, us j • K j
  refine ⟨uw, ?_, ?_⟩
  · -- Bound 1: `‖u_w‖₂ ≤ C_s V* / (n^{r - 1} √w)`
    have hK_Cs : ∀ j : Fin m, l2norm (K j) ≤ Cs r / Real.sqrt w := fun j =>
      (hK_l2 j).trans (by
        rw [← div_div]
        exact div_le_div_of_nonneg_right hCs_ge (Real.sqrt_nonneg _))
    calc l2norm uw
        ≤ ∑ j : Fin m, |us j| * l2norm (K j) := l2norm_sum_smul_le us K
      _ ≤ ∑ j : Fin m, |us j| * (Cs r / Real.sqrt w) :=
          Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hK_Cs j) (abs_nonneg _)
      _ = l1norm us * (Cs r / Real.sqrt w) := by unfold l1norm; rw [← Finset.sum_mul]
      _ = Cs r * TVr r n θs / ((n : ℝ) ^ (r - 1) * Real.sqrt w) := by
          unfold TVr us ustar
          have hnp : (n : ℝ) ^ (r - 1) ≠ 0 := pow_ne_zero _ hn0.ne'
          field_simp [hnp]
  · -- Bound 2: `‖S (u* - u_w)‖_n ≤ C_s V* (w / n)^{r - 1/2}`
    have hSmul_eq : Smul r n (us - uw) = ∑ j : Fin m, us j • d j := by
      ext i
      simp only [Smul, Pi.sub_apply, uw, d, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]
      have h1 : ∑ l : Fin m, (us l - ∑ j : Fin m, us j * K j l) * sCol r n l.val i =
          (∑ l : Fin m, us l * sCol r n l.val i) -
            ∑ l : Fin m, (∑ j : Fin m, us j * K j l) * sCol r n l.val i := by
        rw [← Finset.sum_sub_distrib]
        apply Finset.sum_congr rfl; intro l _; ring
      have h2 : ∑ l : Fin m, (∑ j : Fin m, us j * K j l) * sCol r n l.val i =
          ∑ j : Fin m, us j * ∑ l : Fin m, K j l * sCol r n l.val i := by
        simp_rw [Finset.sum_mul]
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl; intro j _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl; intro l _; ring
      rw [h1, h2, ← Finset.sum_sub_distrib]
      apply Finset.sum_congr rfl; intro j _; ring
    have hl2_err : l2norm (Smul r n (us - uw)) ≤
        l1norm us * (Cs r * (w : ℝ) ^ ((r : ℝ) - 1 / 2)) := by
      rw [hSmul_eq]
      calc l2norm (∑ j : Fin m, us j • d j)
          ≤ ∑ j : Fin m, |us j| * l2norm (d j) := l2norm_sum_smul_le us d
        _ ≤ ∑ j : Fin m, |us j| * (Cs r * (w : ℝ) ^ ((r : ℝ) - 1 / 2)) :=
            Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hd_l2 j) (abs_nonneg _)
        _ = l1norm us * (Cs r * (w : ℝ) ^ ((r : ℝ) - 1 / 2)) := by
            unfold l1norm; rw [← Finset.sum_mul]
    have hemp_eq : empNorm (Smul r n (us - uw)) = l2norm (Smul r n (us - uw)) / Real.sqrt n := by
      unfold empNorm l2norm
      exact Real.sqrt_div (Finset.sum_nonneg fun _ _ => sq_nonneg _) n
    rw [hemp_eq]
    calc l2norm (Smul r n (us - uw)) / Real.sqrt n
        ≤ l1norm us * (Cs r * (w : ℝ) ^ ((r : ℝ) - 1 / 2)) / Real.sqrt n :=
          div_le_div_of_nonneg_right hl2_err (Real.sqrt_nonneg _)
      _ = Cs r * TVr r n θs * ((w : ℝ) / n) ^ ((r : ℝ) - 1 / 2) := by
          unfold TVr us ustar
          rw [Real.div_rpow hw0.le hn0.le]
          have hnr : (n : ℝ) ^ ((r : ℝ) - 1 / 2) = (n : ℝ) ^ (r - 1) * Real.sqrt n := by
            rw [Real.sqrt_eq_rpow, ← Real.rpow_natCast (n : ℝ) (r - 1), ← Real.rpow_add hn0]
            congr 1
            rw [Nat.cast_sub hr1]; push_cast; ring
          rw [hnr]
          have hnp : (n : ℝ) ^ (r - 1) ≠ 0 := pow_ne_zero _ hn0.ne'
          have hns : Real.sqrt n ≠ 0 := (Real.sqrt_pos.mpr hn0).ne'
          field_simp [hnp, hns]

end BQTF
