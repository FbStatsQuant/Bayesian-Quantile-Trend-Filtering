# The rate gap n^{−4/7} → n^{−5/6} below σ̄: where it is lost, and the route to recover it

> **SUPERSEDED** by `FABLE_lemmaF_C2.md` (proofs) and `THEOREM_C_STAR.md` (assembly). Kept as the planning record.

*Fable, planning consult for Theory, 2026-11-23. Exponent-level only. **Nothing here is proved**; each claim is marked SKETCH or CONJECTURE. Notation as in `C1_any_sigma.md`; oracle λ = n^{5/2}/V; nε² ≍ (n log n)^{1/6}V^{1/3}.*

**Bottom line.** The gap is two separate losses: n^{−4/7} → n^{−5/7} (one line of Lemma W) and n^{−5/7} → n^{−5/6} (the supremum in C1 Step 3). One new elementary lemma (F) repairs the first and is the only missing input for the second, via Hölder–Knight (C2) on C1's localized body. I found no exponent obstruction to n^{−5/6}(log n)^{1/6} with σ learned and λ deterministic.

## 1. Where the exponent is lost

**Loss A, n^{−5/7} → n^{−4/7}: Lemma W, step 5 — SKETCH.** The loss is not the ℓ₁/ℓ∞ duality (that is sharp up to √log for an ℓ₁ ball). It is the line "Σ_{r>k}σ_r²b_r(j)² ≤ Σ_{r>k}σ_r²", which bounds one column of A_{>k} by the whole Frobenius norm. The true column size is smaller by a factor 1/m: ≍ n⁴k^{−5}, not n⁵k^{−5}. With the column bound, the tail becomes T₀√n·k^{−5/2}√log n instead of T₀n·k^{−5/2}, and balancing at k³ = T₀/ρ gives the entropy width √n·ρ^{5/6}T₀^{1/6}√log n in-house. C1 then gives r² ≍ n^{−6/7}T₀^{2/7} = n^{−5/7} (with logs), and condition (i) relaxes to λ ≫ n^{21/11}. The fix is Lemma F below (spline projector instead of SVD truncation).

**Loss B, n^{−5/6} → n^{−5/7}: C1 Steps 3–4, the event G = sup_{K′}|ℛ − M| ≤ (f/4)nr² — SKETCH.** Your guess is right, with one refinement.
- T₀ ≍ n³/λ = V√n is forced: prior and posterior draws have λ‖u‖₁ ≈ m, and Step 6 needs T ≥ 4.
- The fixed point of any uniform bound over a third-order ball of radius √n is n^{−6/7}(√n)^{2/7} = n^{−5/7}. A better width cannot beat it, and neither can extra constraints: I checked that adding ‖u‖₂ ≲ √m/λ to the gauge (a Sobolev-3 ball of radius √n) gives λ^{−2/7} again.
- The mechanism: in the fine directions (beyond J ≍ nε² ≍ n^{1/6} spline coefficients) the supremum pays **linearly**, ‖u‖₁‖t‖∞ ≍ T₀√n·J^{−5/2} ≍ n^{7/12}, while integration against Π_λ pays **quadratically**, ω²Σtⱼ²/λ² ≍ nJ^{−5} ≍ n^{1/6} = nε². Theorem B gets this for free from Fubini; C1 gives it up by taking the supremum before integrating.

## 2. Realized control below σ̄: yes at sketch level, through Lemma C2

**Lemma F (fine-scale columns) — SKETCH, elementary, new.** Let P_J be the orthogonal projector of ℝⁿ onto discrete C¹ quadratic splines with J equispaced knots (dimension J + 3, containing range N). Then

  max_j ‖(I − P_J)Se_j‖₂ ≤ C_F(n/J)^{5/2},  hence ‖(I − P_J)S‖²_F ≤ C_F²·n(n/J)⁵.

*Idea.* Se_j is a truncated quadratic modulo N. Subtract a spline matching the zeroth and first moments of its second-difference defect over two knot cells. The error then lives on ≤ 2n/J points with size ≤ (n/J)².

**Lemma C2 (realized numerator on a shell) — SKETCH.** Assume (A1), full (A2), (A3), λ ≍ n^{5/2}/V, ω ∈ [ω₁, ω₂]. Put s₀ := min(L, 3f/(4ω₂f̄)), J := ⌊(f²/128)·M·nε²⌋ and, for a ≥ M,

  E_a := {aε² < ‖δ‖²ₙ ≤ 2aε², ‖δ‖∞ ≤ s₀}  (deterministic, centred at θ\*).

There is an ω-free event Ω_ψ with P₀(Ω_ψᶜ) → 0 such that, for each a, with probability ≥ 1 − e^{−ηω·a·nε²} on Ω_ψ,

  N_ω(E_a) ≤ V₃(2a·nε²)^{3/2}·exp{ −ω(f/8 − η)·a·nε² + C·ω²·nε²/(M⁵ log n) + o(nε²) }.

*Proof skeleton.*
1. **Knight.** ℛ = −⟨ψ, δ⟩ + R(δ), with ψᵢ = τ − 1{Zᵢ < 0} (bounded, mean zero) and Rᵢ ≥ 0. Cauchy–Schwarz in ν: N(E_a) ≤ (∫_{E_a}e^{2ω⟨ψ,δ⟩}dν)^{1/2}(∫_{E_a}e^{−2ωR}dν)^{1/2}.
2. **Remainder, by Fubini, any ω.** E Rᵢ² ≤ f̄|δᵢ|³/3 (secant form of (A2) suffices) gives E e^{−2ωRᵢ} ≤ e^{−ωmᵢ} for |δᵢ| ≤ s₀. So E₀∫_{E_a}e^{−2ωR}dν ≤ poly·e^{−ω(f/2)a·nε²}; then Markov.
3. **Score, coarse.** |⟨P_Jψ, δ⟩| ≤ ‖P_Jψ‖₂√n‖δ‖ₙ ≤ √((J+3)·2a·nε²) ≤ (f/8)a·nε² on Ω_ψ. No net, no chaining.
4. **Score, fine.** ⟨(I − P_J)ψ, δ⟩ = ⟨t, u − u\*⟩ with t = Sᵀ(I − P_J)ψ. Keep the c-section (volume V₃(2a·nε²)^{3/2}), drop the u-indicator, and use the exact Laplace MGF ∏ⱼ(1 − 4ω²tⱼ²/λ²)^{−1}.
   - By F and Hoeffding, ‖t‖∞ ≤ C_F(n/J)^{5/2}√(2 log 2m) and Σtⱼ² ≲ n(n/J)⁵.
   - Log-MGF ≲ ω²V²nJ^{−5} = Cω²nε²/(M⁵ log n); V cancels.
   - Truth shift 2ω|⟨t, u\*⟩| ≤ 2ω‖t‖∞V/n² ≍ n^{1/12} = o(nε²).

**Assembly — SKETCH.** Π(‖δ‖²ₙ > Mε² | y) ≤ Π(K′ᶜ | y) [C1] + Σ_{a=2^kM} N(E_a ∩ K′)/N(ℝⁿ) [C2 over L6]. This → 0 once ω₁(f/8 − η)M > ω₂(1.44C₁ + 1) + C_pr. Uniformity in ω comes from e^{−ωx} ≤ e^{−ω₁x} + e^{−ω₂x}, as in memo (c). Sanity check: the constant scales as M ≍ ω^{1/6}, matching the sandwich term κ^{1/6}λ^{−1/3} of the memo.

**Where it could fail.**
- **Exponential moment of the fine tilt: safe, but only with F.** It needs 2ω‖t‖∞ < λ, and 2ω‖t‖∞/λ ≍ ωV√(log n)·J^{−5/2} ≍ n^{−5/12} → 0, a wide margin. It requires **column-wise** control of t. With W's Frobenius-only bound, ‖t‖∞ ≲ n³J^{−5/2}√log n: the MGF then needs J ≫ n^{1/5} and the truth shift needs J ≳ n^{2/7}, so C2 collapses back to n^{−5/7}. The moment also dies under λ-mixing (polynomial tail of ‖u‖₁; `astra_learned_lambda.md`).
- **Random centre: none in this lemma.** E_a ∩ K′ is deterministic and centred at θ\*, so Fubini in step 2 is legitimate; Ω_ψ is δ-free and ω-free. Localization is imported from C1 as a set intersection, not from the posterior under study. Circularity returns only if one recentres at θ̂ to sharpen the Cauchy–Schwarz constant (f/8 instead of f/2). Do not do that; it costs constants, not exponents, and coverage is not claimed.
- **Remainder.** It needs ‖δ‖∞ ≤ 3f/(4ω₂f̄) on the whole integration set, which is exactly C1 Step 1 (s_K → 0). So C2 inherits C1's window.
- **Not checked.** F in the discrete setting near the boundary; concentration of Σtⱼ² (Hanson–Wright; relative fluctuation ≍ J^{−1/2}); the sign conventions of Knight's identity at atoms.

## 3. Tuesday's route and its main risk

**Route (single recommendation): C1 → F → C2 → endpoint uniformity → Lemma S.**
1. Prove Lemma F. This also upgrades W, so C1 reaches n^{−5/7} with window λ ≫ n^{21/11}, a publishable fallback by itself.
2. Write C2 with constants on dyadic shells Mε² ≤ ‖δ‖²ₙ ≤ r² (about log n shells).
3. Assemble with L6, the two-endpoint trick on Lemma S's compact [l, H₀], and the decomposition of memo (c).

Target statement — CONJECTURE: with σ ~ IG learned and λ ≍ n^{5/2}/V deterministic, ‖θ − θ\*‖²ₙ ≲ n^{−5/6}(log n)^{1/6} in posterior probability, moment-free apart from Lemma S's uniform integrability, with no condition σ > σ̄.

**Main risk.** C2 is exponent-checked only, and it rests entirely on the uniform column bound of Lemma F for the actual discrete S. If F holds only in Frobenius average, the route gives n^{−5/7} and no more. Secondary: the rate constant grows like ω₂^{1/6}·(ω₂/ω₁) as the σ-interval widens, and learned λ stays out of scope.
