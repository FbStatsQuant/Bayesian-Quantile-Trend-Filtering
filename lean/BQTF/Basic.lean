import BQTF.Spec

/-!
# BQTF: core objects of the proof (appendix `app:proofs`)

Shared definitions used by every proof module. Nothing here is a statement of the paper; the
statements are in `Spec.lean`. Notation follows the appendix with `r = k + 1` and `m = n − r`.
Indices are 0-based: the paper's column `j ∈ {1,…,m}` is `j − 1` here and its row `i ∈ {1,…,n}`
is `i − 1`; formulas that depend only on `i − j` (such as `s_j(i)`) are unchanged.

Conventions:
* vectors are `Fin n → ℝ`; ℓ¹/ℓ² quantities are explicit sums (`l2sq`, `l2norm`, `empNorm`,
  `dot`); Mathlib's `‖·‖` on `Fin n → ℝ` is the sup norm `‖·‖_∞`;
* orthogonal projections are taken in `EuclideanSpace ℝ (Fin n)` and transported (`orthProj`);
* events on the data are sets of `y : Fin n → ℝ`; the data law is `Measure.pi μ`.
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal NNReal

noncomputable section

namespace BQTF

/-! ## ℓ² geometry on `Fin n → ℝ` -/

/-- `‖v‖₂² = ∑ v_i²`. -/
def l2sq {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- `‖v‖₂`. -/
def l2norm {n : ℕ} (v : Fin n → ℝ) : ℝ := Real.sqrt (l2sq v)

/-- The empirical norm `‖v‖_n = n^{−1/2} ‖v‖₂` (appendix, "Outline"). -/
def empNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := Real.sqrt (l2sq v / n)

/-- `⟨u, v⟩ = ∑ u_i v_i`. -/
def dot {n : ℕ} (u v : Fin n → ℝ) : ℝ := ∑ i, u i * v i

/-- The identification `ℝⁿ ≃ EuclideanSpace ℝ (Fin n)` (same vector, ℓ² structure). -/
def toE (n : ℕ) : (Fin n → ℝ) ≃ₗ[ℝ] EuclideanSpace ℝ (Fin n) :=
  (WithLp.linearEquiv 2 ℝ (Fin n → ℝ)).symm

/-- The orthogonal projector onto a subspace `V ⊆ ℝⁿ` for the dot product. -/
def orthProj {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ) :=
  (toE n).symm.toLinearMap ∘ₗ ((V.map (toE n).toLinearMap).starProjection).toLinearMap ∘ₗ
    (toE n).toLinearMap

/-! ## Falling factorials and the matrix `S` (appendix, "Coordinates and the check loss") -/

/-- `b_p(t) = C(t, p) 1{t ≥ 0}` for integers `t` (paper: `b_p(t) = binom(t,p) 1(t ≥ 0)`). -/
def bfun (p : ℕ) (t : ℤ) : ℝ := if 0 ≤ t then ((t.toNat.choose p : ℕ) : ℝ) else 0

/-- Column `j` of `S` (0-based `j`): `s_j(i) = b_{r−1}(i − j − 1)`. -/
def sCol (r n : ℕ) (j : ℕ) : Fin n → ℝ := fun i => bfun (r - 1) ((i : ℤ) - j - 1)

/-- `S u = ∑_j u_j s_j`, `S ∈ ℝ^{n×m}`, `m = n − r`. -/
def Smul (r n : ℕ) (u : Fin (n - r) → ℝ) : Fin n → ℝ := fun i => ∑ j, u j * sCol r n j i

/-- `𝒫`: the vectors `(p(i))_{i}` with `p` a polynomial of degree at most `r − 1`. -/
def polySpace (r n : ℕ) : Submodule ℝ (Fin n → ℝ) :=
  Submodule.span ℝ (Set.range fun p : Fin r => fun i : Fin n => (i : ℝ) ^ (p : ℕ))

/-- `P`, the orthogonal projector onto `𝒫`. -/
def Pproj (r n : ℕ) : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ) := orthProj (polySpace r n)

/-- `P^⊥ = I − P`. -/
def Pperp (r n : ℕ) : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ) := LinearMap.id - Pproj r n

/-- The monomial vectors `(i^p)_i`, `p = 0, …, r−1`. -/
def monomial (r n : ℕ) (p : Fin r) : Fin n → ℝ := fun i => (i : ℝ) ^ (p : ℕ)

/-- An orthonormal basis `N = (N_0, …, N_{r−1})` of `𝒫`: Gram–Schmidt of the monomials (for
`n ≥ r` the monomials are linearly independent, so this is orthonormal; that is a lemma). -/
def Ncol (r n : ℕ) (p : Fin r) : Fin n → ℝ :=
  (toE n).symm (InnerProductSpace.gramSchmidtNormed ℝ (fun q => toE n (monomial r n q)) p)

/-- `N c = ∑_p c_p N_p`. -/
def Nmul (r n : ℕ) (c : Fin r → ℝ) : Fin n → ℝ := fun i => ∑ p, c p * Ncol r n p i

/-- `Nᵀ v = (⟨N_p, v⟩)_p`. -/
def NT (r n : ℕ) (v : Fin n → ℝ) : Fin r → ℝ := fun p => dot (Ncol r n p) v

/-- The coordinate map `(c, u) ↦ N c + S u` (Lemma `pf:lem:coord`(b)). -/
def coordMap (r n : ℕ) (cu : (Fin r → ℝ) × (Fin (n - r) → ℝ)) : Fin n → ℝ :=
  Nmul r n cu.1 + Smul r n cu.2

/-! ## The prior in coordinates -/

/-- Laplace density `(λ/2) e^{−λ|x|}`. -/
def laplacePDF (lam x : ℝ) : ℝ := lam / 2 * Real.exp (-(lam * |x|))

/-- The Laplace(λ) law on `ℝ`. -/
def laplace (lam : ℝ) : Measure ℝ := volume.withDensity fun x => ENNReal.ofReal (laplacePDF lam x)

/-- `Q_λ`: the law on `ℝ^m` of `m` independent Laplace(λ) variables. -/
def Qlam (m : ℕ) (lam : ℝ) : Measure (Fin m → ℝ) := Measure.pi fun _ => laplace lam

/-- `ν`: the image of `Leb_r ⊗ Q_λ` under `(c, u) ↦ N c + S u` (Lemma `pf:lem:coord`(b)). -/
def nu (r n : ℕ) (lam : ℝ) : Measure (Fin n → ℝ) :=
  (volume.prod (Qlam (n - r) lam)).map (coordMap r n)

/-- `V_r`, the volume of the unit ball of `ℝ^r`. -/
def Vr (r : ℕ) : ℝ≥0∞ := volume (Metric.ball (0 : EuclideanSpace ℝ (Fin r)) 1)

/-! ## Check loss along the data -/

/-- `L̂(δ) = ∑_i {ρ_τ(Z_i − δ_i) − ρ_τ(Z_i)}` with `Z = y − θ*` (appendix, "Outline"). -/
def lossHat {n : ℕ} (τ : ℝ) (Z δ : Fin n → ℝ) : ℝ :=
  ∑ i, (checkLoss τ (Z i - δ i) - checkLoss τ (Z i))

/-- `N(B) = ∫_B e^{−L̂(θ − θ*)} dν(θ)` (eq. `pf:eq:ratio`), at data `y`. -/
def Nmass {n : ℕ} (r : ℕ) (τ lam : ℝ) (y θs : Fin n → ℝ) (B : Set (Fin n → ℝ)) : ℝ≥0∞ :=
  ∫⁻ θ in B, ENNReal.ofReal (Real.exp (-lossHat τ (y - θs) (θ - θs))) ∂(nu r n lam)

/-- The score `ζ_i = τ − 1{Z_i < 0}`. -/
def score {n : ℕ} (τ : ℝ) (Z : Fin n → ℝ) : Fin n → ℝ := fun i => τ - if Z i < 0 then 1 else 0

/-- `L(δ) = E L̂(δ)` under the data law (`Z_i = y_i − θ*_i`). -/
def lossExp {n : ℕ} (τ : ℝ) (μ : Fin n → Measure ℝ) (θs δ : Fin n → ℝ) : ℝ :=
  ∫ y, lossHat τ (y - θs) δ ∂(Measure.pi μ)

/-! ## Rates (appendix, "Outline" and before Proposition `pf:prop:local`) -/

/-- `ε_n² = n^{−(2r−1)/(2r)}`. -/
def epsSq (r n : ℕ) : ℝ := (n : ℝ) ^ (-((2 * r - 1 : ℝ) / (2 * r)))

/-- `ρ_n² = n^{−(2r−1)/(2r+1)} log n`. -/
def rhoSq (r n : ℕ) : ℝ := (n : ℝ) ^ (-((2 * r - 1 : ℝ) / (2 * r + 1))) * Real.log n

/-- `T_n = 4 n^r / λ` (with `λ = c n^{r−1/2}` this is `(4/c) √n`). -/
def Tn (r n : ℕ) (lam : ℝ) : ℝ := 4 * (n : ℝ) ^ r / lam

/-- `TV^{(r)}(δ) = n^{r−1} ‖D^{(r)} δ‖₁`; equal to `TV (r−1)` of `Spec` for `r ≥ 1`. -/
def TVr (r n : ℕ) (δ : Fin n → ℝ) : ℝ := (n : ℝ) ^ (r - 1) * l1norm (diffOp r n δ)

/-- `K(ρ, T) = {δ : ‖δ‖_n ≤ ρ, TV^{(r)}(δ) ≤ T}` (before Lemma `pf:lem:width`). -/
def Kset (r n : ℕ) (ρ T : ℝ) : Set (Fin n → ℝ) := {δ | empNorm δ ≤ ρ ∧ TVr r n δ ≤ T}

/-! ## Spline spaces (appendix, "Spline approximation") -/

/-- `h = ⌈m/J⌉`. -/
def hJ (m J : ℕ) : ℕ := (m + J - 1) / J

/-- `J' = ⌊m/h⌋`. -/
def J' (m J : ℕ) : ℕ := m / hJ m J

/-- `V_J = 𝒫 + span{s_{lh} : l = 1, …, J'}` (paper's 1-based column `lh` is 0-based `lh − 1`). -/
def VJ (r n J : ℕ) : Submodule ℝ (Fin n → ℝ) :=
  polySpace r n ⊔ Submodule.span ℝ
    (Set.range fun l : Fin (J' (n - r) J) => sCol r n ((l.val + 1) * hJ (n - r) J - 1))

/-- `P_J`, the orthogonal projector onto `V_J`. -/
def PJ (r n J : ℕ) : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ) := orthProj (VJ r n J)

/-! ## Rademacher signs -/

/-- The Rademacher law on `{−1, 1}`. -/
def rademacher1 : Measure ℝ := (1 / 2 : ℝ≥0∞) • (Measure.dirac (-1) + Measure.dirac 1)

/-- `n` independent Rademacher signs. -/
def rademacher (n : ℕ) : Measure (Fin n → ℝ) := Measure.pi fun _ => rademacher1

end BQTF
