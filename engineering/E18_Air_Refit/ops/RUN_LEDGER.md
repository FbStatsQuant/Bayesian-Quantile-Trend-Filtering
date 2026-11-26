# E-18 Stage 1 benchmark run ledger

All times are Central on 2026-11-26. Recorded CPU time is Slurm
TotalCPU over array tasks. Outputs stay under
`$HOME/BQTF/tmp/e18-results/` on NOTS until copied to Owls.

| Job | Stage | Submitted | Status | CPU core-hours |
| --- | --- | --- | --- | ---: |
| 2918224 | Original ADMM, 300 tasks | 09:25:01 | All tasks failed loading `libglpk.so.40` through `Rglpk.so` | 0.170966 |
| 2918226 | Original Onizuka HS, 300 tasks | 09:25:11 | Cancelled by explicit job ID at 09:45:50 after ADMM failed. No tasks started. | 0 |
| 2920040 | Replacement Onizuka HS, 300 tasks | 09:46:19 | Cancelled by explicit job ID at 09:51:43 to preserve the 80-core-hour cap. Zero completed fits. | 23.589929 |
| 2920382 | ADMM compute-node preflight, 1 task | 09:51:58 | Rglpk and detrendr loaded, and the ADMM fit completed | 0.001053 |
| 2920391 | Replacement ADMM, 300 tasks | 09:52:57 | 299 completed and verified. Task 161 (τ = 0.05, seed 62) hit the 20-minute wall limit. | 0.831854 |

The retry uses the authorized bundle SHA-256
`7b144f5ef7b34dd63bae24cd944e728747580cb441ac4070b34e3c6959b710a4`
(HEAD `bf2dbb863fcd8cf65486331125c63a8f98cc65bd`).

NOTS provides `GLPK/5.0` with GCCcore 14.3.0. Loading it after GCC and
R resolves `/opt/apps/software/GLPK/5.0-GCCcore-14.3.0/lib/libglpk.so.40`.
The environment-only Slurm change is:

```diff
 module load GCC/14.3.0 R/4.5.2
+case "$stage" in admm-sim|admm-real) module load GLPK/5.0 ;; esac
```

The ADMM preflight adds an explicit package load on a compute node
and runs one input through the authorized worker. Rglpk and detrendr
retain their installed versions.

At 09:51:33, all 300 replacement HS tasks were still running, with
22.840 sampled CPU core-hours and no complete fits. Its final charge
was 23.589929 core-hours. The remaining Stage 1 budget before the
replacement ADMM job was approximately 3.408 core-hours.

Stage 1 used 77.423864 core-hours across both pilots, PMALA production,
the original failed ADMM job, the HS attempt, the ADMM preflight, and the
ADMM replacement. The completed ADMM fits were verified on NOTS and
Owls against a manifest with SHA-256
`488a9fa864c64e677a01ee9380e809e18c8ea092075d155d6e43351db6d580f1`.
The Stage 1 comparison includes those 299 fits. Stage 2 remains on hold.
