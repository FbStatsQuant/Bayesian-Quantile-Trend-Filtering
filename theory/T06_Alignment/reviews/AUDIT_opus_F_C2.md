# Audit: Lemma F, W′ and Lemma C2 (`FABLE_lemmaF_C2.md`, with `FABLE_rate_gap.md`)

*Independent referee (Opus), 2026-11-23, about 14:15 CT. Pure mathematics, re-derived by hand. No compute was run and nothing was committed. Inputs read: `C1_any_sigma.md` (with its audit response), `W_width_lemma.md`, `../T05_Proofs/THEOREM_B_COMPLETE.md` (L2, L3, L4q, L5, L6) and `../T05_Proofs/L10I_interpolation.md`. For the learned-σ remark only: `astra_sigma_concentration.md` and `reviews/AUDIT_opus_S.md`.*

## Bottom line

**C2 holds.** I re-derived every step on the focus list and found no mathematical gap. The rate

  ‖θ − θ\*‖²ₙ ≤ M·εₙ²,  εₙ² = C(log n)^{1/6}V^{1/3}n^{−5/6},

holds at the deterministic oracle λ. It holds at every fixed σ and uniformly on compact σ-intervals, **including σ < σ̄**. It is moment-free, and the supremum over ω sits inside the expectation. The findings below are editorial (1–3, 5). Finding 4 is a positive scope observation: the learned-σ rate looks to be two lines away.

## Verdicts

| Item | Verdict |
|---|---|
| Lemma F (§1), brief re-check | **ACCEPT** |
| W′ (§2.1–2.2) | **ACCEPT** |
| C1 with W′ (§2.3), substitution algebra only | **ACCEPT**. r² ≍ T^{2/7}λ^{−2/7}(log n)^{6/7}; window λ ≫ n^{21/11}(log n)^{12/11}; both re-derived |
| C2.1: Knight identity, R ≥ 0, convention at atoms, mean zero | **ACCEPT** |
| C2.2: E e^{−2ωRᵢ} ≤ e^{−ωmᵢ} on \|δᵢ\| ≤ min(L, 3f/(4ωf̄)); the threshold is met on C1's body | **ACCEPT** |
| C2: Cauchy–Schwarz split; Tonelli plus Markov on the remainder factor | **ACCEPT** |
| C2.3: coarse event {‖P_Jψ‖² ≤ J} and its probability | **ACCEPT** (the repair of the planning note is correct and needed) |
| C2.4: fine factor (drop the u-indicator, keep the c-volume, exact Laplace MGF, 2ω‖t‖∞ < λ, truth shift) | **ACCEPT** |
| C2.5: dyadic shells, M threshold | **ACCEPT WITH FIXES** (findings 1–3, editorial) |
| Uniformity in ω ∈ [ω₁, ω₂], supremum inside the expectation | **ACCEPT** |
| Random-centre circularity | **ACCEPT**: there is none |
| **Overall** | **ACCEPT WITH FIXES (editorial)**. The rate n^{−5/6}(log n)^{1/6} stands |

---

## What I re-derived (C2)

**Knight (§3.1).** Write ψ = τ − 1{Z < 0} and R(δ) = X(δ) + δψ. Substituting L2's closed form gives:
- for δ > 0: R = δ − clip(Z, 0, δ) − δ1{Z < 0}. This is 0 for Z < 0, δ − Z for 0 ≤ Z ≤ δ, and 0 for Z > δ.
- for δ = −a < 0: R = a1{Z < 0} − clip(−Z, 0, a). This is 0 for Z ≥ 0, Z − δ for δ ≤ Z < 0, and 0 for Z < δ.

So R ≥ 0 for every data value, and e^{−ωℛ} = e^{ω⟨ψ,δ⟩}e^{−ωR} ✓.

Under upper (A2), the generalized-inverse quantile gives F(0−) ≤ τ ≤ F(0). Continuity at 0 then gives F(0−) = F(0) = τ, so Eψ = 0, P(Z = 0) = 0 and E R = m ✓. The remark about mixing conventions is correct.

**Remainder (§3.2).**
- *Integration by parts.* ∫_{[0,δ]}(δ − z)²dF = ∫₀^δ 2(δ − z)(F(z) − F(0−))dz. The boundary term vanishes because g(δ) = 0. This is ≤ f̄δ³/3 ✓.
- *Exponential bound.* m ≥ fδ²/2. With e^{−x} ≤ 1 − x + x²/2 for x ≥ 0, the inequality 2ω²ER² ≤ ωm holds exactly when |δ| ≤ 3f/(4ωf̄) ✓.
- *Threshold on C1's body.* At the oracle, C1 (with W) has r² ≍ n^{−4/7} and T₀ ≍ TV√n. Then s_K = 6r + 7.06r^{4/5}T₀^{1/5} ≍ n^{−9/70} → 0. So s_K ≤ s₀ = min(L, 3f/(4ω₂f̄)) for n ≥ n₀(ω₂) ✓. Since s₀ is a positive constant for every fixed ω₂, this works at any σ, however small.
- *Tonelli and Markov.* Tonelli applies to a deterministic E_a (ν is σ-finite). Markov at the level e^{2ηωa·nε²}, followed by the square root, gives f/2 → f/4 ✓.

**Cauchy–Schwarz bookkeeping.**
- Each factor carries ν-volume^{1/2}, so the product has V₃(2a·nε²)^{3/2}, with no double count. The c-section bound uses ‖Nᵀδ‖₂ = ‖c − c̄(u)‖₂ ≤ ‖δ‖₂ (L5) ✓.
- The exponent is −ω(f/4 − η) + ω·f/8 = −ω(f/8 − η) ✓.
- No independence between the factors is used. Each factor is bounded on its own event, followed by a union bound ✓.

**Coarse factor (§3.3).** ψᵢ is two-point: τ − 1 with probability τ, τ with probability 1 − τ.
- Var ψᵢ = τ(1 − τ) ≤ ¼ and Var ψᵢ² = τ(1 − τ)(1 − 2τ)² ≤ ¼.
- The cross-covariance between the diagonal and off-diagonal parts of Q vanishes, since each term has an unpaired ψ with mean zero.
- Hence Var Q ≤ ¼‖P_J‖²_F = (J + 3)/4. Chebyshev gives 4(J + 3)/(9(J − 1)²) = O(n^{−1/6}) ✓.
- The bound (J·2a·nε²)^{1/2} ≤ (f/8)a·nε² ⇔ J ≤ (f²/128)a·nε² holds for every a ≥ M ✓.
- The planning note's Markov version gives only 3/4, and its J + 3 overshoots the budget. The repair is right.

**Fine factor (§3.4).**
- *Identity.* tⱼ = ⟨(I − P_J)Seⱼ, ψ⟩, using symmetry of P_J and (I − P_J)N = 0 ✓.
- *Concentration.* Hoeffding (range 1) plus a union bound give (2m)^{−3} ✓.
- *Laplace MGF.* For (λ/2)e^{−λ|x|}, E e^{sx} = λ²/(λ² − s²) ✓.
- *Ratio.* 2ωt_∞/λ ≲ ωV·J^{−5/2}√(log n) ≍ n^{−5/12}(log n)^{1/12} → 0 ✓.
- *Log bound.* −log(1 − x) ≤ 2x on [0, ½] holds by convexity and the endpoint check 0.693 ≤ 1 ✓.
- *C_fine.* ½ log-MGF ≤ 4ω²Σtⱼ²/λ² ≤ 8ω²C_F²a₁^{−2}V²·m·J^{−5}·log(2m). With V²n = (nε²)⁶/(C⁶ log n), J ≥ (f²/256)M·nε², m ≤ n and log(2m) ≤ 2 log n, this gives C_fine = 16C_F²(256/f²)⁵/(a₁²C⁶) exactly ✓.
- *Role of the log.* The (log n)^{1/6} in εₙ² is precisely what absorbs the √(log m) in ‖t‖∞. The crude bound Σtⱼ² ≤ m‖t‖²∞ costs nothing in the exponent.
- *Truth shift.* ω·t_∞V/n² ≍ n^{1/12}V^{1/6}(log n)^{1/12} = o(nε²) ✓.
- *Dropping the u-indicator* is legitimate, because the integrand is positive.

**Assembly (§3.5).**
- K′ ∩ shell ⊂ E_{a_k} because s_K ≤ s₀ ✓.
- The ratio of the denominator volume to V₃(ε√n/2)³ is (8a)^{3/2} ✓.
- The shell sum is ≤ e^{−(cM − K)nε²}·Σ_k(8·2^kM)^{3/2}e^{−c(2^k − 1)M·nε²}, where the last sum is bounded. So it tends to 0 once c·M > K, with c = ω₁(f/8 − η) and K = ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂²/M⁵ + o(1) ✓.
- The left side grows in M and the last term of K shrinks, so a threshold exists.
- C1 as audited suffices here: λ ≍ n^{5/2} ≫ n^{23/11}, and Vλ = o(n³) ✓.

**Uniformity in ω and the supremum inside the expectation.**
- e^{−ωx} is convex in ω, so its maximum over [ω₁, ω₂] is at an endpoint, and the bound N_ω ≤ N_{ω₁} + N_{ω₂} holds pointwise ✓.
- J, E_a (s₀ is built with ω₂), Ω_ψ and Ω₆ (L6) are all ω-free.
- The only ω-dependent events are the Markov events at the **two endpoints**, for O(log n) shells. This is a finite family, so the good event is one ω-free set, on which sup_ω of the ratio is bounded deterministically. Hence

  E sup_ω Π ≤ P(bad) + bound + E sup_ω Π_ω(K′ᶜ | y) (C1) ✓.

- Measurability follows C1's continuity argument.
- All the bounds on P(bad) use only boundedness of ψ, (A2) constants, f̄, L and V, so they are uniform in P ✓.

**Random centre.** E_a is deterministic and centred at θ\*. Ω_ψ is free of δ and of ω. Localization enters only as the set inclusion K′ ∩ shell ⊂ E_a, with C1 bounding Π(K′ᶜ | y) separately. Nothing is recentred at θ̂, and nothing uses the posterior under study. **There is no circularity.**

## Lemma F and W′ (brief re-check)

**Lemma F.**
- *Formula for s_k.* s_k(i) = C(i − k − 1, 2)1{i ≥ k + 3}, which equals p_i(k) for i ≥ k + 1 ✓.
- *Case 1, support claim (the point §4 asks a second reader to check).* For i ≥ κ + 2h + 1, all four indices k ∈ {j, κ, κ + h, κ + 2h} are ≤ κ + 2h ≤ i − 1. So no truncation is active, and exactness on the quadratic k ↦ p_i(k) kills e(i) ✓.
- *Case 1, size and constants.* k ↦ s_k(i) is nonincreasing, Σ|a_l| ≤ 5/4, and (★) is valid (t⁴ ≤ ∫_t^{t+1}x⁴). (9/4)²·32/20 = 8.1 ✓.
- *Cases 2–4.* The bounds (h + 1)⁵/20, m + 2 − J′h ≤ h + 1 and 3.5⁵/20 = 26.26 are all correct. The conversion constants 16.2 and 29.1 are correct.
- *Uniformity.* The lemma is uniform in j, as C2 requires.

**W′.**
- *Head.* √(tr P_J) ✓.
- *Tail.* Hoeffding with |εᵢ| ≤ 1 gives variance proxy ‖w_j‖² ✓.
- *Choice of J.* All three branches are correct (q < 1; 1 ≤ q ≤ m; q > m, where V_J = ℝⁿ and √n ≤ √3 + √q).

---

## Findings

**1. CONFIRMED (editorial): the shell count must cover r².** §3.5 says "k_max ≤ log₂(r²/(Mε²))". The shells (a_kε², 2a_kε²] cover (Mε², r²] only if 2^{k_max+1}M ≥ r²/ε², and a floor can miss the top shell.
*Fix:* k_max := ⌈log₂(r²/(Mε²))⌉. The count is still O(log n), and nothing else changes.

**2. CONFIRMED (editorial): the range of η.** Lemma C2 says "η > 0". The conclusion is vacuous unless 0 < η < f/8, and the M threshold implicitly assumes this.
*Fix:* state η ∈ (0, f/8), for example η = f/16.

**3. CONFIRMED (presentation): name the good event.** "On Ω_ψ …, with probability ≥ 1 − e^{−2ηωa·nε²}" mixes an event with a probability.
*Fix:* define Ω_R(a, ω) := {∫_{E_a}e^{−2ωR}dν ≤ ν(E_a)·e^{−ω(f/2 − 2η)a·nε²}}, so that P(Ω_R(a, ω)ᶜ) ≤ e^{−2ηωa·nε²}. Then state §3.5 on

  Ω := Ω_ψ ∩ Ω₆ ∩ ⋂_{k ≤ k_max, ω ∈ {ω₁, ω₂}} Ω_R(a_k, ω).

Ω is ω-free once the endpoints are fixed. This one sentence is what makes the supremum inside the expectation airtight. The mathematics is already in §3.5; only the naming is missing.

**4. PLAUSIBLE (scope; positive, and worth Theory's attention): the learned-σ rate may already follow.**
- **The chain.**
  - C2's uniformity holds on **any** fixed compact [ω₁, ω₂] ⊂ (0, ∞). That includes ω₂ = 1/l for Lemma S §2's coarse interval I = [l, H₀], however small l is. No (EM) is used, and s₀ = min(L, 3f·l/(4f̄)) stays a positive constant.
  - The penalty is σ-free (AUDIT_opus_S #6), so Π(θ | σ = s, y) = Π_s.
  - Hence

    E Π^θ(‖δ‖²ₙ > Mεₙ² | y) ≤ E sup_{s∈I}Π_s(… | y) + E Π(σ ∉ I | y) → 0,

    with M = M(l, H₀). This needs **no** concentration of σ on σ₀.
- **A second consequence.** C1 alone (‖δ‖ₙ ≤ r → 0 uniformly on I) appears to supply Lemma S's Hypothesis U on the full coarse interval. AUDIT_opus_S (around line 107) flagged that as the open input, because the (EM) route cannot reach small l.
- **Caveats.**
  - I did not re-audit Lemma S §2.
  - The hypothesis sets must be intersected: Lemma S's moment and uniform-integrability conditions, plus full (A2) with common constants, plus (A3).
  - M grows like (ω₂/ω₁) and ω₂², i.e. like H₀/l, so the constant may be large. It is still fixed in n.
- **Fix/next step:** Theory writes this as a short corollary ("C2 on I, plus Lemma S §2, gives the learned-σ rate at deterministic λ") and sends it for audit. Until then, keep it at CONJECTURE.

**5. CONFIRMED (housekeeping).**
- **The planning note quotes superseded claims.** `FABLE_rate_gap.md` still states three things that §3 replaces:
  - the J + 3 event;
  - failure probability e^{−ηωa·nε²};
  - log-MGF C/(M⁵ log n) and "Σtⱼ² ≲ n(n/J)⁵".

  *Fix:* add a one-line pointer at the top: "superseded by `FABLE_lemmaF_C2.md` §3; quote only that file."
- **An unused remark.** Lemma F's remark on unequal gaps (Σ|a_l| ≤ 2·max/min + (g₁ + g₂)²/(4g₁g₂)) is unverified and unused. It is consistent at g₁ = g₂ (3 ≥ 5/4).
  *Fix:* delete it or mark it as an unchecked remark.

## Resulting rate

Nothing fails. Under (A1), full (A2), (A3), deterministic λ ≍ n^{5/2}/V and C1's hypotheses at the oracle:

  sup_P E_P sup_{ω∈[ω₁,ω₂]} Πₙ,ω(‖θ − θ\*‖²ₙ > M·εₙ² | y) → 0,  εₙ² = C(log n)^{1/6}V^{1/3}n^{−5/6}.

This holds for every M with ω₁(f/8 − η)M > ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂²/M⁵. It is valid at every fixed σ, including σ < σ̄, and uniformly on compacts. C1 with W′ gives n^{−5/7}(log n)^{6/7} as a stand-alone fallback.

**Out of scope, unchanged:** learned λ (the exact MGF needs 2ω‖t‖∞ < λ for the realized λ) and the 1/log n sharpening of the fine log-MGF (not needed).
