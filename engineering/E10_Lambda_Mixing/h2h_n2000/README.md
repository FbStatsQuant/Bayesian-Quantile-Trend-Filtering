# E-10: n = 2000 side-by-side, old vs new λ move (preliminary, 2026-11-25)

**Samplers.**
- *old*: the current sampler, with the polynomial ASIS move.
- *new*: the spline-held ASIS move, with q cycled over {10, 20, 40}.

**Setup.**
- Data seed 1, Normal noise, order 2.
- Priors: λ ~ Gamma(1, 1e-5), σ ~ IG(0.1, 0.1).
- Two chains per sampler (seeds 1001 and 1002); 30k sweeps with 10k burn-in.
- Taken from the E-10 calibration chains on NOTS (run E10-lambdamix-20261125).

**Files.**
- `h2h_n2000.md` / `.csv`: every n = 2000 cell. Columns:
  - ESS and ESS/min for λ, σ and θ (median and min over coordinates);
  - split R-hat;
  - MSE, coverage, band width and minutes per chain.
- `h2h_n2000_{S_t050,S_t075,VS_t075,VS_t095}.png`: one page per cell. Panels:
  - λ trace (log scale) and σ trace;
  - θ traces at n/10, n/2 and 9n/10, with the truth;
  - ACF of λ;
  - histograms of λ and σ;
  - fit with 95% bands.
- `h2h_n2000_chain_difference.png` / `.csv`: posterior mean of chain 1 minus chain 2 over x, against the within-chain 95% half-width.

**Scripts.** `../e10_h2h_n2000.R` and `../e10_chaindiff_n2000.R`.

## Caveat: the n = 2000 S/VS bands are not reportable from either sampler

**New sampler.**
- λ mixes: split R-hat 1.00–1.04.
- θ does not mix where λ is huge (λ ≈ 5e5 in S, 5–7e4 in VS):
  - θ split R-hat median/max is 3.9/14.4 at S τ0.5;
  - the two chains differ by 1–3 band half-widths (median), up to 11.
- The disagreement is smooth and low-frequency (scale n/q and longer), spread over the whole domain. It is not tied to the bump in VS or to the edges.
- Given λ and σ, θ's posterior is log-concave, so it has one mode. Two chains at the same λ level that disagree on θ by several band widths therefore show slow θ mixing, not a posterior with several modes.
- The narrow bands (width 0.02–0.10) and the low coverage (0.18–0.68) are stuck-chain bands, not posterior bands.

**Old sampler.**
- λ has not converged: it is still rising at sweep 30k, and its split R-hat is 2.2–2.7.
- So its bands sit at a λ well below the posterior's, and its coverage (0.88–0.92) is not a posterior quantity either.

**Pending.**
- The δ and acceptance traces, and the PC MSE check across seeds: follow-up job `e10_extra.R`.
- The cross-initialisation runs.
