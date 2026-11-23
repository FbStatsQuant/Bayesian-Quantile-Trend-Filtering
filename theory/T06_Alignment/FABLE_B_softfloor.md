# Task B-softfloor: which Gamma(a_n, b_n) replaces the λ floor?

*Fable, research sub-agent for Theory, 2026-11-23. Pure mathematics, by hand; no compute; **not audited**. Built on `FABLE_A_n56.md` (V0T\*, C2-mix), `FABLE_V2T_proof.md` (Steps 3–4), `astra_sigma_concentration.md` (Lemma S), `astra_noFloor.md` (obstruction, audited), `FABLE_A_noFloor.md` (reduction §4.1, proxy §5) and `FABLE_B_lowerbound.md` (Theorem LB, unaudited).*

**Model.** π(θ, λ, σ | y) ∝ σ^{−n}e^{−Q(θ)/σ}·λ^m e^{−λ‖Dθ‖₁}·Gamma(λ; a_n, b_n)·IG(σ; a_σ, b_σ), **no truncation**. Shape a_n, rate b_n, prior mean μ_n := a_n/b_n. IG fixed (as in the audited theorems). m = n − 3, t := τ(1−τ), k := min(τ, 1−τ).

**Labels.** PROVED = every line is written here and rests only on audited statements or elementary facts. SKETCH = argument given, a step not written. CONJECTURE = heuristic.

## 0. Answers

| # | Claim | Status |
|---|---|---|
| 1 | **Evidence upper bound.** At any σ in a compact [l, H₀], the evidence of {λ < Λ} relative to the good-set denominator is ≤ [P_prior(λ < Λ)/p_w]·exp{C₂n + O(nε̄²)}, C₂ = (B + 1)/l. So the needed suppression is **e^{−C₂n}**, linear in n | PROVED (§2) |
| 2 | Inside C1's window the same ratio is ≤ exp{C·n·r_ℓ²} = exp{C·n^{8/7}ℓ^{−2/7}·polylog}, sub-exponential | PROVED from C1's cones (§2.3) |
| 3 | **Is c₀ ≤ 0 under σ₀ < 2τ(1−τ)R with margin? Not shown, and I expect no.** That condition only rules out the full-interpolation corner (σ → 0, λ ≈ 1/R). For λ between polylog(n) and n^{5/2} the sign is that of 6 − σ̄/σ₀ (proxy), which is negative for the paper's Gaussian and Beta designs at τ ≤ 0.05 and τ ≥ 0.95 | corner: PROVED in skeleton (§2.4; the denominator is that of Proposition R, unaudited); sign elsewhere: CONJECTURE |
| 4 | **Soft-floor theorem.** a_n = A·n (any A > 0) and b_n = a_n/(κn^{5/2}) (mean κn^{5/2}): all three conclusions of V0T\* hold with no floor, rate n^{−5/6}(log n)^{1/6} | PROVED by assembly (§3), given two short extensions of audited steps, written in §3.2 |
| 5 | **Threshold.** Class-wide, a_n ≥ C·n/log n is sufficient (C large) and a_n ≤ c·n/log n is fatal (c small): below it Astra's law defeats the method for every polynomial mean | necessity: PROVED by substitution (§4); sufficiency for C·n/log n: SKETCH |
| 6 | **Adaptivity is lost.** Any shape that passes the threshold has relative prior s.d. ≤ (log n/n)^{1/2}, while the evidence moves by only e^{±O(n^{1/6})} across the oracle scale. The posterior of λ is pinned at the prior mean: the method becomes "deterministic λ = κn^{5/2}" | lower pin: SKETCH; upper bound λ ≤ (1+η)(m + a_n)/b_n: PROVED (§5) |
| 7 | **Felipe's a = n, b = 1 is not covered, and cannot be.** No interpolation, but λ is pinned in [n/K, 2.1n], far below n^{21/11}; by Theorem LB its posterior is no faster than c·n^{−1/3} | pinning: PROVED (§6); rate floor: PROVED given `FABLE_B_lowerbound.md` (unaudited) |
| 8 | Same family, right scale: **a = n, b_n = n^{−3/2}/κ**, i.e. b_n = b₅₀₀·(500/n)^{3/2} | covered by item 4 (A = 1) |
| 9 | b_n ≍ b₀(500/n)^{5/2} with fixed shape: not rescued by any choice of b₀ | PROVED (audited no-floor scope) |

**One-sentence conclusion.** Within the Gamma family a class-wide theorem without truncation exists only at shapes a_n ≳ n/log n, and there the prior fixes λ; adaptivity in λ and a class-wide guarantee are incompatible in this family. Adaptivity can only come from a design condition (a sharp Occam bound), which is still the open conjecture of `FABLE_A_noFloor.md` §5.

---

## 1. Framework — PROVED

**Reduction** (`FABLE_A_noFloor.md` §4.1; holds for any prior on λ). For every Λ > 0 and event B,

  Π(B | y) ≤ Π^{Λ}(B | y) + Π(λ < Λ | y),

where Π^{Λ} is the posterior under the prior Gamma(a_n, b_n) conditioned on [Λ, ∞). V0T\* holds for **any** law p_n on [Λ₋, ∞), Λ₋ = κ₋n^{5/2}, whose denominator window has −log(mass) = o(nε̄²). So a no-floor theorem follows from:
- **(W)** a window [Λ_w, 2Λ_w] ⊂ [Λ₋, ∞) at the oracle order with prior mass bounded below;
- **(S)** Π(λ < Λ₋ | y) → 0.

**Gamma lower tail (Chernoff).** For K > 1: P(Gamma(a, b) ≤ μ/K) ≤ exp{−a·I(K)}, I(K) := log K − 1 + 1/K. (Optimize e^{θx}(b/(b + θ))^a at θ = a/x − b.)

**Conditional of λ.** λ | θ, y ~ Gamma(m + a_n, b_n + ‖Dθ‖₁), stochastically below Gamma(m + a_n, b_n) for every θ.

---

## 2. Deliverable 1: evidence of {λ < Λ} against the good-set denominator

Notation of V2T: N_{ω,ℓ}(B) = ∫_B e^{−ωℛ}dν_ℓ, ν_ℓ = dc ⊗ Π_ℓ; p = Gamma(a_n, b_n); Π_s(· | y) the posterior at fixed σ = s with λ mixed.

### 2.1 Universal upper bound — PROVED

For every ℓ > 0, ω > 0 and every data vector,

  N_{ω,ℓ}(ℝⁿ) = e^{ωQ\*}∫∫e^{−ωQ(θ)}dc Π_ℓ(du) ≤ e^{ωQ\*}·8π/(ωk)³.

*Proof.* Q(θ) ≥ k‖y − θ‖₁ ≥ k‖c − Nᵀ(y − Su)‖₂, so ∫e^{−ωQ}dc ≤ ∫_{ℝ³}e^{−ωk‖c‖₂}dc = 8π/(ωk)³ for every u; Π_ℓ has mass 1. ∎

On {Q\* ≤ n(B + 1)} (probability → 1, Lemma S §1) and for ω ∈ [ω₁, ω₂]: N_{ω,ℓ}(ℝⁿ) ≤ 8π(ω₁k)^{−3}·e^{ω₂(B+1)n}. It is free of ℓ and of the prior.

### 2.2 Suppression criterion — PROVED

**Denominator** (V2T Step 3, which uses only the prior mass of the window, with any prior): on Ω_D, for all ω > 0,

  ∫p(dℓ)N_{ω,ℓ}(ℝⁿ) ≥ V₃(ε̄√n/2)³·p_w·exp{−(3 + ω(1.25C₁ + 1))nε̄²},  p_w := p([Λ_w, 2Λ_w]).

**Lemma SF1.** On Ω_D ∩ {Q\* ≤ n(B + 1)}, for every Λ > 0:

  sup_{s∈[l,H₀]}Π_s(λ < Λ | y) ≤ [P_p(λ < Λ)/p_w]·C(ε̄√n)^{−3}·exp{ω₂(B + 1)n + (3 + ω₂(1.25C₁ + 1))nε̄²}.

So (S) holds at fixed or compact-uniform σ as soon as

  **−log P_p(λ < Λ₋) ≥ (C₂ + η)·n + log(1/p_w),  C₂ := ω₂(B + 1) = (B + 1)/l.**

This answers "how much suppression is needed": **exponential in n with constant C₂**, in the worst case. The obstruction's e^{c₀n} shows that linear in n cannot be improved class-wide; only the constant can.

### 2.3 Inside C1's window — PROVED from C1 Steps 2–6 (as extended in V2T Step 4)

For Λ in C1's window and the prior restricted to [Λ, ∞), with K′ the body frozen at Λ: on Ω_G(Λ),

  ∫_{ℓ≥Λ}p(dℓ)N_{ω,ℓ}(ℝⁿ) ≤ V₃(√n r_Λ)³·e^{ω(f/4)n r_Λ²} + (cone terms → 0).

*Proof.* On K′: −ℛ ≤ G − M ≤ G ≤ (f/4)nr_Λ² and ν̄(K′) ≤ V₃(√n r_Λ)³; the cones A₁, A₂ are V2T (3)–(4). ∎

So for slabs [Λ_i, 2Λ_i] in the window the evidence gain over the truth is at most exp{C·n r²_{Λ_i}}, with n r_Λ² ≍ n^{8/7}Λ^{−2/7}(log n)^{6/7} (audited W; n·Λ^{−2/7} with W′). At Λ ≍ n^{5/2} this is e^{O(n^{3/7})}. With the C2 shells it would be e^{O(nΛ^{−1/3})} — SKETCH (`FABLE_B_joint.md` §4, step 1).

**Between polylog(n) and n^{21/11}** nothing better than §2.1 is proved. Theorem H of `FABLE_A_noFloor.md` (SKETCH) would give exp{C·n·ℓ^{−2/7}·polylog}.

### 2.4 What σ₀ < 2τ(1−τ)R with margin gives — PROVED for the corner only

- *Corner.* On {Q(θ) ≤ nh}: ‖Dθ‖₁ ≥ n(R_n − 8h/k), and ∫s^{−n}e^{−Q/s}dθ = t^{−n} for every s. So the evidence of this region is ≤ J_n·t^{−n}·sup{π̄(u) : ‖u‖₁ ≥ n(R_n − 8h/k)}, π̄ the λ-mixed density. For weak priors (a_n = O(1)) this is poly(n)·[2e·t·(R_n − 8h/k)]^{−n}, against a truth evidence ≥ poly(n)⁻¹(eσ₀)^{−n}e^{−o(n)}. The ratio is [σ₀/(2t(R − 8h/k))]ⁿ, exponentially small under the margin. This is the converse of Proposition O.
- *Everything else.* Partial fits, Q(θ) between nh and (1 − η)Q\*, at λ between constants and n^{5/2}, are not controlled by this condition. The only universal bound there is §2.1.
- *Expected sign — CONJECTURE.* In the Gaussian proxy the log-evidence at tuning ℓ is −(π/6)(6 − σ̄/σ₀)·k_eff(ℓ), k_eff ≍ nℓ^{−1/3}. If σ̄/σ₀ < 6 the evidence itself penalizes small λ by e^{−c·nℓ^{−1/3}} and a weak prior would do. If σ̄/σ₀ > 6 it rewards small λ by e^{+c·nℓ^{−1/3}}. From `../T05_Proofs/checks/gap_ratio_check.out` (σ̄ computed with the minimal density over the design): σ̄/σ₀ = 6.70 (Gaussian, τ = 0.05, 0.95), 6.56 (Beta, 0.95), 7.4–20.9 beyond 0.95; below 6 at central levels and for Mixed up to 0.96. **So for the extreme levels the margin in the necessary condition does not imply c₀ ≤ 0.**

---

## 3. Deliverable 2: the soft-floor theorem

### 3.1 Statement

**Theorem SF.** Assume the hypotheses of V0T\* (class constants fixed). Let **a_n = A·n with A > 0** and **b_n = a_n/(κn^{5/2})**, κ > 0 fixed, no truncation. Then there are constants K_A < ∞ and M such that, with κ₋ := κ/K_A and ε̄² := C_ε n^{−5/6}[κ₋^{−1/3}(log m)^{1/6} + (κ/2)^{5/3}V²]:
1. sup_P E_P Π(λ < κ₋n^{5/2} | y) → 0, and Π(λ > (1 + η)(1 + 1/A)κn^{5/2} | y) ≤ e^{−c(η)n} for every data vector;
2. sup_P E_P Π(‖θ − θ\*‖²ₙ > M·ε̄² | y) → 0: rate n^{−5/6}(log n)^{1/6};
3. the sup-norm and σ/σ₀,ₙ conclusions of V0T\*.

### 3.2 Proof (assembly) — PROVED given the two extensions (G1), (G2)

**(G1) V0T\* with the denominator window away from the floor.** Let p_n be any law on [Λ₋, ∞) and J_w = [Λ_w, 2Λ_w] with Λ₋ ≤ Λ_w. V2T Step 3 on J_w: the spread bound uses ℓ ≥ Λ_w ≥ Λ₋ (L3 is monotone in ℓ), the shift charge uses ℓ ≤ 2Λ_w. So V-3 holds with p_n(J_w) in place of p₀,ₙ and κ₋^{5/3}V² replaced by (2Λ_w/n^{5/2})^{5/3}V²/2^{5/3} in ε̄². The numerator steps (V-4, C2-mix) use only "p_n is a law on [Λ₋, ∞)" and the first term of ε̄². Nothing else changes.

**(G2) Lemma S §2 for the unfloored Gamma mixture (volume form).** S §2 uses the u-prior at two places.
- *Evidence.* Π̄(‖P⊥Su‖ₙ ≤ 1) ≥ P_p(λ ≥ λ₁)·e^{−n} with λ₁ = C√(log m) (L3, monotone in ℓ), and P_p(λ ≥ λ₁) → 1. So the uncentred joint evidence is ≥ e^{−Cn}, as in S §2.
- *Roughness, without the IG negative moment.* On S §2's data event, {Q(θ) < qn} ⊂ {‖Dθ‖₁ ≥ nd/4}. The λ-mixed prior has Lebesgue density π̄(u) = 2^{−m}·(b_n^{a_n}Γ(m + a_n)/Γ(a_n))·(b_n + ‖u‖₁)^{−(m+a_n)}, decreasing in ‖u‖₁, and dc du = J_n dθ with J_n = det(DDᵀ)^{1/2} ≤ 20^{m/2} (Hadamard; each row of D has squared norm 20). Since ∫s^{−n}e^{−Q(θ)/s}dθ = t^{−n} for every s, the evidence of {Q < qn}, over **all** scales, is

  ≤ J_n·t^{−n}·sup{π̄(u) : ‖u‖₁ ≥ nd/4} ≤ exp{a_n log b_n + m log(m + a_n) − (m + a_n)log(nd/4) + O(n)} = exp{−a_n·log(n/b_n) + O(n + a_n)}.

  (Γ(m + a)/Γ(a) ≤ (m + a)^m, and m log((m + a_n)/n) = O(n) for a_n ≤ Cn.) Divided by e^{−Cn} this → 0 **iff a_n·log(n/b_n) ≥ C′·n** for a class constant C′. With b_n = a_n/(κn^{5/2}) and a_n = An this reads (5/2)A·n log n(1 + o(1)) ≥ C′n: true for every A > 0.

The other steps of S §2 (upper tail; {s < l, Q ≥ qn}) use only that the u-prior has mass 1. So σ ∈ [l, H₀] and Q(θ) ≥ qn with posterior mass → 1. The audited S §2 route (IG negative moment e^{n log n}) would need the stronger (5/2)A > 1; the volume form removes that.

**Assembly.**
1. *σ-containment:* (G2).
2. *(S):* Lemma SF1 with Λ₋ := μ_n/K_A, K_A := exp{1 + (C₂ + η)/A + log 4/A}. Then a_n·I(K_A) ≥ (C₂ + η)n + n·log 4 ≥ (C₂ + η)n + log(1/p_w), since p_w = P_p(λ ∈ [μ/2, μ]) ≥ ¼ for large n (Λ_w := μ_n/2; the Gamma(a_n) law is asymptotically normal around its mean). Disintegrate over σ as in V2T Step 1.
3. *Floored part:* Π^{Λ₋} has a law on [Λ₋, ∞) with window mass ≥ ¼. Apply V0T\* in the form (G1).
4. *Upper bound on λ:* §1, conditional law, and Chernoff for Gamma(m + a_n, b_n) at (1 + η) times its mean (m + a_n)/b_n = (1 + 1/A)κn^{5/2}·(1 + o(1)).
5. Combine with the reduction of §1. ∎

**About the constants.** K_A is finite but enormous with the crude pair (l, H₀) of Lemma S (C₂ = (B + 1)/l ≥ 10⁵/(kd), `reviews/AUDIT_fable_S.md` finding 8). Two repairs, both SKETCH:
- re-disintegrate on the narrow interval of V0T\* after σ-consistency, which turns C₂ into ≈ (B + 1)/d;
- use §2.3 on dyadic slabs between μ_n/K_A and μ_n/e: the evidence gain there is e^{O(n^{3/7}K^{2/7})} against a prior cost e^{−An·I(K)}, so the floor can be raised to μ_n(1 − o(1)). Then κ₋ ≈ κ and the rate constant is that of deterministic λ = κn^{5/2}.

### 3.3 How weak can the shape be?

- **a_n·log n/n → ∞** (for instance n/√(log n)): Lemma SF1 gives Π(λ < μ_n·n^{−γ_n} | y) → 0 with γ_n → 0 — PROVED from §2.2, with σ-containment by (G2). The floor is then n^{5/2−o(1)}, inside C1's window; reaching the exact rate needs the slab refinement (SKETCH).
- **a_n = C·n/log n:** works for C larger than (22/13)(C₂ + 1) with W′, (22/9)(C₂ + 1) with audited W (the first-pass floor μ_n·n^{−(C₂+1)/C} must stay inside C1's window) — SKETCH.
- **a_n ≤ c·n/log n, c small:** fails class-wide (§4).

---

## 4. Necessity: Astra's law defeats every weak shape — PROVED by substitution into the audited obstruction

Astra's evidence comparison is prior-free in its numerator ("both remaining priors have unit mass"). Its denominator uses the prior only through the mass of a **fixed** rectangle around (ℓ, s) = (1/r, 0+), on which the integrand exceeds the numerator's rate by e^{2cn}; for her law 2c = log(q/(2tr)) = log(0.043/0.04028) = 0.065.

For Gamma(a_n, b_n) with mean μ_n = κn^p, the mass of a fixed interval [ℓ₁, ℓ₂] is at least (ℓ₂ − ℓ₁)·b_n^{a_n}ℓ₁^{a_n−1}e^{−b_nℓ₂}/Γ(a_n) = exp{−a_n[log(μ_n/ℓ₁) − 1] − O(log a_n) − o(a_n)} = exp{−p·a_n log n·(1 + o(1))}.

Hence: **if p·a_n·log n ≤ c·n** (for her law at p = 5/2: a_n ≤ 0.013·n/log n), the conclusion of the obstruction stands: Π(Q(θ) ≥ nq | y) ≤ e^{−cn/2}, and the posterior leaves a fixed neighbourhood of the truth. This covers every fixed shape with every polynomial rate schedule (item 9 of §0), and every shape o(n/log n).

So the threshold n/log n of §3.3 is sharp up to the constant. With an n-dependent IG prior the comparison would have to be redone; not examined.

---

## 5. What it does to adaptivity

- **Prior.** A shape a_n ≥ c·n/log n has relative s.d. a_n^{−1/2} ≤ (log n/(cn))^{1/2}.
- **Evidence.** Across the oracle scale the λ-evidence varies by e^{±O(nε̄²)} = e^{±O(n^{1/6})} (two-sided: L6 below; §2.3 with C2 shells above, SKETCH). The prior's log-density varies by a_n·I(K) ≈ a_n(K − 1)²/2.
- **Consequence — SKETCH.** The posterior of λ lies within relative distance (n^{1/6}/a_n)^{1/2} ≤ n^{−5/12}√(log n) of μ_n. The data cannot move λ. PROVED part: λ ≤ (1 + η)(m + a_n)/b_n always (§1).
- **Cost.** The theorem is that of deterministic λ = κn^{5/2}: rate-optimal for every κ, adaptive to V for none. The bound's constant is κ^{−1/3}(log n)^{1/6} + κ^{5/3}V². With the oracle 46× apart between S and VS, one fixed κ loses, in the bound, a factor 46^{1/3} ≈ 3.6 on the smooth design if κ = 1/V_max, or 46^{5/3} ≈ 590 on the rough design if κ = 1/V_min. Choose κ small.
- **Moderate shapes** (1 ≪ a_n ≪ n/log n) do not help: they already pin λ once a_n ≫ n^{1/6}, and they do not pass §4.
- **Where adaptivity could come from.** Only from the evidence itself penalizing small λ: a design condition of the type σ̄/σ₀ < 6 plus a sharp realized Occam bound (`FABLE_A_noFloor.md` §5). Then a weak prior with a_n = O(1) and b_n ≲ n^{−7/3} (so that the prior does not pull λ below n^{5/2}: the proxy fixed point is (n/b_n)^{3/4}) would self-tune to n^{5/2}/V. CONJECTURE; and by §2.4 it would exclude the extreme levels.

---

## 6. Deliverable 3: a = n, b = 1

- **No interpolation, σ contained — PROVED by (G2).** The condition a_n·log(n/b_n) ≥ C′n reads n log n ≥ C′n: true. So σ ∈ [l, H₀] and Q(θ) ≥ qn with posterior mass → 1, and §4's obstruction does not apply. (The audited S §2 route would not suffice here: P_p(λ < C log n) = e^{−n log n(1−o(1))} is the boundary case against the IG moment e^{n log n + O(n)}. The volume form is what settles it.)
- **λ is pinned at order n.**
  - Upper: λ | θ ≤_st Gamma(m + n, 1), so Π(λ > 2.1n | y) ≤ e^{−cn} for every data vector — PROVED.
  - Lower: Lemma SF1 with a_n·I(K) = n·I(K) ≥ (C₂ + η)n + log 4, i.e. Π(λ < n/K | y) → 0 for K = exp{2 + C₂ + η} — PROVED, with σ-containment by (G2). The denominator window is [n/2, n] with the L4 centre u_h = u\* (shift cost ≤ 2nV/n² → 0; L4q's hypothesis (R1) fails at ℓ ≍ n and is not used); its cost is e^{−O(n^{2/3}(log n)^{1/6})} = e^{−o(n)}.
- **Not covered.** λ ≍ n is below every window: C1 needs n^{21/11} (W′) or n^{23/11} (audited). No upper rate is proved at λ ≍ n for σ below σ̄; Theorem H (SKETCH) would give a Huber rate n^{−2/7}·polylog.
- **Cannot reach n^{−5/6}.** By Theorem LB (`FABLE_B_lowerbound.md`) on {λ ≤ 2.1n}: Π(Δ²ₙ(θ − θ\*) ≤ c₀(2.1n)^{−1/3} | y) → 0. So the posterior is **no faster than n^{−1/3}**, whatever the truth, quadratic truths included. Status: PROVED at fixed σ modulo the audit of that note; with σ learned it also needs the σ-containment above.
- **The fix inside Felipe's family.** Keep a = n and scale the rate: **b_n = n^{−3/2}/κ**, mean κn^{5/2}. This is Theorem SF with A = 1. In the paper's normalization: b_n = b₅₀₀·(500/n)^{3/2}, with b₅₀₀ = 500^{−3/2}/κ = 8.9·10⁻⁵/κ. For κ = 1/V: b₅₀₀ ≈ 0.014 (S, V ≈ 156) and ≈ 0.65 (VS, V ≈ 7276). Felipe's b = 1 at n = 500 corresponds to κ = 8.9·10⁻⁵, i.e. mean 500, close to the VS oracle (≈ 768) but 70× below the S oracle (≈ 3.6·10⁴).

---

## 7. Flags

- **Recommendation status: UNTESTED.** Nothing here was run. Theorem SF's prior makes the sampler's λ-step Gamma(m + a_n, b_n + ‖Dθ‖₁) with no truncation, which is a one-line change. Pilot to compare with Felipe's original before anything goes to HQ: the R-A1 cells (S and VS, n = 500–4000) with (a_n, b_n) = (n, n^{−3/2}/κ) at two values of κ; cost = one R-A1 pass per κ.
- **Theorem SF is asymptotic with poor constants** until the two repairs of §3.2 are written.
- **(G1) and (G2) are extensions of audited statements written here in a few lines; they have not been audited.**
- **The boundary case in §6** (exponent p·A = 1 for (n, 1)) is why its σ-containment is only SKETCH.
- **Honest reading for the paper.** In the Gamma/IG family, "no data-dependent tuning, no truncation, class-wide guarantee" forces λ to be effectively deterministic. The learned-λ feature of the method is then decorative asymptotically. A guarantee for a genuinely adaptive λ needs a restriction on the designs, not on the hyperparameters.
- **Not examined:** n- or τ-dependent IG hyperparameters. Pinning σ above σ̄/6 would restore the Occam sign, but σ̄ = τ(1−τ)/f depends on the unknown density and on the scale of the data, so it cannot be set without data.
