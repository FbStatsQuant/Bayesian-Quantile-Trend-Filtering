# Extreme quantiles: ADMM / quantile trend filtering worker (Brantley, Guinness and Chi 2020)

Part of the individual job; submitted, validated and processed from `../Extreme_Individual`.

- `qtf_lp_ebic.R`: problem (1) of the paper, min rho_tau(y - theta) + lambda ||D^(3) theta||_1 (k = 2),
  solved exactly as the linear program of `detrendr::get_model` with PIQP (tolerance 1e-9), for each
  lambda in exp(seq(-6, 10, by = 0.25)) (65 values). lambda is chosen by the paper's eBIC (Sec. 3.2, p. 594):
  2 rho_tau / sigma + nu log n + 2 gamma log choose(P, nu), sigma = (1 - |1 - 2 tau|)/2, gamma = 1,
  P = n - k - 1, nu = #{|D theta| > 1e-6}.
- Why exact rather than the windowed ADMM of Algorithm 1: with n = 500 one window is the whole series,
  Sec. 2.3.1 advises as few windows as the budget allows, and the authors' own simulation driver
  (github.com/halleybrantley/detrendify, Code/Sim_detrendr.R) calls `detrendr::get_trend_BIC`, which
  solves the LP directly.
- Why PIQP: in a local check (VS/S, Normal/Mixed, tau 0.96/0.99, lambda 1-13,000) GLPK sometimes returned
  a non-optimal status or slightly suboptimal points at large lambda and lpSolve often failed, while PIQP
  matched the best objective everywhere. With PIQP, counting |D theta| > 1e-6 reproduced the knot counts
  that the vertex solvers give with detrendr's 1e-9 threshold.
- Why this grid: in 60 local datasets the eBIC minimiser was at the grid boundary 7 times with the
  authors' simulation grid n^seq(0, 1.4, length = 15) and 4 times with the earlier exp(-4..8) 25-point
  grid, and never with this grid. Boundary selections are still flagged per task.
- A failed solve is retried with 50,000 iterations; a lambda that still fails is excluded from the eBIC
  search and counted in the task diagnostics.

`worker_admm.R RUN_DIR INDEX` fits one task (indices 2401-4800 of the individual job).
