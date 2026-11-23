# Link L2: bounded tuning λ ∈ [ℓ₁, ℓ₀] — the design condition (DC)

*Fable, research sub-agent for Theory, 2026-11-23, written under a hard stop. By hand; no compute. **Not audited.** Inputs: `FABLE_A_Arule_lowertail.md` §2 and §6.1, `astra_noFloor.md`, the end of `astra_gap4_sign.md`.*

**Labels.** PROVED = fully written here from elementary facts or audited statements. SKETCH = argument given, steps open. CONJECTURE = heuristic.

## 0. Verdict

- **No proof exists for the Gaussian design at τ = ½.** I found no argument that closes (DC) on the whole bounded range. What is proved is the reduction of (DC) to a **compact rectangle** in (s, ℓ) with explicit analytic bounds outside it, a data-free grid lemma, and two computable upper bounds for the nodes.
- **The certificate is specified below in three tiers.** Tier 1 is fully deterministic (one- and two-dimensional integrals with closed-form integrands) but, by my rough hand estimates, certifies only ℓ ≲ 3. Tier 2 (blocks) reaches larger ℓ but is rigorous only in its annealed form, which I expect to fail at small s·ℓ; its quenched form is a statistical certificate, not a proof. Tier 3 is a cheap non-rigorous map of the whole surface from fixed-(σ, λ) chains.

| # | Claim | Status |
|---|---|---|
| 1 | Statement (DC_γ) and its consequence Π(ℓ₁ ≤ λ ≤ ℓ₀ \| y) ≤ e^{−γn/2} | PROVED given the benchmark denominator of `FABLE_A_Arule_lowertail.md` §5 |
| 2 | Upper scale cut: s ≥ e^{1+γ}σ₀ is excluded, every ℓ | PROVED (§2.1) |
| 3 | Small-scale corner: g_n(s, ℓ) ≤ log(ℓ/(2t)) − ℓR_n + log M_τ(8ℓs) | PROVED (§2.2) |
| 4 | One-sided Lipschitz bound in (log s, log ℓ), data-free | PROVED (§2.3) |
| 5 | Block decoupling and the quenched Chernoff bound | PROVED (§2.4) |
| 6 | (DC) for Gaussian τ = ½ | **OPEN**; certificate specified (§4); UNTESTED |
| 7 | Rough hand estimates of where Tier 1 succeeds | CONJECTURE (§3) |

---

## 1. Statement

**Notation.** t = τ(1−τ), k = min(τ, 1−τ). Z(s, ℓ) := ∫s^{−n}e^{−Q(θ)/s}dν_ℓ(θ), the evidence at fixed scale s and tuning ℓ. By Astra's identity (audited),

  Z(s, ℓ) = J_n·(ℓ/2)^m·t^{−n}·𝔼_s exp{−ℓ‖D(y − E)‖₁},  1 ≤ J_n ≤ n^{9/2},

with E₁, …, Eₙ i.i.d. of density t·s⁻¹e^{−ρ_τ(x)/s}. Put

  **g_n(s, ℓ) := log(ℓ/(2t)) + Φ_n(s, ℓ),  Φ_n(s, ℓ) := n⁻¹·log 𝔼_s exp{−ℓ‖D(y − E)‖₁} ≤ 0,**

so n⁻¹log Z(s, ℓ) = g_n(s, ℓ) + O(log n/n). Benchmark: **b\* := −1 − log σ₀** (the per-observation log-evidence near the truth at the learned scale).

**(DC_γ).** With probability → 1: **sup{g_n(s, ℓ) : s > 0, ℓ₁ ≤ ℓ ≤ ℓ₀} ≤ b\* − γ.**

**Consequence — PROVED given the benchmark.** The joint evidence of {ℓ₁ ≤ λ ≤ ℓ₀} is ∫IG(ds)∫_{ℓ₁}^{ℓ₀}p_n(dℓ)Z(s, ℓ) ≤ n^{9/2}e^{n(b\* − γ)}, since both priors have mass ≤ 1. The total evidence is ≥ e^{n·b\* − o(n)} (`FABLE_A_Arule_lowertail.md` §5; V2T Step 3 with the likelihood-ratio inequality of `FABLE_A_noFloor.md` §1). Hence Π(ℓ₁ ≤ λ ≤ ℓ₀ | y) ≤ e^{−γn/2} for large n.

**For the Gaussian design at τ = ½:** σ₀ = 0.13298, b\* = 1.0175, R = 1.18942, t = ¼, ℓ₁ ≈ 1.38(1 − η)e^{−η}.

---

## 2. Reductions — PROVED

### 2.1 Upper scale cut

For every u and s, ∫e^{−Q/s}dc ≤ 8π(s/k)³ (Q ≥ k‖c − Nᵀ(y − Su)‖₂), and Π_ℓ has mass 1. So Z(s, ℓ) ≤ 8πk^{−3}s^{3−n} and g_n(s, ℓ) ≤ −log s + O(log n/n), for every ℓ and every data vector. Hence

  **s ≥ s_hi := e^{1+γ}·σ₀  ⇒  g_n(s, ℓ) ≤ b\* − γ + o(1).**  (Gaussian τ = ½: s_hi = 0.3615·e^{γ}.)

### 2.2 Small-scale corner

‖D(y − E)‖₁ ≥ ‖Dy‖₁ − ‖DE‖₁ ≥ nR_n − 8‖E‖₁ (R_n := ‖Dy‖₁/n; absolute column sums of D are ≤ 8). For x < k: 𝔼_s e^{x|E₁|/s} = t·[1/(τ − x) + 1/(1 − τ − x)] =: **M_τ(x)** (two exponential integrals). Hence, for 8ℓs < k,

  **g_n(s, ℓ) ≤ log(ℓ/(2t)) − ℓ·R_n + log M_τ(8ℓs).**

At τ = ½, M(x) = 1/(1 − 2x), so g_n ≤ log(2ℓ) − ℓR_n − log(1 − 16ℓs). With R_n → R = 1.189 this is ≤ b\* − γ on

  **s ≤ s_lo(ℓ) := [1 − exp{−(b\* − γ − log(2ℓ) + ℓR)}]/(16ℓ).**

(For γ small: s_lo(1.38) ≈ 0.036, s_lo(10) ≈ 0.0062, s_lo(100) ≈ 1/1600.) The exponent b\* − log(2ℓ) + ℓR is positive for every ℓ > 0 because max_ℓ[log(2ℓ) − ℓR] = −1 − log(R/2) = −0.48 < b\*; this is the necessary condition σ₀ < 2tR with its margin.

### 2.3 Grid lemma (one-sided Lipschitz, data-free)

For every data vector, s′ ≤ s and ℓ ≤ ℓ′:

  **g_n(s′, ℓ′) ≤ g_n(s, ℓ) + log(s/s′) + log(ℓ′/ℓ) + O(log n/n).**

*Proof.* e^{−Q/s′} ≤ e^{−Q/s} gives Z(s′, ℓ) ≤ (s/s′)ⁿZ(s, ℓ). (ℓ′/2)^m e^{−ℓ′‖u‖₁} ≤ (ℓ′/ℓ)^m·(ℓ/2)^m e^{−ℓ‖u‖₁} gives Z(s, ℓ′) ≤ (ℓ′/ℓ)^m Z(s, ℓ). ∎

So on a geometric grid of ratio e^{δ} in both variables, the node (s_a, ℓ_b) controls the cell s ∈ [s_ae^{−δ}, s_a], ℓ ∈ [ℓ_b, ℓ_be^{δ}] at a cost 2δ. **No derivative bounds are needed.**

### 2.4 Two computable upper bounds for Φ_n at a node

**(H4) Four-class Hölder** (`FABLE_A_Arule_lowertail.md` §6.1). Φ_n(s, ℓ) ≤ (4n)⁻¹Σⱼlog φ_s(4ℓ; (Dy)ⱼ), with φ_s(a; x) := 𝔼_s exp{−a|x − (E₁ − 3E₂ + 3E₃ − E₄)|}.

**(BL) Block decoupling.** Cut {1, …, n} into consecutive blocks b of length L and drop the three stencils crossing each boundary (each factor is ≤ 1). Then

  Φ_n(s, ℓ) ≤ n⁻¹Σ_b log Ξ_b,  Ξ_b := 𝔼_s exp{−ℓ‖D^{(L)}(y_b − E_b)‖₁} ∈ (0, 1],

and the Ξ_b are **independent** across blocks (disjoint coordinates). The price is that the prefactor log(ℓ/(2t)) still counts the dropped stencils: a loss of 3·log(ℓ/2)/L per observation for ℓ > 2.

**(CH) Quenched-to-moment (Chernoff).** For independent variables X_b = log Ξ_b ≤ 0 and any θ ∈ (0, 1], η > 0: with probability ≥ 1 − e^{−nη},

  n⁻¹Σ_bX_b ≤ (θn)⁻¹Σ_b log E_y[Ξ_b^θ] + η/θ.

(Markov on exp{θΣX_b}.) θ = 1 is the annealed bound; θ ↓ 0 gives the quenched mean L⁻¹E log Ξ_b. The same applies to (H4) within each of its four classes.

**Resulting sufficient condition.** With N_nodes nodes and N_nodes·e^{−nη} → 0: (DC_γ) holds if at every node of the rectangle of §4.1

  **log(ℓ/(2t)) + (θL)⁻¹·avg_b log E_y[Ξ_b(s, ℓ)^θ] + η/θ ≤ b\* − γ − 2δ**  (or the analogue with (H4)).

The left side is a property of the design only. The truth enters through ‖Dθ\*‖₁ ≤ V/n², a factor e^{ℓV/n²} = 1 + o(1).

---

## 3. Why there is no proof at τ = ½ — and rough estimates (CONJECTURE)

- **(H4) alone is not enough.** Rough hand estimates at s = σ₀ (E₁ − 3E₂ + 3E₃ − E₄ has s.d. ≈ 1.7, (Dy)ⱼ has s.d. ≈ 1.5): the (H4) bound is ≈ 0.4 at ℓ = 1.4 (margin ≈ 0.6 against b\* = 1.02) but ≈ 1.3 at ℓ = 5 (fails). It grows like ¾·log ℓ. I expect it to certify **ℓ ≲ 3** only. These numbers are order-of-magnitude, not computed.
- **Annealing (θ = 1) fails at small s·ℓ.** As s → 0 the annealed value tends to log(ℓ/(2t)) plus the log-probability per site that the *noise itself* has third differences ≲ 1/ℓ, which is close to 0 for large ℓ; the quenched value there is log(ℓ/(2t)) − ℓR. Rare smooth data dominate the annealed average. So annealed bounds can only be used away from the corner, and the corner bound of §2.2 covers only s ≤ s_lo(ℓ) ≈ 0.06/ℓ.
- **Convexity does not help.** log∫e^{−aQ − ℓ‖Dθ‖₁}dθ is convex in (a, ℓ), so it lies below its chords; but the known boundary values (ℓ = 0; a → ∞) give back only the trivial bounds of regions (I) and §2.2.
- **Astra's remark applies:** in this range a constant fraction of the n directions is fitted (k_eff/n ≍ ℓ^{−1/3}), so nothing local or sign-based is available. The margin itself is of that order: about (6 − β̄)(2ωf)^{1/6}ℓ^{−1/3}/6 ≈ 1.2·ℓ^{−1/3} in the proxy (0.56 at ℓ = 10, 0.26 at ℓ = 100; the proxy is not reliable for ℓ of order 1).

So (DC) at τ = ½ is a finite computation, and I see no way around doing it.

---

## 4. Certificate specification

### 4.1 Domain and grid

- Rectangle: 𝒦 := {(s, ℓ) : ℓ₁ ≤ ℓ ≤ ℓ₀, s_lo(ℓ) ≤ s ≤ s_hi}, with s_lo, s_hi from §2.1–2.2 evaluated at R − 0.01 and σ₀ ± 1% (both are laws of large numbers; the 1% is paid in γ).
- Grid: ℓ_b = ℓ₁e^{bδ}, s_a = s_hi·e^{−aδ}; node (s_a, ℓ_b) certifies its cell by §2.3. Take **δ = 0.02** and γ = 0.05; the node inequality must hold with slack 2δ + γ + η/θ.
- Size: (log(ℓ₀/ℓ₁)/δ)·(log(s_hi/s_lo)/δ). For ℓ₀ = 20: 135 × ~250 ≈ 3·10⁴ nodes. For ℓ₀ = 100: 215 × ~300 ≈ 6·10⁴.
- **Choice of ℓ₀.** Any constant serves the chain (the range above ℓ₀ is gap G4 regardless). The cost of Tier 2 grows with ℓ₀ because the margin shrinks like ℓ^{−1/3} while the block loss is 3·log(ℓ/2)/L. Start with ℓ₀ = 20.

### 4.2 Tier 1: four-class bound — deterministic, interval arithmetic

- *Functions.* At τ = ½, Eᵢ is Laplace with scale 2s. The density of W := E₁ − 3E₂ + 3E₃ − E₄ has characteristic function (1 + 4s²ω²)^{−2}(1 + 36s²ω²)^{−2}; by partial fractions it is an explicit combination of (1 + |w|/c)e^{−|w|/c} with c ∈ {2s, 6s}. Then φ_s(a; x) = ∫e^{−a|x − w|}g_W(w)dw is a closed-form combination of exponentials in |x| (piecewise). For the Gaussian design (Dy)ⱼ ~ N(0, 20·s(uⱼ)²·(1 + O(1/n))).
- *Node quantity.* H_θ(s, ℓ) := log(2ℓ) + (4θ)⁻¹∫₀¹log E_ξ[φ_s(4ℓ; √20·s(u)·ξ)^θ]du + 4η/θ, with θ ∈ {1, ½, ¼} (take the best) and η = 10⁻³. A two-dimensional integral (ξ, u) of a closed-form integrand; enclose it by interval quadrature. Monotonicity in u (through s(u)) can replace the u-integral by 8 bins with upper bounds.
- *Pass criterion.* H_θ(s_a, ℓ_b) ≤ b\* − γ − 2δ.
- *Cost.* 3·10⁴ nodes × a 2-D interval quadrature: minutes to an hour on one core.
- *Expected outcome.* Pass for ℓ up to a few units (CONJECTURE, §3). The run tells where it stops; call that ℓ_H.

### 4.3 Tier 2: block bound on [ℓ_H, ℓ₀]

- *Block length.* L ≥ 3·log(ℓ₀/2)/(margin/3); for ℓ₀ = 20 and margin 0.4: L ≈ 50. For ℓ₀ = 100: L ≈ 150.
- *Transfer recursion for one block.* With w = y_b − E_b, the L-fold integral is a chain with state (w_{i}, w_{i+1}, w_{i+2}): h_{i+1}(w₂, w₃, w₄) = q_{i+3}(w₄)·∫e^{−ℓ|w₄ − 3w₃ + 3w₂ − w₁|}h_i(w₁, w₂, w₃)dw₁, where q_i is the density of yᵢ − Eᵢ (quenched: a Laplace density centred at yᵢ; annealed: the convolution of the noise density with the Laplace density, which for Gaussian noise is a closed form with erfc).
- *Annealed version (θ = 1): rigorous.* The integrand is positive, so replacing each kernel by its cell-wise supremum on a product grid gives a rigorous **upper** bound; truncate at ±6 noise s.d. with the explicit Gaussian/Laplace tail. Grid 64³ states: 1.7·10⁷ operations per step, × L steps, × 8 design bins, × the nodes not passed by Tier 1. For ℓ₀ = 20: ≈ 10¹⁴ operations, of order 10–30 core-hours. **Expected to pass only where s is not small relative to 1/ℓ** (§3).
- *Quenched version (θ < 1): statistical.* E_y[Ξ_b^θ] requires an average over simulated blocks y_b; each Ξ_b is one run of the recursion. With N_MC blocks and a Bernstein confidence bound (0 ≥ θ·log Ξ_b ≥ −θℓ‖D^{(L)}y_b‖₁, so Ξ_b^θ ∈ (0, 1]) this certifies the node at a stated confidence level. It is **not a proof**; it should be labelled as such. Cost ≈ N_MC (10²–10³) times the annealed cost at the nodes concerned: of order 10³ core-hours on NOTS.
- *Between the two.* The region where neither §2.2 nor the annealed bound works is, by §3, roughly s_lo(ℓ) < s ≲ 1/ℓ. If it is non-empty after Tier 2-annealed, the only rigorous alternative I see is a longer-range corner bound: condition on blocks, apply §2.2's argument to E restricted to a subset of coordinates, and integrate the rest. Not designed here.

### 4.4 Tier 3: cheap map of the surface (non-rigorous; do this first)

By differentiation under the integral, at fixed (s, ℓ) with posterior expectation E_{s,ℓ}:

  ∂_{log ℓ}log Z = m − ℓ·E_{s,ℓ}‖Dθ‖₁,  ∂_{log s}log Z = −n + E_{s,ℓ}[Q(θ)]/s.

Both are means in a fixed-(σ, λ) Gibbs chain. As s → 0, g_n(s, ℓ) → log(ℓ/(2t)) − ℓR_n exactly (the bound of §2.2 is tight there). Integrating ∂_{log s} upward from a small s (say s_lo(ℓ)/10, where the §2.2 slack log M_τ(8ℓs) is below 0.01) yields g_n on the whole rectangle. About 20 values of ℓ × 15 of s = 300 short chains at one n (n = 2000 suffices: g_n is a per-observation quantity). This locates the worst node and the true margin, and tells whether Tiers 1–2 are worth running and with which ℓ₀ and L. **UNTESTED.**

---

## 5. Flags

- **Deliverable 2 is negative:** no proof at τ = ½.
- **Tier 1 is the only fully rigorous, cheap piece,** and I expect it to cover only ℓ ≲ 3. The estimates behind that are rough.
- **Tier 2-annealed may fail in a band of small s·ℓ.** If so, (DC) on [ℓ_H, ℓ₀] would rest on a statistical certificate, and the paper should say so.
- **Other designs and levels.** §2 holds for every τ (with M_τ) and every law. Tier 1 needs the law of (Dy)ⱼ: Gaussian for the Gaussian design (2-D integrals); for Beta and Mixed it is a 4-fold convolution, so the node quantity becomes a 4- or 5-dimensional integral, or the statistical version. For τ ≠ ½ the density of E₁ − 3E₂ + 3E₃ − E₄ is still an explicit exponential-polynomial mixture (asymmetric).
- **What (DC) does not give.** Even certified, it excludes only [ℓ₁, ℓ₀] with ℓ₀ a constant. The range from ℓ₀ to n^{99/43} is gap G4 and is untouched.
- **Not verified:** all numbers in §3 and the cost figures in §4 are hand estimates.

---

## Theory response (2026-11-23)

**Status: L2 is OPEN. There is no proof at Gaussian τ = ½.** The statement and the reductions are PROVED (one pass), UNAUDITED. The certificate is a specification only (UNTESTED).

**Checked by Theory: the grid lemma direction.** For s′ ≤ s, the AL density ratio is p_{s′}/p_s = (s/s′)·e^{−ρ(1/s′ − 1/s)} ≤ s/s′, per coordinate. For ℓ′ ≥ ℓ, e^{−ℓ′‖·‖₁} ≤ e^{−ℓ‖·‖₁}. So a node (s, ℓ) controls every (s′, ℓ′) with s′ ≤ s and ℓ′ ≥ ℓ, at the stated additive cost. **Ruling: HOLDS.**

**For the plan, link L2:**
1. **First, Tier 3**, the cheap non-rigorous surface map (≈ 300 fixed-(σ, λ) chains). It locates the worst node and the true margin. Engineering to price it; Tuesday at the earliest (HQ: no compute tonight).
2. **Tier 1**, rigorous, under 1 core-h, covers ℓ ≲ 3 only.
3. **Tier 2 annealed**, rigorous, 10–30 core-h. It may fail in the band s ∈ [0.06/ℓ, 1/ℓ].

**Fallback:** (DC) as a named assumption, with the Tier 3 map as empirical support. This is the same treatment as L4a.
