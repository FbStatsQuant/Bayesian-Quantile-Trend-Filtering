.libPaths(c("/home/fb31/R/e02lib", .libPaths()))
ROOT <- "/home/fb31/Bayesian-Quantile-Trend-Filtering"
src <- readLines(file.path(ROOT, "method/individual/Individual_Sampler_PMALA_Augmented.R"))
i0 <- grep("^simulate_data <- function", src); i1 <- grep("^# ---- Model pieces", src) - 1
eval(parse(text = src[i0:i1]))
SCR <- "/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/12592220-6c98-4d66-a1f5-aba8b81d5bdd/scratchpad"
Sys.setenv(E07_CACHE = file.path(SCR, "cache"))
source(file.path(ROOT, "engineering/E07_Tuning_Free/joint_gibbs/e07_joint_v3.R"))
e07v3_load(cache = file.path(SCR, "cache"))
