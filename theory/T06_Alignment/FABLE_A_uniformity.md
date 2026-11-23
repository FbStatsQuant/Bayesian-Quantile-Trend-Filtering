# Uniformity of Theorem LO in ω and ℓ, and the A-rule posterior statement on the top window

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute. Builds on `FABLE_A_three_lemmas.md` (Theorem LO, audited at fixed (ω, ℓ): `reviews/AUDIT_astra_LO.md`, findings 1–9), follows the repair route of finding 11, and answers finding 10. Reuses V2T Steps 3–4 and C1 (audited). Written in one pass; **not audited**.*

**Labels.** PROVED = every line is written here and rests on audited statements or on the standard inequalities named in §7. SKETCH = argument given, a detail open.

## 0. Verdict

**Theorem U is PROVED** (subject to audit): for the A-rule at a fixed compact scale interval with β < 6 at its small-scale end,

  sup_P E_P sup_{ω∈I} Π_ω(L_n ≤ λ < Λ₋,ₙ | y) → 0,  L_n := C·n^{99/43}(log n)^{c},  Λ₋,ₙ := c₋·n^{5/2}(log n)^{−1/2}.

No step broke. The proof uses three reductions and one strengthened node estimate:

| Step | Content | Status |
|---|---|---|
| U1 | ω: log-convexity of the evidence ⇒ only the two endpoints of I are needed | PROVED (§2.1) |
| U2 | ℓ: grid of ratio 1 + 1/n; the whole evidence (shift included) changes by ≤ e between nodes | PROVED (§2.2) |
| U3 | C1 bodies and Lemma 1 on O(log n) dyadic panels, bodies frozen at the left end | PROVED (§2.3) |
| N | Node estimate: Theorem LO with Hanson–Wright and Hoeffding tails, failure ≤ C·log n·n^{−4} per node, overhead O(log n) in the exponent | PROVED (§3), by substitution into the audited §4 of the three-lemmas note |
| A | Union over O(n log n) nodes; division by V2T's mixed denominator | PROVED (§4–5) |
| σ | **Theorem U-σ**: the same band has vanishing mass under the joint posterior (σ ~ IG learned), under t/(f(1−ϵ)d) < 6 | PROVED (§6); its extreme-scale part cites Lemma S §2 / V2T Step 2 as audited |

**How finding 10 is answered.**
- *Block matrices 𝒟(w) not ordered.* No ordering is used. Each node has its own fixed (w, c₀, Σ_±) and its own score events; there are only polynomially many nodes and each event fails with probability ≤ 2n^{−4}.
- *Signed shift ψᵀBy\*.* Controlled at each node by Hoeffding at cost O(log n); between nodes nothing is interpolated at the level of the score, because U2 interpolates the evidence itself.
- *K_n ≫ log n against K_n = o(min k_\*).* K no longer enters the exponent. It survives only in Lemma 1 (panels), where K_n = (log n)² costs a polylog factor in L_n. On this window min k_\* ≍ n^{1/6}(log n)^{1/6}, which absorbs the O(log n) overheads.

---

## 1. Setting and statement

- Model at fixed scale: λ ~ Gamma(1, b_n), b_n = c_b·n^{−5/2}, untruncated; Π_ω(· | y) the λ-mixed posterior at ω = 1/σ; Z̃_ω(ℓ) := ∫e^{−ωℛ}dc Π_ℓ(du).
- Assumptions of Theorem LO: (A1), full (A2) in secant form with (L, f, f̄), (A3) with V. t := τ(1−τ).
- I := [ω₁, ω₂] ⊂ (0, ∞) with **β₂ := ω₂·t/f < 6** (f the common lower secant constant, i.e. the minimum-density version). Then β(ω) ≤ β₂ on I.
- k(ℓ) := n·ℓ^{−1/3}; k_\*(ω, ℓ) := (2ω(1 − η)f)^{1/6}·k(ℓ)/π. On [L_n, n^{5/2}]: n^{1/6} ≤ k(ℓ) ≤ n^{10/43}; on [L_n, Λ₋,ₙ]: k(ℓ) ≥ c₋^{−1/3}·n^{1/6}(log n)^{1/6}.
- κ_min := min_{j=1,2}(1 − ε)(6 − β(ω_j))·(2ω_j(1 − η)f)^{1/6}/6 > 0, with ε, η, γ fixed as in Theorem LO for the margin 6 − β₂.
- J := [κn^{5/2}, 2κn^{5/2}] with κ := 1/c_b; nε_J² := C_ε·n^{1/6}[κ^{−1/3}(log m)^{1/6} + κ^{5/3}V²] (V2T Step 3).

**Theorem U.** There are C, c < ∞ and c₋ > 0, depending on the class constants, I, c_b and 6 − β₂ only, such that:

1. **(uniform evidence bound)** with probability ≥ 1 − C(log n)^{−1}, simultaneously for all ω ∈ I and all ℓ ∈ [L_n, n^{5/2}]:

   Z̃_ω(ℓ) ≤ n^{C}·exp{−κ_min·n·ℓ^{−1/3}};

2. **(posterior)** sup_P E_P sup_{ω∈I} Π_ω(L_n ≤ λ < c₋·n^{5/2}(log n)^{−1/2} | y) → 0.

---

## 2. Three reductions

### 2.1 U1: the scale, by log-convexity — PROVED

For every data vector and every ℓ, ω ↦ Z̃_ω(ℓ) = ∫e^{−ωℛ}dν_ℓ is log-convex on (0, ∞) (Hölder's inequality for the measure ν_ℓ; the integral is finite by L5). Hence for ω = (1 − θ)ω₁ + θω₂:

  Z̃_ω(ℓ) ≤ Z̃_{ω₁}(ℓ)^{1−θ}·Z̃_{ω₂}(ℓ)^{θ} ≤ max(Z̃_{ω₁}(ℓ), Z̃_{ω₂}(ℓ)).

So a bound n^{C}e^{−κ₁(ω_j)k(ℓ)} at both endpoints gives n^{C}e^{−κ_min k(ℓ)} on all of I. No grid in ω.

### 2.2 U2: the tuning, by density comparison — PROVED

For ℓ′ ≤ ℓ ≤ ℓ′(1 + 1/n), the normalized Laplace product densities satisfy, for every u ∈ ℝᵐ,

  (ℓ/2)^m e^{−ℓ‖u‖₁} ≤ (ℓ/ℓ′)^m·(ℓ′/2)^m e^{−ℓ′‖u‖₁} ≤ e·(ℓ′/2)^m e^{−ℓ′‖u‖₁}  (m ≤ n).

The integrand e^{−ωℛ} ≥ 0 is the same, so **Z̃_ω(ℓ) ≤ e·Z̃_ω(ℓ′)** for every ω, every data vector and every truth. Since k(ℓ′) ≥ k(ℓ), a bound e^{−κk(ℓ′)} at the node ℓ′ implies e·e^{−κk(ℓ)} at ℓ.

Grid: ℓ_g := L_n(1 + 1/n)^g, g = 0, …, G, with ℓ_G ≥ n^{5/2}. G ≤ 2n·log(n^{5/2}/L_n) ≤ n·log n.

### 2.3 U3: bodies and the remainder, on dyadic panels — PROVED

Panels: Λ_p := 2^pL_n, p = 0, …, P, P ≤ log₂n. A node ℓ_g belongs to the panel with Λ_p ≤ ℓ_g < 2Λ_p.

**Frozen body.** K′_p := {‖δ‖ₙ ≤ r_p, TV(δ) ≤ Tn³/Λ_p}, C1's body at λ = Λ_p (audited C1 with Lemma W; its window λ ≫ n^{23/11} contains [L_n, n^{5/2}]). Let Ω_{G,p} be C1's event for K′_p; P₀(Ω_{G,p}ᶜ) ≤ 1/n (Bousquet at level log n, as in V2T Step 4). By V2T Step 4, eqs. (3)–(4) (frozen body; the Chernoff bound uses only the law of ℓ‖u‖₁ and Λ_p/ℓ ≤ 1), on Ω_{G,p}, for **all** ℓ ≥ Λ_p and all ω ∈ I:

  N_{ω,ℓ}(K′_pᶜ) ≤ n^{C}·(e^{−ω₁f·n·r_p²/8} + e^{−Tn/4}),  and n·r_p² ≥ n^{c}·k(Λ_p).

**Lemma 1 on a panel.** Apply Lemma 1 of the three-lemmas note (with the audit's fixes: open active interval, s = s(min(x_a, r_p²)), 3 ≤ X ≤ m/4) to the body K′_p, with shells starting at x₀,p := (2Λ_p)^{−1/3} and with K := K_n := (log n)². Its condition (S), evaluated at (Λ_p, x₀,p), changes by absolute factors only and holds on the window once L_n ≥ C(K_n/η)^{36/5}(log n)^{18/5}n^{54/25}, which is implied by the definition of L_n (99/43 > 54/25). On its event Ω_{R,p} (probability ≥ 1 − 6.3/K_n), for all δ ∈ K′_p:

  R(δ) ≥ (1 − η)(f/2)‖δ‖₂² − η(f/4)·n·x₀,p ≥ (1 − η)(f/2)‖δ‖₂² − η(f/4)·k(ℓ)  for every ℓ < 2Λ_p.

**Consequence.** On Ω_{G,p} ∩ Ω_{R,p}, for every ℓ ∈ [Λ_p, 2Λ_p) and ω ∈ I (three-lemmas §4.1, with K′_p in place of K′(ℓ); 𝒵 does not involve the body):

  Z̃_ω(ℓ) ≤ e^{ωη(f/4)k(ℓ)}·𝒵_ω(ℓ) + n^{C}(e^{−ω₁fnr_p²/8} + e^{−Tn/4}),  𝒵_ω(ℓ) := ∫exp{ω⟨ψ, δ⟩ − (a/2)‖δ‖₂²}dc Π_ℓ(du).  (1)

Both events are free of ω. Their total failure over the panels is ≤ (P + 1)(1/n + 6.3/K_n) ≤ C/log n.

---

## 3. The node estimate with strong tails — PROVED by substitution

Fix a node (ω, ℓ) with ω ∈ {ω₁, ω₂}, ℓ = ℓ_g. Run §4.2–4.6 of the three-lemmas note (exact mixture formula, monotonicity, splitting of the mixture) unchanged, with its own fixed (w, c₀, Σ_±, Σ^{(i)}) for this node. Only the score events of §4.4 are replaced.

**Tail inequalities.** ψ has independent, mean-zero coordinates with values in [τ − 1, τ].
- (HW) Hanson–Wright: for a fixed symmetric Q, P(|ψᵀQψ − t·tr Q| > x) ≤ 2exp{−c_HW·min(x²/‖Q‖_F², x/‖Q‖_op)}. For Q = aM with M = Σ(I + aΣ)^{−1}: ‖Q‖_op ≤ 1 and ‖Q‖_F² ≤ d := a·tr M. So with x_d := (4d·log n/c_HW)^{1/2} + 4 log n/c_HW: P(|ψᵀ(aM)ψ − t·d| > x_d) ≤ 2n^{−4}.
- (H) Hoeffding: for a fixed vector b, P(|⟨b, ψ⟩| > x‖b‖₂) ≤ 2e^{−2x²}.

**Replacements.**
- (Q1′) main gain: ½ω²ψᵀM₊ψ ≤ (β′/2)·d₊ + (β′/(2t))·x_{d₊}, d₊ = a·tr M₊, off an event of probability 2n^{−4}. Since d₊ ≤ C·k_\* and k_\* ≥ c·n^{1/6}, the deviation (β′/(2t))x_{d₊} is ≤ η·k_\* for n ≥ n₀.
- (Q2′) shift: with x² = 2 log n in (H), off probability 2n^{−4}: −ω⟨B₊y\*, ψ⟩ − (a/2)‖B₊^{1/2}y\*‖² ≤ sup_z[ω√(2 log n)·z − (a/2)z²] = **(ω/f′)·log n** (using ‖B₊y\*‖ ≤ ‖B₊^{1/2}y\*‖, audit finding 1).
- (Q3′) flat part, **one event for all nodes**: P_N has rank 3; by (H) on three orthonormal directions, ‖P_Nψ‖₂² ≤ 6 log n off probability 6n^{−4}; cost (ω/(2f′))·6 log n.
- (Q4′) dyadic family for atypical variances, levels i ≥ 0, κ^{(i)} = 2^{i/6}k_\*:
  - κ^{(i)} ≤ n (at most 6 log₂n levels): (HW) for M^{(i)}, each off probability 2n^{−4}; with Lemma 2a (crude gain) the gain is ≤ β′[(π²/6)κ^{(i)} + 1] + (β′/(2t))x_{d_i} ≤ C₂′·κ^{(i)}, since x_{d_i} ≤ C(κ^{(i)} + log n) and κ^{(i)} ≥ k_\* ≥ log n;
  - κ^{(i)} > n: deterministic bound n·ω/(2f′) ≤ C₂′κ^{(i)};
  - shift at level i: (H) with x² = 2 log n + i, off probability 2n^{−4}e^{−2i}; cost (ω/(2f′))(2 log n + i) ≤ C₂′κ^{(i)}.

  So the audited bound "exponent ≤ C₂·k_\*·2^{i/6}" holds with a constant C₂′ **free of K**, and c₀ ≍ k_\*^{6/5} + log n, w ≍ k_\*^{6/5} + log n exactly as in audit finding 3. The block-window condition is again ℓ ≥ C·n^{99/43} up to the logarithm absorbed in L_n.

**Node proposition.** At each node, off an event of probability ≤ C·log n·n^{−4} (plus the single event of (Q3′)):

  log 𝒵_ω(ℓ) ≤ −(π/6)·k_\*·[6c₋^{1/6} − β′(1 + η)c₊^{1/6}/(1 − η²/2)] + 3η·k_\* + C·log n ≤ −(1 − ε/2)(π/6)(6 − β(ω))·k_\* + C·log n.

The C·log n collects (Q2′), (Q3′), the prefactor (2π/a)^{3/2} and 12 log k_\*. Everything else is the audited §4.5–4.6 (findings 1–4).

---

## 4. Proof of Theorem U, part 1 — PROVED

Let Ω be the intersection of: Ω_{G,p} ∩ Ω_{R,p} for all panels; the event of (Q3′); and the node events of §3 at all 2(G + 1) nodes. Then

  P₀(Ωᶜ) ≤ C/log n + 6n^{−4} + 2(n log n + 1)·C log n·n^{−4} ≤ C′/log n.

On Ω, at each node (ω_j, ℓ_g) in panel p, by (1) and the node proposition, and since ωη(f/4)k = O(η)·k_\* and n·r_p² ≥ n^{c}k(ℓ_g):

  Z̃_{ω_j}(ℓ_g) ≤ n^{C}·exp{−(1 − ε)(π/6)(6 − β(ω_j))k_\*(ω_j, ℓ_g)} = n^{C}·exp{−κ₁(ω_j)·k(ℓ_g)}.

By U2, for ℓ ∈ [ℓ_g, ℓ_{g+1}]: Z̃_{ω_j}(ℓ) ≤ e·n^{C}e^{−κ₁(ω_j)k(ℓ)}. By U1, for ω ∈ I: Z̃_ω(ℓ) ≤ e·n^{C}e^{−κ_min k(ℓ)}. ∎

## 5. Proof of Theorem U, part 2 — PROVED

For ω ∈ I, with Λ₋ := c₋n^{5/2}(log n)^{−1/2} ≤ n^{5/2}:

  Π_ω(L_n ≤ λ < Λ₋ | y) = ∫_{L_n}^{Λ₋}p_n(dℓ)Z̃_ω(ℓ) / ∫p_n(dℓ)Z̃_ω(ℓ) ≤ [sup_{L_n≤ℓ≤Λ₋}Z̃_ω(ℓ)] / ∫_J p_n(dℓ)Z̃_ω(ℓ).

- *Numerator*, on Ω: ≤ e·n^{C}·exp{−κ_min·k(Λ₋)} = e·n^{C}·exp{−κ_min·c₋^{−1/3}·n^{1/6}(log n)^{1/6}}.
- *Denominator*, on V2T's event Ω_D for the window J (ω-free; P₀(Ω_Dᶜ) ≤ 1.25/(nε_J²)), for all ω > 0: ≥ V₃(ε_J√n/2)³·p_n(J)·exp{−(3 + ω₂(1.25C₁ + 1))·nε_J²}, with p_n(J) = e^{−1}(1 − e^{−1}) and nε_J² ≤ C_J·n^{1/6}(log n)^{1/6}.
- *Ratio*: ≤ n^{C′}·exp{−[κ_min·c₋^{−1/3} − (3 + ω₂(1.25C₁ + 1))C_J]·n^{1/6}(log n)^{1/6}}, deterministic and → 0 once c₋ is small enough that the bracket is positive.

Hence sup_P E_P sup_{ω∈I}Π_ω(L_n ≤ λ < Λ₋ | y) ≤ o(1) + P₀(Ωᶜ) + P₀(Ω_Dᶜ) → 0. Measurability of the supremum over ω is by continuity, as in C1. All constants depend on the law only through the class constants, so the supremum over P is free. ∎

---

## 6. Theorem U-σ: the learned scale — PROVED (written after §1–5, same pass)

**Model.** σ ~ IG(a, b) (fixed a, b > 0), λ ~ Gamma(1, b_n), both untruncated; Lemma S's assumptions (uniform integrability, d ≤ σ₀,ₙ ≤ B).

**Condition (LO), class form.** There is ϵ ∈ (0, ½) with **t/(f·(1 − ϵ)·d) < 6**. (For one law: t/(f·σ₀,ₙ) < 6 with margin.)

**Theorem U-σ.** Under (LO), with L_n and Λ₋,ₙ as in Theorem U (constants now depending also on ϵ, d, B):

  sup_P E_P Π(L_n ≤ λ < Λ₋,ₙ | y) → 0  for the joint posterior.

*Proof.* Notation: Z(s, ℓ) = s^{−n}e^{−Q\*/s}·Z̃_{1/s}(ℓ) (uncentred evidence), σ̂ := Q\*/n, g(s) := log s + σ̂/s, so s^{−n}e^{−Q\*/s} = e^{−n·g(s)} and g(s) − g(σ̂) = h(s/σ̂) with h(ρ) := log ρ + 1/ρ − 1 ≥ 0. Let I_ϵ := [(1 − ϵ)σ₀,ₙ, (1 + ϵ)σ₀,ₙ] (deterministic for each law), contained in the fixed interval [(1 − ϵ)d, (1 + ϵ)B] =: I_hull. Work on: Theorem U's event Ω for the scale interval I_hull (its small-scale end has β < 6 by (LO)); Ω_D; the panel events Ω_{G,p}; Lemma S's data events; and {|σ̂/σ₀,ₙ − 1| ≤ ϵ/4} (Lemma S §1's law of large numbers). Write 𝔅 := [L_n, Λ₋,ₙ) and W_ϵ := ∫_{I_ϵ}IG(ds)e^{−n·g(s)}.

- *Denominator.* By V2T Step 3 (valid for all ω at once): ∫IG(ds)∫p_n(dℓ)Z(s, ℓ) ≥ W_ϵ·D_J, with D_J := V₃(ε_J√n/2)³p_n(J)·exp{−(3 + (1.25C₁ + 1)/((1 − ϵ)d))·nε_J²}. Moreover W_ϵ ≥ c·n^{−1/2}·e^{−n·g(σ̂) − 1}: on |s/σ̂ − 1| ≤ n^{−1/2} one has h ≤ 1/n, the interval lies in I_ϵ for large n, and the IG density is bounded below on [d/2, 2B].
- *(a) Scales in I_ϵ.* Theorem U part 1 on I_hull gives Z̃_{1/s}(ℓ) ≤ n^{C}e^{−κ_min k(Λ₋,ₙ)} for all s ∈ I_ϵ, ℓ ∈ 𝔅. So this part of the numerator is ≤ W_ϵ·n^{C}e^{−κ_min k(Λ₋,ₙ)}; W_ϵ cancels, and the ratio is the deterministic one of §5, → 0 for small c₋.
- *(b) Scales in Lemma S's compact [l, H₀] outside I_ϵ.* On Ω_{G,p}, for every ℓ ≥ Λ_p and ω ∈ [1/H₀, 1/l]: on K′_p, ℛ ≥ M − G ≥ −(f/4)n·r_p², and ν_ℓ(K′_p) ≤ V₃(√n·r_p)³; with the cone bounds of §2.3, Z̃_ω(ℓ) ≤ n^{C}·exp{(f/(4l))·n·r_p²} = e^{o(n)}, uniformly on 𝔅 (r_p → 0). And s ∉ I_ϵ with |σ̂/σ₀,ₙ − 1| ≤ ϵ/4 forces |s/σ̂ − 1| ≥ ϵ/2, so e^{−n·g(s)} ≤ e^{−n·g(σ̂) − c(ϵ)n}, c(ϵ) := min(h(1 + ϵ/2), h(1 − ϵ/2)) > 0. Ratio to the denominator: ≤ e^{−c(ϵ)n + o(n)}·√n/(c·D_J) → 0, since D_J = e^{−O(n^{1/6}(log n)^{1/6})}.
- *(c) Extreme scales.* Lemma S §2, whose bounds hold for every ℓ and use the floor only through "ℓ ≥ L_n ≫ log n" on 𝔅 (V2T Step 2's monotonicity remarks): the parts s > H₀, {s < l, Q ≥ qn} and {s < l, Q < qn} of the numerator are e^{−(C+1)n}-small against a denominator ≥ e^{−n·g(σ̂) − o(n)} ≥ e^{−Cn}, for Lemma S's choice of (l, H₀).

Summing (a)–(c) and adding the probabilities of the complements of the events proves the claim. ∎

**What was checked and what was not.** (a) and (b) are written in full above. For (c) I rely on Lemma S §2 and V2T Step 2 as audited (roughness cost 2^{n−3}e^{−ℓnd/8} at ℓ ≥ L_n; flat bounds C_ks³), without re-deriving their constants for the band 𝔅.

## 6b. What Theorems U and U-σ do not give

- **Below L_n.** Nothing: Lemma 1 has no sup-norm localization there (gap G4), and bounded tuning needs the numerical certificate (G5). Theorem U therefore excludes the band [L_n, Λ₋,ₙ) only; it is not yet the lower-tail input (LT) of Theorem H's Corollary P.
- **Above Λ₋,ₙ.** Not needed: that is where the posterior is allowed to be.
- **Averaged density.** The min-density version only (audit finding 9).

## 7. Conditions, and what was not verified

- n₀ conditions: those of Theorem LO at each node (audit findings 3–5: the block window with c₀, w ≍ k_\*^{6/5} + log n; 3 ≤ X ≤ m/4; κ_±, k_\* above fixed numerical bounds), now implied uniformly by the definition of L_n; k_\* ≥ C·log n/η² (true: k_\* ≥ c·n^{1/6}); C1's conditions at each Λ_p (window λ ≫ n^{23/11}, VΛ_p = o(n³)); V2T's (N6) for the window J.
- Standard inequalities quoted, not re-derived: Hanson–Wright for independent bounded mean-zero coordinates (Rudelson–Vershynin form, absolute constant c_HW); Hoeffding; Hölder (log-convexity); Bousquet as used in C1.
- I did not re-open the audited §4.5–4.6 beyond checking that the score events enter only through: one upper bound on ψᵀM₊ψ, one on the shift bracket, one on ‖P_Nψ‖², and the family (Q4). If the audit's fixes changed how they enter, §3 must be re-read against the fixed text.
- The exponent C in n^{C} and the constants C₂′, c₋ are not tracked numerically.
- Written in one pass; nothing numerically checked.

---

## Theory response (2026-11-23)

**Status: PROVED (one pass), UNAUDITED.** A cross-family audit by Astra has been requested.

**Checked by Theory:**
- U1: log-convexity in ω by Hölder, so a convex combination is bounded by the max of the endpoints.
- U2: (ℓ/ℓ′)^m ≤ (1 + 1/n)^n ≤ e, and the right-hand side is monotone, since k(ℓ′) ≥ k(ℓ).
- The grid count: G ≈ n·log(n^{5/2}/L_n) = O(n log n).

**These answer audit finding 10's three objections:**
- per-node matrices with per-node Hanson–Wright;
- a per-node Hoeffding bound on the signed shift;
- K_n removed from the exponent.

**Scope:**
- **Excludes** the band [C·n^{99/43}polylog, c₋n^{5/2}(log n)^{−1/2}] under the joint posterior with σ learned, for the min-density β < 6.
- **Does not cover** λ below n^{2.30} (gap 4, open) or the averaged β (gap 2).
- **Caveat:** §3 substitutes stronger tails into §4 of the three-lemmas note. It must be re-read against that text once audit fixes 1–4 are applied.
