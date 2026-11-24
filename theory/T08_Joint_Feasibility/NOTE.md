# T-08: Can the T-07 theorem be extended to the joint non-crossing sampler?

Theory Department, 2026-11-24. This is a feasibility question from Felipe, answered as an opinion; no proof was written.

Three agents answered independently: the T-07 prover (Fable), Astra-1 and Astra-2 (`prover_answer.md`, `astra1_answer.md`, `astra2_answer.md`). I worked out the main argument myself before reading them. All four of us agree.

## Setting

The joint model is in `paper/sections/methodology.tex`, §Joint quantile sampler. Its levels are τ₁ < … < τ_J, held fixed. Each level j has its own θ_j and uses the T-07 prior and likelihood, with λ_j = c_j n^{(2r−1)/2} and σ_j fixed. All levels use the same data y. The joint posterior is

Π_C(dΘ | y) ∝ 1_C(Θ) ∏_j Π_j(dθ_j | y),  C = {θ_{i1} ≤ … ≤ θ_{iJ} for every i}.

The assumptions are those of T-07 at every level: A and B with common (L, f, f̄), V*_j ≤ V̄, and r ≥ 2.

## Verdict

**Yes.** Each level's marginal under the joint posterior keeps both T-07 results:
- the log-free upper bound (Thm 2), at rate n^{−(2r−1)/(2r)};
- the matching lower bound (Prop 5).

The expected tail mass is O(J·n^{−1/(2r)}). **No extra assumption** is needed.

## Why (the whole argument)

1. **Truncation is conditioning.** Write Π^⊗ for the product of the individual posteriors. For any set A of θ_j values,

   Π_C(θ_j ∈ A | y) = Π^⊗({θ_j ∈ A} ∩ C | y) / Π^⊗(C | y) ≤ Π_j(A | y) / Π^⊗(C | y).

   This is pathwise in y, so it holds even though all levels share the data. It needs no J-fold integral over C and no normalizing constant: λ_j is fixed, so the constant cancels. It also needs no Anderson-type inequality on the cone C.
2. **The true curves are separated, automatically.** By B at level j, if θ*_{i,j+1} − θ*_{ij} = d < L, then
   τ_{j+1} − τ_j = F_i(θ*_{i,j+1}) − F_i(θ*_{ij}) ≤ f̄·d.
   So every gap is at least g₀ = min{L, min_j(τ_{j+1} − τ_j)/f̄} > 0. Touching true curves are impossible under A + B with fixed levels.
3. **The posterior stays ordered with high probability.** T-07's localization (Prop 2) shows each Π_j puts mass at least 1 − e^{−c nρ_n²} on a set where ‖θ_j − θ*_j‖_∞ ≤ s_n → 0, on the good-data event. Once s_n < g₀/2, every Θ in the product of these sets is ordered. So Π^⊗(C | y) ≥ 1 − J·e^{−c nρ_n²} ≥ 1/2.
4. **Transfer.** On the intersection of the J good events, Π_C(θ_j ∈ A | y) ≤ 2·Π_j(A | y). Take A = {Δ²_n > M ε_n²} for the upper bound and A = {Δ²_n ≤ c₀ ε_n²} for the lower bound. The bad events add J times T-07's failure probabilities.

## What carries over and what is new

- **Used verbatim, per level:** prior mass, evidence, localization, shells, the lower bound, and all constants.
- **New:** the conditioning inequality (2 lines), the gap lemma (3 lines) and the statement. In total about 1 page.

## Caveats (for the paper's wording)

- **The result is asymptotic.** The sup-norm radius s_n decays slowly, like n^{−1/30} up to logs at r = 2. At practical n the ordering constraint can still bind and change the posterior. The theorem says that its effect vanishes, not that it is absent.
- **The scope is that of T-07:** fixed λ_j and σ_j, fixed and distinct levels. The paper's joint sampler learns λ_j and σ_j, which is not covered (same as for T-07).
- **Not covered:** n-dependent levels or gaps (τ_{j+1} − τ_j → 0), and truths that violate B, where curves can touch. These would need a new sup-norm small-ball lemma: about 4–6 pages, medium-to-high risk, about 50% confidence (prover's estimate). Not recommended.
- **The "truncation to a convex set containing the truth can only help" argument is not valid by itself.** What makes the proof work is the lower bound on Π^⊗(C | y) from step 3.

## Size, risk, confidence

About 1–2 pages, low risk. Confidence: high for all three agents (prover about 90%, Astras high), and mine is high too.
