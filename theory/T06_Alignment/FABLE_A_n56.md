# Task A: Theorems C\* and V0T\* at n^{−5/6}(log n)^{1/6}, ready to switch on when the C2 audit passes

*Fable, research sub-agent for Theory, 2026-11-23 (CT session). Pure mathematics, no compute. Written from: `THEOREM_C.md` and `C1_any_sigma.md` (audited), `FABLE_V2T_proof.md` (audited, ACCEPT WITH FIXES), `FABLE_lemmaF_C2.md` = Lemma F + C2 (**audit running**), L5, L6, L10-I (audited). This note has not been audited.*

**Labels.**
- **PROVED** = every line is written here and rests only on audited statements.
- **PROVED\*** = every line is written here, but it uses Lemma F or a C2 item (§3.1–3.5 of `FABLE_lemmaF_C2.md`), whose audit is pending. These become PROVED when that audit passes with the items unchanged.
- **SKETCH** = argument given, a detail open. **CONJECTURE** = no argument.

## 0. Verdict

| Item | Status |
|---|---|
| Theorem C\* (σ learned, λ deterministic oracle): rate M·ε², ε² ≍ V^{1/3}n^{−5/6}(log n)^{1/6} | **PROVED\*** (§2). Pure assembly: Theorem C + C2 shells |
| Lemma C2-mix (shell numerator for the λ-mixed prior with floor) | **PROVED\*** (§3.2). The only new mathematics; four lines beyond C2 |
| Theorem V0T\* (σ and λ learned, floor κ₋n^{5/2}, constant or scaled b₀): rate M·ε̄², ε̄² ≍ n^{−5/6}[κ₋^{−1/3}(log n)^{1/6} + κ₋^{5/3}V²] | **PROVED\*** (§3). Theorem V2T + C2-mix shells |
| Sup-norm rate n^{−7/30}(log n)^{1/15} in both theorems | **PROVED\*** (L10-I on the intersection) |
| Rate constant in terms of (d, B) only; sharper law-dependent version | **PROVED\*** (§2.1, §4) |
| W′ / C1 at n^{−5/7} | **Not needed** by either theorem. Audited C1 (n^{−4/7}) suffices as the localizer, so the only pending dependency is Lemma F + C2 |
| Other floor exponents Λ₋ = κn^p; MSE prediction | SKETCH / CONJECTURE (§6) |

**Design choice that shortens both proofs.** The σ-interval is taken from the *conclusion* of the audited theorems (Theorem C, resp. V2T: σ/σ₀,ₙ → 1), not from Lemma S §2. So the interval is I = [(1 − η₁)d, (1 + η₁)B], the new part never touches Lemma S, and neither the rate constant nor n₀ involves the crude pair (l, H₀ = e^{C+1}).

**Answers to the three cancelled questions.**
1. *Fine score uniformly in ℓ ≥ Λ₋.* Yes, and uniformity is not even needed. The λ-mixed moment generating function is a mixture of products whose factors decrease in ℓ, so it is bounded by the single product at the floor (§3.2 (d)). The floor is exactly what makes this moment finite: without it, p_n charges ℓ < 2ω‖t‖∞ and the mixed MGF is +∞.
2. *Coarse step and shell assembly against the mixed denominator.* Yes. The coarse step and the remainder use the prior only through "probability measure in u". Cauchy–Schwarz must be applied **once to the mixed measure ν̄**, not per ℓ: applying C2 for each ℓ would need a continuum of Markov events.
3. *Large ℓ.* No problem (§3.4). Every numerator bound is prior-free or monotone in ℓ in the right direction; the truth shift is ℓ-free; the over-smoothing bias is paid only in the denominator window [Λ₋, 2Λ₋]. No upper truncation of λ is needed.

---

## 1. Common notation

- δ := θ − θ\*, TV(δ) := n²‖Dδ‖₁, ℛ(δ) = Q(θ) − Q(θ\*), ω = 1/σ, m = n − 3.
- ψᵢ := τ − 1{Zᵢ < 0}; Rᵢ(δ) := Xᵢ(δ) + δψᵢ ≥ 0 (C2 §3.1), so ℛ = −⟨ψ, δ⟩ + R.
- P_J, w_j = (I − P_J)Se_j, C_F = 29.1 (Lemma F); t := Sᵀ(I − P_J)ψ; t_∞ := C_F(n/J)^{5/2}√(2 log(2m)).
- **σ-interval.** σ₀,ₙ := n⁻¹ΣᵢE ρ_τ(Zᵢ) ∈ [d, B]. Fix η₁ ∈ (0, 1) (say ½). I := [(1 − η₁)d, (1 + η₁)B]; ω₁ := 1/((1 + η₁)B), ω₂ := 1/((1 − η₁)d); ρ := (1 + η₁)/(1 − η₁). I is deterministic and the same for every law of the class.
- s₀ := min(L, 3f/(4ω₂f̄)) = min(L, 3f(1 − η₁)d/(4f̄)).
- For a radius ε and a > 0: E_a := {aε² < ‖δ‖²ₙ ≤ 2aε², ‖δ‖∞ ≤ s₀}. Deterministic, centred at θ\*.
- γ ∈ (0, f/8): the Markov slack (C2's "η"; renamed because η is the theorems' tolerance).
- J := ⌊(f²/128)·M·nε²⌋, with the ε of the theorem in question.
- Ω_ψ := {‖P_Jψ‖₂² ≤ J} ∩ {‖t‖∞ ≤ t_∞}. It is free of ω, λ, a and the prior. P₀(Ω_ψᶜ) ≤ 4(J + 3)/(9(J − 1)²) + (2m)^{−3} (C2 §3.3–3.4).

---

## 2. Theorem C\*: σ learned, λ deterministic at the oracle

### 2.1 Statement

**Model.** π(θ, σ | y) ∝ σ^{−n}e^{−Q(θ)/σ}·e^{−λ‖Dθ‖₁}·IG(σ; a, b); flat prior on quadratics; a, b > 0 fixed; penalty σ-free.

**Assumptions** (exactly those of Theorem C). Fixed interior τ; (A1); full (A2) in secant form with (L, f, f̄); (A3) with V; row-average uniform integrability of ρ_τ(Zᵢ) with a common modulus; d ≤ σ₀,ₙ ≤ B with d > 0. λ deterministic, a₁n^{5/2}/V ≤ λ ≤ a₂n^{5/2}/V.

**Constants.**
- ε² := C·(log n)^{1/6}V^{1/3}n^{−5/6}, with C the oracle constant for which C1's hypothesis (ii) holds with constant C_pr (joins J5–J8).
- C_fine := 16·C_F²·(256/f²)⁵/(a₁²C⁶) (C2 §3.4).
- T ≥ 4, T₀ := Tn³/λ, r as in C1.
- **M\*** := the smallest M ≥ 1 with ω₁(f/8 − γ)·M > ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂². Multiplying by (1 + η₁)B:

  (f/8 − γ)·M > ρ(B/d)·(1.44C₁ + 1) + (1 + η₁)B·C_pr + ρ(B/d)·C_fine/((1 − η₁)d).

  (For M ≥ 1, C2's term C_fine·ω₂²/M⁵ is ≤ C_fine·ω₂².)

**Theorem C\*.** For every M > M\* and every fixed η > 0:
1. sup_P E_P Π(‖θ − θ\*‖²ₙ > M·ε² | y) → 0, i.e. rate **n^{−5/6}(log n)^{1/6}**;
2. sup_P E_P Π(‖θ − θ\*‖∞ > s\* | y) → 0, with s\* := 6√M·ε + 7.06·(√M·ε)^{4/5}T₀^{1/5} ≍ **n^{−7/30}(log n)^{1/15}**;
3. sup_P E_P Π(|σ/σ₀,ₙ − 1| > η | y) → 0.

No (EM), no σ ≥ σ̄, no moments beyond uniform integrability.

### 2.2 Proof

| Step | Statement | Reuses | Status |
|---|---|---|---|
| C\*-1 | Conclusion 3; in particular sup_P E_P Π(σ ∉ I \| y) → 0 | Theorem C, conclusion 3, at η = η₁ (and at the given η) | PROVED |
| C\*-2 | Π(B \| y) ≤ sup_{s∈I}Π_s(B \| y) + Π(σ ∉ I \| y), for every event B | Theorem C's disintegration (penalty σ-free; measurability by continuity in s) | PROVED |
| C\*-3 | sup_P E_P sup_{ω∈[ω₁,ω₂]}Πₙ,ω(K′ᶜ \| y) → 0, K′ = {‖δ‖ₙ ≤ r, TV(δ) ≤ T₀}; on K′, ‖δ‖∞ ≤ s_K → 0 | C1 as audited (uniform on any compact ω-interval; r² ≍ n^{−4/7}(log n)^{6/7}); L10-I | PROVED |
| C\*-4 | sup_P E_P sup_{ω∈[ω₁,ω₂]}Πₙ,ω(‖δ‖²ₙ > Mε² \| y) → 0 for M > M\* | C2 §3.5 verbatim on [ω₁, ω₂]; L6 | PROVED\* |
| C\*-5 | Conclusion 1 | C\*-2 with B = {‖δ‖²ₙ > Mε²}, then C\*-4 and C\*-1 | PROVED\* |
| C\*-6 | Conclusion 2 | C\*-2 with B = K′ᶜ gives TV(δ) ≤ T₀ with mass → 1; intersect with conclusion 1; L10-I at (a, T) = (√M·ε, T₀) | PROVED\* |

**Detail of C\*-4** (written out so that the file is self-contained).
- Shells a_k := 2^kM, 0 ≤ k ≤ k_max := ⌈log₂(r²/(Mε²))⌉ = O(log n).
- For n ≥ n₀, s_K ≤ s₀, so K′ ∩ {a_kε² < ‖δ‖²ₙ ≤ 2a_kε²} ⊂ E_{a_k}.
- Two endpoints: ω ↦ e^{−ωx} is convex, so N_ω(E_a) ≤ N_{ω₁}(E_a) + N_{ω₂}(E_a) for ω ∈ [ω₁, ω₂]. C2 is applied at ω₁ and ω₂ only.
- On Ω_G ∩ Ω₆ ∩ Ω_ψ ∩ (the 2(k_max + 1) Markov events), for all ω ∈ [ω₁, ω₂] at once:

  Πₙ,ω(‖δ‖²ₙ > Mε² | y) ≤ Πₙ,ω(K′ᶜ | y) + 2Σ_k(8·2^kM)^{3/2}·exp{−[ω₁(f/8 − γ)·2^kM − ω₂(1.44C₁ + 1) − C_pr − C_fine·ω₂²/M⁵ − ζ_n]·nε²},

  with ζ_n := ω₂·t_∞V/(n²·nε²) → 0 (truth shift). With Δ := ω₁(f/8 − γ)M − [ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂² + ζ_n] > 0, the k-th exponent is ≤ −2^kΔ·nε², so the sum → 0.
- The probability of the complement is at most

  P₀(Ω_Gᶜ) + 1.44/(nε²) + 4(J + 3)/(9(J − 1)²) + (2m)^{−3} + 4e^{−2γω₁M·nε²},

  the last term bounding Σ_k 2·e^{−2γω₁2^kM·nε²} once 2γω₁M·nε² ≥ log 2. ∎

**What is new in C\*:** nothing mathematical. It is Theorem C with C2 §3.5 in place of C1 in the rate step, on the interval I supplied by Theorem C itself.

---

## 3. Theorem V0T\*: σ and λ learned, λ floor

### 3.1 Statement

**Model** (as V2T). π(θ, λ, σ | y) ∝ σ^{−n}e^{−Q(θ)/σ}·λ^m e^{−λ‖Dθ‖₁}·p_n(λ)·IG(σ; a, b), with p_n a probability law on [Λ₋, ∞), Λ₋ := κ₋n^{5/2}, κ₋ > 0 fixed. Write J₀ := [Λ₋, 2Λ₋] and p₀,ₙ := p_n(J₀).
- **V0T (Felipe + floor):** p_n = Gamma(1, b₀) truncated to [Λ₋, ∞), b₀ constant. Then p₀,ₙ = 1 − e^{−b₀Λ₋} → 1.
- **V2T (scaled):** b_n = c_b n^{−5/2}. Then p₀,ₙ = 1 − e^{−c_bκ₋}, a constant.
- **In general:** any p_n on [Λ₋, ∞) with −log p₀,ₙ = o(nε̄²). This is stricter than V2T's o(nr²). (If only −log p₀,ₙ ≤ c_p·nε̄², add c_p to the right side of the threshold below.)

**Assumptions.** Those of Theorem C\*, with no condition on λ and no relation between κ₋ and V.

**Constants.**
- ε̄² := C_ε·n^{−5/6}·[κ₋^{−1/3}(log m)^{1/6} + κ₋^{5/3}V²], C_ε as in V2T Step 3.
- C̄_fine := 16·C_F²·(256/f²)⁵/C_ε⁶. It is free of κ₋ and V.
- T ≥ 4, T₀ := (T/κ₋)√n, r² := C_r(T/κ₋)^{2/7}n^{−4/7}(log n)^{6/7} (V2T's frozen body K′).
- **M̄\*** := the smallest M ≥ 1 with ω₁(f/8 − γ)·M > 3 + ω₂(1.25C₁ + 1) + C̄_fine·ω₂², i.e.

  (f/8 − γ)·M > 3(1 + η₁)B + ρ(B/d)·(1.25C₁ + 1) + ρ(B/d)·C̄_fine/((1 − η₁)d).

**Theorem V0T\*.** For every M > M̄\* and every fixed η > 0:
1. sup_P E_P Π(‖θ − θ\*‖²ₙ > M·ε̄² | y) → 0, i.e. rate **n^{−5/6}(log n)^{1/6}**, with constant ∝ κ₋^{−1/3} + κ₋^{5/3}V²/(log n)^{1/6};
2. sup_P E_P Π(‖θ − θ\*‖∞ > s̄\* | y) → 0, s̄\* := 6√M·ε̄ + 7.06·(√M·ε̄)^{4/5}T₀^{1/5} ≍ n^{−7/30}(log n)^{1/15};
3. sup_P E_P Π(|σ/σ₀,ₙ − 1| > η | y) → 0.

No containment statement for λ is needed or claimed. At κ₋ = 1/V the constant is the oracle's V^{1/3}. The theorem is rate-optimal for every κ₋, but adaptive to V only in that case.

### 3.2 Lemma C2-mix (the only new mathematics) — PROVED\*

Notation of V2T §2: ν̄ = dc ⊗ Π̄, Π̄ = ∫p_n(dℓ)Π_ℓ, N̄_ω(B) = ∫_B e^{−ωℛ}dν̄.

**Lemma C2-mix.** Let p_n be any probability law on [Λ₋, ∞); no other property of it is used. Let ω ∈ (0, ω₂], M ≥ 1, γ ∈ (0, f/8), ε = ε̄, and let n satisfy (N8)–(N9). On Ω_ψ, for each a ≥ M, with P₀-probability ≥ 1 − e^{−2γω·a·nε̄²}:

  N̄_ω(E_a) ≤ V₃(2a·nε̄²)^{3/2}·exp{−ω(f/8 − γ)·a·nε̄² + C̄_fine·ω²·nε̄²/M⁵ + ω·t_∞V/n²}.

This is C2's bound with (a₁/V, C) replaced by (κ₋, C_ε). It does not depend on p_n.

*Proof.*

**(a) Knight, and one Cauchy–Schwarz in ν̄.** ℛ = −⟨ψ, δ⟩ + R with R ≥ 0 pointwise (C2 §3.1; a statement about the data and δ, not about the prior). Hence

  N̄_ω(E_a) ≤ (∫_{E_a}e^{2ω⟨ψ,δ⟩}dν̄)^{1/2}·(∫_{E_a}e^{−2ωR}dν̄)^{1/2}.

Equivalently: Cauchy–Schwarz in ν_ℓ for each ℓ, then Cauchy–Schwarz in p_n.

**(b) Remainder.** E_a is deterministic and |δᵢ| ≤ s₀ on it. By Tonelli, (A1) and C2 §3.2, E₀∫_{E_a}e^{−2ωR}dν̄ ≤ ∫_{E_a}e^{−ωM(δ)}dν̄ ≤ ν̄(E_a)·e^{−ω(f/2)a·nε̄²}. For every u the c-section of E_a lies in a ball of radius (2a·nε̄²)^{1/2} (L5), and Π̄ is a probability measure, so ν̄(E_a) ≤ V₃(2a·nε̄²)^{3/2}. Markov, **one event for the mixed measure**: with probability ≥ 1 − e^{−2γω·a·nε̄²},

  (∫_{E_a}e^{−2ωR}dν̄)^{1/2} ≤ V₃^{1/2}(2a·nε̄²)^{3/4}·e^{−ω(f/4 − γ)a·nε̄²}.

Nothing here depends on ℓ.

**(c) Coarse score.** On Ω_ψ and E_a: |⟨P_Jψ, δ⟩| ≤ (J·2a·nε̄²)^{1/2} ≤ (f/8)·a·nε̄², because J ≤ (f²/128)·a·nε̄² (C2 §3.3). Prior-free.

**(d) Fine score: the mixed MGF is dominated at the floor.** ⟨(I − P_J)ψ, δ⟩ = ⟨t, u − u\*⟩. Integrate c over the section, then drop the u-indicator:

  ∫_{E_a}e^{2ω⟨ψ,δ⟩}dν̄ ≤ e^{2ω(f/8)a·nε̄²}·V₃(2a·nε̄²)^{3/2}·e^{−2ω⟨t,u\*⟩}·∫p_n(dℓ)∏ⱼ(1 − 4ω²tⱼ²/ℓ²)^{−1}.

On Ω_ψ, 2ω‖t‖∞ ≤ 2ω₂t_∞ < Λ₋ ≤ ℓ by (N9), so every factor is finite, and each factor is decreasing in ℓ on ℓ > 2ω|tⱼ|. Therefore

  ∫p_n(dℓ)∏ⱼ(1 − 4ω²tⱼ²/ℓ²)^{−1} ≤ ∏ⱼ(1 − 4ω²tⱼ²/Λ₋²)^{−1}.

By (N9), 4ω²tⱼ²/Λ₋² ≤ ½, and −log(1 − x) ≤ 2x on [0, ½] gives

  log-MGF ≤ 8ω²Σtⱼ²/Λ₋² ≤ 8ω²·m·t_∞²/Λ₋² = 16ω²C_F²·log(2m)·m·J^{−5}·κ₋^{−2}.

Now use three facts:
- J ≥ (f²/256)·M·nε̄² (from (N8));
- (nε̄²)⁶ ≥ C_ε⁶·n·κ₋^{−2}·log m (first term of ε̄² only);
- log(2m) ≤ 2 log m.

Then ½·log-MGF ≤ 8ω²C_F²·(256/f²)⁵M^{−5}(nε̄²)^{−5}·κ₋^{−2}·n·log(2m) ≤ 16C_F²(256/f²)⁵C_ε^{−6}·ω²·nε̄²/M⁵ = C̄_fine·ω²·nε̄²/M⁵. κ₋ cancels, as V did in C2.

**(e) Truth shift.** |2ω⟨t, u\*⟩| ≤ 2ω·t_∞·V/n². It is ℓ-free, and ω·t_∞V/n² = ωC_F√(2 log 2m)·V√n·J^{−5/2} = o(nε̄²) (order κ₋^{5/6}V·n^{1/12}(log n)^{1/12}).

Multiplying the square roots of (b) and of (c)–(e) gives the display. ∎

**Remarks.**
- The lemma uses the floor at exactly one place, (d). With Felipe's unfloored Gamma(1, b₀) on (0, ∞) the mixed MGF is +∞ for every t ≠ 0. This is the precise form of "the moment dies under λ-mixing" (`astra_learned_lambda.md`; open item 4 of `FABLE_lemmaF_C2.md` §4, now closed for the floored prior).
- Do **not** apply C2 separately for each ℓ and then integrate: the Markov event of (b) would depend on ℓ. The mixed measure needs one event per shell and endpoint.

### 3.3 Proof of Theorem V0T\*

| Step | Statement | Reuses | Status |
|---|---|---|---|
| V-1 | Conclusion 3; in particular sup_P E_P Π(σ ∉ I \| y) → 0 | V2T, conclusion 3 (covers constant and scaled b₀; audit fix 3) | PROVED |
| V-2 | Π(B \| y) ≤ sup_{s∈I}Π_s(B \| y) + Π(σ ∉ I \| y), with Π_s = N̄_ω(·)/N̄_ω(ℝⁿ) | V2T Step 1 | PROVED |
| V-3 | On Ω_D (ω-free, λ-free, P₀(Ω_Dᶜ) ≤ 1.25/(nε̄²)), for all ω > 0: N̄_ω(ℝⁿ) ≥ V₃(ε̄√n/2)³·p₀,ₙ·exp{−(3 + ω(1.25C₁ + 1))nε̄²} | V2T Step 3, eq. (2) | PROVED |
| V-4 | On Ω_G ∩ Ω_D, for all ω ∈ [ω₁, ω₂]: Π_s(K′ᶜ \| y) ≤ R_n → 0; on K′, ‖δ‖∞ ≤ s_K ≍ n^{−9/70}(log n)^{12/35} | V2T Steps 4–5, eq. (5). Its bound depends on the σ-interval only through the two endpoints, and I ⊂ [l, H₀] (in S §2, l may be decreased and H₀ increased freely) | PROVED |
| V-5 | Lemma C2-mix at ω₁ and ω₂, for each shell | §3.2 | PROVED\* |
| V-6 | Shell assembly (below) | V-3, V-4, V-5 | PROVED\* |
| V-7 | Conclusions 1 and 2 | V-2, V-1, V-6; L10-I at (√M·ε̄, T₀) | PROVED\* |

**V-6, assembly.**
- Shells a_k := 2^kM, 0 ≤ k ≤ k_max := ⌈log₂(r²/(Mε̄²))⌉ = O(log n). By (N10), s_K ≤ s₀, so K′ ∩ {a_kε̄² < ‖δ‖²ₙ ≤ 2a_kε̄²} ⊂ E_{a_k}.
- Pointwise convexity in ω: N̄_ω(E_a) ≤ N̄_{ω₁}(E_a) + N̄_{ω₂}(E_a).
- Volume ratio: (2a·nε̄²)^{3/2}/(nε̄²/4)^{3/2} = (8a)^{3/2}.
- Hence, on Ω_G ∩ Ω_D ∩ Ω_ψ ∩ (the Markov events), for all ω ∈ [ω₁, ω₂] at once:

  Π_s(‖δ‖²ₙ > Mε̄² | y) ≤ R_n + (2/p₀,ₙ)·Σ_k(8·2^kM)^{3/2}·exp{−[ω₁(f/8 − γ)·2^kM − 3 − ω₂(1.25C₁ + 1) − C̄_fine·ω₂²/M⁵ − ζ̄_n]·nε̄²} =: R_n + R′_n,

  with ζ̄_n := ω₂t_∞V/(n²·nε̄²) → 0. R′_n is deterministic, and R′_n → 0 for M > M̄\*, since nε̄² → ∞ and −log p₀,ₙ = o(nε̄²).
- Therefore

  sup_P E_P sup_{s∈I}Π_s(‖δ‖²ₙ > Mε̄² | y) ≤ R_n + R′_n + 1/n + 1.25/(nε̄²) + 4(J + 3)/(9(J − 1)²) + (2m)^{−3} + 4e^{−2γω₁M·nε̄²} → 0. ∎

The slowest terms are 1.25/(nε̄²) and ≈ 4/(9J), both ≍ n^{−1/6}(log n)^{−1/6}.

### 3.4 Large ℓ: where each piece stands

| Piece | Dependence on ℓ ≥ Λ₋ |
|---|---|
| Remainder (b), coarse score (c), cone A₁ | none (only the unit mass of Π_ℓ) |
| Fine MGF (d) | decreasing in ℓ; bounded by its value at Λ₋ |
| Truth shift (e) | none |
| Cone A₂ (V2T (4)) | n²‖u‖₁/T₀ = (Λ₋/ℓ)·Γ/(Tn) ≤ Γ/(Tn); improves with ℓ |
| Denominator | only ℓ ∈ [Λ₋, 2Λ₋] is used; the bias κ₋^{5/3}V² is paid there, once |

Over-smoothed draws (large ℓ) have a large ‖δ‖ₙ and fall in high shells or in K′ᶜ, where the numerator bounds above already apply. No lower bound on the evidence at large ℓ is ever needed.

---

## 4. Sharper constant: law-dependent interval — PROVED\*

The thresholds M\* and M̄\* carry the class ratio B/d because I must contain σ₀,ₙ for every law. For one law at a time this is avoidable.

Put I_P := [(1 − η₁)σ₀,ₙ, (1 + η₁)σ₀,ₙ] ⊂ I. For each law and each n it is a deterministic interval.
- Conclusion 3 gives sup_P E_P Π(σ ∉ I_P | y) → 0.
- Disintegrate over I_P. Localization (C\*-3, V-4) is already uniform on I ⊃ I_P. Apply C2 / C2-mix at the two endpoints of I_P; s₀ stays as defined in §1 (conservative).
- The threshold at these endpoints, multiplied by (1 + η₁)σ₀,ₙ and bounded with d ≤ σ₀,ₙ ≤ B, is implied by

  **(f/8 − γ)·M > ρ(1.44C₁ + 1) + (1 + η₁)B·C_pr + ρ·C_fine/((1 − η₁)d)**  (C\*),

  and by (f/8 − γ)·M > ρ(1.25C₁ + 1) + 3(1 + η₁)B + ρ·C̄_fine/((1 − η₁)d) (V0T\*).
- The Markov failure probabilities are ≤ 4e^{−2γM·nε²/((1+η₁)B)}, uniformly over the class. Ω_G, Ω₆ (or Ω_D) and Ω_ψ are ω-free, so nothing else changes.

As η₁ ↓ 0 and γ ↓ 0 the threshold tends to that of a known scale σ = σ₀,ₙ: M ≈ (8/f)·[1.44C₁ + 1 + σ₀,ₙC_pr + C_fine/σ₀,ₙ]. Not circular: σ-concentration comes from the audited n^{−4/7} theorems, and the shell bound is then run once on the small interval.

---

## 5. n₀ conditions

**Theorem C\*.**
- (C-N1) Those of Theorem C (C1 at the oracle on [ω₁, ω₂], L6's joins J5–J8, Lemma S). Lemma S's law-of-large-numbers events carry no explicit rate.
- (C-N2) (N8)–(N11) below, with (ε̄, Λ₋, κ₋) replaced by (ε, λ, a₁/V), and K′ the oracle body.

**Theorem V0T\*.**
- (N1)–(N7) of V2T, unchanged (they include Lemma S, so there is no explicit overall n₀).
- **(N8)** (f²/128)·M·nε̄² ≥ 3 and J ≤ m. Then J ≥ 3 and J ≥ (f²/256)·M·nε̄².
- **(N9)** 16·ω₂²·C_F²·log(2m) ≤ κ₋²·J⁵. This is 4ω₂²t_∞²/Λ₋² ≤ ½, and it implies 2ω₂t_∞ < Λ₋. The left side is O(log n); the right side is ≍ n^{5/6}(log n)^{5/6}.
- **(N10)** s_K = 6r + 7.06·r^{4/5}T₀^{1/5} ≤ s₀ = min(L, 3f(1 − η₁)d/(4f̄)). Stronger than V2T's (N2). Since s_K ≍ n^{−9/70}, this is the slowest condition: n ≳ s₀^{−70/9} up to logs. With W′ (s_K ≍ n^{−13/70}) it would be n ≳ s₀^{−70/13}; that is the only thing W′ would buy here.
- **(N11)** ζ̄_n = ω₂C_F√(2 log 2m)·V√n·J^{−5/2}/(nε̄²) ≤ ζ and −log p₀,ₙ ≤ ζ·nε̄², where 2ζ is the slack in the strict inequality defining M̄\*; and 2γω₁M·nε̄² ≥ log 2.

---

## 6. Flags

**Dependencies still pending.** Lemma F (all columns) and C2 §3.1–3.4. In this session I re-derived by hand the parts both theorems lean on, and found no error:
- Lemma F, Case 1: the choice a = min(⌊j/h⌋, J′ − 2); the support {κ + 3, …, κ + 2h} (left: all four indices are ≥ κ; right: i ≥ κ + 2h + 1 makes all four truncations inactive, and the Lagrange weights are exact on the quadratic k ↦ p_i(k)); Σ|a_l| ≤ 5/4; ‖e‖₂² ≤ 8.1h⁵. Cases 2–3: the identity q_j(i) = C(j + 2 − i, 2) for i ≤ j.
- C2 §3.2: E Rᵢ² ≤ f̄|δ|³/3 and the threshold 3f/(4ωf̄).
- C2 §3.3: Var(ψᵀP_Jψ) ≤ (J + 3)/4 (the cross-covariances vanish because E ψᵢ = 0), the Chebyshev bound, and J ≤ (f²/128)a·nε².
- C2 §3.4: the Hoeffding union bound (2m)^{−3}, the Laplace MGF, the bookkeeping of C_fine.
- The exponents f/2 → f/4 (square root) → f/8 (coarse score).

This is a re-derivation by the same model that wrote the original, so it is not an independent audit.

**If the audit changes C2.** Only two C2 outputs enter this note: the shell exponent ω(f/8 − γ)a·nε² and the fine constant C_fine. A change in either changes M\* and C̄_fine, not the structure. If Lemma F held only in Frobenius average (not column-wise), both theorems would fall back to n^{−5/7} (`FABLE_rate_gap.md` §2).

**(A2) form.** C2 uses (A2) in secant form on [−L, L], lower and upper. Theorem C says "both halves" without the word secant; the clean write-up should state it once, in the secant form.

**No adaptation in λ.** The numerator pays the fine MGF at the floor for every ℓ, so the rate is that of λ = Λ₋. With Λ₋ = κ₋n^{5/2} this is the oracle order, so nothing is lost in the exponent; the constant is that of κ₋, not of the best λ.

**Other floor exponents — SKETCH.** For Λ₋ = κn^p, C2-mix and V-3 balance at ε_p² ≍ Λ₋^{−1/3}(log n)^{1/6} ≍ n^{−p/3}(log n)^{1/6}: the fine term ω²n⁶J^{−5}log n/Λ₋² with J ≍ nε_p² is again ≍ nε_p². The localizer needs p > 23/11 (audited C1) or p > 21/11 (with W′). So a floor n^{9/4} would give n^{−3/4}, against V2T's sketch n^{−1/2}. Exponent checks done: bias V²Λ₋^{5/3}n^{−5} ≤ ε_p² ⇔ p ≤ 5/2; L4q's (R1) ⇔ p ≥ 12/7; truth shift o(nε_p²) ⇔ p < 18/7; MGF ratio t_∞/Λ₋ ≍ n^{−p/6} → 0; window mass −log p₀,ₙ = O(log n) for the scaled prior and → 0 for constant b₀. Not written out with constants.

**The floor binding under constant b₀ (Engineering, n ≈ 4000).** Not a problem for the theorem: it is a statement about the posterior as defined, and it never says where λ sits. **CONJECTURE** on MSE: the unfloored posterior has λ ∝ n^{3/4}, far below every proved window. The same small-ball budget at p = 3/4 is n^{−1/4}, against n^{−5/6} with the floor. Both are upper-bound budgets (there is no lower bound for the unfloored posterior here), so this predicts, but does not prove, that the floor improves MSE increasingly with n. If κ₋V ≫ 1 the floor instead over-smooths, and costs the factor (κ₋V)^{5/3} in ε̄².

**Sup-norm rate.** n^{−7/30}(log n)^{1/15} is what L10-I gives from (√M·ε, T₀ ≍ √n). No claim that it is sharp.

**Not verified.** The internals of C1, Theorem C, V2T, L3, L6, L10-I (used as quoted, or as read in their files); the numerical value of C_ε (it depends on C_M); L6's 1.44 against V2T's 1.25 (each is quoted from its own audited file).

---

## Theory Department: cross-family audit response (Astra, `reviews/AUDIT_astra_V0Tstar.md`, 2026-11-23)

Verdicts:
- **Theorem C\*: ACCEPT.**
- **Lemma C2-mix: ACCEPT WITH FIXES.**
- **Theorem V0T\*: ACCEPT WITH FIXES.**

All eight findings are CONFIRMED. Theory verified the central new step (the λ-mixed fine MGF is monotone in ℓ, so it is bounded by its value at the floor) before the audit, and rules that **all eight HOLD**. None changes a conclusion or a rate. The fixes, all editorial:
1. **σ-interval.** Narrowing to [(1−η₁)d, (1+η₁)B] uses the audited scale consistency of Theorem C / V2T; it is non-circular.
2. **Mixed measure.** Cauchy–Schwarz is applied in dc ⊗ Π̄ on the deterministic sup-norm-restricted shell.
3. **Probabilities.** State the Markov failure probability **unconditionally**, then intersect with the λ-free score event (the coarse event, failure ≤ 4(J+3)/(9(J−1)²); the fine event, failure ≤ (2m)^{−3}).
4. **Floor comparison and fine constant.** Confirmed.
5. **Evidence.** One deterministic centre per truth across the window; the upper support of λ is unbounded, and that is harmless.
6. **(N11).** Reserve positive slack and state the threshold as a **strict** inequality. The ceiling shell index is fine.
7. **Rate.** ε̄² = M C_ε n^{−5/6}[κ₋^{−1/3}(log m)^{1/6} + κ₋^{5/3}V²], and the sup-norm rate follows.
8. **The alternative-floor sketch (outside both theorems).** It needs extra log care; it stays SKETCH.

**Status: Theorem V0T\* (Felipe's method + λ floor, σ and λ learned, n^{−5/6}) is PROVED and cross-family audited, modulo editorial fixes.**
