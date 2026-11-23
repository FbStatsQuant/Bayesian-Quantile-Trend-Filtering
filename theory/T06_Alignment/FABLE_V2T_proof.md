# Theorem V2T: contraction with σ AND λ learned, λ-prior truncated below

*Fable, for Theory, 2026-11-23. Written in one pass from the audited statements as quoted in `C1_any_sigma.md`, `W_width_lemma.md`, `astra_sigma_concentration.md` (S), `astra_learned_lambda.md` and `../T05_Proofs/THEOREM_B_COMPLETE.md` (L2–L6, L4q, L4q-M). **Not yet audited.** Each step says exactly which audited statement it uses. After writing, I checked Step 3 against the files `L6_evidence_lower_bound.md` and `L4q_quadratic_shift.md` (statement, half-radius form, Corollary L4q-M); the other lemmas are used as quoted.*

**Step labels.** PROVED = every line is written here and rests only on audited statements. SKETCH = argument given, a detail left open. New material is marked **NEW**.

**Verdict in one paragraph.** All five steps close at PROVED level. Three things are new: (a) one fixed C1 body for every λ ≥ Λ₋; (b) a mixed denominator with one common centre on the window [Λ₋, 2Λ₋]; (c) monotonicity in λ inside Lemma S §2. No relation between κ₋ and V is needed. The hyperprior enters only through the mass of [Λ₋, 2Λ₋], so the scaling b₀,ₙ ∝ n^{−5/2} is not what makes the proof work: the truncation is.

---

## 1. Statement

**Model.** With Q(θ) = Σᵢρ_τ(yᵢ − θᵢ), D = D⁽³⁾, m = n − 3:

  π(θ, λ, σ | y) ∝ σ^{−n}e^{−Q(θ)/σ} · λ^m e^{−λ‖Dθ‖₁} · p_n(λ) · IG(σ; a, b),

- flat prior on quadratics; a, b > 0 fixed;
- p_n = Gamma(1, b_n) truncated to [Λ₋, ∞), i.e. density b_n e^{−b_n(λ−Λ₋)} on λ ≥ Λ₋;
- Λ₋ := κ₋n^{5/2}, κ₋ > 0 fixed; b_n := b₀(500/n)^{5/2} = c_b n^{−5/2}, c_b := b₀·500^{5/2}.

In L5 coordinates θ = Nc + Su the prior is dc ⊗ Π_λ(du) ⊗ p_n(dλ) ⊗ IG(dσ), with Π_λ the normalized product Laplace law. The factor λ^m is exactly the λ-dependent part of Π_λ's normalization, so the λ-mixture is the correct one; the Jacobian and 2^m are λ-free.

**Assumptions** (those of Theorem C; constants fixed, suprema over the class): (A1); full (A2) with (L, f, f̄); (A3) with V; row-average uniform integrability of ρ_τ(Zᵢ); σ₀,ₙ ≥ d > 0.

**Constants.** Fix T ≥ 4. Put

  T₀ := T·n³/Λ₋ = (T/κ₋)·√n,  r² := C_r·T^{2/7}·n^{1/7}·Λ₋^{−2/7}·(log n)^{6/7} = C_r(T/κ₋)^{2/7}·n^{−4/7}(log n)^{6/7},

with C_r = C_r(f) the constant of C1 Step 3. Let δ := θ − θ\*, TV(δ) := n²‖Dδ‖₁, t(δ) := max(‖δ‖ₙ/r, TV(δ)/T₀).

**Theorem V2T.** For every fixed η > 0:
1. sup_P E_P Π(‖θ − θ\*‖ₙ > r or TV(θ − θ\*) > T₀ | y) → 0;
2. sup_P E_P Π(‖θ − θ\*‖∞ > s_K | y) → 0, with s_K := 6r + 7.06·r^{4/5}T₀^{1/5} ≍ n^{−9/70}(log n)^{12/35} → 0;
3. sup_P E_P Π(|σ/σ₀,ₙ − 1| > η | y) → 0.

No (EM), no σ ≥ σ̄, no moments beyond uniform integrability, and **no containment statement for λ** is needed or claimed.

---

## 2. Notation for the proof

- ν_ℓ := dc ⊗ Π_ℓ; ν̄ := ∫p_n(dℓ)ν_ℓ = dc ⊗ Π̄, where Π̄ := ∫p_n(dℓ)Π_ℓ is a probability measure on ℝᵐ.
- For ω = 1/s: N_{ω,ℓ}(B) := ∫_B e^{−ωℛ}dν_ℓ and N̄_ω(B) := ∫_B e^{−ωℛ}dν̄ = ∫p_n(dℓ)N_{ω,ℓ}(B), with ℛ(δ) = Σᵢ Xᵢ(δᵢ) = Q(θ) − Q(θ\*).
- Π_s(B | y) := N̄_ω(B)/N̄_ω(ℝⁿ): the θ-posterior at fixed σ = s, **with λ mixed**.

**Propriety (PROVED; S §2's flat bound).** For every u and s, ∫e^{−Q/(2s)}dc ≤ C_k s³, and Π̄ has mass 1, so N̄_ω(ℝⁿ) < ∞ for every data vector. The joint posterior is proper because ∫s^{3−n}IG(ds) < ∞ (n ≥ 4).

---

## 3. Proof

### Step 1. Disintegration — PROVED

The penalty and p_n do not involve σ. So, given σ = s and y, θ has law Π_s exactly, and for every event B and every interval I,

  Π(B | y) = ∫Π_s(B | y)·Π(ds | y) ≤ sup_{s∈I}Π_s(B | y) + Π(σ ∉ I | y).  (1)

*Reuses:* memo (c), S §3. *New:* nothing; Π_s is now the λ-mixed posterior. Measurability of the supremum is as in S §3: numerator and denominator are continuous in s on I, dominated by e^{−Q/H₀}.

### Step 2. Compact containment of σ, uniformly in λ ≥ Λ₋ — PROVED

**Claim.** There are fixed 0 < l < d ≤ B < H₀ < ∞, depending only on (k, d, B, V) as in S §2, with sup_P E_P Π(σ ∉ [l, H₀] | y) → 0.

*Proof.* Run S §2 with Π_λ replaced by Π̄. The roughness cost in (b) below uses the data event {‖Dy‖₁ ≥ nd/2}, and the evidence bound uses {Q\*/n ≤ B + 1}; both are λ-free. λ enters S §2 at two places only.

- **(a) Evidence lower bound.** S §2 uses Π_λ(‖P⊥Su‖ₙ ≤ 1) ≥ e^{−n} from L3 at radius one. **NEW:** for ℓ ≥ Λ₋, L3 gives −log Π_ℓ(‖P⊥Su‖ₙ ≤ 1) ≤ 30(n^{5/2}/ℓ)^{2/5}(log m)^{1/5} + 6 ≤ 30κ₋^{−2/5}(log m)^{1/5} + 6 ≤ n for n ≥ n₀ (N7). Integrating over p_n, Π̄(‖P⊥Su‖ₙ ≤ 1) ≥ e^{−n}. The rest of S §2's evidence bound (unit ball in c, ‖P⊥θ\*‖ₙ ≤ V, s ∈ [1, 2]) is λ-free, so the joint evidence is ≥ e^{−Cn} with the same C.
- **(b) Roughness cost.** S §2 uses Π_λ(‖u‖₁ ≥ nd/4) ≤ 2^{n−3}e^{−λnd/8}. **NEW:** the right side decreases in λ, so Π̄(‖u‖₁ ≥ nd/4) ≤ 2^{n−3}e^{−Λ₋nd/8}. This beats the IG negative-moment cost O(n log n) and Cn, because Λ₋/log n → ∞.

The upper tail (≤ C_k H₀^{3−n}) and the part {s < l, Q ≥ qn} use only the flat bound and unit prior mass, so they are unchanged. ∎

*Reuses:* S §2 in full, L3. *New:* the two monotonicity remarks.

### Step 3. Mixed denominator on J₀ := [Λ₋, 2Λ₋] — PROVED

**Hyperprior mass.** p_n(J₀) = 1 − e^{−b_nΛ₋} = 1 − e^{−c_bκ₋} =: p₀ ∈ (0, 1), constant in n. (For b₀ = 1e-3 and 5e-4, c_b ≈ 5590 and 2795.) **NEW.** With a general shape a₀ the mass is again a positive constant, because b_nΛ₋ is fixed.

**Radius.** Let C_M be the absolute constant of L4q-M and put

  ε² := C_ε·n^{−5/6}·[κ₋^{−1/3}(log m)^{1/6} + κ₋^{5/3}V²],  C_ε := max(39.6, 25.2·4^{1/5}·C_M^{11/5})^{5/6}.

So nε² ≍ n^{1/6}(log n)^{1/6} → ∞ and nε² = o(nr²), since nr² ≍ n^{3/7}(log n)^{6/7}.

**One centre for the whole window — NEW.** Let u_h be the L4q-M centre with w := ⌊n(ε²/(4C_MV²))^{1/5}⌋ (u_h := 0 if V = 0). It depends on (ε, V, n) only, not on ℓ.
- L4q-M (2): ‖P⊥S(u_h − u\*)‖ₙ ≤ ‖S(u_h − u\*)‖ₙ ≤ (C_MV²(w/n)⁵)^{1/2} ≤ ε/2.
- L3 at radius ε/2, for ℓ ≥ Λ₋: φ_ℓ(ε/2) ≤ 30(2/(κ₋ε))^{2/5}(log m)^{1/5} + 6 ≤ nε² + 6, by the first term of ε² and C_ε^{6/5} ≥ 39.6.
- L4q applies for every ℓ ∈ J₀ once (N6) holds: δ_A ≤ n/√3 ≤ Λ₋ε/4 and (R1) Λ₋ε ≥ 102·n^{10/7}(log m)^{1/7}; then c_{K′} ≤ 3.144. With L4q-M (1) and n/w ≤ 2(4C_MV²/ε²)^{1/5}, the charge is

  c_{K′}ℓ²‖u_h‖₂² ≤ 3.144·4κ₋²n⁵·C_M²V²/(n⁴w) ≤ 25.2·4^{1/5}C_M^{11/5}·κ₋²V^{12/5}ε^{−2/5} ≤ nε²,

  by the second term of ε².
- Hence, for **every** ℓ ∈ J₀: −log Π_ℓ(u_h + B_{ε/2}) ≤ 2nε² + 6 ≤ 3nε².

**Good set and event.** Let G := {(c, u) : u ∈ u_h + B_{ε/2}, ‖N(c − c\*) + P_NS(u − u\*)‖ₙ ≤ ε/2} (L6's set; it does not depend on ℓ). By L5, ν_ℓ(G) = V₃(ε√n/2)³·Π_ℓ(u_h + B_{ε/2}), and on G, ‖δ‖ₙ² ≤ (ε/2)² + ε² = 1.25ε². Let ν̄₀ := ∫_{J₀}p_n(dℓ)ν_ℓ and g := ν̄₀(· ∩ G)/ν̄₀(G), a **deterministic** probability measure, with

  ν̄₀(G) ≥ V₃(ε√n/2)³·p₀·e^{−3nε²}.

Put 𝒯 := ∫ℛ dg = ΣᵢYᵢ, Yᵢ := ∫Xᵢ(δᵢ)dg. Then:
- E₀𝒯 = ∫M dg ≤ 1.25C₁nε² (L2 (iv), Tonelli since |Xᵢ| ≤ |δᵢ|);
- the Yᵢ are independent by (A1), and Var Yᵢ ≤ ∫E Xᵢ² dg ≤ ∫δᵢ² dg (Jensen, L2 (i)), so Var 𝒯 ≤ 1.25nε²;
- Chebyshev: Ω_D := {𝒯 ≤ (1.25C₁ + 1)nε²} has P₀(Ω_Dᶜ) ≤ 1.25/(nε²).

Jensen gives, on Ω_D and **for all ω > 0 simultaneously**,

  N̄_ω(ℝⁿ) ≥ ν̄₀(G)·∫e^{−ωℛ}dg ≥ V₃(ε√n/2)³·p₀·exp{−(3 + ω(1.25C₁ + 1))·nε²}.  (2)

Ω_D is ω-free and λ-free. ∎

*Reuses:* L2 (i), (iv); L3; L4q with (R1); L4q-M; L5; L6's proof line by line (its measure replaced by g). The mixed good set is Astra's (`astra_learned_lambda.md`, denominator paragraph; that part does not use (EM)). *New:* the common centre, the explicit ε, the window inside the truncated support. No per-ℓ L6 event and no oracle-specific join (J7, J8) is used.

### Step 4. Mixed numerator: one C1 body for every λ ≥ Λ₋ — PROVED

**Body.** K′ := {t ≤ 1} = {‖δ‖ₙ ≤ r, TV(δ) ≤ T₀}. This is exactly C1's body at the deterministic value λ = Λ₋. C1's conditions at λ = Λ₋ hold: (i) r⁴T₀ ≍ n^{−9/14}(log n)^{12/7} → 0; (i′) VΛ₋ = κ₋Vn^{5/2} = o(n³). Condition (ii) is not needed; Step 3 replaces it.

**Steps 0–4 of C1, verbatim.** They involve only K′, ℛ and the data, never the prior:
- s_K → 0 and M(δ) ≥ (f/2)n‖δ‖ₙ² on K′ (C1 Step 1; L10-I, L2);
- Ω_G := {sup_{K′}|ℛ − M| ≤ (f/4)nr²} has P₀(Ω_Gᶜ) ≤ 1/n for n ≥ n₀ (C1 Step 3; Lemma W, Ledoux–Talagrand, Bousquet at x = log n);
- on Ω_G, with the cones A₁, A₂ of C1 Step 2: ℛ(δ) ≥ t·(f/4)nr² on A₁ and ℛ(δ) ≥ −t·(f/4)nr² on A₂ (C1 Step 4).

Ω_G is ω-free and λ-free.

**Cone A₁ (C1 Step 5).** For each u, with a(ω) := ω(f/4)nr²: ∫1_{A₁}e^{−ωℛ}dc ≤ 8π(2√n r/a)³e^{−a/2}. The bound is free of u and ℓ and decreasing in a. Integrating against Π_ℓ and then p_n (unit masses), for all ω ≥ ω₁:

  N̄_ω(A₁) ≤ 8π·(8/(ω₁f√n r))³·e^{−ω₁fnr²/8}.  (3)

**Cone A₂ (C1 Step 6) — the NEW inequality.** On A₂, t = n²‖u − u\*‖₁/T₀. Under Π_ℓ, Γ := ℓ‖u‖₁ ~ Gamma(m, 1) for **every** ℓ. For ℓ ≥ Λ₋,

  n²‖u‖₁/T₀ = Γ·n²/(ℓT₀) = (Λ₋/ℓ)·Γ/(Tn) ≤ Γ/(Tn),  so  t ≤ Γ/(Tn) + s₀,  s₀ := V/T₀ = κ₋V/(T√n) → 0.

The c-section lies in a ball of radius √n·r·t and the integrand is ≤ e^{a t}, so ∫1_{A₂}e^{−ωℛ}dc ≤ V₃(√n r)³·t³e^{at}1{t > 1}, which is increasing in t. With t³ ≤ 6eᵗ, 1{t > 1} ≤ e^{β(t−1)}, β := Tn/2 − a − 1 > 0, and E e^{Γ/2} = 2^m, for every ℓ ≥ Λ₋:

  N_{ω,ℓ}(A₂) ≤ 6V₃(√n r)³·exp{−Tn/2 + a + 1 + κ₋V√n/2 + m log 2}.

Under (N5) the exponent is ≤ −Tn/4 for all ω ≤ ω₂. Integrating over p_n:

  N̄_ω(A₂) ≤ 6V₃(√n r)³·e^{−Tn/4}.  (4)

*Reuses:* C1 Steps 0–6, W, L10-I, L2, L5. *New:* the body is frozen at Λ₋ and the Chernoff bound uses only the law of ℓ‖u‖₁, which is ℓ-free. In particular C1's upper restriction on λ disappears: (4) holds for all ℓ ≥ Λ₋, including ℓ > n³/V.

### Step 5. Combine, uniformly in σ ∈ [l, H₀] — PROVED

Let ω₁ := 1/H₀ and ω₂ := 1/l. On Ω_G ∩ Ω_D, (2)–(4) give, for all ω ∈ [ω₁, ω₂] at once,

  Π_s(t > 1 | y) ≤ p₀⁻¹·{ (8π/V₃)·(16/(ω₁f·εnr))³·exp[−ω₁fnr²/8 + (3 + ω₂(1.25C₁+1))nε²] + 6(2r/ε)³·exp[−Tn/4 + (3 + ω₂(1.25C₁+1))nε²] } =: R_n.

R_n is deterministic and R_n → 0, because nε² = o(nr²), εnr ≍ n^{25/84} → ∞ and nε² = o(n). Hence

  sup_P E_P sup_{s∈[l,H₀]}Π_s(t > 1 | y) ≤ R_n + 1/n + 1.25/(nε²) → 0.  (5)

**Conclusions 1 and 2.** (1) with I = [l, H₀], then (5) and Step 2, give conclusion 1. On {t ≤ 1}, L10-I gives ‖δ‖∞ ≤ s_K, which is conclusion 2.

**Conclusion 3.** |Q(θ) − Q(θ\*)|/n ≤ ‖δ‖ₙ ≤ r → 0 on {t ≤ 1}, so hypothesis (H) of S §1 holds for the θ-marginal. S §1's proof uses only (H), the LLN for Q\*/n, and the conditional law (b + Q(θ))/σ | θ, y ~ Gamma(n + a, 1). That conditional is unchanged when λ is random with a σ-free prior, since σ and λ are conditionally independent given (θ, y). So S §1 applies verbatim. ∎

---

## 4. Flags

**Λ₋ ≍ n^{5/2} versus V: no relation is needed.**
- r and T₀ do not involve V at all. κ₋ may be above or below the oracle constant 1/V.
- V enters only: ε² (through κ₋^{5/3}V², still O(n^{−5/6})); s₀ = κ₋V/(T√n); (l, H₀) of S §2; and n₀.
- If κ₋V ≫ 1 the truncation forces oversmoothing, but the bias (κ₋V)^{5/3}V^{1/3}n^{−5/6} stays far below r², so the statement survives. It would enter the constant of an n^{−5/6} upgrade.
- Rate constant: r² ∝ κ₋^{−2/7}. A smaller κ₋ (safer at n = 500) costs only this factor.
- **Other exponents — SKETCH.** For Λ₋ = κ₋n^p the proof needs n^{23/11}(log n)^{12/11} ≪ Λ₋ (sup-norm) and Λ₋ ≪ n^{108/41}V^{−42/41} (bias on J₀ below r²). For p < 5/2, take the L4 centre u_h = u\* when p ≤ 9/4; p₀ becomes ≈ c_bκ₋n^{p−5/2}, polynomially small, which costs O(log n) in the exponent. Rates: n^{−1/2}(log n)^{6/7} at p = 9/4.

**The hyperprior matters only through p_n(J₀).** The proof works for any p_n on [Λ₋, ∞) with −log p_n([Λ₋, 2Λ₋]) = o(nr²). This includes Felipe's **constant** b₀ with the same truncation (then p_n(J₀) → 1). So the theorem does not distinguish V2T from "V0 truncated", and it says nothing about where the posterior of λ sits. If the evidence prefers smaller λ (conjecturally when σ₀ < σ̄/6, see `FABLE_joint_V2.md`), the posterior piles up at Λ₋; the theorem still holds, but the truncation is then binding for large n.

**Sampler (for Engineering).** The only change to the Gibbs step is λ | θ ~ Gamma(m + 1, b_n + ‖Dθ‖₁) truncated to [Λ₋, ∞). The σ-step is unchanged.

**Exact n₀ conditions.**
- (N1) n ≥ 5 (L3, L4q-M).
- (N2) s_K = 6r + 7.06r^{4/5}T₀^{1/5} ≤ L (C1 Step 1).
- (N3) W's truncation level: (T₀√n/r)^{1/3} ≤ m; and E sup_{K′}|ℛ − M| ≤ (f/8)nr², which fixes C_r(f) and needs √n·r ≥ c(f).
- (N4) Bousquet at x = log n, in the form of C1's self-check (v ≤ nr², envelope 2s_K, E G ≤ (f/8)nr²): √(2 log n·(nr² + 4s_K·(f/8)nr²)) + (2/3)s_K log n ≤ (f/8)nr².
- (N5) Tn/4 ≥ ω₂(f/4)nr² + 1 + κ₋V√n/2 + (n − 3)log 2. With T = 4 this reads 0.306n + 1.08 ≥ ω₂(f/4)nr² + κ₋V√n/2.
- (N6) ε < 1; nε² ≥ 6; n/√3 ≤ κ₋n^{5/2}ε/4; κ₋n^{5/2}ε ≥ 102·n^{10/7}(log m)^{1/7}; 3 ≤ w ≤ m/2.
- (N7) 30κ₋^{−2/5}(log m)^{1/5} + 6 ≤ n; and C_k2^{n−3}e^{−Λ₋nd/8}b^{3−n}Γ(n+a−3)/Γ(a) ≤ e^{−(C+1)n}.
- The LLN events of S (uniform integrability) carry no explicit rate, so the theorem is asymptotic with no explicit n₀ overall.

**What I did not verify.**
- The internals of C1, W, S, L3 and L10-I; I used their statements as quoted. For L6 and L4q/L4q-M I read the files: L6's proof (Steps 1–3: orthogonal split, Jensen, mean and variance) is the one reproduced in Step 3 with ν_G replaced by g, and u_h is λ-free. L4q's condition K′ ≤ 1 is taken from (R1) as stated in the Theorem B package; K(ρ) is nonincreasing, so ℓ ≥ Λ₋ suffices.
- The numerical value of C_ε (it depends on C_M, which I did not look up).
- That C_r can be taken exactly as in C1 (it can: Steps 0–4 are identical to C1 at λ = Λ₋).

**Upgrades — SKETCH** (see `FABLE_rate_gap.md`). Lemma F replaces W and gives r² ≍ n^{−5/7} here. The C2 shell bound is also uniform in ℓ ≥ Λ₋ (its fine term ω²n⁶J^{−5}ℓ^{−2} decreases in ℓ and its truth shift is ℓ-free), which would give n^{−5/6}(log n)^{1/6} with the same Steps 1–3 and 5.
