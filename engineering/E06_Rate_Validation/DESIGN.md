# E-06 Rate validation: design note

*Engineering, 2026-11-22. Requested by HQ for Felipe; HQ approved it the same day (main, then supp after the gate). This section showcases the theorems for the paper.*

## Target
The target is the theorem's own quantity: posterior contraction of θ in Δ²ₙ(θ − θ\*) around the true τ-quantile. The sampler is the exact banded Gibbs sampler (E-02/E-04, `exact_latents = TRUE`), with λ and σ fixed. Each fit runs 1000 burn-in sweeps and keeps 5000, thinned by 5. This is the E-02 setting, which E-04 judged fit.

## Factors
| factor | levels |
|---|---|
| λ schedule (Λ = λσ = Λ\*·(n/500)^a) | primary a = 5/2, i.e. n^{5/2}/V (pred. −5/6); fallback a = 9/4, i.e. (n³/V)^{3/4} (pred. −3/4); Padilla a = 15/7 (pred. −5/7) |
| calibration | Λ\* = argmin over Λ of the mean Δ²(MAP − θ\*) at n₀ = 500, over 10 seeds and a 49-point log grid from 1 to 1e6, per truth × noise × τ (the E-02 method). λ = Λ/σ, so the two σ arms share the MAP and differ only in posterior temperature |
| σ arm | **Abar**: σ = 1.1σ̄, with σ̄ = τ(1−τ)/f(q_τ), inside Theorem A. **S0**: σ = σ₀ = E ρ_τ(ε − q_τ), the paper's scale, which probes A⁺. Cauchy has no σ₀, so its S0 arm uses the Gaussian σ₀/σ̄ at the same τ (equal κ) |
| noise | Gaussian, Laplace, t₃, t₂, Cauchy. All are scaled to the same density at the median, f(0) = 0.798 (N(0, 0.5²)), so they differ only in their tails |
| τ | 0.5, 0.9 |
| truth | pq (C¹ piecewise quadratic, 3 kinks, finite V, the E-02 kinked truth) and sin. quad is skipped: V = 0 makes λ unbounded |
| n, seeds | 1k, 2k, …, 32k (6 sizes) × 20 seeds. A seed fixes the data across n-schedules and σ arms (paired) |

**σ₀/σ̄:**

| noise | τ = 0.5 | τ = 0.9 |
|---|---|---|
| Gaussian | 0.64 | 0.34 |
| Laplace | 1.00 | 0.29 |
| t₃ | 0.81 | 0.33 |
| t₂ | 1.00 | 0.36 |

So S0 lies outside Theorem A everywhere, except Laplace and t₂ at τ = ½, where it sits on the boundary.

## Measures per fit
- The posterior mean of Δ².
- **q̂ₙ**, the 95% posterior quantile of Δ² (the contraction radius).
- P(Δ² > M·εₙ² | y) for M ∈ {1, 2, 4}. Here εₙ² := (the seed-median q̂ at n = 1k) × (n/1k)^{pred}, so the prediction is that this probability stays small and does not grow with n.
- ‖·‖ₙ² versions (mean, q95) as a secondary measure.
- **Rough-part radius q̂ₙ^⊥** (added at Theory's request): the 95% quantile of Δ²ₙ(P^⊥(θ − θ\*)), with the quadratic null space projected out, and the centre's rough error.
  - Why: the null-space term is about 3/(nκ), against a rough spread of about 0.3n^{−5/6}, a ratio of roughly 10·n^{−1/6}. That is O(1) across 1k–32k, so the slope of the full-Δ² radius can be pulled toward −1.
  - The full Δ²ₙ is the theorem's quantity; the rough part gives the cleanest slope comparison. Both are reported.
- Also recorded: the MAP error, ESS(Δ²) and the timing.

Thinned Δ² and ‖·‖ₙ² traces (1000 draws each) are saved, so εₙ and M can be redefined later.

## Analysis
- Per config: the OLS slope of log(seed-median q̂ₙ) on log n, with a 95% CI from a paired bootstrap over seeds (B = 2000).
- Headline slopes use **c = 0**, i.e. a plain log–log slope, per Theory: the (log n)^c is a proof artefact, and E-02 found the spread ∝ λ^{−1/3} with no log.
- A c = 1/6 log-adjusted slope is a supplement sensitivity column; it shifts the slope by about 0.02.
- **Supplement diagnostics** (HQ): per config, min n·λ^{−1/3}, max w/n with w = (λ²/κ)^{1/6}, max bias²/risk (centre Δ² ÷ posterior-mean Δ²), max λ‖Dθ‖₁/m, min ESS(Δ²) and max split-R̂.
- **Gate for phase supp:** n·λ^{−1/3} ≥ 10, ESS ≥ 110 per 5000, R̂ ≤ 1.01, w/n ≤ 0.1, and λ‖Dθ‖₁/m ≤ 1.1.
- The same slopes for the posterior mean of Δ².

**Proof coverage** (Theory, 2026-11-22):
- **Gaussian and Laplace at 1.1σ̄:** Theorem B, whose proof is complete and advisor-checked. This holds at both oracle tunings and both τ.
- **t₃, t₂ and Cauchy:** Theorem A, which is pending L10, so these are conjectures.
- **σ₀ arm:** A⁺, not proved.
- **Padilla:** Corollary A2, an upper bound; that it is also the actual rate is conjectured.
- **Predicted slopes:** −5/6, −3/4 and −5/7 for q̂ₙ, unchanged by σ.

## Outputs (paper first)
- **Main text, figure:** log q̂ₙ against log n for pq, Gaussian, τ = ½, σ = 1.1σ̄. It shows the three schedules as seed-medians with bootstrap bands and dashed theory lines at slopes −5/6, −3/4 and −5/7. The figure is a vector PDF.
- **Main text, table** (Large Prior Table 2 style): slope [95% CI] of q̂ₙ (and a q̂ₙ^⊥ variant; the choice is made with HQ on seeing the data) for the primary schedule, with rows noise × τ (10) and columns pq/sin × Abar/S0, against the predicted −5/6.
- **Supplement:** every config × measure, and the P(Δ² > Mεₙ²) curves.
- **Section stub:** `paper_section.tex`, with a paragraph and the LaTeX for the table and figure. It includes the sentence that the σ₀ arm gives the same slopes, if the data show it. `paper/` is not edited.

**Reuse:** E-02 kink25 (pq, Gaussian, τ = ½, σ₀, a = 5/2) gave a risk slope of −0.811 against −0.833. It is cited as an independent replication. Its calibration (one sin-based Λ\*) and its noise generator differ, so its cells are not pooled.

## Compute (NOTS, 16-core array tasks)
- **Per-fit cost:** from E-02 timings at a = 5/2 (Gibbs plus MAP), the six sizes together take ≈ 307 s per config × seed, ≈ 1.7 core-h per config.
- **Phase main (launch on HQ's ≤ 150 rule):**
  - The configs: primary × {Abar, S0} × 5 noises × 2 τ × 2 truths (40); fallback × Abar × all (20); Padilla × Abar × τ = ½ (10). That is 70 configs, i.e. 8400 fits.
  - Cost: **≈ 120–130 core-h**, including calibration (≈ 3) and a 10% margin for the heavy-tail and τ = 0.9 MAP cost and load imbalance.
  - Wall time ≈ 2 h on 4 × 16 cores.
- **Phase supp (needs HQ OK):** fallback and Padilla at S0 (40), plus Padilla × Abar × τ = 0.9 (10). That is 50 configs, **≈ 85–95 core-h**.
- **Guard:** the first array task's per-fit time is checked against the estimate. If the projection exceeds 150, I hold the remaining array tasks and flag HQ.

## Timing and safety
- **Launch:** after lamxl (2857431) finishes.
- **Isolation:** the run directory is `runs/E06-ratevalid-<date>/` with its own code snapshot, so it is independent of the repo clone and of the E-03 rewrite and re-clone (2026-11-24 01:45Z).
- **Output size:** ≈ 140 MB of small .rds files, under the runs tree. Only tables, figures, scripts and the .tex are committed.
