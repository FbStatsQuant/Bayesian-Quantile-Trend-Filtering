# The missing lemma (SUP): posterior sup-norm on the low-mode subspace

*Fable, research sub-agent for Theory, 2026-11-23, written under a hard stop. By hand; no compute. **Not audited.** Context: `FABLE_B_L4a.md` §3–4 (Lemma F2 and the measure on 𝒮), Lemma Lev of `FABLE_A_theoremH.md` (audited).*

**Labels.** PROVED = fully written here from elementary facts, audited statements, or named standard facts about one-dimensional log-concave laws. SKETCH = argument given, a step open. CONJECTURE = heuristic.

## 0. Verdict

**(SUP) is not proved.** What is proved is a reduction of the fluctuation part to one scalar statement, and exact identities that give an averaged version.

| # | Claim | Status |
|---|---|---|
| 1 | Fluctuation: ‖a − â‖∞ ≤ (1 + (C+1)·log n)·maxᵢσᵢ with posterior probability ≥ 1 − e·n^{−C} | PROVED (§2) |
| 2 | maxᵢσᵢ² ≤ lev(𝒮)·‖Cov_μ‖_op, and lev(𝒮) ≤ 9/h for the spline choice of 𝒮 | PROVED (§2) |
| 3 | **So the fluctuation part of (SUP) follows from (COV): ‖Cov_μ‖_op ≤ C/(ωf).** Then ‖a − â‖∞ ≲ log n·√(D/(n·ωf)) | PROVED reduction; (COV) open |
| 4 | Directional virial identity ω·E[(X − m)·S_v] = 1, and "slope ⇒ variance": if the marginal potential has slope c beyond scale t₀, then sd(X) ≤ t₀ + c^{−1/2} | PROVED (§3) |
| 5 | Trace virial identity ω·ΣᵢE[(aᵢ − âᵢ)1{aᵢ > zᵢ}] = D, and its consequence Σ_{i∈𝒜}σᵢ ≤ 4C₀·D/ω over the "active" coordinates | PROVED (§4) |
| 6 | Averaged version: tr Cov_μ ≲ D/(ωf), and at most a fraction C/K² of coordinates have σᵢ > K√(D/(nωf)) | SKETCH (§4): needs a leave-one-out stability step |
| 7 | Uniform-curvature arguments reproduce the n^{3/2} barrier; they cannot prove (COV) below it | PROVED computation (§5) |
| 8 | Posterior mean: exact estimating equation P_𝒮(E_μ1{z < a} − τ) = 0; sup-norm of â − (target) | identity PROVED; bound open (§6) |
| 9 | Alternative route: block localization from the order-3 Markov structure of the prior | SKETCH (§7) |

**In one sentence.** Log-concavity turns the sup-norm fluctuation into a question about the largest eigenvalue of the posterior covariance on 𝒮; the virial identities show that the covariance has the right size on average; the worst direction is what is still missing.

---

## 1. Setting

- 𝒮 ⊂ ℝⁿ: a subspace of dimension D containing range N. **Choose 𝒮 := the spline space V_H of Lemma F′** (knot spacing h, D ≤ n/h + 3). Lemma F2 of `FABLE_B_L4a.md` holds for any 𝒮 = range N ⊕ range P_Tᵀ with P_T orthonormal in (range N)^⊥, so this choice is allowed; it is made because its leverage is known: **lev(𝒮) := maxᵢ‖P_𝒮eᵢ‖₂² ≤ 9/h** (Lemma Lev, audited).
- Fix ω > 0 and an offset x ∈ ℝⁿ (the high-mode part). zᵢ := Zᵢ − xᵢ. U(a) := ω·ℛ(a + x) = ω·Σᵢ[ρ_τ(zᵢ − aᵢ) − ρ_τ(Zᵢ)] for a ∈ 𝒮.
- μ: the probability measure on 𝒮 with density ∝ e^{−U} with respect to Lebesgue measure on 𝒮.
  - U is convex and piecewise linear, and U(a) ≥ ωk‖a‖₁ − C(z): so μ is a proper log-concave measure with all moments. **There are no flat directions on 𝒮**: the three quadratic directions are part of 𝒮 and are pinned by the likelihood, with the same linear growth as any other direction.
  - ∇U(a) = ω·P_𝒮 s(a), s(a)ᵢ := 1{aᵢ > zᵢ} − τ (defined for a.e. a).
- â := E_μa, Σ_μ := Cov_μ(a), σᵢ² := Var_μ(aᵢ).

The same statements hold for the full fixed-(s, ℓ) posterior of θ on ℝⁿ (it is log-concave: convex check loss plus the convex penalty ℓ‖Dθ‖₁); only §2's leverage step is specific to 𝒮.

**Standard facts used** (one-dimensional log-concave density π with mean m, standard deviation σ):
- (LC1) P(|X − m| > tσ) ≤ e^{1−t} for t ≥ 1 (Lovász–Vempala, Lemma 5.7).
- (LC2) sup π ≤ 1/σ.
- (LC3) σ ≤ C₀·E|X − m| for an absolute constant C₀ (Borell's reverse Hölder inequality).
- Marginals and conditionals of log-concave measures are log-concave (Prékopa).

---

## 2. Fluctuation: reduction to the operator norm of the covariance — PROVED

**Lemma S1.** For every C > 0: μ(∃i : |aᵢ − âᵢ| > (1 + (C + 1)log n)·σᵢ) ≤ e·n^{−C}.

*Proof.* aᵢ = ⟨eᵢ, a⟩ is a linear functional of a log-concave vector, hence one-dimensional log-concave. Apply (LC1) with t = 1 + (C + 1)log n and a union bound over the n coordinates. ∎

**Lemma S2.** σᵢ² = (P_𝒮eᵢ)ᵀΣ_μ(P_𝒮eᵢ) ≤ lev(𝒮)·‖Σ_μ‖_op ≤ (9/h)·‖Σ_μ‖_op.

*Proof.* aᵢ = ⟨P_𝒮eᵢ, a⟩ for a ∈ 𝒮. ∎

**Corollary S3 (reduction).** If **(COV) ‖Σ_μ‖_op ≤ C_cov/(ωf)**, then with μ-probability ≥ 1 − e·n^{−C}:

  **‖a − â‖∞ ≤ (1 + (C + 1)log n)·3·√(C_cov/(h·ωf)) ≍ log n·√(D/(n·ωf)).**

This is (SUP) for the fluctuation, with log n in place of √(log n). It is small whenever D·(log n)² ≪ n, i.e. for every ℓ ≫ polylog(n). **The worst-case leverage bound d/√n has disappeared: it was the product of the leverage with the ℓ₂ radius √D, whereas a typical draw is governed by the leverage times the *directional* standard deviation.**

(COV) says: the posterior variance of every linear functional ⟨v, a⟩, v a unit vector of 𝒮, is at most a constant times the Gaussian-proxy value 1/(ωf).

---

## 3. Tools for (COV): directional virial identity and "slope ⇒ variance" — PROVED

Fix a unit vector v ∈ 𝒮, X := ⟨v, a⟩, m := E_μX, and let e^{−W_v} be the density of X (W_v convex by Prékopa). Put S_v(a) := Σᵢvᵢ·1{aᵢ > zᵢ}.

**Lemma S4.**
- (a) W_v′(x) = E_μ[∂_vU(a) | X = x] = ω·E_μ[S_v(a) | X = x] − ωτΣᵢvᵢ, for a.e. x, and W_v′ is nondecreasing.
- (b) **ω·E_μ[(X − m)·S_v(a)] = 1.**
- (c) Along v, S_v is nondecreasing: t ↦ S_v(a + tv) is nondecreasing for every a.

*Proof.* (a) Differentiate W_v(x) = −log∫e^{−U(xv + b)}db over the orthogonal complement of v in 𝒮; the integrand is Lipschitz in x and dominated. (b) Integration by parts in one dimension: E[(X − m)W_v′(X)] = 1 (the density decays exponentially), then (a) and E(X − m) = 0. (c) For vᵢ > 0 the indicator 1{aᵢ + tvᵢ > zᵢ} increases in t; for vᵢ < 0 it decreases and is multiplied by vᵢ < 0. ∎

**Lemma S5 (slope ⇒ variance).** Let X have density e^{−W}, W convex, mean m, standard deviation σ. Suppose that for some c > 0, t₀ ≥ 0 and a.e. x:

  (W′(x) − W′(m))·(x − m) ≥ c·|x − m|·(|x − m| − t₀).

Then **σ ≤ t₀ + c^{−1/2}.**

*Proof.* 1 = E[(X − m)W′(X)] = E[(X − m)(W′(X) − W′(m))] ≥ c·E|X − m|² − c·t₀·E|X − m| ≥ cσ² − ct₀σ. Solve the quadratic inequality. ∎

So (COV) holds if, for every unit v ∈ 𝒮, the **marginal** potential W_v has slope c ≍ ωf beyond a scale t₀ ≲ (ωf)^{−1/2}. In the Gaussian proxy W_v′(x) − W_v′(m) = ωf·(x − m)·(1 + o(1)), with t₀ = 0. What is needed is a realized version, with any constant c and any t₀ of the right order.

**Why the marginal potential and not U itself.** By Lemma S4(a) the slope of W_v is a conditional average of the directional slope of U. U itself has no curvature (it is piecewise linear), and its second differences at scale t,

  U(a + tv) + U(a − tv) − 2U(a) = ω·Σᵢ(t|vᵢ| − |zᵢ − aᵢ|)₊,

are sums over the few coordinates whose data point lies within t|vᵢ| of aᵢ. They have the right mean, ωf·t²(1 + o(1)), but controlling them uniformly in a is exactly what fails below n^{3/2} (§5). The averaging over the conditional law of a given X = x in Lemma S4(a) is what a proof must exploit.

---

## 4. The trace: exact identity and an averaged bound

**Lemma S6 (trace virial) — PROVED.** ω·Σᵢ E_μ[(aᵢ − âᵢ)·1{aᵢ > zᵢ}] = D.

*Proof.* On 𝒮 the vector field a ↦ a − â has divergence D, and e^{−U} decays exponentially, so ∫_𝒮⟨a − â, ∇U(a)⟩e^{−U}da = D·∫_𝒮e^{−U}da. Since a − â ∈ 𝒮, ⟨a − â, ∇U⟩ = ω⟨a − â, s(a)⟩, and E_μ[(aᵢ − âᵢ)τ] = 0. ∎

(This is the scaling identity (I3) of `FABLE_B_Arule_gauss.md`, restricted to 𝒮.)

**Lemma S7 — PROVED.** Let π be a one-dimensional log-concave density with mean m and standard deviation σ, and T(z) := ∫_z^∞(x − m)π(x)dx. Then T(z) ≥ 0 for all z, and **T(z) ≥ σ/(4C₀) whenever |z − m| ≤ σ/√(2C₀)**.

*Proof.* T(z) = E[(X − m)1{X > z}] = −E[(X − m)1{X ≤ z}] ≥ 0 (use the first form for z ≥ m, the second for z < m). T(m) = E(X − m)₊ = ½E|X − m| ≥ σ/(2C₀) by (LC3). T′(z) = −(z − m)π(z), so |T(z) − T(m)| ≤ (z − m)²·sup π/2 ≤ (z − m)²/(2σ) by (LC2). For |z − m| ≤ σ/√(2C₀) this is ≤ σ/(4C₀). ∎

**Corollary S8 — PROVED.** Let 𝒜 := {i : |zᵢ − âᵢ| ≤ σᵢ/√(2C₀)} (the coordinates whose data point lies within a fraction of a posterior standard deviation of the posterior mean). Then

  **Σ_{i∈𝒜}σᵢ ≤ 4C₀·D/ω.**

*Proof.* Lemma S6, with every term ≥ 0 and the terms i ∈ 𝒜 bounded below by Lemma S7 applied to the marginal of aᵢ. ∎

This holds for every data vector, every offset x and every subspace 𝒮, with no curvature assumption.

**Averaged consequence — SKETCH.** If, for a set B of coordinates with σᵢ ≥ σ̄, the number of i ∈ B with |zᵢ − âᵢ| ≤ σ̄/√(2C₀) is at least f₋·σ̄·|B|/√(2C₀) (the data fall near the posterior mean with at least the density f₋ > 0), then σ̄·f₋σ̄|B|/√(2C₀) ≤ 4C₀D/ω, i.e.

  **#{i : σᵢ ≥ σ̄} ≤ C·D/(ω·f₋·σ̄²).**

With σ̄ = K·√(D/(n·ωf₋)) at most a fraction C/K² of the coordinates have a larger posterior standard deviation, and summing over dyadic levels gives tr Σ_μ = Σσᵢ² ≲ (D/(ωf₋))·log n. This is the Gaussian-proxy size of the total variance.

*What is missing.* The hypothesis is a statement about zᵢ against the data-dependent centre âᵢ and scale σᵢ. It needs (i) ‖â − θ\*‖∞ ≤ L (a constant-level sup-norm bound for the posterior mean, far weaker than (SUP)), so that the noise density is ≥ f₋ at âᵢ − θ\*ᵢ, and (ii) a leave-one-out stability step: âᵢ and σᵢ must depend on Zᵢ weakly enough that Zᵢ cannot systematically avoid the window. I have not proved either.

**From the average to the maximum.** By Lemma S2 the maximum is controlled by ‖Σ_μ‖_op, not by tr Σ_μ. The averaged bound gives ‖Σ_μ‖_op ≤ tr Σ_μ ≲ D/(ωf), which returns the leverage bound d/√n. The trace is not enough; the largest eigenvalue is needed.

---

## 5. Why uniform curvature cannot do it — PROVED computation

Suppose one tries to prove (COV) by showing that U is strongly convex at scale t uniformly over the bulk {‖a − â‖₂² ≲ D/(ωf)} and over unit v ∈ 𝒮, i.e. Σᵢ(t|vᵢ| − |zᵢ − aᵢ|)₊ ≥ (f/2)t² for all such (a, v).

- The sum has mean ≈ f·t² and involves ≈ 2f·t‖v‖₁ active coordinates, each contributing at most t‖v‖∞ ≤ t·√(lev) ≈ t√(D/n).
- Its fluctuation, uniformly over a D-dimensional family of centres a, is of order t^{3/2}·√(Df)·(D/n)^{1/4} (active-set contraction as in Lemma 1 of the three-lemmas note, with the multiplier variance p ≈ f·t·‖v‖∞).
- Relative to the mean this is t^{−1/2}·D^{3/4}·n^{−1/4}: small only for t ≫ D^{3/2}/√n.

So uniform strong convexity holds only at scales t₀ ≳ D^{3/2}/√n. Through Lemmas S5, S2 and S1 this gives ‖a − â‖∞ ≲ log n·√(D/n)·max(1, D^{3/2}/√n), which tends to 0 only for D ≪ √n: **the same n^{3/2} barrier**. The uniform route is not merely unproved below the barrier; it is the barrier. Any proof of (COV) for D ≥ √n must use the averaging in Lemma S4(a), or the trace identity of §4, rather than a supremum over a.

---

## 6. The posterior mean — identity PROVED, bound open

**Estimating equation.** E_μ∇U = 0 gives **P_𝒮·ĝ = 0, ĝᵢ := μ(aᵢ > zᵢ) − τ.** The posterior-averaged "residual sign" vector is orthogonal to 𝒮. This is the Bayesian counterpart of the quantile-regression normal equations (where ĝ is the vector of residual signs at the point estimate).

**What it should give — SKETCH.** If μ(aᵢ > zᵢ) is replaced by its smooth population counterpart Fᵢ-type function of âᵢ − (target)ᵢ, the equation becomes P_𝒮·[f·(â − θ_𝒮) − ψ] ≈ 0, i.e. â − θ_𝒮 ≈ f⁻¹P_𝒮ψ, whose coordinates are ⟨P_𝒮eᵢ, ψ⟩/f: sub-Gaussian with variance ≤ t·lev(𝒮)/f², hence **‖â − θ_𝒮‖∞ ≲ √(log n·D/n)/f** by Hoeffding and a union bound. Making the replacement rigorous needs the same local information as (COV): that each marginal of aᵢ is concentrated at scale σᵢ ≪ 1 around âᵢ, so that μ(aᵢ > zᵢ) is a smoothed indicator of zᵢ < âᵢ at that scale. So the mean and the fluctuation are coupled; a bootstrap is the natural structure (constant-level sup-norm → averaged variance (§4) → …), but the step from the average to the maximum is missing in each round.

---

## 7. An alternative route: block localization — SKETCH

The prior on θ (third differences i.i.d. Laplace) is a Markov random field of order 3, and the likelihood is a product over coordinates. Hence, for the full fixed-(s, ℓ) posterior: conditionally on two boundary triples (θ_{a−3}, θ_{a−2}, θ_{a−1}) and (θ_{b+1}, θ_{b+2}, θ_{b+3}), the block (θ_a, …, θ_b) is independent of everything outside it, and its conditional law depends only on the data in the block.

So a sup-norm bound follows from a **block statement**: for a block of length L_b = C·h (h ≍ ℓ^{1/3} the bandwidth) and **every** boundary condition, the conditional posterior of the middle coordinate is within C√(log n/h) of the truth with conditional probability ≥ 1 − n^{−C}.
- Heuristic: a wrong boundary value at distance Δ costs prior mass e^{−c·ℓ·Δ/g²} to correct over a transition of length g, against a likelihood gain ≈ ω·Δ·(L_b − g); the correction pays as soon as g ≳ (ℓ/ω)^{1/3} ≍ h. So the middle of a block of length C·h forgets its boundary.
- A proof would be a local version of L6 and L3 with pinned boundary values, in dimension L_b ≍ h rather than n. The block has only O(h) coordinates, so the union and entropy costs are of order h·log n, which is what the target √(log n/h) allows.
- This route avoids (COV) and the low-mode subspace altogether, and it would serve Fable A's truncation route directly, since it is a statement about the full posterior. It is not started.

---

## 8. Flags

- **Nothing here closes L4a or L4b.** The proved content is the reduction (Corollary S3) and the identities.
- Lemmas S1–S8 are new and short; they are unaudited. The constants in (LC1)–(LC3) are quoted from memory of the standard literature; only their existence as absolute constants matters here.
- The choice 𝒮 = spline space changes Lemma F2's prior factor S(V) (the low modes are then spline coefficients, not eigen-modes); `FABLE_B_L4a.md` §3 holds for it, but the Gaussian-prior decoupling stated there used eigenvectors and would have to be redone with P_𝒮. I have not done this.
- §5's fluctuation order is a scaling computation, not a written proof.
- **Suggested diagnostic (UNTESTED):** from saved fixed-λ draws at mid ℓ, the largest eigenvalue of the posterior covariance of the spline coefficients (in an orthonormal basis of 𝒮), compared with 1/(ωf). (COV) predicts a bounded ratio as n grows. This is a direct numerical test of the one missing statement.

---

## Theory response (2026-11-23)

**Status: the posterior sup-norm lemma is OPEN. The note is UNAUDITED.**

**Reduction (PROVED, unaudited).** The fluctuation part reduces to one scalar statement: ‖Cov_post|𝒮‖_op ≤ C/(ωf) on the spline subspace. The route is log-concave coordinate tails, a union bound, and the (9/h) evaluation bound.

**Exact tools:**
- the directional virial identity;
- the slope ⇒ variance lemma;
- the trace virial bound, which holds for every data vector.

**Negative finding (scaling only, not written as a proof).** Uniform strong convexity reproduces exactly the n^{3/2} barrier. A proof below n^{3/2} must therefore use conditional averaging, not a supremum over the bulk.

**For the plan.** The Tuesday target for L4a/L4b becomes the operator-norm statement or the block-localization route.

**Diagnostic (UNTESTED, internal).** The largest posterior-covariance eigenvalue of the spline coefficients, from saved mid-ℓ draws, compared against 1/(ωf). It could ride on the L4a draws check already proposed for Tuesday.
