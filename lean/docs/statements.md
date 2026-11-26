# What the Lean statements say

This page reads the formal statements in plain mathematics, so you can check them against the paper without reading Lean. The statements live in [`BQTF/Spec.lean`](../BQTF/Spec.lean).

**Current scope:** Theorem 1 (`thm:main`). The statement passed the Astra fidelity audit on 2026-11-25 (`notes/audits/spec_thm1_astra_r1.md`, PASS WITH FIXES); the four documentation fixes are applied. The joint posterior is already defined in `Spec.lean`, but the statement of Theorem 2 (`thm:joint`) comes later.

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

## 3. Differences from the paper

These are the differences so far, each with its direction. "Safe" means that the Lean statement implies the paper's.

| # | Difference | Direction |
|---|---|---|
| D1 | A and B are stated coordinatewise, not with δ ∈ ℝⁿ. | Equivalent. |
| D2 | θ* is any τ-quantile, not "the" τ-quantile. | Equivalent under A and B (uniqueness; see Section 1). |
| D3 | Measurability of y ↦ Π(B \| y) is part of the conclusion. | Safe. Without it, Mathlib's `∫⁻` would only bound a lower integral. |
| D4 | The posterior is written with its normalizing integral Z in `ℝ≥0∞`. If Z were 0 or ∞, the totalized definition would give the zero measure. Properness, 0 < Z < ∞, is a lemma still to be proved (`posterior_isProbability`), not an assumption. It holds for every n ≥ 1, τ ∈ (0,1), σ > 0 and λ ≥ 0: the weight is positive and continuous, and it is at most ∏_i exp(−a\|y_i − θ_i\|) with a = min(τ,1−τ)/σ. | Equivalent once the lemma is proved. |
| D5 | (Joint posterior, for later.) The per-level normalizers are cancelled in the definition. | Equivalent when each normalizer is in (0, ∞). By D4, this holds for n ≥ 1 when every level has τ_j ∈ (0,1), σ_j > 0 and λ_j ≥ 0. To be stated as a lemma. |
