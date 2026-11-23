# Route A sims for Theory (2026-11-23).  Measurement instrument: the exact banded augmented Gibbs (E-07 sampler, move "exact",
# collapsed lambda block) on Felipe's DEFAULT posterior: sigma ~ IG(0.1, 0.1), lambda ~ Gamma(1, b0) with b0 = 1e-3 (VS) / 5e-4 (S),
# raw scale (no standardisation), the paper's data generator.  Same target as his P-MALA (G0: agreement where his chain mixes).
#   R_A = "A1": VS, S x Normal, Beta, Mixed x tau {0.05, 0.5, 0.95} x n {250, 500, 1000, 2000, 4000} x seeds 1-5 (+ VS-Normal tau 0.5 n 8000)
#   R_A = "A2": sigma and lambda FIXED at the A1 posterior medians (frozen exact sampler, e02 run_gibbs_frozen), n {500, 2000}
# Per fit: quantiles of sigma/sigma0_n and sigma/sigma_bar; lambda and lambda*sigma quantiles; rough and full Delta2 radii (95% posterior
# quantile); MSE of the posterior mean; ESS (bulk/tail) and Rhat for log sigma and log lambda (posterior package, 4 chains).
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "route_a"); RA <- Sys.getenv("R_A", "A1")
suppressPackageStartupMessages(library(posterior))
source(file.path(E02, "e02_lib.R")); source(file.path(E07, "sampler", "e07_sampler.R")); e07_load(file.path(E07, "sampler"), Sys.getenv("E07_CACHE")); load_kernel()
pl <- readLines(file.path(E07, "Individual_Sampler_PMALA_Augmented_E07R1copy.R")); i <- grep("^simulate_data", pl); j <- i + which(pl[(i + 1):length(pl)] == "}")[1]
eval(parse(text = pl[i:j]))
dir.create(file.path(OUT, RA), recursive = TRUE, showWarnings = FALSE)
b0_of <- function(bl) if (bl == "VS") 1e-3 else 5e-4
# per-design-point error law: quantile q_u, density f_u(q_u), E rho_tau(eps_u - q_u)
law <- function(noise, tau, u) {
  if (noise == "Normal") { s <- (1 + u^2) / 4; z <- qnorm(tau); return(list(f = dnorm(z) / s, er = s * dnorm(z))) }   # E rho_tau(Z - z_tau) = phi(z_tau)
  ug <- seq(min(u), 1, length.out = 120)
  one <- function(x) {
    if (noise == "Beta") { b <- 11 - 10 * x; q <- qbeta(tau, 1, b); d <- function(e) dbeta(e, 1, b); lo <- 0; hi <- 1 }
    else { cdf <- function(t) x * pnorm(t, -.2, sqrt(.5)) + (1 - x) * pnorm(t, .2, sqrt(.5)); q <- uniroot(function(t) cdf(t) - tau, c(-10, 10), tol = 1e-12)$root
           d <- function(e) x * dnorm(e, -.2, sqrt(.5)) + (1 - x) * dnorm(e, .2, sqrt(.5)); lo <- -Inf; hi <- Inf }
    c(f = d(q), er = integrate(function(e) rho_tau(e - q, tau) * d(e), lo, hi, rel.tol = 1e-9, subdivisions = 2000L)$value) }
  G <- t(sapply(ug, one)); list(f = approx(ug, G[, "f"], u, rule = 2)$y, er = approx(ug, G[, "er"], u, rule = 2)$y)
}
g <- function(n, seeds, bl = c("VS", "S"), noise = c("Normal", "Beta", "Mixed"), tau = c(0.05, 0.5, 0.95)) expand.grid(bl = bl, noise = noise, tau = tau, n = n, seed = seeds, stringsAsFactors = FALSE)
tasks <- if (RA == "A1") rbind(g(c(250, 500, 1000, 2000, 4000), 1:5), g(8000, 1:5, "VS", "Normal", 0.5)) else g(c(500, 2000), 1:5)
tasks$file <- file.path(OUT, RA, sprintf("%s_%s_t%03d_n%05d_s%d.rds", tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$n, tasks$seed))
tasks <- tasks[!file.exists(tasks$file), ]; tasks <- tasks[order(-tasks$n, tasks$seed), ]
if (nzchar(Sys.getenv("R_TEST"))) tasks <- tasks[tasks$n == min(tasks$n) & tasks$noise == "Beta", ][1, ]
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
if (K > 1) tasks <- tasks[(seq_len(nrow(tasks)) - 1L) %% K == (k %% K), ]
cat(sprintf("[%s] Route A %s: %d tasks here, %s cores\n", format(Sys.time()), RA, nrow(tasks), Sys.getenv("SLURM_CPUS_PER_TASK")))
qq <- function(x, p = c(0.05, 0.5, 0.95)) setNames(quantile(x, p, names = FALSE), c("q05", "q50", "q95"))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) {
  tk <- tasks[i, ]
  r <- tryCatch({
    d <- simulate_data(tk$seed, tk$n, tk$tau, tk$bl, tk$noise); n <- tk$n; u <- seq_len(n) / n
    L <- law(tk$noise, tk$tau, u); sig0n <- mean(L$er); sbar <- tk$tau * (1 - tk$tau) / min(L$f)
    X <- qr.Q(qr(cbind(1, u, u^2)))
    set.seed(tk$seed + 2000L)
    if (RA == "A1") {
      f <- bqtf_tf(d$y, tk$tau, move = "exact", standardize = FALSE, a0 = 1, b0 = b0_of(tk$bl), a_s = 0.1, b_s = 0.1, max_sweeps = 20000L)
      TH <- f$draws; lam <- f$lambda; sig <- f$sigma
      dg <- f$diag; diagv <- c(rhat_loglam = dg[1, "rhat"], ess_loglam = dg[1, "ess"], esst_loglam = dg[1, "ess_tail"],
                                rhat_logsig = dg[2, "rhat"], ess_logsig = dg[2, "ess"], esst_logsig = dg[2, "ess_tail"])
      extra <- c(sweeps = f$sweeps, converged = f$converged, seconds = f$seconds)
    } else {
      A1 <- readRDS(file.path(OUT, "A1", basename(tk$file))); lamf <- A1$row$lam_q50; sigf <- A1$row$sig_q50
      map <- qtf_map_best(d$y, tk$tau, lamf * sigf)
      ch <- run_gibbs_frozen(d$y, d$truth, tk$tau, lamf, sigf, map, burn = 1000L, keep = 5000L, thin = 5L, return_draws = TRUE)
      TH <- ch$draws; lam <- lamf; sig <- sigf; diagv <- c(ess_d2 = ch$summ[["ess_d2"]]); extra <- c(seconds = ch$summ[["seconds"]])
    }
    Dl <- sweep(TH, 2, d$truth); d2 <- rowMeans(pmin(abs(Dl), Dl^2)); Dr <- Dl - (Dl %*% X) %*% t(X); d2r <- rowMeans(pmin(abs(Dr), Dr^2))
    pm <- colMeans(TH)
    row <- data.frame(tk[1:5], sigma0_n = sig0n, sigma_bar = sbar, t(qq(sig / sig0n)), t(qq(sig / sbar)), t(qq(lam)), t(qq(lam * sig)),
                      q95_full = unname(quantile(d2, 0.95)), q95_rough = unname(quantile(d2r, 0.95)), mse_pm = mean((pm - d$truth)^2),
                      t(diagv), t(extra), stringsAsFactors = FALSE)
    names(row)[8:19] <- c(paste0("sig_s0_", c("q05", "q50", "q95")), paste0("sig_sbar_", c("q05", "q50", "q95")), paste0("lam_", c("q05", "q50", "q95")), paste0("lamsig_", c("q05", "q50", "q95")))
    row$sig_q50 <- row$sig_s0_q50 * sig0n
    saveRDS(list(row = row), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
