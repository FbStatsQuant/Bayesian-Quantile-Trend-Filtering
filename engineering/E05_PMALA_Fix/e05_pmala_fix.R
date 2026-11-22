# E-05 (HQ): can the paper's P-MALA be fixed cheaply for b0 = n^-2?  On a COPY of the paper sampler (only the metric cap is made
# configurable).  sin truth, N(0, 0.5^2), tau 0.5, learned lambda and sigma, b0 = n^-2, n in {2000, 8000}, seeds 1-3, the paper's
# run length (30000 sweeps, 10000 burn-in).  Variants:
#   a  metric cap raised from 1e8 to 1e20 (covers kappa*lambda^2/2 for lambda up to ~1e9)
#   b  lambda initialised near its posterior scale instead of m: sigma_hat = mean check loss of the QTF MAP at penalty m,
#      kappa_hat = phi(0)^2 / sigma_hat^2 (Gaussian working value), lambda0 = (0.27 n kappa_hat^(1/6) / b0)^(3/4) (Theory's fixed point)
#   c  a + b
# Reference: the banded Gibbs runs of the same datasets (pvg, seeds 1-3), read from $E02_GRID/pvg.
E05 <- Sys.getenv("E05_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E05_PMALA_Fix")
E02_DIR <- Sys.getenv("E02_DIR"); OUT <- Sys.getenv("E05_OUT", "/home/fb31/BQTF_runs/E05"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
source(file.path(E02_DIR, "e02_lib.R")); load_kernel()
psrc <- file.path(E05, "Individual_Sampler_PMALA_Augmented_E05copy.R")
pl <- readLines(psrc); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]
PAPER <- new.env(parent = globalenv())
local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", file.path(E02_DIR, "Individual_Sampler_PMALA_Augmented.R"))) }, envir = PAPER)
eval(parse(text = pl), envir = PAPER); PAPER$load_prox_cpp(file.path(E02_DIR, "prox_admm_metric.cpp"))
jobs <- expand.grid(variant = c("a", "b", "c"), n = c(8000, 2000), seed = 1:3, stringsAsFactors = FALSE)
res <- parallel::mclapply(seq_len(nrow(jobs)), function(j) {
  jb <- jobs[j, ]; n <- jb$n; m <- n - 3; b0 <- n^-2
  dat <- make_data("sin", "gauss", 0.5, n, jb$seed)
  cap <- if (jb$variant %in% c("a", "c")) 1e20 else 1e8
  lam0 <- NULL
  if (jb$variant %in% c("b", "c")) {
    mp <- qtf_map_best(dat$y, 0.5, m)                         # MAP at penalty m (sigma unknown: use lambda*sigma = m as a neutral start)
    sh <- mean(rho_tau(dat$y - mp, 0.5)); kh <- dnorm(0)^2 / sh^2
    lam0 <- (0.27 * n * kh^(1/6) / b0)^(3/4)
  }
  options(bqtf.metric_cap = cap); set.seed(jb$seed + 1000L)
  fit <- tryCatch(PAPER$gibbs_pmala_aug(dat$y, 0.5, 2L, a0 = 1, b0 = b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = 30000L, gibbs_burn = 10000L,
               delta_init = 0.2, lambda_init = lam0, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
               control = PAPER$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
               warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
               lamjump = FALSE, verbose = FALSE), error = function(e) e)
  if (inherits(fit, "error")) return(data.frame(variant = jb$variant, n = n, seed = jb$seed, lam0 = if (is.null(lam0)) m else lam0, status = paste("ERROR:", conditionMessage(fit))))
  post <- 10001:30000; d2 <- apply(fit$theta, 1, function(t) Delta2(t - dat$theta_star)); lam <- fit$lambda[post]
  ess <- function(x) as.numeric(coda::effectiveSize(x)); h <- length(lam) %/% 2
  data.frame(variant = jb$variant, n = n, seed = jb$seed, lam0 = if (is.null(lam0)) m else lam0, status = "ok", sec = fit$seconds, acc = fit$acc_post,
             lam_mean = mean(lam), lam_drift = log(mean(lam[-(1:h)]) / mean(lam[1:h])), d2 = mean(d2), ess_d2 = ess(d2), ess_loglam = ess(log(lam)),
             esspsec_d2 = ess(d2) / fit$seconds, esspsec_loglam = ess(log(lam)) / fit$seconds, delta_final = fit$delta_final)
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
R <- data.table::rbindlist(res, fill = TRUE)
G <- data.table::rbindlist(lapply(list.files(file.path(Sys.getenv("E02_GRID"), "pvg"), pattern = "^gibbs_Bn2_n0(2000|8000)_s00[1-3]", full.names = TRUE),
       function(f) data.table::as.data.table(readRDS(f)$row)[, .(n, seed, lam_gibbs = lam_mean, d2_gibbs = d2_mean, esspsec_d2_gibbs = esspsec_d2, esspsec_loglam_gibbs = esspsec_loglam)]))
R <- merge(R, G, by = c("n", "seed"), all.x = TRUE)
saveRDS(R, file.path(OUT, "e05.rds")); options(width = 250); print(R)
cat("\nsummary (mean over seeds):\n")
print(R[status == "ok", .(reps = .N, lam0 = signif(mean(lam0), 3), lam_ratio = signif(mean(lam_mean / lam_gibbs), 3), d2_ratio = signif(mean(d2 / d2_gibbs), 3),
                         drift = signif(mean(abs(lam_drift)), 2), acc = round(mean(acc), 2), ess_loglam = round(mean(ess_loglam)), gibbs_gain_d2 = round(mean(esspsec_d2_gibbs / esspsec_d2)),
                         gibbs_gain_loglam = round(mean(esspsec_loglam_gibbs / esspsec_loglam))), by = .(variant, n)][order(variant, n)])
print(R[status != "ok", .(variant, n, seed, status)])
