# Historical scalability benchmarks

This folder preserves the earlier time-per-sweep benchmark. Its benchmark
and table-building scripts do not run against the repository as shipped.
The benchmark uses pre-E-03 source paths. The
[paper's cost table](../../paper/sections/scalability.tex) is the authoritative
source for the reported timings.

- **F1** — `benchmark_existing.R` sources files at pre-E-03 paths that no longer exist.
- **F2** — `build_tables.py` expects `n` and `ms_per_sweep`, while the shipped
  `timings.csv` contains `method`, `rep`, and `ms_per_iteration`.
- **F3** — `table_cost_scaling_body.tex` contains superseded timings.
