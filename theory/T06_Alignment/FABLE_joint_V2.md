# Joint argument for V2 (σ and λ both learned), and final read of Theorem C

*Fable, planning consult for Theory, 2026-11-23. Exponent-level only. Everything in §1 is SKETCH or CONJECTURE; nothing is proved. §2's verdict is a verdict. Notation: C1, S, L6, `astra_learned_lambda.md`; p_n = Gamma(1, b_n), b_n = c·n^{−5/2}; nε\*² ≍ (n log n)^{1/6}; Z̃_s(ℓ) := ∫e^{−ℛ/s}dν_ℓ (centred evidence at σ = s, λ = ℓ).*

**Bottom line.** Do not prove a two-sided window. Mix over λ at fixed σ: the upper tail then needs no containment at all, Lemma S is uniform in λ by monotonicity, and the rate is set by the **lower** endpoint Λ₋ alone. The lower tail is the whole problem. It cannot hold uniformly on Lemma S's [l, H₀] (that is the counterexample). It is provable now only with a lower truncation of the λ-prior; untruncated, it needs an Occam bound with a sharp constant, conjecturally σ₀ > σ̄/6.

## 1. Q1: the joint argument

**Structure — SKETCH.** At fixed σ = s the θ-posterior is the λ-mixture (the penalty is σ-free). For a bad set B and any Λ₋,

  Π_s(B | y) ≤ Π_s(λ < Λ₋ | y) + ∫_{ℓ≥Λ₋} p_n(dℓ)·N_{s,ℓ}(B) / D_s,  D_s := ∫ p_n(dℓ)·Z̃_s(ℓ),

then Π(B | y) ≤ sup_{s∈I} Π_s(B | y) + Π(σ ∉ I | y).

**Mixed denominator — SKETCH.** Astra's mixed good-set bound uses only L2 and L3/L4q-M, not (EM): with J₀ = [n^{5/2}/V, 2n^{5/2}/V], p_n(J₀) ≥ const and D_s ≥ poly·e^{−C(ω₂)nε\*²} with probability → 1, uniformly on s ∈ I. No per-ℓ L6 event is needed.

**Upper tail: not needed — SKETCH.** Fix **one** body K′₋ := {‖δ‖ₙ ≤ r₋, TV(δ) ≤ T₀₋}, with T₀₋ = Tn³/Λ₋ and r₋² = C_r T^{2/7}n^{1/7}Λ₋^{−2/7}(log n)^{6/7}. For every ℓ ≥ Λ₋, including ℓ > n³/V:
- Step 5 of C1 is ℓ-free.
- Step 6: t ≤ (Λ₋/ℓ)·Γ/(Tn) + V/T₀₋ ≤ Γ/(Tn) + s₀, so the same Chernoff bound holds.
- Hence on the single event Ω_G(K′₋): N_{s,ℓ}(t > 1) ≤ poly·(e^{−ω₁fnr₋²/8} + e^{−Tn/4}) for all ℓ ≥ Λ₋ and all s ∈ I.

Dividing by D_s, the second term → 0 because nr₋² ≫ nε\*². C1's restriction (i′) was an artefact of letting T₀ shrink with ℓ; Astra's λ = n^{7/2} counterexample does not apply to a fixed body. Large λ is harmless because the mixture's denominator already pays for the oracle window. Requirements: Λ₋ ≫ n^{23/11}(log n)^{12/11} (sup-norm) and V ≪ T₀₋.

*If an explicit upper window is still wanted:* Π_s(λ > Λ₊ | y) ≤ e^{−b_nΛ₊}·poly·e^{ω₂(f/4)nr₊²}/D_s. With Λ₊ = n^{3−γ} this needs n^{1/2−γ} ≫ n^{2/7+2γ/7}, i.e. γ < 1/6 (with W) or γ < 5/18 (with Lemma F).

**Rate.** r₋² ≍ n^{1/7}Λ₋^{−2/7}: n^{−5/11} at Λ₋ = n^{23/11}, n^{−1/2} at n^{9/4}, n^{−4/7} at Λ₋ ≍ n^{5/2}. The C2 shell bound is also uniform over ℓ ≥ Λ₋ (the fine term ω²n⁶J^{−5}ℓ^{−2} decreases in ℓ; the truth shift is ℓ-free), so F → C2 gives n^{−5/6} up to logs when Λ₋ ≍ n^{5/2}.

**Lemma S uniform in λ — SKETCH, easy.** In S §2, λ enters only through the L3 radius-one mass (increasing in λ) and the roughness cost 2^{n−3}e^{−λnd/8} (decreasing in λ). Both are evaluated at inf J; the data events are λ-free. So S §2 holds for sup_{ℓ≥Λ₋} and for any mixture supported on [Λ₋, ∞), given Λ₋/log n → ∞. S §1 then follows from joint θ-contraction with no new λ estimate.

**Lower tail: the crux.** The hyperprior cannot do it: p_n(λ < Λ₋) ≈ cΛ₋n^{−5/2} is only polynomially small against D_s ≥ e^{−Cn^{1/6}}. One needs an **Occam (evidence upper) bound**:

  sup_{ℓ<Λ₋} Z̃_s(ℓ) ≤ exp{−κ(s)·n·Λ₋^{−1/3}},  with κ(s)·nΛ₋^{−1/3} > C·nε\*².  (★)

- **It is false on Lemma S's [l, H₀] in general.** That is exactly Astra's counterexample: at small fixed s the evidence rewards roughness. So "uniformly over σ ∈ [l, H₀]" is the wrong target when l is S's crude constant.
- **Conjectured sharp threshold — CONJECTURE (Gaussian proxy for the Laplace prior, quadratic Knight remainder).** Mode by mode, with β := σ̄/s and ρ_r = (k_eff/r)⁶,

  log Z̃_s(ℓ) ≈ ½Σ_r[βρ_r/(1+ρ_r) − log(1+ρ_r)] − bias = −(π/6)(6 − σ̄/s)·k_eff(ℓ) − bias,  k_eff ≍ nℓ^{−1/3}.

  So κ(s) > 0 **iff s > σ̄/6** (6 = 2 × difference order). Consistency: β ≤ 1 makes every term ≤ 0, which is the (EM) range; β > 6 rewards more degrees of freedom until k_eff ≍ n, which is the counterexample's bounded λ.
- With σ integrated out, (b + Q)^{−(n+a)} ≈ Q\*^{−n}e^{−nℛ/Q\*} on the localized region, so the effective scale is σ₀. **Minimal extra condition, conjecturally: σ₀,ₙ ≥ (1+η)σ̄/6**, plus a global no-interpolation condition **(NI): σ₀,ₙ < (1−η)·τ(1−τ)·n⁻¹E‖DZ‖₁** (crude comparison of the interpolating region's joint evidence with the good mode; it needs det(DDᵀ)^{1/n} → 1).
- **Warning for the method.** For Gaussian noise σ₀/σ̄ = φ(z_τ)²/(τ(1−τ)): 0.64 at τ = 0.5, 0.22 at 0.05, 0.14 at 0.025, 0.07 at 0.01. The measured range 0.13–0.23 at τ = 0.05, 0.95 straddles 1/6. Testable prediction: where σ₀/σ̄ < 1/6, learned λ/oracle drifts down with n. This matters for the joint levels 0.90–0.99.
- **Proving (★).** On the C1 window: C1 cones + Knight + Cauchy–Schwarz + a reverse small-ball bound (Anderson for the shift; Laplace-transform bound for the centred ball) give an exponent k_eff·[ωc√(jα) + Cω²/(2j⁵) − ω(f/4)α − (c_φ/2)α^{−1/5}], all terms ∝ k_eff. It is negative only for ω below an explicit, **non-sharp** constant, which may sit above σ₀ and make the theorem vacuous for the method. Below the C1 window (ℓ ≲ n^{23/11}) there is no localization and I have no route.

**Recommendation for Tuesday — SKETCH.** Prove the theorem for **V2t: V2 with the λ-prior truncated to λ ≥ λ_min,n := κ₋·n^{5/2}** (or κ₋n^{9/4}), κ₋ fixed below every learned λ at n = 500, so the truncation never binds there. The sampler change is a truncated-Gamma draw. The lower tail is then empty and everything above closes with existing lemmas: n^{−4/7}(log n)^{6/7} now (n^{−1/2} for n^{9/4}), n^{−5/6} via F → C2. Untruncated V2 stays CONJECTURE, conditional on (★).

**Side remark — CONJECTURE.** The memo's "λ ∝ n^{21/8}" for V2 ignores bias. With b_n ∝ n^{−5/2} the hyperprior is nearly flat near the oracle (b_nλ = O(1)), so λ is set by the evidence: near n^{5/2}/V for truths with TV ≍ V, and up to n^{21/8} only for truths with no bias. The mixed argument does not care.

## 2. Q2: final read of THEOREM_C.md

**Verdict: FIX** (one substantive finding; at the oracle λ ≍ n^{5/2}/V the assembly is correct: ACCEPT there).

1. **Substantive: C1's hypothesis (ii) is dropped.** Theorem C assumes only n^{23/11}(log n)^{12/11} ≪ λ ≪ n³/V. C1 also requires (ii): a common ε and centre with prior budget C_pr·nε² and nε² = o(nr²). C1 verifies it only at the oracle. It fails near the top of the window: the L4q-M charge forces ε² ≳ V²λ^{5/3}n^{−5}, and ε² ≪ r² then needs **λ ≪ n^{108/41}V^{−42/41}** (≈ n^{2.63}). With L4 only (exact truth centre) the range is λ ≲ (n³/V)^{3/4}. Beyond n^{108/41} the stated rate is unproved and probably false for a worst-case truth, since the bias exceeds r_n. *Fix:* state Theorem C at λ ≍ n^{5/2}/V, or carry (ii) as an assumption, or replace the upper limit by n^{108/41}V^{−42/41} after checking join J8 away from the oracle.
2. **Disintegration: correct.** The penalty is σ-free and λ is deterministic, so θ | σ = s is exactly Π_s. The supremum is inside the expectation, as C1 delivers; measurability is S §3.
3. **Compactness: correct.** (l, H₀) depend on (k, d, B, V) only, not on λ or n, so [1/H₀, 1/l] is a fixed compact for C1.
4. **Conclusion 2: correct.** L10-I on K′ with r⁴T₀ → 0, which is (i).
5. **Conclusion 3: correct.** |Q − Q\*|/n ≤ ‖δ‖₁,ₙ ≤ ‖δ‖ₙ ≤ r_n gives (H); S §1 needs nothing else.
6. **Cosmetic.** Add n ≥ 5 (L3). Say that the oracle rule λ ≍ n^{5/2}/V presumes V. The status line "PROVED" should read "PROVED at the oracle" until finding 1 is applied.
