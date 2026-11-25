# E-14b Interior S rerun at b₀ = 0.001

E-14b repeats the 1,500 S fits from E-14 at λ ~ Gamma(1, 0.001) in
shape/rate form. The E-14 S rate was 0.0005. The data, σ prior
IG(0.1, 0.1), chain RNG seeds, and sampler settings carry over from
E-14. The sampler is pinned to `63f2a56205b8d2ec311565db8c98874cd96754b2`
and each run uses 30,000 sweeps with 10,000 burn-in.

`e14b_tasks()` takes the S rows of the E-14 grid and maps them to Slurm
indices 0–1499. The chain seed is `11501 + index`, which preserves the
original S seeds after reindexing. The pilot covers task 0 (Normal at
0.05, seed 1) and task 1499 (Mixed at 0.95, seed 100). The two pilot runs
join the eight E-15 runs for the common-rate gates, with a combined
production budget of 260 core-hours.

The production array is `bqtf-e14b` on commons with one core, 768 MiB,
and a 15-minute limit per task. Its 200-task throttle complements the
400-task E-15 throttle. The second submission waits for sufficient room
under the commons limit of 5,000 submitted tasks per user.

The verified bundle snapshot includes the E-14 sampler, data and worker
scripts, the original generator source used by `e14_data.R`, and the
E-14b scripts. The run goes under
`$HOME/BQTF/runs/E14b-inner-S-b1e3-20261125`. Use `e14b_check.R` and
`e14b_summary.R` after completion. The per-run λ and σ means use the
full posterior traces. The compact result retains only the thinned
traces and curve summaries.

## Production results

The two E-14b pilot tasks in job `2895796` completed with zero σ guards
and acceptance of 0.49490 and 0.49970. Their measured mean CPU time
projected to 59.499 core-hours for the E-14b array. The combined E-14b
and E-15 projection was 208.416 core-hours. Production used verified
engineering commit `20cc922927e2d68375f5a55bc91d13ec4bb68ffb`.

Array `2896648` completed all 1,500 runs. The checker found zero missing
IDs and zero failure files. Slurm TotalCPU was 265,449.043 seconds
(73.735845 core-hours). Acceptance ranged from 0.48850 to 0.51545.
No run triggered the σ guard, and all runs recorded 200 warm-start
IPM fallbacks.

The Owls copy is `runs/E14b-inner-S-b1e3-20261125/`. All 1,502 result
and summary hashes verified on both hosts. The transfer manifest
SHA-256 is `f28606266a10a099057ce928534215ce29b1b4b31be6ead5ccf3882d972ecda5`.
The NOTS run was sealed after transfer. All 3,022 seal entries verified.
