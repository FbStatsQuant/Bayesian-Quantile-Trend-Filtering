# What the Lean statements say

This page reads the formal statements in plain mathematics, so you can check them against the paper without reading Lean. The statements live in [`BQTF/Spec.lean`](../BQTF/Spec.lean).

**Scope:** Theorem 1 (`thm:main`) and Theorem 2 (`thm:joint`), both fully proved (2026-11-26). The Theorem 1 statement passed the Astra fidelity audit on 2026-11-25 (`notes/audits/spec_thm1_astra_r1.md`, PASS WITH FIXES; the four documentation fixes are applied). The Theorem 2 statements (§3, `JointStatement`, `JointStatementScale`) passed the Astra audit on 2026-11-25 (`notes/reviews/Thm2Skeleton_Astra_2026-11-25.md`, STATEMENTS APPROVED; its documentation fixes are applied).

The source is the paper at commit e36c20d or later:
- `paper/sections/theory.tex`, Section "Posterior contraction";
- `paper/sections/appendix_theory.tex`.

## 1. Setting

The trend is a vector in ℝⁿ, represented as `Fin n → ℝ`. Lean indexes from 0 to n−1; the paper indexes from 1 to n. The order is k ≥ 1, and r = k + 1.

| Lean | Meaning |
|---|---|
| `checkLoss τ u` | ρ_τ(u) = u (τ − 1{u < 0}) |
| `diffOp r n θ` | D^{(r)}θ ∈ ℝ^{n−r}, (D^{(r)}θ)_i = Σ_{l=0}^{r} (−1)^{r−l} C(r,l) θ_{i+l}. The paper's D is D^{(k+1)}, with m = n − k − 1 rows. |
| `l1norm v` | ‖v‖₁ = Σ \|v_i\| |
| `TV k n θ` | TV(θ) = n^k ‖D^{(k+1)}θ‖₁ |
| `lossΔ v` | Δ²_n(v) = n⁻¹ Σ_i min{\|v_i\|, v_i²} |
| `postWeight τ σ λ k n y θ` | exp{−σ⁻¹ Σ_i ρ_τ(y_i − θ_i) − λ‖D^{(k+1)}θ‖₁} |
| `posterior τ σ λ k n y` | Π_λ(B \| y) = ∫_B w dθ / ∫_{ℝⁿ} w dθ, with w = `postWeight` and dθ Lebesgue measure on ℝⁿ |
| `distFn μ t` | F(t) = μ(−∞, t] |
| `IsQuantile μ τ q` | μ(−∞, q) ≤ τ ≤ μ(−∞, q], i.e. q is a τ-quantile of μ |
| `lamSeq c k n` | λ = c n^{(2k+1)/2} |
| `rate k n` | n^{−(2k+1)/(2k+2)} |
| `massRate k n` | n^{−1/(2k+2)} |
| `farSet k θ* M` | {θ : Δ²_n(θ − θ*) > M n^{−(2k+1)/(2k+2)}} |

**The posterior.** It is eq. (post-fixed) of the paper. The paper writes it at σ = 1; at scale σ the check-loss sum is divided by σ. This is the product of:
- the asymmetric Laplace working likelihood, eq. (ald): f(u) = τ(1−τ)σ⁻¹ exp{−ρ_τ(u)/σ}, one factor per observation;
- the prior, eq. (prior_theta): p(θ | λ) ∝ λ^m exp{−λ‖Dθ‖₁}, which does not involve σ.

The constant factors cancel in the ratio. The data are **not** assumed to follow the asymmetric Laplace law: it is a working likelihood only.

**The data.** y₁, …, y_n are independent, and y_i has an arbitrary probability law μ_i on ℝ. The law of y is the product ⊗_i μ_i (`Measure.pi μ`). E_{θ*} is the integral against this product.

**Assumptions** (`DataHyp k n τ μ θ* L f̲ f̄ V̄`):
- each μ_i is a probability measure;
- each θ*_i is a τ-quantile of μ_i;
- **Assumption A**: |F_i(θ*_i + t) − F_i(θ*_i)| ≥ f̲ |t| for every i and every |t| ≤ L;
- **Assumption B**: |F_i(θ*_i + t) − F_i(θ*_i)| ≤ f̄ |t| for every i and every |t| ≤ L;
- the signal bound V* = TV(θ*) ≤ V̄.

The paper states A and B with a vector δ, ‖δ‖_∞ ≤ L, "for all i". The condition at coordinate i involves only δ_i, so the two forms are equivalent.

Under A and B together, the τ-quantile is unique:
- B excludes an atom at θ*_i, so F_i(θ*_i) = τ.
- A then gives F_i(θ*_i − s) < τ < F_i(θ*_i + s) for 0 < s ≤ L.
- By monotonicity, every other point fails to be a τ-quantile.

So "θ*_i is a τ-quantile" is the same as the paper's "θ*_i denotes the τ-quantile". A alone would not be enough: an atom at θ*_i can leave a whole interval of quantiles.

## 2. Theorem 1

**`MainStatement`** (the paper's Theorem `thm:main`, at σ = 1).

Take an order k ≥ 1 and constants c > 0, L > 0, f̲ > 0, f̄ and V̄. Then there are constants M > 0, C > 0 and n₀ such that the following holds. Take:
- any n ≥ n₀,
- any level τ ∈ (0, 1),
- any laws μ₁, …, μ_n and any θ* satisfying the assumptions above with (L, f̲, f̄, V̄),

and the posterior with σ = 1 and λ = c n^{(2k+1)/2}. Then:

1. y ↦ Π_λ(Δ²_n(θ − θ*) > M n^{−(2k+1)/(2k+2)} | y) is measurable;
2. E_{θ*} Π_λ(θ : Δ²_n(θ − θ*) > M n^{−(2k+1)/(2k+2)} | y) ≤ C n^{−1/(2k+2)}.

**`MainStatementScale`** is the same statement with any fixed σ = σ₀ > 0. The constants may then also depend on σ₀. This is the paper's last sentence of the theorem.

**How it reads the paper:**
- **"Constants depending only on c, k, L, f̲, f̄, V̄."** M, C and n₀ are chosen after these six constants and before everything else.
- **"Uniform over all laws."** M, C and n₀ are chosen before n, the law and θ*.
- **τ.** The paper's list of dependencies does not include τ, so τ is also chosen after the constants.
- **f̄ and V̄** range over all reals. For n ≥ 1 the hypotheses force f̄ ≥ f̲ > 0 (apply A and B at one coordinate), and they always force V̄ ≥ 0. So no extra restriction is needed: an infeasible choice only gives an empty class.

## 3. Theorem 2

Source: `thm:joint` (`paper/sections/theory.tex`, eq. `joint-fixed`), with 𝒞 from eq. `joint_order` (`paper/sections/methodology.tex`). Lean indexes levels from 0 to J−1; the paper indexes them from 1 to J.

| Lean | Meaning |
|---|---|
| `Θ : Fin J → Fin n → ℝ` | a joint trend; `Θ j = θ_j` and `Θ j i = θ_{ij}` |
| `orderSet J n` | 𝒞 = {Θ : θ_{i1} ≤ ⋯ ≤ θ_{iJ} for every i} (weak inequalities, as in eq. `joint_order`) |
| `jointWeight τ σ λ k n y Θ` | ∏_j w_j(θ_j), with w_j = `postWeight` at (τ_j, σ_j, λ_j) |
| `jointPosterior τ σ λ k n y` | Π_𝒞(B \| y) = ∫_{B∩𝒞} ∏_j w_j dΘ / ∫_𝒞 ∏_j w_j dΘ (eq. `joint-fixed`, normalizers cancelled; D5) |
| `LevelGrid J τ gmin` | every τ_j ∈ (0,1), τ strictly increasing, and τ_{j+1} − τ_j ≥ gmin for every consecutive pair (D6) |
| `jointFarSet k θ* M` | U_M = {Θ : ∃ j, Δ²_n(θ_j − θ*_j) > M n^{−(2k+1)/(2k+2)}} (D9) |

The data law ⊗_i μ_i and the vector y are shared by all levels. Each level j has its own target θ*_j, the τ_j-quantile curve.

**`JointStatement`** (the paper's Theorem `thm:joint`, at σ_1 = ⋯ = σ_J = 1).

Take:
- an order k ≥ 1;
- a number of levels J ∈ ℕ (D7);
- constants c_0, …, c_{J−1} > 0, L > 0, f̲ > 0, f̄ and V̄;
- a spacing lower bound gmin > 0 (D6).

Then there are constants M > 0, C > 0 and n₀ > 0 such that the following holds. Take:
- any n ≥ n₀;
- any levels τ_0 < ⋯ < τ_{J−1} in (0, 1) whose consecutive spacings are all ≥ gmin;
- any laws μ₁, …, μ_n and any targets θ*_0, …, θ*_{J−1} such that `DataHyp k n τ_j μ θ*_j L f̲ f̄ V̄` holds at every level j (A and B with the same constants, θ*_j a τ_j-quantile, V*_j ≤ V̄).

Let the joint posterior have σ_j = 1 and λ_j = c_j n^{(2k+1)/2}. Then:
1. y ↦ Π_𝒞(U_M | y) is measurable (D8);
2. E_{θ*} Π_𝒞(U_M | y) ≤ C n^{−1/(2k+2)}, where U_M = {Θ : ∃ j, Δ²_n(θ_j − θ*_j) > M n^{−(2k+1)/(2k+2)}}. For J ≥ 1 this is E_{θ*} Π_𝒞(Θ : max_j Δ²_n(θ_j − θ*_j) > M n^{−(2k+1)/(2k+2)} | y) ≤ C n^{−1/(2k+2)}, the paper's display (D9).

**`JointStatementScale`** is the same statement with any fixed scales σ_j = σ_{0j} > 0. The scales σ₀ : Fin J → ℝ are chosen together with c, before the constants, so the constants may also depend on σ_{00}, …, σ_{0,J−1}. This is the last sentence of the theorem.

**How it reads the paper:**
- **"Constants depending only on c_1, …, c_J, k, L, f̲, f̄, V̄, J and the smallest spacing."** M, C and n₀ are chosen after these constants and gmin, and before everything else.
- **τ** is chosen after the constants (Theory, 2026-11-25, PLAN §5.5 item 4). τ enters only through the spacing. The proof can choose M and C independently of the spacing, so that it enters only n₀. The propositions allow all three witnesses to depend on gmin.
- **"Uniform over all laws."** M, C and n₀ are chosen before n, the law and θ*.
- **f̄ and V̄** range over all reals, as in Theorem 1.

## 4. Differences from the paper

These are all the differences, each with its direction. "Safe" means that the Lean statement implies the paper's.

| # | Difference | Direction |
|---|---|---|
| D1 | A and B are stated coordinatewise, not with δ ∈ ℝⁿ. | Equivalent. |
| D2 | θ* is any τ-quantile, not "the" τ-quantile. | Equivalent under A and B (uniqueness; see Section 1). |
| D3 | Measurability of y ↦ Π(B \| y) is part of the conclusion. | Safe. Without it, Mathlib's `∫⁻` would only bound a lower integral. |
| D4 | The posterior is written with its normalizing integral Z in `ℝ≥0∞`. If Z were 0 or ∞, the totalized definition would give the zero measure. Properness, 0 < Z < ∞, is proved as a lemma (`posterior_isProbability`, `BQTF/Coord.lean`), not assumed. It holds for every n ≥ 1, τ ∈ (0,1), σ > 0 and λ ≥ 0: the weight is positive and continuous, and it is at most ∏_i exp(−a\|y_i − θ_i\|) with a = min(τ,1−τ)/σ. | Equivalent (the lemma is proved). |
| D5 | (Joint posterior.) The per-level normalizers are cancelled in the definition. | Equivalent when each normalizer is in (0, ∞). By D4, this holds for n ≥ 1 when every level has τ_j ∈ (0,1), σ_j > 0 and λ_j ≥ 0. Stated as `jointPosterior_eq_cond` in `BQTF/Joint/Product.lean`, as Π_𝒞(B \| y) = Π^⊗(B ∩ 𝒞 \| y)/Π^⊗(𝒞 \| y) for measurable B and n ≥ 1. Proved (J1, Neon-A; reviewed 2026-11-26). |
| D6 | (Theorem 2.) "Constants depending on the smallest spacing" is encoded as a lower bound gmin > 0 on the consecutive spacings, quantified before ∃ M C n₀. τ is quantified after them. `LevelGrid` also lists "τ strictly increasing", which the spacing bound already implies. | Safe. Apply the statement with gmin = min_j(τ_{j+1} − τ_j). |
| D7 | (Theorem 2.) J ranges over all of ℕ. J = 0 is vacuous (U_M = ∅). For J = 1 the spacing condition is empty and 𝒞 is everything, so the statement is Theorem 1. | Safe. It contains the paper's cases J ≥ 2. |
| D8 | (Theorem 2.) Measurability of y ↦ Π_𝒞(U_M \| y) is part of the conclusion, as in D3. | Safe. |
| D9 | (Theorem 2.) The event "max_j Δ²_n(θ_j − θ*_j) > M n^{−(2k+1)/(2k+2)}" is written "∃ j, Δ²_n(θ_j − θ*_j) > M n^{−(2k+1)/(2k+2)}". | Equivalent for J ≥ 1. For J = 0 the max is undefined and the Lean event is empty (D7). |
| D10 | (Intermediate lemmas.) The constants of Lemma evid and Prop. prior (C_E, C_pr) are existential in `denominator` and `prior_mass`, not the paper's explicit formulas. The proof sets C_E = (5/4)C₁ + 1 + C_pr. The quad-shift coefficient is H = (1 + K_max/2)/(1 − e^{−2}), not the paper's eventual c_K ≤ 2. | Safe for thm:main and thm:joint, whose constants are existential. The intermediate lemmas are weaker than the paper's explicit versions; the paper's explicit constants are correct (Denominator review 2026-11-26). |
| D11 | (Theorem 2.) Lemma gap's Lean counterpart is the pairwise `quantile_gap`, which needs only B. `level_gap` is the grid wrapper used under the joint hypotheses, which also assume A and `DataHyp`. With gmin equal to the minimum spacing, it gives the paper's g₀ exactly. | Safe. `quantile_gap` implies Lemma gap (Gap review 2026-11-26). |
| D12 | (Theorem 2.) Lemma sup (`supNorm_concentration`) concludes with an existential good event Ω, not the named Ω_E ∩ Ω_G. The proof exhibits Ω_E ∩ Ω_G. This was approved at the statement gate. | Weaker than the paper's lemma, but sufficient for thm:joint, which `joint_theorem` proves from it (J4/J5 review 2026-11-26). |
