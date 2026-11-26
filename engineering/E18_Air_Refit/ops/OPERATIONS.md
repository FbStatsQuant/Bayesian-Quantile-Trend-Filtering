# E-18 NOTS operations

The Engineering head will relay the bundle and its runner contract.
Prepare locally until then. Use `queue.sh` after NOTS access is
authorized and before submitting the first job. Compare the shared
commons occupancy with the SMC agreement and report a change to the
Engineering head before submission. The queue report labels requested
CPUs. Slurm's billing TRES can differ. Production arrays use at most
`%300`, one active E-18 array at a time, on commons. All SSH uses the
E-17 locked wrapper with one connection, 15-minute timeout backoff,
and no SSH from 18:55 to 19:45 CT.

Use only the bundle SHA-256 relayed by the Engineering head. Verify it
on both hosts, including its SHA-256 and matching
HEADs. The bundled snapshot script must support writing into an
empty snapshot directory. Work and temporary output live under
`$HOME/BQTF/tmp/e18-results/` and `$HOME/BQTF/tmp/e18-code-<HEAD>/`.
Keep all NOTS outputs outside the directory the PC puller scans.
The staging wrapper derives `e18_private.slurm` from the verified
Slurm script with the private run path. Submission passes the worker
stage and run directory as its two arguments.

```bash
ops=engineering/E18_Air_Refit/ops
SLURM_PATH=engineering/E18_Air_Refit/e18_private.slurm
bash "$ops/stage.sh" "$BUNDLE" "$BUNDLE_SHA256" "$SNAPSHOT_SCRIPT"
bash "$ops/queue.sh"
bash "$ops/submit.sh" "$MODE" "$RUN_ID" "$HEAD" "$SLURM_PATH" "$ARRAY" "$MEM" "$TIME"
bash "$ops/accounting.sh" "$JOB_ID" > "$ACCOUNTING"
```

Report every accepted job ID immediately. After a submission timeout,
respect backoff and check for an accepted job before retrying. For an
authorized cancellation, pass only the explicit Slurm ID to `scancel`.
Before any production array, including a benchmark, measure at least
one fit using that array's settings. The compute-node preflight must
load every runtime library needed by the worker. This includes
`library(Rglpk)` and `library(detrendr)` for ADMM, with the GLPK module
loaded for ADMM stages.
For pilots, report submission-to-start queue wait separately from
elapsed run time and Slurm TotalCPU. If any E-18 job or array tasks
remain pending about 60 minutes after submission, run
`bash "$ops/pending.sh" "$JOB_ID"` and immediately report the job ID,
reason, and observed position in the commons `squeue` listing. That
position is a snapshot of the listing. Leave the job queued on
commons and leave all SMC jobs untouched.

## Stage 1 (closed)

Use indices `0,100,200,900,1000,1100`, one per \(\tau\) at each
of 0.001 and 0.000001, with seed 1.
Check all six complete with post-burn-in acceptance 0.4–0.6 and zero
σ-guard events with `Rscript --vanilla "$ops/sim_pilot_gate.R" "$PILOT_DIR"`.
Run `python3 "$ops/pilot_resources.py" sim "$ACCOUNTING"`
offline to project Slurm TotalCPU and size the production memory from
MaxRSS. The projection weights the six extreme-rate pilot cells equally.
It includes the pilot and leaves a separately reported allowance for
ADMM. The cap is 80 core-hours. Use the bundled starting memory
allocation for the pilot and measure MaxRSS before setting production
memory.
Stage 1 closed at 77.424 of 80 core-hours. The approved ADMM result
contains 299 fits. Reuse the sealed Laplace archive. HQ ruled against
an HS refit, so there are no further HS submissions.

## Stage 1′ (held)

Wait for the Engineering head's authorized bundle SHA. This design uses
`a0 = n = 500`, three quantiles, five rates, and 100 seeds per cell,
for 1,500 production fits. Use `E18-prime-*` run IDs, with
`sim-prime-pilot` for the pilot and `sim-prime` for production. Pilot
indices `0,100,200,1200,1300,1400` select seed 1 at both endpoint rates
for each quantile.

Use the full pilot completion, sampler provenance, acceptance and
σ-guard gates. Report queue wait, wall time, TotalCPU, MaxRSS, log-λ
ESS and θ ESS. Project production using 500 times the mean measured
CPU per fit at each quantile, summed across quantiles. Add the Stage 1′
pilot CPU and compare with the fresh 80-core-hour cap. Stop and report
if a gate fails or the projection exceeds that cap.

## Stage 2 (held)

Apply the same approval sequence under the 40-core-hour cap. Use
authorized, hash-verified real-data input and one pilot run per
\(\tau\) with about 45 minutes of computation each. Production is
four rates by three quantiles by two chains, for 24 fits.
The workers must emit completed-sweep counts or equivalent timing so the
full chain cost can be extrapolated. Record warm and regular sweep times
separately if the pilot stops before all planned sweeps. Read MaxRSS
with `python3 "$ops/pilot_resources.py" real "$ACCOUNTING"`, and account
for extra retained posterior draws when the pilot used a shorter chain.
For sizing context, a dense matrix of 20,000 by 8,640 doubles alone
uses 1.29 GiB. If all pilots use 45 CPU minutes, 37.75 core-hours remain
for 24 production fits and the detrendr rerun, or 94.375 minutes per
fit before detrendr. Send the measured projection to the Engineering
head. Stop if the sampler stalls at n = 8,640 or continuing would
require changing the E-14/E-17 algorithm.

The pilot supplies one chain per quantile, so assess cross-chain
R-hat when both production chains for a quantile and rate are
available. Read `log_lambda_rhat` in `spod_cell_health.csv`, which
`e18_real_report.R` calculates from the retained log-λ draws using
classic Gelman–Rubin R-hat. Stop and report any value above 1.1.

## Collection

After accounting is terminal, run the bundled output checker. Report
failed tasks, including their retained error messages. Once the expected
outputs are complete, copy the result folder and any named summaries
with a SHA-256 manifest verified on both sides.

```bash
bash "$ops/collect.sh" "$RUN_ID" "$EXPECTED_RDS_COUNT" "$SUMMARY_FILE"
```

The summary-file argument is optional. For a worker with another output
format, use `-` for the expected RDS count and verify the artifacts with
its checker. The Owls destination is `runs/<RUN_ID>/`. NOTS does not use
the automatic PC pickup.
