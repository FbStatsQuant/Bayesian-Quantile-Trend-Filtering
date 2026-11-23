# Audit: `astra_noFloor.md` (no-floor evidence obstruction) — Fable, cross-family referee

*2026-11-23. Read-only audit; all checks by hand, no code run. Target: `theory/T06_Alignment/astra_noFloor.md`, including the Theory verification section.*

## Verdict: **ACCEPT WITH FIXES**

No mathematical error found. Every step of the evidence comparison, every number in the counterexample, the learned-σ consequence and the necessary condition were re-derived and hold. The fixes are to wording and scope, mainly in the Theory interpretation ("the floor is needed", "excludes exactly"), plus two editorial points in Astra's text.

Notation as in the target: t = τ(1−τ), k = min(τ, 1−τ), m = n−3, D = D⁽³⁾, R_n = ‖Dy‖₁/n, Q\* = Q(θ\*).

---

## Findings

### A. Evidence comparison (claim 1)

**1. CONFIRMED — normalization is consistent between numerator and denominator.**
The map θ ↦ (c₀, u) = (Nᵀθ, Dθ) has matrix [Nᵀ; D] with Gram matrix diag(I₃, DDᵀ) (because DN = 0), so d c₀ du = J_n dθ with J_n = √det(DDᵀ). Astra's Z (flat dc₀ × normalized Laplace (ℓ/2)^m e^{−ℓ‖u‖₁}du × the two probability hyperpriors) equals J_n·2^{−m} times the normalizer of Felipe's posterior. The constant cancels in Z_{Q≥nq}/Z, which is therefore exactly Π(Q ≥ nq | y). The target posterior matches the paper's object (σ-free penalty, λ^m, Gamma(λ; 1, b₀), IG(0.1, 0.1)).

**2. CONFIRMED — numerator bound.**
- On {Q ≥ nq}: e^{−Q/s} = e^{−Q/(ns)}·e^{−(n−1)Q/(ns)} ≤ e^{−Q/(ns)}·e^{−(n−1)q/s}.
- Q ≥ k‖y−θ‖₁ ≥ k‖y−θ‖₂ ≥ k‖Nᵀy − c₀‖₂, using NᵀN = I₃ and NᵀS = 0. This holds for every u.
- ∫_{ℝ³} e^{−k‖Nᵀy−c₀‖₂/(ns)} dc₀ = 8π(ns/k)³. So **C_k = 8π/k³** (the text leaves it implicit).
- The Laplace law on u and both hyperpriors are probability measures, so Z_{Q≥nq} ≤ C_k n³ sup_s s^{3−n}e^{−(n−1)q/s}.
- With w = 1/s the supremum is at w = (n−3)/((n−1)q), i.e. s = (n−1)q/(n−3), value [(n−3)/(e(n−1)q)]^{n−3}. The per-observation limit is −1 − log q, for all data.

**3. CONFIRMED — J_n ≥ 1.** Cauchy–Binet: det(DDᵀ) is the sum of squared m×m minors of D. The minor on the last m columns is lower triangular with diagonal entries ±1. Only the lower bound J_n ≥ 1 is used, and only in the denominator; the numerator in Astra's normalization contains no J_n. (So the condition det(DDᵀ)^{1/n} → 1 from the sketch in `FABLE_joint_V2.md` §1 is not needed.)

**4. CONFIRMED — denominator identity and Jensen step.**
- ∫ s⁻¹e^{−ρ_τ(x)/s}dx = 1/τ + 1/(1−τ) = 1/t, so s^{−n}e^{−Q(y−E)/s} = t^{−n}·∏(normalized ALD density at E_i). With θ = y − E, dθ = dE, the fixed-(s, ℓ) evidence is J_n(ℓ/2)^m t^{−n} E_s e^{−ℓ‖D(y−E)‖₁}.
- Auxiliary ALD: mass 1−τ on the positive side with conditional mean s/τ, mass τ on the negative side with conditional mean s/(1−τ). So E_s|E_i| = s[(1−τ)² + τ²]/t ≤ s/k (a convex combination of s/τ and s/(1−τ)).
- Column absolute sums of D are ≤ 1+3+3+1 = 8, so E‖DE‖₁ ≤ 8ns/k. Jensen plus the triangle inequality give E e^{−ℓ‖D(y−E)‖₁} ≥ exp[−nℓ(R_n + 8s/k)].
- Hence n⁻¹log Z(s, ℓ) ≥ g(ℓ, s) − (3/n)log(ℓ/2), with g(1/r, 0) = −1 − log(2tr).

**5. CONFIRMED — the fixed rectangle.** g is continuous on {ℓ > 0, s ≥ 0}; a closed rectangle [ℓ₁, ℓ₂] × [s₁, s₂] with 0 < s₁ < s₂ small and ℓ near 1/r keeps g > −1 − log q + 2c. Exp(b₀) and IG(0.1, 0.1) have positive densities on (0, ∞), so the rectangle has fixed positive mass p₀. The (3/n)log(ℓ/2) correction is bounded on it. Result: Π(Q ≥ nq | y) ≤ e^{−2cn + O(log n) − log p₀} ≤ e^{−cn} for n ≥ n₀(τ, r, q, b₀, IG), on {R_n ≤ r}.

**6. CONFIRMED — transfer to neighbourhoods.** ρ_τ is max(τ, 1−τ)-Lipschitz, so ‖θ−θ\*‖_{1,n} ≤ s\* − q and Q\*/n ≥ s\* force Q(θ) ≥ nq. The RMS ball and the sup-norm ball of the same radius sit inside the ℓ₁-average ball. The min(δ², |δ|) step (‖δ‖_{1,n} ≤ √v + v) is correct.

**7. CONFIRMED (editorial fix) — the displayed bound needs less than stated.** Π(Q ≥ nq | y) ≤ e^{−cn} uses only R_n ≤ r and q > 2tr. The hypotheses Q\*/n ≥ s\* and q < s\* are needed only for the ball consequence in finding 6. Suggest stating the two parts separately.

**8. CONFIRMED (editorial fix) — notation clashes.** Here k = min(τ, 1−τ) and C_k = 8π/k³, while elsewhere in T06 k is the trend-filter order and C_k = (k+1)² (general-k memo); t is a vector in `FABLE_A_n56.md`. Rename before this is merged into the package (e.g. κ_τ, C_τ).

### B. Counterexample (claim 2)

**9. CONFIRMED — every number.** Recomputed by hand, τ = 0.05, t = 0.0475, k = 0.05:

| Quantity | Target | Recomputed |
|---|---|---|
| Weights | sum to 1 | 0.049 + 0.002 + 0.949 = 1 |
| F on \|x\| < 0.005 | 0.05 + 0.2x | 0.049 + 0.002(x + 0.005)/0.01 = 0.05 + 0.2x; f(0) = 0.2 |
| (A2) | L = 0.004, slopes 0.2 | exact equality \|F(δ) − F(0)\| = 0.2\|δ\| for \|δ\| ≤ 0.005; unique quantile 0 |
| σ₀ lower | ≥ 0.04745 | 0.949 · 0.05 · 1 = 0.04745 |
| σ₀ upper | < 0.049 | 0.000931 + 0.0000095 + 0.04749745 = 0.04843795 |
| σ₀ exact | — | 0.00069825 + 0.0000025 + 0.04747373 = **0.048174** |
| σ̄ = t/f(0) | 0.2375 | 0.0475/0.2 = 0.2375 |
| σ₀/σ̄ | (0.19, 0.21) | bounds 0.1998 and 0.2039; exact **0.2028** > 1/6 |
| E\|Y − 1\| | < 0.053 | crude 0.04998 + 0.00201 + 0.000949 = 0.052939; exact 0.0522095 |
| R_n bound | ≤ 0.424 w.p. → 1 | 8 · 0.052939 = 0.4235 < 0.424, strict, so the weak law applies |
| Q\*/n | ≥ 0.047 w.p. → 1 | limit σ₀ ≥ 0.04745 > 0.047, strict |
| 2tr | 0.095 · 0.424 | 0.04028 < q = 0.043 < s\* = 0.047 |
| Ball radius | 0.004 | s\* − q = 0.004 |

(A1) holds by independence, (A3) with V any value ≥ 0 since θ\* = 0, uniform integrability by boundedness, σ₀,ₙ ≥ d with d = 0.047.

**10. PLAUSIBLE — actual size of the violation.** By hand (two-cluster approximation with P(low) = 0.051), R = lim R_n ≈ 0.38, so 2tR ≈ 0.036 and σ₀/(2tR) ≈ 1.3. The true per-observation evidence gap is about log 1.3 ≈ 0.28, larger than the 0.065 obtained from the crude r = 0.424. Not needed for the proof.

**11. CONFIRMED — learned-σ consequence.** σ | θ, λ, y ∝ σ^{−(n+0.1)−1}e^{−(Q+0.1)/σ}, free of λ, so G = (0.1 + Q)/σ ~ Gamma(n + 0.1, 1) with mean = variance = n + 0.1. Chebyshev: P(G < 0.97n) ≤ (n + 0.1)/(0.03n + 0.1)² → 0, uniformly in (θ, λ, y). On {G ≥ 0.97n, Q < 0.043n}: σ ≤ 0.04433 + 0.103/n < 0.045 eventually. So Π(σ > 0.045 | y) → 0 in probability while σ₀ ≥ 0.04745; i.e. Π(|σ/σ₀ − 1| ≥ 0.05 | y) → 1. All three conclusions of V0T\* (rate, sup-norm, scale) fail for the no-floor posterior on this law.

### C. Necessary condition (claim 3)

**12. CONFIRMED — σ₀ ≤ 2τ(1−τ)R is necessary** for consistency in average absolute error (hence RMS and sup-norm) whenever R_n → R and Q\*/n → σ₀ in probability. Under (A3), |‖Dy‖₁ − ‖DZ‖₁| ≤ Vn⁻², so R is a functional of the noise alone, as `noFloor_necessary.py` assumes. The condition is the s → 0, ℓ = 1/R corner only; Astra correctly calls it necessary and not sufficient.

**13. CONFIRMED — the factor 2 is right, and it differs from the earlier sketch.** The conjectured (NI) in `FABLE_joint_V2.md` §1 reads σ₀ < (1−η)·τ(1−τ)·n⁻¹E‖DZ‖₁, without the 2. Astra's constant is the correct one for this argument: sup_ℓ (ℓ/2)^m e^{−ℓnR} = (2eR)^{−n} up to polynomial factors, against the truth mode's (eσ₀)^{−n}. The sketch was stricter by the Laplace normalizer. Under the sketch's version the paper designs would have ratio 0.36–0.95 (Beta, τ = 0.99: 0.95), i.e. almost no margin, so the "with margin" statement rests on this factor. Suggest correcting the sketch or cross-referencing.

**14. Design check — CONFIRMED for Gaussian, PLAUSIBLE for Beta and Mixed.**
- Gaussian, closed form: R = (1/3)√20·√(2/π) = 1.1894; σ₀ = φ(z_τ)/3 = 0.13298, 0.10593, 0.03438, 0.00888 at τ = 0.5, 0.25, 0.05, 0.01. Ratios 0.224, 0.237, 0.304, 0.377. All match the `.out` file.
- Mixed: Gaussian-proxy R ≈ 0.7979·√(20·(0.5 + 0.16/6)) ≈ 2.59, matching 2.5899. Ratios equal to the Gaussian ones to three digits is expected (near scale family; the ratio is scale-invariant).
- Beta: Simpson on a Gaussian proxy gives R ≈ 0.51 against 0.4943. Not recomputed exactly (no compute in this audit).

### D. Does the counterexample show the floor is needed?

**15. CONFIRMED — the law lies in the class of Theorems C, C\* and V0T\*.** Their law-side hypotheses are (A1), full (A2) with fixed (L, f, f̄), (A3), row-average uniform integrability and σ₀,ₙ ≥ d; none requires (EM), σ ≥ σ̄ or moments. The example meets all of them with (L, f, f̄, V, d) = (0.004, 0.2, 0.2, any, 0.047). The remaining hypotheses concern the method (deterministic λ in C and C\*; p_n supported on [Λ₋, ∞) in V0T\*). So on this one law V0T\* gives contraction with the floor, and the exact no-floor posterior puts mass ≤ e^{−cn} on a fixed neighbourhood of the truth. There is no conflict with Lemma S §2 (it needs λ/log n → ∞) or with V0T\* (the floor removes the rectangle near ℓ = 1/r).

**16. CONFIRMED (fix to the Theory section) — "the floor is needed" and "excludes exactly" overstate what is proved.**
- Proved: no theorem over this assumption class can hold for the unmodified method. Some change is required: either to the hyperprior or to the class.
- Not proved: that a floor, or the level κ₋n^{5/2}, is necessary. The obstruction only needs −log p_n(rectangle) = o(n). Any λ-prior with exponentially small mass on bounded λ removes it; the floor is one sufficient repair and removes far more than "exactly these configurations".
- The other repair, keeping the method and adding σ₀ ≤ (1−η)·2τ(1−τ)R to the class, is OPEN, as the Theory section already says.
- Suggested wording: "the exact method admits no class-wide theorem; V0T's floor is a sufficient repair; whether the no-interpolation condition alone suffices is open."

**17. CONFIRMED — the obstruction is wider than stated.** The proof uses only positive hyperprior mass on a fixed rectangle. It therefore covers any Gamma(a₀, b₀), any IG(a, b), and the scaled unfloored hyperprior b_n = c·n^{−5/2} (mass of [ℓ₁, ℓ₂] ≈ b_n(ℓ₂ − ℓ₁), polynomially small). So V2 without the floor is obstructed too, consistent with `astra_learned_lambda.md`.

**18. PLAUSIBLE — general order k.** Each step is order-free: nullspace dimension k+1 gives (ns)^{k+1}, column sums 2^{k+1}, J_n ≥ 1 by the same minor. The threshold becomes σ₀ ≤ 2τ(1−τ)R⁽ᵏ⁾ with R⁽ᵏ⁾ = lim ‖D⁽ᵏ⁺¹⁾y‖₁/n. Not checked line by line.

**19. PLAUSIBLE — the example's n₀ is of order 10⁴; a rescaled law would be testable (UNTESTED).**
- At ℓ = 1/r the margin is log(q/(2tr)) − 8s/(kr) = 0.0653 − 377s, so the rectangle needs s ≲ 1.7·10⁻⁴. There IG(0.1, 0.1) has mass about e^{−0.1/s}, i.e. −log p₀ ≈ 600–1000. The proof's bound becomes non-trivial only for n ≳ 6·10³ (using R ≈ 0.38) to 3.5·10⁴ (using r = 0.424).
- Nothing in the claim is affected (it is asymptotic), but the failure should not be expected in a simulation at n = 500, and its absence there would not contradict the result.
- Multiplying Y by 1000 keeps σ₀/σ̄ = 0.2028 and every hypothesis (constants L = 4, f = f̄ = 2·10⁻⁴, d = 47), moves the rectangle to s ≈ 0.1–0.2 where the IG mass is O(1), and costs only −log(b₀·Δℓ) ≈ 10–15 in the λ prior. Hand estimate: n₀ of order 10³. This is a suggestion for an optional numerical illustration, not a tested claim; a pilot would be one exact-Gibbs run at n ≈ 2000 on that law.

---

## Summary of required fixes

1. Separate the two parts of the comparison statement (finding 7).
2. Rename k, t, C_k and state C_k = 8π/k³ (findings 2, 8).
3. Reword the Theory interpretation as in finding 16, and note the wider scope of finding 17.
4. Reconcile the factor 2 with the (NI) sketch in `FABLE_joint_V2.md` (finding 13).

Optional: record the n₀ remark and the rescaled example (finding 19).

**Status after fixes:** the obstruction, the counterexample, the σ consequence and the necessary condition can be marked cross-family audited.
