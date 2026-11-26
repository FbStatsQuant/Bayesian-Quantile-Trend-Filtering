import BQTF.Basic

/-!
# Falling factorials (appendix, eq. `pf:eq:pascal`)

Owner: Neon-A. Pascal's rule for `b_p(t) = C(t,p) 1{t ≥ 0}` and its iterate, the fact behind
`D S = I` in Lemma `pf:lem:coord`(a).
-/

open Finset

namespace BQTF

/-- Paper eq. `pf:eq:pascal`, first part: `b_p(t+1) − b_p(t) = b_{p−1}(t)` for `p ≥ 1`. -/
theorem bfun_pascal (p : ℕ) (hp : 1 ≤ p) (t : ℤ) :
    bfun p (t + 1) - bfun p t = bfun (p - 1) t := by
  unfold bfun
  by_cases ht : 0 ≤ t
  · have ht1 : 0 ≤ t + 1 := by omega
    simp only [ht, ht1, ↓reduceIte]
    obtain ⟨m, rfl⟩ := Int.eq_ofNat_of_zero_le ht
    obtain ⟨q, rfl⟩ := Nat.exists_eq_add_of_le' hp
    have h1 : ((m : ℤ) + 1).toNat = m + 1 := by omega
    have h2 : (m : ℤ).toNat = m := Int.toNat_natCast m
    rw [h1, h2]
    simp only [Nat.add_sub_cancel, Nat.choose_succ_succ', Nat.cast_add]
    ring
  · by_cases ht1 : 0 ≤ t + 1
    · have hteq : t = -1 := by omega
      subst hteq
      simp only [neg_add_cancel, le_refl, ↓reduceIte, Int.toNat_zero,
        show ¬ (0 : ℤ) ≤ -1 by omega]
      rw [Nat.choose_eq_zero_of_lt (by omega)]
      simp
    · simp [ht, ht1]

/-- Paper eq. `pf:eq:pascal`, second part: `b_0(t+1) − b_0(t) = 1(t = −1)`. -/
theorem bfun_zero_pascal (t : ℤ) :
    bfun 0 (t + 1) - bfun 0 t = if t = -1 then 1 else 0 := by
  unfold bfun
  by_cases ht : 0 ≤ t
  · have ht1 : 0 ≤ t + 1 := by omega
    have hne : t ≠ -1 := by omega
    simp [ht, ht1, hne]
  · by_cases ht1 : 0 ≤ t + 1
    · have hteq : t = -1 := by omega
      subst hteq
      simp
    · have hne : t ≠ -1 := by omega
      simp [ht, ht1, hne]

/-- Forward difference of shifted `bfun`: `Δ_[1] (t ↦ b_p(t - c)) = (t ↦ b_{p-1}(t - c))`. -/
lemma fwdDiff_bfun_shift (p : ℕ) (hp : 1 ≤ p) (c : ℤ) :
    fwdDiff (1 : ℤ) (fun t => bfun p (t - c)) = fun t => bfun (p - 1) (t - c) := by
  ext t
  change bfun p (t + 1 - c) - bfun p (t - c) = bfun (p - 1) (t - c)
  rw [show t + 1 - c = (t - c) + 1 by omega]
  exact bfun_pascal p hp (t - c)

/-- Iterated forward difference of shifted `bfun` reduces order `p` to `0`. -/
lemma fwdDiff_iter_bfun_shift (p : ℕ) (c : ℤ) :
    (fwdDiff (1 : ℤ))^[p] (fun t => bfun p (t - c)) = fun t => bfun 0 (t - c) := by
  induction p with
  | zero => rfl
  | succ p ih =>
    rw [Function.iterate_succ_apply, fwdDiff_bfun_shift (p + 1) (Nat.succ_pos p) c]
    simpa using ih

/-- Applying `Δ_[1]^(p+1)` to `t ↦ b_p(t - c)` yields the Kronecker delta `1(t - c = -1)`. -/
lemma fwdDiff_iter_succ_bfun_shift (p : ℕ) (c t : ℤ) :
    (fwdDiff (1 : ℤ))^[p + 1] (fun s => bfun p (s - c)) t = if t - c = -1 then 1 else 0 := by
  rw [Function.iterate_succ_apply', fwdDiff_iter_bfun_shift]
  change bfun 0 (t + 1 - c) - bfun 0 (t - c) = _
  rw [show t + 1 - c = (t - c) + 1 by omega]
  exact bfun_zero_pascal (t - c)

/-- `diffOp r n θ i` agrees with the `r`-th iterated forward difference of any `ℤ → ℝ`
extension of `θ`. -/
lemma diffOp_eq_fwdDiff_iter (r n : ℕ) (θ : Fin n → ℝ) (f : ℤ → ℝ)
    (hf : ∀ k : Fin n, f (k : ℤ) = θ k) (i : Fin (n - r)) :
    diffOp r n θ i = (fwdDiff (1 : ℤ))^[r] f (i : ℤ) := by
  rw [fwdDiff_iter_eq_sum_shift, diffOp]
  rw [← Fin.sum_univ_eq_sum_range (fun l =>
    ((-1 : ℤ) ^ (r - l) * (r.choose l : ℕ)) • f ((i : ℤ) + l • (1 : ℤ))) (r + 1)]
  apply Finset.sum_congr rfl
  intro l _
  simp only [zsmul_eq_mul, nsmul_eq_mul, mul_one, Int.cast_mul,
    Int.cast_pow, Int.cast_neg, Int.cast_one, Int.cast_natCast]
  have hidx : i.val + l.val < n := by have := i.isLt; have := l.isLt; omega
  have hfeq := hf ⟨i.val + l.val, hidx⟩
  simp only [Nat.cast_add] at hfeq
  rw [hfeq]

/-- Columnwise identity `D^{(r)} s_j = e_j` for `r ≥ 1`, `r < n`. -/
lemma diffOp_sCol (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (j i : Fin (n - r)) :
    diffOp r n (sCol r n j.val) i = if i = j then 1 else 0 := by
  obtain ⟨p, rfl⟩ := Nat.exists_eq_add_of_le' hr
  rw [diffOp_eq_fwdDiff_iter (p + 1) n (sCol (p + 1) n j.val)
    (fun t => bfun p (t - (j.val + 1))) (fun k => by
      simp only [sCol, Nat.add_sub_cancel]
      congr 1; omega)]
  rw [fwdDiff_iter_succ_bfun_shift]
  have hiff : ((i : ℤ) - ((j.val : ℤ) + 1) = -1) ↔ i = j := by
    constructor
    · intro h; ext; omega
    · intro h; subst h; omega
  simp [hiff]

/-- `D^{(r)}` annihilates every monomial `(i^p)_i` of degree `p < r`. -/
lemma diffOp_monomial (r n : ℕ) (p : Fin r) :
    diffOp r n (monomial r n p) = 0 := by
  ext i
  rw [Pi.zero_apply]
  rw [diffOp_eq_fwdDiff_iter r n (monomial r n p) (fun t : ℤ => (t : ℝ) ^ (p : ℕ))
    (fun k => by simp [monomial])]
  have hcast : (fwdDiff (1 : ℤ))^[r] (fun t : ℤ => (t : ℝ) ^ (p : ℕ)) (i : ℤ) =
      (fwdDiff (1 : ℝ))^[r] (fun x : ℝ => x ^ (p : ℕ)) (i : ℝ) := by
    rw [fwdDiff_iter_eq_sum_shift, fwdDiff_iter_eq_sum_shift]
    apply Finset.sum_congr rfl
    intro l _
    simp [zsmul_eq_mul, nsmul_eq_mul]
  rw [hcast, fwdDiff_iter_pow_eq_zero_of_lt p.isLt, Pi.zero_apply]

/-! ### Falling-binomial evaluation and bound (shared by SplineApprox, Smooth, Interp) -/

/-- For `t ≥ 0`, `b_p(t) = ∏_{k < p} (t − k) / p!` (the falling-binomial polynomial at `t`). -/
theorem bfun_eq_prod_div_factorial (p : ℕ) (t : ℤ) (ht : 0 ≤ t) :
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

/-- `b_p(t) ≤ t^p / p!` for `t ≥ 0`. -/
theorem bfun_le_pow_div_factorial (p : ℕ) (t : ℤ) (ht : 0 ≤ t) :
    bfun p t ≤ ((t.toNat : ℝ) ^ p) / (p.factorial : ℝ) := by
  rw [bfun]
  simp only [ht, ↓reduceIte]
  have hfac : (0 : ℝ) < p.factorial := Nat.cast_pos.mpr (Nat.factorial_pos p)
  rw [le_div_iff₀ hfac]
  have hnat : t.toNat.choose p * p.factorial ≤ t.toNat ^ p := by
    rw [mul_comm, ← Nat.descFactorial_eq_factorial_mul_choose]
    exact Nat.descFactorial_le_pow t.toNat p
  exact_mod_cast hnat

end BQTF
