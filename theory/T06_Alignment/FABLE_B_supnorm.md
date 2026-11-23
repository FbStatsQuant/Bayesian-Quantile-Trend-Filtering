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

---

## 9. Route (a) pursued: the covariance statement

*Appended 2026-11-23, about 16:20 CT, same author. Not audited. I chose route (a) because its first steps are exact identities that could be written and checked in the time; route (b) needs a multi-scale forgetting argument for which I have only heuristics (§7). Route (a) does not close either. The precise stopping point is §9.5.*

### 9.0 Outcome

| # | Claim | Status |
|---|---|---|
| 1 | Matrix virial identity: ω·C·P_𝒮 + γ·Σ = P_𝒮 on 𝒮, with C_{kj} = E[(a_k − â_k)1{a_j > z_j}] | PROVED (§9.1) |
| 2 | Each entry C_{kj} = R_{kj}(z_j) is the value **at the data point z_j** of a function R_{kj} with ∫R_{kj}(z)dz = Σ_{kj} exactly | PROVED (§9.2) |
| 3 | Hence, if the data points sampled these functions as a locally flat density f would, Σ = (ωf + γ)^{−1}P_𝒮: the Gaussian-proxy covariance comes out of an identity, with no quadratic expansion of the check loss | PROVED as a conditional statement (§9.2) |
| 4 | One-site stability: removing one observation changes the posterior by at most C·ω·σᵢ in total variation | PROVED (§9.3) |
| 5 | Under linear regressions (LR): Σ^{−1} = ω·P_𝒮·diag(κ_j(z_j))·P_𝒮 + γ·P_𝒮, with κ_j an explicit probability density of width σ_j, κ_j(z_j) ≥ 1{j ∈ 𝒜}/(4C₀σ_j) | PROVED (§9.4) |
| 6 | (COV) follows from (LR-approx) + (ACT) | PROVED implication (§9.4); both hypotheses open |
| 7 | (ACT) has no n^{3/2} barrier in a matrix-Chernoff heuristic: it needs only D ≪ n/log²n | CONJECTURE (§9.4) |
| 8 | **Stopping point:** the non-linearity of the regressions of a global functional on a single coordinate (§9.5) | open |

### 9.1 Matrix virial identity — PROVED

Add a Gaussian confinement (it is needed for the bootstrap of §9.6 and costs nothing): for γ ≥ 0 and c ∈ 𝒮 let μ_γ ∝ exp{−U(a) − (γ/2)‖a − c‖²} on 𝒮, with mean â, covariance Σ (as an operator on 𝒮), marginals π_j of a_j with standard deviations σ_j. For γ > 0, Σ ⪯ γ^{−1}P_𝒮 for **every** data vector (Brascamp–Lieb: the potential is γ-strongly convex).

**Lemma S9.** Let C be the n×n matrix C_{kj} := E_{μ_γ}[(a_k − â_k)·1{a_j > z_j}]. Then, as operators on 𝒮:

  **ω·C·P_𝒮 + γ·Σ = P_𝒮.**

*Proof.* In an orthonormal basis of 𝒮, integration by parts gives E[(a − â)·∇U_γ(a)ᵀ] = I_D (the density is Lipschitz and decays exponentially). ∇U_γ(a) = ω·P_𝒮s(a) + γ(a − c), s(a)_j = 1{a_j > z_j} − τ. The constant −τ and the centre c drop because E(a − â) = 0. ∎

Lemmas S4(b) and S6 are the quadratic-form and trace versions of this identity at γ = 0.

### 9.2 Each entry is a point evaluation of a function with known integral — PROVED

For k, j let **R_{kj}(z) := E_{μ_γ}[(a_k − â_k)·1{a_j > z}]**, z ∈ ℝ. Then C_{kj} = R_{kj}(z_j).

**Lemma S10.** R_{kj} is continuous, tends to 0 at ±∞ exponentially fast at the scale σ_j, and

  **∫_ℝ R_{kj}(z)dz = Σ_{kj} = Cov(a_k, a_j).**

*Proof.* 1{a_j > z} − 1{â_j > z} integrates over z ∈ ℝ to a_j − â_j, and E[(a_k − â_k)·1{â_j > z}] = 0. By Fubini (the tails of a_j are exponential, (LC1)): ∫R_{kj}(z)dz = E[(a_k − â_k)(a_j − â_j)]. For the decay: |R_{kj}(z)| ≤ σ_k·min(μ(a_j > z), μ(a_j ≤ z))^{1/2}. ∎

**Reading.** Put Lemma S10 into Lemma S9. The matrix C is obtained by evaluating, in column j, the functions R_{·j} at the single data point z_j. If z_j were replaced by an independent draw from a density that is flat, equal to f, on the window â_j ± σ_j·log n where R_{·j} lives, the expectation of column j would be f·Σ_{·j}, and Lemma S9 would read (ωf + γ)·Σ = P_𝒮. So:

  **(COV) is equivalent to an equidistribution statement:** the data points z_j sample the functions R_{kj} well enough that P_𝒮(C − f·Σ)P_𝒮 is small against f·Σ, in the sense of quadratic forms on 𝒮.

No expansion of the check loss, and no curvature, appears. The density f of the noise enters only as the sampling density of z_j at the posterior scale σ_j. This is why σ_j ≪ (noise scale) is the natural requirement, not ‖a‖∞ → 0 uniformly over a body.

### 9.3 One-site stability — PROVED

**Lemma S11.** Let μ be a probability measure on 𝒮 under which a_i is one-dimensional log-concave with standard deviation σ_i, and let dμ′/dμ ∝ e^{φ(a_i)} with φ ω-Lipschitz. If ωσ_i ≤ ½, then **‖μ′ − μ‖_TV ≤ C·ω·σ_i**, C absolute.

*Proof.* dμ′/dμ = e^{ϕ}/E_μe^{ϕ} with ϕ := φ(a_i) − φ(â_i), |ϕ| ≤ ω|a_i − â_i|. By (LC1), E_μe^{ω|a_i − â_i|} ≤ 1 + C′ωσ_i for ωσ_i ≤ ½. So E_μ|e^{ϕ} − 1| ≤ E_μ[e^{ω|a_i−â_i|} − 1] ≤ C′ωσ_i and |E_μe^{ϕ} − 1| ≤ C′ωσ_i, which bounds E_μ|dμ′/dμ − 1| by 4C′ωσ_i. ∎

*Use.* The posterior μ and the leave-one-out posterior μ^{(−i)} (the factor e^{−ωρ_τ(z_i − a_i)} removed) differ by such a tilt. So a single observation moves the posterior by O(ω·σ_i) in total variation, and μ^{(−i)} is independent of Z_i. This is the tool for the leave-one-out step that §4 and §9.4 need. It requires the a priori smallness ωσ_i ≪ 1 (posterior s.d. of a coordinate much below the noise scale), which is why a bootstrap is needed (§9.6).

### 9.4 The linear-regression form — PROVED implication

For j let T_j(z) := ∫_z^∞(t − â_j)π_j(t)dt (Lemma S7) and

  **κ_j(z) := T_j(z)/σ_j².**

κ_j ≥ 0 and ∫κ_j = 1 (Lemma S10 with k = j): κ_j is a probability density, unimodal with mode at â_j, of width σ_j; for a Gaussian marginal κ_j = π_j. By Lemma S7, **κ_j(z_j) ≥ 1{j ∈ 𝒜}/(4C₀σ_j)**, 𝒜 the active set of Corollary S8.

**(LR)** For all k, j: E[a_k − â_k | a_j = t] = (Σ_{kj}/σ_j²)·(t − â_j). (True for Gaussian measures.)

**Lemma S12.** Under (LR): C = Σ·diag(κ_j(z_j)), and therefore

  **Σ^{−1} = ω·P_𝒮·diag(κ_j(z_j))·P_𝒮 + γ·P_𝒮  on 𝒮.**

*Proof.* R_{kj}(z) = ∫_z^∞E[a_k − â_k | a_j = t]π_j(t)dt = Σ_{kj}κ_j(z). Insert in Lemma S9 and multiply by Σ^{−1}. ∎

So under (LR) the posterior precision on 𝒮 is the compression to 𝒮 of a **diagonal** matrix whose entries are the smoothed "densities of the posterior at the data points". (COV) is then the statement

  **(ACT)** Σ_j v_j²·κ_j(z_j) ≥ c·f for every unit v ∈ 𝒮,

and it is implied by Σ_{j∈𝒜}v_j²/σ_j ≥ 4C₀c·f.

**Why (ACT) is plausible with no n^{3/2} barrier — CONJECTURE.** If the z_j were independent of (â_j, σ_j) with density ≥ f₋ near â_j, the matrices κ_j(z_j)·P_𝒮e_je_jᵀP_𝒮 would be independent, positive semidefinite, with mean ⪰ f₋·P_𝒮e_je_jᵀP_𝒮 (summing to f₋P_𝒮) and norm ≤ lev(𝒮)/σ_j. A matrix Chernoff bound then gives λ_min ≥ f₋/2 as soon as lev(𝒮)/σ_min ≤ c·f₋/log D, i.e. (with σ ≍ √(D/(nωf))) **D ≪ n·f/(ω·log²D)**. The condition is on D/n, not on D²/n: the diagonal structure replaces the uniform-in-a supremum of §5 by a sum of independent rank-one terms.

### 9.5 Where it stops

1. **(LR) is false in general for log-concave measures**, and I could not bound the remainder. Write C = Σ·diag(κ_j(z_j)) + 𝔈, 𝔈_{kj} := ∫_{z_j}^∞[E(a_k − â_k | a_j = t) − (Σ_{kj}/σ_j²)(t − â_j)]π_j(t)dt. One needs ‖P_𝒮·𝔈·P_𝒮‖_op ≪ f·‖Σ‖_op. For a unit v ∈ 𝒮 and X = ⟨v, a⟩ the relevant quantity is the non-linear part of the regression of the **global** functional X on the **single** coordinate a_j. These two have correlation of order D^{−1/2}, and the linear part is correspondingly small. Cauchy–Schwarz ignores this and bounds the non-linear part by the full standard deviation of X, which makes the remainder larger than the main term by a factor of order √D. So the missing estimate is: **the regression of X on a_j is linear up to a relative error o(1), or at least its non-linear part is also of relative size D^{−1/2}.** I see two possible sources for it (neither worked out): a second-order (Hessian-free) integration-by-parts identity for E[(X − m)·g(a_j)] with g a general test function, in the spirit of Lemma S9; or the block/Markov structure of §7, which makes a_j nearly independent of the part of X supported far from j.
2. **(ACT) needs the independence that the heuristic assumes.** Lemma S11 gives it one site at a time, under the crude bound ωσ_j·log n ≪ 1 and a constant-level bound ‖â − θ\*‖∞ ≤ L (so that the noise density at â_j is ≥ f₋). A high-probability matrix bound also needs second-order stability (two sites), not written.
3. **Expectation against probability.** Taking the data expectation of Lemma S9 with leave-one-out gives, under (LR-approx), E[λ_max]·(ωf₋(1 − o(1)) + γ) ≤ 1, hence λ_max ≤ K/(ωf₋ + γ) with probability ≥ 1 − 1/K by Markov. This is enough for a one-shot statement at a γ where the crude bound is automatic, but not for the bootstrap, which needs each step to hold with probability close to 1.

### 9.6 The intended bootstrap in γ — SKETCH

- For γ ≥ γ₀ := lev(𝒮)·(ω·log n/ε)² the crude bound max_jσ_j ≤ ε/(ω·log n) holds for every data vector (Σ ⪯ γ^{−1}P_𝒮 and Lemma S2).
- *Implication to prove:* crude bound at γ ⇒ sharp bound Σ ⪯ C/(ωf₋ + γ) at γ (this is (LR-approx) + (ACT) with Lemma S11).
- The sharp bound gives max_jσ_j² ≤ (9/h)·C/(ωf₋), which is below the crude level by a fixed factor when D ≪ n·ε²f₋/(ω·log²n). The covariance is continuous in γ. So the set of γ ≥ 0 at which the crude bound holds is closed, and open by the implication: it is all of [0, ∞), in particular γ = 0.
- This is a standard continuity argument; it requires the implication on a data event that does not depend on γ (or on a grid of γ with a perturbation bound between grid points).

### 9.7 Assessment

- The identities S9–S10 and the stability lemma S11 are, I think, the right skeleton: they show that (COV) is an equidistribution statement and that its natural range is D ≪ n/polylog, with no n^{3/2} barrier.
- The gap is genuine and is a statement about the dependence structure of a log-concave measure (item 1 of §9.5), not about empirical processes. I do not have an estimate of how hard it is.
- Route (b) remains untouched. If item 1 of §9.5 is attacked through the Markov structure, the two routes meet: near-independence of a_j from the far part of the path is exactly the forgetting property of §7.
- **Numerical test of the skeleton (UNTESTED):** from saved draws at one mid-ℓ cell, form Σ̂ and the diagonal matrix with entries κ̂_j(z_j) = T̂_j(z_j)/σ̂_j², and compare Σ̂^{−1} with ω·P_𝒮diag(κ̂)P_𝒮 on 𝒮 (relative operator-norm error). A small error would confirm (LR-approx); the smallest eigenvalue of P_𝒮diag(κ̂)P_𝒮 against f tests (ACT). Both are cheap post-processing.

---

## 10. Two sharpenings of the stopping point

*Appended about 16:15 CT. Not audited. These do not close the gap; they show that it is smaller than §9.5 suggests, and local.*

### 10.1 The coordinate variances obey a local identity — PROVED

(SUP) needs maxᵢσᵢ², not ‖Σ‖_op. Take the (i, i) entry of Lemma S9:

  **ω·Σ_k P_{ki}·R_{ik}(z_k) + γ·σᵢ² = P_{ii},  P := P_𝒮, R_{ik}(z) = E[(aᵢ − âᵢ)1{a_k > z}],  ∫R_{ik}(z)dz = Cov(aᵢ, a_k).**

The equidistributed version of the left side is ω·f·Σ_kP_{ki}Σ_{ik} + γσᵢ² = (ωf + γ)·σᵢ² (because ΣP = Σ on 𝒮). So the target is

  **σᵢ² ≈ P_{ii}/(ωf + γ) ≤ (9/h)/(ωf + γ),**

and it follows from equidistribution of the data points z_k **in the row i of the projector only**.

Consequences for the difficulty.
- *Locality — SKETCH.* For the spline projector the kernel k ↦ P_{ki} is concentrated on |k − i| ≲ h (I expect exponential decay at scale h, as for any banded Gram system; not proved here). So only the pairs (aᵢ, a_k) with |k − i| ≲ h·log n matter.
- *The Cauchy–Schwarz loss disappears.* For such pairs the correlation of aᵢ and a_k is of order one, not D^{−1/2}. Bounding |R_{ik}(z_k)| ≤ σᵢ·(activity of k)^{1/2} and counting ≈ h·f·σ active neighbours with weights |P_{ki}| ≲ 1/h gives |Σ_kP_{ki}R_{ik}(z_k)| ≲ f·σ²: **the same order as the main term**, with a constant. So in the local form the missing estimate is no longer a factor √D; it is a **lower bound with a positive constant**: Σ_kP_{ki}R_{ik}(z_k) ≥ c·f·σᵢ².
- *What would give the sign.* If the regression t ↦ E[aᵢ | a_k = t] is nondecreasing for the neighbours k in the central lobe of the kernel (where P_{ki} > 0), then R_{ik} ≥ 0 there, and the central lobe alone gives the lower bound, provided the negative side lobes of the kernel carry a smaller share. Monotone regression between neighbouring coordinates of a "smooth path" measure is plausible but is not implied by log-concavity.

### 10.2 The second derivative of the marginal potential — PROVED for a smoothed loss

Replace the check loss by a convex C² smoothing ρ^{(η)} (curvature supported on |x| ≤ η, total curvature 1), so that U is C². For a unit v ∈ 𝒮 and X = ⟨v, a⟩, with S_v := ∂_vU/ω and ∂_vS_v = Σᵢvᵢ²·(ρ^{(η)})″(zᵢ − aᵢ) ≥ 0, the classical identity for marginals of e^{−U} reads

  **W_v″(x) = ω·E[∂_vS_v | X = x] − ω²·Var(S_v | X = x) ≥ 0.**

(The inequality is Brascamp–Lieb / Prékopa.) Two consequences.
- **PROVED:** ω·Var(S_v | X = x) ≤ E[∂_vS_v | X = x]. The conditional variance of the sign statistic is at most its mean crossing density divided by ω. This is a free a priori bound; in the equidistributed regime the right side is ≈ f.
- **(COV) is exactly a strict version of it.** By Lemma S5, (COV) holds as soon as, on average over x at scales beyond t₀,

  ω·Var(S_v | X = x) ≤ (1 − c)·E[∂_vS_v | X = x].

  In words: given the value of the linear functional X, the sign statistic S_v = Σᵢvᵢ1{aᵢ > zᵢ} still fluctuates, but by strictly less than the extremal amount.

*Why the strict gap is expected — CONJECTURE.* Linearize: the fluctuation of S_v given X is ≈ Σᵢvᵢfᵢ·(a_{⊥,i} − E a_{⊥,i}) plus a discretization remainder, a_⊥ the component of a orthogonal to v. For constant fᵢ = f the linear part is f·⟨v, a_⊥ − E a_⊥⟩ = 0 **identically**, because a_⊥ ⊥ v. What remains is the discretization noise of ≈ n·f·σ indicators with weights vᵢ² ≈ 1/n, of variance ≈ f·σ, so ω·Var(S_v | X) ≈ ω·σ·f ≪ f when ωσ ≪ 1. For non-constant fᵢ the linear part is ⟨f∘v, a_⊥⟩ and v should be taken as an eigenvector of the weighted problem, as in the averaged-β note.

*What is missing.* A proof that the conditional variance of S_v is dominated by this cancellation. A Poincaré inequality applied to S_v directly fails (its gradient is spiky: |∇S_v|² ≈ f/η for smoothing scale η); the cancellation of the linear part has to be used before any variance inequality. This is the same object as the non-linearity remainder 𝔈 of §9.5, seen from the conditional side.

### 10.3 Stopping point, restated

The fluctuation part of (SUP) holds if **either** of the following is proved for the log-concave measure μ on 𝒮, on a data event of probability → 1:

- **(L)** for each i: Σ_kP_{ki}·R_{ik}(z_k) ≥ c·f·σᵢ² (a local, one-sided, constant-level bound); or
- **(G)** for each unit v ∈ 𝒮: ω·Var(S_v | X) ≤ (1 − c)·E[∂_vS_v | X] on average (a strict Brascamp–Lieb gap).

Both are constant-level statements, in a regime where every quantity is of its natural order. Neither is proved. (L) is the one I would attack first: it is local, it needs only ωσ ≪ 1 and the leave-one-out lemma S11 for the equidistribution of the central lobe, and its remaining difficulty is a sign (monotone regression between neighbouring coordinates), for which the order-3 Markov structure of route (b) is the natural tool.

## Theory response to §9–§10 (2026-11-23)

**Status: OPEN. Route (a) does not close; route (b) is untouched. UNAUDITED.**

**PROVED (unaudited):**
- the matrix virial identity ω·C·P_𝒮 + γΣ = P_𝒮, with the equidistribution reading of each entry;
- one-site stability;
- the conditional implication (linear regressions ⇒ the exact precision formula).

**The stopping point, now a single sign.** A strict Brascamp–Lieb gap, ω·Var(S_v | X) ≤ (1 − c)·E[∂_vS_v | X]; the non-strict version is proved. Equivalently: monotone regression between neighbouring coordinates. This is where route (b)'s Markov structure should enter. **That makes it the Tuesday entry point for the L4a/L4b lemma.**

**Diagnostic (UNTESTED, internal).** It can ride on the Tuesday draws check: compare Σ̂⁻¹ with ω·P_𝒮·diag(κ̂)·P_𝒮.

---

## 11. Route (b): the order-3 Markov structure

*Appended 2026-11-23, about 16:30 CT, same author. Not audited. Read for this section: `FABLE_A_gap4.md` §3–4. Object: the full fixed-(ω, ℓ) posterior of θ on ℝⁿ, density ∝ exp{−ωQ(θ) − ℓ‖Dθ‖₁}; k̄ := max(τ, 1 − τ).*

### 11.0 Outcome

| # | Claim | Status |
|---|---|---|
| 1 | (i) **The interaction is not attractive.** The FKG lattice (MTP₂) criterion fails in θ-coordinates, in u = Dθ coordinates and in second-difference coordinates. No positive-association theorem applies; monotone neighbour regression is not obtained | PROVED computation (§11.1) |
| 2 | (ii) **Block spike lemma.** For a block I of length g with g(g+1)² ≤ ℓ/(ωk̄), every data vector and every outside configuration: P(‖θ_I − θ′_I‖∞ > a \| outside, y) ≤ exp{2ℓρ_I + 1.8g − ℓa/(2(g+1)²)}, θ′_I the minimal-roughness interpolant and ρ_I its cost | PROVED (§11.2) |
| 3 | Exact additivity ℛ(δ) = ℛ(δ^{lo}) + ℛ(δ^{hi}), and: for Fable A's reduction a **posterior-probability** bound Π(E_s > ηk \| y) ≤ ½ is enough (it can be absorbed) | PROVED (§11.3) |
| 4 | The bound on high-amplitude energy | **not proved**; it is reduced to two named statements, (ρ) and (B2) (§11.4) |

### 11.1 FKG does not apply — PROVED computation

Holley's criterion on ℝⁿ asks for −log(density) to have non-positive mixed second derivatives (in the distributional sense).
- *θ-coordinates.* The likelihood is a sum of one-coordinate terms (no mixed derivatives). A penalty term |cᵀθ| with stencil c = (−1, 3, −3, 1) has mixed derivative δ₀(cᵀθ)·c_ic_k, and c_ic_k takes both signs: (−1)(3) < 0 but (−1)(−3) > 0 and (3)(−3) < 0, (3)(1) > 0. So the third-difference penalty is attractive between adjacent coordinates and **repulsive between coordinates two apart**. (For first differences, c = (−1, 1), every product is negative: order k = 0 is attractive. For second differences, c = (1, −2, 1), the pair at distance two is repulsive. So FKG is available only for k = 0.)
- *u-coordinates.* The prior is a product. The likelihood terms ρ_τ(yᵢ − (Nc + Su)ᵢ) have mixed derivatives ρ_τ″·S_{ij}S_{ik} ≥ 0 (all entries of S are ≥ 0): repulsive.
- *Second-difference coordinates.* The penalty becomes a first difference (attractive) but the likelihood is again a convex function of a non-negative combination: repulsive.

The criterion is sufficient, not necessary, so this does not show that neighbour regressions fail to be monotone. It shows that **no off-the-shelf positive-association argument gives the sign** asked for in §10.3 (L). Item (i) stops here.

### 11.2 The block spike lemma — PROVED

Let I = {p+1, …, p+g} with at least three coordinates on each side, and 𝒥_I := {p−2, …, p+g} the g + 3 stencils that touch I. Fix the outside values. Let F(θ_I) := Σ_{j∈𝒥_I}|(Dθ)_j|, ρ_I := min_{θ_I}F, θ′_I a minimizer, β := θ_I − θ′_I ∈ ℝ^g, and 𝖣β ∈ ℝ^{g+3} the values on 𝒥_I of D applied to β extended by zero.

**Lemma B1.** If g(g+1)² ≤ ℓ/(ωk̄), then for every a > 0, every data vector and every outside configuration:

  **P(‖θ_I − θ′_I‖∞ > a | θ_{Iᶜ}, y) ≤ exp{2ℓρ_I + g·log 6 − ℓa/(2(g+1)²)}.**

*Proof.*
1. *Inverse inequality.* β extended by zero vanishes at p−2, p−1, p, so by Newton's formula β_{p+i} = Σ_{j=p−2}^{p+i−3}C(p+i−j−1, 2)·(𝖣β)_j, with coefficients ≤ (g+1)²/2. Hence ‖β‖∞ ≤ ((g+1)²/2)·‖𝖣β‖₁ and ‖β‖₁ ≤ (g(g+1)²/2)·‖𝖣β‖₁. In particular 𝖣 is injective and N(β) := ‖𝖣β‖₁ is a norm on ℝ^g.
2. *Sandwich.* F(θ_I) = ‖(Dθ′)_{𝒥_I} + 𝖣β‖₁ ∈ [N(β) − ρ_I, N(β) + ρ_I], and |Q_I(θ′_I + β) − Q_I(θ′_I)| ≤ k̄‖β‖₁ ≤ (ℓ/(2ω))·N(β) by the hypothesis on g. So the conditional density of β is between c·e^{−ℓρ_I}e^{−(3ℓ/2)N(β)} and c·e^{ℓρ_I}e^{−(ℓ/2)N(β)}.
3. *Ratio.* For any Borel A: P(β ∈ A | ·) ≤ e^{2ℓρ_I}·∫_Ae^{−(ℓ/2)N}/∫e^{−(3ℓ/2)N} = e^{2ℓρ_I}·3^g·P_{ℓ/2}(A), where P_c has density ∝ e^{−cN(β)} (by scaling, ∫e^{−cN} = c^{−g}∫e^{−N}).
4. *Radial law.* Under P_c, N(β) ~ Gamma(g, rate c). {‖β‖∞ > a} ⊂ {N > 2a/(g+1)²}, and P(Gamma(g, 1) > x) ≤ 2^g e^{−x/2}. ∎

**Reading.** At block lengths up to the bandwidth (g³ ≲ ℓ/ω), the likelihood cannot move a block away from the prior's minimal-roughness interpolant of its surroundings by more than a ≈ (g²/ℓ)·(4ℓρ_I + 4g): **features narrower than the bandwidth are slaved to the prior, whatever the data.** With the prior-typical boundary cost ℓρ_I ≍ g this is a ≍ g³/ℓ, which is ≪ s = ℓ^{−1/18}/log n for g ≤ c·(ℓs)^{1/3}, a length just below the bandwidth ℓ^{1/3}. The lemma is deterministic in the data, so it is immune to the score-alignment obstruction (Astra §1; (O1) of `FABLE_A_gap4.md`): a score-aligned bump of width < g and amplitude > a simply has no room.

### 11.3 Two exact facts for the reduction — PROVED

- **Additivity.** ℛ(δ) = ΣᵢXᵢ(δᵢ) and Xᵢ(0) = 0. With δ^{hi}ᵢ := δᵢ1{|δᵢ| > s} and δ^{lo} := δ − δ^{hi}: **ℛ(δ) = ℛ(δ^{lo}) + ℛ(δ^{hi})**, exactly. The high-amplitude part of the loss is a sum over the high-amplitude coordinates only.
- **Absorption.** In the reduction of `FABLE_A_gap4.md` §3, Z̃ ≤ e^{Cηk}𝒵 + N(K_Hᶜ) + N(K_H ∖ 𝒢). If Π_{ω,ℓ}(K_H ∖ 𝒢 | y) ≤ ½, i.e. N(K_H ∖ 𝒢) ≤ ½Z̃, then Z̃ ≤ 2(e^{Cηk}𝒵 + N(K_Hᶜ)). So **a posterior-probability bound of ½ on {E_s(δ) > ηk} suffices**; an absolute evidence bound e^{−ck} is not needed.

### 11.4 Where it stops

To get Π_{ω,ℓ}(E_s(δ) > ηk | y) ≤ ½ from Lemma B1, two statements are missing.

**(ρ) Posterior control of the boundary cost.** Lemma B1 carries the factor e^{2ℓρ_I}. ρ_I ≤ ‖(Dθ)_{𝒥_I}‖₁, and Theorem H gives only the global bound ‖Dθ‖₁ ≤ Tn/ℓ, i.e. ℓρ_I ≲ g **on average over blocks**. What is needed is: for all but a fraction o(k/n·…) of the blocks, ℓρ_I ≤ C·g, in posterior probability. The global bound gives this by Markov's inequality for a fixed fraction of blocks (at most a fraction 1/K of the n/g blocks have ℓ·‖Dθ‖_{1,block} > K·T·g), which is **not enough**: the exceptional blocks are a constant fraction, and E_s > ηk is itself an event about a fraction ≍ k/(n s²·g)·… of blocks. A multi-scale induction (the cost at scale g is controlled by the deviations at scale 2g, which Lemma B1 controls given the cost at scale 2g) is the natural proof; it is not written.

**(B2) Wide runs.** After Lemma B1, a high-amplitude set consists of runs of length ≳ g whose profile varies slowly (it is the interpolant of coarse values plus a deviation ≤ a). For such δ one needs, uniformly: **ℛ(δ^{hi}) ≥ (1 − η)·M(δ^{hi})**, with M(δ^{hi}) ≥ (f/2)‖δ^{hi}‖₂². Scale bookkeeping says there is room: on a run of length L the margin is ≥ ω(f/2)s²L, the profiles have ≈ L/g free coarse values, so the entropy is ≈ (L/g)·log n, and s²·g ≍ ℓ^{−1/9}·(ℓs)^{1/3} = ℓ^{11/54}/polylog ≫ log n. So a net-and-union argument over coarse profiles should work run by run — SKETCH; the uniformity over the deviation ≤ a inside each block (where score alignment is possible but bounded by ω·a·L) also has to be absorbed, which needs a ≪ s²·f, i.e. a slightly shorter g.

**Then the conclusion would be:** on K_H ∖ 𝒢 minus the spiky configurations, −ωℛ(δ) ≤ ω·η·f·k − ω(1 − η)(f/2)‖δ^{hi}‖₂² (Lemma 1′ for the low part, (B2) for the high part), which is ≤ −cηk as soon as E_s > 3ηk; and the spiky configurations have small posterior probability by B1 + (ρ). That is the posterior statement (O1) asks for.

**Markov-chain form — SKETCH.** Conditionally on the triples at block boundaries, blocks are independent, so the sequence of boundary triples is a Markov chain under the posterior. Both (ρ) and the block-wise version of the energy bound are statements about this chain; the clean formulation is a drift condition: a Lyapunov function V of the boundary triple (distance to the truth plus incompatibility cost) with E[e^{θ(E_s^{block} + V(next))} | current] ≤ e^{θ(ϱ·V(current) + c)}, ϱ < 1. Lemma B1 is the "one-step contraction at scales below the bandwidth" for the incompatibility part. The contraction of the distance-to-truth part over a block of length C·h (the forgetting property of §7) is the piece with no proof and no partial result.

### 11.5 Assessment

- (i) is closed negatively: the sign will not come from positive association.
- (ii) has one new unconditional tool (Lemma B1) and a sharper target (posterior probability ½ instead of an evidence bound). The remaining work is (ρ), (B2) and forgetting at the bandwidth scale. Of these, (B2) looks routine, (ρ) looks like a careful induction, and forgetting is the genuine difficulty: it is where the likelihood, not the prior, must do the work, at exactly the scale where Lemma B1's hypothesis g³ ≲ ℓ/ω stops.
- Lemma B1 uses only that the check loss is k̄-Lipschitz; it holds for any Lipschitz convex loss and every level τ.

## Theory response to §11 (2026-11-23)

**Status: OPEN. UNAUDITED.**

**(i) FKG fails.** The FKG lattice criterion fails in θ-, u- and second-difference coordinates; only k = 0 is attractive. This is a PROVED computation. Since the criterion is only sufficient, monotone regression is not disproved, but off-the-shelf positive association is ruled out.

**(ii) New unconditional tool: the block spike lemma (PROVED, unaudited).** Sub-bandwidth features are slaved to the prior, deterministically in the data, so the lemma is immune to the score-alignment obstruction.

**Sharpening of Fable A's target (PROVED).**
- The loss splits exactly into low and high parts.
- In FABLE_A_gap4.md §3, a posterior-probability bound of ½ on high-amplitude energy suffices.

**What stops it:**
- posterior control of the boundary cost for almost all blocks, which needs a multi-scale induction;
- the forgetting property at the bandwidth scale, where the likelihood must do the work. **This is the genuine difficulty.**

**Next.** All of this goes to Tuesday's L4a/L4b entry, alongside the strict Brascamp–Lieb gap (§10).
