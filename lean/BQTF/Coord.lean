import BQTF.Falling

/-!
# Coordinates (appendix, Lemma `pf:lem:coord`)

Owner: Neon-A. With `r = k + 1` and `n > r`: `D S = I`, `ker D = 𝒫`, the coordinates
`θ = N c + S u`, the ratio form of the posterior (eq. `pf:eq:ratio`), Pythagoras
(eq. `pf:eq:pyth`) and the volume formula (eq. `pf:eq:vol`).

In θ-coordinates `c − c̄(u) = Nᵀ(θ − θ*)` and `u = Dθ` (this follows from (a)–(c)), so the volume
formula is stated with `Nᵀ(θ − θ*)` and `Dθ`.
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `u* = D θ*`. -/
def ustar (r n : ℕ) (θs : Fin n → ℝ) : Fin (n - r) → ℝ := diffOp r n θs

/-- `c* = Nᵀ(θ* − S u*)`. -/
def cstar (r n : ℕ) (θs : Fin n → ℝ) : Fin r → ℝ := NT r n (θs - Smul r n (ustar r n θs))

/-- `c̄(u) = c* − Nᵀ S (u − u*)`. -/
def cbar (r n : ℕ) (θs : Fin n → ℝ) (u : Fin (n - r) → ℝ) : Fin r → ℝ :=
  cstar r n θs - NT r n (Smul r n (u - ustar r n θs))

/-! ## Linearity and ℓ² helpers -/

/-- `diffOp r n` as a linear map. -/
def diffOpLinear (r n : ℕ) : (Fin n → ℝ) →ₗ[ℝ] (Fin (n - r) → ℝ) where
  toFun := diffOp r n
  map_add' θ₁ θ₂ := by
    ext i; simp only [diffOp, Pi.add_apply, mul_add, Finset.sum_add_distrib]
  map_smul' a θ := by
    ext i
    simp only [diffOp, Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro l _; ring

/-- `Smul r n` as a linear map. -/
def SmulLinear (r n : ℕ) : (Fin (n - r) → ℝ) →ₗ[ℝ] (Fin n → ℝ) where
  toFun := Smul r n
  map_add' u₁ u₂ := by
    ext i; simp only [Smul, Pi.add_apply, add_mul, Finset.sum_add_distrib]
  map_smul' a u := by
    ext i
    simp only [Smul, Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro j _; ring

/-- `Nmul r n` as a linear map. -/
def NmulLinear (r n : ℕ) : (Fin r → ℝ) →ₗ[ℝ] (Fin n → ℝ) where
  toFun := Nmul r n
  map_add' c₁ c₂ := by
    ext i; simp only [Nmul, Pi.add_apply, add_mul, Finset.sum_add_distrib]
  map_smul' a c := by
    ext i
    simp only [Nmul, Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro p _; ring

/-- `NT r n` as a linear map. -/
def NTLinear (r n : ℕ) : (Fin n → ℝ) →ₗ[ℝ] (Fin r → ℝ) where
  toFun := NT r n
  map_add' v₁ v₂ := by
    ext p; simp only [NT, dot, Pi.add_apply, mul_add, Finset.sum_add_distrib]
  map_smul' a v := by
    ext p
    simp only [NT, dot, Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro i _; ring

lemma Smul_add (r n : ℕ) (u₁ u₂ : Fin (n - r) → ℝ) :
    Smul r n (u₁ + u₂) = Smul r n u₁ + Smul r n u₂ :=
  (SmulLinear r n).map_add u₁ u₂

lemma Smul_sub (r n : ℕ) (u₁ u₂ : Fin (n - r) → ℝ) :
    Smul r n (u₁ - u₂) = Smul r n u₁ - Smul r n u₂ :=
  (SmulLinear r n).map_sub u₁ u₂

lemma Smul_smul (r n : ℕ) (a : ℝ) (u : Fin (n - r) → ℝ) :
    Smul r n (a • u) = a • Smul r n u :=
  (SmulLinear r n).map_smul a u

lemma Nmul_add (r n : ℕ) (c₁ c₂ : Fin r → ℝ) :
    Nmul r n (c₁ + c₂) = Nmul r n c₁ + Nmul r n c₂ :=
  (NmulLinear r n).map_add c₁ c₂

lemma Nmul_sub (r n : ℕ) (c₁ c₂ : Fin r → ℝ) :
    Nmul r n (c₁ - c₂) = Nmul r n c₁ - Nmul r n c₂ :=
  (NmulLinear r n).map_sub c₁ c₂

lemma Nmul_smul (r n : ℕ) (a : ℝ) (c : Fin r → ℝ) :
    Nmul r n (a • c) = a • Nmul r n c :=
  (NmulLinear r n).map_smul a c

/-- `coordMap r n` as a linear map. -/
def coordLinear (r n : ℕ) : ((Fin r → ℝ) × (Fin (n - r) → ℝ)) →ₗ[ℝ] (Fin n → ℝ) where
  toFun := coordMap r n
  map_add' x y := by
    change Nmul r n (x.1 + y.1) + Smul r n (x.2 + y.2) =
      (Nmul r n x.1 + Smul r n x.2) + (Nmul r n y.1 + Smul r n y.2)
    rw [Nmul_add, Smul_add]
    abel
  map_smul' a x := by
    change Nmul r n (a • x.1) + Smul r n (a • x.2) = a • (Nmul r n x.1 + Smul r n x.2)
    rw [Nmul_smul, Smul_smul, smul_add]

lemma Smul_eq_sum (r n : ℕ) (u : Fin (n - r) → ℝ) :
    Smul r n u = ∑ j : Fin (n - r), u j • sCol r n j.val := by
  ext i; simp [Smul]

lemma Nmul_eq_sum (r n : ℕ) (c : Fin r → ℝ) :
    Nmul r n c = ∑ p : Fin r, c p • Ncol r n p := by
  ext i; simp [Nmul]

lemma inner_toE {n : ℕ} (u v : Fin n → ℝ) :
    @inner ℝ _ _ (toE n u) (toE n v) = dot u v := by
  simp only [toE, EuclideanSpace.inner_eq_star_dotProduct, star_trivial, dotProduct, dot]
  apply Finset.sum_congr rfl; intro i _
  change v i * u i = u i * v i
  ring

lemma norm_toE_sq {n : ℕ} (v : Fin n → ℝ) : ‖toE n v‖ ^ 2 = l2sq v := by
  rw [← real_inner_self_eq_norm_sq, inner_toE]
  simp [dot, l2sq, sq]

lemma norm_toE {n : ℕ} (v : Fin n → ℝ) : ‖toE n v‖ = l2norm v := by
  rw [l2norm, ← norm_toE_sq, Real.sqrt_sq (norm_nonneg _)]

/-- Linear independence of the monomial vectors `(i^p)_i` for `r ≤ n`. -/
lemma monomial_linearIndependent (r n : ℕ) (hn : r ≤ n) :
    LinearIndependent ℝ (monomial r n) := by
  rw [Fintype.linearIndependent_iff]
  intro c hc
  by_cases hr : r = 0
  · subst hr; intro p; exact Fin.elim0 p
  · have hr1 : 1 ≤ r := Nat.pos_of_ne_zero hr
    let P : Polynomial ℝ := ∑ p : Fin r, Polynomial.C (c p) * Polynomial.X ^ (p : ℕ)
    have hcoeff_lt : ∀ p : Fin r, P.coeff (p : ℕ) = c p := fun p => by
      simp [P, Polynomial.finsetSum_coeff, Fin.val_inj]
    have hcoeff_ge : ∀ k, r ≤ k → P.coeff k = 0 := fun k hk => by
      simp only [P, Polynomial.finsetSum_coeff, Polynomial.coeff_C_mul_X_pow]
      apply Finset.sum_eq_zero; intro p _
      simp [show k ≠ (p : ℕ) by omega]
    have hPzero : P = 0 := by
      by_contra hPne
      have hsub : (Finset.range r).image (fun k : ℕ => (k : ℝ)) ⊆ P.roots.toFinset := by
        intro x hx
        rcases Finset.mem_image.mp hx with ⟨k, hk, rfl⟩
        have hkr : k < r := Finset.mem_range.mp hk
        rw [Multiset.mem_toFinset, Polynomial.mem_roots hPne, Polynomial.IsRoot]
        have hev : P.eval (k : ℝ) = (∑ p : Fin r, c p • monomial r n p) ⟨k, by omega⟩ := by
          simp [P, Polynomial.eval_finsetSum, monomial]
        rw [hev, hc, Pi.zero_apply]
      have hcard_le : r ≤ P.roots.toFinset.card := by
        have := Finset.card_le_card hsub
        rwa [Finset.card_image_of_injective _ Nat.cast_injective, Finset.card_range] at this
      have hdeg : P.natDegree < r := by
        have hle : P.natDegree ≤ r - 1 :=
          Polynomial.natDegree_le_iff_coeff_eq_zero.mpr fun k hk => hcoeff_ge k (by omega)
        omega
      have hroots : P.roots.toFinset.card < r :=
        lt_of_le_of_lt ((Multiset.toFinset_card_le _).trans (Polynomial.card_roots' _)) hdeg
      omega
    intro p
    rw [← hcoeff_lt p, hPzero, Polynomial.coeff_zero]

/-- Lemma `pf:lem:coord`(a), first part: `D S = I_m`. -/
theorem diffOp_Smul (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (u : Fin (n - r) → ℝ) :
    diffOp r n (Smul r n u) = u := by
  ext i
  change diffOpLinear r n (Smul r n u) i = u i
  rw [Smul_eq_sum, map_sum, Finset.sum_apply]
  have hterm : ∀ j : Fin (n - r), diffOpLinear r n (u j • sCol r n j.val) i =
      if i = j then u j else 0 := by
    intro j
    rw [map_smul, Pi.smul_apply, smul_eq_mul]
    change u j * diffOp r n (sCol r n j.val) i = _
    rw [diffOp_sCol r n hr hn j i]
    split_ifs <;> ring
  simp [hterm]

/-- Lemma `pf:lem:coord`(a), second part: `ker D = 𝒫`. -/
theorem diffOp_eq_zero_iff (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (θ : Fin n → ℝ) :
    diffOp r n θ = 0 ↔ θ ∈ polySpace r n := by
  let D := diffOpLinear r n
  have hle : polySpace r n ≤ LinearMap.ker D := by
    rw [polySpace, Submodule.span_le]
    rintro _ ⟨p, rfl⟩
    exact diffOp_monomial r n p
  have hsurj : Function.Surjective D := fun u => ⟨Smul r n u, diffOp_Smul r n hr hn u⟩
  have hrange : LinearMap.range D = ⊤ := LinearMap.range_eq_top.mpr hsurj
  have hdim_poly : Module.finrank ℝ (polySpace r n) = r := by
    have hli := monomial_linearIndependent r n hn.le
    change Module.finrank ℝ (Submodule.span ℝ (Set.range (monomial r n))) = r
    rw [finrank_span_eq_card hli, Fintype.card_fin]
  have hdim_ker : Module.finrank ℝ (LinearMap.ker D) = r := by
    have hrn := LinearMap.finrank_range_add_finrank_ker D
    rw [hrange, finrank_top, Module.finrank_fin_fun, Module.finrank_fin_fun] at hrn
    omega
  have heq : polySpace r n = LinearMap.ker D :=
    Submodule.eq_of_le_of_finrank_eq hle (by rw [hdim_poly, hdim_ker])
  change θ ∈ LinearMap.ker D ↔ θ ∈ polySpace r n
  rw [heq]

/-- `N` is orthonormal: `⟨N_p, N_q⟩ = 1(p = q)`, and `N` spans `𝒫` (part of the setting of
Lemma `pf:lem:coord`). -/
theorem Ncol_orthonormal (r n : ℕ) (hn : r ≤ n) :
    (∀ p q, dot (Ncol r n p) (Ncol r n q) = if p = q then 1 else 0) ∧
    Submodule.span ℝ (Set.range (Ncol r n)) = polySpace r n := by
  let f : Fin r → EuclideanSpace ℝ (Fin n) := fun q => toE n (monomial r n q)
  have hf : LinearIndependent ℝ f :=
    (monomial_linearIndependent r n hn).map' (toE n).toLinearMap (toE n).ker
  have hortho : Orthonormal ℝ (InnerProductSpace.gramSchmidtNormed ℝ f) :=
    InnerProductSpace.gramSchmidtNormed_orthonormal hf
  constructor
  · intro p q
    rw [← inner_toE]
    have h1 : toE n (Ncol r n p) = InnerProductSpace.gramSchmidtNormed ℝ f p :=
      (toE n).apply_symm_apply _
    have h2 : toE n (Ncol r n q) = InnerProductSpace.gramSchmidtNormed ℝ f q :=
      (toE n).apply_symm_apply _
    rw [h1, h2]
    exact orthonormal_iff_ite.mp hortho p q
  · have hspanE : Submodule.span ℝ (Set.range (InnerProductSpace.gramSchmidtNormed ℝ f)) =
        Submodule.span ℝ (Set.range f) := by
      rw [InnerProductSpace.span_gramSchmidtNormed_range, InnerProductSpace.span_gramSchmidt]
    have hmap := congrArg (Submodule.map (toE n).symm.toLinearMap) hspanE
    simp only [Submodule.map_span, ← Set.range_comp] at hmap
    have h1 : ((toE n).symm.toLinearMap ∘ InnerProductSpace.gramSchmidtNormed ℝ f) = Ncol r n := by
      ext p i; rfl
    have h2 : ((toE n).symm.toLinearMap ∘ f) = monomial r n := by
      ext p i
      change (toE n).symm (toE n (monomial r n p)) i = monomial r n p i
      rw [LinearEquiv.symm_apply_apply]
    rw [h1, h2] at hmap
    exact hmap

/-! ## Properties of `N`, `Nᵀ`, `P`, `P^⊥` -/

lemma NT_Nmul (r n : ℕ) (hn : r ≤ n) (c : Fin r → ℝ) :
    NT r n (Nmul r n c) = c := by
  have hortho := (Ncol_orthonormal r n hn).1
  ext p
  simp only [NT, dot, Nmul]
  calc ∑ i : Fin n, Ncol r n p i * ∑ q : Fin r, c q * Ncol r n q i
      = ∑ q : Fin r, c q * dot (Ncol r n p) (Ncol r n q) := by
        simp_rw [Finset.mul_sum]
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl; intro q _
        simp only [dot, Finset.mul_sum]
        apply Finset.sum_congr rfl; intro i _; ring
    _ = ∑ q : Fin r, c q * (if p = q then 1 else 0) := by
        apply Finset.sum_congr rfl; intro q _; rw [hortho p q]
    _ = c p := by simp

lemma Nmul_mem_polySpace (r n : ℕ) (hn : r ≤ n) (c : Fin r → ℝ) :
    Nmul r n c ∈ polySpace r n := by
  rw [← (Ncol_orthonormal r n hn).2, Nmul_eq_sum]
  exact Submodule.sum_mem _ fun p _ => Submodule.smul_mem _ _ (Submodule.subset_span ⟨p, rfl⟩)

lemma Nmul_NT_of_mem_polySpace (r n : ℕ) (hn : r ≤ n) (v : Fin n → ℝ) (hv : v ∈ polySpace r n) :
    Nmul r n (NT r n v) = v := by
  rw [← (Ncol_orthonormal r n hn).2, Submodule.mem_span_range_iff_exists_fun] at hv
  obtain ⟨c, rfl⟩ := hv
  have hEq : (∑ p : Fin r, c p • Ncol r n p) = Nmul r n c := (Nmul_eq_sum r n c).symm
  rw [hEq, NT_Nmul r n hn]

lemma dot_Nmul_left (r n : ℕ) (c : Fin r → ℝ) (v : Fin n → ℝ) :
    dot (Nmul r n c) v = ∑ p : Fin r, c p * NT r n v p := by
  simp only [dot, Nmul, NT, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro p _
  apply Finset.sum_congr rfl; intro i _; ring

lemma Pproj_eq_Nmul_NT (r n : ℕ) (hn : r ≤ n) (v : Fin n → ℝ) :
    Pproj r n v = Nmul r n (NT r n v) := by
  let K : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (polySpace r n).map (toE n).toLinearMap
  have hmem : toE n (Nmul r n (NT r n v)) ∈ K :=
    Submodule.mem_map_of_mem (Nmul_mem_polySpace r n hn _)
  have horth : ∀ y ∈ K, @inner ℝ _ _ (toE n v - toE n (Nmul r n (NT r n v))) y = 0 := by
    intro y hy
    rcases Submodule.mem_map.mp hy with ⟨w, hw, rfl⟩
    rw [← map_sub]
    change @inner ℝ _ _ (toE n (v - Nmul r n (NT r n v))) (toE n w) = 0
    rw [inner_toE]
    have hdot_symm : ∀ a b : Fin n → ℝ, dot a b = dot b a := fun a b => by
      simp only [dot]; apply Finset.sum_congr rfl; intro i _; ring
    rw [← (Ncol_orthonormal r n hn).2, Submodule.mem_span_range_iff_exists_fun] at hw
    obtain ⟨a, rfl⟩ := hw
    have ha : (∑ p : Fin r, a p • Ncol r n p) = Nmul r n a := (Nmul_eq_sum r n a).symm
    rw [ha, hdot_symm, dot_Nmul_left]
    apply Finset.sum_eq_zero; intro p _
    have hNTsub : NT r n (v - Nmul r n (NT r n v)) = 0 := by
      change NTLinear r n (v - Nmul r n (NT r n v)) = 0
      rw [map_sub]
      change NT r n v - NT r n (Nmul r n (NT r n v)) = 0
      rw [NT_Nmul r n hn, sub_self]
    rw [hNTsub, Pi.zero_apply, mul_zero]
  have hproj : K.starProjection (toE n v) = toE n (Nmul r n (NT r n v)) :=
    Submodule.eq_starProjection_of_mem_of_inner_eq_zero hmem horth
  change (toE n).symm (K.starProjection (toE n v)) = Nmul r n (NT r n v)
  rw [hproj, LinearEquiv.symm_apply_apply]

lemma Pproj_of_mem_polySpace (r n : ℕ) (hn : r ≤ n) (v : Fin n → ℝ) (hv : v ∈ polySpace r n) :
    Pproj r n v = v := by
  rw [Pproj_eq_Nmul_NT r n hn, Nmul_NT_of_mem_polySpace r n hn v hv]

lemma Pperp_of_mem_polySpace (r n : ℕ) (hn : r ≤ n) (v : Fin n → ℝ) (hv : v ∈ polySpace r n) :
    Pperp r n v = 0 := by
  change v - Pproj r n v = 0
  rw [Pproj_of_mem_polySpace r n hn v hv, sub_self]

lemma l2sq_Nmul (r n : ℕ) (hn : r ≤ n) (c : Fin r → ℝ) :
    l2sq (Nmul r n c) = l2sq c := by
  have h1 : l2sq (Nmul r n c) = dot (Nmul r n c) (Nmul r n c) := by
    simp [l2sq, dot, sq]
  rw [h1, dot_Nmul_left, NT_Nmul r n hn]
  simp [l2sq, sq]

lemma l2sq_eq_l2sq_Pproj_add_l2sq_Pperp (r n : ℕ) (v : Fin n → ℝ) :
    l2sq v = l2sq (Pproj r n v) + l2sq (Pperp r n v) := by
  let K : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (polySpace r n).map (toE n).toLinearMap
  have hP : toE n (Pproj r n v) = K.starProjection (toE n v) := (toE n).apply_symm_apply _
  have hPp : toE n (Pperp r n v) = toE n v - K.starProjection (toE n v) := by
    change toE n (v - Pproj r n v) = _
    rw [map_sub, hP]
  have horth : @inner ℝ _ _ (toE n (Pperp r n v)) (toE n (Pproj r n v)) = 0 := by
    rw [hPp, hP]
    exact Submodule.starProjection_inner_eq_zero (K := K) (toE n v) _
      (Submodule.starProjection_apply_mem K (toE n v))
  have hsum : toE n v = toE n (Pperp r n v) + toE n (Pproj r n v) := by
    rw [hPp, hP, sub_add_cancel]
  rw [← norm_toE_sq, ← norm_toE_sq, ← norm_toE_sq, hsum,
    norm_add_sq_real, horth, mul_zero, add_zero, add_comm]

/-- Lemma `pf:lem:coord`(b): `(c, u) ↦ N c + S u` is a bijection `ℝ^r × ℝ^m → ℝⁿ`, with `u = Dθ`. -/
theorem coordMap_bijective (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) :
    Function.Bijective (coordMap r n) ∧
    ∀ cu, diffOp r n (coordMap r n cu) = cu.2 := by
  have hD : ∀ cu : (Fin r → ℝ) × (Fin (n - r) → ℝ), diffOp r n (coordMap r n cu) = cu.2 := by
    intro cu
    change diffOpLinear r n (Nmul r n cu.1 + Smul r n cu.2) = cu.2
    rw [map_add]
    have hN : diffOpLinear r n (Nmul r n cu.1) = 0 :=
      (diffOp_eq_zero_iff r n hr hn _).mpr (Nmul_mem_polySpace r n hn.le cu.1)
    rw [hN, zero_add]
    exact diffOp_Smul r n hr hn cu.2
  refine ⟨⟨?_, ?_⟩, hD⟩
  · intro x y hxy
    have hu : x.2 = y.2 := by rw [← hD x, ← hD y, hxy]
    have hN : Nmul r n x.1 = Nmul r n y.1 := by
      have : Nmul r n x.1 + Smul r n x.2 = Nmul r n y.1 + Smul r n y.2 := hxy
      rw [hu] at this
      exact add_right_cancel this
    have hc : x.1 = y.1 := by
      rw [← NT_Nmul r n hn.le x.1, ← NT_Nmul r n hn.le y.1, hN]
    exact Prod.ext hc hu
  · intro θ
    let u := diffOp r n θ
    let c := NT r n (θ - Smul r n u)
    refine ⟨(c, u), ?_⟩
    have hmem : θ - Smul r n u ∈ polySpace r n := by
      rw [← diffOp_eq_zero_iff r n hr hn]
      change diffOpLinear r n (θ - Smul r n u) = 0
      rw [map_sub]
      change diffOp r n θ - diffOp r n (Smul r n u) = 0
      rw [diffOp_Smul r n hr hn u, sub_self]
    change Nmul r n c + Smul r n u = θ
    rw [Nmul_NT_of_mem_polySpace r n hn.le _ hmem, sub_add_cancel]

/-! ## Measure-theoretic helpers for `laplace`, `Qlam`, `nu`, and `posterior` -/

/-- `∫⁻ x, exp(-a |x|) dx = 2 / a` for `a > 0`. -/
lemma lintegral_exp_neg_mul_abs {a : ℝ} (ha : 0 < a) :
    ∫⁻ x : ℝ, ENNReal.ofReal (Real.exp (-(a * |x|))) = ENNReal.ofReal (2 / a) := by
  have hIoi : ∫⁻ x in Set.Ioi (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |x|))) =
      ENNReal.ofReal (1 / a) := by
    have hcongr : ∫⁻ x in Set.Ioi (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |x|))) =
        ∫⁻ x in Set.Ioi (0 : ℝ), ENNReal.ofReal (Real.exp ((-a) * x)) := by
      apply setLIntegral_congr_fun measurableSet_Ioi
      intro x hx
      dsimp only
      rw [abs_of_pos (Set.mem_Ioi.mp hx), neg_mul]
    rw [hcongr]
    have hint : IntegrableOn (fun x : ℝ => Real.exp ((-a) * x)) (Set.Ioi 0) :=
      integrableOn_exp_mul_Ioi (neg_lt_zero.mpr ha) 0
    rw [← ofReal_integral_eq_lintegral_ofReal hint
      (Filter.Eventually.of_forall fun _ => (Real.exp_pos _).le)]
    have hval : ∫ x in Set.Ioi (0 : ℝ), Real.exp ((-a) * x) = 1 / a := by
      have hderiv : ∀ x ∈ Set.Ici (0 : ℝ),
          HasDerivAt (fun t : ℝ => -(1 / a) * Real.exp ((-a) * t)) (Real.exp ((-a) * x)) x := by
        intro x _
        have h1 : HasDerivAt (fun t : ℝ => (-a) * t) (-a) x := by
          simpa using (hasDerivAt_id x).const_mul (-a)
        have h2 := h1.exp
        have h3 := h2.const_mul (-(1 / a))
        convert h3 using 1
        field_simp [ha.ne']
      have htend : Filter.Tendsto (fun t : ℝ => -(1 / a) * Real.exp ((-a) * t))
          Filter.atTop (nhds 0) := by
        have h1 : Filter.Tendsto (fun t : ℝ => (-a) * t) Filter.atTop Filter.atBot :=
          Filter.Tendsto.const_mul_atTop_of_neg (neg_lt_zero.mpr ha) Filter.tendsto_id
        have h2 := Real.tendsto_exp_atBot.comp h1
        simpa using h2.const_mul (-(1 / a))
      have hcalc := integral_Ioi_of_hasDerivAt_of_tendsto' hderiv hint htend
      simpa using hcalc
    rw [hval]
  have hIio : ∫⁻ x in Set.Iio (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |x|))) =
      ENNReal.ofReal (1 / a) := by
    have hmeas : MeasurePreserving (fun x : ℝ => -x) volume volume := Measure.measurePreserving_neg volume
    have hpre : (fun x : ℝ => -x) ⁻¹' Set.Ioi (0 : ℝ) = Set.Iio (0 : ℝ) := by
      ext x; simp
    have hfmeas : Measurable (fun x : ℝ => ENNReal.ofReal (Real.exp (-(a * |x|)))) :=
      ENNReal.measurable_ofReal.comp (Real.measurable_exp.comp
        (Measurable.neg (measurable_const.mul measurable_id.abs)))
    calc ∫⁻ x in Set.Iio (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |x|)))
        = ∫⁻ x in (fun x : ℝ => -x) ⁻¹' Set.Ioi (0 : ℝ),
            ENNReal.ofReal (Real.exp (-(a * |(-x)|))) := by
          rw [hpre]
          apply setLIntegral_congr_fun measurableSet_Iio
          intro x _; simp [abs_neg]
      _ = ∫⁻ y in Set.Ioi (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |y|)))
            ∂(Measure.map (fun x : ℝ => -x) volume) :=
          (setLIntegral_map measurableSet_Ioi hfmeas measurable_neg).symm
      _ = ENNReal.ofReal (1 / a) := by rw [hmeas.map_eq, hIoi]
  have hIic : ∫⁻ x in Set.Iic (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |x|))) =
      ENNReal.ofReal (1 / a) := by
    rw [← hIio]
    exact setLIntegral_congr Iio_ae_eq_Iic.symm
  have hdisj : Disjoint (Set.Iic (0 : ℝ)) (Set.Ioi (0 : ℝ)) :=
    Set.disjoint_left.mpr fun _ hx1 hx2 =>
      not_lt_of_ge (Set.mem_Iic.mp hx1) (Set.mem_Ioi.mp hx2)
  have huniv : ∫⁻ x : ℝ, ENNReal.ofReal (Real.exp (-(a * |x|))) =
      (∫⁻ x in Set.Iic (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |x|)))) +
      (∫⁻ x in Set.Ioi (0 : ℝ), ENNReal.ofReal (Real.exp (-(a * |x|)))) := by
    rw [← setLIntegral_univ, ← Set.Iic_union_Ioi (a := (0 : ℝ)),
      lintegral_union measurableSet_Ioi hdisj]
  rw [huniv, hIic, hIoi, ← ENNReal.ofReal_add (by positivity) (by positivity)]
  congr 1; ring

lemma laplace_isProbabilityMeasure (lam : ℝ) (hlam : 0 < lam) :
    IsProbabilityMeasure (laplace lam) := by
  constructor
  rw [laplace, withDensity_apply _ MeasurableSet.univ, setLIntegral_univ]
  have hrew : ∀ x : ℝ, ENNReal.ofReal (laplacePDF lam x) =
      ENNReal.ofReal (lam / 2) * ENNReal.ofReal (Real.exp (-(lam * |x|))) := by
    intro x; simp [laplacePDF, ENNReal.ofReal_mul (by linarith : 0 ≤ lam / 2)]
  simp_rw [hrew]
  rw [lintegral_const_mul _ (by fun_prop), lintegral_exp_neg_mul_abs hlam,
    ← ENNReal.ofReal_mul (by linarith : 0 ≤ lam / 2)]
  have h1 : lam / 2 * (2 / lam) = 1 := by field_simp [hlam.ne']
  rw [h1, ENNReal.ofReal_one]

lemma Qlam_isProbabilityMeasure (m : ℕ) (lam : ℝ) (hlam : 0 < lam) :
    IsProbabilityMeasure (Qlam m lam) := by
  have : IsProbabilityMeasure (laplace lam) := laplace_isProbabilityMeasure lam hlam
  unfold Qlam
  infer_instance

/-- Fubini/Tonelli for products of `ℝ≥0∞`-valued functions on `Fin m → ℝ`. -/
lemma lintegral_fin_prod (m : ℕ) (f : Fin m → ℝ → ℝ≥0∞) (hf : ∀ i, Measurable (f i)) :
    ∫⁻ x : Fin m → ℝ, ∏ i, f i (x i) ∂volume = ∏ i, ∫⁻ t : ℝ, f i t ∂volume := by
  induction m with
  | zero =>
    simp [volume_pi, Measure.pi_empty_univ]
  | succ m ih =>
    have hmp := (volume_preserving_piFinSuccAbove (fun _ : Fin (m + 1) => ℝ) 0).symm
    rw [← hmp.lintegral_comp_emb (MeasurableEquiv.measurableEmbedding _)]
    have hcomp : ∀ p : ℝ × (Fin m → ℝ),
        (∏ i : Fin (m + 1), f i ((MeasurableEquiv.piFinSuccAbove (fun _ => ℝ) 0).symm p i)) =
          f 0 p.1 * ∏ j : Fin m, f j.succ (p.2 j) := by
      intro p
      rw [Fin.prod_univ_succ]
      simp [MeasurableEquiv.piFinSuccAbove_symm_apply]
    simp_rw [hcomp]
    have hgm : Measurable (fun y : Fin m → ℝ => ∏ j : Fin m, f j.succ (y j)) :=
      Finset.measurable_prod _ fun (j : Fin m) _ => (hf j.succ).comp (measurable_pi_apply j)
    rw [Measure.volume_eq_prod,
      lintegral_prod_mul (f := f 0) (g := fun y : Fin m → ℝ => ∏ j : Fin m, f j.succ (y j))
        (hf 0).aemeasurable hgm.aemeasurable,
      ih (fun (j : Fin m) => f j.succ) (fun (j : Fin m) => hf j.succ), Fin.prod_univ_succ]

/-- `Q_λ` has Lebesgue density `(λ/2)^m exp(-λ ‖u‖₁)` on `ℝ^m`. -/
lemma Qlam_eq_withDensity (m : ℕ) (lam : ℝ) (hlam : 0 < lam) :
    Qlam m lam =
      volume.withDensity (fun u : Fin m → ℝ =>
        ENNReal.ofReal ((lam / 2) ^ m * Real.exp (-(lam * l1norm u)))) := by
  have : IsProbabilityMeasure (laplace lam) := laplace_isProbabilityMeasure lam hlam
  unfold Qlam
  refine Measure.pi_eq (μ := fun _ : Fin m => laplace lam) fun s hs => ?_
  rw [withDensity_apply _ (MeasurableSet.univ_pi hs)]
  have hprod_eq : ∀ u : Fin m → ℝ,
      ENNReal.ofReal ((lam / 2) ^ m * Real.exp (-(lam * l1norm u))) =
        ∏ j : Fin m, ENNReal.ofReal (laplacePDF lam (u j)) := by
    intro u
    rw [← ENNReal.ofReal_prod_of_nonneg (fun j _ => by unfold laplacePDF; positivity)]
    congr 1
    simp only [laplacePDF, Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ,
      Fintype.card_fin, ← Real.exp_sum, l1norm, Finset.mul_sum, ← Finset.sum_neg_distrib]
  have hind : ∀ u : Fin m → ℝ,
      Set.indicator (Set.univ.pi s)
          (fun u => ENNReal.ofReal ((lam / 2) ^ m * Real.exp (-(lam * l1norm u)))) u =
        ∏ j : Fin m, Set.indicator (s j) (fun x => ENNReal.ofReal (laplacePDF lam x)) (u j) := by
    intro u
    by_cases hu : u ∈ Set.univ.pi s
    · rw [Set.indicator_of_mem hu, hprod_eq]
      apply Finset.prod_congr rfl; intro j _
      rw [Set.indicator_of_mem (hu j trivial)]
    · rw [Set.indicator_of_notMem hu]
      simp only [Set.mem_pi, Set.mem_univ, forall_true_left, not_forall] at hu
      obtain ⟨j₀, hj₀⟩ := hu
      symm
      exact Finset.prod_eq_zero (Finset.mem_univ j₀) (Set.indicator_of_notMem hj₀ _)
  rw [← lintegral_indicator (MeasurableSet.univ_pi hs)]
  simp_rw [hind]
  rw [lintegral_fin_prod m _ fun j =>
    (Measurable.indicator (by unfold laplacePDF; fun_prop) (hs j))]
  apply Finset.prod_congr rfl; intro j _
  rw [laplace, withDensity_apply _ (hs j), lintegral_indicator (hs j)]

/-- Lower bound on the check loss: `min(τ, 1-τ) |u| ≤ ρ_τ(u)`. -/
lemma min_mul_abs_le_checkLoss (τ u : ℝ) :
    min τ (1 - τ) * |u| ≤ checkLoss τ u := by
  unfold checkLoss
  by_cases hu : u < 0
  · simp only [hu, ↓reduceIte, abs_of_neg hu]
    have h1 : min τ (1 - τ) ≤ 1 - τ := min_le_right _ _
    nlinarith
  · simp only [hu, ↓reduceIte, abs_of_nonneg (not_lt.mp hu)]
    have h1 : min τ (1 - τ) ≤ τ := min_le_left _ _
    nlinarith

/-- Measurability of `postWeight`. -/
lemma measurable_postWeight (τ σ lam : ℝ) (k n : ℕ) (y : Fin n → ℝ) :
    Measurable (postWeight τ σ lam k n y) := by
  unfold postWeight checkLoss l1norm diffOp
  refine ENNReal.measurable_ofReal.comp (Real.measurable_exp.comp ?_)
  refine Measurable.sub (Measurable.div_const (Measurable.neg ?_) σ)
    (Measurable.const_mul ?_ lam)
  · refine Finset.measurable_sum _ fun i _ => ?_
    have hsub : Measurable (fun θ : Fin n → ℝ => y i - θ i) :=
      measurable_const.sub (measurable_pi_apply i)
    refine hsub.mul (measurable_const.sub ?_)
    exact Measurable.ite (measurableSet_lt hsub measurable_const) measurable_const measurable_const
  · refine Finset.measurable_sum _ fun i _ => ?_
    refine Measurable.abs (Finset.measurable_sum _ fun l _ => ?_)
    exact measurable_const.mul (measurable_pi_apply _)

/-- The normalizing integral `∫⁻ θ, postWeight ... dθ` is strictly positive and finite. -/
lemma lintegral_postWeight_pos_lt_top (k n : ℕ) (τ σ lam : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (hσ : 0 < σ) (hlam : 0 ≤ lam) (y : Fin n → ℝ) :
    0 < ∫⁻ θ, postWeight τ σ lam k n y θ ∧ ∫⁻ θ, postWeight τ σ lam k n y θ < ∞ := by
  constructor
  · rw [pos_iff_ne_zero]
    intro hzero
    have hae := (lintegral_eq_zero_iff (measurable_postWeight τ σ lam k n y)).mp hzero
    have hnever : ∀ θ, postWeight τ σ lam k n y θ ≠ 0 := fun θ => by
      unfold postWeight
      exact (ENNReal.ofReal_pos.mpr (Real.exp_pos _)).ne'
    have hnull : (volume : Measure (Fin n → ℝ)) Set.univ = 0 := by
      have hsub : Set.univ ⊆ {θ | postWeight τ σ lam k n y θ ≠ 0} := fun θ _ => hnever θ
      exact measure_mono_null hsub hae
    have hbox : (volume : Measure (Fin n → ℝ)) (Set.univ.pi fun _ : Fin n => Set.Icc (0 : ℝ) 1) = 1 := by
      rw [volume_pi_pi]
      simp
    have hle := measure_mono (μ := (volume : Measure (Fin n → ℝ)))
      (Set.subset_univ (Set.univ.pi fun _ : Fin n => Set.Icc (0 : ℝ) 1))
    rw [hbox, hnull] at hle
    exact one_ne_zero (le_antisymm hle bot_le)
  · let c0 : ℝ := min τ (1 - τ) / σ
    have hc0 : 0 < c0 := div_pos (lt_min hτ.1 (sub_pos.mpr hτ.2)) hσ
    have hpt : ∀ θ : Fin n → ℝ,
        postWeight τ σ lam k n y θ ≤
          ∏ i : Fin n, ENNReal.ofReal (Real.exp (-(c0 * |y i - θ i|))) := by
      intro θ
      rw [← ENNReal.ofReal_prod_of_nonneg fun i _ => (Real.exp_pos _).le]
      unfold postWeight
      apply ENNReal.ofReal_le_ofReal
      rw [← Real.exp_sum]
      apply Real.exp_le_exp.mpr
      have hl1 : 0 ≤ lam * l1norm (diffOp (k + 1) n θ) :=
        mul_nonneg hlam (Finset.sum_nonneg fun _ _ => abs_nonneg _)
      have hchk : ∑ i : Fin n, c0 * |y i - θ i| ≤ (∑ i : Fin n, checkLoss τ (y i - θ i)) / σ := by
        rw [Finset.sum_div]
        apply Finset.sum_le_sum; intro i _
        have hmin := min_mul_abs_le_checkLoss τ (y i - θ i)
        have := div_le_div_of_nonneg_right hmin hσ.le
        simpa [c0, div_mul_eq_mul_div] using this
      rw [Finset.sum_neg_distrib, neg_div]
      linarith
    have hmeas_f : ∀ i : Fin n,
        Measurable (fun t : ℝ => ENNReal.ofReal (Real.exp (-(c0 * |y i - t|)))) := fun i =>
      ENNReal.measurable_ofReal.comp (Real.measurable_exp.comp
        (Measurable.neg (measurable_const.mul (Measurable.abs (measurable_const.sub measurable_id)))))
    have hstep1 : ∫⁻ θ : Fin n → ℝ, postWeight τ σ lam k n y θ ∂volume ≤
        ∫⁻ θ : Fin n → ℝ, ∏ i : Fin n, ENNReal.ofReal (Real.exp (-(c0 * |y i - θ i|))) ∂volume :=
      lintegral_mono hpt
    have hstep2 : ∫⁻ θ : Fin n → ℝ, ∏ i : Fin n, ENNReal.ofReal (Real.exp (-(c0 * |y i - θ i|))) ∂volume =
        ∏ i : Fin n, ∫⁻ t : ℝ, ENNReal.ofReal (Real.exp (-(c0 * |y i - t|))) ∂volume :=
      lintegral_fin_prod n (fun i t => ENNReal.ofReal (Real.exp (-(c0 * |y i - t|)))) hmeas_f
    have hstep3 : ∏ i : Fin n, ∫⁻ t : ℝ, ENNReal.ofReal (Real.exp (-(c0 * |y i - t|))) ∂volume =
        ∏ _i : Fin n, ENNReal.ofReal (2 / c0) := by
      apply Finset.prod_congr rfl; intro i _
      have hshift : ∫⁻ t : ℝ, ENNReal.ofReal (Real.exp (-(c0 * |y i - t|))) =
          ∫⁻ t : ℝ, ENNReal.ofReal (Real.exp (-(c0 * |t|))) :=
        lintegral_sub_left_eq_self
          (fun t : ℝ => ENNReal.ofReal (Real.exp (-(c0 * |t|)))) (y i)
      rw [hshift, lintegral_exp_neg_mul_abs hc0]
    have hstep4 : (∏ _i : Fin n, ENNReal.ofReal (2 / c0)) < ∞ := by
      rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin]
      exact ENNReal.pow_lt_top ENNReal.ofReal_lt_top
    exact lt_of_le_of_lt (hstep1.trans_eq (hstep2.trans hstep3)) hstep4

/-- Pushing forward `(volume.prod volume)` along the linear bijection `coordMap` yields a positive
finite multiple of Lebesgue measure `volume` on `Fin n → ℝ`. -/
lemma map_coordMap_volume_prod (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) :
    ∃ J : ℝ≥0∞, J ≠ 0 ∧ J ≠ ∞ ∧
      Measure.map (coordMap r n)
          ((volume : Measure (Fin r → ℝ)).prod (volume : Measure (Fin (n - r) → ℝ))) =
        J • (volume : Measure (Fin n → ℝ)) := by
  let e : ((Fin r → ℝ) × (Fin (n - r) → ℝ)) ≃ₗ[ℝ] (Fin n → ℝ) :=
    LinearEquiv.ofBijective (coordLinear r n) (coordMap_bijective r n hr hn).1
  let eC : ((Fin r → ℝ) × (Fin (n - r) → ℝ)) ≃L[ℝ] (Fin n → ℝ) := e.toContinuousLinearEquiv
  have hcoe : (eC : ((Fin r → ℝ) × (Fin (n - r) → ℝ)) → (Fin n → ℝ)) = coordMap r n := rfl
  let μ' : Measure (Fin n → ℝ) :=
    Measure.map (coordMap r n)
      ((volume : Measure (Fin r → ℝ)).prod (volume : Measure (Fin (n - r) → ℝ)))
  have : Measure.IsAddHaarMeasure
      ((volume : Measure (Fin r → ℝ)).prod (volume : Measure (Fin (n - r) → ℝ))) := {}
  have : Measure.IsAddHaarMeasure μ' := by
    change Measure.IsAddHaarMeasure (Measure.map eC (volume.prod volume))
    exact eC.isAddHaarMeasure_map (volume.prod volume)
  have hsmul : μ' = (Measure.addHaarScalarFactor μ' (volume : Measure (Fin n → ℝ))) • volume :=
    Measure.isAddLeftInvariant_eq_smul μ' volume
  let J : ℝ≥0∞ := (Measure.addHaarScalarFactor μ' (volume : Measure (Fin n → ℝ)) : ℝ≥0∞)
  have hJtop : J ≠ ∞ := ENNReal.coe_ne_top
  have hJzero : J ≠ 0 := by
    intro h0
    have hμ0 : μ' = 0 := by rw [hsmul]; change J • volume = 0; rw [h0, zero_smul]
    exact Measure.IsOpenPosMeasure.open_pos (μ := μ') Set.univ isOpen_univ Set.univ_nonempty
      (by rw [hμ0]; simp)
  exact ⟨J, hJzero, hJtop, hsmul⟩

/-- Lemma `pf:lem:coord`(b), eq. `pf:eq:ratio`: at `σ = 1` the posterior is `N(B)/N(ℝⁿ)` with
`0 < N(ℝⁿ) < ∞`, for every measurable `B`, every `y` and every reference point `θ*`. -/
theorem posterior_eq_ratio (k n : ℕ) (hn : k + 1 < n) (τ lam : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (hlam : 0 < lam) (y θs : Fin n → ℝ) :
    0 < Nmass (k + 1) τ lam y θs Set.univ ∧ Nmass (k + 1) τ lam y θs Set.univ < ∞ ∧
    ∀ B, MeasurableSet B →
      posterior τ 1 lam k n y B = Nmass (k + 1) τ lam y θs B / Nmass (k + 1) τ lam y θs Set.univ := by
  let r := k + 1
  have hr : 1 ≤ r := Nat.succ_pos k
  let m := n - r
  obtain ⟨J, hJ0, hJtop, hJmap⟩ := map_coordMap_volume_prod r n hr hn
  let wPrior : (Fin n → ℝ) → ℝ≥0∞ := fun θ =>
    ENNReal.ofReal ((lam / 2) ^ m * Real.exp (-(lam * l1norm (diffOp r n θ))))
  have hwPrior_meas : Measurable wPrior := by
    unfold wPrior l1norm diffOp
    fun_prop
  have hcoord_meas : Measurable (coordMap r n) :=
    (coordLinear r n).continuous_of_finiteDimensional.measurable
  have hnu : nu r n lam = J • (volume.withDensity wPrior) := by
    have hprod_wd : (volume : Measure (Fin r → ℝ)).prod (Qlam m lam) =
        ((volume : Measure (Fin r → ℝ)).prod (volume : Measure (Fin m → ℝ))).withDensity
          (fun cu => wPrior (coordMap r n cu)) := by
      rw [Qlam_eq_withDensity m lam hlam, prod_withDensity_right (by unfold l1norm; fun_prop)]
      congr 1; ext cu
      simp only [wPrior, (coordMap_bijective r n hr hn).2 cu]
    unfold nu
    rw [hprod_wd]
    ext B hB
    rw [Measure.map_apply hcoord_meas hB, withDensity_apply _ (hcoord_meas hB),
      ← setLIntegral_map hB hwPrior_meas hcoord_meas, hJmap, Measure.smul_apply,
      withDensity_apply _ hB, setLIntegral_smul_measure]
  let cData : ℝ≥0∞ :=
    ENNReal.ofReal (Real.exp (∑ i : Fin n, checkLoss τ (y i - θs i))) *
      ENNReal.ofReal ((lam / 2) ^ m)
  have hcData0 : cData ≠ 0 :=
    mul_ne_zero (ENNReal.ofReal_pos.mpr (Real.exp_pos _)).ne'
      (ENNReal.ofReal_pos.mpr (pow_pos (half_pos hlam) m)).ne'
  have hcDatatop : cData ≠ ∞ := ENNReal.mul_ne_top ENNReal.ofReal_ne_top ENNReal.ofReal_ne_top
  let K : ℝ≥0∞ := J * cData
  have hK0 : K ≠ 0 := mul_ne_zero hJ0 hcData0
  have hKtop : K ≠ ∞ := ENNReal.mul_ne_top hJtop hcDatatop
  have hNmass_eq : ∀ B, MeasurableSet B →
      Nmass r τ lam y θs B = K * ∫⁻ θ in B, postWeight τ 1 lam k n y θ := by
    intro B hB
    unfold Nmass
    rw [hnu, setLIntegral_smul_measure, setLIntegral_withDensity_eq_setLIntegral_mul _ hwPrior_meas
      (by
        unfold lossHat checkLoss
        refine ENNReal.measurable_ofReal.comp (Real.measurable_exp.comp (Measurable.neg ?_))
        refine Finset.measurable_sum _ fun i _ => Measurable.sub ?_ measurable_const
        have hsub : Measurable (fun θ : Fin n → ℝ => (y - θs) i - (θ - θs) i) :=
          measurable_const.sub ((measurable_pi_apply i).sub measurable_const)
        exact hsub.mul (measurable_const.sub
          (Measurable.ite (measurableSet_lt hsub measurable_const) measurable_const measurable_const)))
      hB]
    have hmul_pt : ∀ θ : Fin n → ℝ,
        wPrior θ * ENNReal.ofReal (Real.exp (-lossHat τ (y - θs) (θ - θs))) =
          cData * postWeight τ 1 lam k n y θ := by
      intro θ
      unfold wPrior cData postWeight lossHat
      rw [← ENNReal.ofReal_mul (by positivity), ← ENNReal.ofReal_mul (by positivity),
        ← ENNReal.ofReal_mul (by positivity)]
      congr 1
      have hsub : ∀ i : Fin n, (y - θs) i - (θ - θs) i = y i - θ i := fun i => by
        change y i - θs i - (θ i - θs i) = y i - θ i; ring
      simp_rw [hsub]
      rw [Finset.sum_sub_distrib, div_one]
      have hexp : Real.exp (-(lam * l1norm (diffOp r n θ))) *
          Real.exp (-(∑ i : Fin n, checkLoss τ (y i - θ i) - ∑ i : Fin n, checkLoss τ (y i - θs i))) =
          Real.exp (∑ i : Fin n, checkLoss τ (y i - θs i)) *
            Real.exp (-(∑ i : Fin n, checkLoss τ (y i - θ i)) - lam * l1norm (diffOp r n θ)) := by
        rw [← Real.exp_add, ← Real.exp_add]
        congr 1; ring
      calc (lam / 2) ^ m * Real.exp (-(lam * l1norm (diffOp r n θ))) *
              Real.exp (-(∑ i : Fin n, checkLoss τ (y i - θ i) - ∑ i : Fin n, checkLoss τ (y i - θs i)))
          = (lam / 2) ^ m * (Real.exp (-(lam * l1norm (diffOp r n θ))) *
              Real.exp (-(∑ i : Fin n, checkLoss τ (y i - θ i) - ∑ i : Fin n, checkLoss τ (y i - θs i)))) := by
            ring
        _ = (lam / 2) ^ m * (Real.exp (∑ i : Fin n, checkLoss τ (y i - θs i)) *
              Real.exp (-(∑ i : Fin n, checkLoss τ (y i - θ i)) - lam * l1norm (diffOp r n θ))) := by
            rw [hexp]
        _ = Real.exp (∑ i : Fin n, checkLoss τ (y i - θs i)) * (lam / 2) ^ m *
              Real.exp (-(∑ i : Fin n, checkLoss τ (y i - θ i)) - lam * l1norm (diffOp r n θ)) := by
            ring
    simp_rw [Pi.mul_apply, hmul_pt]
    rw [lintegral_const_mul _ (measurable_postWeight τ 1 lam k n y), smul_eq_mul]
    simp only [K, cData, mul_assoc]
  have ⟨hZpos, hZtop⟩ := lintegral_postWeight_pos_lt_top k n τ 1 lam hτ zero_lt_one hlam.le y
  have hNuniv : Nmass r τ lam y θs Set.univ = K * ∫⁻ θ, postWeight τ 1 lam k n y θ := by
    rw [hNmass_eq Set.univ MeasurableSet.univ, setLIntegral_univ]
  refine ⟨?_, ?_, ?_⟩
  · rw [hNuniv]
    exact ENNReal.mul_pos hK0 hZpos.ne'
  · rw [hNuniv]
    exact ENNReal.mul_lt_top hKtop.lt_top hZtop
  · intro B hB
    rw [hNmass_eq B hB, hNuniv, ENNReal.mul_div_mul_left _ _ hK0 hKtop,
      posterior, Measure.smul_apply, withDensity_apply _ hB, smul_eq_mul, div_eq_mul_inv, mul_comm]

/-- Properness (docs D4): for `n ≥ 1`, `τ ∈ (0,1)`, `σ > 0`, `λ ≥ 0` the posterior is a
probability measure. -/
theorem posterior_isProbability (k n : ℕ) (hn : 1 ≤ n) (τ σ lam : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (hσ : 0 < σ) (hlam : 0 ≤ lam) (y : Fin n → ℝ) :
    IsProbabilityMeasure (posterior τ σ lam k n y) := by
  have _ := hn
  constructor
  have ⟨hZpos, hZtop⟩ := lintegral_postWeight_pos_lt_top k n τ σ lam hτ hσ hlam y
  rw [posterior, Measure.smul_apply, withDensity_apply _ MeasurableSet.univ,
    setLIntegral_univ, smul_eq_mul]
  exact ENNReal.inv_mul_cancel hZpos.ne' hZtop.ne

/-- Decomposition `coordMap (c, u) - θ* = N(c - c*) + S(u - u*)`. -/
lemma coordMap_sub_eq (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (θs : Fin n → ℝ)
    (c : Fin r → ℝ) (u : Fin (n - r) → ℝ) :
    coordMap r n (c, u) - θs =
      Nmul r n (c - cstar r n θs) + Smul r n (u - ustar r n θs) := by
  have hmem : θs - Smul r n (ustar r n θs) ∈ polySpace r n := by
    rw [← diffOp_eq_zero_iff r n hr hn]
    change diffOpLinear r n (θs - Smul r n (ustar r n θs)) = 0
    rw [map_sub]
    change diffOp r n θs - diffOp r n (Smul r n (diffOp r n θs)) = 0
    rw [diffOp_Smul r n hr hn, sub_self]
  have hθs : θs = Nmul r n (cstar r n θs) + Smul r n (ustar r n θs) := by
    unfold cstar
    rw [Nmul_NT_of_mem_polySpace r n hn.le _ hmem, sub_add_cancel]
  rw [Nmul_sub, Smul_sub]
  calc coordMap r n (c, u) - θs
      = (Nmul r n c + Smul r n u) - (Nmul r n (cstar r n θs) + Smul r n (ustar r n θs)) := by
        unfold coordMap; congr 1
    _ = (Nmul r n c - Nmul r n (cstar r n θs)) + (Smul r n u - Smul r n (ustar r n θs)) := by
        abel

/-- `c − c̄(u) = Nᵀ(θ − θ*)` for `θ = N c + S u`. -/
theorem sub_cbar_eq (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (θs : Fin n → ℝ)
    (c : Fin r → ℝ) (u : Fin (n - r) → ℝ) :
    c - cbar r n θs u = NT r n (coordMap r n (c, u) - θs) := by
  rw [coordMap_sub_eq r n hr hn θs c u]
  change c - cbar r n θs u = NTLinear r n (Nmul r n (c - cstar r n θs) + Smul r n (u - ustar r n θs))
  rw [map_add]
  change c - cbar r n θs u =
    NT r n (Nmul r n (c - cstar r n θs)) + NT r n (Smul r n (u - ustar r n θs))
  rw [NT_Nmul r n hn.le, cbar]
  abel

/-- Lemma `pf:lem:coord`(c), eq. `pf:eq:pyth`: for `θ = N c + S u`, `δ = θ − θ*`,
`‖δ‖₂² = ‖c − c̄(u)‖₂² + ‖P^⊥ S (u − u*)‖₂²`. -/
theorem pythagoras (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (θs : Fin n → ℝ)
    (c : Fin r → ℝ) (u : Fin (n - r) → ℝ) :
    l2sq (coordMap r n (c, u) - θs) =
      l2sq (c - cbar r n θs u) + l2sq (Pperp r n (Smul r n (u - ustar r n θs))) := by
  rw [l2sq_eq_l2sq_Pproj_add_l2sq_Pperp r n]
  congr 1
  · rw [Pproj_eq_Nmul_NT r n hn.le, ← sub_cbar_eq r n hr hn θs c u, l2sq_Nmul r n hn.le]
  · rw [coordMap_sub_eq r n hr hn θs c u, map_add,
      Pperp_of_mem_polySpace r n hn.le _ (Nmul_mem_polySpace r n hn.le _), zero_add]

/-- Volume of a closed Euclidean ball `{c : Fin r → ℝ | l2norm (c - x) ≤ s}` for `r ≥ 1, s ≥ 0`. -/
lemma volume_l2norm_closedBall (r : ℕ) (hr : 1 ≤ r) (x : Fin r → ℝ) (s : ℝ) (hs : 0 ≤ s) :
    (volume : Measure (Fin r → ℝ)) {c : Fin r → ℝ | l2norm (c - x) ≤ s} =
      Vr r * ENNReal.ofReal (s ^ r) := by
  have : Nonempty (Fin r) := ⟨⟨0, hr⟩⟩
  have hpre : {c : Fin r → ℝ | l2norm (c - x) ≤ s} =
      (@WithLp.toLp 2 (Fin r → ℝ)) ⁻¹' Metric.closedBall (WithLp.toLp 2 x) s := by
    ext c
    simp only [Set.mem_ofPred_eq, Set.mem_preimage, Metric.mem_closedBall, dist_eq_norm]
    have hnorm : ‖WithLp.toLp 2 c - WithLp.toLp 2 x‖ = l2norm (c - x) := by
      have := norm_toE (c - x)
      simpa [toE] using this
    rw [hnorm]
  rw [hpre, (PiLp.volume_preserving_toLp (Fin r)).measure_preimage
    Metric.isClosed_closedBall.measurableSet.nullMeasurableSet,
    EuclideanSpace.volume_closedBall]
  have hVr : Vr r =
      ENNReal.ofReal (Real.sqrt Real.pi ^ Fintype.card (Fin r) /
        Real.Gamma (Fintype.card (Fin r) / 2 + 1)) := by
    unfold Vr
    simpa using EuclideanSpace.volume_ball (Fin r) 0 1
  rw [← hVr, ENNReal.ofReal_pow hs, Fintype.card_fin, mul_comm]

/-- Lemma `pf:lem:coord`(c), eq. `pf:eq:vol`: for measurable `H ≥ 0` and `ϱ ≥ 0` on `ℝ^m`,
`∫ 1{‖c − c̄(u)‖₂ ≤ ϱ(u)} H(u) dν = V_r ∫ ϱ(u)^r H(u) dQ_λ(u)`. -/
theorem vol_formula (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (lam : ℝ) (hlam : 0 < lam)
    (θs : Fin n → ℝ) (H : (Fin (n - r) → ℝ) → ℝ≥0∞) (hH : Measurable H)
    (ϱ : (Fin (n - r) → ℝ) → ℝ) (hϱ : Measurable ϱ) (hϱ0 : ∀ u, 0 ≤ ϱ u) :
    ∫⁻ θ, Set.indicator {θ | l2norm (NT r n (θ - θs)) ≤ ϱ (diffOp r n θ)}
        (fun θ => H (diffOp r n θ)) θ ∂(nu r n lam) =
      Vr r * ∫⁻ u, ENNReal.ofReal (ϱ u ^ r) * H u ∂(Qlam (n - r) lam) := by
  have : IsProbabilityMeasure (Qlam (n - r) lam) := Qlam_isProbabilityMeasure (n - r) lam hlam
  have hcoord_meas : Measurable (coordMap r n) :=
    (coordLinear r n).continuous_of_finiteDimensional.measurable
  have hD_meas : Measurable (diffOp r n) :=
    (diffOpLinear r n).continuous_of_finiteDimensional.measurable
  have hNT_meas : Measurable (NT r n) :=
    (NTLinear r n).continuous_of_finiteDimensional.measurable
  have hl2_meas : Measurable (l2norm (n := r)) := by
    unfold l2norm l2sq; fun_prop
  have hset_meas : MeasurableSet {θ : Fin n → ℝ | l2norm (NT r n (θ - θs)) ≤ ϱ (diffOp r n θ)} :=
    measurableSet_le (hl2_meas.comp (hNT_meas.comp (measurable_id.sub measurable_const)))
      (hϱ.comp hD_meas)
  have hind_meas : Measurable (Set.indicator {θ | l2norm (NT r n (θ - θs)) ≤ ϱ (diffOp r n θ)}
      (fun θ => H (diffOp r n θ))) :=
    (hH.comp hD_meas).indicator hset_meas
  unfold nu
  rw [lintegral_map hind_meas hcoord_meas]
  have hcomp : ∀ cu : (Fin r → ℝ) × (Fin (n - r) → ℝ),
      Set.indicator {θ | l2norm (NT r n (θ - θs)) ≤ ϱ (diffOp r n θ)}
          (fun θ => H (diffOp r n θ)) (coordMap r n cu) =
        Set.indicator {c : Fin r → ℝ | l2norm (c - cbar r n θs cu.2) ≤ ϱ cu.2}
          (fun _ => H cu.2) cu.1 := by
    intro ⟨c, u⟩
    simp only [Set.indicator, Set.mem_ofPred_eq, (coordMap_bijective r n hr hn).2 (c, u),
      ← sub_cbar_eq r n hr hn θs c u]
  simp_rw [hcomp]
  have hprod_meas : Measurable (fun cu : (Fin r → ℝ) × (Fin (n - r) → ℝ) =>
      Set.indicator {c : Fin r → ℝ | l2norm (c - cbar r n θs cu.2) ≤ ϱ cu.2}
        (fun _ => H cu.2) cu.1) := by
    have : (fun cu : (Fin r → ℝ) × (Fin (n - r) → ℝ) =>
        Set.indicator {c : Fin r → ℝ | l2norm (c - cbar r n θs cu.2) ≤ ϱ cu.2}
          (fun _ => H cu.2) cu.1) =
        (Set.indicator {θ | l2norm (NT r n (θ - θs)) ≤ ϱ (diffOp r n θ)}
          (fun θ => H (diffOp r n θ))) ∘ coordMap r n := by
      ext cu; exact (hcomp cu).symm
    rw [this]
    exact hind_meas.comp hcoord_meas
  rw [lintegral_prod_symm _ hprod_meas.aemeasurable]
  have hinner : ∀ u : Fin (n - r) → ℝ,
      ∫⁻ c : Fin r → ℝ,
          Set.indicator {c : Fin r → ℝ | l2norm (c - cbar r n θs u) ≤ ϱ u}
            (fun _ => H u) c ∂volume =
        Vr r * (ENNReal.ofReal (ϱ u ^ r) * H u) := by
    intro u
    have hball_meas : MeasurableSet {c : Fin r → ℝ | l2norm (c - cbar r n θs u) ≤ ϱ u} :=
      measurableSet_le (hl2_meas.comp (measurable_id.sub measurable_const)) measurable_const
    rw [lintegral_indicator hball_meas, setLIntegral_const,
      volume_l2norm_closedBall r hr (cbar r n θs u) (ϱ u) (hϱ0 u)]
    ring
  simp_rw [hinner]
  exact lintegral_const_mul (Vr r)
    (f := fun u => ENNReal.ofReal (ϱ u ^ r) * H u)
    ((ENNReal.measurable_ofReal.comp (hϱ.pow_const r)).mul hH)

/-- Lemma `pf:lem:coord`(c), last claim: `ν{‖δ‖₂ ≤ ϱ} ≤ V_r ϱ^r` for every constant `ϱ ≥ 0`. -/
theorem nu_ball_le (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (lam : ℝ) (hlam : 0 < lam)
    (θs : Fin n → ℝ) (ϱ : ℝ) (hϱ : 0 ≤ ϱ) :
    nu r n lam {θ | l2norm (θ - θs) ≤ ϱ} ≤ Vr r * ENNReal.ofReal (ϱ ^ r) := by
  have : IsProbabilityMeasure (Qlam (n - r) lam) := Qlam_isProbabilityMeasure (n - r) lam hlam
  have hsub : {θ : Fin n → ℝ | l2norm (θ - θs) ≤ ϱ} ⊆
      {θ : Fin n → ℝ | l2norm (NT r n (θ - θs)) ≤ ϱ} := by
    intro θ hθ
    simp only [Set.mem_ofPred_eq] at hθ ⊢
    obtain ⟨⟨c, u⟩, rfl⟩ := (coordMap_bijective r n hr hn).1.2 θ
    have hle : l2sq (NT r n (coordMap r n (c, u) - θs)) ≤ l2sq (coordMap r n (c, u) - θs) := by
      rw [← sub_cbar_eq r n hr hn θs c u, pythagoras r n hr hn θs c u]
      have hnn : 0 ≤ l2sq (Pperp r n (Smul r n (u - ustar r n θs))) :=
        Finset.sum_nonneg fun _ _ => sq_nonneg _
      linarith
    exact (Real.sqrt_le_sqrt hle).trans hθ
  have hNT_meas : Measurable (NT r n) :=
    (NTLinear r n).continuous_of_finiteDimensional.measurable
  have hl2_meas : Measurable (l2norm (n := r)) := by
    unfold l2norm l2sq; fun_prop
  have hball_meas : MeasurableSet {θ : Fin n → ℝ | l2norm (NT r n (θ - θs)) ≤ ϱ} :=
    measurableSet_le (hl2_meas.comp (hNT_meas.comp (measurable_id.sub measurable_const)))
      measurable_const
  calc nu r n lam {θ | l2norm (θ - θs) ≤ ϱ}
      ≤ nu r n lam {θ | l2norm (NT r n (θ - θs)) ≤ ϱ} := measure_mono hsub
    _ = ∫⁻ θ, Set.indicator {θ | l2norm (NT r n (θ - θs)) ≤ ϱ} (fun _ => (1 : ℝ≥0∞)) θ
          ∂(nu r n lam) := (lintegral_indicator_one hball_meas).symm
    _ = Vr r * ∫⁻ _u, ENNReal.ofReal (ϱ ^ r) * 1 ∂(Qlam (n - r) lam) :=
        vol_formula r n hr hn lam hlam θs (fun _ => 1) measurable_const (fun _ => ϱ)
          measurable_const (fun _ => hϱ)
    _ = Vr r * ENNReal.ofReal (ϱ ^ r) := by
        simp [mul_one, lintegral_const]

end BQTF
