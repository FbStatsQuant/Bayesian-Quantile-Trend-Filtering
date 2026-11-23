# Task B-lowerbound: the posterior is not faster than its spread λ^{−1/3} (short note; task interrupted)

*Fable, research sub-agent for Theory, 2026-11-23. Written in compressed form because the task was pre-empted. By hand, no compute, **not audited**. Proofs are given as complete skeletons with constants; they should be expanded and audited before use.*

**Two-line status.** The conjecture holds: at any fixed σ and deterministic λ, E₀Π(Δ²ₙ(θ − θ\*) ≤ c₀λ^{−1/3} | y) → 0, for quadratic truths and for general truths up to the oracle (λ ≲ n^{5/2}/V); the route is a Castillo-type prior-mass argument, not anti-concentration of the posterior. Two new lemmas do the work: a small-ball **upper** bound valid at every centre (L3⁻) and a **log-free** version of L3 (L3⁺).

## Lemma L3⁻ (small-ball upper bound, any centre) — PROVED (skeleton below)

For every θ₀ ∈ ℝⁿ, λ > 0 and r > 0 with rλ ≥ 1/804 and 117(rλ)^{2/5} ≤ n, and with x := n^{5/2}/(λr):

- ℓ₂ form: Π_λ{u : ∃c, ‖Nc + Su − θ₀‖ₙ ≤ r} ≤ exp(−x^{2/5}/117).
- Huber form, if also r² ≤ λ^{−1/3}/168: Π_λ{u : ∃c, H(Nc + Su − θ₀) ≤ nr²} ≤ exp(−x^{2/5}/465), H(δ) = Σmin(δᵢ², |δᵢ|).

*Proof skeleton.*
1. Blocks I_k := {(k−1)4h + 1, …, 4kh}, k ≤ K := ⌊n/(4h)⌋ ≥ n/(8h). Let (Δ_h³θ)(i) := θ_{i+3h} − 3θ_{i+2h} + 3θ_{i+h} − θ_i and L_k(θ) := h⁻¹Σ_{s<h}(Δ_h³θ)((k−1)4h + 1 + s).
2. L_k kills quadratics. By Cauchy–Schwarz (1 + 9 + 9 + 1 = 20) and because the indices i_k + s + ph (s < h, p < 4) enumerate I_k once: L_k(θ)² ≤ (20/h)Σ_{i∈I_k}θᵢ².
3. Δ_h³ = (1 + E + … + E^{h−1})³Δ₁³ and Δ₁³θ = Dθ = u, so L_k(Nc + Su) = Σ_l w(l)u_{i_k+l}, w = h⁻¹·1_h^{∗4} ≥ 0 on {0, …, 4h − 4}, Σw = h³, hence ‖w‖₂² ≥ h⁶/(4h − 3) ≥ h⁵/4. The u-blocks are disjoint, so the L_k are **independent** under Π_λ.
4. L_k is symmetric log-concave with variance ≥ h⁵/(2λ²). A symmetric log-concave density g satisfies g(0) ≤ 1/(√2·sd) (single crossing against the Laplace density with the same value at 0). So each L_k has density ≤ λ/h^{5/2}, at every point, and so does any translate.
5. ‖δ‖ₙ ≤ r gives Σ_k(L_k(Su) − L_k(θ₀))² ≤ 20nr²/h. Volume of the K-ball times the density bound: probability ≤ (√(2πe/K)·√(20n/h)·rλ/h^{5/2})^K ≤ (52.3·rλ/h^{5/2})^K. Take h := ⌈(142.2·rλ)^{2/5}⌉ ≤ 14.6(rλ)^{2/5}: probability ≤ e^{−K} ≤ exp(−n(rλ)^{−2/5}/117).
6. Huber form: at most nr² indices have |δᵢ| > 1, so at most nr² ≤ K/2 blocks are spoiled (this is r²h ≤ 1/16). Union over the ≤ 2^K choices of ⌈K/2⌉ clean blocks, same volume bound, h := ⌈(803.8·rλ)^{2/5}⌉. ∎

No singular values, no Anderson, no logarithm. The bound is uniform in the centre, so **the truth need not be quadratic**.

## Lemma L3⁺ (L3 without the logarithm) — PROVED (skeleton below)

For n ≥ 4, λ > 0, r > 0: **φ(r) ≤ 75·x^{2/5} + 5**, x = n^{5/2}/(λr). Together with L3⁻: x^{2/5}/117 ≤ φ(r) ≤ 75x^{2/5} + 5.

*Proof skeleton.* Condition on the mixing variances V (L3 Step 1): Au | V ~ N(0, Σ_V), Σ_V = MMᵀ, M = A·diag(V)^{1/2}, eigenvalues μ₁ ≥ μ₂ ≥ …. For the spline projector P_J of Lemma F, P_JM has rank ≤ J, so by Weyl Σ_{r>J}μ_r ≤ ‖(I − P_J)M‖²_F = n⁻¹ΣⱼVⱼ‖(I − P_J)sⱼ‖₂² ≤ C_F²n⁴J^{−5}·ΣⱼVⱼ. **The uniform column bound of Lemma F turns max Vⱼ into ΣVⱼ**, which needs no logarithm: on {ΣVⱼ ≤ 4m/λ²} (probability ≥ ½ by Markov) the tail sums are ≤ b₁J^{−5}, b₁ = 4C_F²n⁵/λ², for every J. With J = ⌊r/2⌋: μ_r ≤ 486·b₁·r^{−6} (and μ₁ ≤ tr Σ_V ≤ n⁵/(5λ²)). L3 Step 6 with b = 486b₁ gives −log P ≤ log(4/3) + 3.85K, K ≤ 1 + 19.3·x^{2/5}. ∎

## Theorem LB — PROVED given L6 (and L4/L4q-M for V > 0)

Assume (A1) and upper (A2) (only for L6's C₁). No lower margin, no (EM), no moments. Fix ω > 0, λ deterministic with λ → ∞ and D := nλ^{−1/3} → ∞.

- **Numerator.** mᵢ ≥ 0 (θ\*ᵢ is a τ-quantile) and Hoeffding's lemma (Xᵢ(δ) lies in an interval of length |δ|) give E e^{−ωXᵢ(δ)} ≤ exp(c_ω·min(δ², |δ|)), c_ω = max(ω²/8, ω). So E₀N(ℋ_r) ≤ e^{c_ω nr²}·ν(ℋ_r) ≤ e^{c_ω nr²}·V₃max(√n r, nr²)³·exp(−x_r^{2/5}/465), ℋ_r = {H(δ) ≤ nr²}.
- **Denominator.** L6 at radius ε_d with centre u_h: N(ℝⁿ) ≥ V₃(ε_d√n/2)³·Π_λ(u_h + B_{ε_d/2})·e^{−ω(1.44C₁+1)nε_d²} with probability ≥ 1 − 1.44/(nε_d²).
- **Combine** with r² = cλ^{−1/3} and ε_d² = λ^{−1/3}: the exponent is −D·[c^{−1/5}/465 − c_ω c − 99 − ω(1.44C₁ + 1) − (shift)/D] + 5.
  - V = 0 (quadratic truth): shift = 0. So for c₀ := min{1/168, [930(100 + ω(1.44C₁ + 1) + c_ω)]^{−5}}: **E₀Π(Δ²ₙ(θ − θ\*) ≤ c₀λ^{−1/3} | y) → 0** for every λ → ∞ with λ = o(n³).
  - V > 0: shift/D ≤ Vλ^{4/3}/n³ (L4) or ≤ C(Vλ/n^{5/2})^{12/5} (L4q + L4q-M, under their hypotheses). So the same conclusion holds for λ ≤ a₂n^{5/2}/V, with c₀ depending also on a₂. In particular at the oracle: lower bound c₀V^{1/3}n^{−5/6}, against the upper bound MV^{1/3}n^{−5/6}(log n)^{1/6}.
- Uniform in ω on compacts (two endpoints; L6's event is ω-free), hence also for σ learned (Lemma S §2 or Theorem C\*'s interval).

## Gaps and remarks — SKETCH

- **Constants are crude** (c₀ ≈ 10^{−25}). For ω ≤ 1 the ℓ₂ form with optimized ε_d gives c₀ ∝ ω^{−5/6}, which reproduces the memo's spread law κ^{−5/6}λ^{−1/3}; for large ω the tilt term c_ω c forces c₀ ∝ ω^{−5/3}.
- **Upper side logarithm.** L3⁺ removes (log n)^{1/6} from Theorem B (substitute it in join J5; exponent c = 0 becomes admissible). For the any-σ theorems the log also enters C2's fine term; bounding Σtⱼ² by Markov instead of m·t_∞² gives rate M_n·λ^{−1/3} for every M_n → ∞. Not written.
- **Learned λ.** The lower bound is false in general under λ-mixing (for a quadratic truth, large λ concentrates the prior at the truth). It holds on {λ ≤ λ_max}: Π(Δ²ₙ ≤ cλ_max^{−1/3}, λ ≤ λ_max | y) → 0. For V0T with **constant** b₀, the prior tail e^{−b₀(λ−Λ₋)} beats the e^{O(n log n)} of Lemma S's flat bound, so the posterior of λ sits within O(n log n) of the floor and the lower bound c₀Λ₋^{−1/3} follows (with (log n)^{−5/6} unless L3⁺ is substituted in V2T Step 3). Not written out.
- **Above the oracle** (bias-dominated λ): not covered; the denominator cost exceeds D.
- **The two proposed routes** (posterior anti-concentration along singular directions; Gaussian twin) are not needed.
- **Check suggested (UNTESTED):** verify numerically that −log Π_λ(B_r)/x^{2/5} stays in a bounded band without log growth (T-03 found slope 0.404), and the block-functional identity L_k(Su) = Σw(l)u_{i_k+l}.
