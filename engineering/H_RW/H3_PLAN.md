# H3 Munich draw retention

M1 (`0aa2bac`) moved the Munich files to `archive/munich_rent/code/`.
`git ls-files` and the working-tree file sizes give this inventory of
tracked RDS draws, with paths relative to `archive/munich_rent/code/Others/`.

| Directory | RDS files | Bytes |
|---|---:|---:|
| `results/` (including `validated/`) | 17 | 25,827,334 |
| `results_onizuka/` | 5 | 24,027,542 |
| `results_onizuka_k2/` | 6 | 48,230,961 |
| `results_pmala/` | 5 | 14,116,637 |
| `results_pmala_k2/` | 0 | 0 |
| **Total** | **33** | **112,202,474 (107.0 MiB)** |

All 33 draws match the size and SHA-256 recorded in
[`archive/munich_rent/code/DATA.md`](../../archive/munich_rent/code/DATA.md).
The `SHA256SUMS.inputs` and `SHA256SUMS.outputs` files in `results_pmala_k2/`
cover inputs and summary outputs. No `SHA256SUMS` file covers these 33 draws.

All 33 paths match the existing rule in [`remove-paths.txt`](remove-paths.txt).
The rule also covers their historical Munich paths.

```text
regex:^(?:(?:Data Applications|applications)/Munich Rent|archive/munich_rent/code)/Others/results[^/]*/.*\.[rR][dD][sS]$
```

Keep the draws, companion results and full history in the private repository.
At submission, [`build.sh`](build.sh) builds the separate public repository
and applies the existing RDS exclusion there.

Keep [`01b_heavy_rm.sh:19`](../E03_Repo_Organization/migration/01b_heavy_rm.sh#L19)
as a record of the E-03 migration. Its old Munich path predates M1. Retire
that script from operational use and rely on the public build for exclusion.
