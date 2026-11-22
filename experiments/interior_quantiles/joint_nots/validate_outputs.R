args <- commandArgs(trailingOnly = TRUE)
root <- normalizePath(args[1])
source(file.path(root, "code", "config.R")); source(file.path(root, "code", "common.R"))
a <- read.csv(file.path(root, "summary", "average_metrics_targets.csv"))
p <- read.csv(file.path(root, "summary", "per_seed_all_taus.csv"))
cmp <- read.csv(file.path(root, "summary", "comparison_paper_interior.csv"))
n_levels <- sum(lengths(lapply(cfg$batches, `[[`, "taus")))
stopifnot(nrow(a) == 30L, all(a$n_seeds == 2L), nrow(p) == 2L * 3L * 2L * n_levels,
          nrow(cmp) == 90L, all(is.finite(cmp$joint)), all(is.finite(cmp$paper_PMALA)))
for (i in seq_len(nrow(a))) {
  sub <- p[p$baseline == a$baseline[i] & p$noise == a$noise[i] & p$tau == a$tau[i], ]
  stopifnot(nrow(sub) == 2L, all(sub$batch == a$batch[i]))
  for (metric in c("MSE", "MAD", "MCIW"))
    stopifnot(isTRUE(all.equal(a[[paste0("mean_", metric)]][i], sum(sub[[metric]]) / 2, tolerance = 1e-12)))
}
# Each target level is reported from the batch that owns it.
owner <- setNames(names(cfg$batches), vapply(cfg$batches, function(z) as.character(z$targets), ""))
stopifnot(all(a$batch == owner[as.character(a$tau)]))
# Raw files: thinned theta, full traces, and the same data for every batch of a seed.
ys <- list()
for (batch in names(cfg$batches)) {
  x <- readRDS(file.path(task_dir(root, "S", "Beta", batch, 2L), "summary.rds"))
  raw <- readRDS(x$raw_path)
  kept <- cfg$sampler$gibbs_iter - cfg$sampler$gibbs_burn
  idx <- seq(1L, kept, by = cfg$raw_keep_every)
  stopifnot(identical(raw$fit$theta_thin_index, idx),
            all(dim(raw$fit$theta) == c(length(idx), cfg$n, length(cfg$batches[[batch]]$taus))),
            nrow(raw$fit$lambda) == cfg$sampler$gibbs_iter,
            all(raw$fit$theta[, , -1] - raw$fit$theta[, , -dim(raw$fit$theta)[3]] >= 0))
  ys[[batch]] <- raw$dat$y
}
stopifnot(all(vapply(ys, identical, logical(1), ys[[1]])))
cat("Verified", nrow(task_grid(cfg)), "workers, 30 target averages, 90 paper comparisons, batch ownership, thinning and shared data.\n")
