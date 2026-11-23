# V0T (Theory spec, INTERNAL; BUILD ONLY until Astra's audit + HQ cost OK). Felipe's ORIGINAL sampler, paper priors/settings, plus a fixed
# lambda floor lambda >= kappa_minus n^{5/2}, kappa_minus = 1.6e-5 (truncated conjugate draw + floored ASIS slice; floor 0 reproduces the
# original exactly: identity check passed). Arms on the same data/seeds:
#   C   = his method (floor 0);  V0T = with the floor;  C2x = his method at 2x sweeps on S (mixing diagnostic, not a candidate)
# V_PHASE = "ind":   VS, S x Normal, Beta, Mixed x tau {0.05, 0.5, 0.95} x n (V_N, default "2000,4000") x seeds (V_SEEDS, default 1:3)
# V_PHASE = "joint": his joint non-crossing sampler (floor 0) vs V0T joint, VS (the paper's joint design), levels 0.90..0.99, n = 2000,
#                    seed 1 per noise, J_SWEEPS sweeps (default 30000; burn = J_SWEEPS / 3)
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "v0t"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
PH <- Sys.getenv("V_PHASE", "ind"); KM <- 1.6e-5
ld <- function(f, joint = FALSE) { pl <- readLines(file.path(E07, f)); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]; E <- new.env(parent = globalenv())
  local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", file.path(E02, if (joint) "Joint_Sampler_PMALA_Augmented.R" else "Individual_Sampler_PMALA_Augmented.R"))) }, envir = E)
  eval(parse(text = pl), envir = E); E }
paper_cfg <- function(bl) if (bl == "VS") list(b0 = 1e-3, asis = TRUE, it = 30000L, burn = 10000L) else list(b0 = 5e-4, asis = FALSE, it = 20000L, burn = 5000L)
sig0n <- function(noise, tau, n) { u <- seq_len(n) / n                       # n^-1 sum_i E rho_tau(eps_i - q_i), exact per design point
  if (noise == "Normal") return(mean((1 + u^2) / 4) * dnorm(qnorm(tau)))
  ug <- seq(min(u), 1, length.out = 120)
  er <- sapply(ug, function(x) { if (noise == "Beta") { b <- 11 - 10 * x; q <- qbeta(tau, 1, b); integrate(function(e) (e - q) * (tau - (e < q)) * dbeta(e, 1, b), 0, 1, rel.tol = 1e-9)$value }
    else { cdf <- function(t) x * pnorm(t, -.2, sqrt(.5)) + (1 - x) * pnorm(t, .2, sqrt(.5)); q <- uniroot(function(t) cdf(t) - tau, c(-10, 10), tol = 1e-12)$root
           integrate(function(e) (e - q) * (tau - (e < q)) * (x * dnorm(e, -.2, sqrt(.5)) + (1 - x) * dnorm(e, .2, sqrt(.5))), -Inf, Inf, rel.tol = 1e-9)$value } })
  mean(approx(ug, er, u, rule = 2)$y) }
if (PH == "ind") {
  P <- ld("Individual_Sampler_PMALA_Augmented_V0T.R"); P$load_prox_cpp(file.path(E02, "prox_admm_metric.cpp"))
  NS <- as.integer(strsplit(Sys.getenv("V_N", "2000,4000"), ",")[[1]]); SEEDS <- eval(parse(text = Sys.getenv("V_SEEDS", "1:3")))
  CH <- seq_len(as.integer(Sys.getenv("V_CHAINS", "1")))
  g <- function(arm, bl) expand.grid(arm = arm, n = NS, bl = bl, noise = c("Normal", "Beta", "Mixed"), tau = c(0.05, 0.5, 0.95), seed = SEEDS, chain = CH, stringsAsFactors = FALSE)
  tasks <- rbind(g(c("C", "V0T"), c("VS", "S")), g("C2x", "S"))
  if (nzchar(Sys.getenv("V_CELLS"))) { keep <- strsplit(Sys.getenv("V_CELLS"), ",")[[1]]                 # e.g. "VS:Mixed:0.95,S:Beta:0.95"
    tasks <- tasks[paste(tasks$bl, tasks$noise, tasks$tau, sep = ":") %in% keep, ] }
  tasks$file <- file.path(OUT, sprintf("%s_n%05d_%s_%s_t%03d_s%d_c%d.rds", tasks$arm, tasks$n, tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$seed, tasks$chain))
  tasks <- tasks[!file.exists(tasks$file), ]; tasks <- tasks[order(-tasks$n, tasks$arm != "C2x", tasks$bl != "VS"), ]
  K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
  if (K > 1) tasks <- tasks[(seq_len(nrow(tasks)) - 1L) %% K == (k %% K), ]
  cat(sprintf("[%s] V0T ind: %d tasks here\n", format(Sys.time()), nrow(tasks)))
  res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]
    r <- tryCatch({
      d <- P$simulate_data(tk$seed, tk$n, tk$tau, tk$bl, tk$noise); pc <- paper_cfg(tk$bl); fl <- if (tk$arm == "V0T") KM * tk$n^2.5 else 0
      if (tk$arm == "C2x") { pc$it <- 2L * pc$it; pc$burn <- 2L * pc$burn }
      options(bqtf.metric_cap = 1e8, bqtf.lambda_floor = fl); set.seed(tk$seed + 1000L + 500L * (tk$chain - 1L))
      fit <- P$gibbs_pmala_aug(d$y, tk$tau, 2L, a0 = 1, b0 = pc$b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = pc$it, gibbs_burn = pc$burn,
               delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
               control = P$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
               warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = pc$asis, tol = 0, lamjump = FALSE, verbose = FALSE)
      post <- (pc$burn + 1):pc$it; TH <- fit$theta; lam <- fit$lambda[post]; sig <- fit$sigma[post]
      est <- colMeans(TH); lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
      row <- data.frame(tk[1:7], floor = fl, sweeps = pc$it, seconds = fit$seconds, lam_med = median(lam), frac_at_floor = if (fl > 0) mean(lam < 1.001 * fl) else NA,
                        sig_s0 = median(sig) / sig0n(tk$noise, tk$tau, tk$n), ess_loglam = as.numeric(coda::effectiveSize(log(lam))),
                        mse = mean((est - d$truth)^2), mciw = mean(hi - lo), cover = mean(d$truth >= lo & d$truth <= hi), stringsAsFactors = FALSE)
      saveRDS(list(row = row, lam_trace = fit$lambda[seq(1, pc$it, by = 10)]), tk$file); "ok"
    }, error = function(e) paste("ERROR", conditionMessage(e)))
    if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
  }, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
  cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
} else {
  J <- ld("Joint_Sampler_PMALA_Augmented_V0T.R", joint = TRUE); J$load_box_cpp(E02, E02)
  taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99); n <- 2000L; JS <- as.integer(Sys.getenv("J_SWEEPS", "30000"))
  tasks <- expand.grid(arm = c("C", "V0T"), noise = strsplit(Sys.getenv("J_NOISES", "Normal,Beta,Mixed"), ",")[[1]], stringsAsFactors = FALSE)
  tasks$file <- file.path(OUT, sprintf("joint_%s_n%05d_VS_%s_s1.rds", tasks$arm, n, tasks$noise)); tasks <- tasks[!file.exists(tasks$file), ]
  res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]
    r <- tryCatch({
      d <- J$simulate_data(1L, n, taus[1], "VS", tk$noise); truth <- sapply(taus, function(t) J$simulate_data(1L, n, t, "VS", tk$noise)$truth)
      options(bqtf.metric_cap = 1e8, bqtf.lambda_floor = if (tk$arm == "V0T") KM * n^2.5 else 0); set.seed(1001L)
      fit <- J$gibbs_joint_pmala(d$y, taus, 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = JS, gibbs_burn = JS %/% 3L, delta_init = 0.2, lambda_init = NULL,
               adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L,
               mh = TRUE, adapt = TRUE, warm = 200L, gamma_warm = 1e4, kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0, zeta_scale = 1, verbose = FALSE)
      est <- apply(fit$theta, c(2, 3), mean); fl <- if (tk$arm == "V0T") KM * n^2.5 else 0; post <- (JS %/% 3L + 1):JS
      row <- data.frame(arm = tk$arm, noise = tk$noise, n = n, sweeps = JS, seconds = fit$seconds, tau = taus, mse = colMeans((est - truth)^2),
                        lam_med = apply(fit$lambda[post, , drop = FALSE], 2, median), frac_at_floor = if (fl > 0) colMeans(fit$lambda[post, , drop = FALSE] < 1.001 * fl) else NA,
                        acc = colMeans(fit$acc[post, , drop = FALSE], na.rm = TRUE), crossings_postmean = sum(apply(est, 1, function(v) sum(diff(v) < 0))))
      saveRDS(list(row = row), tk$file); "ok"
    }, error = function(e) paste("ERROR", conditionMessage(e)))
    if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
  }, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
  cat(sprintf("[%s] joint done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
}
