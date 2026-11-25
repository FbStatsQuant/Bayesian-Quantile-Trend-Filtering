ROOT <- local({ f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)); d <- if (length(f)) dirname(normalizePath(f[1])) else getwd(); r <- tryCatch(system2("git", c("-C", shQuote(d), "rev-parse", "--show-toplevel"), stdout = TRUE, stderr = FALSE), error = function(e) character(0)); if (!length(r) || !nzchar(r[1])) stop("E07: cannot find the repo root; run from inside the checkout"); r[1] })   # E-12: repo root (Owls or NOTS), no absolute paths
source(file.path(ROOT, "engineering/E07_Tuning_Free/joint/smoke_scripts/common.R"))   # E-12: tracked twin of the archived scratchpad common.R (differs only in the R-library and Rcpp-cache lines)
taus <- c(0.90, 0.93)
dat <- e_new$simulate_data(1, 200L, taus, "VS", "Normal")
iter <- 260L; burn <- 220L    # warm = 200, so 60 post-warm exact-kernel sweeps
fo <- run(e_old, dat$y, taus, iter, burn, 1001)
fn <- run(e_new, dat$y, taus, iter, burn, 1001, lamjump = FALSE)
cat("identical theta:", identical(fo$theta, fn$theta), " max|diff|:", max(abs(fo$theta - fn$theta)), "\n")
cat("identical lambda/sigma/delta:", identical(fo$lambda, fn$lambda), identical(fo$sigma, fn$sigma), identical(fo$delta, fn$delta), "\n")
cat("old acc_post:", fo$acc_post, " outside:", fo$outside_post, "\n")
# sanity: lamjump = TRUE runs and differs
ft <- run(e_new, dat$y, taus, iter, burn, 1001, lamjump = TRUE)
cat("lamjump TRUE differs:", !identical(ft$theta, fn$theta), " acc_lamjump:", ft$acc_lamjump, " outside:", ft$lj_outside_post, "\n")
