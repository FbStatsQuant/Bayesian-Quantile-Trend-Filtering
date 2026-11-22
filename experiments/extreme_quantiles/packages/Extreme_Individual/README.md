# Extreme quantiles, individual job (NOTS)

Folder on NOTS: `/home/fb31/projects/Quant_Reg/Extreme_Individual`. Its workers, together with those in
`Extreme_admm` and `Extreme_Onizuka`, make up the **individual job**. The joint sampler is a separate job
in `Extreme_Joint_Sampler`. **Nothing is submitted until the user gives the deployment command.**

## Design

| Setting | Value |
|---|---|
| Baselines / noises | VS, S / Normal, Beta, Mixed (Onizuka parameterisation) |
| n, seeds | 500, seeds 1-100; data RNG seed s, MCMC RNG seed s + 1000 (Mersenne-Twister/Inversion/Rejection) |
| Levels | tau = 0.96, 0.97, 0.98, 0.99, each fitted separately |
| Order | k = 2 (third differences) for every method |
| Bayesian-PMALA | `source/Individual_Sampler_PMALA_Augmented.R` unchanged; the worker evaluates that file's own Main-section call, so every saved setting is used. Overrides: tau, order = 2, b0 = 0.01 (VS) / 0.001 (S), 10,000 sweeps with 3,000 burn-in |
| ADMM (Brantley et al. 2020) | Eq. (1) solved exactly as an LP (PIQP) at each lambda; lambda by their eBIC (Sec. 3.2: gamma = 1, P = n - k - 1, sigma = (1 - abs(1 - 2 tau))/2); 65-point grid exp(-6), ..., exp(10) |
| Onizuka (Laplace, horseshoe) | Original `BQTF-function.R` unchanged, `BQTF.MCMC.Lap.multi` / `BQTF.MCMC.HS.multi`; X = 1..n, sig.init = (1, 1), 10,000 draws with 3,000 burn-in |
| Point estimate | Posterior mean (ADMM: the eBIC-selected fit) |

All methods generate data with the same `simulate_extreme()` (`common_extreme.R`), which is checked in
validation to reproduce `simulate_data()` of both PMALA sources exactly (response and truth).

## Tasks and batches

9,600 tasks = 4 methods x 2 baselines x 3 noises x 4 levels x 100 seeds, indexed with seed fastest,
then tau, noise, baseline, method. Each method is one batch (array) of 2,400 tasks:
pmala 1-2400, admm 2401-4800, onizuka_lap 4801-7200, onizuka_hs 7201-9600.
Each array runs at most 400 tasks at a time (`%400`), i.e. six waves of 400. `chain.sh` submits one batch;
a 1-CPU chain job submits the next batch after the previous array has ended (`afterany`), and the
processing job after the last batch. Only one batch is queued at a time, which keeps the queue below
the commons QOS limit of 5,000 submitted jobs per user.

Requested per task: 1 CPU; pmala 2 GB / 2 h, admm 2 GB / 1 h, Onizuka 4 GB / 8 h. These are allocations,
not measured production runtimes.

## Outputs

Code and summaries live under `runs/RUN/` (home); `runs/RUN/tasks` and `runs/RUN/logs` link to
`/scratch/fb31/qr_data/extreme_individual/RUN`. Each task stores one compressed `result.rds` with the
response, truth, posterior mean (or eBIC fit), MSE and method diagnostics (PMALA lambda/sigma/delta/acc
traces and the settings actually used; ADMM eBIC path, selected lambda, boundary flag; Onizuka midpoint
trace). Full posterior draws are not stored. Completed tasks refuse to run again.

`process_results.R` (submitted automatically after the last batch) verifies every task's hashes,
configuration and code manifest, recomputes MSE, checks that all methods saw the identical response,
and computes crossings. It refuses to average an incomplete run.

Crossings (reported levels 0.96-0.99 only): for a (method, baseline, noise, seed), a crossing between
levels a < b at index i means est_a[i] > est_b[i]. For level tau, *neighbor* counts the indices crossing
the adjacent reported levels (e.g. 0.97: 0.96 and 0.98), summed over those pairs; *all* sums over every
other reported level (0.97: 0.96, 0.98, 0.99). Tables report the average over the 100 seeds.

Final tables (MSE, neighbor crossings, all crossings; CSV and LaTeX, one per baseline), after both jobs:

    Rscript --vanilla make_tables.R IND_RUN/summary/attempt_X JOINT_RUN/summary/attempt_Y OUT_DIR

## Commands (on NOTS, from this folder)

    bash seal.sh                                   # after any edit: re-seal the three folders
    sbatch --chdir=$PWD slurm/validate.slurm $PWD  # validation job (required before submission)
    bash submit.sh RUN_NAME                        # PRODUCTION: only on the user's command
    bash status.sh runs/RUN_NAME                   # progress
    bash retry.sh runs/RUN_NAME BATCH 4805,4911    # resubmit failed indices of a batch
