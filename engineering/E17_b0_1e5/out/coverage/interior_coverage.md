# E-17 interior pointwise coverage (HQ only; not for Writing)

Coverage = fraction of the 500 grid points where the true τ-quantile curve lies inside the pointwise 95% equal-tailed credible
interval (probs 0.025/0.975), averaged over 100 seeds. Nominal = 0.95. Sources: E-17 `runs/E17-interior-20261125/e17_summary.csv`
(b0 = 1e-5); previous b0 = E-14 (VS 1e-3; S 5e-4) and E-14b (S 1e-3); Onizuka per-seed `coverage` (estimator = mean rows) from the
owner's workbook `tmp/E14_admm_mask/onizuka_inner_quantiles_summary.xlsx` (run onizuka_n500_20260908, intervals 0.025/0.975).

**Caveat on the Onizuka source:** its per-seed MCIW averages reproduce the paper's Onizuka MCIW for S to within about 1% (seed-mask
differences), but NOT for VS (off by up to ±25%). The VS Onizuka coverage below is therefore from a run that is not verified to be the
published VS comparator. ADMM has no intervals.

Sorted by E-17 coverage, worst first.

| Signal | Noise | τ | E-17 (1e-5) | E-14 | E-14b S (1e-3) | Onizuka Lap | Onizuka HS | MCIW E-17 | MCIW Lap | MCIW HS |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| S | Beta | 0.95 | 0.471 | 0.643 | 0.660 | 0.701 | 0.718 | 0.0828 | 0.1457 | 0.1525 |
| S | Mixed | 0.05 | 0.475 | 0.679 | 0.680 | 0.691 | 0.715 | 0.2703 | 0.5380 | 0.5725 |
| S | Mixed | 0.95 | 0.478 | 0.695 | 0.700 | 0.710 | 0.732 | 0.2560 | 0.5354 | 0.5734 |
| S | Normal | 0.95 | 0.478 | 0.707 | 0.724 | 0.740 | 0.765 | 0.1122 | 0.2507 | 0.2691 |
| S | Normal | 0.05 | 0.485 | 0.699 | 0.704 | 0.726 | 0.749 | 0.1247 | 0.2535 | 0.2752 |
| S | Beta | 0.75 | 0.506 | 0.871 | 0.886 | 0.896 | 0.912 | 0.0471 | 0.1408 | 0.1446 |
| S | Mixed | 0.25 | 0.520 | 0.884 | 0.889 | 0.901 | 0.921 | 0.1759 | 0.5410 | 0.5816 |
| S | Normal | 0.75 | 0.524 | 0.901 | 0.918 | 0.922 | 0.938 | 0.0835 | 0.2628 | 0.2739 |
| S | Beta | 0.50 | 0.528 | 0.893 | 0.917 | 0.927 | 0.940 | 0.0374 | 0.1181 | 0.1191 |
| S | Mixed | 0.75 | 0.529 | 0.891 | 0.900 | 0.901 | 0.921 | 0.1819 | 0.5419 | 0.5821 |
| S | Normal | 0.25 | 0.538 | 0.883 | 0.895 | 0.908 | 0.927 | 0.0864 | 0.2624 | 0.2766 |
| S | Normal | 0.50 | 0.561 | 0.916 | 0.930 | 0.935 | 0.950 | 0.0839 | 0.2659 | 0.2746 |
| S | Beta | 0.05 | 0.564 | 0.921 | 0.940 | 0.963 | 0.971 | 0.0137 | 0.0516 | 0.0558 |
| S | Mixed | 0.50 | 0.565 | 0.932 | 0.930 | 0.934 | 0.948 | 0.1750 | 0.5473 | 0.5768 |
| S | Beta | 0.25 | 0.589 | 0.925 | 0.938 | 0.952 | 0.962 | 0.0262 | 0.0866 | 0.0877 |
| VS | Mixed | 0.05 | 0.642 | 0.678 | — | 0.704 | 0.710 | 0.4991 | 0.6853 | 0.4696 |
| VS | Beta | 0.95 | 0.647 | 0.649 | — | 0.709 | 0.699 | 0.1583 | 0.2002 | 0.1441 |
| VS | Mixed | 0.95 | 0.671 | 0.683 | — | 0.725 | 0.722 | 0.5120 | 0.7094 | 0.4842 |
| VS | Normal | 0.05 | 0.697 | 0.698 | — | 0.739 | 0.737 | 0.2675 | 0.3514 | 0.2482 |
| VS | Normal | 0.95 | 0.704 | 0.704 | — | 0.745 | 0.749 | 0.2671 | 0.3341 | 0.2393 |
| VS | Mixed | 0.25 | 0.818 | 0.858 | — | 0.894 | 0.903 | 0.4844 | 0.5617 | 0.4693 |
| VS | Mixed | 0.75 | 0.844 | 0.865 | — | 0.902 | 0.907 | 0.4965 | 0.5658 | 0.4680 |
| VS | Mixed | 0.50 | 0.865 | 0.890 | — | 0.925 | 0.936 | 0.4923 | 0.5573 | 0.4684 |
| VS | Beta | 0.75 | 0.870 | 0.873 | — | 0.908 | 0.888 | 0.1527 | 0.1796 | 0.1314 |
| VS | Normal | 0.25 | 0.875 | 0.879 | — | 0.919 | 0.900 | 0.2704 | 0.3099 | 0.2343 |
| VS | Normal | 0.75 | 0.893 | 0.897 | — | 0.930 | 0.922 | 0.2717 | 0.3096 | 0.2342 |
| VS | Normal | 0.50 | 0.904 | 0.908 | — | 0.939 | 0.935 | 0.2702 | 0.3062 | 0.2352 |
| VS | Beta | 0.50 | 0.914 | 0.917 | — | 0.938 | 0.917 | 0.1280 | 0.1501 | 0.1113 |
| VS | Beta | 0.25 | 0.941 | 0.941 | — | 0.960 | 0.941 | 0.0965 | 0.1172 | 0.0861 |
| VS | Beta | 0.05 | 0.948 | 0.945 | — | 0.967 | 0.955 | 0.0627 | 0.0900 | 0.0603 |

| Signal | Mean coverage E-17 | E-14 | Onizuka Lap | Onizuka HS |
|---|---:|---:|---:|---:|
| VS | 0.815 | 0.826 | 0.860 | 0.855 |
| S | 0.521 | 0.829 | 0.854 | 0.871 |
