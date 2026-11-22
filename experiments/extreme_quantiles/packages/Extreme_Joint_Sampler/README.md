# Extreme quantiles, joint job (NOTS)

Folder on NOTS: `/home/fb31/projects/Quant_Reg/Extreme_Joint_Sampler`. **Nothing is submitted until the
user gives the deployment command.**

| Setting | Value |
|---|---|
| Baselines / noises | VS, S / Normal, Beta, Mixed |
| n, seeds | 500, seeds 1-100; data RNG seed s, MCMC RNG seed s + 1000; same data as the individual job |
| Levels fitted jointly | 0.90, 0.93, 0.96, 0.97, 0.98, 0.99 |
| Levels analysed | 0.96, 0.97, 0.98, 0.99 only (0.90 and 0.93 are excluded from every summary) |
| Sampler | `source/Joint/Joint_Sampler_PMALA_Augmented.R` unchanged; the worker evaluates that file's own Main-section call, so every saved setting is used. Overrides: tau_list, b0 = 0.01 (VS) / 0.001 (S), 30,000 sweeps with 10,000 burn-in (the 10k/3k run of 2026-10-07 had not settled). Order k = 2 is the saved value |

600 tasks (seed fastest, then noise, baseline) in two batches of 300: VS = 1-300, then S = 301-600,
chained (`afterany`) and capped at 400 running. Per task: 1 CPU, 4 GB, 6 h (at 10k sweeps tasks took 16-28 min on NOTS; allocation, not a measured
runtime). Task outputs and logs go to `/scratch/fb31/qr_data/extreme_joint/RUN`.

Each task stores the posterior means at all six levels (summaries use 0.96-0.99), MSE, per-level
acceptance / outside-box / interior-point / ASIS rates, lambda and sigma traces, and the settings used;
every retained draw is re-checked to be ordered. Full draws are not stored. Processing verifies hashes,
configuration and data, recomputes MSE and counts crossings exactly as in the individual job
(see `../Extreme_Individual/README.md`); for the joint sampler they must be zero.

    bash seal.sh                                   # after any edit
    sbatch --chdir=$PWD slurm/validate.slurm $PWD  # validation job (required before submission)
    bash submit.sh RUN_NAME                        # PRODUCTION: only on the user's command
    bash status.sh runs/RUN_NAME
    bash retry.sh runs/RUN_NAME BATCH 305,411-415
