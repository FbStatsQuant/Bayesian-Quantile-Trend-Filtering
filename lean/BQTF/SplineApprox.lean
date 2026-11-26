import BQTF.Coord

/-!
# Spline approximation (appendix, Lemma `pf:lem:F`)

Owner: Neon-A. `V_J` (discrete splines with `J'` equally spaced knots), `P_J`, the bounds
`h ≤ 2n/J`, `dim V_J ≤ J + r`, `(I − P_J) N = 0` and eq. `pf:eq:F`.
-/

open Finset

noncomputable section

namespace BQTF

/-- `c_∞ = (1 + 2^{r−1}) (2r)^{r−1} / (r−1)!`. -/
def cInf (r : ℕ) : ℝ := (1 + 2 ^ (r - 1)) * (2 * r : ℝ) ^ (r - 1) / (Nat.factorial (r - 1))

/-- `c_F = √r c_∞`. -/
def cF (r : ℕ) : ℝ := Real.sqrt r * cInf r

/-- `c_op = √3 r c_∞`. -/
def cOp (r : ℕ) : ℝ := Real.sqrt 3 * r * cInf r

/-! ## Setting bounds and polynomial invariance -/

/-- Setting of Lemma `pf:lem:F`: `h = ⌈m/J⌉ ≤ 2n/J` and `dim V_J ≤ J + r`. -/
theorem hJ_le (r n J : ℕ) (hn : r < n) (hJpos : 1 ≤ J) (hJm : J ≤ n - r) :
    1 ≤ hJ (n - r) J ∧ (hJ (n - r) J : ℝ) ≤ 2 * n / J ∧
    Module.finrank ℝ (VJ r n J) ≤ J + r := by
  let m := n - r
  let h := hJ m J
  have hh1 : 1 ≤ h := by
    change 1 ≤ (m + J - 1) / J
    exact Nat.div_pos (by omega) (by omega)
  have hh_mul : h * J ≤ 2 * n := by
    have h1 : ((m + J - 1) / J) * J ≤ m + J - 1 := Nat.div_mul_le_self (m + J - 1) J
    change ((m + J - 1) / J) * J ≤ 2 * n
    omega
  have hh_real : (h : ℝ) ≤ 2 * n / J := by
    have hJ0 : (0 : ℝ) < J := Nat.cast_pos.mpr (by omega)
    rw [le_div_iff₀ hJ0]
    exact_mod_cast hh_mul
  have hm_le_hJ : m ≤ h * J := by
    have hmod : (m + J - 1) % J < J := Nat.mod_lt _ (by omega)
    have hdiv := Nat.div_add_mod (m + J - 1) J
    change m ≤ ((m + J - 1) / J) * J
    rw [mul_comm]
    omega
  have hJ'_le : J' m J ≤ J := by
    change m / h ≤ J
    exact (Nat.div_le_div_right hm_le_hJ).trans_eq (Nat.mul_div_cancel_left J (by omega))
  have hfin_poly : Module.finrank ℝ (polySpace r n) ≤ r := by
    have hle := finrank_span_le_card (R := ℝ)
      (Set.range fun p : Fin r => fun i : Fin n => (i : ℝ) ^ (p : ℕ))
    have hcard : (Set.range fun p : Fin r => fun i : Fin n => (i : ℝ) ^ (p : ℕ)).toFinset.card ≤ r := by
      have h1 := Fintype.card_range_le (fun p : Fin r => fun i : Fin n => (i : ℝ) ^ (p : ℕ))
      rw [Set.toFinset_card]
      simpa using h1
    exact hle.trans hcard
  have hfin_spl : Module.finrank ℝ (Submodule.span ℝ
      (Set.range fun l : Fin (J' m J) => sCol r n ((l.val + 1) * h - 1))) ≤ J' m J := by
    have hle := finrank_span_le_card (R := ℝ)
      (Set.range fun l : Fin (J' m J) => sCol r n ((l.val + 1) * h - 1))
    have hcard : (Set.range fun l : Fin (J' m J) => sCol r n ((l.val + 1) * h - 1)).toFinset.card ≤
        J' m J := by
      have h1 := Fintype.card_range_le (fun l : Fin (J' m J) => sCol r n ((l.val + 1) * h - 1))
      rw [Set.toFinset_card]
      simpa using h1
    exact hle.trans hcard
  have hfin_VJ : Module.finrank ℝ (VJ r n J) ≤ J + r := by
    have hsup := Submodule.finrank_sup_add_finrank_inf_eq (polySpace r n)
      (Submodule.span ℝ (Set.range fun l : Fin (J' (n - r) J) => sCol r n ((l.val + 1) * hJ (n - r) J - 1)))
    dsimp only [m, h] at hfin_spl hJ'_le
    unfold VJ
    omega
  exact ⟨hh1, hh_real, hfin_VJ⟩

/-- Lemma `pf:lem:F`, "consequently": `(I − P_J) N = 0`, i.e. `P_J` fixes `𝒫`. -/
theorem PJ_fixes_poly (r n J : ℕ) (θ : Fin n → ℝ) (hθ : θ ∈ polySpace r n) :
    PJ r n J θ = θ := by
  have hmem : θ ∈ VJ r n J := Submodule.mem_sup_left hθ
  have hmemE : toE n θ ∈ (VJ r n J).map (toE n).toLinearMap := Submodule.mem_map_of_mem hmem
  change (toE n).symm (((VJ r n J).map (toE n).toLinearMap).starProjection (toE n θ)) = θ
  rw [Submodule.starProjection_eq_self_iff.mpr hmemE, LinearEquiv.symm_apply_apply]

/-! ## Falling binomial polynomials, Lagrange bounds, and Schur test -/

/-- The falling binomial polynomial `∏_{k < p} (P - k) / p!` in `ℝ[X]`. -/
private def fallBinomPoly (p : ℕ) (P : Polynomial ℝ) : Polynomial ℝ :=
  (∏ k ∈ range p, (P - Polynomial.C (k : ℝ))) * Polynomial.C ((p.factorial : ℝ)⁻¹)

/-- Evaluation of `fallBinomPoly p P` at `x` equals `∏_{k < p} (P.eval x - k) / p!`. -/
private lemma eval_fallBinomPoly (p : ℕ) (P : Polynomial ℝ) (x : ℝ) :
    (fallBinomPoly p P).eval x =
      (∏ k ∈ range p, (P.eval x - (k : ℝ))) / (p.factorial : ℝ) := by
  simp [fallBinomPoly, Polynomial.eval_prod, div_eq_mul_inv]

/-- `fallBinomPoly p P` agrees with `bfun p t` whenever `P.eval x = t` for an integer `t ≥ 0`. -/
private lemma eval_fallBinomPoly_eq_bfun (p : ℕ) (P : Polynomial ℝ) (x : ℝ) (t : ℤ)
    (ht : 0 ≤ t) (heval : P.eval x = (t : ℝ)) :
    (fallBinomPoly p P).eval x = bfun p t := by
  rw [eval_fallBinomPoly, heval, bfun]
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

/-- `bfun p t ≤ (t.toNat : ℝ)^p / p!` for `0 ≤ t`. -/
private lemma bfun_le_pow_div_factorial (p : ℕ) (t : ℤ) (ht : 0 ≤ t) :
    bfun p t ≤ ((t.toNat : ℝ) ^ p) / (p.factorial : ℝ) := by
  rw [bfun]
  simp only [ht, ↓reduceIte]
  have hfac : (0 : ℝ) < p.factorial := Nat.cast_pos.mpr (Nat.factorial_pos p)
  rw [le_div_iff₀ hfac]
  have hnat : t.toNat.choose p * p.factorial ≤ t.toNat ^ p := by
    rw [mul_comm, ← Nat.descFactorial_eq_factorial_mul_choose]
    exact Nat.descFactorial_le_pow t.toNat p
  exact_mod_cast hnat

/-- Degree of `fallBinomPoly p P` is at most `p` whenever `P.degree ≤ 1`. -/
private lemma degree_fallBinomPoly_le (p : ℕ) (P : Polynomial ℝ) (hP : P.degree ≤ 1) :
    (fallBinomPoly p P).degree ≤ (p : WithBot ℕ) := by
  unfold fallBinomPoly
  have h1 : (∏ k ∈ range p, (P - Polynomial.C (k : ℝ))).degree ≤ (p : WithBot ℕ) := by
    calc (∏ k ∈ range p, (P - Polynomial.C (k : ℝ))).degree
        ≤ ∑ k ∈ range p, (P - Polynomial.C (k : ℝ)).degree := Polynomial.degree_prod_le _ _
      _ ≤ ∑ _k ∈ range p, (1 : WithBot ℕ) := by
          apply Finset.sum_le_sum; intro k _
          exact (Polynomial.degree_sub_le _ _).trans (max_le hP (Polynomial.degree_C_le.trans (by decide)))
      _ = (p : WithBot ℕ) := by simp
  calc ((∏ k ∈ range p, (P - Polynomial.C (k : ℝ))) * Polynomial.C ((p.factorial : ℝ)⁻¹)).degree
      ≤ (∏ k ∈ range p, (P - Polynomial.C (k : ℝ))).degree + (Polynomial.C ((p.factorial : ℝ)⁻¹)).degree :=
        Polynomial.degree_mul_le _ _
    _ ≤ (p : WithBot ℕ) + 0 := add_le_add h1 Polynomial.degree_C_le
    _ = (p : WithBot ℕ) := by simp

/-- Any polynomial of degree `< r` evaluated on `0, …, n-1` lies in `polySpace r n`. -/
private lemma poly_eval_mem_polySpace (r n : ℕ) (Q : Polynomial ℝ) (hdeg : Q.degree < (r : WithBot ℕ)) :
    (fun i : Fin n => Q.eval (i : ℝ)) ∈ polySpace r n := by
  have hnat : Q.natDegree < r ∨ Q = 0 := by
    by_cases hQ : Q = 0
    · exact Or.inr hQ
    · left
      rw [Polynomial.degree_eq_natDegree hQ] at hdeg
      exact WithBot.coe_lt_coe.mp hdeg
  rcases hnat with hlt | rfl
  · have hsum : (fun i : Fin n => Q.eval (i : ℝ)) =
        ∑ p : Fin r, Q.coeff p.val • (fun i : Fin n => (i : ℝ) ^ (p : ℕ)) := by
      ext i
      rw [Finset.sum_apply]
      have hQ := Polynomial.eval_eq_sum_range' (p := Q) hlt (i : ℝ)
      rw [hQ, ← Fin.sum_univ_eq_sum_range (fun k => Q.coeff k * (i : ℝ) ^ k) r]
      apply Finset.sum_congr rfl; intro p _; simp
    rw [hsum]
    exact Submodule.sum_mem _ fun p _ =>
      Submodule.smul_mem _ _ (Submodule.subset_span ⟨p, rfl⟩)
  · simp only [Polynomial.eval_zero]
    exact Submodule.zero_mem (polySpace r n)

/-- `∏_{t < d} (t + 1) = d!`. -/
private lemma prod_range_succ_eq_factorial (d : ℕ) :
    ∏ t ∈ range d, ((t + 1 : ℕ) : ℝ) = (d.factorial : ℝ) := by
  induction d with
  | zero => simp
  | succ d ih =>
    rw [Finset.prod_range_succ, ih, Nat.factorial_succ, Nat.cast_mul, mul_comm]

/-- `∏_{k ∈ Ico (a + 1) (a + 1 + d)} (k - a) = d!`. -/
private lemma prod_Ico_sub_eq_factorial (a d : ℕ) :
    ∏ k ∈ Finset.Ico (a + 1) (a + 1 + d), ((k - a : ℕ) : ℝ) = (d.factorial : ℝ) := by
  rw [← prod_range_succ_eq_factorial d]
  refine Finset.prod_bij (fun k _ => k - (a + 1)) ?_ ?_ ?_ ?_
  · intro k hk; rw [Finset.mem_Ico] at hk; rw [Finset.mem_range]; omega
  · intro k₁ hk₁ k₂ hk₂ heq; rw [Finset.mem_Ico] at hk₁ hk₂; omega
  · intro t ht; rw [Finset.mem_range] at ht
    exact ⟨a + 1 + t, Finset.mem_Ico.mpr ⟨by omega, by omega⟩, by omega⟩
  · intro k hk; rw [Finset.mem_Ico] at hk; congr 1; omega

/-- `∏_{k < d} (d - k) = d!`. -/
private lemma prod_range_sub_eq_factorial (d : ℕ) :
    ∏ k ∈ range d, ((d - k : ℕ) : ℝ) = (d.factorial : ℝ) := by
  rw [← prod_range_succ_eq_factorial d]
  refine Finset.prod_bij (fun k _ => d - 1 - k) ?_ ?_ ?_ ?_
  · intro k hk; rw [Finset.mem_range] at hk ⊢; omega
  · intro k₁ hk₁ k₂ hk₂ heq; rw [Finset.mem_range] at hk₁ hk₂; omega
  · intro t ht; rw [Finset.mem_range] at ht
    exact ⟨d - 1 - t, Finset.mem_range.mpr (by omega), by omega⟩
  · intro k hk; rw [Finset.mem_range] at hk; congr 1; omega

/-- `n ≤ C(n, k)` for `1 ≤ k` and `k ≤ n - 1`. -/
private lemma nat_le_choose (n k : ℕ) (hk1 : 1 ≤ k) (hkn : k + 1 ≤ n) : n ≤ n.choose k := by
  induction n generalizing k with
  | zero => omega
  | succ n ih =>
    by_cases h1 : k = 1
    · subst h1; simp
    · by_cases h2 : k = n
      · subst h2; rw [← Nat.choose_symm (by omega : k ≤ k + 1)]; simp
      · have hks : k = (k - 1) + 1 := by omega
        conv_rhs => rw [hks, Nat.choose_succ_succ']
        have hpos : 1 ≤ n.choose (k - 1) := Nat.choose_pos (by omega)
        have hih : n ≤ n.choose k := ih k (by omega) (by omega)
        rw [← hks]
        omega

/-- Core Lagrange numerator bound when `l ≤ m` and `x ∈ [m, m + 1]`. -/
private lemma lagrange_num_le_aux (r m l : ℕ) (hr : 2 ≤ r) (hm : m + 1 ≤ r - 1) (hl : l ≤ m)
    (x : ℝ) (hx1 : (m : ℝ) ≤ x) (hx2 : x ≤ (m + 1 : ℝ)) :
    ∏ k ∈ (range r).erase l, |x - (k : ℝ)| ≤ ((r - 1).factorial : ℝ) := by
  have hsplit : (range r).erase l = (range (m + 1)).erase l ∪ Finset.Ico (m + 1) r := by
    ext k
    simp only [Finset.mem_erase, Finset.mem_range, Finset.mem_union, Finset.mem_Ico]
    omega
  have hdisj : Disjoint ((range (m + 1)).erase l) (Finset.Ico (m + 1) r) := by
    rw [Finset.disjoint_left]
    intro k hk1 hk2
    rw [Finset.mem_erase, Finset.mem_range] at hk1
    rw [Finset.mem_Ico] at hk2
    omega
  rw [hsplit, Finset.prod_union hdisj]
  have hS2 : ∏ k ∈ Finset.Ico (m + 1) r, |x - (k : ℝ)| ≤ ((r - 1 - m).factorial : ℝ) := by
    calc ∏ k ∈ Finset.Ico (m + 1) r, |x - (k : ℝ)|
        ≤ ∏ k ∈ Finset.Ico (m + 1) r, ((k - m : ℕ) : ℝ) := by
          gcongr with k hk
          rw [Finset.mem_Ico] at hk
          have hkx : x ≤ (k : ℝ) := hx2.trans (by exact_mod_cast hk.1)
          rw [abs_of_nonpos (sub_nonpos.mpr hkx), neg_sub, Nat.cast_sub (by omega)]
          linarith
      _ = ((r - 1 - m).factorial : ℝ) := by
          have hr_eq : r = m + 1 + (r - 1 - m) := by omega
          conv_lhs => rw [hr_eq]
          exact prod_Ico_sub_eq_factorial m (r - 1 - m)
  by_cases hm0 : m = 0
  · subst hm0
    have hl0 : l = 0 := by omega
    subst hl0
    simp only [zero_add, range_one, erase_singleton, prod_empty, one_mul, Nat.sub_zero] at hS2 ⊢
    exact hS2
  · have hm1 : 1 ≤ m := by omega
    have hS1 : ∏ k ∈ (range (m + 1)).erase l, |x - (k : ℝ)| ≤ ((m + 1).factorial : ℝ) := by
      calc ∏ k ∈ (range (m + 1)).erase l, |x - (k : ℝ)|
          ≤ ∏ k ∈ (range (m + 1)).erase l, ((m + 1 - k : ℕ) : ℝ) := by
            gcongr with k hk
            rw [Finset.mem_erase, Finset.mem_range] at hk
            have hkx : (k : ℝ) ≤ x := (by exact_mod_cast (by omega : k ≤ m) : (k : ℝ) ≤ m).trans hx1
            rw [abs_of_nonneg (sub_nonneg.mpr hkx), Nat.cast_sub (by omega), Nat.cast_add, Nat.cast_one]
            linarith
        _ ≤ ∏ k ∈ range (m + 1), ((m + 1 - k : ℕ) : ℝ) := by
            have hlmem : l ∈ range (m + 1) := Finset.mem_range.mpr (by omega)
            rw [← Finset.mul_prod_erase (range (m + 1)) (fun k => ((m + 1 - k : ℕ) : ℝ)) hlmem]
            have hge1 : (1 : ℝ) ≤ ((m + 1 - l : ℕ) : ℝ) := by exact_mod_cast (by omega : 1 ≤ m + 1 - l)
            have hnn : 0 ≤ ∏ k ∈ (range (m + 1)).erase l, ((m + 1 - k : ℕ) : ℝ) :=
              Finset.prod_nonneg fun _ _ => Nat.cast_nonneg _
            nlinarith
        _ = ((m + 1).factorial : ℝ) := prod_range_sub_eq_factorial (m + 1)
    have hfac_le : (m + 1).factorial * (r - 1 - m).factorial ≤ (r - 1).factorial := by
      have hch : m + 1 ≤ (r - 1).choose m :=
        le_trans (by omega : m + 1 ≤ r - 1) (nat_le_choose (r - 1) m hm1 (by omega))
      calc (m + 1).factorial * (r - 1 - m).factorial
          = (m + 1) * (m.factorial * (r - 1 - m).factorial) := by
            rw [Nat.factorial_succ, mul_assoc]
        _ ≤ (r - 1).choose m * (m.factorial * (r - 1 - m).factorial) :=
            Nat.mul_le_mul_right _ hch
        _ = (r - 1).factorial := by
            rw [← mul_assoc]
            exact Nat.choose_mul_factorial_mul_factorial (by omega)
    calc (∏ k ∈ (range (m + 1)).erase l, |x - (k : ℝ)|) *
            (∏ k ∈ Finset.Ico (m + 1) r, |x - (k : ℝ)|)
        ≤ ((m + 1).factorial : ℝ) * ((r - 1 - m).factorial : ℝ) :=
          mul_le_mul hS1 hS2 (Finset.prod_nonneg fun _ _ => abs_nonneg _) (Nat.cast_nonneg _)
      _ ≤ ((r - 1).factorial : ℝ) := by exact_mod_cast hfac_le

/-- Lagrange numerator bound on `[0, r - 1]`: `∏_{k ≠ l} |x - k| ≤ (r - 1)!`. -/
private lemma lagrange_num_le (r l : ℕ) (hr : 2 ≤ r) (hl : l < r)
    (x : ℝ) (hx0 : 0 ≤ x) (hxr : x ≤ (r - 1 : ℝ)) :
    ∏ k ∈ (range r).erase l, |x - (k : ℝ)| ≤ ((r - 1).factorial : ℝ) := by
  let m := min (Nat.floor x) (r - 2)
  have hm : m + 1 ≤ r - 1 := by omega
  have hx1 : (m : ℝ) ≤ x :=
    (Nat.cast_le.mpr (min_le_left _ _)).trans (Nat.floor_le hx0)
  have hx2 : x ≤ (m + 1 : ℝ) := by
    by_cases hfl : Nat.floor x ≤ r - 2
    · have hm_eq : m = Nat.floor x := min_eq_left hfl
      rw [hm_eq]
      exact (Nat.lt_floor_add_one x).le
    · have hm_eq : m = r - 2 := min_eq_right (by omega)
      rw [hm_eq]
      have hcast : ((r - 2 : ℕ) : ℝ) + 1 = (r - 1 : ℝ) := by
        rw [Nat.cast_sub (by omega)]; push_cast; ring
      rw [hcast]
      exact hxr
  by_cases hlm : l ≤ m
  · exact lagrange_num_le_aux r m l hr hm hlm x hx1 hx2
  · let x' : ℝ := (r - 1 : ℝ) - x
    let l' : ℕ := r - 1 - l
    let m' : ℕ := r - 2 - m
    have hsymm : ∏ k ∈ (range r).erase l, |x - (k : ℝ)| =
        ∏ k ∈ (range r).erase l', |x' - (k : ℝ)| := by
      refine Finset.prod_bij (fun k _ => r - 1 - k) ?_ ?_ ?_ ?_
      · intro k hk
        rw [Finset.mem_erase, Finset.mem_range] at hk ⊢
        omega
      · intro k₁ hk₁ k₂ hk₂ heq
        rw [Finset.mem_erase, Finset.mem_range] at hk₁ hk₂
        omega
      · intro k hk
        rw [Finset.mem_erase, Finset.mem_range] at hk
        exact ⟨r - 1 - k, Finset.mem_erase.mpr ⟨by omega, Finset.mem_range.mpr (by omega)⟩, by omega⟩
      · intro k hk
        rw [Finset.mem_erase, Finset.mem_range] at hk
        have hcast : ((r - 1 - k : ℕ) : ℝ) = (r - 1 : ℝ) - (k : ℝ) := by
          rw [Nat.cast_sub (by omega), Nat.cast_sub (by omega)]; push_cast; ring
        rw [hcast]
        show |x - (k : ℝ)| = |((r - 1 : ℝ) - x) - ((r - 1 : ℝ) - (k : ℝ))|
        rw [show ((r - 1 : ℝ) - x) - ((r - 1 : ℝ) - (k : ℝ)) = -(x - (k : ℝ)) by ring, abs_neg]
    rw [hsymm]
    have hx1' : (m' : ℝ) ≤ x' := by
      have hc : (m' : ℝ) = (r - 1 : ℝ) - (m + 1 : ℝ) := by
        dsimp only [m']
        rw [Nat.cast_sub (by omega), Nat.cast_sub (by omega)]; push_cast; ring
      rw [hc]; linarith
    have hx2' : x' ≤ (m' + 1 : ℝ) := by
      have hc : (m' : ℝ) + 1 = (r - 1 : ℝ) - (m : ℝ) := by
        dsimp only [m']
        rw [Nat.cast_sub (by omega), Nat.cast_sub (by omega)]; push_cast; ring
      rw [hc]; linarith
    exact lagrange_num_le_aux r m' l' hr (by omega) (by omega) x' hx1' hx2'

/-- Lagrange weight bound `|(Lagrange.basis (range r) Nat.cast l).eval x| ≤ C(r - 1, l)`
for `x ∈ [0, r - 1]`. -/
private lemma abs_lagrange_basis_le_choose (r l : ℕ) (hr : 2 ≤ r) (hl : l < r)
    (x : ℝ) (hx0 : 0 ≤ x) (hxr : x ≤ (r - 1 : ℝ)) :
    |(Lagrange.basis (range r) (Nat.cast : ℕ → ℝ) l).eval x| ≤ ((r - 1).choose l : ℝ) := by
  have heval : (Lagrange.basis (range r) (Nat.cast : ℕ → ℝ) l).eval x =
      (∏ k ∈ (range r).erase l, (x - (k : ℝ))) /
        (∏ k ∈ (range r).erase l, ((l : ℝ) - (k : ℝ))) := by
    rw [Lagrange.basis, Polynomial.eval_prod, ← Finset.prod_div_distrib]
    apply Finset.prod_congr rfl; intro k _
    simp [Lagrange.basisDivisor, div_eq_mul_inv, mul_comm]
  rw [heval, abs_div, Finset.abs_prod, Finset.abs_prod]
  have hden : ∏ k ∈ (range r).erase l, |(l : ℝ) - (k : ℝ)| =
      (l.factorial : ℝ) * ((r - 1 - l).factorial : ℝ) := by
    have hsplit : (range r).erase l = range l ∪ Finset.Ico (l + 1) r := by
      ext k; simp only [Finset.mem_erase, Finset.mem_range, Finset.mem_union, Finset.mem_Ico]; omega
    have hdisj : Disjoint (range l) (Finset.Ico (l + 1) r) := by
      rw [Finset.disjoint_left]; intro k hk1 hk2
      rw [Finset.mem_range] at hk1; rw [Finset.mem_Ico] at hk2; omega
    rw [hsplit, Finset.prod_union hdisj]
    congr 1
    · calc ∏ k ∈ range l, |(l : ℝ) - (k : ℝ)|
          = ∏ k ∈ range l, ((l - k : ℕ) : ℝ) := by
            apply Finset.prod_congr rfl; intro k hk
            rw [Finset.mem_range] at hk
            rw [abs_of_nonneg (sub_nonneg.mpr (by exact_mod_cast hk.le)), Nat.cast_sub hk.le]
        _ = (l.factorial : ℝ) := prod_range_sub_eq_factorial l
    · calc ∏ k ∈ Finset.Ico (l + 1) r, |(l : ℝ) - (k : ℝ)|
          = ∏ k ∈ Finset.Ico (l + 1) r, ((k - l : ℕ) : ℝ) := by
            apply Finset.prod_congr rfl; intro k hk
            rw [Finset.mem_Ico] at hk
            rw [abs_of_nonpos (sub_nonpos.mpr (by exact_mod_cast (by omega : l ≤ k))),
              neg_sub, Nat.cast_sub (by omega)]
        _ = ((r - 1 - l).factorial : ℝ) := by
            have hr_eq : r = l + 1 + (r - 1 - l) := by omega
            conv_lhs => rw [hr_eq]
            exact prod_Ico_sub_eq_factorial l (r - 1 - l)
  rw [hden]
  have hden_pos : (0 : ℝ) < (l.factorial : ℝ) * ((r - 1 - l).factorial : ℝ) :=
    mul_pos (Nat.cast_pos.mpr (Nat.factorial_pos l)) (Nat.cast_pos.mpr (Nat.factorial_pos _))
  rw [div_le_iff₀ hden_pos]
  have hchoose : ((r - 1).choose l : ℝ) * ((l.factorial : ℝ) * ((r - 1 - l).factorial : ℝ)) =
      ((r - 1).factorial : ℝ) := by
    have hnat := Nat.choose_mul_factorial_mul_factorial (by omega : l ≤ r - 1)
    rw [← mul_assoc]
    exact_mod_cast hnat
  rw [hchoose]
  exact lagrange_num_le r l hr hl x hx0 hxr

/-- Orthogonal projection residual contraction: `‖(I - P_J) v‖₂ ≤ ‖v‖₂`. -/
private lemma l2norm_sub_PJ_le (r n J : ℕ) (v : Fin n → ℝ) :
    l2norm (v - PJ r n J v) ≤ l2norm v := by
  let K : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (VJ r n J).map (toE n).toLinearMap
  have hP : toE n (PJ r n J v) = K.starProjection (toE n v) := (toE n).apply_symm_apply _
  have hsub : toE n (v - PJ r n J v) = toE n v - K.starProjection (toE n v) := by
    rw [map_sub, hP]
  have horth : @inner ℝ _ _ (toE n (v - PJ r n J v)) (toE n (PJ r n J v)) = 0 := by
    rw [hsub, hP]
    exact Submodule.starProjection_inner_eq_zero (K := K) (toE n v) _
      (Submodule.starProjection_apply_mem K (toE n v))
  have hsum : toE n v = toE n (v - PJ r n J v) + toE n (PJ r n J v) := by
    rw [hsub, hP, sub_add_cancel]
  have hsq : l2sq (v - PJ r n J v) ≤ l2sq v := by
    have heq : l2sq v = l2sq (v - PJ r n J v) + l2sq (PJ r n J v) := by
      rw [← norm_toE_sq, ← norm_toE_sq, ← norm_toE_sq, hsum, norm_add_sq_real, horth,
        mul_zero, add_zero]
    have hnn : 0 ≤ l2sq (PJ r n J v) := Finset.sum_nonneg fun _ _ => sq_nonneg _
    linarith
  exact Real.sqrt_le_sqrt hsq

/-- Schur test for a matrix `A : Fin n → Fin m → ℝ`. -/
private lemma schur_test {n m : ℕ} (A : Fin n → Fin m → ℝ) (Mrow Mcol : ℝ)
    (hMrow : 0 ≤ Mrow) (hMcol : 0 ≤ Mcol)
    (hrow : ∀ i : Fin n, ∑ j : Fin m, |A i j| ≤ Mrow)
    (hcol : ∀ j : Fin m, ∑ i : Fin n, |A i j| ≤ Mcol)
    (u : Fin m → ℝ) :
    l2norm (fun i => ∑ j : Fin m, A i j * u j) ≤ Real.sqrt (Mrow * Mcol) * l2norm u := by
  have hsq : l2sq (fun i => ∑ j : Fin m, A i j * u j) ≤ (Mrow * Mcol) * l2sq u := by
    unfold l2sq
    have hi : ∀ i : Fin n,
        (∑ j : Fin m, A i j * u j) ^ 2 ≤ Mrow * ∑ j : Fin m, |A i j| * u j ^ 2 := by
      intro i
      have habs : (∑ j : Fin m, A i j * u j) ^ 2 ≤ (∑ j : Fin m, |A i j| * |u j|) ^ 2 := by
        rw [← sq_abs (∑ j, A i j * u j)]
        have htri : |∑ j : Fin m, A i j * u j| ≤ ∑ j : Fin m, |A i j| * |u j| := by
          simpa only [abs_mul] using Finset.abs_sum_le_sum_abs (fun j => A i j * u j) Finset.univ
        exact pow_le_pow_left₀ (abs_nonneg _) htri 2
      have hcs : (∑ j : Fin m, |A i j| * |u j|) ^ 2 ≤
          (∑ j : Fin m, |A i j|) * (∑ j : Fin m, |A i j| * u j ^ 2) := by
        have h1 := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
          (fun j : Fin m => Real.sqrt |A i j|)
          (fun j : Fin m => Real.sqrt |A i j| * |u j|)
        have hlhs : ∑ j : Fin m, Real.sqrt |A i j| * (Real.sqrt |A i j| * |u j|) =
            ∑ j : Fin m, |A i j| * |u j| := by
          apply Finset.sum_congr rfl; intro j _
          rw [← mul_assoc, Real.mul_self_sqrt (abs_nonneg _)]
        have hrhs1 : ∑ j : Fin m, Real.sqrt |A i j| ^ 2 = ∑ j : Fin m, |A i j| := by
          apply Finset.sum_congr rfl; intro j _; exact Real.sq_sqrt (abs_nonneg _)
        have hrhs2 : ∑ j : Fin m, (Real.sqrt |A i j| * |u j|) ^ 2 =
            ∑ j : Fin m, |A i j| * u j ^ 2 := by
          apply Finset.sum_congr rfl; intro j _
          rw [mul_pow, Real.sq_sqrt (abs_nonneg _), sq_abs]
        rwa [hlhs, hrhs1, hrhs2] at h1
      have hnn : 0 ≤ ∑ j : Fin m, |A i j| * u j ^ 2 :=
        Finset.sum_nonneg fun j _ => mul_nonneg (abs_nonneg _) (sq_nonneg _)
      exact habs.trans (hcs.trans (mul_le_mul_of_nonneg_right (hrow i) hnn))
    calc ∑ i : Fin n, (∑ j : Fin m, A i j * u j) ^ 2
        ≤ ∑ i : Fin n, Mrow * ∑ j : Fin m, |A i j| * u j ^ 2 :=
          Finset.sum_le_sum fun i _ => hi i
      _ = Mrow * ∑ j : Fin m, (∑ i : Fin n, |A i j|) * u j ^ 2 := by
          rw [← Finset.mul_sum, Finset.sum_comm]
          congr 1; apply Finset.sum_congr rfl; intro j _
          rw [Finset.sum_mul]
      _ ≤ Mrow * ∑ j : Fin m, Mcol * u j ^ 2 := by
          apply mul_le_mul_of_nonneg_left _ hMrow
          apply Finset.sum_le_sum; intro j _
          exact mul_le_mul_of_nonneg_right (hcol j) (sq_nonneg _)
      _ = (Mrow * Mcol) * ∑ j : Fin m, u j ^ 2 := by
          rw [← Finset.mul_sum, mul_assoc]
  unfold l2norm
  rw [← Real.sqrt_mul (mul_nonneg hMrow hMcol)]
  exact Real.sqrt_le_sqrt hsq

/-- Construction of the localized residual `e_j` in Lemma `pf:lem:F` (all three cases). -/
private lemma exists_localized_residual (r n J : ℕ) (hr : 2 ≤ r) (hn : r < n)
    (hJpos : 1 ≤ J) (hJm : J ≤ n - r) (j : Fin (n - r)) :
    let h := hJ (n - r) J
    ∃ e : Fin n → ℝ,
      sCol r n j.val - e ∈ VJ r n J ∧
      (∀ i : Fin n, e i ≠ 0 → |(i.val : ℤ) - (j.val : ℤ)| ≤ ((r * h : ℕ) : ℤ)) ∧
      (Finset.univ.filter fun i : Fin n => e i ≠ 0).card ≤ r * h ∧
      ∀ i : Fin n, |e i| ≤ cInf r * (h : ℝ) ^ (r - 1) := by
  let m := n - r
  let h := hJ m J
  let J1 := J' m J
  have hh1 : 1 ≤ h := (hJ_le r n J hn hJpos hJm).1
  have hh0 : (0 : ℝ) < h := Nat.cast_pos.mpr (by omega)
  let j1 : ℕ := j.val + 1
  have hj1_pos : 1 ≤ j1 := Nat.succ_pos _
  have hj1_le : j1 ≤ m := j.isLt
  have hcInf_fac : (2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1) ≤
      cInf r * (h : ℝ) ^ (r - 1) := by
    unfold cInf
    have hpow : (1 : ℝ) ≤ 1 + (2 : ℝ) ^ (r - 1) := by
      linarith [pow_nonneg (by norm_num : (0 : ℝ) ≤ 2) (r - 1)]
    have hnn : 0 ≤ (2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1) := by positivity
    rw [mul_div_assoc]
    calc (2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1)
        = 1 * ((2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1)) := by ring
      _ ≤ (1 + (2 : ℝ) ^ (r - 1)) * ((2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1)) :=
          mul_le_mul_of_nonneg_right hpow hnn
      _ = (1 + (2 : ℝ) ^ (r - 1)) * ((2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) * (h : ℝ) ^ (r - 1) := by
          ring
  by_cases hcase1 : r ≤ J1 ∧ h ≤ j1 ∧ j1 ≤ J1 * h
  · -- Case 1: `J' ≥ r` and `h ≤ j1 ≤ J' * h`.
    rcases hcase1 with ⟨hJ1r, hj1_ge, hj1_le_J1h⟩
    let a : ℕ := min (j1 / h) (J1 - r + 1)
    have ha1 : 1 ≤ a := by
      have : 1 ≤ j1 / h := Nat.div_pos hj1_ge (by omega)
      omega
    have ha_le : a + r - 1 ≤ J1 := by omega
    let x : ℝ := (j1 : ℝ) / (h : ℝ) - (a : ℝ)
    have hx0 : 0 ≤ x := by
      have hdiv : (a : ℝ) ≤ (j1 : ℝ) / (h : ℝ) := by
        rw [le_div_iff₀ hh0]
        have hnat : a * h ≤ j1 := (Nat.mul_le_mul_right h (min_le_left _ _)).trans
          (Nat.div_mul_le_self j1 h)
        exact_mod_cast hnat
      linarith
    have hxr : x ≤ (r - 1 : ℝ) := by
      by_cases hmin : j1 / h ≤ J1 - r + 1
      · have ha_eq : a = j1 / h := min_eq_left hmin
        have hlt : j1 < (a + 1) * h := by
          rw [ha_eq, add_mul, one_mul]
          have hmod := Nat.mod_lt j1 (by omega : 0 < h)
          have hdm := Nat.div_add_mod j1 h
          rw [mul_comm] at hdm
          omega
        have hlt' : (j1 : ℝ) / (h : ℝ) < (a : ℝ) + 1 := by
          rw [div_lt_iff₀ hh0]
          have : (j1 : ℝ) < ((a + 1 : ℕ) : ℝ) * (h : ℝ) := by exact_mod_cast hlt
          simpa [Nat.cast_add] using this
        have hr1 : (1 : ℝ) ≤ (r : ℝ) - 1 := by
          have : (2 : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr
          linarith
        linarith
      · have ha_eq : a = J1 - r + 1 := min_eq_right (by omega)
        have hle' : (j1 : ℝ) / (h : ℝ) ≤ (J1 : ℝ) := by
          rw [div_le_iff₀ hh0]; exact_mod_cast hj1_le_J1h
        have hJ1_eq : (J1 : ℝ) - (a : ℝ) = (r : ℝ) - 1 := by
          rw [ha_eq, Nat.cast_add, Nat.cast_sub hJ1r]; push_cast; ring
        linarith
    let wt : ℕ → ℝ := fun l => (Lagrange.basis (range r) (Nat.cast : ℕ → ℝ) l).eval x
    let knot : ℕ → ℕ := fun l => (a + l) * h
    let e : Fin n → ℝ := sCol r n j.val - ∑ l ∈ range r, wt l • sCol r n (knot l - 1)
    have hj_lo : knot 0 ≤ j1 := by
      have : a * h ≤ j1 := (Nat.mul_le_mul_right h (min_le_left _ _)).trans
        (Nat.div_mul_le_self j1 h)
      simpa [knot] using this
    have hj_hi : j1 ≤ knot (r - 1) := by
      have : (j1 : ℝ) ≤ ((a + (r - 1) : ℕ) : ℝ) * (h : ℝ) := by
        have h1 : (j1 : ℝ) / (h : ℝ) ≤ (a : ℝ) + ((r - 1 : ℕ) : ℝ) := by
          rw [Nat.cast_sub (by omega : 1 ≤ r), Nat.cast_one]; linarith
        rwa [div_le_iff₀ hh0, ← Nat.cast_add] at h1
      exact_mod_cast this
    have he_zero_le : ∀ i : Fin n, i.val + 1 ≤ knot 0 → e i = 0 := by
      intro i hle
      have hsj : sCol r n j.val i = 0 := by
        unfold sCol bfun
        have hneg : ¬ (0 : ℤ) ≤ (i : ℤ) - (j.val : ℤ) - 1 := by omega
        simp only [hneg, ↓reduceIte]
      have hsk : ∀ l ∈ range r, sCol r n (knot l - 1) i = 0 := by
        intro l _
        unfold sCol bfun
        have hkl : knot 0 ≤ knot l := Nat.mul_le_mul_right h (Nat.le_add_right a l)
        have h1 : 1 ≤ knot l := by
          have : 1 ≤ a * h := Nat.mul_pos ha1 (by omega)
          dsimp only [knot]; nlinarith
        have hneg : ¬ (0 : ℤ) ≤ (i : ℤ) - ((knot l - 1 : ℕ) : ℤ) - 1 := by omega
        simp only [hneg, ↓reduceIte]
      dsimp only [e]
      rw [Pi.sub_apply, Finset.sum_apply, hsj, zero_sub, neg_eq_zero]
      exact Finset.sum_eq_zero fun l hl => by rw [Pi.smul_apply, hsk l hl, smul_zero]
    have he_zero_gt : ∀ i : Fin n, knot (r - 1) < i.val + 1 → e i = 0 := by
      intro i hgt
      let P : Polynomial ℝ :=
        Polynomial.C ((i.val + 1 : ℝ) - (a : ℝ) * (h : ℝ) - 1) - Polynomial.C (h : ℝ) * Polynomial.X
      let F : Polynomial ℝ := fallBinomPoly (r - 1) P
      have hPdeg : P.degree ≤ 1 := by
        refine (Polynomial.degree_sub_le _ _).trans (max_le (Polynomial.degree_C_le.trans (by decide)) ?_)
        calc (Polynomial.C (h : ℝ) * Polynomial.X).degree
            ≤ (Polynomial.C (h : ℝ)).degree + Polynomial.X.degree := Polynomial.degree_mul_le _ _
          _ ≤ 0 + 1 := add_le_add Polynomial.degree_C_le (by rw [Polynomial.degree_X])
          _ = 1 := by simp
      have hFdeg : F.degree < #(range r) := by
        rw [Finset.card_range]
        exact (degree_fallBinomPoly_le (r - 1) P hPdeg).trans_lt (Nat.cast_lt.mpr (by omega))
      have hinj : Set.InjOn (Nat.cast : ℕ → ℝ) (range r : Set ℕ) := Nat.cast_injective.injOn
      have hinterp := Lagrange.eq_interpolate (f := F) hinj hFdeg
      have heval_x : F.eval x = ∑ l ∈ range r, wt l * F.eval (l : ℝ) := by
        have h1 := congrArg (Polynomial.eval x) hinterp
        rw [Lagrange.interpolate_apply, Polynomial.eval_finsetSum] at h1
        rw [h1]
        apply Finset.sum_congr rfl; intro l _
        rw [Polynomial.eval_mul, Polynomial.eval_C, mul_comm]
      have hFx : F.eval x = sCol r n j.val i := by
        have hPeval : P.eval x = ((((i : ℤ) - (j.val : ℤ) - 1) : ℤ) : ℝ) := by
          have hax : ((a : ℝ) + x) * (h : ℝ) = (j1 : ℝ) := by
            dsimp only [x]; field_simp [hh0.ne']; ring
          simp only [P, Polynomial.eval_sub, Polynomial.eval_C, Polynomial.eval_mul, Polynomial.eval_X,
            Int.cast_sub, Int.cast_natCast, Int.cast_one]
          have : (i.val + 1 : ℝ) - (a : ℝ) * (h : ℝ) - 1 - (h : ℝ) * x =
              (i.val + 1 : ℝ) - ((a : ℝ) + x) * (h : ℝ) - 1 := by ring
          rw [this, hax]
          dsimp only [j1]; push_cast; ring
        exact eval_fallBinomPoly_eq_bfun (r - 1) P x ((i : ℤ) - (j.val : ℤ) - 1)
          (by omega) hPeval
      have hFl : ∀ l ∈ range r, F.eval (l : ℝ) = sCol r n (knot l - 1) i := by
        intro l hl
        have hl_lt : l < r := Finset.mem_range.mp hl
        have hkl_le : knot l ≤ knot (r - 1) := Nat.mul_le_mul_right h (by omega)
        have hkl1 : 1 ≤ knot l := by
          have : 1 ≤ a * h := Nat.mul_pos ha1 (by omega)
          dsimp only [knot]; nlinarith
        have hPeval : P.eval (l : ℝ) = ((((i : ℤ) - ((knot l - 1 : ℕ) : ℤ) - 1) : ℤ) : ℝ) := by
          simp only [P, Polynomial.eval_sub, Polynomial.eval_C, Polynomial.eval_mul, Polynomial.eval_X,
            Int.cast_sub, Int.cast_natCast, Int.cast_one]
          have hkc : ((knot l - 1 : ℕ) : ℝ) = ((a : ℝ) + (l : ℝ)) * (h : ℝ) - 1 := by
            rw [Nat.cast_sub hkl1]; dsimp only [knot]; push_cast; ring
          rw [hkc]; ring
        exact eval_fallBinomPoly_eq_bfun (r - 1) P (l : ℝ)
          ((i : ℤ) - ((knot l - 1 : ℕ) : ℤ) - 1) (by omega) hPeval
      dsimp only [e]
      rw [Pi.sub_apply, Finset.sum_apply, ← hFx, heval_x]
      have hsum_eq : ∑ l ∈ range r, (wt l • sCol r n (knot l - 1)) i =
          ∑ l ∈ range r, wt l * F.eval (l : ℝ) := by
        apply Finset.sum_congr rfl; intro l hl
        simp [hFl l hl]
      rw [hsum_eq, sub_self]
    have he_supp : ∀ i : Fin n, e i ≠ 0 → knot 0 < i.val + 1 ∧ i.val + 1 ≤ knot (r - 1) := by
      intro i hi
      by_contra hnot
      by_cases hle : i.val + 1 ≤ knot 0
      · exact hi (he_zero_le i hle)
      · exact hi (he_zero_gt i (by omega))
    refine ⟨e, ?_, ?_, ?_, ?_⟩
    · -- `s_j - e ∈ V_J`
      have hsub : sCol r n j.val - e = ∑ l ∈ range r, wt l • sCol r n (knot l - 1) := by
        dsimp only [e]; abel
      rw [hsub]
      refine Submodule.sum_mem _ fun l hl => Submodule.smul_mem _ _ (Submodule.mem_sup_right ?_)
      have hl_lt : l < r := Finset.mem_range.mp hl
      have hidx : a + l - 1 < J1 := by omega
      refine Submodule.subset_span ⟨⟨a + l - 1, hidx⟩, ?_⟩
      change sCol r n ((a + l - 1 + 1) * h - 1) = sCol r n ((a + l) * h - 1)
      rw [show a + l - 1 + 1 = a + l by omega]
    · -- Support bound `|i - j| ≤ r * h`
      intro i hi
      have hsupp := he_supp i hi
      have hspan : knot (r - 1) - knot 0 = (r - 1) * h := by
        dsimp only [knot]; rw [← Nat.sub_mul]; congr 1; omega
      have hrh : (r - 1) * h ≤ r * h := Nat.mul_le_mul_right h (Nat.sub_le r 1)
      change |(i.val : ℤ) - (j.val : ℤ)| ≤ ((r * h : ℕ) : ℤ)
      rw [abs_le]
      constructor <;> omega
    · -- Support cardinality `≤ r * h`
      have hsub : (Finset.univ.filter fun i : Fin n => e i ≠ 0).image Fin.val ⊆
          Finset.Ico (knot 0) (knot (r - 1)) := by
        intro idx hidx
        rcases Finset.mem_image.mp hidx with ⟨i, hi, rfl⟩
        rw [Finset.mem_filter] at hi
        have hsupp := he_supp i hi.2
        rw [Finset.mem_Ico]; omega
      have hcard := Finset.card_le_card hsub
      rw [Finset.card_image_of_injective _ Fin.val_injective, Nat.card_Ico] at hcard
      have hdiff : knot (r - 1) - knot 0 ≤ r * h := by
        dsimp only [knot]; rw [← Nat.sub_mul]
        exact Nat.mul_le_mul_right h (by omega)
      exact hcard.trans hdiff
    · -- Sup norm bound `|e i| ≤ cInf r * h^(r - 1)`
      intro i
      by_cases hei : e i = 0
      · rw [hei, abs_zero]; unfold cInf; positivity
      · have hi_le : i.val + 1 ≤ knot (r - 1) := (he_supp i hei).2
        let M : ℝ := (2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1)
        have hM_nn : 0 ≤ M := by positivity
        have hbound_sCol : ∀ k1 : ℕ, knot 0 ≤ k1 → |sCol r n (k1 - 1) i| ≤ M := by
          intro k1 hk1
          have hk1_pos : 1 ≤ k1 := by
            have : 1 ≤ a * h := Nat.mul_pos ha1 (by omega)
            have hk0 : knot 0 = a * h := by dsimp only [knot]; simp
            omega
          unfold sCol
          by_cases ht : 0 ≤ (i : ℤ) - ((k1 - 1 : ℕ) : ℤ) - 1
          · have hnn : 0 ≤ bfun (r - 1) ((i : ℤ) - ((k1 - 1 : ℕ) : ℤ) - 1) := by
              unfold bfun; simp only [ht, ↓reduceIte]; positivity
            rw [abs_of_nonneg hnn]
            refine (bfun_le_pow_div_factorial (r - 1) _ ht).trans ?_
            have hle_2rh : ((i : ℤ) - ((k1 - 1 : ℕ) : ℤ) - 1).toNat ≤ 2 * r * h := by
              have hdiff : knot (r - 1) - knot 0 = (r - 1) * h := by
                dsimp only [knot]; rw [← Nat.sub_mul]; congr 1; omega
              have hrh : (r - 1) * h ≤ 2 * r * h := Nat.mul_le_mul_right h (by omega)
              omega
            have hpow : ((((i : ℤ) - ((k1 - 1 : ℕ) : ℤ) - 1).toNat : ℝ)) ^ (r - 1) ≤
                (2 * r : ℝ) ^ (r - 1) * (h : ℝ) ^ (r - 1) := by
              rw [← mul_pow]
              exact pow_le_pow_left₀ (Nat.cast_nonneg _) (by exact_mod_cast hle_2rh) (r - 1)
            calc ((((i : ℤ) - ((k1 - 1 : ℕ) : ℤ) - 1).toNat : ℝ)) ^ (r - 1) / ((r - 1).factorial : ℝ)
                ≤ ((2 * r : ℝ) ^ (r - 1) * (h : ℝ) ^ (r - 1)) / ((r - 1).factorial : ℝ) :=
                  div_le_div_of_nonneg_right hpow (Nat.cast_nonneg _)
              _ = M := by dsimp only [M]; ring
          · unfold bfun; simp only [ht, ↓reduceIte, abs_zero]; exact hM_nn
        have hwt_sum : ∑ l ∈ range r, |wt l| ≤ (2 : ℝ) ^ (r - 1) := by
          calc ∑ l ∈ range r, |wt l|
              ≤ ∑ l ∈ range r, ((r - 1).choose l : ℝ) := by
                apply Finset.sum_le_sum; intro l hl
                exact abs_lagrange_basis_le_choose r l hr (Finset.mem_range.mp hl) x hx0 hxr
            _ = (2 : ℝ) ^ (r - 1) := by
                have h1 := Nat.sum_range_choose (r - 1)
                have hr_eq : r = r - 1 + 1 := by omega
                rw [hr_eq]
                exact_mod_cast h1
        have htri : |e i| ≤ (1 + (2 : ℝ) ^ (r - 1)) * M := by
          dsimp only [e]
          rw [Pi.sub_apply, Finset.sum_apply]
          calc |sCol r n j.val i - ∑ l ∈ range r, (wt l • sCol r n (knot l - 1)) i|
              ≤ |sCol r n j.val i| + |∑ l ∈ range r, (wt l • sCol r n (knot l - 1)) i| :=
                abs_sub _ _
            _ ≤ |sCol r n (j1 - 1) i| + ∑ l ∈ range r, |wt l| * |sCol r n (knot l - 1) i| := by
                have hsum_abs : |∑ l ∈ range r, (wt l • sCol r n (knot l - 1)) i| ≤
                    ∑ l ∈ range r, |wt l| * |sCol r n (knot l - 1) i| := by
                  simpa only [Pi.smul_apply, smul_eq_mul, abs_mul] using
                    Finset.abs_sum_le_sum_abs (fun l => (wt l • sCol r n (knot l - 1)) i) (range r)
                exact add_le_add le_rfl hsum_abs
            _ ≤ M + ∑ l ∈ range r, |wt l| * M := by
                apply add_le_add (hbound_sCol j1 hj_lo)
                apply Finset.sum_le_sum; intro l _
                exact mul_le_mul_of_nonneg_left
                  (hbound_sCol (knot l) (Nat.mul_le_mul_right h (Nat.le_add_right a l)))
                  (abs_nonneg _)
            _ = (1 + ∑ l ∈ range r, |wt l|) * M := by rw [← Finset.sum_mul]; ring
            _ ≤ (1 + (2 : ℝ) ^ (r - 1)) * M :=
                mul_le_mul_of_nonneg_right (add_le_add le_rfl hwt_sum) hM_nn
        refine htri.trans_eq ?_
        unfold cInf; dsimp only [M]; ring
  · by_cases hcase2 : j1 ≤ J1 * h
    · -- Case 2: `j1 < h`, or `J' < r` and `h ≤ j1 ≤ J' * h`. In both subcases `j1 ≤ (r - 1) * h`.
      have hj1_le_rh : j1 ≤ (r - 1) * h := by
        by_cases hlt : j1 < h
        · have : 1 * h ≤ (r - 1) * h := Nat.mul_le_mul_right h (by omega)
          omega
        · have hJ1_lt : J1 < r := by omega
          have : J1 * h ≤ (r - 1) * h := Nat.mul_le_mul_right h (by omega)
          omega
      let P : Polynomial ℝ := Polynomial.X - Polynomial.C ((j.val : ℝ) + 1)
      let Q : Polynomial ℝ := fallBinomPoly (r - 1) P
      let qj : Fin n → ℝ := fun i => Q.eval (i.val : ℝ)
      let e : Fin n → ℝ := sCol r n j.val - qj
      have hQdeg : Q.degree < (r : WithBot ℕ) := by
        have hPdeg : P.degree ≤ 1 := by
          refine (Polynomial.degree_sub_le _ _).trans (max_le ?_ (Polynomial.degree_C_le.trans (by decide)))
          rw [Polynomial.degree_X]
        exact (degree_fallBinomPoly_le (r - 1) P hPdeg).trans_lt (Nat.cast_lt.mpr (by omega))
      have he_zero_ge : ∀ i : Fin n, j1 ≤ i.val → e i = 0 := by
        intro i hi
        have hPeval : P.eval (i.val : ℝ) = ((((i : ℤ) - (j.val : ℤ) - 1) : ℤ) : ℝ) := by
          simp only [P, Polynomial.eval_sub, Polynomial.eval_X, Polynomial.eval_C,
            Int.cast_sub, Int.cast_natCast, Int.cast_one]
          ring
        have hqe : qj i = sCol r n j.val i :=
          eval_fallBinomPoly_eq_bfun (r - 1) P (i.val : ℝ) ((i : ℤ) - (j.val : ℤ) - 1)
            (by omega) hPeval
        simp [e, hqe]
      refine ⟨e, ?_, ?_, ?_, ?_⟩
      · have hsub : sCol r n j.val - e = qj := by dsimp only [e]; abel
        rw [hsub]
        exact Submodule.mem_sup_left (poly_eval_mem_polySpace r n Q hQdeg)
      · intro i hi
        have hilt : i.val < j1 := by
          by_contra hge; exact hi (he_zero_ge i (by omega))
        have hrh : (r - 1) * h ≤ r * h := Nat.mul_le_mul_right h (Nat.sub_le r 1)
        change |(i.val : ℤ) - (j.val : ℤ)| ≤ ((r * h : ℕ) : ℤ)
        rw [abs_le]
        constructor <;> omega
      · have hsub : (Finset.univ.filter fun i : Fin n => e i ≠ 0).image Fin.val ⊆ range j1 := by
          intro idx hidx
          rcases Finset.mem_image.mp hidx with ⟨i, hi, rfl⟩
          rw [Finset.mem_filter] at hi
          rw [Finset.mem_range]
          by_contra hge; exact hi.2 (he_zero_ge i (by omega))
        have hcard := Finset.card_le_card hsub
        rw [Finset.card_image_of_injective _ Fin.val_injective, Finset.card_range] at hcard
        exact hcard.trans (hj1_le_rh.trans (Nat.mul_le_mul_right h (Nat.sub_le r 1)))
      · intro i
        by_cases hi : j1 ≤ i.val
        · rw [he_zero_ge i hi, abs_zero]; unfold cInf; positivity
        · have hsj0 : sCol r n j.val i = 0 := by
            unfold sCol bfun
            have hneg : ¬ (0 : ℤ) ≤ (i : ℤ) - (j.val : ℤ) - 1 := by omega
            simp only [hneg, ↓reduceIte]
          have hei : |e i| = |qj i| := by simp [e, hsj0]
          rw [hei]
          dsimp only [qj, Q]
          rw [eval_fallBinomPoly, abs_div, Finset.abs_prod,
            abs_of_pos (Nat.cast_pos.mpr (Nat.factorial_pos (r - 1)))]
          have hprod_le : ∏ k ∈ range (r - 1), |P.eval (i.val : ℝ) - (k : ℝ)| ≤
              (2 * r : ℝ) ^ (r - 1) * (h : ℝ) ^ (r - 1) := by
            calc ∏ k ∈ range (r - 1), |P.eval (i.val : ℝ) - (k : ℝ)|
                ≤ ∏ _k ∈ range (r - 1), ((2 * r : ℝ) * (h : ℝ)) := by
                  gcongr with k hk
                  have hk_lt : k < r - 1 := Finset.mem_range.mp hk
                  have hval : P.eval (i.val : ℝ) - (k : ℝ) = -(((j.val + 1 + k - i.val : ℕ) : ℝ)) := by
                    simp only [P, Polynomial.eval_sub, Polynomial.eval_X, Polynomial.eval_C]
                    rw [Nat.cast_sub (by omega)]; push_cast; ring
                  rw [hval, abs_neg, abs_of_nonneg (Nat.cast_nonneg _)]
                  have hnat : j.val + 1 + k - i.val ≤ 2 * r * h := by
                    have h1 : (r - 1) * h ≤ r * h := Nat.mul_le_mul_right h (Nat.sub_le r 1)
                    have h2 : k ≤ r * h := (by omega : k ≤ r).trans (Nat.le_mul_of_pos_right r (by omega))
                    have h3 : r * h + r * h = 2 * r * h := by ring
                    omega
                  exact_mod_cast hnat
              _ = (2 * r : ℝ) ^ (r - 1) * (h : ℝ) ^ (r - 1) := by
                  rw [Finset.prod_const, Finset.card_range, mul_pow]
          calc (∏ k ∈ range (r - 1), |P.eval (i.val : ℝ) - (k : ℝ)|) / ((r - 1).factorial : ℝ)
              ≤ ((2 * r : ℝ) ^ (r - 1) * (h : ℝ) ^ (r - 1)) / ((r - 1).factorial : ℝ) :=
                div_le_div_of_nonneg_right hprod_le (Nat.cast_nonneg _)
            _ = (2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1) := by ring
            _ ≤ cInf r * (h : ℝ) ^ (r - 1) := hcInf_fac
    · -- Case 3: `j1 > J' * h`. Put `e = s_j`.
      have hj1_gt : J1 * h < j1 := by omega
      have hm_lt : m < J1 * h + h := by
        have hmod := Nat.mod_lt m (by omega : 0 < h)
        have hdm := Nat.div_add_mod m h
        change m < (m / h) * h + h
        rw [mul_comm (m / h) h]
        omega
      let e : Fin n → ℝ := sCol r n j.val
      have he_zero_lt : ∀ i : Fin n, i.val < j.val + r → e i = 0 := by
        intro i hi
        unfold e sCol bfun
        by_cases ht : 0 ≤ (i : ℤ) - (j.val : ℤ) - 1
        · simp only [ht, ↓reduceIte]
          have hlt : ((i : ℤ) - (j.val : ℤ) - 1).toNat < r - 1 := by omega
          rw [Nat.choose_eq_zero_of_lt hlt, Nat.cast_zero]
        · simp only [ht, ↓reduceIte]
      refine ⟨e, ?_, ?_, ?_, ?_⟩
      · rw [sub_self]; exact Submodule.zero_mem _
      · intro i hi
        have hge : j.val + r ≤ i.val := by
          by_contra hlt; exact hi (he_zero_lt i (by omega))
        have hrh : r + h ≤ r * h + 2 := by nlinarith
        have hle : i.val - j.val ≤ r * h := by
          have := i.isLt
          omega
        change |(i.val : ℤ) - (j.val : ℤ)| ≤ ((r * h : ℕ) : ℤ)
        rw [abs_le]
        constructor <;> omega
      · have hsub : (Finset.univ.filter fun i : Fin n => e i ≠ 0).image Fin.val ⊆
            Finset.Ico (j.val + r) n := by
          intro idx hidx
          rcases Finset.mem_image.mp hidx with ⟨i, hi, rfl⟩
          rw [Finset.mem_filter] at hi
          rw [Finset.mem_Ico]
          refine ⟨?_, i.isLt⟩
          by_contra hlt; exact hi.2 (he_zero_lt i (by omega))
        have hcard := Finset.card_le_card hsub
        rw [Finset.card_image_of_injective _ Fin.val_injective, Nat.card_Ico] at hcard
        have hle : n - (j.val + r) ≤ h := by omega
        have hhr : h ≤ r * h := Nat.le_mul_of_pos_left h (by omega)
        exact hcard.trans (hle.trans hhr)
      · intro i
        by_cases hi : i.val < j.val + r
        · rw [he_zero_lt i hi, abs_zero]; unfold cInf; positivity
        · have ht : 0 ≤ (i : ℤ) - (j.val : ℤ) - 1 := by omega
          have hnn : 0 ≤ e i := by unfold e sCol bfun; simp only [ht, ↓reduceIte]; positivity
          rw [abs_of_nonneg hnn]
          refine (bfun_le_pow_div_factorial (r - 1) _ ht).trans ?_
          have hle_2rh : ((i : ℤ) - (j.val : ℤ) - 1).toNat ≤ 2 * r * h := by
            have h1 : h + r ≤ 2 * r * h := by nlinarith
            have := i.isLt
            omega
          have hpow : ((((i : ℤ) - (j.val : ℤ) - 1).toNat : ℝ)) ^ (r - 1) ≤
              (2 * r : ℝ) ^ (r - 1) * (h : ℝ) ^ (r - 1) := by
            rw [← mul_pow]
            exact pow_le_pow_left₀ (Nat.cast_nonneg _) (by exact_mod_cast hle_2rh) (r - 1)
          calc ((((i : ℤ) - (j.val : ℤ) - 1).toNat : ℝ)) ^ (r - 1) / ((r - 1).factorial : ℝ)
              ≤ ((2 * r : ℝ) ^ (r - 1) * (h : ℝ) ^ (r - 1)) / ((r - 1).factorial : ℝ) :=
                div_le_div_of_nonneg_right hpow (Nat.cast_nonneg _)
            _ = (2 * r : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) * (h : ℝ) ^ (r - 1) := by ring
            _ ≤ cInf r * (h : ℝ) ^ (r - 1) := hcInf_fac

/-- Lemma `pf:lem:F`, eq. `pf:eq:F`: `max_j ‖(I − P_J) s_j‖₂ ≤ c_F h^{r−1/2}` and
`‖(I − P_J) S‖_op ≤ c_op h^r` (the operator bound written as `‖(I − P_J) S u‖₂ ≤ c_op h^r ‖u‖₂`). -/
theorem spline_approx (r n J : ℕ) (hr : 2 ≤ r) (hn : r < n) (hJpos : 1 ≤ J) (hJm : J ≤ n - r) :
    (∀ j : Fin (n - r), l2norm (sCol r n j - PJ r n J (sCol r n j))
        ≤ cF r * (hJ (n - r) J : ℝ) ^ ((r : ℝ) - 1 / 2)) ∧
    (∀ u : Fin (n - r) → ℝ, l2norm (Smul r n u - PJ r n J (Smul r n u))
        ≤ cOp r * (hJ (n - r) J : ℝ) ^ r * l2norm u) := by
  let m := n - r
  let h := hJ m J
  have hh1 : 1 ≤ h := (hJ_le r n J hn hJpos hJm).1
  have hh0 : (0 : ℝ) < h := Nat.cast_pos.mpr (by omega)
  have hcInf_nn : 0 ≤ cInf r := by unfold cInf; positivity
  choose E hE_mem hE_supp hE_card hE_inf using
    fun j : Fin m => exists_localized_residual r n J hr hn hJpos hJm j
  have hPJ_eq : ∀ v w : Fin n → ℝ, v - w ∈ VJ r n J → v - PJ r n J v = w - PJ r n J w := by
    intro v w hvw
    have hfix : PJ r n J (v - w) = v - w := by
      have hmemE : toE n (v - w) ∈ (VJ r n J).map (toE n).toLinearMap := Submodule.mem_map_of_mem hvw
      change (toE n).symm (((VJ r n J).map (toE n).toLinearMap).starProjection (toE n (v - w))) = v - w
      rw [Submodule.starProjection_eq_self_iff.mpr hmemE, LinearEquiv.symm_apply_apply]
    have hlin := (PJ r n J).map_sub v w
    rw [hfix] at hlin
    ext i
    have := congr_fun hlin i
    simp only [Pi.sub_apply] at this ⊢
    linarith
  constructor
  · intro j
    rw [hPJ_eq (sCol r n j.val) (E j) (hE_mem j)]
    refine (l2norm_sub_PJ_le r n J (E j)).trans ?_
    have hsq : l2sq (E j) ≤ (r : ℝ) * (cInf r) ^ 2 * (h : ℝ) ^ (2 * r - 1) := by
      unfold l2sq
      let S := Finset.univ.filter fun i : Fin n => E j i ≠ 0
      have hsum_eq : ∑ i : Fin n, (E j i) ^ 2 = ∑ i ∈ S, (E j i) ^ 2 := by
        symm
        apply Finset.sum_subset (Finset.subset_univ S)
        intro i _ hi
        simp only [S, Finset.mem_filter, Finset.mem_univ, true_and, not_not] at hi
        rw [hi, zero_pow two_ne_zero]
      rw [hsum_eq]
      calc ∑ i ∈ S, (E j i) ^ 2
          ≤ ∑ _i ∈ S, (cInf r * (h : ℝ) ^ (r - 1)) ^ 2 := by
            apply Finset.sum_le_sum; intro i _
            rw [← sq_abs (E j i)]
            exact pow_le_pow_left₀ (abs_nonneg _) (hE_inf j i) 2
        _ = (S.card : ℝ) * (cInf r * (h : ℝ) ^ (r - 1)) ^ 2 := by simp
        _ ≤ ((r * h : ℕ) : ℝ) * (cInf r * (h : ℝ) ^ (r - 1)) ^ 2 :=
            mul_le_mul_of_nonneg_right (by exact_mod_cast hE_card j) (sq_nonneg _)
        _ = (r : ℝ) * (cInf r) ^ 2 * (h : ℝ) ^ (2 * r - 1) := by
            rw [Nat.cast_mul, mul_pow, ← pow_mul]
            have hpow : (h : ℝ) * (h : ℝ) ^ ((r - 1) * 2) = (h : ℝ) ^ (2 * r - 1) := by
              rw [← pow_succ']
              congr 1; omega
            calc (r : ℝ) * (h : ℝ) * ((cInf r) ^ 2 * (h : ℝ) ^ ((r - 1) * 2))
                = (r : ℝ) * (cInf r) ^ 2 * ((h : ℝ) * (h : ℝ) ^ ((r - 1) * 2)) := by ring
              _ = (r : ℝ) * (cInf r) ^ 2 * (h : ℝ) ^ (2 * r - 1) := by rw [hpow]
    have hrpow : Real.sqrt ((r : ℝ) * (cInf r) ^ 2 * (h : ℝ) ^ (2 * r - 1)) =
        cF r * (h : ℝ) ^ ((r : ℝ) - 1 / 2) := by
      have hrhs_nn : 0 ≤ cF r * (h : ℝ) ^ ((r : ℝ) - 1 / 2) := by
        unfold cF; positivity
      rw [Real.sqrt_eq_iff_eq_sq (by positivity) hrhs_nn]
      unfold cF
      rw [mul_pow, mul_pow, Real.sq_sqrt (Nat.cast_nonneg r)]
      have hhsq : ((h : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 = (h : ℝ) ^ (2 * r - 1) := by
        rw [← Real.rpow_natCast, ← Real.rpow_mul hh0.le]
        have hexp : ((r : ℝ) - 1 / 2) * (2 : ℕ) = ((2 * r - 1 : ℕ) : ℝ) := by
          rw [Nat.cast_sub (by omega : 1 ≤ 2 * r)]; push_cast; ring
        rw [hexp, Real.rpow_natCast]
      rw [hhsq]
    unfold l2norm
    rw [← hrpow]
    exact Real.sqrt_le_sqrt hsq
  · intro u
    let Eu : Fin n → ℝ := fun i => ∑ j : Fin m, E j i * u j
    have hmem_u : Smul r n u - Eu ∈ VJ r n J := by
      have heq : Smul r n u - Eu = ∑ j : Fin m, u j • (sCol r n j.val - E j) := by
        ext i
        simp only [Pi.sub_apply, Smul, Eu, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]
        rw [← Finset.sum_sub_distrib]
        apply Finset.sum_congr rfl; intro j _; ring
      rw [heq]
      exact Submodule.sum_mem _ fun j _ => Submodule.smul_mem _ _ (hE_mem j)
    rw [hPJ_eq (Smul r n u) Eu hmem_u]
    refine (l2norm_sub_PJ_le r n J Eu).trans ?_
    let Mcol : ℝ := (r : ℝ) * cInf r * (h : ℝ) ^ r
    let Mrow : ℝ := 3 * (r : ℝ) * cInf r * (h : ℝ) ^ r
    have hMcol_nn : 0 ≤ Mcol := by positivity
    have hMrow_nn : 0 ≤ Mrow := by positivity
    have hpow_h : (h : ℝ) * (h : ℝ) ^ (r - 1) = (h : ℝ) ^ r := by
      rw [← pow_succ']; congr 1; omega
    have hcol : ∀ j : Fin m, ∑ i : Fin n, |E j i| ≤ Mcol := by
      intro j
      let S := Finset.univ.filter fun i : Fin n => E j i ≠ 0
      have hsum_eq : ∑ i : Fin n, |E j i| = ∑ i ∈ S, |E j i| := by
        symm
        apply Finset.sum_subset (Finset.subset_univ S)
        intro i _ hi
        simp only [S, Finset.mem_filter, Finset.mem_univ, true_and, not_not] at hi
        rw [hi, abs_zero]
      rw [hsum_eq]
      calc ∑ i ∈ S, |E j i|
          ≤ ∑ _i ∈ S, cInf r * (h : ℝ) ^ (r - 1) :=
            Finset.sum_le_sum fun i _ => hE_inf j i
        _ = (S.card : ℝ) * (cInf r * (h : ℝ) ^ (r - 1)) := by simp
        _ ≤ ((r * h : ℕ) : ℝ) * (cInf r * (h : ℝ) ^ (r - 1)) :=
            mul_le_mul_of_nonneg_right (by exact_mod_cast hE_card j) (by positivity)
        _ = Mcol := by
            rw [Nat.cast_mul]
            dsimp only [Mcol]
            calc (r : ℝ) * (h : ℝ) * (cInf r * (h : ℝ) ^ (r - 1))
                = (r : ℝ) * cInf r * ((h : ℝ) * (h : ℝ) ^ (r - 1)) := by ring
              _ = (r : ℝ) * cInf r * (h : ℝ) ^ r := by rw [hpow_h]
    have hrow : ∀ i : Fin n, ∑ j : Fin m, |E j i| ≤ Mrow := by
      intro i
      let S := Finset.univ.filter fun j : Fin m => E j i ≠ 0
      have hsum_eq : ∑ j : Fin m, |E j i| = ∑ j ∈ S, |E j i| := by
        symm
        apply Finset.sum_subset (Finset.subset_univ S)
        intro j _ hj
        simp only [S, Finset.mem_filter, Finset.mem_univ, true_and, not_not] at hj
        rw [hj, abs_zero]
      have hcard_S : S.card ≤ 3 * r * h := by
        let lo : ℕ := i.val - r * h
        let hi : ℕ := i.val + r * h + 1
        have hsub : S.image Fin.val ⊆ Finset.Ico lo hi := by
          intro idx hidx
          rcases Finset.mem_image.mp hidx with ⟨j, hj, rfl⟩
          rw [Finset.mem_filter] at hj
          have hbd : |(i.val : ℤ) - (j.val : ℤ)| ≤ ((r * h : ℕ) : ℤ) := hE_supp j i hj.2
          rw [abs_le] at hbd
          rw [Finset.mem_Ico]
          dsimp only [lo, hi]
          omega
        have h1 := Finset.card_le_card hsub
        rw [Finset.card_image_of_injective _ Fin.val_injective, Nat.card_Ico] at h1
        have h2 : hi - lo ≤ 3 * r * h := by
          have hrh : 1 ≤ r * h := Nat.mul_pos (by omega) (by omega)
          have h3 : 3 * r * h = 2 * (r * h) + r * h := by ring
          dsimp only [lo, hi]; omega
        exact h1.trans h2
      rw [hsum_eq]
      calc ∑ j ∈ S, |E j i|
          ≤ ∑ _j ∈ S, cInf r * (h : ℝ) ^ (r - 1) :=
            Finset.sum_le_sum fun j _ => hE_inf j i
        _ = (S.card : ℝ) * (cInf r * (h : ℝ) ^ (r - 1)) := by simp
        _ ≤ ((3 * r * h : ℕ) : ℝ) * (cInf r * (h : ℝ) ^ (r - 1)) :=
            mul_le_mul_of_nonneg_right (by exact_mod_cast hcard_S) (by positivity)
        _ = Mrow := by
            push_cast
            dsimp only [Mrow]
            calc 3 * (r : ℝ) * (h : ℝ) * (cInf r * (h : ℝ) ^ (r - 1))
                = 3 * (r : ℝ) * cInf r * ((h : ℝ) * (h : ℝ) ^ (r - 1)) := by ring
              _ = 3 * (r : ℝ) * cInf r * (h : ℝ) ^ r := by rw [hpow_h]
    have hschur := schur_test (fun i j => E j i) Mrow Mcol hMrow_nn hMcol_nn hrow hcol u
    have hsqrt : Real.sqrt (Mrow * Mcol) = cOp r * (h : ℝ) ^ r := by
      have hrhs_nn : 0 ≤ cOp r * (h : ℝ) ^ r := by unfold cOp; positivity
      rw [Real.sqrt_eq_iff_eq_sq (mul_nonneg hMrow_nn hMcol_nn) hrhs_nn]
      unfold cOp; dsimp only [Mrow, Mcol]
      rw [mul_pow, mul_pow, mul_pow, Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 3)]
      ring
    simpa only [Eu, hsqrt] using hschur

end BQTF
