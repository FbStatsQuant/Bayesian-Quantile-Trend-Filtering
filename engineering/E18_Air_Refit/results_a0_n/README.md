# E-18 Stage 1′ with a0 = n

These CSVs come from the 1,500 completed PMALA fits at `a0 = 500` in
`runs/E18-prime-sim-20261126`. The preregistered rule selected
`b0 = 1e-2` at all three levels under branch (i).

Table note. Within a cell, `theta_ess_median` and `theta_ess_p10` are
the median and 10th percentile across the per-fit medians of pointwise
θ ESS. The worker retained the pointwise ESS median and p05 for each
fit. The per-fit pointwise p10 is unavailable. Coverage is the
cell mean of per-fit pointwise 95% interval coverage.

The warm-up columns in `pmala_cells.csv` summarize the median, minimum,
maximum, and share at 200 of 200 for each counter. All 1,500 fits
recorded 200 fallbacks and 200 IPM nonconvergences.

The ADMM comparison uses common seeds. ADMM timed out at τ = .05,
seed 62, leaving 299 fits. Onizuka HS uses the published aggregates,
and Laplace uses the sealed archive.
