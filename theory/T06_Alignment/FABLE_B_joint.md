# Task B-joint: does V0T\* (or C\*) transfer to the joint non-crossing posterior π_C?

*Fable, research sub-agent for Theory, 2026-11-23. Pure mathematics, by hand; no compute; **not audited**. Built on `FABLE_A_n56.md` (Theorems C\* and V0T\*, cross-audited), `L2` (statement), `L10-I`, and for the sketches `L3`, `L4q`, `L6`, `FABLE_lemmaF_C2.md`.*

**Notation.** The number of levels is written **q** (the symbol J is already the spline dimension in C2). Levels 0 < τ₁ < … < τ_q < 1; Δτ := min_j(τ_{j+1} − τ_j). θ\*ⱼ ∈ ℝⁿ is the vector of true τⱼ-quantiles, Θ = (θ₁, …, θ_q).

**Labels.** PROVED = every line is written here and rests only on audited statements. SKETCH = argument given, a step not written or a lemma missing. CONJECTURE = no argument.

## 0. Answer

**Yes, for fixed levels, and with no new condition.** Under the assumptions of V0T\* at each level:

1. The upper half of (A2) already forces the true quantile curves to be **uniformly separated**: θ\*_{i,j+1} − θ\*_{ij} ≥ g₀ := min(L, Δτ/f̄) > 0. They cannot touch. (§2.1, PROVED)
2. Given y, the unconstrained composite posterior is a **product measure** over levels, and π_C is that product conditioned on C. (§1, PROVED)
3. By the sup-norm conclusion of V0T\*, the product puts mass → 1 on C. So ‖Π_C − Π^⊗‖_TV = Π^⊗(Cᶜ | y) → 0, and every conclusion of V0T\* transfers to Π_C at the same rate n^{−5/6}(log n)^{1/6}, simultaneously for all levels. (§2, PROVED)

| Point raised | Outcome | Status |
|---|---|---|
| Truth in C; touching quantiles | Excluded by upper (A2): gap ≥ min(L, Δτ/f̄) | PROVED |
| Numerator across levels with shared data | No expectation of a product over levels is ever taken. Each level's bound is a realized bound on its own event; the events are combined by a union bound. No Hölder is needed | PROVED |
| Denominator inside C | Not needed under separation: Π^⊗(C \| y) → 1, so the constraint costs a factor ≤ 2, not e^{−O(nε²)} | PROVED |
| σⱼ, λⱼ disintegration | None at the joint level. The constraint involves Θ only; all disintegrations stay inside the single-level theorems | PROVED |
| Extra conditions | Fixed q; the single-level assumptions at every level with common constants. Minimal separation is implied, not assumed | PROVED |
| Levels approaching each other with n | Enough: Δτₙ ≥ 2f̄·s̄\*ₙ ≍ n^{−7/30}(log n)^{1/15} | PROVED for fixed q; SKETCH for growing q |
| No separation at the sup-norm scale (gap < 2s̄\*) | Needs a lower bound Π^⊗(C \| y) ≥ e^{−O(nε²)}. Route given; one lemma missing (sup-norm small ball) | SKETCH / CONJECTURE (§4) |

**Main risk.** The theorem is true but **asymptotically vacuous about the constraint**: it works by showing that the ordering becomes inactive. That needs 2s̄\* ≤ min(L, Δτ/f̄) with s̄\* ≍ n^{−7/30}, i.e. n ≳ (c·f̄/Δτ)^{30/7}, which is far beyond the paper's sample sizes for Δτ of a few hundredths. At realistic n the constraint is active and this proof says nothing; that regime is §4, which is not proved.

---

## 1. The object — PROVED

**Single level.** For level j, write πⱼ(θⱼ, λⱼ, σⱼ | y) for the single-level posterior of V0T\* at τⱼ (σⱼ ~ IG, λⱼ ~ p_n on [Λ₋, ∞)), and Πⱼ(· | y) for the corresponding probability measure. It is proper for every y (V2T, propriety).

**Product.** Π^⊗(· | y) := ⊗ⱼΠⱼ(· | y), a probability measure on (Θ, λ, σ). **Given y, the levels are independent under Π^⊗.** The data are shared, but they are fixed once we condition on y; the dependence across levels is a property of the sampling law of y, not of Π^⊗(· | y).

**Joint.** The paper's joint posterior has density ∝ 1_C(Θ)·∏ⱼπⱼ(θⱼ, λⱼ, σⱼ | y), with C := {Θ : θ_{i1} ≤ … ≤ θ_{iq} for all i}. C is closed with nonempty interior and each πⱼ(θⱼ | y) is positive, so Π^⊗(C | y) > 0 and

  **Π_C(B | y) = Π^⊗(B ∩ C | y)/Π^⊗(C | y).**

**Three elementary facts.**
- (F1) Π_C(B | y) ≤ Π^⊗(B | y)/Π^⊗(C | y).
- (F2) ‖Π_C(· | y) − Π^⊗(· | y)‖_TV = Π^⊗(Cᶜ | y). *Proof.* With μ := Π^⊗ and p := μ(C): μ_C(A) − μ(A) = μ(A ∩ C)(1/p − 1) − μ(A ∩ Cᶜ), which lies in [−(1 − p), 1 − p], with equality at A = C.
- (F3) If B = ∪ⱼBⱼ with Bⱼ depending on level j only, then Π^⊗(B | y) ≤ ΣⱼΠⱼ(Bⱼ | y).

**σ and λ.** 1_C does not involve (λ, σ). So the Θ-marginal of Π_C is the Θ-marginal of Π^⊗ conditioned on C, and the conditional law of (λⱼ, σⱼ) given Θ under Π_C is the single-level conditional. Under Π_C the pairs (λⱼ, σⱼ) are dependent across levels through Θ; nothing below uses their independence. The Kozumi–Kobayashi latent variables integrate out level by level and do not change any of this.

---

## 2. Theorem J — PROVED

### 2.1 Separation is implied by upper (A2)

**Lemma J0.** Suppose that at every level j and every i, |Fᵢ(θ\*_{ij} + δ) − Fᵢ(θ\*_{ij})| ≤ f̄|δ| for |δ| ≤ L (upper (A2); Fᵢ is the cdf of yᵢ). Then for all i and all j < q:

  **θ\*_{i,j+1} − θ\*_{ij} ≥ g₀ := min(L, Δτ/f̄).**

*Proof.* Upper (A2) gives Fᵢ(θ\*_{ij}) = τⱼ (L2 (iii)). Let δ := θ\*_{i,j+1} − θ\*_{ij} ≥ 0. If δ > L we are done. Otherwise τ_{j+1} − τⱼ = Fᵢ(θ\*_{ij} + δ) − Fᵢ(θ\*_{ij}) ≤ f̄δ. ∎

So the truth lies in the interior of C at sup-norm distance g₀/2 from the boundary, uniformly in i and n. Two true quantile curves can touch at a point i only if Fᵢ has an atom there (it must jump from ≤ τⱼ to ≥ τ_{j+1}). Upper (A2), which the single-level theorem already assumes, excludes that.

### 2.2 Statement

**Assumptions.** q ≥ 2 and the levels are fixed. For each j the assumptions of Theorem V0T\* hold at level τⱼ: (A1); full (A2) in secant form; (A3); row-average uniform integrability of ρ_{τⱼ}(yᵢ − θ\*_{ij}); dⱼ ≤ σ₀,ₙ,ⱼ ≤ Bⱼ; floor Λ₋,ⱼ = κ₋,ⱼn^{5/2} and p_n as in V0T\* (constant or scaled b₀). The class 𝒫 is the set of laws of y satisfying all of these at once with fixed constants; write (L, f̄) for the worst-case upper-margin constants.

**Constants.** ε̄ⱼ², M̄\*ⱼ and s̄\*ⱼ := 6√M·ε̄ⱼ + 7.06·(√M·ε̄ⱼ)^{4/5}T₀,ⱼ^{1/5} as in V0T\* at level j; M > maxⱼM̄\*ⱼ; s̄\* := maxⱼs̄\*ⱼ ≍ n^{−7/30}(log n)^{1/15}; g₀ as in Lemma J0.

**Theorem J.** For every fixed η > 0, as n → ∞:
1. sup_P E_P Π^⊗(Cᶜ | y) → 0. Equivalently, sup_P E_P‖Π_C − Π^⊗‖_TV → 0: **the joint non-crossing posterior and the product of the single-level posteriors merge in total variation.**
2. sup_P E_P Π_C( ‖θⱼ − θ\*ⱼ‖²ₙ > M·ε̄ⱼ² for some j | y ) → 0. Rate **n^{−5/6}(log n)^{1/6}** at every level simultaneously.
3. sup_P E_P Π_C( ‖θⱼ − θ\*ⱼ‖∞ > s̄\*ⱼ for some j | y ) → 0.
4. sup_P E_P Π_C( |σⱼ/σ₀,ₙ,ⱼ − 1| > η for some j | y ) → 0.

The same holds with Theorem C\* in place of V0T\* (σⱼ learned, λⱼ deterministic at the oracle), with its ε, M\* and s\*.

**Quantitative form.** For every event B = ∪ⱼBⱼ with Bⱼ a level-j event, and every n with 2s̄\* ≤ g₀:

  **E_P Π_C(B | y) ≤ 2·Σⱼ[ E_P Πⱼ(Bⱼ | y) + E_P Πⱼ(‖θⱼ − θ\*ⱼ‖∞ > s̄\*ⱼ | y) ].**

Every term on the right is a single-level quantity bounded in V0T\* (its conclusions 1–3).

### 2.3 Proof

**Step 1 (the sup-norm tube lies in C).** Let n be large enough that 2s̄\* ≤ g₀; this is possible because s̄\* → 0 and g₀ is fixed. If ‖θⱼ − θ\*ⱼ‖∞ ≤ s̄\*ⱼ for all j, then for all i and j < q:

  θ_{i,j+1} − θ_{ij} ≥ (θ\*_{i,j+1} − θ\*_{ij}) − 2s̄\* ≥ g₀ − 2s̄\* ≥ 0,

so Θ ∈ C. Hence Cᶜ ⊂ ∪ⱼ{‖θⱼ − θ\*ⱼ‖∞ > s̄\*ⱼ}.

**Step 2 (conclusion 1).** By (F3), Π^⊗(Cᶜ | y) ≤ ΣⱼΠⱼ(‖θⱼ − θ\*ⱼ‖∞ > s̄\*ⱼ | y). Take E_P and the supremum over 𝒫: each of the q terms → 0 by V0T\*, conclusion 2, at level j. The TV statement is (F2).

**Step 3 (transfer).** By (F1), on the data event {Π^⊗(Cᶜ | y) ≤ ½}: Π_C(B | y) ≤ 2Π^⊗(B | y). Off it, Π_C(B | y) ≤ 1. By Markov, P(Π^⊗(Cᶜ | y) > ½) ≤ 2E Π^⊗(Cᶜ | y). So

  E Π_C(B | y) ≤ 2E Π^⊗(B | y) + 2E Π^⊗(Cᶜ | y),

and (F3) with Step 2 gives the quantitative form.

**Step 4 (conclusions 2–4).** Apply Step 3 with Bⱼ := {‖θⱼ − θ\*ⱼ‖²ₙ > Mε̄ⱼ²}, then {‖θⱼ − θ\*ⱼ‖∞ > s̄\*ⱼ}, then {|σⱼ/σ₀,ₙ,ⱼ − 1| > η}, and use conclusions 1, 2, 3 of V0T\* at each level. ∎

**What the proof uses.**
- From the single-level theory: only the **statements** of V0T\* (or C\*), in particular its sup-norm conclusion, which comes from L10-I on the TV body.
- New: Lemma J0 and (F1)–(F3). Nothing else.
- The measurability of Π_C(B | y) in y follows from that of the single-level numerators (L5) and of Π^⊗(C | y), which is an integral of a jointly measurable integrand.

---

## 3. The points raised, one by one

**(a) Numerator: dependent Zᵢⱼ across levels — PROVED that it is not an issue.**
- Zᵢⱼ = yᵢ − θ\*_{ij} are dependent across j (same yᵢ) and independent across i (A1). The single-level proofs use only independence across i.
- Restricting to C only removes mass: N_C(B) ≤ N^⊗(B). For a product set, N^⊗(∏ⱼEⱼ) = ∏ⱼNⱼ(Eⱼ) is an **identity for each y**: the integrals are over different θⱼ with the data held fixed. Fubini over the data (Tonelli in C2 §3.2) is applied inside one level at a time and produces one Markov event per level, shell and endpoint. Across levels the realized bounds are multiplied on the intersection of the events, whose failure probabilities add.
- So no expectation of a product over levels is taken, and no Hölder step is needed. If a joint expectation were wanted, generalized Hölder with exponent q would work, at the cost of replacing ω by qω in C2's remainder threshold |δ| ≤ 3f/(4ωf̄) and in the fine MGF condition; this is not used.

**(b) Denominator: mass of a good set inside C — PROVED under separation.** With the posterior-probability form (F1), the joint denominator is Π^⊗(C | y), and it tends to 1. The product of the single-level L6 sets is **not** used, and that is fortunate: an ‖·‖ₙ-ball of radius ε does not control the sup-norm, so intersecting those balls with C could cut the prior mass badly. The order is instead guaranteed by the sup-norm conclusion of the single-level posteriors. No order-preserving mollification and no common shift are needed in this regime.

**(c) σⱼ and λⱼ over q levels — PROVED.** See §1. The interval for σⱼ, the λ-mixing and the floor are all internal to Πⱼ.

**(d) Extra conditions — PROVED.**
- *Fixed q.* The bound is a sum of q single-level terms.
- *Common constants.* Needed only to take the supremum over 𝒫.
- *Separation.* Implied by upper (A2), Lemma J0.
- *Levels approaching each other.* The proof needs only 2s̄\*ₙ ≤ min(L, Δτₙ/f̄), so Δτₙ may shrink as long as **Δτₙ ≥ 2f̄·s̄\*ₙ ≍ n^{−7/30}(log n)^{1/15}** (fixed q, common constants).

**(e) Growing q — SKETCH.** The bound is q times the single-level convergence rate. Two things are missing: V0T\* is stated for a fixed interior τ (uniformity over τ in a compact subinterval is plausible, the constants depending on τ only through min(τ, 1 − τ) in Lemma S and through the class constants), and Lemma S's law-of-large-numbers events carry no explicit rate under uniform integrability alone. With a common 1 + γ moment these get a polynomial rate, and then q_n = o(n^{c}) for some c > 0 would be allowed, subject to Δτₙ ≥ 2f̄s̄\*ₙ, i.e. q_n ≲ n^{7/30}. Not written.

---

## 4. Without separation at the sup-norm scale — SKETCH / CONJECTURE

This is the regime that describes finite n (gap < 2s̄\*), and n-dependent grids finer than n^{−7/30}. Here Π^⊗(C | y) need not tend to 1, and (F1) requires

  **Π^⊗(C | y) ≥ exp(−C_C·nε²) with probability → 1.**

Then Theorem J's conclusions 2–4 would hold with M increased by a multiple of C_C/ω₁, **provided** the single-level bad mass is ≤ e^{−Δ(M)·nε²} on the good events, with Δ linear in M (step 0 below). Heuristically the budget is right: the posteriors have about nε² ≍ n^{1/6} effective degrees of freedom, and two independent draws with nearly equal centres are ordered everywhere with probability e^{−O(nε²)}.

**Route (not proved).**
0. *Exponentially small single-level bad mass — SKETCH.* V0T\* as stated gives Πⱼ(bad | y) → 0, not ≤ e^{−Δ·nε²}: its σ-step ends with Π(σ ∉ I | y) → 0, which rests on a Chebyshev bound of order 1/n (Lemma S §1). The θ-part is already exponential on the good events (R_n + R′_n in V-6). For the σ-part, replace Chebyshev by the Gamma(n + a, 1) Chernoff bound, P(|G/n − 1| > h) ≤ 2e^{−c(h)·n}, and use that {|Q − Q\*| > nt} has posterior mass ≤ e^{−c·nr²} at fixed σ on the C1 events and that Lemma S §2's tails are e^{−n}. This should give Π(σ ∉ I | y) ≤ e^{−c·nr²} ≪ e^{−C·nε²} on a data event of probability → 1. Not written.
1. *Evidence upper bound per level — SKETCH, from audited parts.* On the V0T\* events, Nⱼ(ℝⁿ) ≤ Nⱼ(K′ ∩ {‖δ‖²ₙ ≤ Mε²})/(1 − o(1)), and the inner ball is bounded by C2's coarse and fine score steps without the remainder gain: ≤ V₃(M·nε²)^{3/2}·exp{ω(f/(8√2))M·nε² + O(ω²nε²/M⁵) + o(nε²)}. So upper and lower evidence bounds differ by e^{O(M·nε²)}.
2. *An ordered product set.* Tubes Gⱼ := {‖θⱼ − θ̃ⱼ − 2j·a·1‖∞ ≤ a} with a ≍ ε/q. The constant shifts 2j·a·1 are free: the prior is flat on constants. The tubes are ordered if the centres are: θ̃_{j+1} ≥ θ̃ⱼ.
3. *Order-preserving mollified centres — SKETCH.* L4q-M's signed kernel does not preserve positivity of the gaps gⱼ := θ\*_{j+1} − θ\*ⱼ ≥ 0, and its sup-norm error is ≍ V(w/n)² ≍ n^{−1/3} ≫ ε. Repair: mollify θ\*₁ and each gap gⱼ, then add to the mollified gap the nonnegative bump Σ_l|(Dgⱼ)_l|·β⁽ˡ⁾, where β⁽ˡ⁾ ≥ |S(e_l − K⁽ˡ⁾)| is a smooth bump of height Cw² on 3w points. This keeps g̃ⱼ ≥ gⱼ ≥ 0 and has the same budgets as L4q-M up to constants (‖β⁽ˡ⁾‖ₙ ≲ w^{5/2}/√n, ‖Dβ⁽ˡ⁾‖₂ ≲ w^{−1/2}). Errors add over j, which is harmless for fixed q.
4. *Sup-norm small ball — the missing lemma, CONJECTURE.* −log Π_λ(‖P⊥Su‖∞ ≤ a) ≲ (n^{5/2}/(λa))^{2/5}·polylog(n). The exponent is the known one for twice-integrated Brownian motion in sup-norm, and Step 1 of L3 (scale mixture + Anderson) applies to any symmetric convex set; but L3's singular-value argument is specific to ℓ₂. The shift step needs L4q for a sup-norm ball, which its proof allows in principle (any norm, with δ_A measured in that norm); not checked.
5. *Joint Jensen (L6) on the ordered product set.* The mean adds over levels; the variance of Σⱼωⱼ∫ℛⱼ dg is ≤ q·Σⱼ of the single-level variances despite the dependence across levels. Fine for fixed q.

**Fallback with audited tools only — SKETCH, exponent level.** Replace step 4 by {‖P⊥Su‖ₙ ≤ ε′, TV ≤ T₀} and L10-I: the sup-norm is ≤ a/2 once ε′ ≍ a^{5/4}n^{−1/8}, at small-ball cost ≍ ε′^{−2/5} = a^{−1/2}n^{1/20}. Balancing against n·a² gives a² ≍ n^{−19/25}. So without separation the audited tools would give a joint rate of about **n^{−19/25}** (between C1's n^{−5/7} and the target n^{−5/6}), provided steps 1–3 and 5 are written. I did not check the L4q hypotheses for the intersected set.

---

## 5. Flags

- **The theorem does not explain any benefit of the joint model.** Asymptotically Π_C and Π^⊗ coincide in total variation, so the statement is "the constraint does no harm", not "the constraint helps". That is the honest reading for the paper.
- **n₀.** 2s̄\* ≤ min(L, Δτ/f̄) is the binding finite-sample condition. With s̄\* ≍ c·n^{−7/30}, it reads n ≳ (2c·f̄/Δτ)^{30/7}. For the paper's upper-tail grid (Δτ = 0.01) this is astronomically large whatever c is. The sup-norm rate n^{−7/30} is not claimed sharp (heuristically n^{−1/3} at second-derivative kinks), but even that would not bring n₀ into range.
- **Crossing frequency as a diagnostic (suggestion, UNTESTED).** Conclusion 1 predicts that the fraction of unconstrained product draws violating C tends to 0 with n. Engineering can read this off existing single-level chains; a non-vanishing fraction at the largest n would mean the experiments sit in the regime of §4.
- **Dependence on single-level inputs.** Theorem J inherits every assumption of V0T\* at every level, in particular full (A2) at each τⱼ. At extreme levels (τ = 0.99) the constants f, d are small, so M and n₀ are driven by the worst level.
- **Composite, not a likelihood.** Π_C is not a Bayes posterior for any joint model of y. Nothing here needs it to be; all statements are about the measure as defined.
- **Not verified.** The internals of V0T\* and C\* (used as stated; cross-audited by Astra); the paper's exact joint hyperprior specification beyond "each πⱼ is the single-level posterior".
