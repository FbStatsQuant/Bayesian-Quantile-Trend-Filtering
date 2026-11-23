# W-01c part 1: response to REVIEW_astra.md and REVIEW_fable.md

Writing checked each point before applying it. Ground truth: STATEMENT_DRAFT v3.1 and THEOREM_B_COMPLETE.
The σ section (Target 3, σ options) is **not changed**; it waits for Felipe's decision.
Numbers come from `simulation_laws.R` (rerun for this response, extended to τ = 0.90 … 0.99). None were copied from the reviews.

## Points both reviews agree on (HQ list)

| # | Point | Ruling | What changed |
|---|---|---|---|
| 1 | Uniform contraction definition; GvdV as the definition; triangular-sequence equivalence with the same M; squared scale | **Holds.** The truth θ* ∈ ℝⁿ changes with n, so laws form a triangular array. A fixed M is stronger than M_n → ∞. Picking near-maximisers P_n gives the equivalence. | Definition: "triangular sequence", fixed M vs M_n → ∞, rates quoted on the squared scale. Remark: equivalence "with the same M", with a one-line reason. |
| 1b | Finite-sample note (Fable) | **Holds.** Checked against THEOREM_B_COMPLETE §3 Step 4. The bound is 1.44/(nε²) plus an exponential term. The first term dominates, so convergence is polynomial (≈ n^{-1/6} up to logs), not exponential. | Finite-sample display added after Theorem B. |
| 2 | Scope: per-signal b₀ is hidden tuning; the joint six-level sampler is not covered | **Holds.** Paper: Gamma(1, 10⁻³) for VS, Gamma(1, 5×10⁻⁴) for S, default 10⁻². No result covers the joint posterior on the ordered cone. | Scope paragraph states both plainly. |
| 3 | Propriety iff b_σ > 0 and b₀ > 0 (Astra Q9, Fable F9) | **Holds.** Checked: integrate λ, then θ (∫e^{-Q/σ} = (σ/τ(1−τ))ⁿ), then σ. Necessity: non-integrable singularities at θ = y (b_σ = 0) and at {D^{(3)}θ = 0} (b₀ = 0). | Proposition (Propriety) and proof sketch after the regimes. Notes that propriety gives no rate. |
| 4 | Extend Table 4 to τ = 0.99 | **Holds.** Recomputed (n → ∞ convention): Gaussian 20.906, Beta 17.091, mixed 14.130. Astra's 20.89 is the n = 500 discrete value; same conclusion. | New Table 5 (joint-sampler levels 0.90–0.99) and the range sentence: "grows to about 21". |
| 5 | Log-concave ⇒ σ₀ ≤ σ̄, so the learned σ never meets (A4)/(EM) (Fable F2, first part) | **Holds.** Proof: tangent bounds on log F and log(1−F) at q; equality iff ALD. Heteroscedastic version via f_min. Mixed normal checked log-concave numerically for all u. | Proposition (Log-concave noise) with proof; consequence stated as a fact. "(EM) for every σ > σ̄" is **not** claimed (in the Pending box). |

## Other points

| Source | Point | Ruling | What changed |
|---|---|---|---|
| Astra Q1 | Table 1: B's σ column should not read "fixed, any" | Holds: B needs (EM). | "fixed, with (EM)". |
| Astra Q2 | Failing (A4)/(EM) at σ₀ is a proof limitation, not inconsistency | Holds. | One sentence in Scope. |
| Astra Q3 | Design ratios at τ = .99 | Holds (see #4). | Table 5. |
| Astra Q4, Fable Q8 | Ordered/joint extreme curves | Holds: nothing covers them. Astra's "ordered extension" proof idea is PLAUSIBLE only. | Scope sentence; no result added. |
| Astra Q5, A3 row | (A3) via an integral representation of D³ | Holds: Δ³g(uᵢ) = n⁻³∫M g''' with M the quadratic B-spline, so TV₂ ≤ ∫\|g'''\| ≤ sup\|g'''\| for every n. | (A3) paragraph: bound added. Table 6 caption: the unsupported "within 0.1% of the limit" was replaced by "values rise toward the limit". |
| Astra A3 row | V is an envelope (V > 0 even for a quadratic truth) | Holds. | One sentence. |
| Astra Q6, Fable F6 | At n = 500 the paper's b₀ gives λ of oracle order; the problem is the n-scaling | Holds: VS λ̄ ≈ 2.1×10³ (E-02) vs n^{5/2}/V ≈ 770 and (n³/V)^{3/4} ≈ 1500. The b₀-only formula ignores ‖D³θ*‖₁ = 0.029 ≫ 10⁻³. | Target 2 "fixed b₀" paragraph corrected. The λ ≈ 50–75 figure is labelled a pilot Gamma(1,1) configuration. |
| Astra Q7, Fable F12 | E-02 slopes are evidence, not proof; Gaussian arms run at σ₀ (outside A, B) | Holds. | Caveat in "Numerical support". |
| Astra Q8 | A's plain-words line reads as proved | Holds. | "If the open step closes: …". |
| Fable F13 | Target 1 "covers the method's practice" misleads | Holds: A⁺ covers fixed σ = σ₀; learned σ needs Target 3. | Plain-words line rewritten. |
| Fable Q5 | MAP beats posterior: say so | Partly holds. The E-02 evidence is real (slope −0.90 for the mode vs −0.69 for the posterior at λ = n^{15/7}). The lower bound is not proved. | Evidence added next to the conjecture; it stays a conjecture. |
| Fable Q10 | Beta gap is mostly the worst case over u | Holds: local ratio in [1.12, 2.00] at τ = 0.05 vs R = 5.49; > 1 everywhere. | One sentence after Table 4. |
| Fable F5 | "Kinked truths self-tune to n^{9/4}" is a premise, not a fact | Holds as a wording issue: it rests on one E-02 slope (2.14 [2.02, 2.27]). | Target 2 text softened to an observation; premise listed in the Pending box. |
| Astra (D1) | s_y from the data makes H1 empirical Bayes; d₁ carries units | Holds. | D1 note. |
| Fable F1 | HQ (EM) ratios slightly off | Not applicable: those ratios are not in this document. Table 4 confirmed. | None. |

## Deferred to Felipe's σ decision (not changed)

Astra "Options for σ" and Q10/(M) specifics; Astra "E-02 0.97–1.01 scale ratios"; Fable §(iv) options and recommendation (calibrated σ prior); Fable Q1, Q6 (coverage). Fable's per-family (A2) constants: correct and optional; deferred.

## Not applied as results; listed in the boxed "Pending Theory verification" note

Theory has not verified any of these. Writing did not try to verify them either.

- P1. Fable F2, second part: log-concave ⇒ (EM) for every σ > σ̄ (also Fable Q3, Q4).
- P2. Fable F3: uniformity in σ on compacts.
- P3. Fable F4: learned λ by hyperprior mass. If verified, Target 2B reaches n^{-5/6} and D1/D2 change (stated in D1).
- P4. Fable F7/F8: squared loss n^{-2/3}(log n)^{1/3} and the posterior-mean corollary.
- P5. Fable F11: Target 6 exponent r_k = (2k+1)/(2k+2).
- P6. Fable F5: the n^{9/4} self-tuning premise.
- P7. Fable F10: n₀(V) ≈ 10⁶ (S), 10⁸ (VS).

Not listed: Astra's "(EM) infimum exactly τ(1−τ)/d", a refinement of the necessity statement already in the document.
