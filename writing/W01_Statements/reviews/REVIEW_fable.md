# Review of W-01b (`statements.pdf`, commit b76ec6f): referee readiness

*Fable (VP mathematical reviewer), 2026-11-23. Read-only review; this file is the only thing written.*

**Verdict.** The document is accurate about what is proved and honest about scope. Its weak point is the one Felipe named: as written, no theorem covers any simulation in the paper. Most of that gap can be closed with what is already proved. Four short corollaries of Theorem B (called **B⁺** below) would cover a fully Bayesian sampler with a learned λ and a σ prior restricted to the calibrated range, and would make the assumptions checkable for all three of the paper's noise families. The remaining gap, the default σ ~ IG(0.1, 0.1) that learns σ₀, cannot be closed by any expectation-based argument, for a structural reason given in §(iv).

**What I checked.**
- Read `statements.tex`, `STATEMENT_DRAFT.md` v3.1, `THEOREM_B_COMPLETE.md`, `L6_evidence_lower_bound.md`, `B_light_tail.md` (remarks), the paper's `methodology.tex`, `simulations.tex` and appendix hyperparameter text, E-02 `REPORT.md`, E-06 `DESIGN.md`.
- Recomputed Table 4 independently and extended it to τ = 0.90–0.99 (same definitions as `simulation_laws.R`).
- Computed the (EM) critical scale for the three simulation families from the exact MGF identity L8′(a): 240-point δ grid on ±[10⁻³, 30], bisection in σ, u = 0, 0.1, …, 1. One R process via `owls_run -j 1`.
- Every derivation marked CONFIRMED below is written out so that Theory can re-derive it under Felipe's verify rule. None of them has had an advisor check.
- Literature pointers are from memory; verify each before citing.

---

## (i) Top 10 referee questions

| # | Question | Answer or fix |
|---|---|---|
| 1 | **"Your theorem does not describe your method: you learn σ, and your own Table 4 says the learned σ violates (A4)."** | True today, and structural (§(iv)): for log-concave noise σ₀ ≤ σ̄ always. Fix: prove B⁺, which covers any σ prior supported on [σ_lo, σ_hi] with σ_lo > σ̄, including a truncated IG inside the Gibbs sampler. Present 1/σ as a learning rate and σ > σ̄ as the calibration condition. Scope the untruncated default honestly, with E-06's two σ arms as evidence. |
| 2 | **"λ is fixed at n^{5/2}/V, which depends on the unknown V; the paper learns λ with a hand-set b₀ that ranges from 5×10⁻⁴ to 10 to √G across experiments."** | Under (EM), a learned λ needs only hyperprior mass on the oracle window (finding F4). Gamma(a₀, c·n^{−5/2}) gives the oracle rate n^{−5/6} with V unknown. The paper's fixed b₀ gives a provable but slow n^{−1/4}. At n = 500 nothing in the paper changes: c = b₀·500^{5/2} reproduces each run. |
| 3 | **"Do your assumptions hold in your own simulations?"** | (A1)–(A3): yes, shown. (A4)/(EM): hold exactly when σ > σ̄ = τ(1−τ)/f_min, by the log-concave proposition (F2), for all three families and every τ. They fail at the learned σ by the factor R in Table 4. Extend Table 4 to the extreme levels (R reaches 14–21 at τ = 0.99; table in §(ii)). |
| 4 | **"(EM) is an opaque condition on the law and σ jointly. How would I check it?"** | Replace it in the headline statement by: errors have log-concave densities with f_i(q_i) ≥ f, and σ > τ(1−τ)/f. That implies (EM) through Proposition 1 (F2). Keep (EM) as the general condition in a remark. |
| 5 | **"Your posterior contracts at n^{−5/6}, slower than the estimator it is built on (n^{−6/7}). Proof artefact, or is the Bayesian method really worse?"** | Real, and say so. A single-scale Laplace prior behaves like a Gaussian one (E-02 twin ratios 0.98–1.05), so the posterior is a linear smoother in rate; E-02 shows the MAP beating the posterior (slopes −0.90 vs −0.69 at a = 15/7). Cite the Bayesian-lasso precedent (Castillo, Schmidt-Hieber and van der Vaart 2015, the Laplace-prior result). The mode keeps the n^{−6/7} rate at any σ, since it depends on λσ only. The lower bound stays a labelled conjecture. |
| 6 | **"What is the frequentist coverage of your credible bands?"** | Not claimed, correctly. But the paper already reports under-coverage at the outer levels, and the σ gap predicts it: in unpenalised directions posterior sd ÷ sampling sd = √(σ₀/σ̄) = 0.79 down to 0.39 across Table 4 (0.22 at τ = 0.99). The calibrated σ of answer 1 is the standard remedy (Yang, Wang and He 2016; Syring and Martin 2019). This turns the σ restriction from a weakness into a selling point. |
| 7 | **"The theorem is in Δₙ; you report MSE of the posterior mean."** | Theorem B already implies squared-loss contraction at n^{−2/3}(log n)^{1/3} (F7; three lines). Theorem A would give the full rate in ‖·‖ₙ. A posterior-mean corollary is plausible (F8). State both; drop "a squared-loss version is not claimed". |
| 8 | **"Section 4.2 fits τ up to 0.99 jointly with a non-crossing constraint. Does any theory apply?"** | No, and the document is silent on it. The joint target is a composite posterior restricted to an ordered cone; every result here is single-level, fixed τ. Add a scope sentence. A corollary needs separated true quantiles and sup-norm localization (Theorem A's open step), so it is not available from B. At τ = 0.99 and n = 500 there are five observations above the curve; no fixed-τ asymptotic statement is informative there. |
| 9 | **"The prior is improper on polynomials and you integrate over λ and σ. Is the posterior proper?"** | Regime (i) is proved. Regime (iv), the method as run, is proper iff b_σ > 0 and b₀ > 0 (F9, short proof). The paper's settings satisfy both. Add one line to §1. |
| 10 | **"Heavy tails and heteroscedasticity: what exactly do you claim?"** | Heavy tails: B excludes them; A is open; HQ's decision D6 stands (conjecture, supported by the t₂ and Cauchy arms). Heteroscedasticity: allowed, but one σ must clear the worst location. For Beta noise most of the gap is this effect: the local ratio σ̄(u)/σ₀(u) is only 1.1–2.0 at τ = 0.05, against R = 5.5 for the pooled σ. Say this next to Table 4. |

---

## (ii) Per-assumption verdict

| Assumption | Explained? | Holds for the paper's simulations (VS/S, three noises, n = 500)? | Holds for E-02 / E-06? | Fix |
|---|---|---|---|---|
| **(A1)** independence, grid i/n | Yes. | Yes, by construction. | Yes. | None for simulations. Data applications: see the note below. |
| **(A2)** two-sided margin | Yes; the secant-versus-point-density remark and the Beta edge distances are the right caveats. | Yes at every τ, uniformly in u (continuous, bounded densities; f̄ ≤ 11 for Beta). | Yes. E-06's σ = 1.1σ̄ arm leaves only 9% slack, so (A4) with the secant f needs a small L; say so. | Print one (L, f, f̄) triple per family, so the claim is a checked statement rather than an argument. |
| **(A3)** TV₂(θ\*) ≤ V | Yes; Table 5 is adequate. | Yes: V ≈ 7280 (VS), ≈ 157 (S; 142–179 with Beta). | Yes: V = 0, 26, 157. | Add one sentence on n₀(V) (F10): with the proved constants the primary n^{−5/6} bound starts near n ≈ 10⁶ (S) and 10⁸ (VS); only the fallback bound B-ii is in force at the paper's n. |
| **(A4)** σ ≥ σ̄/(1−η) | Partly. The sandwich sentence is correct but reads as a proof device. | **No at the learned σ.** I reproduced Table 4 to three digits: R = 1.59–6.70. At the extreme levels it is worse (below). Yes for any σ > σ̄. | E-02: no (all Gaussian arms at σ₀); the Cauchy arm satisfies it (σ = 2.5σ̄). E-06: yes in the Abar arm, no in the S0 arm, by design. | Recast as the calibration / learning-rate condition (§(iv)). Add the structural fact F2. Extend Table 4 to τ ≤ 0.99. |
| **(EM)** | Weakly. The "expected likelihood ratio" sentence is accurate, but a referee cannot check it, and Proposition 2's threshold is far above σ̄. | **Yes iff σ > σ̄**, for all three families (all are log-concave). Numerically the critical scale is 0.9985–0.9998 × σ̄(u) at every u and τ tested, i.e. equal within grid error. So no at the learned σ. | E-06 Abar, Gaussian and Laplace: yes, and F2 turns Theory's grid check into a proof. t₃, t₂, Cauchy: no (tails). | Add the log-concave proposition (F2). Do not print the HQ ratios as a separate column: the exact value is R of Table 4 (F1). |
| **(M)** (Target 3 only) | Yes. | Yes for all three families. | Fails for Cauchy, as stated. | None. |

**Table 4 extended to the joint-sampler levels** (same conventions; R = σ̄/σ₀, worst case over u):

| τ | 0.90 | 0.93 | 0.96 | 0.97 | 0.98 | 0.99 |
|---|---|---|---|---|---|---|
| Gaussian | 4.38 | 5.42 | 7.76 | 9.43 | 12.5 | 20.9 |
| Beta | 4.85 | 5.60 | 7.35 | 8.61 | 10.9 | 17.1 |
| Mixed normal | 2.96 | 3.66 | 5.24 | 6.37 | 8.48 | 14.1 |

**Data applications (deferred; not evaluated).** They would need: a position on serial dependence in the sensor series (A1); a treatment of replicated design points for the growth data (about twenty children per slot); a check of (A2) against rounding and detection limits; and an account of λ ~ Gamma(1, 10), which the paper itself says pins λ near m/10, so λ is set, not learned, there.

---

## (iii) Contraction definition

**Recommendation: state every theorem in the uniform sup-E form, and keep the Ghosal–van der Vaart wording only as the definition of the word "contracts".** That is the arrangement W-01b already has; I would keep it and make three edits.

Reasons for the sup-E form as the primary statement:
1. It is what the proof bounds, and it is the stronger statement. The equivalence remark in the document is correct (bounded variables; near-maximizing sequences).
2. The textbook pointwise form is not available here. The truth θ\* ∈ ℝⁿ is a triangular array, so "a fixed P₀" is already a sequence of laws. A referee who knows the textbook definition will ask what is held fixed; the uniform form answers that.
3. The extensions in B⁺ need it. Uniformity over σ and a hyperprior on λ are both obtained by bounding a supremum inside the expectation.

Edits:
- Say in the Definition that it is stated for sequences because the truth changes with n, and that M is a fixed constant (stronger than the textbook's "every Mₙ → ∞").
- Put the finite-sample bound in Theorem B. The proof gives E_P Πₙ(Δₙ² > Mεₙ² | y) ≤ 1.44/(nεₙ²) + C₃(b/σ)·V₃⁻¹·(2/(εₙ√n))³·exp{−c·nεₙ²}. The first term dominates, so the convergence is polynomial, of order n^{−1/6}. A referee will otherwise assume it is exponential.
- Give the textbook reference for the definition (Ghosal and van der Vaart 2017, the contraction-rate definition in Ch. 8; check the number).

---

## (iv) The treatment of σ

### Why no cheap theorem covers the default

**CONFIRMED (F2, derivation below).** If the error density is log-concave, then σ₀ ≤ σ̄ (point density), with equality only when the error is itself asymmetric Laplace. So for Gaussian, Laplace, uniform, logistic, Beta(1, β ≥ 1) and the paper's mixed normal, the learned scale is always at or below the threshold. This is not an accident of the designs in Table 4.

The same computation shows what the threshold means. For a correctly specified ALD, E exp{−X(δ)/σ} equals 1 at σ = σ₀ and is below 1 only for σ > σ₀. So (EM) is the fractional-posterior condition "power α = σ₀/σ < 1" of Bhattacharya, Pati and Yang (2019), and (A4) is the "learning rate below critical" condition of the Gibbs-posterior literature. Any proof that takes the expectation of the numerator needs it. A theorem at the learned σ₀ must control the realized numerator with entropy or tests. That is A⁺, and it is a different and harder proof, not a refinement of A or B.

### What is available now: B⁺

Four corollaries of the audited Theorem B chain. Each is a few lines; none has been advisor-checked.

1. **Log-concave ⇒ (EM) for every σ > σ̄** (F2).
2. **Uniformity in σ** (F3). The supremum over σ ∈ [σ_lo, σ_hi] can be taken inside the expectation. So the theorem covers a data-driven σ̂ that lands in the interval with probability → 1, and any prior on σ supported there, including a truncated IG updated inside the Gibbs sampler.
3. **Learned λ by hyperprior mass** (F4).
4. **Squared loss at n^{−2/3}** (F7).

Together:

> **Theorem B⁺ (proposed).** Assume (A1), (A3), and that each εᵢ has a log-concave density fᵢ with fᵢ(0) ≥ f and sup fᵢ ≤ f̄. Let σ_lo > τ(1−τ)/f and σ_hi < ∞. Let σ have any prior supported on [σ_lo, σ_hi], and λ ~ πₙ with πₙ([a₁, a₂]·n^{5/2}/V) ≥ exp(−c₁nεₙ²), for example Gamma(a₀, c·n^{−5/2}). Then the θ-marginal of the joint posterior satisfies sup_P E_P Πₙ(Δₙ² > Mεₙ² | y) → 0 with εₙ² = C(log n)^{1/6}V^{1/3}n^{−5/6}.

This is a theorem about a fully Bayesian Gibbs sampler in (θ, λ, σ). It differs from the method as run in two settings: the lower truncation of σ, and the n-scaling of b₀.

An honest caveat goes with it. Because σ₀ < σ_lo, the truncated posterior of σ sits at σ_lo, within O(1/n). The scale is in effect fixed by the rule. The paper should say so; a referee will see it anyway.

### Options

| Option | What the theorem then covers | Change to the method or the paper | Proof by Tuesday 24 Nov | Referee risk |
|---|---|---|---|---|
| **(a)** A⁺ for any fixed σ | Fixed σ = σ₀ runs (the S0 arms). Not the learned σ: that needs Target 3 on top. | None. | **≤ 5%.** Two lemmas are missing: L10 Stage 1 (parked) and L8-b (not started). Advisor odds were 40% with no deadline. | Low if proved. As the only plan, high: no theorem at σ₀ and nothing else to show. |
| **(b)** σ fixed by a rule, σ̂ = (1+η)τ(1−τ)/f̂ | B⁺ with light tails; A when proved. A data-driven σ̂ is covered by corollary 2 if it lands above σ̄. | σ is no longer learned. A sparsity estimate is needed (worst case over locations). Simulation tables re-run; b₀ recalibrated. | **About 85%** for B⁺ (corollaries of an audited proof). | Low to medium. "Why not learn σ?" has a standard answer: 1/σ is a learning rate, and σ ≥ σ̄ is the calibration condition. |
| **(c)** prior on σ kept above the threshold (truncated IG on [σ_lo, σ_hi]) | Same as (b), with the sampler still fully Bayesian. | One line in the σ update. Otherwise as (b). | Same as (b). | Medium. The posterior of σ is pinned at σ_lo; say so, or the referee will. |
| **(d)** honest scoping, simulations at σ₀ | No run in the paper. | None; E-06 as designed. | No proof needed. | High alone: Tables 3–4 concede the point in print. Medium with E-06's paired σ arms. |
| **(e1)** sandwich adjustment after sampling (Yang, Wang and He 2016) | Nothing new; it repairs intervals, not contraction. | A post-processing step. | n/a | Does not answer question 1. Useful only for question 6. |
| **(e2)** sparsity from adjacent levels of the joint sampler: σ_j ∝ τ_j(1−τ_j)·(θ_{j+1} − θ_{j−1})/(τ_{j+1} − τ_{j−1}) | Potentially (b) with a built-in, location-aware f̂. | New methodology. | No. | A direction for a revision, not for Tuesday. |

### Recommendation

**Adopt (c), stated so that it contains (b), together with (d) for the default. Do not make Tuesday depend on (a).**

1. **Theory, by Tuesday:** write and check B⁺ (the four corollaries). This replaces A⁺ as the near-term deliverable. A⁺ stays as the stated conjecture that the restriction σ > σ̄ is not needed for the rate.
2. **Paper, method section:** describe 1/σ as the learning rate of a Gibbs posterior. Offer the calibrated prior, σ ~ IG restricted to [σ_lo, σ_hi] with σ_lo = (1+η)τ(1−τ)/f̂, as the theorem-covered version. Any upper bound on the sparsity is safe: an over-large σ_lo costs only constants, since the rate carries (σ/f)^{5/6}.
3. **Paper, scope:** keep the untruncated IG default and the existing tables. State that its learned σ₀ lies below σ̄ for every log-concave law, that B⁺ therefore does not cover it, and that E-06 shows the same slopes in both σ arms.
4. **Engineering:** one added table, the paper's 30 interior configurations at the calibrated σ with coverage reported, next to the default. E-06 is already the right rate experiment.
5. **Decision for Felipe (new):** whether the calibrated σ becomes the default in a later revision. I would decide after seeing item 4.

Why this and not a change of default now:
- Changing σ changes the results. At a fixed MAP penalty the bands widen by about R^{7/12}, i.e. 1.3× to 3× (PLAUSIBLE, from the spread law). At a fixed b₀ the MAP penalty λσ also rises, by about R^{7/8}, so b₀ would need rescaling by about R^{7/6} to hold the fit. None of this can be measured by Tuesday.
- The calibrated version has merit of its own, which is what makes it defensible. The paper's discussion already concedes under-coverage at the outer levels; that is where R is largest. And in the A⁺ rate formula the factor (σ/f)^{5/6}(1 ∨ σ̄/σ) is smallest at σ = σ̄, so the conjectured bound itself prefers the calibrated scale (PLAUSIBLE; the document notes the factor is likely conservative).

**What a referee can still say after this:** "your default prior is outside the theorem." The reply is then one sentence with a table behind it, instead of a concession covering every experiment.

---

## (v) Other findings

**F1. CONFIRMED (numerical). Table 4 is right; the HQ (EM) ratios are slightly off.**
My recomputation matches Table 4 in every cell. The (EM) critical scale equals σ̄(u) at every u tested (ratio 0.9985–0.9998), so the exact value of "smallest σ satisfying (EM) ÷ σ₀" is R of Table 4. The HQ figures differ from it by more than the stated ±2% in three places: Beta τ = 0.75 (3.71 against 3.96), mixed normal τ = 0.05/0.95 (4.72 against 4.53), mixed normal τ = 0.25/0.75 (1.94 against 1.88). The Beta cell is a u-grid effect: the minimum of f is at u = 0.96, and a grid in steps of 0.1 gives 3.73. Use Table 4's column and F2; do not print a second set.

**F2. CONFIRMED (derivation). Log-concave errors: σ₀ ≤ σ̄, and (EM) holds for every σ > σ̄.**
Let Z have a log-concave density g with τ-quantile 0. The hazard g/(1−G) is nondecreasing, so P(Z > t) ≤ (1−τ)exp{−g(0)t/(1−τ)} for t ≥ 0. The reversed hazard g/G is nonincreasing, so P(Z < −t) ≤ τ·exp{−g(0)t/τ}.
- Integrating: E Z⁺ ≤ (1−τ)²/g(0) and E Z⁻ ≤ τ²/g(0), so σ₀ = τE Z⁺ + (1−τ)E Z⁻ ≤ τ(1−τ)/g(0) = σ̄. Equality forces constant hazards on both sides, i.e. the ALD.
- These are the envelopes of Proposition 1 with β₊ = g(0)/(1−τ) and β₋ = g(0)/τ. Its conditions β₊ > τ/σ and β₋ > (1−τ)/σ both read σ > τ(1−τ)/g(0). With fᵢ(0) ≥ f the same envelopes hold with f in place of g(0), so b is common to the class.
- The paper's families: Gaussian; Beta(1, β) with β ∈ [1, 11] (density β(1−x)^{β−1} on [0, 1]); the mixed normal (equal variances 0.5, half-separation 0.2 ≤ sd 0.707, which is the log-concavity condition for a two-component equal-variance mixture; checked numerically as well). All three are log-concave.
- Consequence for E-06: the claim "Gaussian and Laplace at 1.1σ̄ are covered by Theorem B" currently rests on a grid check that the package says is not a premise. This proposition proves it.

**F3. CONFIRMED (derivation). (EM) is monotone in σ, and Theorem B is uniform in σ on compacts.**
- Monotone: for σ′ ≥ σ, E e^{−X/σ′} = E[(e^{−X/σ})^{σ/σ′}] ≤ (E e^{−X/σ})^{σ/σ′} by Jensen. So (EM) at σ gives (EM) at σ′ with the same b. "Smallest σ satisfying (EM)" is therefore well defined.
- Numerator: for each θ, ω ↦ e^{−ωℛ(θ)} is monotone, so sup over ω ∈ [ω_lo, ω_hi] of N_ω(E) ≤ N_{ω_lo}(E) + N_{ω_hi}(E). The prior does not depend on σ.
- Denominator: L6's event {∫ℛ dν_G ≤ (1.44C₁ + 1)nε²} does not involve ω, so on it N_ω(ℝⁿ) ≥ ν(G)exp{−ω_hi(1.44C₁ + 1)nε²} for all ω at once.
- Result: E sup_σ Π_σ(Δₙ² > Mε² | y) → 0 for M > (2/b)[(σ_hi/σ_lo)(1.44C₁ + 1) + σ_hi·C_pr]. Splitting the interval into pieces of ratio 2 replaces σ_hi/σ_lo by 2.
- A posterior on σ supported in [σ_lo, σ_hi] gives a θ-marginal that is a mixture of the Π_σ, hence bounded by the supremum.

**F4. CONFIRMED (derivation); it contradicts Target 2 and Decision D2 as written. Under (EM), learned λ needs only hyperprior mass, and the rate is n^{−5/6}.**
- Step 2 of Theorem B uses only that the prior on u = Dθ is a probability measure. A mixture ∫Π_λ πₙ(dλ) is one. L6 holds for any product prior dc ⊗ Π. So the only change is ν(G): the mixture gives Π(u_h + B_{ε/2}) ≥ πₙ(W)·inf_{λ∈W} Π_λ(u_h + B_{ε/2}) ≥ πₙ(W)e^{−C_pr nε²}, with W = [a₁, a₂]·n^{5/2}/V. The centre u_h does not depend on λ.
- So contraction at the oracle rate holds whenever −log πₙ(W) ≤ c₁nεₙ², with C_pr replaced by C_pr + c₁. No contraction of the hyperposterior is needed. The document's sentence "uniform bounds for deterministic λ cannot simply be plugged in" is true but beside the point under (EM).
- Gamma(a₀, c·n^{−5/2}): the rate times the window is c/V, so πₙ(W) is bounded below for every V. V need not be known. (β = 7/3 is the boundary; β = 2 gives only the fallback rate n^{−3/4}, which is consistent with E-02's quad slope 2.26.)
- A polynomial-tailed prior (H2) also passes: −log πₙ(W) = O(log n).
- The paper's fixed b₀: the same argument with the fallback route (L3 and L4 hold for every λ) at λ ≍ (n/b₀)^{3/4} gives a proved upper bound ε² ≍ (b₀/n)^{1/4}(log n)^{1/6}. The n^{−1/4} in the document becomes a theorem about the prior the paper uses, not a heuristic. This needs B-ii stated for general λ, ε²(λ) = C[(log n)^{1/6}λ^{−1/3} + λVn^{−3}], which the existing lemmas give.
- Changes to the document: Target 2 (version 2B) should target n^{−5/6} with b₀,ₙ ∝ n^{−5/2} or (H2); D1 and D2 should be rewritten accordingly. This was flagged as an unchecked remark in `B_light_tail.md` and in my light-tail opinion; it is now derived.

**F5. PLAUSIBLE. The premise "kinked truths self-tune to n^{9/4}" needs a second look.**
F4 does not depend on where the hyperposterior of λ sits. But F4 together with the spread law says it cannot stay at n^{9/4} asymptotically when the hyperprior allows n^{5/2}/V. The n^{9/4} fixed point comes from charging the signal its ℓ₁ norm V/n²; E-02's own bias law rejects ℓ₁ accounting, and the quadratic charge puts the fixed point at n^{5/2}/V. The evidence for n^{9/4} is one slope (2.14 [2.02, 2.27], n ≤ 8k, at σ₀, outside (EM)). At these n the two rates differ by (n/V)^{1/12} ≤ 1.6, so there is no finite-sample conflict. Theory should reconcile before the paper says anything about kinked truths.

**F6. CONFIRMED (arithmetic on reported numbers). At n = 500 the paper's learned λ is at the oracle order, not far below it.**
VS: n^{5/2}/V = 768 and (n³/V)^{3/4} = 1501; E-02 measured λ̄ ≈ 2.1×10³ on VS data at the paper's b₀ = 10⁻³. S: 3.6×10⁴ and 2.7×10⁴; the document's formula predicts about 1.5×10⁴ at b₀ = 5×10⁻⁴ (no measured value in the files I read). The paper's b₀ values were tuned at n = 500 and land near the oracle there. What is wrong is the scaling in n, not the reported runs. Two consequences: the "why not the paper's fixed b₀" paragraph should say this, and its formula does not apply to VS, where ‖Dθ\*‖₁ = V/n² = 0.029 is thirty times b₀ (the formula gives about 9×10³ against the measured 2.1×10³).

**F7. CONFIRMED (derivation). Theorem B gives squared-loss contraction at n^{−2/3}.**
Step 2 of the proof shows H(δ) ≥ min(‖δ‖₂², ‖δ‖₂). On {H ≤ Mnε²} with Mnε² ≥ 1 this gives ‖δ‖₂ ≤ Mnε², so ‖θ − θ\*‖ₙ² ≤ M²nεₙ⁴ = M²C²V^{2/3}(log n)^{1/3}n^{−2/3}. Not the right rate, but it is a squared-loss consistency statement at no cost.

**F8. PLAUSIBLE. A posterior-mean corollary at the same crude rate.**
On L6's event the numerator bound holds for every M at once (Markov over a dyadic grid of M), which gives an exponential posterior tail for H and hence E_post‖δ‖₂ ≲ nε² in probability. Then ‖θ̄ − θ\*‖ₙ² ≲ nε⁴. This is the statement that matches what the simulation tables report. Not written out.

**F9. CONFIRMED (derivation). Propriety of the method as run.**
The θ-marginal in regime (iv) is g(θ) = {b_σ + Q(θ)}^{−(n+a_σ)}{b₀ + ‖Dθ‖₁}^{−(a₀+m)}. It is bounded when b_σ, b₀ > 0. Since Q(θ) ≥ min(τ, 1−τ)(‖θ‖₁ − ‖y‖₁), in the (c, u) coordinates g ≤ C(1 + |c| + ‖u‖₁)^{−(n+a_σ)}(b₀ + ‖u‖₁)^{−(a₀+m)}. Integrating c over ℝ³ leaves (1 + t)^{3−n−a_σ} with t = ‖u‖₁, and the radial integral in u has exponent 2 − n − a_σ − a₀ at infinity, integrable for n ≥ 4. With b_σ = 0 the density is not integrable at θ = y; with b₀ = 0 not at Dθ = 0. Regime (ii) follows the same way.

**F10. PLAUSIBLE (back-of-envelope). n₀(V) is very large on the primary route.**
Condition (R1), λε ≥ 102·n^{10/7}(log m)^{1/7}, at λ = n^{5/2}/V and C = 1 needs n^{55/84} ≳ 114·V^{5/6}: n ≳ 10⁶ for S and 10⁸ for VS. The fallback route has no such condition. Nothing is wrong, but E-06's "proof coverage" line should not suggest that the proved n^{−5/6} bound is active at n ≤ 32k; there the experiment tests the rate, and the proved bound in force is B-ii.

**F11. PLAUSIBLE. Target 6 can state its exponent now.**
The same balance for order k (r = k+1) gives spread λ^{−1/r}, bias V²λ^{(2r−1)/r}n^{−(2r−1)}, oracle λ_{k,n} ≍ n^{k+1/2}/V and r_k = (2k+1)/(2k+2): n^{−1/2}, n^{−3/4}, n^{−5/6} for k = 0, 1, 2. This is the linear-smoother minimax rate for the order-k bounded-variation class, which fits the k = 2 positioning. A target with an undetermined exponent is not yet a statement.

**F12. CONFIRMED (reading). E-02 and E-06 against the assumptions.**
- E-02: every Gaussian arm runs at σ₀ (R = 1.57 at τ = ½, 2.92 at τ = 0.9), so it lies outside A and B. The Cauchy arm has σ = 2.5σ̄ and lies inside A's assumptions, outside B's.
- E-06: the Abar arm is inside B for Gaussian and Laplace (by F2) and inside A's assumptions for t₃, t₂, Cauchy. The S0 arm is outside both, as the design says. The design is the right one for the recommendation in §(iv); its paired σ arms are exactly the evidence item 3 needs.

**F13. CONFIRMED (reading). Wording that would mislead a referee.**
- Target 1's plain-words line says A⁺ "covers the method's practice". It covers a fixed σ equal to σ₀; the learned σ needs Target 3 as well. The Target 3 remark says this; the Target 1 line should too.
- Section 1 lists regimes (ii)–(iv) without a propriety statement (F9).
- Nothing mentions the joint sampler (question 8).
