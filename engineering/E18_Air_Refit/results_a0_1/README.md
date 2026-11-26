# E-18 Stage 1 sensitivity

`a0 = 1, not adopted; sensitivity`.

The original `runs/E18-sim-20261126/` remains in place. The selection and
PMALA cell CSVs preserve the sensitivity evaluation. The rebuilt per-fit
CSV adds the explicit `a0` column. The comparison uses 299 verified ADMM
refits, the 300 sealed Laplace fits and the published HS aggregates.
ADMM's τ = .05, seed 62 timeout is recorded in `discarded_reps.csv`.
