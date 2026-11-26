import Mathlib

/-!
# Eckart–Young–Mirsky lower bound (Frobenius form)

For linear maps `T H : E →ₗ[ℝ] F` between finite-dimensional real inner product spaces with
`rank H ≤ J`, the Frobenius norm `‖T - H‖_F²` (computed in any orthonormal basis of `E`) is at
least the tail `∑_{q ≥ J} σ_q(T)²` of the squared singular values of `T`.

Proof: let `K = ker H`, `(u_k)` an orthonormal basis of `K` and `(v_q)` the eigenbasis of `T†T`.
* `∑_k ‖T u_k‖² = ∑_k ‖(T - H) u_k‖² ≤ ‖T - H‖_F²` (Bessel, after passing to the adjoint);
* `∑_k ‖T u_k‖² = ∑_q σ_q² w_q`, with `w_q = ∑_k ⟪v_q, u_k⟫² ∈ [0,1]`, `∑_q w_q = dim K ≥ d - J`;
* an elementary rearrangement gives `∑_q σ_q² w_q ≥ ∑_{q ≥ J} σ_q²` since `σ²` is antitone, `≥ 0`.
-/

open Module
open scoped RealInnerProductSpace

namespace BQTF.Lin

namespace EckartYoung

/-- Elementary weighted-sum lemma (Ky Fan, minimum form): with antitone nonnegative `f`
and weights `W ∈ [0,1]` of total mass at least `d - J`, the weighted sum dominates the tail. -/
theorem weighted_tail_le (f W : ℕ → ℝ) (d J : ℕ) (hf : Antitone f) (hf0 : ∀ q, 0 ≤ f q)
    (hW0 : ∀ q < d, 0 ≤ W q) (hW1 : ∀ q < d, W q ≤ 1)
    (hsum : (d : ℝ) - J ≤ ∑ q ∈ Finset.range d, W q) :
    ∑ q ∈ Finset.Ico J d, f q ≤ ∑ q ∈ Finset.range d, f q * W q := by
  rcases le_or_gt J d with hJ | hJ
  · have hc : 0 ≤ f J := hf0 J
    have hsplit : ∀ g : ℕ → ℝ, ∑ q ∈ Finset.range d, g q =
        ∑ q ∈ Finset.range J, g q + ∑ q ∈ Finset.Ico J d, g q := fun g =>
      (Finset.sum_range_add_sum_Ico g hJ).symm
    have h1 : ∑ q ∈ Finset.Ico J d, f q * (1 - W q) ≤
        ∑ q ∈ Finset.Ico J d, f J * (1 - W q) := by
      apply Finset.sum_le_sum
      intro q hq
      rw [Finset.mem_Ico] at hq
      exact mul_le_mul_of_nonneg_right (hf hq.1) (by linarith [hW1 q hq.2])
    have h2 : ∑ q ∈ Finset.range J, f J * W q ≤ ∑ q ∈ Finset.range J, f q * W q := by
      apply Finset.sum_le_sum
      intro q hq
      rw [Finset.mem_range] at hq
      exact mul_le_mul_of_nonneg_right (hf hq.le) (hW0 q (by omega))
    have e1 : ∑ q ∈ Finset.Ico J d, f q * (1 - W q) =
        ∑ q ∈ Finset.Ico J d, f q - ∑ q ∈ Finset.Ico J d, f q * W q := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun q _ => by ring
    have e2 : ∑ q ∈ Finset.Ico J d, f J * (1 - W q) =
        f J * ((d : ℝ) - J) - f J * ∑ q ∈ Finset.Ico J d, W q := by
      rw [← Finset.mul_sum, Finset.sum_sub_distrib, Finset.sum_const, Nat.card_Ico,
        nsmul_eq_mul, mul_one, Nat.cast_sub hJ]
      ring
    have e3 : ∑ q ∈ Finset.range J, f J * W q = f J * ∑ q ∈ Finset.range J, W q := by
      rw [Finset.mul_sum]
    have h3 := mul_le_mul_of_nonneg_left hsum hc
    rw [hsplit W, mul_add] at h3
    rw [hsplit (fun q => f q * W q)]
    linarith
  · rw [Finset.Ico_eq_empty (by omega), Finset.sum_empty]
    apply Finset.sum_nonneg
    intro q hq
    exact mul_nonneg (hf0 q) (hW0 q (Finset.mem_range.1 hq))

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]

/-- The Frobenius sum can be computed through the adjoint. -/
theorem frob_eq_adjoint {ι κ : Type*} [Fintype ι] [Fintype κ] (b : OrthonormalBasis ι ℝ E)
    (c : OrthonormalBasis κ ℝ F) (S : E →ₗ[ℝ] F) :
    ∑ i, ‖S (b i)‖ ^ 2 = ∑ j, ‖LinearMap.adjoint S (c j)‖ ^ 2 := by
  calc ∑ i, ‖S (b i)‖ ^ 2 = ∑ i, ∑ j, ⟪c j, S (b i)⟫ ^ 2 :=
        Finset.sum_congr rfl fun i _ => (c.sum_sq_inner_right (S (b i))).symm
    _ = ∑ j, ∑ i, ⟪LinearMap.adjoint S (c j), b i⟫ ^ 2 := by
        rw [Finset.sum_comm]
        simp_rw [LinearMap.adjoint_inner_left]
    _ = ∑ j, ‖LinearMap.adjoint S (c j)‖ ^ 2 :=
        Finset.sum_congr rfl fun j _ => b.sum_sq_inner_left _

/-- Bessel-type bound: the Frobenius sum over an orthonormal family is at most the
Frobenius sum over an orthonormal basis. -/
theorem orthonormal_sum_le {ι κ : Type*} [Fintype ι] [Fintype κ] (b : OrthonormalBasis ι ℝ E)
    (u : κ → E) (hu : Orthonormal ℝ u) (S : E →ₗ[ℝ] F) :
    ∑ k, ‖S (u k)‖ ^ 2 ≤ ∑ i, ‖S (b i)‖ ^ 2 := by
  let c := stdOrthonormalBasis ℝ F
  rw [frob_eq_adjoint b c S]
  calc ∑ k, ‖S (u k)‖ ^ 2 = ∑ k, ∑ j, ⟪u k, LinearMap.adjoint S (c j)⟫ ^ 2 := by
        refine Finset.sum_congr rfl fun k _ => ?_
        rw [← c.sum_sq_inner_right (S (u k))]
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [LinearMap.adjoint_inner_right, real_inner_comm (S (u k))]
    _ = ∑ j, ∑ k, ⟪u k, LinearMap.adjoint S (c j)⟫ ^ 2 := Finset.sum_comm
    _ ≤ ∑ j, ‖LinearMap.adjoint S (c j)‖ ^ 2 := by
        refine Finset.sum_le_sum fun j _ => ?_
        have := hu.sum_inner_products_le (LinearMap.adjoint S (c j)) (s := Finset.univ)
        simpa [Real.norm_eq_abs, sq_abs] using this

/-- Spectral expansion of `‖T x‖²` in the eigenbasis of `T†T`. -/
theorem norm_sq_eq_sum_eigen (T : E →ₗ[ℝ] F) (x : E) :
    ‖T x‖ ^ 2 = ∑ q, T.isSymmetric_adjoint_comp_self.eigenvalues rfl q *
      ⟪T.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl q, x⟫ ^ 2 := by
  have h1 : ‖T x‖ ^ 2 = ⟪(LinearMap.adjoint T ∘ₗ T) x, x⟫ := by
    rw [LinearMap.comp_apply, LinearMap.adjoint_inner_left, real_inner_self_eq_norm_sq]
  rw [h1, ← (T.isSymmetric_adjoint_comp_self.eigenvectorBasis rfl).sum_inner_mul_inner]
  refine Finset.sum_congr rfl fun q _ => ?_
  rw [T.isSymmetric_adjoint_comp_self x, T.isSymmetric_adjoint_comp_self.apply_eigenvectorBasis,
    inner_smul_right, real_inner_comm x]
  simp only [RCLike.ofReal_real_eq_id, id]
  ring

end EckartYoung

open EckartYoung in
theorem eckartYoung_tail {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]
    {ι : Type*} [Fintype ι] (b : OrthonormalBasis ι ℝ E) (T H : E →ₗ[ℝ] F) (J : ℕ)
    (hH : Module.finrank ℝ (LinearMap.range H) ≤ J) :
    ∑ q ∈ Finset.Ico J (Module.finrank ℝ E), T.singularValues q ^ 2 ≤
      ∑ i, ‖(T - H) (b i)‖ ^ 2 := by
  classical
  -- notation
  let d := finrank ℝ E
  let v := T.isSymmetric_adjoint_comp_self.eigenvectorBasis (rfl : finrank ℝ E = d)
  let lam := T.isSymmetric_adjoint_comp_self.eigenvalues (rfl : finrank ℝ E = d)
  let K := LinearMap.ker H
  let u0 := stdOrthonormalBasis ℝ K
  let u : Fin (finrank ℝ K) → E := K.subtypeₗᵢ ∘ u0
  have hu : Orthonormal ℝ u := u0.orthonormal.comp_linearIsometry K.subtypeₗᵢ
  -- weights
  let w : Fin d → ℝ := fun q => ∑ k, ⟪v q, u k⟫ ^ 2
  have hw0 : ∀ q, 0 ≤ w q := fun q => Finset.sum_nonneg fun k _ => sq_nonneg _
  have hw1 : ∀ q, w q ≤ 1 := by
    intro q
    have := hu.sum_inner_products_le (v q) (s := Finset.univ)
    rw [v.orthonormal.1 q, one_pow] at this
    simpa [w, Real.norm_eq_abs, sq_abs, real_inner_comm (v q)] using this
  have hwsum : ∑ q, w q = finrank ℝ K := by
    show ∑ q, ∑ k, ⟪v q, u k⟫ ^ 2 = _
    rw [Finset.sum_comm]
    have : ∀ k, ∑ q, ⟪v q, u k⟫ ^ 2 = 1 := fun k => by
      rw [v.sum_sq_inner_right, hu.1 k, one_pow]
    simp [this]
  have hK : (d : ℝ) - J ≤ finrank ℝ K := by
    have := LinearMap.finrank_range_add_finrank_ker H
    have h' : (finrank ℝ (LinearMap.range H) : ℝ) ≤ J := by exact_mod_cast hH
    have h'' : (finrank ℝ (LinearMap.range H) : ℝ) + finrank ℝ K = d := by exact_mod_cast this
    linarith
  -- Step A: restrict to the kernel of `H`
  have hA : ∑ k, ‖T (u k)‖ ^ 2 ≤ ∑ i, ‖(T - H) (b i)‖ ^ 2 := by
    have h := orthonormal_sum_le b u hu (T - H)
    have heq : ∀ k, (T - H) (u k) = T (u k) := fun k => by
      have : H (u k) = 0 := (u0 k).2
      rw [LinearMap.sub_apply, this, sub_zero]
    simpa only [heq] using h
  -- Step B: spectral expansion
  have hB : ∑ k, ‖T (u k)‖ ^ 2 = ∑ q, lam q * w q := by
    simp_rw [norm_sq_eq_sum_eigen T]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun q _ => ?_
    rw [Finset.mul_sum]
  -- Step C: pass to `ℕ`-indexed sums and apply the elementary lemma
  let f : ℕ → ℝ := fun q => T.singularValues q ^ 2
  let W : ℕ → ℝ := fun q => if h : q < d then w ⟨q, h⟩ else 0
  have hf : Antitone f := fun i j hij =>
    pow_le_pow_left₀ (T.singularValues_nonneg j) (T.singularValues_antitone hij) 2
  have hf0 : ∀ q, 0 ≤ f q := fun q => sq_nonneg _
  have hWq : ∀ q : Fin d, W q = w q := fun q => by simp [W, q.isLt]
  have hlam : ∀ q : Fin d, lam q = f q := fun q => (T.sq_singularValues_fin rfl q).symm
  have hC1 : ∑ q, lam q * w q = ∑ q ∈ Finset.range d, f q * W q := by
    rw [← Fin.sum_univ_eq_sum_range (fun q => f q * W q) d]
    exact Finset.sum_congr rfl fun q _ => by rw [hlam, hWq]
  have hC2 : ∑ q ∈ Finset.range d, W q = finrank ℝ K := by
    rw [← Fin.sum_univ_eq_sum_range W d, ← hwsum]
    exact Finset.sum_congr rfl fun q _ => hWq q
  have hmain := weighted_tail_le f W d J hf hf0
    (fun q hq => by simpa [W, hq] using hw0 ⟨q, hq⟩)
    (fun q hq => by simpa [W, hq] using hw1 ⟨q, hq⟩)
    (by rw [hC2]; exact hK)
  calc ∑ q ∈ Finset.Ico J (finrank ℝ E), T.singularValues q ^ 2
      = ∑ q ∈ Finset.Ico J d, f q := rfl
    _ ≤ ∑ q ∈ Finset.range d, f q * W q := hmain
    _ = ∑ k, ‖T (u k)‖ ^ 2 := by rw [hB, hC1]
    _ ≤ ∑ i, ‖(T - H) (b i)‖ ^ 2 := hA

end BQTF.Lin
