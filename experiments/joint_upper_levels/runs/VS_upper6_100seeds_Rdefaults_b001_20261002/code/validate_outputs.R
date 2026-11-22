args <- commandArgs(trailingOnly = TRUE)
root <- normalizePath(args[1])
source(file.path(root, "code", "config.R"))
a <- read.csv(file.path(root, "summary", "average_metrics_tau096_099.csv"))
p <- read.csv(file.path(root, "summary", "per_seed_all_six_quantiles.csv"))
stopifnot(nrow(a) == 12L, nrow(p) == 36L, all(a$n_seeds == 2L))
for (i in seq_len(nrow(a))) {
  sub <- p[p$noise == a$noise[i] & p$tau == a$tau[i], ]
  for (metric in c("MSE", "MAD", "MCIW"))
    stopifnot(isTRUE(all.equal(a[[paste0("mean_", metric)]][i],
                              sum(sub[[metric]]) / 2, tolerance = 1e-12)))
}
# Independently reconstruct a worker's metrics from its preserved raw draws.
x <- readRDS(file.path(root, "tasks", "Normal", "seed_001", "summary.rds"))
raw <- readRDS(x$raw_path)
for (j in seq_along(cfg$taus)) {
  draws <- raw$fit$theta[, , j]
  truth <- raw$dat$truth[, j]
  expected <- c(mean((colMeans(draws) - truth)^2), mean(abs(colMeans(draws) - truth)),
    mean(apply(draws, 2, quantile, .975) - apply(draws, 2, quantile, .025)))
  actual <- as.numeric(x$metrics[j, c("MSE", "MAD", "MCIW")])
  stopifnot(max(abs(expected - actual)) < 1e-12)
}
cat("Verified 6 workers, 12 summary rows, arithmetic seed averages, and raw-draw metrics.\n")
