# Neon-A Questions and Classical-Input Audit

Date: 2026-11-25

## 1. Confirmation on candidate paper correction C-04 (`Interp.lean`)

**Confirmed.** In `BQTF/Interp.lean` (`window_poly_approx`), the case `w = r` (which occurs when `⌈n x*⌉ = r`) genuinely cannot invoke `Coord.coordMap_bijective` because `Coord` requires `r < w`. We handled `w = r` separately: `monomial_linearIndependent r r (le_refl r)` gives `Module.finrank ℝ (polySpace r r) = r = Module.finrank ℝ (Fin r → ℝ)`, so `polySpace r r = ⊤`, hence `δ_W ∈ polySpace r r` itself with approximation error `0 ≤ ϱ_w`.

No other gaps or wrong constants appeared in `Falling`, `Coord`, `Gram`, `SplineApprox`, `Smooth`, or `Interp`.

---

## 2. Classical inputs audit before proving `SmallBall.lean` (Lemma `pf:lem:sb`)

The paper's proof of Lemma `pf:lem:sb` (`paper/sections/appendix_theory.tex:141-148`) uses four classical facts. We checked the pinned Mathlib (`v4.35.0-rc2` / `065356127b`) for each:

### (a) Rotation / orthonormal-basis invariance of the standard multivariate Gaussian
- **Exact statement needed:** For a finite-dimensional real inner product space `E` and any orthonormal basis `b : OrthonormalBasis (Fin m) ℝ E`, pushing forward the i.i.d. `N(0, 1)` product measure `Measure.pi (fun _ : Fin m => gaussianReal 0 1)` by `x ↦ ∑ q, x q • b q` equals `stdGaussian E`; in particular, for any linear map `G : EuclideanSpace ℝ (Fin m) →ₗ[ℝ] EuclideanSpace ℝ (Fin n)`, choosing `b` to be the orthonormal eigenbasis of `G.adjoint ∘ₗ G` gives that the law of `‖G g‖²` under `g ~ Measure.pi (fun _ => gaussianReal 0 1)` equals the law of `∑ q, (G.singularValues q)² * γ_q²` under `γ ~ Measure.pi (fun _ => gaussianReal 0 1)`.
- **Mathlib status:** **ALREADY IN MATHLIB.** `Mathlib/Probability/Distributions/Gaussian/Multivariate.lean` provides:
  - `stdGaussian_map` (invariance under any `LinearIsometryEquiv`),
  - `map_pi_eq_stdGaussian`,
  - `stdGaussian_eq_map_pi_orthonormalBasis`.
- **Estimated effort to wire up:** ~0.1 day (~30–50 lines of glue).

### (b) Eckart–Young / Ky Fan Frobenius tail bound
- **Exact statement needed:** Let `E = EuclideanSpace ℝ (Fin m)`, `F = EuclideanSpace ℝ (Fin n)`, `G : E →ₗ[ℝ] F`, `T : E →ₗ[ℝ] F`, and `J : ℕ` with `Module.finrank ℝ (LinearMap.range T) ≤ J`. Then
  $$\sum_{q = J}^{m - 1} \sigma_q(G)^2 \le \sum_{j : \mathrm{Fin}\, m} \|(G - T)(e_j)\|^2$$
  where `σ_q(G) = G.singularValues q` and `e_j = EuclideanSpace.basisFun (Fin m) ℝ j`.
- **Mathlib status:** **Missing**, though `LinearMap.singularValues`, `LinearMap.sq_singularValues_fin`, `LinearMap.singularValues_antitone`, and `LinearMap.IsSymmetric.eigenvectorBasis` / `eigenvalues_antitone` exist in `Mathlib/Analysis/InnerProductSpace/SingularValues.lean` and `Spectrum.lean`.
- **Elementary direct proof (no Courant–Fischer / min-max needed):**
  1. Set `W = LinearMap.ker T`, so `d := finrank W ≥ m - J`. Pick an orthonormal basis `w_0, …, w_{d-1}` of `W` and extend it to an orthonormal basis of `E`. Since Frobenius norm is basis-independent and `(G - T) w = G w` on `W`, `‖G - T‖_F² ≥ ∑_{i<d} ‖G w_i‖² = ∑_{i<d} ⟪w_i, (G† G) w_i⟫`.
  2. Expand in the orthonormal eigenbasis `u_0, …, u_{m-1}` of `G† G` with eigenvalues `μ_0 ≥ ⋯ ≥ μ_{m-1} ≥ 0`: `∑_{i<d} ⟪w_i, (G† G) w_i⟫ = ∑_q μ_q c_q`, where `c_q = ∑_{i<d} ⟪w_i, u_q⟫² ∈ [0, 1]` and `∑_q c_q = d ≥ m - J`.
  3. By monotonicity of `μ_q`: for `J < m`, `∑_{q<m} μ_q c_q - ∑_{q≥J} μ_q = ∑_{q<J} μ_q c_q - ∑_{q≥J} μ_q (1 - c_q) ≥ μ_J (∑_{q<m} c_q - (m - J)) = μ_J (d - (m - J)) ≥ 0`.
- **Estimated effort to prove in `BQTF/Lin/`:** **~0.25 day** (~80–120 lines).

### (c) Andrews–Mallows Gaussian scale mixture for the Laplace law
- **Exact statement needed:** For `λ > 0`, if `V ~ expMeasure (λ² / 2)` (density `(λ² / 2) e^{-λ² v / 2}` on `v > 0`, mean `2 / λ²`) and `g ~ gaussianReal 0 1` are independent, then the pushforward of `(expMeasure (λ² / 2)).prod (gaussianReal 0 1)` by `(v, g) ↦ √v * g` equals `laplace λ` (and hence the `m`-fold product pushforward `(v, g) ↦ (fun j => √(v j) * g j)` equals `Qlam m λ`).
- **Mathlib status:** **Missing**, though `expMeasure`, `gaussianReal`, `charFun_gaussianReal`, `integral_exp_mul_complex_Ioi`, and `Measure.ext_of_charFun` all exist in Mathlib.
- **Short proof via characteristic functions:** Compute `charFun (laplace λ) t = λ² / (λ² + t²)` via `integral_exp_mul_complex_Ioi`/`Iic`, and compute `charFun (map (√v * g) (expMeasure (λ²/2) × gaussianReal 0 1)) t = ∫_{v>0} exp(-t² v / 2) d(expMeasure (λ²/2)) = λ² / (λ² + t²)` via Fubini + `charFun_gaussianReal`, then conclude by `Measure.ext_of_charFun`.
- **Estimated effort to prove in `BQTF/Lin/`:** **~0.25 day** (~60–100 lines).

### (d) 1D Gaussian small-ball lower bound
- **Exact statement needed:** For `t ≥ 0`, `gaussianReal 0 1 {x | |x| ≤ t} ≥ ENNReal.ofReal (0.48 * min t 1)`.
- **Mathlib status:** Missing as a packaged lemma, but `gaussianReal_apply_eq_integral`, `gaussianPDFReal`, `Real.pi_lt_d4`, and `Real.exp_one_lt_d9` exist.
- **Proof:** On `[-m, m]` (`m = min t 1`), the density is `≥ (2π)^{-1/2} e^{-1/2}`, giving `≥ √(2 / (π e)) · m ≥ 0.48 · m` since `π e < 3.15 * 2.72 = 8.568 < 2 / 0.48² = 8.6805...`.
- **Estimated effort:** **~0.1 day** (~30–40 lines).

### Recommendation / Decision Request
All four inputs are either already in Mathlib (a) or have short, self-contained proofs totaling **~200–300 lines (~0.5–1 day)** — well below the 300-line-per-result threshold and without needing any temporary hypothesis on `small_ball`. Stopping on `SmallBall.lean` as instructed; ready to prove (b), (c), (d) directly in `BQTF/Lin/` and discharge `SmallBall.lean` sorry-free once you give the go-ahead.
