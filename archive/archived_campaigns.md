# Archived NOTS campaigns

On 2026-11-22 the NOTS tree `~/projects/Quant_Reg` was archived to Felipe's PC through the E-01 pipeline.

- **Run id:** `legacy-quant-reg-20261122`
- **Size:** 4,787 files, 81,808,447 bytes
- **Receipt:** signed, 2026-11-22
- Loose Sep-Oct 2026 campaign scripts, logs and tarballs from `/scratch/fb31` went with it as **`legacy_scratch_20261122`**: 25 files, 650,587 bytes.

Package code and the summaries used in the paper are in this repo under `experiments/` (frozen as run). What was archived is the NOTS-side tree: raw task outputs, logs and working copies.

| NOTS folder (`~/projects/Quant_Reg/...`) | Size | Files | What | Where the code/summary is in the repo |
|---|---|---|---|---|
| `Air_sim` | 12M | 826 | Air simulation: ADMM / QTF worker | `experiments/air_simulation/drivers/admm_air_sim.R` |
| `Air_sim_Lap` | 4.1M | 245 | Air-quality peak detection: Onizuka Laplace add-on | `experiments/air_simulation/onizuka_laplace_20261023/` (`package_stage/`) |
| `cleanup_logs` | 628K | 13 | cleanup logs | none |
| `Data_applications` | empty | 0 | placeholder | none |
| `Extreme_admm` | 20K | 4 | extreme quantiles, ADMM worker | `experiments/extreme_quantiles/packages/Extreme_admm/` |
| `Extreme_Individual` | 22M | 2715 | extreme quantiles, individual job | `experiments/extreme_quantiles/packages/Extreme_Individual/` |
| `Extreme_Joint_Sampler` | 6.3M | 572 | extreme quantiles, joint job | `experiments/extreme_quantiles/packages/Extreme_Joint_Sampler/` |
| `Extreme_Joint_Sampler_4lev` | 18M | 256 | extreme quantiles, joint job at four levels | `experiments/extreme_quantiles/tables_4lev_20261023/` |
| `Extreme_Onizuka` | 44K | 4 | Onizuka MCMC worker | `experiments/extreme_quantiles/packages/Extreme_Onizuka/` |
| `Inner_admm` | empty | 0 | placeholder | none |
| `Inner_Individual` | 39M | 117 | individual inner (interior) quantiles NOTS package | `experiments/interior_quantiles/individual_nots_20261003/` |
| `Inner_Joint` | 280K | 22 | joint sampler, interior quantiles | `experiments/interior_quantiles/joint_nots/` |
| `Inner_onizuka` | empty | 0 | placeholder | none |
| `NOTS_Exercise` | 108K | 10 | throwaway Slurm-array exercise | pattern note: `engineering/E03_Repo_Organization/NOTS_EXERCISE_PATTERN.md` |

TODO (Engineering): the six-level joint package `Joint_Sampler` (production destination named in `experiments/joint_upper_levels/README.md`) is not in the index supplied for this file; confirm whether it was archived, and add its line. Its package and run summary are in `experiments/joint_upper_levels/`.

To restore anything: ask Felipe for the PC path of run `legacy-quant-reg-20261122`; the signed receipt lists every file with its SHA-256.
