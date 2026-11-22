# VP review of STATEMENT_DRAFT.md (verbatim)

**Verdict.** The theorem has the right shape (fixed σ and λ, Padilla's Δ²ₙ, the BV class, in-probability contraction), and I believe the spread term λ^{−1/3} and Corollary A2's n^{−5/7}. I would not send it to Felipe as written, for three reasons. First, the bias term λV*n⁻³ looks like an artefact of the shift lemma L4, so n^{−3/4} is probably not this posterior's best rate; my calculation gives n^{−5/6} at λ ≍ n^{5/2}. Second, L8 is false as stated and L9 cannot deliver what it claims, so the proof plan and the "no moments" claim are currently conjecture. Third, L10 (sup-norm control) is a prerequisite for the fallback A′ and for Corollary A2, not an optional extra.

## 1. Is this the right theorem?
- **Target, loss and mode of convergence are right.** Δ²ₙ is the natural moment-free loss, and uniformity over the class is what a comparison with minimax needs.
- **The bias term is too pessimistic.** L4 charges the full ℓ₁ cost λ‖Dθ*‖₁ for shifting the prior exactly onto θ*. Shifting onto a mollified copy of θ* costs only about λ²‖Dh‖₂², because each increment's tilt is far below the prior scale 1/λ.
  - *Mechanism:* the posterior keeps a kink of size J in θ″ only if J ≳ n²λ^{−2/3}, which exceeds V* throughout the window. Below that it smooths the kink over λ^{1/3} grid points, as a Gaussian prior of the same variance would.
  - *Resulting rate (heuristic):* ε² ≍ λ^{−1/3} + V*²λ^{5/3}n^{−5}, with best rate V*^{1/3}n^{−5/6} at λ ≍ n^{5/2}/V*. This is the linear-smoother minimax rate that Tibshirani (2014) cites from Donoho–Johnstone.
  - *Quick check I ran:* n = 300, one kink, Gaussian likelihood, noiseless data, exact Gibbs. The Laplace posterior-mean bias² is 1.01–1.04 times the smoothing-spline bias² at λ = 10⁶ and 3·10⁶, and about 1% of the draft's bound. This is one small n, so Theory should repeat it.
- **What changes.** Corollary A1 is not the "best rate", and the sharpness belief in doubt 3 is wrong. The posterior's loss against the mode is n^{1/42}, not n^{3/28}. The memo's upside conjecture s^{1/7}n^{−6/7} for sparse truths is a property of the mode, not the posterior.
- **E-02 can already discriminate.** For the kinked truth, the draft predicts risk rising past a = 9/4 (n^{−2/3} at 7/3, n^{−1/2} at 5/2). I predict it keeps falling to n^{−5/6} at a = 5/2.
- **"So the full posterior is slower" is a lower-bound claim.** Theorem A is only an upper bound. Either prove the spread lower bound (the memo's remark) or reword.

## 2. Assumptions
- **(A3): drop ‖θ*‖∞ ≤ B.** The prior is flat on quadratics, so the posterior of θ − θ* is exactly invariant to adding a quadratic to θ*. Padilla has no such bound either.
- **(A2) upper half: keep, but label it sufficient and proof-driven.** It excludes atoms and rounded data, which Padilla allows. The upper bound in L2 must be stated globally (mᵢ(δ) ≤ max(f̄/2, 1/L)·δ² for all δ, which is true), because a small L² ball does not give ‖δ‖∞ ≤ L.
- **(A4): carry κ = f/σ explicitly.** Corollary A1 shows σ^{−1/8} while the theorem hides σ in constants. The polylog lower end is overreach; see L10 below.
- **"No moments" is credible as a statement, not yet as a proof.** The check loss has bounded influence, so the claim is plausible, but every listed route to it currently breaks (§4).
- **Drop "+ n⁻¹".** λ ≤ n³ already gives λ^{−1/3} ≥ n⁻¹.

## 3. Rate, corollaries and A′
- The arithmetic is correct given the draft's two terms. The spread heuristic is sound, and I expect it to survive the ALD with κ = f/σ.
- A′ is not lower risk. Its TV-ball sieve has radius n³/λ ≫ 1, and Padilla's sup-norm bound (Lemma 19) is off by n^{r−1} as printed; the correct bound is ‖P_R δ‖∞ ≲ TV⁽ʳ⁾(δ). My check: a kinked quadratic has sup-norm 0.031 with raw ‖D³δ‖₁ = 2/n². This is harmless for Padilla (V = O(1)) but not here: Proposition 2 then gives n^{15/7}/λ, not λ^{−2/7}, unless sup-norm is controlled separately.

## 4. Lemmas
- **L8 is false as stated.** The sieve contains θ* + {‖P⊥v‖ₙ ≤ ε}, a full n-dimensional ball, and a direction fitted to the residual signs gains about nε in empirical risk. Numerically, at n = 16000 and ε² = n^{−3/4}, a point with Δ² = 21ε² has empirical excess risk −13ε². The fine-scale set A_ε needs entropy control at every scale below ε (a multiscale small-ball set), which also changes L3 and L7.
- **L9 cannot reach Mε².** Convexity plus log-concavity in dimension n pays e^{ηn} to gain e^{−ηcnΔ²}, so it controls only {Δ²ₙ > K} for a constant K. That part is plausible and moment-free. The shells between Mε² and K, and the sieve complement, need separate arguments; split L9 into three.
- **Do not accept "σ ≥ σ̄".** The Gibbs MGF route needs ω < f/(τ(1−τ)). For Gaussian noise at τ = ½, the learned scale σ₀ = E ρ_τ(ε) gives ω = 1/σ₀ larger than that by a factor π/2. The restriction would exclude the paper's own regime, so Stage A must hold for every fixed σ, by in-probability uniform bounds over nested sieves.
- **L10 is essential.** I suggest an interpolation bound ‖P_R δ‖∞ ≲ ‖δ‖ₙ^{4/5}·TV^{1/5} on localized shells. Heuristically it works for λ ≳ n^{3/2} with the two-level sieve.
- **L5.** Properness is trivial at fixed σ. The real issue is that "Π(𝔅ᶜ)" has no meaning for an improper prior; integrate the three quadratic coordinates explicitly.
- **L4.** Add a quadratic-cost shift inequality for symmetric convex sets, of the Agapiou–Dashti–Helin type (to be checked).

## 5. The six doubts
1. **ALD spread:** low risk; wait for E-02. Read slopes only where nλ^{−1/3} ≳ 10, and add the a ≥ 9/4 arm described above.
2. **L9:** restructure as in §4. No σ restriction. Sub-exponential noise is not a sufficient fallback, since the ω cap bites for light tails too.
3. **Positioning:** a sub-minimax headline is acceptable. Frame it as "the posterior attains the linear-smoother rate n^{−5/6}; the mode attains n^{−6/7}", paired with the lower-bound remark.
4. **Fast-rate class:** state one remark that s knots give no gain. Do not state a theorem.
5. **b₀:** target b₀ = bₙ ↓ 0, as Felipe prefers, but recompute the exponent. By the memo's own fixed-point formula, λ ≍ n^{5/2} needs b₀ ≍ n^{−7/3}. The self-tuning heuristic relied on the old bias law and must be redone.
6. **Smaller points:**
   - Keep V* explicit and allow slow growth.
   - State the uniform version, also uniform over λ in the window, so Stage B can plug in.
   - Fix c before finalizing, and use either the polylog or Mₙ, not both.
   - Yes, raise the lower window to what L10 gives.

## 6. Suggested revision
> **Theorem A.** Let y₁,…,yₙ be independent with (A2), and TV⁽³⁾(θ*) ≤ V. Fix any σ > 0. For n^{a₀} ≤ λ ≤ n³/(V^{3/2}(log n)^{C₀}) set
> ε²(λ) = (log n)^c · [ λ^{−1/3} + min{ λV n⁻³, V² λ^{5/3} n⁻⁵ } ].
> Then for M large, sup over the class and over λ in the window of E₀Πₙ,λ(Δ²ₙ(θ − θ*) > M ε²(λ) | y) → 0. Constants depend on (τ, σ, L, f, f̄) only.
> **Cor. A1.** λ ≍ n^{5/2}/V gives V^{1/3} n^{−5/6}, the linear-smoother rate.
> **Cor. A2.** λσ ≍ n^{15/7} gives n^{−5/7}.
> **Conjecture (lower bound).** Πₙ(Δ²ₙ < c λ^{−1/3} | y) → 0.

Here a₀ is whatever L10 delivers (my guess is 3/2). If the improved shift lemma fails, the min reverts to λVn⁻³ and the draft's n^{−3/4} stands as a valid but unsharp bound.
