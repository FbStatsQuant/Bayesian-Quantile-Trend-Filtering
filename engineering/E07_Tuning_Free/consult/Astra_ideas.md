# Astra’s ranked E-07 designs

Start with **1** on S. Felipe’s doubled run improved all nine measured S cells, so a candidate must beat the extra sweeps its runtime could buy. On VS at 500 his chain already reaches the posterior. Designs 1 and 2 can reduce finite-run error there, but only design 3 changes the limiting estimate. All costs and predicted gains below are guesses.

## 1. Move λ with the fine-scale residual, integrating out the ALD augmentation during the move

Felipe’s ASIS scales the entire departure from a quadratic, including the sine wave itself. Instead hold a coarse curve fixed. For order two, precompute a thin orthonormal basis Q of quadratic splines on the observation grid with 15 equally spaced interior knots (equivalently, constrain third differences to zero except at those 15 indices). Let p = QQᵀθ, v = θ − p, h = n − rank(Q). Most difference rows of p vanish. Rescaling v can therefore change most absolute differences inversely with λ while barely moving fitted quantiles. Integrating out z also frees the move from the large conditional precisions at nearly zero residuals.

Keep the usual proximal θ move and conjugate λ draw. Replace the remaining hyperparameter updates, including ASIS, as follows. With η = log λ hold p and u = λv fixed. Propose t = η + N(0,0.25²), set x = p + exp(η−t)v, and accept with log ratio F(t) − F(η), where

    F(t) = (a₀ + m − h)t − exp(t)(b₀ + ‖Dx‖₁)
           − (aσ + n)log[bσ + Σᵢ ρτ(yᵢ − xᵢ)].

Use x = θ when evaluating F(η). The two Jacobians contribute +t for log λ and −ht for the scaled residual. The final term integrates the ALD scale against its IG prior. After acceptance **or rejection**, draw σ from IG(aσ+n, bσ+Σρτ) at the resulting curve, then z from its conditional at that σ before any augmented update. This composition preserves the paper posterior. Jointly apply the move level by level and reject x outside the current neighbour box. Cost guess 1.00–1.10×, one thin projection and two linear scans, no extra prox. **Confirm** if accepted squared log-λ displacement per second rises, S λ approaches the long-run reference from both starts, and S MSE improves. **Kill** if the added moves have negligible displacement or their larger jumps fail to improve log-λ ESS/s.

## 2. Spend a fixed eight ADMM iterations per proposal map

Use the existing increment-form banded solve, cold start, soft threshold and shared factorization in pmala_move. Set max_iter=8 and tol=0 for both post-warm-up maps. Keep the paper’s warm-start budget. Propose x from N(T₈(θ),δM⁻¹), evaluate the exact energy at x and θ, and use T₈(x) for the reverse Gaussian density. This MH kernel preserves the same conditional for any deterministic T₈. The earlier residual-stopping experiment tried to certify convergence. Here the question is how much drift accuracy acceptance actually needs. If eight iterations suffice, more complete θ–λ sweeps fit in the same seconds, directly exploiting the measured S run-length effect.

Guess 0.10–0.40× individually (16 inner iterations versus 300, with fixed costs). Jointly shorten only the unconstrained first stage of each box map, retain the interior-point fallback and outer feasibility rejection, and use the identical rule in reverse. Measure fallback frequency since it could erase the saving. **Confirm** if at least twice as many sweeps fit, both curve and λ ESS/s rise, and equal-time S MSE falls. **Kill** if a smaller adapted δ or frequent box fallback removes the ESS/s gain despite faster individual sweeps.

## 3. Allow occasional large differences at a learned global scale

VS has a narrow peak amid smoother regions. Give its large differences a lower penalty without reducing smoothing everywhere. This is a posterior variant. For each row independently set sᵢ = 1 with prior probability 0.95 and 1/8 otherwise. Use Dᵢθ | sᵢ,λ ∼ Laplace(rate λsᵢ), with the same polynomial null-space prior. These fixed mixture constants are pilot hypotheses. Given θ,λ, the odds for sᵢ=1/8 versus 1 are (0.05/0.95)exp[(7/8)λ|Dᵢθ|]/8. Sample labels using log odds, then λ ∼ Gamma(a₀+m,b₀+Σsᵢ|Dᵢθ|). In the subsequent proximal update use thresholds λsᵢ/ρ and the same weighted penalty in both target energies. Keep Felipe’s metric, which is fixed within this conditional MH move. His VS ASIS remains valid conditional on labels because λDθ stays fixed. Use these same row weights in both stages of the joint box solver, including the epigraph objective. Each block then preserves the stated mixture posterior restricted to order.

Guess 1.02–1.15× individually. **Confirm** if low-rate labels concentrate near the VS peak, peak-region squared error and whole-curve VS MSE fall, and S and tail cells pass the guardrails. **Kill** if labels follow isolated noise and worsen a cell above 1.25, or λ ESS/s falls. This design earns its place on converged VS accuracy.

## Paired decision within two core-hours

On one core cap screening at 3,600 seconds. Use two data seeds, n=500, S/Gaussian at τ=.5 and VS/Beta at .95. Give each of four arms (Felipe plus three candidates) 210 seconds per seed-cell, including warm-up, with the same data and matched chain seeds. Reuse the timed baseline for all comparisons. This costs 3,360 seconds. Record actual sweeps and k = achieved baseline sweeps / paper sweeps. Match discarded wall-time fractions (S 1/4, VS 1/3), initial states, b₀ and baseline ASIS settings. For exact candidate kernels freeze adaptation after burn-in and use stable, unclipped conditional z draws (at zero residual use the limiting gamma law). Record safeguard hits in Felipe’s published implementation.

Reserve 1,200 seconds for alternate-start paired runs on the leading S design and 2,400 seconds for the leading joint design versus Felipe on one VS/Beta dataset at the six published upper levels, equal seconds per arm. Require positive movement at every level and zero crossings in every retained draw. Report cellwise paired posterior-mean MSE ratios, log-λ and peak/interior θ ESS per elapsed second, split-chain drift and alternate-start R-hat when available. Advance only on a median ratio clearly below one, no cell above 1.25 and no systematic ESS/s loss. Treat noisy ESS or disagreement between seeds as inconclusive. Full-grid replication and paper-length joint runs remain necessary before adoption.

Skip fixed σ, global fixed λ, SIC initialization and another full-prox lamjump. The measured losses or equal-time controls already disqualify those mechanisms. An exact Gaussian θ replacement would abandon the requested proximal update.
