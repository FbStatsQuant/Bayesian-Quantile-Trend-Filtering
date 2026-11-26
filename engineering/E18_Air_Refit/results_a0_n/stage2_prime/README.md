# E-18 Stage 2′ (real SPod data, a0 = 8640): report copies

These are copies of `runs/E18-prime-real-20261126/report/`. The run folder is untracked; its manifest SHA-256 is `d852ae8882da41eea471eb6604625193650ca2be8987f6372080f3abdf60cc29`.

- **Jobs:** NOTS pilot 2923274 (2.05 core-hours) and production 2926921 (30/30 fits, 19.93 core-hours), 21.97 core-hours in total against a 40 cap.
- **Code:** worker `9730ff1`, input preparation `35cc297` (input SHA-256 `7034864a…`), reporter `03fa4cd`.
- **`spod_decision_by_tau.csv`:** HQ's curve-agreement rule, fixed before the results. Its definitions are in the E-18 README. All three τ are marked REPORT. The log-λ R-hat checkpoint tripped at τ = 0.01 (1.186), and the rule treats that as a checkpoint only.
- **Other diagnostics:** `spod_cell_health.csv` gives every τ × b0 cell. `spod_chain_health.csv` gives every chain. `spod_chain_warm_summary.csv` gives the warm-up counters.
- **Figures:** `spod_pmala_figure6.pdf` is in the Figure 6 layout, with detrended panels on the left, pooled medians, and b0 = 1e-2. The `spod_chain_overlay_t*_r2.png` files overlay the chain A and chain B medians at b0 = 1e-2.
