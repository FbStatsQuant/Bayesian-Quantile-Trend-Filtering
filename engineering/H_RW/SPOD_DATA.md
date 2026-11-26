# Rubbertown Site S8 SPod data

`spod_s08_d_2018-06-15_10s.csv` contains the 8,640 ten-second blocks used for the June 15, 2018 analysis of sensor d. Columns give the offset in seconds from source-clock midnight, number of observed readings, imputation flag (1 for an empty block), PID mean in counts, and standardized PID mean. Preparation drops 30 literal N/A readings, excludes four June 16 readings, and interpolates 19 empty blocks. Standardization uses the series mean and sample standard deviation.

The observations come from EPA Rubbertown SPod sensor d on June 15, 2018. See Brantley, H. L., Guinness, J., and Chi, E. C. (2020), “Baseline drift estimation for air quality data using quantile trend filtering,” Annals of Applied Statistics, 14(2), 585–604. The raw export is held separately.

From the repository root, place the original `S08_2018-06-15.csv` in `applications/Air Quality/` and run:

```sh
Rscript --vanilla engineering/E18_Air_Refit/e18_prepare_spod.R /tmp/spod_blocks.rds
Rscript --vanilla engineering/H_RW/export_spod.R /tmp/spod_blocks.rds /tmp/spod_blocks.csv
```

| Artifact | SHA-256 |
| --- | --- |
| Original June 15 file | `6086e8bdc1260cb90ca9250262aa7fc612a5e6e2d91490b7696f3e44f95cd7c3` |
| Prepared RDS | `7034864ae177b222d19d2df68347d1112f5491703fbeb5636adff05a07b76261` |
| Released CSV | `45e04964b2ea51b49c244e7b4778652300435cd2dd035a9be0d4cc73793ee2a0` |
