# Final VP review of STATEMENT_DRAFT.md v3

*Fable (VP / senior advisor), 2026-11-22. Final check before the owner commits.*

**Verdict: READY WITH CHANGES.** The rate, the primary/fallback split and the assumptions are right, and I would commit to this theorem. Five small edits to the statement (point 1) and a re-plan of the likelihood side (points 3 and 4) should go in first.

**What I checked.** I read L3, L4q and L6 line by line and re-derived every exponent in the statement. The two proof routes I propose (3b and 4.1) are checked at the level of exponents only; they are sketches, not proofs.

## 1. Statement: correct, with five edits

The rate algebra matches the lemma chain: small ball against the budget κnε² gives κ^{−5/6}λ^{−1/3}; L4q-M gives κ^{−5/6}V²λ^{5/3}n^{−5}; L4 gives κ^{−1}λVn^{−3}. Corollaries A1, A2 and A-fb check out. No assumption is too strong.

1. **(A4) must read σ ≥ (1+η)σ̄**, with constants depending on η. At σ = σ̄ the MGF exponent vanishes to second order, so L8′ gives no decay. The Laplace and t₂ rows (R = 1) are then not covered.
2. **Correct the sharpness sentence on ω̄(Δ).** `omega_bar_exact.out` tests Δ ≤ 4 sd only, and for the mixture row ω̄(Δ) falls 14.4 → 6.7 → 2.3, so "covered" holds only for Δ ≲ 1 sd. My check at 0.9·ω̄: E e^{−ωX} = 1.06 at δ = 10 for t₃, and 1.46 at δ = 5 for Cauchy. Uniformly over 𝒫ₙ the Fubini route needs Δ ≲ c/ω, so it depends entirely on sup-norm localization.
3. **κ and σ.** In Theorem A, M can be taken free of σ (the budget and the Chebyshev term both scale with κnε²). Say so; otherwise κ^{−5/6} is decoration. In A⁺ the spread term needs a factor (1 ∨ σ̄/σ). σ̄ is exactly where the posterior spread equals the sandwich variance of the centre (σ/f against τ(1−τ)/f²). Below σ̄ the rate is the centre's sampling error, τ(1−τ)f^{−2}κ^{1/6}λ^{−1/3}, which increases in κ.
4. **Fix a₀ = 2 and state C₀ > 3c/5.** The values 3/2 and 9/5 both assume ‖δ‖ₙ ≈ ε, which is the conclusion. The non-circular value I get is 21/11 (point 4.1). Nothing of interest lies below 2.
5. **State the theorem in both losses.** L10 is inside the proof, and Δ²ₙ = ‖δ‖²ₙ on {‖δ‖∞ ≤ Δ ≤ 1}, so Corollary A3 is automatic. Two smaller items: the min is never active inside the window, so present it only as the fallback label; and ASTRA's L2 fix (C₁ inside the min) has not reached the statement table.

## 2. Primary versus fallback

- **n^{−5/6} at λ ≍ n^{5/2}/V is the right primary.** I found no gap in L4q: steps 1–7 are correct as written, for every h, including the j = m edge. For L4q-M, avoid boundary kernels: extend θ\* by its end quadratics (u\* by zeros) and use an interior kernel.
- **L3 is correct**, with two fixes. The Horn index must be ⌊(r+2)/3⌋, not ⌈·⌉ (the bound is unchanged). The head sum is Σ_{r≤K} log(K³/r³) ≈ 3K, so the log(e+x) factor disappears and only (log n)^{1/5} remains. Its numerical check never ran: `l3_singular_values.out` is an owls refusal.
- **Numerics are sufficient for the decision**: mechanism, bias slope and spread law agree. All of it is at τ = ½ with Gaussian noise.
- **n^{−3/4} is a genuine fallback** in the strict sense: it drops only L4q and L4q-M. But it insures the lowest-risk open item and shares all the likelihood-side risk. The statement has no fallback for L10; add one (point 4.1).

## 3. The σ story

a. **The A⁺ plan is credible in outline**, but steps 2 and 4 (net, chaining) are heavier than needed.

b. **Simpler route on the localized set (Hölder–Knight).**
   - Knight: ℛ = −u′δ + Rₙ(δ), with Rᵢ = (δᵢ − Zᵢ)·1{0 < Zᵢ < δᵢ} ≥ 0.
   - Cauchy–Schwarz in ν: N(E) ≤ (∫_E e^{2ωu′δ})^{1/2} (∫_E e^{−2ωRₙ})^{1/2}.
   - Remainder factor: Fubini works for **any** ω. Since E Rᵢ² ≤ f̄|δᵢ|³/3, E e^{−2ωRᵢ} ≤ e^{−ωmᵢ} for |δᵢ| ≤ 3f/(4ωf̄). I confirmed this numerically for Gaussian noise.
   - Score factor: project on quadratic splines with J ≍ Mnε² knots. Coarse part: |u′P_Jδ| ≤ ‖P_Ju‖·‖δ‖₂ ≲ √(Jn)·‖δ‖ₙ, with no net. Fine part: drop the indicator and use the exact Laplace MGF, ∏ⱼ(1 − 4ω²tⱼ²/λ²)^{−1} with t = S′(I − P_J)u and Σtⱼ² ≲ n(n/J)⁵.
   - Balancing gives Mε² ≳ κ^{1/6}f^{−2}λ^{−1/3}, the sandwich term of edit 3. No chaining.

   If this holds, A and A⁺ cost the same once L10 holds, and the Fubini milestone is redundant.

c. **Free test on existing E-02 output.** For Gaussian noise, τ = ½, σ = σ₀: the variance of the posterior mean across replicates, divided by the rough spread, should be ≈ π/2.

## 4. Risks, ranked

1. **L10 with L9-a and L9-c: highest.** The plan as written is circular: the interpolation needs ‖δ‖ₙ ≲ ε, and Step 2 needs L10. A two-stage route breaks the circle:
   - *Stage 1.* TV⁽³⁾(δ) ≤ Tn³/λ in posterior probability, from the Gamma tail of λ‖u‖₁. This TV ball contains no ε-ball, so the reviewers' counterexample does not apply. P&C's uniform bound plus convexity gives Δ²ₙ ≲ λ^{−2/7}, moment-free, for any ω. Convexity along rays also covers the far region and the complement of the ball (the tilt is only t²λ‖u − u\*‖₁/T), so L9-a's log-concavity and the L7 sieve are not needed.
   - *Stage 2.* Interpolation then gives ‖δ‖∞ → 0 when λ ≥ n^{21/11+}.

   This is the demoted Theorem A′, reused as a lemma. **If L10 fails:** the rate is unchanged; add an exponential-tail assumption, under which Fubini is global and L7, L9, L10 are not needed. The "no moments" claim and A⁺ are lost.
2. **L8-b (A⁺ only).** If it fails, the theorem keeps σ ≥ (1+η)σ̄. Gaussian σ₀ stays excluded and learned σ is blocked.
3. **L9-c and L7 as stated.** High as written, but avoidable by item 1. No statement change.
4. **L4q and L4q-M verification.** Low. If it fails: n^{−5/6} becomes n^{−3/4}, the oracle λ becomes (n³/V)^{3/4}, and the "linear-smoother rate" positioning goes.
5. **L3.** Low. A failure costs polylogs only.
6. **L6.** Low. Correct given its inputs.

## 5. Odds

| Target | Odds |
|---|---|
| (a) Theorem A at n^{−3/4}, moment-free as stated | 60% |
| (a′) the same with an exponential-tail assumption | 90% |
| (b) Theorem A at n^{−5/6}, moment-free as stated | 55% |
| (b′) the same with an exponential-tail assumption | 80% |
| (c) Theorem A⁺ (any fixed σ) | 40% |
| (d) Learned λ and σ, later | 20% |

(d) needs A⁺, because σ₀ < σ̄ for Gaussian noise. It also needs an unproved concentration of λ in a band, and by the memo's own analysis kinked truths then reach only n^{−3/4}.

## 6. What a referee attacks first

1. **The theorem does not cover the method as run.** The paper's fixed b₀ gives λ ≍ n^{3/4} (λ ≈ 50–2000 at n = 500), far below the window; the memo's own estimate there is n^{−1/4}. σ is learned and lands at σ₀ < σ̄ for Gaussian noise. This needs the b₀,ₙ decision and A⁺, or honest scoping in the paper.
2. **Upper bound only, for a posterior whose own mode is faster.** Without the lower bound the referee will call n^{−5/6} a proof artefact. Proving the conjecture in one case (quadratic truth) is the best single addition.
3. **The oracle λ depends on the unknown V.**
4. **Novelty against P&C plus ADH.** Lead with L4q and the truth-independent spread.
