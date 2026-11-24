# T08 feasibility: joint non-crossing posterior (prover's answer)

Opinion only; nothing here is written out as a proof. Setting as asked: fixed J, fixed levels τ₁ < … < τ_J, fixed λ_j = c_j n^{(2r−1)/2} and σ_j, r ≥ 2, A + B at each level, V*_j ≤ V̄. Π^⊗ denotes the product of the J individual posteriors, Π_C the joint (truncated) posterior, s_n the sup-norm radius of the T-07 localization set K_n (s_n → 0; about n^{−1/30} at r = 2, n^{−13/70} at r = 3, up to logs).

## (1) Answer: yes to both, with no new assumption

Two elementary facts do all the work.

- **Fact 1 (separation is automatic).** Assumption B at level j gives F_i(θ*_{ij}) = τ_j and F_i(θ*_{ij} + t) − τ_j ≤ f̄ t for 0 ≤ t ≤ L. Hence θ*_{i,j+1} − θ*_{ij} ≥ g₀ := min{L, min_j(τ_{j+1} − τ_j)/f̄} > 0, for every i and n. With fixed distinct levels the true curves cannot touch or nearly touch.
- **Fact 2 (truncation is conditioning).** Π_C(B | y) = Π^⊗(B ∩ C | y)/Π^⊗(C | y), so the total-variation distance between Π_C and Π^⊗ is exactly Π^⊗(Cᶜ | y).

T-07's Proposition 2 already gives, for each level, posterior mass of {‖θ_j − θ*_j‖_∞ > s_n} that is exponentially small outside an event of probability O(n^{−1/(2r)}). Once s_n ≤ g₀/2, every Θ with all levels in their K_n lies in C. So E Π^⊗(Cᶜ | y) ≤ C·J·n^{−1/(2r)}, and each joint marginal is within that distance of the individual posterior.

Consequences: Theorem 2 holds for every level's marginal (and jointly for all levels) with the same M_j and the bound C·J·n^{−1/(2r)}. The lower bound (Proposition 5) transfers the same way. Asymptotically the constraint is inactive.

## (2) Extra assumptions, and the touching case

- **Fixed levels: none.** A gap condition is implied by B (Fact 1).
- **"Truncation to a convex set containing the truth can only help" is not a valid argument.** It lowers the numerator but also the normalizing constant; what is needed is a lower bound on Π^⊗(C | y).
- **Shrinking gaps g_n → 0** arise only outside the T-07 assumptions: levels that get closer with n (J_n → ∞), or B failing between two quantiles.
  - If g_n ≥ 2 s_n and J_n = o(n^{1/(2r)}): the argument above still holds verbatim.
  - If g_n is smaller, or curves touch: Π^⊗(C | y) is exponentially small and a joint evidence bound is needed. My estimate (heuristic, not proved): the loss is exp{−C·J·n ε_n²} = exp{−C·J·n^{1/(2r)}}, the same order in the exponent as the T-07 evidence term, so the rate n^{−(2r−1)/(2r)} would survive with a larger M. The centre must be shifted by about ε_n per level (free in the prior, cost n ε_n² in the likelihood), and one needs a **sup-norm** small-ball bound for the prior at radius ≍ ε_n. T-07 only has the ℓ₂ small ball (Lemma 4); with ℓ₂ plus interpolation the shift would have to be ≫ ε_n and the provable rate would be much worse.

## (3) What carries over

| T-07 step | Joint model, fixed levels |
|---|---|
| Prior mass, evidence (Prop 1, Lemma 7) | Verbatim, per level. No prior mass under truncation is computed. |
| Normalizing constant | N^⊗(C) = Π^⊗(C | y)·∏ N_j(ℝⁿ), and Π^⊗(C | y) ≥ 1/2 on the good event. New, 5 lines. |
| Localization (Prop 2) | Verbatim, per level; it is what proves Π^⊗(C | y) → 1. Union bound over J. |
| Shells (Prop 3) | Verbatim. The J-fold integral over C is never computed: drop the indicator, the other levels cancel exactly, Π_C(E) ≤ 2 Π_j(E) on the good event. |
| Lower bound (Prop 5) | Transfers by Fact 2. Anderson is applied only to the individual symmetric problem; nothing is needed on the cone. |
| Dependence across levels (same y) | Only union bounds are used. |

New work: Fact 1, Fact 2, and the statement. Touching curves would need new work on the evidence bound and a new small-ball lemma.

## (4) Size, risk, confidence

- **Fixed levels (recommended statement):** about 1 page as a corollary of T-07. Risk low. Confidence about 90% that it is correct as described.
- **Caveats to state honestly:**
  - It is an asymptotic statement: it needs s_n ≤ g₀/2, and s_n decays slowly (n^{−1/30} at r = 2), so at practical n the constraint is active and the theorem does not describe that regime. A sharper sup-norm contraction rate would lower the threshold; I expect ε_n up to logs, but T-07 does not prove it.
  - It covers fixed λ_j, σ_j only, not the hyperpriors of the sampler.
- **Touching or n-dependent gaps below s_n:** 4–6 pages, one new lemma (sup-norm small ball for the Laplace-difference prior). Risk medium to high. Confidence about 50% that the sharp rate can be proved. I would not start it unless the paper needs growing J.
