.libPaths(c("/home/fb31/Bayesian-Quantile-Trend-Filtering/ops/Rlib", .libPaths()))
ROOT <- "/home/fb31/Bayesian-Quantile-Trend-Filtering"
src <- readLines(file.path(ROOT, "method/individual/Individual_Sampler_PMALA_Augmented.R"))
i0 <- grep("^simulate_data <- function", src); i1 <- grep("^# ---- Model pieces", src) - 1
eval(parse(text = src[i0:i1]))
SCR <- "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/archive-owls-session-scratch-20261125/7aecef86-4e46-4d00-a632-302610e27229/scratchpad"
Sys.setenv(E07_CACHE = "/home/fb31/Bayesian-Quantile-Trend-Filtering/tmp/rcpp_cache")
source(file.path(ROOT, "engineering/E07_Tuning_Free/joint_gibbs/e07_joint2.R"))
e07_load2(cache = "/home/fb31/Bayesian-Quantile-Trend-Filtering/tmp/rcpp_cache")
