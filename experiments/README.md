# experiments/

Everything that produced numbers in the paper. Frozen NOTS packages are kept exactly as run (their `SHA256SUMS` stay valid; remote paths such as `/home/fb31/projects/Quant_Reg/...` inside them are historical and must not be edited). Raw per-task outputs are on the PC, not here: see `archive/archived_campaigns.md`.

Convention: each experiment has a `results/` (or `summary/`) folder with small summaries and a README whose first section is "Feeds paper: Table X, Figure Y".

## Provenance index: paper item to folder

| Paper item (label) | In | Produced by |
|---|---|---|
| Table `tab:vs_int_mse` (VS, interior levels, MSE) | `simulations.tex` | `interior_quantiles/individual_nots_20261003/` (VS_b0001/, S_b0001/ sub-packages; `paper_reference/`); table builder `deployment/paper_mse_tables.py`. Joint reference: `interior_quantiles/joint_nots/paper_reference/{interior_tables_long.csv, provenance.txt}` |
| Table `tab:s_int_mse` (S, interior levels, MSE) | `simulations.tex` | same as above |
| Tables `tab:vs_int_mad`, `tab:vs_int_mciw`, `tab:s_int_mad`, `tab:s_int_mciw` | `appendix_simulations.tex` | same as above |
| Tables `tab:vs_ext_upper_mse`, `tab:s_ext_upper_mse` (extreme upper levels, MSE) | `simulations.tex` | `extreme_quantiles/packages/{Extreme_Individual, Extreme_Joint_Sampler, Extreme_Onizuka, Extreme_admm}`; tables `extreme_quantiles/tables_20261008/`, `tables_20261023/` (`mse_consolidated_oct7.*`, `gen_tex.R`), `tables_4lev_20261023/` (4-level vs 6-level) |
| Tables `tab:vs_ext_upper_cross_nb`, `tab:s_ext_upper_cross_nb`, `tab:vs_ext_upper_cross_all`, `tab:s_ext_upper_cross_all` (crossings) | `appendix_simulations.tex` | `extreme_quantiles/tables_20261008/crossings_*.csv/.tex` |
| Six-level joint run (0.90 to 0.99, 100 seeds) | text and tables of `simulations.tex` | `joint_upper_levels/runs/VS_upper6_100seeds_Rdefaults_b001_20261002/` (`summary/`, `analysis/`, `paper_reference/table2_mse.csv`); package files in `joint_upper_levels/`; notes `paper/history/joint_extreme_results_20261002/` |
| Table `tab:air_n500` (air simulation, n = 500) | `air_simulation.tex` | `air_simulation/drivers/{individual_air_sim.R, admm_air_sim.R}`; Onizuka-Laplace add-on `air_simulation/onizuka_laplace_20261023/` (`attempt_*/summary.csv`, `per_task_metrics.csv`, `tables/`; code in `package_stage/`; build record `BUILD_REPORT.md`); notes `paper/history/air_*` |
| Table `tab:cost_scaling`, Figures `fig:cost_scaling`, `fig:cost_breakdown` (`scal_time.pdf`, `scal_breakdown.pdf`) | `scalability.tex` | `scalability/` (`timings.csv`, `table_cost_scaling_body.tex`, `make_cost_figure.py`, `benchmark_existing.R`). The TeX comment `% Evidence:` now points here. Generators of `scal_*.pdf` are not in the repo (open item) |
| Table `tab:pmala_variants` | `appendix_pmala.tex` | `interior_quantiles/individual_nots_20261003/paper_reference/appendix_pmala.tex` (and the 2026-09 variant study in `paper/history/`) |
| Figures `growth_pmala_*`, `growth_lms_*` | `data_application.tex`, appendix | data and fits in `applications/Growth/` (the `growth_joint_*` figures there are the generated ones; the `growth_pmala_*`/`growth_lms_*` generators are missing) |
| Figures `spod_*`, `nile_*` | `data_application.tex`, appendix | no generator or Nile data in the repo; see `applications/README.md` |

## Folders

| Folder | Content |
|---|---|
| `interior_quantiles/individual_nots_20261003/` | NOTS package of the individual-sampler campaign (VS and S, interior levels) with `S_b00005/`, `S_b0001/`, `VS_b0001/` sub-packages |
| `interior_quantiles/joint_nots/` | earlier joint interior-level package, `paper_reference/` |
| `extreme_quantiles/` | four NOTS packages (`packages/`), three table folders, `DEPLOYMENT_NOTES.md` (issues log), `tables_20261023/gen_tex.R` |
| `joint_upper_levels/` | joint six-level package and run `VS_upper6_100seeds_Rdefaults_b001_20261002`; the 10.8 MB monitor log is on the PC (`MONITOR_LOG_POINTER.md`) |
| `air_simulation/` | Brantley-style air-quality simulation: drivers, Onizuka-Laplace add-on |
| `scalability/` | time-per-sweep benchmark (from `paper/history/complexity_analysis`); `figures_unused/` |
| `pilots/` | small local pilot runs (n = 500, seed 1) |
