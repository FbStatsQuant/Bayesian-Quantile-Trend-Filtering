# Gap 4: the A-rule lower tail for λ between a constant ℓ₀ and C·n^{99/43}polylog

*Fable, research sub-agent for Theory, 2026-11-23 (CT session), 40 minutes. Pure mathematics, no compute. Read first: `astra_gap4_sign.md` (§1–3), `FABLE_B_Arule_gauss.md` §3–4, `FABLE_A_three_lemmas.md`, `FABLE_A_theoremH.md`. Not audited.*

**Labels.** PROVED = written here in full from audited statements or elementary facts. SKETCH = argument given, details open. CONJECTURE = heuristic only.

## 0. Verdict

**Gap 4 is not closed.** I have no proof of κ(ℓ) ≥ 0, nor of an evidence bound, on [ℓ₀, n^{99/43}]. What this note adds:

| # | Claim | Status |
|---|---|---|
| 1 | **Exact pointwise identity** for the covariance in Astra's §2: Cov(δᵢ, gᵢ) = [R′ᵢ] − ςᵢ·[δᵢ]·πᵢ (fixed scale), ςᵢ = sign of Zᵢ, πᵢ = posterior probability that δᵢ lies beyond Zᵢ | **PROVED** (§1.1) |
| 2 | Hence E₀κ + 3 = Σᵢ E₀{ω[R′ᵢ]·(1 − ωWᵢ) + ω²Wᵢ·ςᵢ[δᵢ]πᵢ}: a **crossing term with coefficient 1 − ωWᵢ ≥ 1 − β** plus an **alignment term ≥ 0 in the proxy** | PROVED (fixed scale); learned scale adds a covariance with ω (SKETCH) |
| 3 | For β ≤ 1 this gives the sign of E₀κ + 3 once the alignment term is shown nonnegative. For β > 1 the comparison "Cov against crossing using Wᵢ ≤ t/pᵢ(0)" **cannot** give the sign by itself: it needs a *lower* bound on over-fitting (alignment ≈ β²Σs_r² in the proxy) against an upper bound on the crossing term, both with sharp constants | PROVED as a reduction; the needed bounds are open |
| 4 | **Lemma 1′** (remainder without sup-norm localization): on Theorem H's Huber body, for every ℓ ≥ polylog, R(δ) ≥ (f/2)[q_s(δ) − η·𝐡(δ)] − η(f/4)k for truncation level s ≲ ℓ^{−1/18}/log n | PROVED in outline (§2); constants not tracked |
| 5 | **Reduction.** If, in addition, the energy above amplitude s, E_s(δ) := Σᵢ(δᵢ² − s²)₊, is ≤ ηk outside a set of evidence e^{−Ck}, then Theorem LO's assembly applies at ℓ wherever its mixture sandwich holds | PROVED given 4 (§3) |
| 6 | **Two precise obstructions** to finishing by the evidence route: (O1) above amplitude s the margin cannot be credited uniformly over the Huber body, so a posterior (not body) bound on the energy above s is needed; (O2) the Gaussian-mixture sandwich needs k² ≪ n, i.e. ℓ ≫ n^{3/2}. Below n^{3/2} the Laplace prior does not homogenize and the constant 6 has no justification | (O1) exponent computation plus two PROVED facts; (O2) SKETCH |

**Bottom line for the plan.** The range splits in two. On [n^{3/2+}, n^{99/43}] the LO proof has a visible extension with two missing lemmas (§4). On [ℓ₀, n^{3/2}] nothing in hand applies, not even the heuristic; the fallback (the sign as a named assumption, supported by κ̂ data) is the right status there.

---

## 1. The identity route (Astra §2 + Fable B's reduction)

### 1.1 An exact pointwise identity — PROVED

Fix the scale (ω constant) and a data vector. Write X := δᵢ under the posterior at (ℓ, y), μᵢ := [δᵢ], z := Zᵢ, ςᵢ := +1 if z ≥ 0 and −1 if z < 0, Cᵢ := {δᵢ > z} if z ≥ 0 and {δᵢ ≤ z} if z < 0 (the fit has **crossed** the data point, moving away from the truth), πᵢ := [1_{Cᵢ}]. Recall gᵢ = 1{δᵢ > Zᵢ} − τ and R′ᵢ = |δᵢ|·1{Zᵢ strictly between 0 and δᵢ} = ςᵢδᵢ1_{Cᵢ} (a.s.).

**Identity.** Cov_{ℓ,y}(δᵢ, gᵢ) = [R′ᵢ] − ςᵢ·μᵢ·πᵢ.

*Proof.* For z ≥ 0: Cov(X, 1{X > z}) = [X·1{X > z}] − [X]·[1{X > z}] = [R′ᵢ] − μᵢπᵢ. For z < 0: Cov(X, 1{X > z}) = −Cov(X, 1{X ≤ z}) = −[X·1{X ≤ z}] + μᵢπᵢ = [R′ᵢ] + μᵢπᵢ. The constant −τ does not contribute. ∎

**Consequence.** With Astra's weight Wᵢ = Wᵢ(Zᵢ) ∈ (0, t/pᵢ(0)] and her identity E_{Zᵢ}{ψᵢ[ωδᵢ]} = E_{Zᵢ}{Wᵢ·Cov(ωδᵢ, ωgᵢ)}, for a quadratic truth:

  **E₀κ(ℓ) + 3 = Σᵢ E₀{ ω[R′ᵢ]·(1 − ωWᵢ(Zᵢ)) + ω²·Wᵢ(Zᵢ)·ςᵢμᵢπᵢ }.**  (1)

- First term (**crossing**): [R′ᵢ] ≥ 0, and ωWᵢ ≤ ωt/pᵢ(0) = βᵢ. Its coefficient is ≥ 1 − βᵢ.
- Second term (**alignment**): ςᵢμᵢπᵢ is positive when the posterior mean at i has moved toward the data point (same sign as Zᵢ) and the posterior has mass beyond it.

*Learned scale (SKETCH).* With ω random, Cov(ωδᵢ, ωgᵢ) = [ω²R′ᵢ] − ςᵢ[ωδᵢ][ω1_{Cᵢ}] − (τ or τ − 1)·Cov(ωδᵢ, ω); the last term is of relative order n^{−1/2} because ω | θ, y is Gamma(n + a) over b + Q.

### 1.2 What (1) does and does not give

**β ≤ 1.** The crossing coefficient is ≥ 0. Then E₀κ + 3 ≥ Σω²E₀{Wᵢςᵢμᵢπᵢ}, and the sign follows if the alignment term is ≥ 0. I could not prove that pointwise (μᵢ can have the sign opposite to Zᵢ when neighbours dominate), but this is the (EM) range, where the lower tail is already a theorem (`FABLE_A_Arule_lowertail.md` §4).

**β > 1 (every paper cell).** The crossing coefficient is negative for Zᵢ near 0, which is where [R′ᵢ] lives. So (1) reads

  E₀κ + 3 ≥ ω²Σᵢ E₀{Wᵢςᵢμᵢπᵢ} − (β − 1)·ωΣᵢ E₀[R′ᵢ],

and the comparison suggested in the brief (bound the covariance by the crossing term through Wᵢ ≤ t/pᵢ(0)) gives **−(β − 1)·crossing**, the wrong sign. The sign must come from the alignment term.

**Proxy check (consistency, CONJECTURE-level).** In the Gaussian proxy with s_r = ρ_r/(1 + ρ_r): ωΣ[R′ᵢ] ≈ Σs_r + βΣs_r² (posterior variance plus squared posterior mean), ΣWᵢCov ≈ βΣs_r (β times the degrees of freedom), so the alignment term is ≈ β²Σs_r² and (1) returns Σs_r − βΣs_r(1 − s_r) = (π/18)(6 − β)k_eff, Fable B's value. So in the proxy:

  crossing ≈ (π/3 + 5πβ/18)·k_eff,  alignment ≈ (5π/18)·β²·k_eff,  κ + 3 ≈ (1 − β)·crossing + alignment.

**Precise statement of what this route needs.** A **lower** bound on the alignment term (how much the posterior mean follows the signs of the noise, i.e. a lower bound on over-fitting) of size ≥ (β − 1)·crossing + 3 + margin, together with an **upper** bound on the crossing term (the posterior second moment at the crossing scale), uniformly in ℓ. Both are two-sided posterior moment bounds with sharp constants: at β = 1.57 the proxy values per unit of k_eff are alignment ≈ 2.15 against (β − 1)·crossing ≈ 1.38, but neither side has even a non-sharp bound below C1's window. Theorem H bounds the Huber loss from above only; nothing bounds over-fitting from below. This is Astra's "posterior weight on score-aligned perturbations", now isolated as the single quantity Σω²Wᵢςᵢμᵢπᵢ.

**Fluctuations.** (1) is a population identity. A realized sign needs κ − E₀κ = o(k), which is a concentration statement for a posterior functional (not for a sum of independent terms). Not addressed.

---

## 2. The evidence route: Lemma 1′, the remainder without sup-norm localization

Lemma 1 of the three-lemmas note used ‖δ‖∞ ≤ s on the body. That can be replaced by truncation, because the remainder is a monotone hinge.

**Notation.** Rᵢ(x) = (ςᵢ(x − Zᵢ))₊ (a hinge at Zᵢ; this is C2 §3.1's formula). q_s(δ) := Σᵢmin(δᵢ², s²). 𝐡, K_H, r, T₀ as in Theorem H at level ℓ; k = nℓ^{−1/3}.

**Lemma 1′.** Let ℓ be in Theorem H's range, 0 < s ≤ L, η ∈ (0, 1), K ≥ 1, and assume the analogue of condition (S): C·K·√(f̄·s·log n)·ℓ^{1/36} + C·K·log n·ℓ^{−1/9} ≤ ηf. Then with probability ≥ 1 − C/K, for all δ ∈ K_H:

  **R(δ) ≥ (f/2)·[q_s(δ) − η·𝐡(δ)] − η(f/4)·k.**

The condition holds for s ≤ c(η/K)²·ℓ^{−1/18}/log n, for **every** ℓ ≥ polylog. No sup-norm bound on the body is used.

*Proof (outline; each step is a line of an audited proof).*
1. *Monotonicity.* |x| ↦ Rᵢ(x) is nondecreasing on each side of 0, so Rᵢ(δᵢ) ≥ Rᵢ(clip_s(δᵢ)), clip_s(x) := max(−s, min(s, x)). Hence R(δ) ≥ R^s(δ) := ΣᵢRᵢ(clip_sδᵢ).
2. *Mean.* E Rᵢ(clip_sx) = mᵢ(clip_sx) ≥ (f/2)min(x², s²) (C2 §3.2, s ≤ L). So M^s(δ) := E R^s(δ) ≥ (f/2)q_s(δ).
3. *Active set.* x ↦ Rᵢ(clip_sx) is 1-Lipschitz, vanishes at 0, and is identically 0 unless |Zᵢ| < s. Symmetrization and contraction on the active set (audit finding 5) give E sup_K|R^s − M^s| ≤ 4·E sup_K⟨ξ, δ⟩, ξᵢ = εᵢ1{|Zᵢ| < s}, E ξᵢ² ≤ 2f̄s, for any symmetric convex K.
4. *Width of Huber shells with small-variance multipliers.* For K = {𝐡 ≤ nx, TV ≤ T₀}: Lemma WH's three terms with ξ in place of ε. The ℓ₂ head gains √(2f̄s) through E‖P_Hξ‖₂ ≤ √(2f̄s·dim); the ℓ₁ head uses Bernstein for ‖P_Hξ‖∞ (variance ≤ 2f̄s·9/h, summands ≤ 9/h); the tail is as in Lemma 1 step 3. Result: ≤ C√(f̄s·log n)·n·x^{5/12}(T/ℓ)^{1/6} + C·log n·n·x^{1/3}(T/ℓ)^{1/3}.
5. *Shells in 𝐡 and Markov,* as in Lemma 1 steps 4–6, with M ≥ (f/2)·nx replaced by the shell's own Huber level: on {𝐡(δ) ∈ (x_{a−1}n, x_an]}, |R^s − M^s| ≤ η(f/2)𝐡(δ); below the first shell, ≤ η(f/4)k. ∎

**Reading.** q_s − η𝐡 is the quadratic margin on the coordinates below amplitude s, minus a fraction of the total Huber loss. The lemma is as good as Lemma 1 exactly when q_s(δ) ≈ 2𝐡(δ), i.e. when δ carries no energy above amplitude s. The deficit is the content of obstruction (O1).

---

## 3. Reduction, and where the LO assembly can go

**Energy above amplitude s.** E_s(δ) := Σᵢ(δᵢ² − s²)₊. For ‖δ‖∞ ≤ L: ‖δ‖₂² = q_s(δ) + E_s(δ) and 𝐡(δ) = ‖δ‖₂²/2.

**Proposition (reduction) — PROVED given Lemma 1′.** On Lemma 1′'s event, for δ ∈ K_H with ‖δ‖∞ ≤ L and E_s(δ) ≤ ηk:

  R(δ) ≥ (1 − η)(f/2)‖δ‖₂² − (3/4)η·f·k.

So with 𝒢 := K_H ∩ {‖δ‖∞ ≤ L, E_s ≤ ηk},

  Z̃_ω(ℓ) ≤ e^{Cηk}·𝒵_ω(ℓ) + N_ℓ(K_Hᶜ) + N_ℓ(K_H ∖ 𝒢),

where 𝒵 is the Gaussian-likelihood integral of the three-lemmas note §4.1. The first term is bounded by Theorem LO's §4.2–4.6 wherever its mixture sandwich holds; the second by Theorem H's cones. **Everything is reduced to N_ℓ(K_H ∖ 𝒢) ≤ e^{−ck}: the evidence carried by fits with energy above amplitude s.**

**Where the first term is available (O2) — SKETCH.** The sandwich of Lemma 2b needs a block length w with (a) law of large numbers for the mixing variances at the scale of the exponent, w ≳ k^{6/5}/η², and (b) negligible perturbation, which with the crude bound tr 𝒟 ≤ (4/3)w²n⁴ gave ℓ ≥ n^{99/43}. Measuring the perturbation through the resolvent instead (the columns' block variation is carried by modes r ≲ k, where it is ≈ (rw/n)² per mode) would give the condition w·k ≲ √η·n·k^{−3/5}, i.e. k^{14/5} ≲ n, **ℓ ≳ n^{27/14}** (≈ n^{1.93}). That needs smoothness of the eigenvectors of DDᵀ, which is not in hand. No refinement can pass **k² ≈ n, i.e. ℓ ≈ n^{3/2}**: there a mode's wavelength n/k is no longer than the block length needed for the variances to average, so the Laplace prior is not locally Gaussian at the scale of the fit.

---

## 4. The precise obstructions

**(O1) Amplitude.** Lemma 1′ credits the quadratic margin only below amplitude s ≍ ℓ^{−1/18}/log n. Above it the remainder has no variance gain (the active fraction 2f̄·amplitude is not small), so the uniform deviation of R − M over a Huber shell is of the order of the score width, n·x^{5/12}ℓ^{−1/6}, which exceeds k at the critical shell by ℓ^{1/36} (the same loss as C1's loss B). The true margin above amplitude s is large, but it cannot be credited **uniformly over the body**. K_H does contain vectors with E_s ≫ k (for s ≤ r/√2 the constant vector δ ≡ 2s has TV = 0, 𝐡 = 2ns², E_s = 3ns² ≫ k), and on score-aligned ones Astra's §1 shows that the integrand can be favourable by c₁k pointwise. So N_ℓ(K_H ∖ 𝒢) cannot be bounded by "supremum of the likelihood × prior mass": combined with Lemma RSB (`FABLE_A_Arule_lowertail.md` §3) that product is small only on shells x ≲ ℓ^{−14/37}, below the critical x₀ = ℓ^{−1/3}. What is needed is a **posterior** statement at fixed (ω, ℓ): the fit has energy ≤ ηk above amplitude s, except on a set of evidence e^{−ck}. This is a form of sup-norm localization in posterior probability at ℓ ≪ n^{21/11}, which C1 cannot give. (Status: the two displayed facts are PROVED; "cannot be credited uniformly" is the exponent computation just given.)

**(O2) Homogenization — SKETCH.** See §3. Between n^{27/14} and n^{99/43} it is a technical window; between n^{3/2} and n^{27/14} it needs a finer sandwich; below n^{3/2} the Gaussian-mixture route stops for a structural reason.

**(O3) Below n^{3/2} — CONJECTURE.** With k ≥ √n the Laplace prior acts through individual innovations, not through local averages. The constant in "gain against Occam cost" is then not the Gaussian one, and I do not know its value or sign condition. The β < 6 criterion should not be quoted for this range. This is consistent with Astra's §3 (no monotonicity principle) and with her remark that at bounded tuning the obstruction is extensive.

---

## 5. Recommendation

1. **Status of G4 in the plan:** keep the sign on [ℓ₀, n^{99/43}] as a named assumption, supported by κ̂ data. Split it in the write-up into [ℓ₀, n^{3/2}] (no theory, no heuristic constant) and [n^{3/2}, n^{99/43}] (extension of LO plausible).
2. **If one more lemma is attempted, make it posterior sup-norm at fixed tuning:** for ℓ ≥ n^{3/2+}, the fixed-(ω, ℓ) posterior puts all but e^{−ck} of its evidence on E_s ≤ ηk with s ≍ ℓ^{−1/18}/log n. With Lemma 1′ and the resolvent form of Lemma 2b this would extend Theorem LO to ℓ ≳ n^{27/14}. Main risk: it is a new kind of statement here (a local, coordinate-wise posterior bound), and I have not found its proof.
3. **The identity route (1)** is clean but needs a lower bound on over-fitting; I see no tool for that. Its value is diagnostic: the three terms crossing, alignment and κ can be estimated separately from fixed-λ chains (crossing = Σ[ωR′ᵢ], alignment = Σω²Wᵢςᵢμᵢπᵢ with the known Gaussian Wᵢ), which would test the proxy constants (π/3 + 5πβ/18 and 5πβ²/18 per unit of k_eff) directly, including below n^{3/2}. UNTESTED; cost: the same fixed-λ chains as the κ̂ run.

## 6. Not verified

- Lemma 1′: steps 1–3 are exact; the width in step 4 and the shell bookkeeping in step 5 are stated by analogy with Lemma 1 and Lemma WH, without recomputing constants.
- The exponent 27/14 in (O2) is an exponent-level estimate assuming smooth eigenvectors of DDᵀ.
- (O1): the exponent −14/37 for the "supremum × prior mass" product is a one-line balance of the score width against Lemma RSB's exponent, not a written proof.
- §1.2's proxy values are hand computations (∫dx/(1+x⁶) = π/3, ∫dx/(1+x⁶)² = 5π/18).
- The learned-scale version of (1) is a sketch.

---

## Theory response (2026-11-23)

**Status: gap 4 is OPEN. This note gives partial results and is UNAUDITED.**

**Reading:**
1. **The covariance route.** The decomposition E₀κ + 3 = Σ E₀{ω[R′ᵢ](1 − ωWᵢ) + ω²Wᵢςᵢ[δᵢ]πᵢ} makes the obstruction quantitative. For β > 1 the crossing term enters with the wrong sign, so the sign must come from the alignment, i.e. over-fitting, term. There is no lower-bound tool for that term.
2. **The evidence route.** Truncation replaces sup-norm localization. The missing lemma is a *posterior* bound on high-amplitude energy.
3. **Homogenization limit.** Below λ ≈ n^{3/2}, β < 6 has no justification, even heuristically.

**For the plan.** Link L4 is split:
- **L4a:** [ℓ₀, n^{3/2}]. No theory; named assumption.
- **L4b:** [n^{3/2}, n^{99/43}]. LO extension; one new lemma.

**Diagnostic (UNTESTED; not requested tonight per HQ):** estimate the crossing, alignment and κ terms from fixed-λ chains, including below n^{3/2}.
