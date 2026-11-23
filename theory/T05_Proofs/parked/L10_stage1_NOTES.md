# L10 Stage 1: parked notes (checkpoint ordered by Felipe, 2026-11-22)

**Status:** PARKED. No new math until Felipe gives the green light. These notes record the state of work so that it can resume exactly from here.

**Goal of Stage 1.** Moment-free, for any ω, at deterministic λ, find r² and T₀ such that

  E₀ Πₙ( ‖δ‖ₙ ≤ r and TV⁽³⁾(δ) ≤ T₀ | y ) → 1,  with r² ≍ λ^{−2/7} (up to T-factors) and T₀ = T·n³/λ.

**Stage 2** is done and advisor-checked (`../L10I_interpolation.md`). Given Stage 1, it yields ‖δ‖∞ → 0 whenever λ/n^{21/11} → ∞.

## Main thread notes (Head of Theory)

**Route: gauge decomposition with integration against the prior ν. Status: SKETCH, all steps outlined, none written as a proof.**

1. **Body.** Let K′ := {δ : ‖δ‖ₙ ≤ r, TV⁽³⁾(δ) ≤ T₀}. It is convex and symmetric. Its gauge is t(δ) := max(‖δ‖ₙ/r, TV⁽³⁾(δ)/T₀), and K′ = {t ≤ 1}. Stage 1 is exactly Πₙ(t ≤ 1 | y) → 1.
2. **Sup-norm on K′ (L10-I, deterministic).** On K′, ‖δ‖∞ ≤ 6r + 7.06·r^{4/5}T₀^{1/5} → 0 when r⁴T₀ → 0. This is the same condition as Stage 2 (λ ≫ n^{21/11}). So on K′ every |δᵢ| ≤ Δ ≤ L, and the local margin of L2 applies: M(δ) ≥ (f/2)n‖δ‖ₙ².
3. **Uniform empirical process on K′ (moment-free).** Let G := sup_{δ∈K′} |ℛ(δ) − M(δ)|.
   - *Expectation.* Symmetrization and Ledoux–Talagrand contraction (each Xᵢ is 1-Lipschitz with Xᵢ(0) = 0) give E G ≤ 4·E sup_{K′} ⟨ε, δ⟩.
   - *Width.* The null-space part contributes ≤ √(3n)·r. The rest is the Rademacher width of a TV⁽³⁾ ball intersected with an ℓ₂ ball, with sup-norm ≤ Δ. Entropy (T₀/u)^{1/3} (Birman–Solomyak / Mammen–van de Geer; the discrete version via Guntuboyina et al. 2020, Lemma B.1, as P&C use it) and Dudley give a width ≲ √n·T₀^{1/6}r^{5/6}.
   - *Deviation.* Bousquet's inequality, with envelope 2Δ and variance ≤ n r², gives deviations ≲ √(n r² log n) + Δ log n ≪ n r².
   - *Condition.* G ≤ (f/4)n r² once n r² ≳ √n T₀^{1/6}r^{5/6}, i.e. **r² ≳ n^{−6/7}T₀^{2/7} = T^{2/7}λ^{−2/7}**. This reproduces the VP's exponent 2/7.
   - **OPEN item (i):** pin down the exact citable width/entropy lemma for the discrete class {‖δ‖ₙ ≤ r, ‖δ‖∞ ≤ Δ, TV⁽³⁾ ≤ T₀}, with its constants and any log factors. Candidates: P&C's own Gaussian-width lemma for the ℓ∞-bounded TV class, or Guntuboyina et al. 2020.
4. **Convexity along rays.** ℛ is convex with ℛ(0) = 0. So for δ ∉ K′, with δ₁ := δ/t(δ) ∈ ∂K′, we have ℛ(δ) ≥ t(δ)·ℛ(δ₁). This holds even when ℛ(δ₁) < 0.
   - **Face 1** (‖δ₁‖ₙ = r): ℛ(δ₁) ≥ M − G ≥ (f/4)n r².
   - **Face 2** (TV(δ₁) = T₀): ℛ(δ₁) ≥ −G ≥ −(f/4)n r².
5. **Integrate against ν = dc ⊗ Π_λ, not Lebesgue.** This is the key point: it avoids the n-dimensional volume factor that limits log-concavity arguments (L9-a) to a constant radius.
   - **Face-1 cone** {‖δ‖ₙ/r ≥ TV/T₀, t > 1}: e^{−ωℛ} ≤ e^{−ω(f/4)n r² t}, with t ≥ ‖c − c₀(u)‖₂/(√n r). Integrating over c ∈ ℝ³ gives a polynomial factor (8/(ωf√n r))³·8π. Π_λ has mass 1. Total ≤ poly·e^{−ωf n r²/8}.
   - **Face-2 cone** {TV/T₀ ≥ ‖δ‖ₙ/r, t > 1}: here t = λ‖u − u\*‖₁/(Tn) depends on u only. The c-range is a ball of radius √n r t, and e^{−ωℛ} ≤ e^{ω(f/4)n r² t}. Under Π_λ, λ‖u‖₁ ~ Gamma(m, 1), and a Chernoff bound gives ≤ poly·e^{−Tn/4} for T ≥ T_min (using λV/n³ ≪ T and n r² ≪ Tn).
   - **Denominator:** L6 (advisor-checked), N(ℝⁿ) ≥ V₃(ε√n/2)³e^{−Cnε²} in P₀-probability.
   - **Ratio** → 0 because n r² ≫ nε² (λ^{−2/7} ≫ λ^{−1/3}) and Tn ≫ nε².
6. **What this would give.** Πₙ(K′ | y) → 1 in P₀-probability, for **any ω** (no σ̄), moment-free, with no expected remote numerator (every bound is on an event). With Stage 2 this gives L10 for λ ≫ n^{21/11}. Note that inside K′ we also get ‖δ‖ₙ ≤ r, which is a crude contraction rate λ^{−2/7} for any σ.
7. **Points to verify on resumption:**
   - **(i)** the width lemma (above);
   - **(ii)** measurability and the exact form of the cone decomposition;
   - **(iii)** the Chernoff step with the λV/n² shift, and the T_min constant;
   - **(iv)** that L6's event and G's event combine without any independence assumption (bound on an intersection of events, as in Theorem B);
   - **(v)** whether log factors from the width or from Bousquet change the 2/7 exponent (they should only add logs to r²);
   - **(vi)** the uniformity of all constants over 𝒫ₙ.

**An earlier dead end, recorded:** a Lebesgue / log-concavity version with Ψ = ωℛ + λ‖Dθ‖₁, centred at θ\*. The prior penalty difference can be as low as −2λ‖u\*‖₁ ≍ n^{1/2} at the oracle, which beats the Huber gain n r² ≍ n^{2/7}. The polar-coordinate volume factor t^{n−1} also needs a gain ≫ n. Both problems disappear when integrating against ν.

## Fable child notes

**Status: the child was cancelled at the checkpoint (2026-11-23, Central evening of 11-22) without a deliverable.** It was a Fable 5.2 child at xhigh effort, launched 23:43 UTC.
- It stayed in a single long reasoning turn for about an hour and never consumed the four steering messages (the output path, the VP's two-stage route, the Stage 1 focus, the stop request). It wrote no file: neither `/home/fb31/L10_candidate.md` nor a section here.
- Recorded from its visible reasoning summaries, for resumption. These are exploration only, with nothing proved:
  1. **1-D log-concave marginals with a union bound.** Each θᵢ − θ\*ᵢ has a log-concave posterior marginal, hence exponential tails relative to its scale. A union bound over n coordinates would need each coordinate within ≈ Δ/log n with constant posterior probability. The open problem is getting per-coordinate control from the averaged (Huber) bound.
  2. **Borell's lemma reduction.** If Πₙ(‖δ‖∞ ≤ rₙ) ≥ 2/3 with rₙ → 0, then the tail beyond Δ is exponentially small. This only moves the problem to a constant-probability sup-norm bound. (Same conclusion as the main thread's item 4 in the original brief.)
  3. **Shift (change-of-variables) argument** with a local bump g: compare Πₙ(E) with Πₙ(E − g). It was being developed when cancelled. The issues already identified (prior cost λ‖Dg‖₁ against the local gain; uniformity of the realized ratio) are in the main thread's brief.
  4. A remark it made: the posterior spread ≍ λ^{−1/3} still shrinks for any polynomial λ.
- **Assessment (Head of Theory).** Nothing in the child's exploration supersedes the main-thread route above (gauge decomposition with integration against ν), which addresses the circularity directly. On resumption, start from the main-thread notes.
