# =============================================================================
# Independent checks of Growth_Joint_PMALA_k2.R (repeated-observation adaptation of the joint non-crossing P-MALA sampler).
# Usage:  Rscript Growth_Joint_checks.R        (from any folder; single-seed, local, ~minutes)
#   G1 data loader            G2 per-slot aggregation (agg_ar)        G3/G4 bitwise parity with the original joint sampler
#   G5 box kernel vs grid integration with repeated observations       G6 smoke run on the real data (boys, J = 5)
# The code under test is source()d into its own environment (main block skipped); the original
# Simulations/Joint/Joint_Sampler_PMALA_Augmented.R is parsed and only its function definitions (plus %||% and box_ctrl)
# are evaluated into a second environment.  Both see the compiled kernels, which load_box_cpp puts in globalenv.
# =============================================================================
t_start <- proc.time()[["elapsed"]]
.this <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
growth_dir <- if (!is.na(.this)) normalizePath(dirname(.this), winslash = "/") else
  normalizePath("C:/Users/felip/OneDrive/Documents/Quantile Regression/Data Applications/Growth", winslash = "/")
new_file  <- file.path(growth_dir, "Growth_Joint_PMALA_k2.R")
orig_file <- file.path(dirname(dirname(growth_dir)), "Simulations", "Joint", "Joint_Sampler_PMALA_Augmented.R")
stopifnot(file.exists(new_file), file.exists(orig_file))

# ---- code under test (main block guarded by sys.nframe() == 0L) -----------------------------------------------------------
NEW <- new.env(parent = globalenv())
sys.source(new_file, envir = NEW)          # sys.source: nframe > 0, so the main block is skipped
cat(sprintf("kernels loaded via %s\n", with(NEW, load_box_cpp(joint_dir, ind_dir))))
stopifnot(exists("pmala_box_move", envir = globalenv()), exists("prox_admm_metric", envir = globalenv()))

# ---- original: function definitions only ---------------------------------------------------------------------------------
ORIG <- new.env(parent = globalenv())
for (e in parse(orig_file, keep.source = FALSE)) {
  if (!is.call(e) || !(identical(e[[1]], as.name("<-")) || identical(e[[1]], as.name("=")))) next
  lhs <- deparse(e[[2]]); rhs <- e[[3]]
  is_fun <- is.call(rhs) && identical(rhs[[1]], as.name("function"))
  if (is_fun || lhs %in% c("`%||%`", "%||%", "box_ctrl")) eval(e, ORIG)
}
stopifnot(is.function(ORIG$gibbs_joint_pmala), !is.null(ORIG$box_ctrl), identical(ORIG$box_ctrl, NEW$box_ctrl))

res <- character(0)
report <- function(id, ok, msg) {
  line <- sprintf("%s %s | %s", id, if (isTRUE(ok)) "PASS" else "FAIL", msg); cat(line, "\n"); res <<- c(res, line)
  ok
}
# shared sampler settings (the scripts' saved values)
S <- list(order = 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1, delta_init = 0.2, lambda_init = NULL,
          adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), metric = "curv", c_fixed = 1e4,
          rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, gamma_warm = 1e4, kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE,
          tol = 0, zeta_scale = 1, verbose = FALSE)

# =========================================================================================================================
# G1 data.  Expected counts from the brief; exact integer checks (no tolerance needed).
# =========================================================================================================================
g1 <- tryCatch({
  raw <- read.csv(file.path(growth_dir, "data", "fdgs.csv"))
  out <- c(); ok <- TRUE
  for (sx in c("boy", "girl")) {
    d <- NEW$load_growth(growth_dir, sx)
    rr <- raw[raw$sex == sx & !is.na(raw$hgt), ]; s_raw <- round(10 * rr$age)
    o <- order(s_raw)                                                       # stable: my own expected ordering
    N <- length(d$y); n <- length(d$x)
    ok_s <- N == c(boy = 4817L, girl = 5190L)[[sx]] && n == c(boy = 220L, girl = 221L)[[sx]] &&
      length(d$g) == N && max(d$g) == n && all(tabulate(d$g, n) > 0) &&
      isTRUE(all.equal(diff(d$x), rep(0.1, n - 1), tolerance = 1e-12)) &&     # consecutive 0.1-year slots
      all(round(10 * d$x) - round(10 * d$x[1]) == 0:(n - 1)) &&
      all(round(10 * d$x[d$g]) == round(10 * d$age)) &&                     # g consistent with round(10 * age)
      all(round(10 * d$age) == s_raw[o]) && identical(d$y, rr$hgt[o]) &&    # same children, sorted by slot
      !is.unsorted(d$g)
    ok <- ok && ok_s
    out <- c(out, sprintf("%s N=%d n=%d slots %.1f-%.1f y, kids/slot %d-%d", sx, N, n, min(d$x), max(d$x), min(tabulate(d$g)), max(tabulate(d$g))))
  }
  report("G1", ok, paste(out, collapse = "; "))
}, error = function(e) report("G1", FALSE, conditionMessage(e)))

# =========================================================================================================================
# G2 aggregation.  Relative tolerance 1e-9: the per-child and per-slot sums differ only by double round-off
# (~1e-15 relative per term, a few hundred terms), so 1e-9 leaves six orders of margin while catching any algebra error.
# =========================================================================================================================
g2 <- tryCatch({
  set.seed(11)
  ok <- TRUE; worst_c <- 0; worst_ar <- 0
  for (rep_ in 1:5) {
    n <- 30; Nc <- 200; tau <- runif(1, 0.05, 0.95); cst <- NEW$ald_const(tau); sigma <- rexp(1) + 0.1
    g <- sample(c(1:n, sample(n, Nc - n, replace = TRUE)))                   # every slot used, repeated, UNSORTED
    y <- rnorm(Nc, 5, 2); z <- rexp(Nc) + 1e-3
    ar <- NEW$agg_ar(y, z, sigma, cst, g, n)
    a_i <- 1 / (cst$t2 * sigma * z); r_i <- y - cst$psi * z
    A <- sapply(1:n, function(s) sum(a_i[g == s])); R <- sapply(1:n, function(s) sum(a_i[g == s] * r_i[g == s]) / A[s])
    worst_ar <- max(worst_ar, max(abs(ar$a - A) / A), max(abs(ar$r - R) / pmax(abs(R), 1)))
    cs <- sapply(1:6, function(k) {
      th <- rnorm(n, 5, 3)
      per_child <- sum(a_i / 2 * (th[g] - r_i)^2); agg <- sum(ar$a / 2 * (th - ar$r)^2)
      c(per_child - agg, per_child)
    })
    worst_c <- max(worst_c, max(abs(cs[1, ] - cs[1, 1])) / max(abs(cs[2, ])))
  }
  # singletons: exactly (a_i, r_i), in slot order g = 1..n and under a permutation
  n <- 50; y <- rnorm(n); z <- rexp(n); cst <- NEW$ald_const(0.3); sigma <- 0.7
  a_i <- 1 / (cst$t2 * sigma * z); r_i <- y - cst$psi * z
  ar1 <- NEW$agg_ar(y, z, sigma, cst, 1:n, n); p <- sample(n); ar2 <- NEW$agg_ar(y, z, sigma, cst, p, n)
  ident <- identical(ar1$a, a_i) && identical(ar1$r, r_i) && identical(ar2$a[p], a_i) && identical(ar2$r[p], r_i)
  ok <- worst_c < 1e-9 && worst_ar < 1e-9 && ident
  report("G2", ok, sprintf("const-diff rel %.1e (tol 1e-9); A,R vs own rel %.1e (tol 1e-9); singleton identical() %s",
                           worst_c, worst_ar, ident))
}, error = function(e) report("G2", FALSE, conditionMessage(e)))

# =========================================================================================================================
# G3 / G4 parity with the original (singletons, g = 1..n): bitwise identity of every chain and of the final RNG state.
# =========================================================================================================================
run_pair <- function(y, tau_list, iter, burn, warm, init_scale) {
  args <- c(list(tau_list = tau_list, gibbs_iter = iter, gibbs_burn = burn, warm = warm), S)
  set.seed(424242); t0 <- proc.time()[["elapsed"]]
  fo <- do.call(ORIG$gibbs_joint_pmala, c(list(y = y), args)); rs_o <- .Random.seed; to <- proc.time()[["elapsed"]] - t0
  set.seed(424242); t0 <- proc.time()[["elapsed"]]
  fn <- do.call(NEW$gibbs_joint_pmala, c(list(y = y, g = seq_along(y), init_scale = init_scale), args)); rs_n <- .Random.seed
  tn <- proc.time()[["elapsed"]] - t0
  drop <- function(f) f[setdiff(names(f), "seconds")]
  list(fo = fo, fn = fn, theta = identical(fo$theta, fn$theta), lambda = identical(fo$lambda, fn$lambda),
       sigma = identical(fo$sigma, fn$sigma), rng = identical(rs_o, rs_n), all = identical(drop(fo), drop(fn)), to = to, tn = tn)
}
sim_y <- function(n, seed) {          # VS baseline + heteroscedastic normal noise (the original's generator, re-written here)
  set.seed(seed); x <- seq_len(n) / n
  2 + sin(4 * x - 2) + 2 * exp(-30 * (4 * x - 2)^2) + rnorm(n, 0, (1 + x^2) / 4)
}
g3 <- tryCatch({
  y <- sim_y(80, 3)
  P <- run_pair(y, 0.1, 400L, 200L, 30L, NULL)
  ok <- P$theta && P$lambda && P$sigma && P$rng && P$all
  report("G3", ok, sprintf("J=1 n=80: identical theta %s lambda %s sigma %s RNG %s full-output %s | acc %.2f | %.1fs/%.1fs",
                           P$theta, P$lambda, P$sigma, P$rng, P$all, P$fn$acc_post, P$to, P$tn))
}, error = function(e) report("G3", FALSE, conditionMessage(e)))

g4 <- tryCatch({
  y <- sim_y(80, 4)
  P <- run_pair(y, c(0.5, 0.9, 0.95), 600L, 300L, 30L, sd(y))
  ipm_share <- colMeans(P$fn$ipm[301:600, , drop = FALSE] > 0, na.rm = TRUE)
  ok <- P$theta && P$lambda && P$sigma && P$rng && P$all
  report("G4", ok, sprintf("J=3 n=80: identical theta %s lambda %s sigma %s RNG %s full-output %s | outside %s | IPM share %s | %.1fs/%.1fs",
                           P$theta, P$lambda, P$sigma, P$rng, P$all, paste(sprintf("%.3f", P$fn$outside_post), collapse = "/"),
                           paste(sprintf("%.3f", ipm_share), collapse = "/"), P$to, P$tn))
}, error = function(e) report("G4", FALSE, conditionMessage(e)))

# =========================================================================================================================
# G5 box kernel with repeated observations vs grid integration of exp(-U) 1_B, U summed over CHILDREN (no agg_ar / U_cond).
# n = 4 slots, k = 0 (D = first differences), 10 children unevenly spread and unsorted.  Fixed z, sigma, lambda, tau.
# Two boxes.  Tolerance: |z| < 4 for 16 statistics (2 x (4 means, 4 variances)) with batch-means SEs; the family-wise
# false-alarm rate under a correct sampler is ~ 16 * 6e-5 = 1e-3.  Grid: 50 midpoint cells per coordinate over the box itself (the target is 0 outside);
# midpoint error ~ h^2/24 relative to sd^2 with h ~ 0.07 sd, i.e. ~2e-4 sd, far below the MC SEs (~1e-2 sd).
# =========================================================================================================================
g5 <- tryCatch({
  set.seed(55)
  n <- 4L; k <- 0L; tau <- 0.3; cst <- NEW$ald_const(tau); sigma <- 0.4; lambda <- 1.5
  g <- c(3, 1, 4, 1, 1, 4, 2, 4, 1, 3)                                   # slot counts 4 / 1 / 2 / 3
  y <- c(1.0, 0.2, 2.5, -0.3, 0.6, 1.8, 0.9, 2.9, 0.1, 1.2) ; z <- rexp(10) + 0.2
  a_i <- 1 / (cst$t2 * sigma * z); r_i <- y - cst$psi * z
  A_own <- sapply(1:n, function(s) sum(a_i[g == s])); R_own <- sapply(1:n, function(s) sum(a_i[g == s] * r_i[g == s]) / A_own[s])
  sdv <- 1 / sqrt(A_own)
  one_box <- function(lo_m, up_m, seed) {
    set.seed(seed)
    lower <- R_own + lo_m * sdv; upper <- R_own + up_m * sdv
    # grid
    H <- 50L; cells <- lapply(1:n, function(s) lower[s] + (seq_len(H) - 0.5) * (upper[s] - lower[s]) / H)
    T <- list(rep(cells[[1]], times = H^3), rep(rep(cells[[2]], each = H), times = H^2),
              rep(rep(cells[[3]], each = H^2), times = H), rep(cells[[4]], each = H^3))
    U <- lambda * (abs(T[[2]] - T[[1]]) + abs(T[[3]] - T[[2]]) + abs(T[[4]] - T[[3]]))
    for (i in seq_along(y)) U <- U + a_i[i] / 2 * (T[[g[i]]] - r_i[i])^2      # per CHILD
    w <- exp(-(U - min(U))); w <- w / sum(w); rm(U)
    mu_g <- sapply(1:n, function(s) sum(w * T[[s]])); var_g <- sapply(1:n, function(s) sum(w * (T[[s]] - mu_g[s])^2))
    rm(T, w); invisible(gc())
    # sampler: tune delta (RM, discarded), then freeze it
    th <- (lower + upper) / 2; delta <- 1; step <- function(th, delta)
      NEW$pmala_box_step(th, y, z, lambda, sigma, delta, cst, k, g, lower, upper, metric = "curv", kappa = 3, iters = 150L)
    for (it in 1:3000) { st <- step(th, delta); th <- st$theta
      delta <- min(max(exp(log(delta) + it^(-0.6) * (exp(st$log_alpha) - 0.5)), 1e-6), 100) }
    for (it in 1:1000) th <- step(th, delta)$theta
    M <- 50000L; X <- matrix(NA_real_, M, n); acc <- out <- ipm <- logical(M)
    for (it in 1:M) { st <- step(th, delta); th <- st$theta; X[it, ] <- th; acc[it] <- st$accept; out[it] <- st$outside
      ipm[it] <- isTRUE(st$ipm > 0) }
    inside <- all(sweep(X, 2, lower, ">=") & sweep(X, 2, upper, "<="))
    B <- 50L; bid <- rep(seq_len(B), each = M / B)
    bm <- function(v) { m <- tapply(v, bid, mean); sd(m) / sqrt(B) }
    zs_mean <- sapply(1:n, function(s) (mean(X[, s]) - mu_g[s]) / bm(X[, s]))
    zs_var  <- sapply(1:n, function(s) { v <- (X[, s] - mu_g[s])^2; (mean(v) - var_g[s]) / bm(v) })
    list(ok = inside && all(abs(c(zs_mean, zs_var)) < 4),
         msg = sprintf("mean grid %s mc %s z %s; sd grid %s mc %s z(var) %s; inside %s acc %.2f out %.3f IPM %.3f",
      paste(sprintf("%.3f", mu_g), collapse = "/"), paste(sprintf("%.3f", colMeans(X)), collapse = "/"), paste(sprintf("%.1f", zs_mean), collapse = "/"),
      paste(sprintf("%.3f", sqrt(var_g)), collapse = "/"), paste(sprintf("%.3f", apply(X, 2, sd)), collapse = "/"), paste(sprintf("%.1f", zs_var), collapse = "/"),
      inside, mean(acc), mean(out), mean(ipm)))
  }
  # box A cuts the bulk on every coordinate; box B excludes the unconstrained centre on slots 1 and 2 (forces the IPM path)
  bA <- one_box(-c(0.4, 2.5, 0.3, 2.5), c(2.5, 0.5, 2.5, 0.3), 551)
  bB <- one_box(c(-2.5, 0.3, -1, -0.5), c(-0.2, 2.8, 1, 2), 552)
  report("G5", bA$ok && bB$ok, sprintf("[A] %s || [B] %s", bA$msg, bB$msg))
}, error = function(e) report("G5", FALSE, conditionMessage(e)))

# =========================================================================================================================
# G6 smoke on the real data (boys, J = 5).  Ordering is checked with <= (the box is closed; ties are not crossings).
# Coverage tolerance 0.03: with N = 4817 the binomial sd of a fraction at tau = 0.5 is 0.007, and the posterior-mean curve of
# a 600-sweep run is itself smoothed/shrunk, so 0.03 (the brief's value) allows ~4 sd plus smoothing bias.
# =========================================================================================================================
g6 <- tryCatch({
  d <- NEW$load_growth(growth_dir, "boy"); tl <- c(0.1, 0.3, 0.5, 0.7, 0.9)
  set.seed(2027); t0 <- proc.time()[["elapsed"]]
  args <- c(list(y = d$y, g = d$g, tau_list = tl, gibbs_iter = 600L, gibbs_burn = 300L, warm = 200L), S)
  fit <- do.call(NEW$gibbs_joint_pmala, args); el <- proc.time()[["elapsed"]] - t0
  dr <- fit$theta; kept <- dim(dr)[1]
  viol <- max(sapply(1:4, function(j) max(dr[, , j] - dr[, , j + 1])))     # > 0 means a crossing in some draw
  n_cross_draws <- sum(apply(dr, 1, function(m) any(diff(t(m)) < 0)))
  est <- apply(dr, c(2, 3), mean); fb <- colMeans(d$y < est[d$g, , drop = FALSE])
  ok <- all(is.finite(dr)) && kept == 300 && viol <= 0 && n_cross_draws == 0 && all(abs(fb - tl) < 0.03)
  report("G6", ok, sprintf("boys J=5: %d kept draws, draws with a crossing %d (max violation %.2e) | frac below %s (|dev| max %.3f, tol 0.03) | acc %s | out %s | %.0fs",
    kept, n_cross_draws, viol, paste(sprintf("%.3f", fb), collapse = "/"), max(abs(fb - tl)),
    paste(sprintf("%.2f", fit$acc_post), collapse = "/"), paste(sprintf("%.2f", fit$outside_post), collapse = "/"), el))
}, error = function(e) report("G6", FALSE, conditionMessage(e)))

cat(sprintf("\n%d/%d checks passed | total %.0f s\n", sum(grepl(" PASS ", res)), length(res), proc.time()[["elapsed"]] - t_start))
stopifnot(isTRUE(g1), isTRUE(g2), isTRUE(g3), isTRUE(g4), isTRUE(g5), isTRUE(g6))
