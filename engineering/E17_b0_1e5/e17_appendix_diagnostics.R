# Appendix C diagnostics (run from runs/: Rscript <this> <run dir>): median log-lambda ESS over thinned retained draws
# (trace_sweep > burn; every 30th sweep = 666 draws), acceptance range, median seconds, sigma guards. Reproduces E-14 102/132/153 s.
suppressMessages(library(coda))
args <- commandArgs(TRUE)
f <- list.files(file.path(args[1], "out"), pattern = "\\.rds$", full.names = TRUE)
r <- do.call(rbind, lapply(f, function(p) { x <- readRDS(p); k <- x$trace_sweep > x$burn
  data.frame(signal = x$signal, n = sum(k), ess = as.numeric(effectiveSize(log(x$lambda[k]))),
             acc = x$acc_post, sec = x$seconds, guard = x$n_sigma_guard) }))
for (s in c("VS", "S")) { d <- r[r$signal == s, ]
  cat(args[1], s, "runs", nrow(d), "draws", paste(range(d$n), collapse = "-"), "median logλ ESS", round(median(d$ess), 1),
      "acc", sprintf("%.5f-%.5f", min(d$acc), max(d$acc)), "median sec", round(median(d$sec), 1), "guards", sum(d$guard), "\n") }
cat("ALL acc", sprintf("%.5f-%.5f", min(r$acc), max(r$acc)), "median sec", round(median(r$sec), 1), "runs", nrow(r), "\n")
