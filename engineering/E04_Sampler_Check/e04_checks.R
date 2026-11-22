# E-04 sampler fitness check (Engineering, 2026-11-22).  Three parts, selected by PART = A | B | C (env), Slurm-array aware:
#  A  exact check at n = 4 (one third difference): posterior exp{-sum rho_tau(y-theta)/sigma - lambda |D theta|}, lambda and sigma
#     fixed, computed on a 4-d midpoint grid; compared with long runs of the banded Gibbs sampler and of the exact P-MALA kernel.
#  B  agreement at the paper's settings: the paper's own data generator (VS, heteroscedastic Normal, tau 0.5, n = 500), learned lambda
#     and sigma, b0 in {1, 1e-3}; the paper's Bayesian-PMALA (unmodified) vs the banded Gibbs sampler, 4 chains each.  Pointwise
#     posterior mean and 2.5/97.5% bands, Delta2 vs truth, lambda, sigma; between-chain standard errors and R-hat.
#  C  R-hat / ESS of the functional E-02 plots: 4 dispersed-start Gibbs chains (fixed lambda, sigma) at representative E-02 cells.
# Outputs: $E04_OUT/<part>/*.rds
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/Engineering/E02_Rate_Sims")
OUT <- Sys.getenv("E04_OUT", "/home/fb31/BQTF_runs/E04"); PART <- Sys.getenv("PART", "A")
cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2"))
source(file.path(E02_DIR, "e02_lib.R")); load_kernel()
dir.create(file.path(OUT, PART), recursive = TRUE, showWarnings = FALSE)
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
slice <- function(v) if (K > 1) v[(seq_along(v) - 1L) %% K == (k %% K)] else v
bm_se <- function(v, nb = 50) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }

if (PART == "A") {
  cells <- list(list(tau = 0.5, lam = 5, sig = 0.3), list(tau = 0.9, lam = 5, sig = 0.3), list(tau = 0.5, lam = 50, sig = 0.3))
  res <- parallel::mclapply(slice(seq_along(cells)), function(ci) {
    cl <- cells[[ci]]; set.seed(100 + ci); n <- 4; y <- c(0.1, 0.5, -0.2, 0.4)
    # grid: each axis covers the bulk of the conditional (ALD tails: rate min(tau,1-tau)/sigma)
    G <- 64; lo_r <- 12 * cl$sig / cl$tau; hi_r <- 12 * cl$sig / (1 - cl$tau)          # ALD tails: below y rate tau/sigma, above (1-tau)/sigma
    ax <- lapply(1:n, function(i) { e <- seq(y[i] - lo_r, y[i] + hi_r, length.out = G + 1); (e[-1] + e[-(G + 1)]) / 2 })   # midpoints
    gr <- as.matrix(expand.grid(ax))
    lp <- -rowSums(rho_tau(sweep(-gr, 2, -y), cl$tau)) / cl$sig - cl$lam * abs(gr[, 4] - 3 * gr[, 3] + 3 * gr[, 2] - gr[, 1])
    w <- exp(lp - max(lp)); w <- w / sum(w)
    m_ex <- colSums(gr * w); s_ex <- sqrt(colSums(gr^2 * w) - m_ex^2)
    th_star <- rep(0, n)                                                          # (Delta2 unused here)
    g <- run_gibbs_frozen(y, th_star, cl$tau, cl$lam, cl$sig, y, burn = 2000, keep = 200000, thin = 10)
    p <- run_frozen(y, th_star, cl$tau, cl$lam, cl$sig, y, burn = 5000, keep = 400000, thin = 20)
    # z-scores from thinned draws' batch means (thinned draws are stored as TH in the chain objects only via post_mean/sd)
    list(cell = cl, m_ex = m_ex, s_ex = s_ex, g = list(m = g$post_mean, s = g$sd, ess = g$summ[["ess_mid_thinned"]]),
         p = list(m = p$post_mean, s = p$sd, ess = p$summ[["ess_mid_thinned"]], acc = p$summ[["acc_post"]]), grid_mass_edge = max(sapply(1:n, function(i) { idx <- gr[, i] <= ax[[i]][2] | gr[, i] >= ax[[i]][G - 1]; sum(w[idx]) })))
  }, mc.cores = cores)
  saveRDS(res, file.path(OUT, "A", sprintf("A_%d.rds", k)))
}

if (PART == "B") {
  psrc <- file.path(E02_DIR, "Individual_Sampler_PMALA_Augmented.R")
  pl <- readLines(psrc); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]
  PAPER <- new.env(parent = globalenv())
  local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", psrc)) }, envir = PAPER)
  eval(parse(text = pl), envir = PAPER); PAPER$load_prox_cpp(file.path(E02_DIR, "prox_admm_metric.cpp"))
  dat <- PAPER$simulate_data(1, 500, 0.5, "VS", "Normal")                       # the paper's generator; truth = true 0.5-quantile
  jobs <- expand.grid(sampler = c("pmala", "gibbs"), b0 = c(1, 1e-3), chain = 1:4, stringsAsFactors = FALSE)
  res <- parallel::mclapply(slice(seq_len(nrow(jobs))), function(j) {
    jb <- jobs[j, ]; set.seed(5000 + 17 * j); n <- 500; m <- n - 3
    if (jb$sampler == "pmala") {
      fit <- PAPER$gibbs_pmala_aug(dat$y, 0.5, 2L, a0 = 1, b0 = jb$b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = 60000L, gibbs_burn = 20000L,
               delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
               control = PAPER$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
               warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
               lamjump = FALSE, verbose = FALSE)
      post <- 20001:60000; TH <- fit$theta
      out <- list(pm = colMeans(TH), lo = apply(TH, 2, quantile, 0.025), hi = apply(TH, 2, quantile, 0.975),
                  d2 = apply(TH, 1, function(t) Delta2(t - dat$truth)), lam = fit$lambda[post], sig = fit$sigma[post], acc = fit$acc_post, sec = fit$seconds)
    } else {
      start <- qtf_map_best(dat$y, 0.5, m)
      ch <- run_gibbs_frozen(dat$y, dat$truth, 0.5, lambda = m, sigma = 1, theta0 = start, burn = 10000L, keep = 30000L, thin = 10L,
                             learn_lambda = TRUE, a0 = 1, b0 = jb$b0, asis = TRUE, learn_sigma = TRUE)
      out <- list(pm = ch$post_mean, lo = ch$bands$lo, hi = ch$bands$hi, d2 = ch$trace$d2, lam = ch$trace$lambda[10001:40000],
                  sig = ch$trace$sigma[10001:40000], acc = NA, sec = ch$summ[["seconds"]])
    }
    c(as.list(jb), out)
  }, mc.cores = cores, mc.preschedule = FALSE)
  saveRDS(list(truth = dat$truth, y = dat$y, res = res), file.path(OUT, "B", sprintf("B_%d.rds", k)))
}

if (PART == "C") {
  cal <- readRDS(file.path(E02_DIR, "calibration.rds"))
  cells <- expand.grid(n = c(500, 4000, 16000), a = c(15/7, 3), truth = "sin", stringsAsFactors = FALSE)
  res <- parallel::mclapply(slice(seq_len(nrow(cells))), function(ci) {
    cl <- cells[ci, ]; dat <- make_data(cl$truth, "gauss", 0.5, cl$n, 1); sig <- sigma0("gauss", 0.5)
    Lam <- cal$Lstar * (cl$n / 500)^cl$a; lam <- Lam / sig; map <- qtf_map_best(dat$y, 0.5, Lam)
    u <- seq_len(cl$n) / cl$n; ls_quad <- fitted(lm(dat$y ~ u + I(u^2)))
    starts <- list(map = map, data = dat$y, quad = ls_quad, map_jitter = map + rnorm(cl$n, 0, 0.5))   # dispersed starts
    chains <- lapply(seq_along(starts), function(s) { set.seed(900 + s); run_gibbs_frozen(dat$y, dat$theta_star, 0.5, lam, sig, starts[[s]], burn = 1000, keep = 5000, thin = 5) })
    mc <- coda::mcmc.list(lapply(chains, function(ch) coda::mcmc(ch$trace$d2)))
    list(cell = cl, rhat_d2 = coda::gelman.diag(mc, autoburnin = FALSE)$psrf[1, ], ess_d2 = sapply(chains, function(ch) ch$summ[["ess_d2"]]),
         d2_means = sapply(chains, function(ch) ch$summ[["d2_mean"]]), rough = sapply(chains, function(ch) ch$summ[["rough_spread"]]),
         centre = sapply(chains, function(ch) ch$summ[["centre_d2"]]))
  }, mc.cores = cores, mc.preschedule = FALSE)
  saveRDS(res, file.path(OUT, "C", sprintf("C_%d.rds", k)))
}
cat(sprintf("[%s] E-04 part %s slice %d/%d done\n", format(Sys.time()), PART, k, K))
