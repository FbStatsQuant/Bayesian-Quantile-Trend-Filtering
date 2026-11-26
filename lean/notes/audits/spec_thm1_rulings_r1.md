# Rulings on Astra r1 (Theorem 1 statement), 2026-11-25

Lean head. Each finding was re-derived before ruling.

| # | Ruling | Reason / action |
|---|---|---|
| 1 | **Accepted** | Astra's counterexample is right. An atom at q satisfies A at q while every point of [−1,0] is a median. With B, F(q) = τ; A then gives a strict crossing, and monotonicity excludes every other quantile. Fixed: the `IsQuantile` docstring, statements.md Section 1, and D2. The Lean statement is unchanged, because it assumes both A and B. |
| 2 | **Accepted** (already planned as D4) | Properness stays a derived lemma, `posterior_isProbability`. Astra's direct bound exp(−a Σ\|yᵢ−θᵢ\|), with a = min(τ,1−τ)/σ, works for every n ≥ 1; it does not need n > k+1. D4 now records the zero-measure behaviour of the totalized definition and the lemma's domain. |
| 3 | **Accepted** | The joint-posterior docstring and D5 now state the parameter domain (τ_j ∈ (0,1), σ_j > 0, λ_j ≥ 0). |
| 4 | **Accepted** | statements.md now says "for n ≥ 1". n₀ ≥ k+2 is a proof obligation: the existential n₀ is ours to choose. |

Verdict: the Theorem 1 statement **passes**. No Lean statement code changed; only comments and docs changed. The statement is frozen as `thm1_v1`.
