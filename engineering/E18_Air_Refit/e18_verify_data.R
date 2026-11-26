# Run from the repo root with Rscript --vanilla. Generates the two audit CSVs.
source("engineering/E18_Air_Refit/e18_common.R")
dest <- "engineering/E18_Air_Refit"
legacy <- "experiments/air_simulation/onizuka_laplace_20261023"
attempt <- file.path(legacy, "attempt_20261023T171713_511660")
arch <- e18_table2_archive(".")
a <- e18_air_generator(".")
b <- e18_air_generator(".", "admm_air_sim.R")
same <- function(x, y) identical(x, y, num.eq = FALSE)
stopifnot(length(arch$data) == 100L)
RNGkind("Mersenne-Twister", "Inversion", "Rejection")

audit <- do.call(rbind, lapply(1:100, function(seed) {
  indiv <- a(seed, 500L, .25)
  admm <- b(seed, 500L, .25)
  saved <- arch$data[[seed]]
  fields <- c("y", "theta", "s")
  err <- vapply(fields, function(field) {
    i <- indiv[[field]]
    x <- saved[[field]]
    stopifnot(same(i, admm[[field]]), length(i) == length(x),
      all(abs(i - x) <= 64 * .Machine$double.eps * pmax(1, abs(x))))
    max(abs(i - x))
  }, 0)
  truth_hash <- vapply(e18_taus, function(tau) {
    q <- indiv$theta + .25 * qnorm(tau)
    original <- saved$theta + .25 * qnorm(tau)
    stopifnot(all(abs(q - original) <= 64 * .Machine$double.eps * pmax(1, abs(original))))
    e18_vector_sha(original)
  }, "")
  stopifnot(identical(indiv$s > .5, saved$s > .5))
  data.frame(seed = seed, n_signal = sum(saved$s > .5),
    y_sha256 = e18_vector_sha(saved$y), baseline_sha256 = e18_vector_sha(saved$theta),
    signal_sha256 = e18_vector_sha(saved$s), q01_sha256 = truth_hash[1L],
    q05_sha256 = truth_hash[2L], q10_sha256 = truth_hash[3L],
    y_exact = same(indiv$y, saved$y), baseline_exact = same(indiv$theta, saved$theta),
    signal_exact = same(indiv$s, saved$s), y_max_error = err[["y"]],
    baseline_max_error = err[["theta"]], signal_max_error = err[["s"]])
}))
common_sha <- "b12396de72540d518cf92ed279ae765236774bad349ea1d3086d76efb1ad21ac"
stopifnot(any(arch$source_sha256 == paste0(common_sha, "  ./Driver/common_air.R")))

oct8 <- read.csv(file.path(legacy, "oct8_partial", "summary.csv"))
oct23 <- read.csv(file.path(attempt, "summary.csv"))
orig <- rbind(oct8, oct23)
methods <- c("pmala", "onizuka_hs", "onizuka_lap", "admm")
metrics <- c("MSE", "CL", paste0("CAA_", e18_h))
pt <- arch$per_task
stopifnot(nrow(pt) == 300L, length(arch$est) == nrow(pt))
for (i in seq_len(nrow(pt))) {
  d <- arch$data[[pt$seed[i]]]
  est <- arch$est[[i]]
  q <- d$theta + .25 * qnorm(pt$tau[i])
  got <- e18_metrics(d$y, est, q, d$s, pt$tau[i])[metrics]
  stopifnot(isTRUE(all.equal(unname(got), as.numeric(pt[i, metrics]), tolerance = 1e-12)))
}
tex <- readLines("paper/sections/air_simulation.tex")
tex <- grep("^0[.](01|05|10) & ", tex, value = TRUE)
stopifnot(length(tex) == 12L)
table <- do.call(rbind, strsplit(sub(" +\\\\.*$", "", tex), " & ", fixed = TRUE))
selected <- do.call(rbind, lapply(e18_taus, function(tau) {
  x <- orig[orig$tau == tau & orig$method %in% methods, ]
  stopifnot(nrow(x) == 4L, !anyDuplicated(x$method))
  x[match(methods, x$method), ]
}))
stopifnot(all(selected$tau == as.numeric(table[, 1L])),
  all(startsWith(table[, 2L], rep(c("Bayesian-PMALA", "Onizuka (HS)", "Onizuka (Laplace)", "ADMM"), 3L))),
  all(selected$n_seeds == ifelse(selected$tau == .05 & selected$method == "admm", 99L, 100L)))
for (j in seq_along(metrics)) {
  col <- paste0("mean_", metrics[j])
  digits <- c(4L, 5L, rep(3L, 4))[j]
  rounded <- formatC(selected[[col]], format = "f", digits = digits)
  stopifnot(all(rounded == table[, j + 2L]))
  lap_means <- vapply(e18_taus, function(tau) {
    d <- pt[pt$tau == tau, ]
    stopifnot(identical(sort(d$seed), 1:100))
    mean(d[[metrics[j]]], na.rm = TRUE)
  }, 0)
  stopifnot(all(formatC(lap_means, format = "f", digits = digits) ==
    table[selected$method == "onizuka_lap", j + 2L]))
}
stopifnot(sum(audit$n_signal > 0L) == 91L,
  all(selected$n_CAA_defined[selected$method != "admm"] == 91L))
cols <- c("method", "tau", "n_seeds", "n_CAA_defined",
          as.vector(rbind(paste0("mean_", metrics), paste0("se_", metrics))))
write.csv(audit, file.path(dest, "table2_data_sha256.csv"), row.names = FALSE)
write.csv(selected[cols], file.path(dest, "published_stage1.csv"), row.names = FALSE)
print(colSums(audit[c("y_exact", "baseline_exact", "signal_exact")]))
print(vapply(audit[c("y_max_error", "baseline_max_error", "signal_max_error")], max, 0))
cat("Both drivers agree bitwise on all 100 seeds. Archived Laplace metrics: 300/300 rows.",
  "\nLaplace per-replication values independently reconstruct all 18 of its printed means.",
  "\nTable 2: 72/72 printed entries match archived summaries.",
  "\nArchive SHA-256:", e18_archive_sha, "\nShared October generator SHA-256:", common_sha, "\n")
