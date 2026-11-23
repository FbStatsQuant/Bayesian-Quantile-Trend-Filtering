# E-06: notes for `paper_section.tex` (held until Theory's Tuesday confirmation, per HQ)

## Decisions
- **Main text:** the rough radius q̂ₙ^⊥.
- **Supplement:** the full Δ²ₙ radius.
- Accepted provisionally by HQ on 2026-11-23 and agreed by Theory the same day.

## Wording from Theory, 2026-11-23

**Null-space sentence:**
> The theorem bounds the full Δ²ₙ. Its three unpenalised (quadratic) directions add a parametric term of order 3/(nκ), which is comparable to the n^{−5/6} rough term at n ≤ 32k and pulls the fitted slope toward −1. We therefore report the radius of the rough component P^⊥(θ − θ\*) in the main text, and the full radius in Supplement X; both are consistent with the theory.

**Pre-asymptotic sentence** (fallback and Padilla slopes 0.02–0.06 steeper):
- The spread's local exponent in log λ at these n is −0.34 to −0.37 (E-02 P1), against −1/3 asymptotically.
- So the finite-n slope along λ ∝ nᵃ is about −0.35a to −0.37a:
  - Padilla: −0.75 to −0.79 (observed −0.74 to −0.77);
  - fallback: −0.79 to −0.83 (observed −0.73 to −0.80).
- This is pre-asymptotic curvature, not a different rate.

**σ₀ arm sentence:**
- The σ₀ arm matches 1.1σ̄ (median slope difference −0.008).
- This agrees with the sandwich test: the rough part shows no variance inflation below σ̄.
- It is empirical support beyond the proved range, not a theorem.

## Report notes (HQ)
- **R̂:**
  - The supplement's R̂ column is the maximum single-chain split-R̂ over the 120 fits of a config.
  - Its null reference, from stationary AR(1) chains with ESS 400, is 1.013–1.026. Observed: 1.01–1.03.
- **Calibration cap:** 3 combos were capped (pq at τ = 0.9: Gaussian, Laplace, t₃), marked †. The uncapped MAP-risk curves are in `tables/e06_calibration_curves.csv`.
- **Compute:**
  - Main: 151.5 core-h (guard 150).
  - Calibration: 2 × ≈ 2 core-h.
  - Cancelled first launch: ≈ 1.2 core-h.
  - Reduced supp: guard 26 core-h.
