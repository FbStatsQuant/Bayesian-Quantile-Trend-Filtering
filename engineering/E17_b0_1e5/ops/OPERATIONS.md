# E-17 NOTS operations

Wait for the Engineering head's NOTS GO before opening a connection.
Submissions open at 21:00 CT on November 25, 2026. Use the locked wrapper
for every NOTS command. It avoids the 18:55–19:45 CT blackout, reserves
time for bulk transfers to finish by 18:50, and records a 15-minute
backoff after a timeout or lock failure. Run one session at a time.

## Runtime estimate

| Design | Production tasks | Prior Slurm TotalCPU per task | Projected production core-hours |
| --- | ---: | ---: | ---: |
| Interior (E-14) | 3,000 | 170.251 s | 141.876 |
| Extreme (E-15) | 3,600 | 162.085 s | 162.085 |
| Both | 6,600 | 165.797 s weighted | 303.961 |

Six pilot runs per design add an estimated 0.554 core-hours. The historic
projection is 304.515 core-hours including the pilot, leaving 25.485
core-hours under the 330 cap. Actual pilot Slurm TotalCPU governs the
decision. With 300 concurrent tasks, 304 core-hours needs about 61
minutes of CPU capacity. Under the shared 1,536-CPU cap, if SMC holds
1,200 CPUs and E-17 tasks bill as two CPUs each, E-17 can occupy at most
about 168 concurrent slots and the same work needs about 109 minutes
of CPU capacity, before queue delays and scheduler overhead.

## Stage and pilot after GO

Run these commands from the Owls repository root. Use Sol-A's verified
bundle and the bundle's advertised HEAD, and set the throttle to the
agreed 300. Staging calls the bundled snapshot script to archive the
individual sampler, original generators, and worker scripts.

```bash
ops=engineering/E17_b0_1e5/ops
slurm=engineering/E17_b0_1e5/e17.slurm
throttle=300
head=$(git bundle list-heads "$BUNDLE" HEAD | awk '$2=="HEAD"{print $1}')
bash "$ops/stage_bundle.sh" "$BUNDLE"
bash "$ops/submit.sh" interior pilot "$throttle" E17-interior-pilot-20261125 "$head" "$slurm"
bash "$ops/submit.sh" extreme pilot "$throttle" E17-extreme-pilot-20261125 "$head" "$slurm"
```

If Sol-A's staging step has already produced the hash-verified snapshot
at `$HOME/BQTF/tmp/e17-code-$head`, use it. The two pilot arrays use six
indices each from the bundled `e17_pilot.R` and can run concurrently.
Report each job ID immediately. Use occasional Slurm accounting
checks through the wrapper. Once all twelve allocation records are
terminal, run:

```bash
bash "$ops/assess_pilots.sh" E17-interior-pilot-20261125 E17-extreme-pilot-20261125
```

The assessment requires every fit to complete, acceptance in [0.4,
0.6], zero σ guards, and matching prior and sampler. The existing
pilot checker applies the E-14 interior projection limit of 150
core-hours and the combined limit of 330 including the pilot. If the gate fails,
report the cause and stop. Once it passes, submit the first production
array immediately and the other as soon as it fits. Run production
arrays in sequence at the agreed throttle to respect both the shared
CPU split and the 5,000 submitted-task limit. Report each job ID when
accepted. If a submission times out, verify whether Slurm accepted it
before retrying.

```bash
bash "$ops/submit.sh" interior full "$throttle" E17-interior-20261125 "$head" "$slurm"
# After the interior array has finished and the submission slot is available.
bash "$ops/submit.sh" extreme full "$throttle" E17-extreme-20261125 "$head" "$slurm"
```

## Collection

When a production array is terminal, validate its task grid and
diagnostics, report Slurm TotalCPU, and generate per-run and health CSVs.
A failed or missing fit prints its index and any RDS error message.
Transfer by the bulk lane into a private Owls directory. Verify the
RDS count and the SHA-256 manifest independently on both hosts.

```bash
bash "$ops/collect.sh" interior E17-interior-20261125 "$PWD/runs/E17-interior-20261125"
bash "$ops/collect.sh" extreme E17-extreme-20261125 "$PWD/runs/E17-extreme-20261125"
```

Send results to the Engineering head only. The collection script uses
`E17_RESULTS.sha256` for integrity checking and leaves the run outside
the automatic E-01 pickup.
