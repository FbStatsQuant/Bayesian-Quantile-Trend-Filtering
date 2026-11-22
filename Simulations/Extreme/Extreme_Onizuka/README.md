# Extreme quantiles: Onizuka BQTF MCMC worker (Laplace and horseshoe priors)

Part of the individual job; submitted, validated and processed from `../Extreme_Individual`.

- `source/BQTF-function.R` is the original sampler file, unchanged (SHA-256 58e073e2...3553, the same as
  every other copy in the project).
- `worker_onizuka.R RUN_DIR INDEX` runs `BQTF.MCMC.Lap.multi` (indices 4801-7200) or `BQTF.MCMC.HS.multi`
  (7201-9600) with the tuning-free defaults of `Onizuka_BQTF_Individual.R`: X = 1, ..., n, TForder = 2,
  sig.init = c(1, 1), sparse = FALSE; mc = 10,000 with the first 3,000 discarded; posterior mean reported.
- The file's `library(Bessel)` is skipped when Bessel is absent (it is used only by the VB/CVB routines,
  not by the MCMC samplers); every other package it loads must be present.
