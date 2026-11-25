# Interior-quantile claims to update

The comparisons below use the values displayed to six decimals in the
published and rebuilt LaTeX tables. For comparisons with the better
Onizuka sampler, the denominator is the smaller of the Laplace and
horseshoe MSE in each cell.

| Manuscript claim | Published | Recomputed |
| --- | --- | --- |
| VS MSE, largest ratio between any two Bayesian samplers in the same cell | 1.22 | 1.22 (1.218389 → 1.218697, both Beta at τ = 0.95) |
| VS Beta MSE, horseshoe smallest | 5 of 5 levels | 5 of 5 levels |
| VS MSE, ADMM largest | 14 of 15 cells, except mixed normal at τ = 0.95 | 14 of 15 cells, same exception |
| S MSE, ADMM smallest | 15 of 15 cells | 15 of 15 cells |
| S MSE, PMALA divided by ADMM | 1.4 to 3.1 | 1.3 to 2.0 (1.2842 to 2.0264, both endpoints under Beta noise at τ = 0.05 and 0.95) |
| S MSE at τ = 0.25, 0.50, 0.75, PMALA below both Onizuka samplers | 9 of 9 cells, 15% to 23% below the better sampler | 9 of 9 cells, 25% to 43% below the better sampler (25.44% to 43.49%) |
| S MSE at τ = 0.05, 0.95, PMALA versus both Onizuka samplers | Above both in 5 of 6 cells, by 8% to 18% relative to the better sampler. Below both for Beta at τ = 0.05 | Below both in all 6 cells, by 4% to 33% relative to the better sampler (4.44% to 33.05%) |
| VS MAD, agreement with the stated MSE pattern | Horseshoe smallest in 5 of 5 Beta cells. ADMM largest in 13 of 15 cells | Horseshoe smallest in 5 of 5 Beta cells. ADMM largest in 14 of 15 cells, except mixed normal at τ = 0.95 |
| VS MCIW, PMALA narrower than both | 15 of 15 cells | 15 of 15 cells |
| S MAD, PMALA versus both Onizuka samplers | Below both in 10 of 15 cells (all nine middle levels and Beta at τ = 0.05). Above both in the other 5 | Below both in all 15 cells |
| S MCIW, PMALA versus both Onizuka samplers | Narrower than both in 10 of 15 cells (all nine middle levels and Beta at τ = 0.05). Between the widths in the other 5 | Narrower than both in all 15 cells |

The extreme-quantile paragraph's reference to the horseshoe winning at
interior VS Beta levels still holds. [Main text, VS](../../paper/sections/simulations.tex#L23) ·
[Main text, S](../../paper/sections/simulations.tex#L56) ·
[Extreme cross-reference](../../paper/sections/simulations.tex#L94) ·
[Appendix, VS](../../paper/sections/appendix_simulations.tex#L14) ·
[Appendix, S](../../paper/sections/appendix_simulations.tex#L78)
