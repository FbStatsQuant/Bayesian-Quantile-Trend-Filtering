ROOT <- local({ f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)); d <- if (length(f)) dirname(normalizePath(f[1])) else getwd(); r <- tryCatch(system2("git", c("-C", shQuote(d), "rev-parse", "--show-toplevel"), stdout = TRUE, stderr = FALSE), error = function(e) character(0)); if (!length(r) || !nzchar(r[1])) stop("E07: cannot find the repo root; run from inside the checkout"); r[1] })   # E-12: repo root (Owls or NOTS), no absolute paths
source(file.path(ROOT, "engineering/E07_Tuning_Free/joint_gibbs/validate/common.R"))   # sets SCR = ROOT/runs/E07-outputs
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99); n <- 500
ds <- lapply(taus, function(t) simulate_data(1, n, t, "VS", "Normal")); y <- ds[[1]]$y
fj <- bqtf_joint(y, taus, 1, 0.01, 0.1, 0.1, 3000, 1000, chains = 2, K_try = 5, seed = 1, verbose = TRUE)
post <- 1001:3000
tab <- data.frame(tau = taus,
  pCN_acc = rowMeans(fj$acc_pcn), coll_acc = rowMeans(fj$acc_collapsed), r_pcn = rowMeans(fj$r_pcn),
  lam_med = sapply(seq_along(taus), function(j) median(fj$lambda[post, j, ])),
  sig_med = sapply(seq_along(taus), function(j) median(fj$sigma[post, j, ])),
  MSE = sapply(seq_along(taus), function(j) mean((fj$levels[[j]]$mean - ds[[j]]$truth)^2)),
  Rhat_loglam = sapply(seq_along(taus), function(j) posterior::rhat(log(fj$lambda[post, j, ]))),
  ESS_loglam = sapply(seq_along(taus), function(j) posterior::ess_bulk(log(fj$lambda[post, j, ]))))
print(tab, digits = 4)
cat(sprintf("total crossings over all sweeps/chains: %d; sec/sweep per chain: %s\n", sum(fj$crossings), paste(round(fj$sec_per_sweep, 4), collapse = " ")))
cat("mean-curve ordering violations:", sum(sapply(1:(length(taus)-1), function(j) sum(fj$levels[[j]]$mean > fj$levels[[j+1]]$mean))), "\n")
saveRDS(list(fj = fj, tab = tab), file.path(SCR, "val_b.rds"))
