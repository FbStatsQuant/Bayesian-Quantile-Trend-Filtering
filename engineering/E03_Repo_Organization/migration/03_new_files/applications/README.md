# applications/

Real-data analyses. Moved from `Data Applications/` as-is: the folder names inside are unchanged.

| Folder | What | Feeds paper |
|---|---|---|
| `Growth/` | Dutch growth data (`data/fdgs.csv`), joint P-MALA fit (`Growth_Joint_PMALA_k2.R`), checks, plots, `results_joint_k2/` | `data_application.tex` (boys), appendix (girls, LMS): figures `growth_pmala_*`, `growth_lms_*` |
| `Air Quality/` | raw SPod sensor CSVs (7 files). Archived to the PC; see `Air Quality/DATA.md` | `data_application.tex`: figures `spod_*` |
| `Munich Rent/` | dropped application (removed from the paper 2026-10-28): code, small data, `results_k2/`. The heavy `Others/results*` draws are archived to the PC (`Munich Rent/DATA.md`) | none (the `munich_*` figures are in `archive/munich_rent/figures/`) |

Growth kernels: `Growth_Joint_PMALA_k2.R` and `Growth_Joint_checks.R` compile the canonical kernels in `../../method/joint/` and `../../method/individual/`.

## Open items (recorded, not fixed by E-03)

1. **Missing generators.** No script in the repo produces the figures `nile_*` (5 png + `nile_individual_sampler.pdf`), `spod_*` (4 png), `growth_lms_*` (2 pdf), `growth_pmala_*` (2 pdf) and `scal_*` (4 pdf). The `growth_joint_*` figures in `Growth/results_joint_k2/figures/` come from `Growth_plots_k2.R` but have different names.
2. **Missing Nile data.** The Nile series (Cobb 1978) used for the `nile_*` figures is not in the repo.
3. **SPod data is not read by any repo script.** The seven `S08_*.csv` files (raw, 20 MB each) are input data whose analysis code is missing; they are archived on the PC, with SHA-256 in `Air Quality/DATA.md`.
4. **Windows paths.** `Growth/Growth_Joint_checks.R` (fallback only) and `Munich Rent/Munich_PMALA_checks.R` contain `C:/Users/felip/...`; the Munich checks are not runnable (historical).
5. **Munich scripts** read `Simulations/Individual/` (old layout); they are historical and not maintained.
6. Question for Felipe: are the generators on the PC? If so, send them through E-01 and they go into `applications/` with a README.
