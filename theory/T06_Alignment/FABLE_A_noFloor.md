# The exact method with no floor (σ ~ IG, λ ~ Gamma(1, b₀), both learned): what can and cannot be proved

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute; nothing here is numerically verified. Reuses `astra_learned_lambda.md`, `FABLE_V2T_proof.md`, `FABLE_lemmaF_C2.md`, `C1_any_sigma.md`, L3–L6, L10-I. Not audited.*

**Labels.** PROVED = fully written here from elementary facts or audited statements (still unaudited as a whole). SKETCH = argument given, details open. CONJECTURE = heuristic only.

## 0. Verdict

| # | Claim | Status |
|---|---|---|
| 1 | The θ-marginal of the exact method is explicit: ∝ (b + Q(θ))^{−(n+a)}·(b₀ + ‖Dθ‖₁)^{−(m+1)} | **PROVED** (§1) |
| 2 | **Obstruction.** If σ₀,ₙ > (1 + η)·2τ(1−τ)·ρ_D (ρ_D = mean absolute third difference of the noise), the exact posterior puts mass ≤ e^{−cn} on every small neighbourhood of θ\*: it interpolates. An explicit law in the theorem class does this at τ = 0.05 | **PROVED** (§2) |
| 3 | So no theorem for the exact method can hold over the class (A1)–(A3). A condition is needed: at least **(NI)** σ₀,ₙ < (1 − η)·2τ(1−τ)·ρ_D | consequence of 2 |
| 4 | For every law: posterior ‖Dθ‖₁ ≤ (1 + η)nσ₀,ₙ/(2τ(1−τ)). Under (NI): no interpolation, Q(θ)/n ≥ q₁ > 0, σ bounded below, λ bounded below by a constant | **PROVED** (§3) |
| 5 | Exact reduction: Π_exact(B \| y) ≤ Π_floor Λ(B \| y) + Π_exact(λ < Λ \| y), for every Λ | **PROVED** (§4.1) |
| 6 | **Theorem H** (what replaces C1 at low λ): for the floored posterior with **any** floor Λ₋ ≫ polylog(n), every σ, Huber-loss contraction at Λ₋^{−2/7}·polylog. At Λ₋ = κn^{3/4}: n^{−3/14} | **SKETCH** (§4.2); all steps identified, exponents checked |
| 7 | Lower containment of λ for the exact method (λ ≥ κn^p with posterior mass → 1) under (NI) and a local condition **(LO)** σ₀ > σ̄/6 | **CONJECTURE** (§5). This is the whole remaining gap |
| 8 | (LO) fails for Gaussian noise at τ < 0.032 or τ > 0.968 (it holds at 0.05, ratio 0.22 against 1/6) | CONJECTURE (Gaussian proxy), testable |

**Answers.**
1. *Any provable contraction for the exact method below σ̄?* Not over the class (item 2), and not on Tuesday even under (NI): the missing piece is an Occam bound with sharp constants (item 7). What **is** provable is the same statement with a floor that never binds in practice (item 6), and the exact method inherits it wherever its posterior λ stays above that floor (item 5).
2. *Obstruction?* Yes, proved: §2.
3. *Tuesday.* Prove Theorem H and state "exact method + safeguard floor κn^p, 0 < p ≤ 3/4" (§6).

---

## 1. The exact posterior in closed form — PROVED

Joint posterior: π(θ, λ, σ | y) ∝ σ^{−n}e^{−Q(θ)/σ}·λ^m e^{−λ‖Dθ‖₁}·b₀e^{−b₀λ}·IG(σ; a, b), in L5 coordinates θ = Nc + Su, reference measure dc du.

Integrating σ: ∫σ^{−n}e^{−Q/σ}IG(σ; a, b)dσ = (bᵃΓ(n + a)/Γ(a))·(b + Q)^{−(n+a)}.

Integrating λ: ∫(λ/2)^m e^{−λ‖u‖₁}b₀e^{−b₀λ}dλ = π̄(u) := b₀·2^{−m}·m!·(b₀ + ‖u‖₁)^{−(m+1)}. This is the density of Π̄ = ∫p(dℓ)Π_ℓ, a probability measure.

Hence

  **π(θ | y) ∝ (b + Q(θ))^{−(n+a)}·π̄(Dθ)  with respect to dc du.**

Three consequences used below.
- **The method is a product of two power laws.** Up to (b, b₀) it is invariant under y ↦ cy, θ ↦ cθ. Its mode minimizes Q(θ)·‖Dθ‖₁; the implied tuning is λσ ≈ Q/‖Dθ‖₁.
- **Likelihood ratio.** (b + Q(θ))^{−(n+a)} = (b + Q\*)^{−(n+a)}·(1 + ℛ(δ)/(b + Q\*))^{−(n+a)} ≥ (b + Q\*)^{−(n+a)}·e^{−ω̂ℛ(δ)}, with ω̂ := (n + a)/(b + Q\*) → 1/σ₀,ₙ. So the σ-integrated denominator is bounded below by a fixed-ω denominator at the data-dependent ω̂. V2T's Step 3 holds "for all ω > 0 simultaneously" on one event, so it applies.
- **Jacobian.** dc du = J_n dθ with **1 ≤ J_n ≤ n^{9/2}**. Proof: let P̃ be the n×3 matrix with columns C(i−1, k), k = 0, 1, 2, and E := [I₃ 0]. Then DP̃ = 0, det[E; D] = ±1 (the last m columns of D are unit triangular) and det(EP̃) = 1. From [P̃ᵀ; D][P̃ᵀ; D]ᵀ = diag(P̃ᵀP̃, DDᵀ) and [P̃ᵀ; D]·[E; D]⁻¹ = [P̃ᵀP̃(EP̃)⁻¹ ∗; 0 I_m], we get det(DDᵀ) = det(P̃ᵀP̃) ≤ n·n³·n⁵ (Hadamard). (Check at order one: det(D⁽¹⁾D⁽¹⁾ᵀ) = n.) This sharpens Astra's J_n ≤ 8^m; the lower bound J_n ≥ 1 is Astra's.

---

## 2. Obstruction: a law in the class on which the exact method interpolates — PROVED

**Notation.** ρ_D,n := n⁻¹Σⱼ E|(DZ)ⱼ|, the mean absolute third difference of the centred noise. k := min(τ, 1 − τ).

**Proposition O.** Assume (A1), (A3), bounded noise (or the uniform integrability of Lemma S), and

  σ₀,ₙ ≥ (1 + η)·2τ(1−τ)·ρ_D,n  for some fixed η > 0.

Then there are ε₀ > 0 and c > 0 such that, with probability → 1,

  Π(n⁻¹‖θ − θ\*‖₁ ≤ ε₀ | y) ≤ e^{−cn}.

The same holds for ‖·‖ₙ and for the Huber loss (both dominate a function of n⁻¹‖δ‖₁). It holds for constant b₀ and for b₀,ₙ = c·n^{−5/2}, and for any fixed a, b > 0.

*Proof.* Compare two regions under the density of §1.

*Near the truth.* On 𝒢 := {n⁻¹‖δ‖₁ ≤ ε₀}: Q(θ) ≥ Q\* − nε₀, the c-section lies in a ball of radius nε₀, and Π̄ has mass 1. So

  ∫_𝒢(b + Q)^{−(n+a)}π̄ dc du ≤ V₃(nε₀)³·(Q\* − nε₀)^{−(n+a)} = poly(n)·[n(σ₀,ₙ − ε₀ − o(1))]^{−n},

by the law of large numbers for Q\*/n (Lemma S §1).

*Near the data.* On ℐ := {Q(θ) ≤ nh}: ‖θ − y‖₁ ≤ nh/k, so ‖Dθ‖₁ ≤ ‖Dy‖₁ + 8nh/k ≤ n(ρ_D,n + 8h/k + o(1)) (‖Dy‖₁ ≤ V/n² + ‖DZ‖₁; LLN for 3-dependent terms). The Lebesgue volume of ℐ is (nh)ⁿ/(n!·(τ(1−τ))ⁿ) (each coordinate map z ↦ ρ_τ(z) is two-to-one with dz = dw/(τ(1−τ)); then a simplex). With J_n ≥ 1 and π̄ decreasing in ‖u‖₁:

  ∫_ℐ(b + Q)^{−(n+a)}π̄ dc du ≥ (b + nh)^{−(n+a)}·(nh)ⁿ/(n!(τ(1−τ))ⁿ)·b₀2^{−m}m!·(b₀ + n(ρ_D,n + 8h/k + o(1)))^{−(m+1)}
              ≥ poly(n)⁻¹·e^{−2b/h}·[2τ(1−τ)·n·(ρ_D,n + 8h/k + o(1))]^{−n}.

(The powers of nh cancel; m!/n! ≥ n^{−3}.)

*Ratio.* Π(𝒢 | y) ≤ poly(n)·e^{2b/h}·[2τ(1−τ)(ρ_D,n + 8h/k + o(1))/(σ₀,ₙ − ε₀ − o(1))]ⁿ. Choose h and ε₀ small so that the bracket is ≤ (1 + η/2)/(1 + η) < 1. ∎

**Reading.** The two bases are code lengths per observation: σ₀/(τ(1−τ)) is what the asymmetric-Laplace working likelihood pays at the truth; 2ρ_D is what the model "third differences are i.i.d. Laplace" pays for the raw data. The exact method learns both scales, so it picks the cheaper code. Nothing in (A1)–(A3) orders them. b₀ does not enter.

**An explicit law in the class (τ = 0.05).** Let Z have density 0.05 on [−1, 0], density 0.005 on (0, 1], and mass 0.945 uniform on [A − 1, A + 1], with A = 200. Take θ\* = 0.
- Class membership: P(Z < 0) = 0.05 = τ; (A2) in secant form with L = 1, f = 0.005, f̄ = 0.05; (A3) for every V; bounded, so uniformly integrable; σ₀ ≥ d.
- σ₀ = 0.95·0.025 + 0.05·(0.0025 + 0.945A) = 0.0239 + 0.04725A.
- ρ_D ≤ A·E|H₁ − 3H₂ + 3H₃ − H₄| + 8, with Hᵢ i.i.d. Bernoulli(p = 0.055) ("low cluster"). E|·| = 8p(1−p)³ + 12p²(1−p)² + 8p³(1−p) = 0.3713 + 0.0324 + 0.0013 = 0.4050.
- 2τ(1−τ)ρ_D ≤ 0.095·(0.405A + 8) = 0.03848A + 0.76. At A = 200: σ₀ = 9.47 against 8.46, so the hypothesis holds with η ≈ 0.12.

The same two-cluster construction works whenever g(τ) := 8τ(1−τ)³ + 12τ²(1−τ)² + 8τ³(1−τ) < ½, i.e. for **τ < 0.069 and, by symmetry, τ > 0.931**. It cannot work at the median: for τ = ½, σ₀ = ½E|Z| and ρ_D ≥ min_t E|Z − t| = E|Z|, so 2τ(1−τ)ρ_D ≥ σ₀ always (SKETCH: with a uniform gap from (A2)).

**Scope of the obstruction.**
- It concerns the method as run (σ learned). In the interpolating region σ is small, not near σ₀. At σ *fixed* at σ₀ I have no proved obstruction; there the proved one is Astra's (fixed small σ), and the conjectured one is (LO) in §5.
- The floored variants are immune: λ ≥ Λ₋ → ∞ makes ‖Dθ‖₁ ≈ m/λ = o(n). Theorems C\*, V2T and V0T\* hold for the law above.
- Gaussian noise is far from it. The margin 2τ(1−τ)ρ_D/σ₀ = 2τ(1−τ)·3.568/φ(z_τ) equals 4.47, 4.21, 3.66, 3.29, 2.65 at τ = 0.5, 0.25, 0.10, 0.05, 0.01. For the paper's Beta and mixture designs the margin is one line of Monte Carlo: n⁻¹‖D⁽³⁾y‖₁·2τ(1−τ) against Q(θ\*)/n. **Not computed here** (no compute); a well-separated mixture at an extreme level is the case to check.

---

## 3. What (NI) buys, with proofs — PROVED

**Proposition R (roughness cap, every law).** Under the assumptions of V2T's Step 3 (mixed denominator), for every η > 0,

  sup_P E_P Π(‖Dθ‖₁ > (1 + η)·nσ₀,ₙ/(2τ(1−τ)) | y) → 0.

*Proof.* Let ρ₁ := (1 + η)σ₀,ₙ/(2τ(1−τ)).
- *Numerator.* π̄ ≤ b₀2^{−m}m!(nρ₁)^{−(m+1)} on the event, and ∫(b + Q)^{−(n+a)}dc du = J_n·(τ(1−τ))^{−n}·b^{−a}Γ(a)/Γ(n + a) (the same simplex computation, over all of ℝⁿ). With Stirling and J_n ≤ n^{9/2}, the numerator is ≤ poly(n)·[2τ(1−τ)nρ₁]^{−n}.
- *Denominator.* By §1 and V2T Step 3 run on the window [L_n, 2L_n], L_n := n^{3/4}(log n)^{1/8}, with centre u\* (L4 shift cost 2L_nV/n² → 0; L3 at radius ε/2; hyperprior cost b₀L_n; this is Astra's constant-b₀ budget): on Ω_D, the denominator is ≥ (b + Q\*)^{−(n+a)}·exp{−C(1 + ω̂)·n^{3/4}(log n)^{1/8}} = [nσ₀,ₙ(1 + o(1))]^{−n}.
- *Ratio.* ≤ poly(n)·e^{o(n)}·(1 + η)^{−n} → 0. ∎

**Corollary (no interpolation under (NI)).** If σ₀,ₙ ≤ (1 − η)·2τ(1−τ)ρ_D,n, take η′ with (1 + η′)(1 − η) < 1. On the event of Proposition R, ‖D(y − θ)‖₁ ≥ ‖Dy‖₁ − nρ₁ ≥ c′n, hence ‖y − θ‖₁ ≥ c′n/8 and **Q(θ) ≥ q₁n**, q₁ := kc′/8 > 0. Consequently:
- σ ≥ q₁/2 with posterior mass → 1 (σ | θ, y is (b + Q)/Gamma(n + a, 1)). This replaces Lemma S §2's lower tail, whose roughness-cost step needs λ/log n → ∞ and is unavailable here.
- λ ≥ 1/(2ρ₁) with posterior mass → 1 (λ | θ ~ Gamma(m + 1, b₀ + ‖Dθ‖₁)). A constant, not a diverging, lower bound.

This is all I can prove for the exact method. From "λ ≥ constant" to "λ → ∞" is the gap of §5.

---

## 4. What replaces C1 when λ ~ n^{3/4}

### 4.1 Exact reduction to a floored posterior — PROVED

For every Λ > 0 and event B, since the posterior under the prior truncated to λ ≥ Λ is the conditional law given {λ ≥ Λ}:

  **Π_exact(B | y) ≤ Π_floor Λ(B | y) + Π_exact(λ < Λ | y).**

So any theorem for the floored method transfers to the exact method on every law (and data set) where the posterior of λ stays above the floor. The second term is observable in the Gibbs output.

### 4.2 Theorem H: Huber-body localization for any floor — SKETCH

C1's window λ ≫ n^{21/11} comes from one requirement only: sup-norm localization, needed to use the *quadratic* margin on an ℓ₂ body. Replace the ℓ₂ ball by a Huber ball and the window disappears.

**Setting.** λ-mixed prior on [Λ₋, ∞) (any hyperprior; constant b₀ included), fixed σ in a compact, Λ₋ → ∞. h_L(x) := x²/2 for |x| ≤ L, L|x| − L²/2 otherwise (convex); 𝐡(δ) := Σᵢh_L(δᵢ). T₀ := Tn³/Λ₋.

**Statement.** With r² := C·K_n^{12/7}·T^{2/7}·Λ₋^{−2/7}(log n)^{6/7}, K_n → ∞ arbitrarily slowly, and (log n)^{c₀} ≪ Λ₋ ≤ n²:

  sup_P E_P sup_{ω∈[ω₁,ω₂]}Π_ω(𝐡(θ − θ\*) > n·r² or TV(θ − θ\*) > T₀ | y) → 0.

So the Huber loss contracts at **Λ₋^{−2/7}·polylog**: n^{−3/14} at Λ₋ = κn^{3/4}, n^{−1/7} at n^{1/2}. With σ learned, add Lemma S (its §2 needs only Λ₋/log n → ∞).

**Steps, and what each reuses.**
1. *Body.* K_H := {𝐡(δ) ≤ nr², TV(δ) ≤ T₀}: convex, symmetric, absorbing. Gauge t; ray inequality ℛ(δ) ≥ t·ℛ(δ/t) (C1 Step 2, unchanged).
2. *Margin without sup-norm.* Under full (A2), mᵢ(x) ≥ (f/2)h_L(x) for **every** x (quadratic for |x| ≤ L; by convexity mᵢ(x) ≥ (|x|/L)mᵢ(±L) ≥ (fL/2)|x| beyond). So M ≥ (f/2)nr² on the face 𝐡 = nr². Moment-free. *New, two lines.*
3. *Width of K_H.* Split coordinates at L: Σ_{|δᵢ|≤L}δᵢ² ≤ 2nr² and Σ_{|δᵢ|>L}|δᵢ| ≤ 2nr²/L. With Lemma F's projector,
   ⟨ε, δ⟩ ≤ ‖P_Jε‖₂·√(2n)r + ‖P_Jε‖∞·2nr²/L + (T₀/n²)·max_j|⟨w_j, ε⟩|.
   The first and third terms are W′. The middle one needs **Lemma Lev: max_i(P_J)ᵢᵢ ≤ 9/h** (the spline space sits inside piecewise quadratics on cells of length ≥ h, whose leverage is the Christoffel constant 9 of L10-I; the last knot must be dropped if the last cell is short, which changes Lemma F's end constant). Then E‖P_Jε‖∞ ≤ 3√(2 log(2n)·J/m), and the middle term is o(nr²) as J log n/n → 0. Balancing as in W′: E sup_{K_H}⟨ε, δ⟩ ≲ √n·r^{5/6}T₀^{1/6}√(log n). *New: Lev.*
4. *Event.* The envelope of K_H is not bounded, so Bousquet is not available. Use symmetrization and contraction (no envelope needed) and **Markov**: P(sup_{K_H}|ℛ − M| > (f/8)nr²) ≤ 1/K_n once the expectation is ≤ (f/8)nr²/K_n. This is the K_n^{12/7} in r².
5. *Cones.* A₁: gauge t ≥ L‖c − c̄(u)‖₂/(n(r² + L²/2)), so the c-integral of e^{−at} is polynomial in n. A₂: the c-section has radius ≤ t·n(r² + L²/2)/L; the Chernoff bound with Γ = ℓ‖u‖₁ ~ Gamma(m, 1) and the frozen body is V2T Step 4 verbatim.
6. *Denominator.* V2T Step 3 on [Λ₋, 2Λ₋] with centre u\* and L4 (cost 2Λ₋V/n²); L3 holds for all λ. ε² ≍ Λ₋^{−1/3}(log n)^{1/6}, and nε² = o(nr²) because Λ₋^{1/21} → ∞. Window mass of the truncated exponential: 1 − e^{−b₀Λ₋}.

**Why no better rate.** C2's shells need ‖δ‖∞ ≤ s₀ in the remainder step, and L10-I gives nothing at T₀ ~ n^{9/4}. So Theorem H stops at Λ₋^{−2/7}; the small-ball rate would be Λ₋^{−1/3} (n^{−1/4} at n^{3/4}).

**Unified picture of the floor exponent p (Λ₋ = κn^p).** 0 < p ≤ 21/11: Huber rate n^{−2p/7} (Theorem H). 21/11 < p ≤ 5/2: n^{−p/3} (C1 + C2-mix, `FABLE_A_n56.md` §6). R-A1's measured λ ∝ n^{0.76–0.94} would correspond to n^{−0.22} to n^{−0.27} under Theorem H.

### 4.3 The three options asked about

- **(a) Lower-λ evidence bound at σ ≈ σ₀.** This is the crux and it is not available: §5.
- **(b) Coarser body with the Huber margin.** Works, and it is Theorem H. It removes C1's window but not the need for *some* lower control of λ: the mixture over ℓ ↓ 0 has no body (T₀ = Tn³/ℓ is unbounded).
- **(c) A different sieve.** No. Slicing by roughness R = ‖Dθ‖₁ and bounding "sup of likelihood × prior volume" on each slice gives evidence ≤ [n·q(R)]^{−n}, with q(R) the best check loss at that roughness. Since q(R) < σ₀ for rough fits, this loses e^{n·log(σ₀/q(R))}: the same "supremum before integration" loss as C1's loss B, now at exponential order. Chernoff bounds on the slice volumes reduce to the free energy n⁻¹log∫e^{−αQ−βR}dθ at bounded β, which is not explicit.

---

## 5. The remaining gap: λ → ∞ for the exact method — CONJECTURE

**What is needed.** Π_exact(λ < κn^p | y) → 0 for some p > 0 (then §4.1 + Theorem H give contraction at n^{−2p/7}). Equivalently: posterior ‖Dθ‖₁ ≲ n^{1−p}. Proposition R gives only p = 0.

**Why it is hard.** The hyperprior does not penalize roughness: P(λ ≤ ℓ) = 1 − e^{−b₀ℓ}, polynomial. All of the penalty must come from the integrated likelihood (Occam), with the **sharp** constant. Cauchy–Schwarz arguments of the C2 type lose constants and give a sign only for σ above a non-sharp multiple of σ̄.

**The sharp constant (Gaussian proxy, valid while k_eff ≪ n).** Per fitted mode, at scale s: ½[β·ρ/(1 + ρ) − log(1 + ρ)], β := σ̄/s, σ̄ := τ(1−τ)/f₀. Summing over modes with ρ_r = (k_eff/r)⁶, k_eff ≍ n·ℓ^{−1/3}:

  log Z̃_s(ℓ) ≈ −(π/6)·(6 − σ̄/s)·k_eff(ℓ).

- If s > σ̄/6, the fixed point d log Z̃/d log ℓ = b₀ℓ gives λ ≍ (n/b₀)^{3/4}: the measured law.
- If s < σ̄/6, the evidence *rewards* roughness and there is no fixed point with λ → ∞.
- With σ learned, the profile over s gives the same threshold at s = σ₀ (envelope theorem): **(LO) σ₀,ₙ > σ̄ₙ/6**.

**(LO) and (NI) are different conditions.** In the proxy the profile evidence is convex in the fitted fraction κ = k_eff/n (a supremum over s of functions affine in κ), which would make (NI) imply (LO). The exact numbers contradict this: Gaussian noise at τ = 0.01 has (NI) margin 2.65 but σ₀/σ̄ = 0.07 < 1/6. So the proxy fails at κ of order one, and the true profile can have an interior maximum: **partial interpolation**, with λ bounded or slowly growing. I therefore expect both conditions to be needed.

**Gaussian noise.** σ₀/σ̄ = φ(z_τ)²/(τ(1−τ)): 0.64 at τ = 0.5; 0.22 at 0.05; 0.18 at 0.035; 0.16 at 0.03; 0.14 at 0.025; 0.07 at 0.01. So (LO) fails for **τ < 0.032 and τ > 0.968**. Prediction (testable in R-A1's setup): at τ = 0.01 or 0.025 the learned λ does not follow n^{3/4}; its exponent drops, and the radius slope flattens. At τ = 0.05 the ratio 0.22 is close to 1/6, so slow drift is plausible there too.

**What a proof would need.** A two-sided realized evidence estimate at fixed (s, ℓ), exact to 1 + o(1) in the exponent constant: Knight's identity, a uniform quadratic lower bound for the remainder on the fitted family (plausible while k_eff ≪ n), a Hanson–Wright bound for the score quadratic form, and a Gaussian comparison for the Laplace prior that keeps the constant (the product MGF ∏(1 − tⱼ²/ℓ²)^{−1} = exp{(1 + o(1))Σtⱼ²/ℓ²} is available only when max|tⱼ| ≪ ℓ). Then the same at κ of order one, where the proxy is wrong. I see no way to do this by Tuesday.

---

## 6. Tuesday: one route, and its risk

**Route.** Prove **Theorem H**, and state the result as *Felipe's exact method plus a safeguard floor λ ≥ κn^p, 0 < p ≤ 3/4*:
1. Lemma Lev (leverage of the spline space) and the Huber-body width (§4.2 steps 2–3).
2. Theorem H at fixed σ, uniform on compacts, λ mixed (steps 4–6 reuse V2T).
3. σ learned: Lemma S as in V2T. Result: Huber-loss contraction at n^{−2p/7}·polylog, σ/σ₀ → 1, no (EM), no σ ≥ σ̄, over the whole class.
4. Corollary for the exact method by §4.1, conditional on the posterior of λ staying above the floor.
5. Proposition O in the paper as the reason a safeguard is needed: without it the method is provably inconsistent for some laws of the class.

**Why this one.** It is the only route whose every step is identified with existing tools. With p ≤ 3/4 and small κ the floor sits below the measured posterior λ ∝ n^{0.76–0.94}, so in practice the sampler is Felipe's; the n^{5/2} floor, by contrast, binds from n ≈ 4000. The rate is slow but it is a theorem at the learned σ.

**Main risk.** Theorem H is a sketch: Lemma Lev, the Markov replacement for Bousquet, and the gauge of the non-homogeneous Huber body are new and unaudited, and step 3 depends on Lemma F (audit pending). If Lemma Lev fails, fall back to audited W with an ℓ₂ body, which needs sup-norm and returns to C1's window. Second risk, empirical and **UNTESTED**: that κn^{3/4} really does not bind on S and VS at the paper's n and τ. Pilot: rerun the R-A1 cells with the truncated-Gamma λ-step and compare MSE and the binding frequency with the original; cost = one R-A1 pass.

**Not recommended for Tuesday.** A theorem for the exact method under (NI) + (LO). It needs the sharp Occam bound of §5 and has no fallback.

## 7. Not verified

- No numerics: the (NI) margins and σ₀/σ̄ values are hand computations for Gaussian noise; the paper's Beta and mixture designs were not evaluated.
- Propositions O and R and the Jacobian identity are short and elementary, but were written in one pass and are unaudited.
- Theorem H: exponents and the list of steps only. The constant c₀ in Λ₋ ≫ (log n)^{c₀} was not tracked (the binding requirements are J log n/n → 0 and nε² = o(nr²)).
- §5 is a proxy calculation throughout.
