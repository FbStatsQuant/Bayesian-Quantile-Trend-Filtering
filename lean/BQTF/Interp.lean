import BQTF.Gram
import BQTF.Coord

/-!
# Interpolation inequality (appendix, Lemma `pf:lem:interp`)

Owner: Neon-A. The sup norm is bounded by the empirical norm and `TV^{(r)}`.
-/

open Finset

noncomputable section

namespace BQTF

/-- `bfun p t ≤ (t.toNat : ℝ)^p / p!` for `0 ≤ t`. -/
private lemma bfun_le_pow_div_fact (p : ℕ) (t : ℤ) (ht : 0 ≤ t) :
    bfun p t ≤ ((t.toNat : ℝ) ^ p) / (p.factorial : ℝ) := by
  rw [bfun]
  simp only [ht, ↓reduceIte]
  have hfac : (0 : ℝ) < p.factorial := Nat.cast_pos.mpr (Nat.factorial_pos p)
  rw [le_div_iff₀ hfac]
  have hnat : t.toNat.choose p * p.factorial ≤ t.toNat ^ p := by
    rw [mul_comm, ← Nat.descFactorial_eq_factorial_mul_choose]
    exact Nat.descFactorial_le_pow t.toNat p
  exact_mod_cast hnat

/-- Sup-norm vs `ℓ₂`-norm comparison for polynomials on `w ≥ r ≥ 1` grid points:
`|p k| ≤ √((r / g_r) / w) * ‖p‖₂`. -/
private lemma poly_abs_le_sqrt_l2norm (r w : ℕ) (hr : 1 ≤ r) (hw : r ≤ w)
    (p : Fin w → ℝ) (hp : p ∈ polySpace r w) (k : Fin w) :
    |p k| ≤ Real.sqrt ((r : ℝ) / gr r / (w : ℝ)) * l2norm p := by
  have hw0 : (0 : ℝ) < w := Nat.cast_pos.mpr (by omega)
  have hgr_pos : 0 < gr r := (gr_pos r hr).1
  rw [polySpace, Submodule.mem_span_range_iff_exists_fun] at hp
  obtain ⟨α, rfl⟩ := hp
  let v : Fin r → ℝ := fun a => α a * (w : ℝ) ^ (a : ℕ)
  have hpk : ∀ j : Fin w,
      (∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) j =
        ∑ a : Fin r, v a * ((j.val : ℝ) / (w : ℝ)) ^ (a : ℕ) := by
    intro j
    rw [Finset.sum_apply]
    apply Finset.sum_congr rfl; intro a _
    simp only [Pi.smul_apply, smul_eq_mul, v, div_pow]
    have hwa : (w : ℝ) ^ (a : ℕ) ≠ 0 := pow_ne_zero _ hw0.ne'
    field_simp [hwa]
  have hcs : ((∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) k) ^ 2 ≤
      (r : ℝ) * l2sq v := by
    rw [hpk k]
    have h1 := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ v
      (fun a : Fin r => ((k.val : ℝ) / (w : ℝ)) ^ (a : ℕ))
    have h2 : ∑ a : Fin r, (((k.val : ℝ) / (w : ℝ)) ^ (a : ℕ)) ^ 2 ≤ (r : ℝ) := by
      have hk0 : 0 ≤ (k.val : ℝ) / (w : ℝ) := by positivity
      have hk1 : (k.val : ℝ) / (w : ℝ) ≤ 1 := by
        rw [div_le_one hw0]; exact_mod_cast k.isLt.le
      calc ∑ a : Fin r, (((k.val : ℝ) / (w : ℝ)) ^ (a : ℕ)) ^ 2
          ≤ ∑ _a : Fin r, (1 : ℝ) := by
            apply Finset.sum_le_sum; intro a _
            have ha0 : 0 ≤ ((k.val : ℝ) / (w : ℝ)) ^ (a : ℕ) := pow_nonneg hk0 _
            have ha1 : ((k.val : ℝ) / (w : ℝ)) ^ (a : ℕ) ≤ 1 := pow_le_one₀ hk0 hk1
            nlinarith
        _ = (r : ℝ) := by simp
    calc (∑ a : Fin r, v a * ((k.val : ℝ) / (w : ℝ)) ^ (a : ℕ)) ^ 2
        ≤ (∑ a : Fin r, v a ^ 2) * (∑ a : Fin r, (((k.val : ℝ) / (w : ℝ)) ^ (a : ℕ)) ^ 2) := h1
      _ ≤ l2sq v * (r : ℝ) := mul_le_mul_of_nonneg_left h2 (Finset.sum_nonneg fun _ _ => sq_nonneg _)
      _ = (r : ℝ) * l2sq v := mul_comm _ _
  have hgram : gramQuad r w v =
      l2sq (∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) / (w : ℝ) := by
    unfold gramQuad l2sq
    congr 1
    rw [← Fin.sum_univ_eq_sum_range
      (fun j => (∑ a : Fin r, v a * ((j : ℝ) / (w : ℝ)) ^ (a : ℕ)) ^ 2) w]
    apply Finset.sum_congr rfl; intro j _
    rw [hpk j]
  have hv_le : l2sq v ≤
      l2sq (∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) / (gr r * (w : ℝ)) := by
    have hgr := gr_le_gramQuad r w hr hw v
    rw [hgram] at hgr
    rw [le_div_iff₀ (mul_pos hgr_pos hw0)]
    have hmul := (le_div_iff₀ hw0).mp hgr
    linarith
  have hsq : ((∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) k) ^ 2 ≤
      ((r : ℝ) / gr r / (w : ℝ)) *
        l2sq (∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) := by
    calc ((∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) k) ^ 2
        ≤ (r : ℝ) * l2sq v := hcs
      _ ≤ (r : ℝ) * (l2sq (∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) /
            (gr r * (w : ℝ))) := mul_le_mul_of_nonneg_left hv_le (Nat.cast_nonneg r)
      _ = ((r : ℝ) / gr r / (w : ℝ)) *
            l2sq (∑ a : Fin r, α a • fun i : Fin w => (i : ℝ) ^ (a : ℕ)) := by
          field_simp [hgr_pos.ne', hw0.ne']
  rw [← Real.sqrt_sq_eq_abs]
  unfold l2norm
  rw [← Real.sqrt_mul (by positivity)]
  exact Real.sqrt_le_sqrt hsq

/-- Windowed polynomial approximation: on any window of size `w` with `r ≤ w ≤ n`, `δ_W` is within
`w^{r-1} TV^{(r)}(δ) / ((r-1)! n^{r-1})` in `ℓ_∞` of a polynomial in `polySpace r w`.
Handles the boundary case `w = r` separately (paper gap C-04: Lemma `coord` needs `w > r`). -/
private lemma window_poly_approx (r n w a0 : ℕ) (hr : 2 ≤ r) (hn : r < n)
    (hw : r ≤ w) (ha0 : a0 + w ≤ n) (δ : Fin n → ℝ) :
    let δW : Fin w → ℝ := fun k => δ ⟨a0 + k.val, by have := k.isLt; omega⟩
    ∃ p : Fin w → ℝ, p ∈ polySpace r w ∧
      ∀ k : Fin w, |δW k - p k| ≤
        (w : ℝ) ^ (r - 1) * TVr r n δ / (((r - 1).factorial : ℝ) * (n : ℝ) ^ (r - 1)) := by
  intro δW
  have hr1 : 1 ≤ r := by omega
  have hn0 : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
  have hTV_nn : 0 ≤ TVr r n δ := by
    unfold TVr l1norm
    exact mul_nonneg (pow_nonneg (Nat.cast_nonneg n) _) (Finset.sum_nonneg fun _ _ => abs_nonneg _)
  by_cases hwr : w = r
  · -- Boundary case `w = r`: `polySpace r r = ⊤`, so `δW` itself is a polynomial (error = 0).
    subst w
    have htop : polySpace r r = ⊤ := by
      apply Submodule.eq_top_of_finrank_eq
      have hli := monomial_linearIndependent r r (le_refl r)
      change Module.finrank ℝ (Submodule.span ℝ (Set.range (monomial r r))) = _
      rw [finrank_span_eq_card hli, Fintype.card_fin, Module.finrank_fin_fun]
    refine ⟨δW, by rw [htop]; trivial, fun k => ?_⟩
    rw [sub_self, abs_zero]
    positivity
  · -- Main case `r < w`: apply `coordMap_bijective` on the window of length `w`.
    have hlt : r < w := by omega
    obtain ⟨⟨c, uW⟩, hcu⟩ := (coordMap_bijective r w hr1 hlt).1.2 δW
    have huW_eq : uW = diffOp r w δW := by
      have hD := (coordMap_bijective r w hr1 hlt).2 (c, uW)
      rw [hcu] at hD
      exact hD.symm
    let p : Fin w → ℝ := Nmul r w c
    refine ⟨p, Nmul_mem_polySpace r w hw c, fun k => ?_⟩
    have hdiff : δW - p = Smul r w uW := by
      rw [← hcu]
      unfold coordMap p
      abel
    have hdiff_k : δW k - p k = Smul r w uW k := congr_fun hdiff k
    rw [hdiff_k]
    have hl1_le : l1norm uW ≤ l1norm (diffOp r n δ) := by
      unfold l1norm
      rw [huW_eq]
      let emb : Fin (w - r) ↪ Fin (n - r) :=
        ⟨fun j => ⟨a0 + j.val, by have := j.isLt; omega⟩, fun j₁ j₂ h => by
          ext; have := congrArg Fin.val h; dsimp at this; omega⟩
      have hcongr : ∀ j : Fin (w - r), diffOp r w δW j = diffOp r n δ (emb j) := by
        intro j
        unfold diffOp
        apply Finset.sum_congr rfl; intro l _
        congr 2
        change δ ⟨a0 + (j.val + l.val), _⟩ = δ ⟨(a0 + j.val) + l.val, _⟩
        congr 1; ext; dsimp only; omega
      calc ∑ j : Fin (w - r), |diffOp r w δW j|
          = ∑ j : Fin (w - r), |diffOp r n δ (emb j)| :=
            Finset.sum_congr rfl fun j _ => by rw [hcongr j]
        _ = ∑ j ∈ Finset.univ.map emb, |diffOp r n δ j| := by
            rw [Finset.sum_map]
        _ ≤ ∑ j : Fin (n - r), |diffOp r n δ j| :=
            Finset.sum_le_univ_sum_of_nonneg fun _ => abs_nonneg _
    have hsCol_le : ∀ j : Fin (w - r), |sCol r w j.val k| ≤
        (w : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) := by
      intro j
      unfold sCol
      by_cases ht : 0 ≤ (k : ℤ) - (j.val : ℤ) - 1
      · have hnn : 0 ≤ bfun (r - 1) ((k : ℤ) - (j.val : ℤ) - 1) := by
          unfold bfun; simp only [ht, ↓reduceIte]; positivity
        rw [abs_of_nonneg hnn]
        refine (bfun_le_pow_div_fact (r - 1) _ ht).trans ?_
        have hle_w : ((k : ℤ) - (j.val : ℤ) - 1).toNat ≤ w := by have := k.isLt; omega
        exact div_le_div_of_nonneg_right
          (pow_le_pow_left₀ (Nat.cast_nonneg _) (by exact_mod_cast hle_w) (r - 1))
          (Nat.cast_nonneg _)
      · unfold bfun; simp only [ht, ↓reduceIte, abs_zero]; positivity
    have htri : |Smul r w uW k| ≤
        l1norm uW * ((w : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) := by
      unfold Smul l1norm
      calc |∑ j : Fin (w - r), uW j * sCol r w j.val k|
          ≤ ∑ j : Fin (w - r), |uW j * sCol r w j.val k| :=
            Finset.abs_sum_le_sum_abs _ _
        _ = ∑ j : Fin (w - r), |uW j| * |sCol r w j.val k| := by
            apply Finset.sum_congr rfl; intro j _; exact abs_mul _ _
        _ ≤ ∑ j : Fin (w - r), |uW j| * ((w : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) :=
            Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hsCol_le j) (abs_nonneg _)
        _ = (∑ j : Fin (w - r), |uW j|) * ((w : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) :=
            (Finset.sum_mul _ _ _).symm
    calc |Smul r w uW k|
        ≤ l1norm uW * ((w : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) := htri
      _ ≤ l1norm (diffOp r n δ) * ((w : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) :=
          mul_le_mul_of_nonneg_right hl1_le (by positivity)
      _ = (w : ℝ) ^ (r - 1) * TVr r n δ / (((r - 1).factorial : ℝ) * (n : ℝ) ^ (r - 1)) := by
          unfold TVr
          have hnp : (n : ℝ) ^ (r - 1) ≠ 0 := pow_ne_zero _ hn0.ne'
          have hfac : ((r - 1).factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero _)
          field_simp [hnp, hfac]

/-- Lemma `pf:lem:interp`: there is `C_I` depending only on `r` such that for `n > r` and every
`δ ∈ ℝⁿ`, `‖δ‖_∞ ≤ C_I {‖δ‖_n + ‖δ‖_n^{(2r−2)/(2r−1)} TV^{(r)}(δ)^{1/(2r−1)}}`. -/
theorem interp (r : ℕ) (hr : 2 ≤ r) :
    ∃ CI : ℝ, 0 < CI ∧ ∀ n : ℕ, r < n → ∀ (δ : Fin n → ℝ) (i : Fin n),
      |δ i| ≤ CI * (empNorm δ + empNorm δ ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) *
        TVr r n δ ^ ((1 : ℝ) / (2 * r - 1))) := by
  have hr1 : 1 ≤ r := by omega
  have hgr_pos : 0 < gr r := (gr_pos r hr1).1
  have hgr_le1 : gr r ≤ 1 := (gr_pos r hr1).2
  let C0 : ℝ := (r : ℝ) / gr r
  have hC0_pos : 0 < C0 := div_pos (Nat.cast_pos.mpr (by omega)) hgr_pos
  have hC0_ge_r : (r : ℝ) ≤ C0 := by
    dsimp only [C0]
    rw [le_div_iff₀ hgr_pos]
    nlinarith [Nat.cast_nonneg (α := ℝ) r]
  let Cp : ℝ := (1 + Real.sqrt C0) / ((r - 1).factorial : ℝ)
  have hCp_pos : 0 < Cp := div_pos (by positivity) (Nat.cast_pos.mpr (Nat.factorial_pos _))
  let CI : ℝ := Real.sqrt C0 + (2 : ℝ) ^ (r - 1) * Cp
  have hCI_pos : 0 < CI := by positivity
  refine ⟨CI, hCI_pos, fun n hn δ i => ?_⟩
  have hn0 : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
  let a : ℝ := empNorm δ
  let T : ℝ := TVr r n δ
  have ha_nn : 0 ≤ a := Real.sqrt_nonneg _
  have hT_nn : 0 ≤ T := by
    unfold T TVr l1norm
    exact mul_nonneg (pow_nonneg (Nat.cast_nonneg n) _) (Finset.sum_nonneg fun _ _ => abs_nonneg _)
  have hl2_eq : l2norm δ = Real.sqrt n * a := by
    have hl2_nn : 0 ≤ l2sq δ := Finset.sum_nonneg fun _ _ => sq_nonneg _
    unfold a empNorm l2norm
    rw [Real.sqrt_div hl2_nn, mul_div_cancel₀ _ (Real.sqrt_pos.mpr hn0).ne']
  -- Window bound for any `r ≤ w ≤ n`
  have hwin : ∀ w : ℕ, r ≤ w → w ≤ n →
      |δ i| ≤ Real.sqrt C0 * a * Real.sqrt ((n : ℝ) / (w : ℝ)) +
        Cp * T * ((w : ℝ) / (n : ℝ)) ^ (r - 1) := by
    intro w hw hwn
    have hw0 : (0 : ℝ) < w := Nat.cast_pos.mpr (by omega)
    let a0 : ℕ := min i.val (n - w)
    have ha0_le_i : a0 ≤ i.val := min_le_left _ _
    have hi_lt : i.val < a0 + w := by
      dsimp only [a0]
      by_cases h : i.val ≤ n - w
      · rw [min_eq_left h]; omega
      · rw [min_eq_right (by omega)]; have := i.isLt; omega
    have ha0_add : a0 + w ≤ n := by
      have : a0 ≤ n - w := min_le_right _ _
      omega
    let δW : Fin w → ℝ := fun k => δ ⟨a0 + k.val, by have := k.isLt; omega⟩
    let k0 : Fin w := ⟨i.val - a0, by omega⟩
    have hδW_k0 : δW k0 = δ i := by
      dsimp only [δW, k0]; congr 1; ext; dsimp; omega
    obtain ⟨p, hp_mem, hp_err⟩ := window_poly_approx r n w a0 hr hn hw ha0_add δ
    let ρw : ℝ := (w : ℝ) ^ (r - 1) * T / (((r - 1).factorial : ℝ) * (n : ℝ) ^ (r - 1))
    have hρw_nn : 0 ≤ ρw := by positivity
    have hδW_l2 : l2norm δW ≤ Real.sqrt n * a := by
      rw [← hl2_eq]
      apply Real.sqrt_le_sqrt
      unfold l2sq
      let emb : Fin w ↪ Fin n :=
        ⟨fun k => ⟨a0 + k.val, by have := k.isLt; omega⟩, fun k₁ k₂ h => by
          ext; have := congrArg Fin.val h; dsimp at this; omega⟩
      calc ∑ k : Fin w, (δW k) ^ 2
          = ∑ k ∈ Finset.univ.map emb, (δ k) ^ 2 := by rw [Finset.sum_map]; rfl
        _ ≤ ∑ k : Fin n, (δ k) ^ 2 := Finset.sum_le_univ_sum_of_nonneg fun _ => sq_nonneg _
    have herr_l2 : l2norm (δW - p) ≤ Real.sqrt w * ρw := by
      have hsq : l2sq (δW - p) ≤ (Real.sqrt w * ρw) ^ 2 := by
        unfold l2sq
        calc ∑ k : Fin w, (δW k - p k) ^ 2
            ≤ ∑ _k : Fin w, ρw ^ 2 := by
              apply Finset.sum_le_sum; intro k _
              rw [← sq_abs (δW k - p k)]
              exact pow_le_pow_left₀ (abs_nonneg _) (hp_err k) 2
          _ = (w : ℝ) * ρw ^ 2 := by simp
          _ = (Real.sqrt w * ρw) ^ 2 := by rw [mul_pow, Real.sq_sqrt hw0.le]
      unfold l2norm
      exact (Real.sqrt_le_sqrt hsq).trans_eq (Real.sqrt_sq (by positivity))
    have hp_l2 : l2norm p ≤ Real.sqrt n * a + Real.sqrt w * ρw := by
      have htri : l2norm p ≤ l2norm δW + l2norm (δW - p) := by
        rw [← norm_toE, ← norm_toE, ← norm_toE]
        have hdecomp : toE w p = toE w δW - toE w (δW - p) := by
          rw [← map_sub]; congr 1; abel
        rw [hdecomp]
        exact norm_sub_le _ _
      linarith
    have hp_k0 : |p k0| ≤ Real.sqrt (C0 / (w : ℝ)) * (Real.sqrt n * a + Real.sqrt w * ρw) :=
      (poly_abs_le_sqrt_l2norm r w hr1 hw p hp_mem k0).trans
        (mul_le_mul_of_nonneg_left hp_l2 (Real.sqrt_nonneg _))
    have htri_i : |δ i| ≤ |p k0| + |δW k0 - p k0| := by
      rw [← hδW_k0]
      calc |δW k0| = |p k0 + (δW k0 - p k0)| := by ring_nf
        _ ≤ |p k0| + |δW k0 - p k0| := abs_add_le _ _
    have hterm1 : Real.sqrt (C0 / (w : ℝ)) * (Real.sqrt n * a) =
        Real.sqrt C0 * a * Real.sqrt ((n : ℝ) / (w : ℝ)) := by
      rw [Real.sqrt_div hC0_pos.le, Real.sqrt_div hn0.le]
      ring
    have hterm2 : Real.sqrt (C0 / (w : ℝ)) * (Real.sqrt w * ρw) + ρw =
        Cp * T * ((w : ℝ) / (n : ℝ)) ^ (r - 1) := by
      rw [Real.sqrt_div hC0_pos.le]
      have hsw : Real.sqrt w ≠ 0 := (Real.sqrt_pos.mpr hw0).ne'
      have h1 : Real.sqrt C0 / Real.sqrt w * (Real.sqrt w * ρw) + ρw =
          (1 + Real.sqrt C0) * ρw := by field_simp [hsw]; ring
      rw [h1]
      dsimp only [Cp, ρw]
      rw [div_pow]
      have hnp : (n : ℝ) ^ (r - 1) ≠ 0 := pow_ne_zero _ hn0.ne'
      have hfac : ((r - 1).factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero _)
      field_simp [hnp, hfac]
    calc |δ i| ≤ |p k0| + |δW k0 - p k0| := htri_i
      _ ≤ Real.sqrt (C0 / (w : ℝ)) * (Real.sqrt n * a + Real.sqrt w * ρw) + ρw :=
          add_le_add hp_k0 (hp_err k0)
      _ = Real.sqrt (C0 / (w : ℝ)) * (Real.sqrt n * a) +
            (Real.sqrt (C0 / (w : ℝ)) * (Real.sqrt w * ρw) + ρw) := by ring
      _ = Real.sqrt C0 * a * Real.sqrt ((n : ℝ) / (w : ℝ)) +
            Cp * T * ((w : ℝ) / (n : ℝ)) ^ (r - 1) := by rw [hterm1, hterm2]
  -- Case split on `a = 0`, `T ≤ a`, and `a < T`
  have hpow_nn : 0 ≤ a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1)) :=
    mul_nonneg (Real.rpow_nonneg ha_nn _) (Real.rpow_nonneg hT_nn _)
  by_cases ha0 : a = 0
  · have hδ0 : δ i = 0 := by
      have hl20 : l2sq δ = 0 := by
        have h1 : Real.sqrt (l2sq δ / (n : ℝ)) = 0 := ha0
        have h2 : l2sq δ / (n : ℝ) = 0 :=
          (Real.sqrt_eq_zero (div_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) hn0.le)).mp h1
        exact (div_eq_zero_iff.mp h2).resolve_right hn0.ne'
      have hi2 : δ i ^ 2 ≤ l2sq δ :=
        Finset.single_le_sum (fun j _ => sq_nonneg (δ j)) (Finset.mem_univ i)
      rw [hl20] at hi2
      exact sq_eq_zero_iff.mp (le_antisymm hi2 (sq_nonneg _))
    rw [hδ0, abs_zero]
    exact mul_nonneg hCI_pos.le (add_nonneg ha_nn hpow_nn)
  · have ha_pos : 0 < a := lt_of_le_of_ne ha_nn (Ne.symm ha0)
    by_cases hTa : T ≤ a
    · -- Case 1: `T ≤ a`, take `w = n`.
      have h1 := hwin n hn.le (le_refl n)
      rw [div_self hn0.ne', Real.sqrt_one, one_pow, mul_one, mul_one] at h1
      have h2pow : (1 : ℝ) ≤ (2 : ℝ) ^ (r - 1) := one_le_pow₀ (by norm_num)
      calc |δ i| ≤ Real.sqrt C0 * a + Cp * T := h1
        _ ≤ Real.sqrt C0 * a + Cp * a := add_le_add le_rfl (mul_le_mul_of_nonneg_left hTa hCp_pos.le)
        _ = (Real.sqrt C0 + Cp) * a := by ring
        _ ≤ CI * a := by
            apply mul_le_mul_of_nonneg_right _ ha_pos.le
            dsimp only [CI]
            nlinarith
        _ ≤ CI * (a + a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1))) :=
            mul_le_mul_of_nonneg_left (le_add_of_nonneg_right hpow_nn) hCI_pos.le
    · -- Case 2: `a < T`.
      have hT_pos : 0 < T := lt_of_lt_of_le ha_pos (le_of_not_ge hTa)
      have h2r1_pos : (0 : ℝ) < (2 * r - 1 : ℝ) := by
        have : (2 : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr
        linarith
      let xstar : ℝ := (a / T) ^ ((2 : ℝ) / (2 * r - 1))
      have hxstar_pos : 0 < xstar := Real.rpow_pos_of_pos (div_pos ha_pos hT_pos) _
      have hxstar_lt1 : xstar < 1 := by
        apply Real.rpow_lt_one (div_nonneg ha_pos.le hT_pos.le)
        · rw [div_lt_one hT_pos]; linarith
        · exact div_pos two_pos h2r1_pos
      -- Key rpow identities relating `xstar` to `a^{(2r-2)/(2r-1)} T^{1/(2r-1)}`
      have hterm_a : a * xstar ^ (-(1 / 2 : ℝ)) =
          a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1)) := by
        dsimp only [xstar]
        rw [← Real.rpow_mul (div_nonneg ha_pos.le hT_pos.le), Real.div_rpow ha_pos.le hT_pos.le]
        have hexp : (2 : ℝ) / (2 * r - 1) * -(1 / 2 : ℝ) = -((1 : ℝ) / (2 * r - 1)) := by ring
        rw [hexp, Real.rpow_neg ha_pos.le, Real.rpow_neg hT_pos.le, div_inv_eq_mul]
        rw [← mul_assoc, ← Real.rpow_neg ha_pos.le]
        have ha1 : a * a ^ (-((1 : ℝ) / (2 * r - 1))) = a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) := by
          conv_lhs => arg 1; rw [← Real.rpow_one a]
          rw [← Real.rpow_add ha_pos]
          congr 1; field_simp [h2r1_pos.ne']; ring
        rw [ha1]
      have hterm_T : T * xstar ^ (r - 1) =
          a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1)) := by
        dsimp only [xstar]
        rw [← Real.rpow_natCast, ← Real.rpow_mul (div_nonneg ha_pos.le hT_pos.le),
          Real.div_rpow ha_pos.le hT_pos.le]
        have hexp : (2 : ℝ) / (2 * r - 1) * ((r - 1 : ℕ) : ℝ) = (2 * r - 2 : ℝ) / (2 * r - 1) := by
          rw [Nat.cast_sub hr1]; push_cast; ring
        rw [hexp]
        have hT1 : T * (a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) / T ^ ((2 * r - 2 : ℝ) / (2 * r - 1))) =
            a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * (T / T ^ ((2 * r - 2 : ℝ) / (2 * r - 1))) := by
          ring
        rw [hT1]
        congr 1
        conv_lhs => arg 1; rw [← Real.rpow_one T]
        rw [← Real.rpow_sub hT_pos]
        congr 1; field_simp [h2r1_pos.ne']; ring
      by_cases hnx : (r : ℝ) ≤ (n : ℝ) * xstar
      · -- Subcase 2a: `n x* ≥ r`, take `w = ⌈n x*⌉`.
        let w : ℕ := Nat.ceil ((n : ℝ) * xstar)
        have hw_ge_r : r ≤ w := Nat.le_ceil _ |> fun h => by
          have : (r : ℝ) ≤ (w : ℝ) := hnx.trans h
          exact_mod_cast this
        have hw_le_n : w ≤ n := by
          apply Nat.ceil_le.mpr
          nlinarith
        have hw0 : (0 : ℝ) < w := Nat.cast_pos.mpr (by omega)
        have hwn_ge : xstar ≤ (w : ℝ) / (n : ℝ) := by
          rw [le_div_iff₀ hn0, mul_comm]
          exact Nat.le_ceil ((n : ℝ) * xstar)
        have hwn_le : (w : ℝ) / (n : ℝ) ≤ 2 * xstar := by
          rw [div_le_iff₀ hn0]
          have hlt1 : (w : ℝ) < (n : ℝ) * xstar + 1 := Nat.ceil_lt_add_one (by positivity)
          have hge1 : (1 : ℝ) ≤ (n : ℝ) * xstar := by
            have : (1 : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr1
            linarith
          linarith
        have hsqrt_le : Real.sqrt ((n : ℝ) / (w : ℝ)) ≤ xstar ^ (-(1 / 2 : ℝ)) := by
          have hinv : (n : ℝ) / (w : ℝ) ≤ xstar⁻¹ := by
            rw [div_le_iff₀ hw0]
            have h1 := (le_div_iff₀ hn0).mp hwn_ge
            have h2 := mul_le_mul_of_nonneg_left h1 (inv_nonneg.mpr hxstar_pos.le)
            rw [← mul_assoc, inv_mul_cancel₀ hxstar_pos.ne', one_mul] at h2
            linarith
          calc Real.sqrt ((n : ℝ) / (w : ℝ))
              ≤ Real.sqrt (xstar⁻¹) := Real.sqrt_le_sqrt hinv
            _ = xstar ^ (-(1 / 2 : ℝ)) := by
                rw [Real.sqrt_eq_rpow, Real.inv_rpow hxstar_pos.le, ← Real.rpow_neg hxstar_pos.le]
        have hpow_le : ((w : ℝ) / (n : ℝ)) ^ (r - 1) ≤ (2 : ℝ) ^ (r - 1) * xstar ^ (r - 1) := by
          rw [← mul_pow]
          exact pow_le_pow_left₀ (by positivity) hwn_le (r - 1)
        have h1 := hwin w hw_ge_r hw_le_n
        calc |δ i|
            ≤ Real.sqrt C0 * a * Real.sqrt ((n : ℝ) / (w : ℝ)) +
                Cp * T * ((w : ℝ) / (n : ℝ)) ^ (r - 1) := h1
          _ ≤ Real.sqrt C0 * a * xstar ^ (-(1 / 2 : ℝ)) +
                Cp * T * ((2 : ℝ) ^ (r - 1) * xstar ^ (r - 1)) := by
              apply add_le_add
              · exact mul_le_mul_of_nonneg_left hsqrt_le (by positivity)
              · exact mul_le_mul_of_nonneg_left hpow_le (by positivity)
          _ = Real.sqrt C0 * (a * xstar ^ (-(1 / 2 : ℝ))) +
                (2 : ℝ) ^ (r - 1) * Cp * (T * xstar ^ (r - 1)) := by ring
          _ = CI * (a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1))) := by
              rw [hterm_a, hterm_T]; dsimp only [CI]; ring
          _ ≤ CI * (a + a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1))) :=
              mul_le_mul_of_nonneg_left (le_add_of_nonneg_left ha_nn) hCI_pos.le
      · -- Subcase 2b: `n x* < r`, use `|δ i| ≤ √n * a`.
        have hnx_lt : (n : ℝ) * xstar < (r : ℝ) := lt_of_not_ge hnx
        have hδ_le : |δ i| ≤ Real.sqrt n * a := by
          rw [← hl2_eq, ← Real.sqrt_sq_eq_abs]
          apply Real.sqrt_le_sqrt
          exact Finset.single_le_sum (fun j _ => sq_nonneg (δ j)) (Finset.mem_univ i)
        have hsn_le : Real.sqrt n ≤ Real.sqrt C0 * xstar ^ (-(1 / 2 : ℝ)) := by
          have hn_le : (n : ℝ) ≤ C0 * xstar⁻¹ := by
            have h1 : (n : ℝ) < (r : ℝ) * xstar⁻¹ := by
              rw [lt_mul_inv_iff₀ hxstar_pos]; exact hnx_lt
            have h2 : (r : ℝ) * xstar⁻¹ ≤ C0 * xstar⁻¹ :=
              mul_le_mul_of_nonneg_right hC0_ge_r (inv_nonneg.mpr hxstar_pos.le)
            linarith
          calc Real.sqrt n
              ≤ Real.sqrt (C0 * xstar⁻¹) := Real.sqrt_le_sqrt hn_le
            _ = Real.sqrt C0 * xstar ^ (-(1 / 2 : ℝ)) := by
                rw [Real.sqrt_mul hC0_pos.le, Real.sqrt_eq_rpow xstar⁻¹,
                  Real.inv_rpow hxstar_pos.le, ← Real.rpow_neg hxstar_pos.le]
        calc |δ i| ≤ Real.sqrt n * a := hδ_le
          _ ≤ (Real.sqrt C0 * xstar ^ (-(1 / 2 : ℝ))) * a :=
              mul_le_mul_of_nonneg_right hsn_le ha_pos.le
          _ = Real.sqrt C0 * (a * xstar ^ (-(1 / 2 : ℝ))) := by ring
          _ = Real.sqrt C0 * (a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1))) := by
              rw [hterm_a]
          _ ≤ CI * (a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1))) := by
              apply mul_le_mul_of_nonneg_right _ hpow_nn
              dsimp only [CI]; linarith [mul_pos (pow_pos (by norm_num : (0 : ℝ) < 2) (r - 1)) hCp_pos]
          _ ≤ CI * (a + a ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) * T ^ ((1 : ℝ) / (2 * r - 1))) :=
              mul_le_mul_of_nonneg_left (le_add_of_nonneg_left ha_nn) hCI_pos.le

end BQTF
