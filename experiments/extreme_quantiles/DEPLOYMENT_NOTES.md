# Extreme-quantile campaign: issues log for a possible redeployment

Running record of what went wrong or looked questionable during the 2026-10-07 deployment.
Only change made after the first deployment: joint sampler rerun at 30k sweeps / 10k burn-in (user decision).
Everything else stays as planned unless discussed.

## Runs on NOTS

| Run | Status |
|---|---|
| `Extreme_Individual/runs/extreme_individual_VS_S_10k3k_20261007` | complete, processed (`summary/attempt_20261008T001907_3662120`, SUCCESS 2026-10-08 01:13 UTC) |
| `Extreme_Joint_Sampler/runs/extreme_joint_VS_S_10k3k_20261007` | complete, processed; **superseded** (chains not settled), kept on disk |
| `Extreme_Joint_Sampler/runs/extreme_joint_VS_S_30k10k_20261007` | complete, processed (`summary/attempt_20261008T013010_3687001`, SUCCESS 01:34 UTC); **used for the tables** |

Tables: NOTS `Extreme_Individual/tables_20261008` (local copy `experiments/extreme_quantiles/tables_20261008`), built 2026-10-08.

## Issues

1. **Joint sampler at 10k/3k did not settle** (2026-10-07). Interior-level (0.93-0.98) lambda still fell 9-15% per
   1,000 sweeps at sweep 10k (median 3.5-4k on VS, 15-20k on S, vs ~350-1,200 for individual PMALA). VS joint MSE was
   2-4x the 2026-10-02 run, which used byte-identical code, data and seeds at 30k/10k. Fix applied: rerun at 30k/10k.
   Root cause is the warm start driving interior lambda very high (see 2026-10-05 diagnosis); an initialisation fix
   (e.g. start interior lambda from individual fits) would need fewer sweeps but changes the sampler.
2. **S starts much farther out for the joint sampler.** With b0 = 0.001 the warm start sends interior lambda to ~380k
   (VS ~35k). 30k sweeps may or may not be enough for S; check the lambda traces of the 30k run before trusting S.
   (b0 = 0.001 itself is not a problem; S joint at 10k already had the lowest MSE in most S cells.)
3. **Individual PMALA saved settings differ from the joint sampler's**: ASIS off and target acceptance 0.55 (joint: ASIS
   on, 0.50). Used as saved, per instruction. On S, individual PMALA trails ADMM (e.g. Normal 0.96: 0.024 vs 0.007);
   cannot separate the effect of these settings from b0 without another run.
4. **ADMM LP failures**: 1,065 of 156,000 PIQP solves (0.7%) still failed after a 50,000-iteration retry; each such
   lambda was excluded from that fit's eBIC search (recorded per task). eBIC picked a grid endpoint in 8 of 2,400 fits.
5. **Validation script bug (fixed)**: `find | head -n 1` under `pipefail` gave SIGPIPE (exit 141) in the individual
   validation after all 192 tasks had passed; fixed with `find -print -quit`. The joint `validate.sh` still has the same
   pattern (it passed only because its task tree is small); fix it on the next redeployment.
6. **One mistaken validation submission** (job 2036325, unfixed script) was cancelled immediately; no effect.
8. **S joint at 30k is worse than at 10k at 0.96-0.98** (2026-10-08, final processed, 100 seeds per cell). Mean MSE at 0.96/0.97/0.98/0.99, 10k run -> 30k run: Normal .0056/.0068/.0091/.0192 ->
   .0107/.0121/.0150/.0219; Beta .0020/.0024/.0029/.0120 -> .0038/.0041/.0049/.0068; Mixed .0217/.0268/.0387/.1359
   -> .0430/.0512/.0643/.0940. Interior lambda is still falling at 30k (median over cells, sweeps 10k/20k/30k:
   Normal 18.4k/12.1k/10.3k, Beta 19.9k/13.9k/11.8k, Mixed 14.2k/9.3k/7.9k), i.e. S has not settled either. The
   lower 10k MSE came from the chain not having moved down from the warm start yet (higher lambda suits the smooth S
   truth), not from a converged posterior. At 30k, ADMM beats the joint fit on S Normal (all 4 levels) and S Beta
   (all 4); the joint fit wins S Mixed at 0.97-0.99. VS at 30k reproduces 2026-10-02 (best in Normal and Mixed at all
   levels). For a redeployment: interior-lambda initialisation (issue 1) or longer runs for S; decide with the user.
7. **Scheduler contention**: the 30k joint tasks share the queue with the Onizuka batches (at 22:25 UTC: 95 joint
   running, 205 pending), so the joint run will finish later than its standalone estimate.
