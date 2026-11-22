# E-02 / HQ request: efficiency of the paper's Bayesian-PMALA (learned lambda and sigma, production settings) versus the
# banded Gibbs sampler (learned lambda and sigma, same model and priors), at
#   (a) b0 = 1 (the paper's Gamma(1,1) pilot, learned lambda ~ 50-75) and (b) b0 = n^-2;
#   sin truth, N(0, 0.5^2) noise, tau = 0.5, n in {500, 2000, 8000}, 5 replicates, 30000 sweeps of which 10000 burn-in.
# Reports ESS (coda) per kept sweep and per second of sampler wall time for: Delta2(theta - theta*), log lambda, sigma, and
# theta_i at i = n/4, n/2, 3n/4; plus P-MALA acceptance and posterior summaries (to cross-check that both target the same law).
#   Rscript pmala_vs_gibbs.R      (Slurm array aware; one .rds per task under $E02_OUT/grid/pvg/)
args <- commandArgs(trailingOnly = TRUE)
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims")
SMOKE <- Sys.getenv("E02_PVG_SMOKE") == "1"            # quick end-to-end check: short chains, n = 500, seed 1
OUT <- file.path(Sys.getenv("E02_OUT", "/home/fb31/BQTF_runs/E02"), "grid", if (SMOKE) "pvg_smoke" else "pvg"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2"))
source(file.path(E02_DIR, "e02_lib.R")); load_kernel()

# --- the paper's sampler: definitions only (everything before "# ---- Main"), in its own environment ---
psrc <- file.path(E02_DIR, "Individual_Sampler_PMALA_Augmented.R")
pl <- readLines(psrc); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]
PAPER <- new.env(parent = globalenv())
local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", psrc)) }, envir = PAPER)
eval(parse(text = pl), envir = PAPER)
PAPER$load_prox_cpp(file.path(E02_DIR, "prox_admm_metric.cpp"))

GIBBS_ITER <- if (SMOKE) 600L else 30000L; BURN <- if (SMOKE) 300L else 10000L
tasks <- expand.grid(sampler = c("pmala", "gibbs"), b0lab = c("B1", "Bn2"), n = if (SMOKE) 500 else c(8000, 2000, 500), seed = if (SMOKE) 1 else 1:5, stringsAsFactors = FALSE)
tasks$file <- file.path(OUT, sprintf("%s_%s_n%05d_s%03d.rds", tasks$sampler, tasks$b0lab, tasks$n, tasks$seed))
todo <- tasks[!file.exists(tasks$file), ]
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
if (K > 1) todo <- todo[(seq_len(nrow(todo)) - 1L) %% K == (k %% K), ]
cat(sprintf("[%s] pvg: %d tasks to do on %d cores\n", format(Sys.time()), nrow(todo), cores))
ess <- function(x) as.numeric(coda::effectiveSize(x))

res <- parallel::mclapply(seq_len(nrow(todo)), function(i) {
  tk <- todo[i, ]
  tryCatch({
    dat <- make_data("sin", "gauss", 0.5, tk$n, tk$seed); n <- tk$n; m <- n - 3L
    b0 <- if (tk$b0lab == "B1") 1 else n^-2
    idx3 <- unique(pmax(1L, round(n * c(0.25, 0.5, 0.75))))
    set.seed(tk$seed + 1000L)
    if (tk$sampler == "pmala") {
      fit <- PAPER$gibbs_pmala_aug(dat$y, 0.5, 2L, a0 = 1, b0 = b0, a_sigma = 0.1, b_sigma = 0.1,
               gibbs_iter = GIBBS_ITER, gibbs_burn = BURN, delta_init = 0.2, lambda_init = NULL,
               adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), control = PAPER$tf_control,
               metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y", warm = 200L,
               gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
               lamjump = FALSE, verbose = FALSE)
      post <- (BURN + 1):GIBBS_ITER
      d2 <- apply(fit$theta, 1, function(th) Delta2(th - dat$theta_star))
      pm <- colMeans(fit$theta)
      spread <- mean(apply(fit$theta[seq(10, nrow(fit$theta), by = 10), , drop = FALSE], 1, function(th) Delta2(th - pm)))
      lam <- fit$lambda[post]; sig <- fit$sigma[post]; th3 <- fit$theta[, idx3, drop = FALSE]
      acc <- fit$acc_post; secs <- fit$seconds
    } else {
      start <- qtf_map_best(dat$y, 0.5, m * 1)                 # lambda0 = m, sigma0 = 1 (the paper's initial values)
      ch <- run_gibbs_frozen(dat$y, dat$theta_star, 0.5, lambda = m, sigma = 1, theta0 = start, burn = BURN, keep = GIBBS_ITER - BURN,
                             thin = 10L, learn_lambda = TRUE, a0 = 1, b0 = b0, asis = TRUE, learn_sigma = TRUE, a_sigma = 0.1, b_sigma = 0.1)
      d2 <- ch$trace$d2; pm <- ch$post_mean; spread <- ch$summ[["spread_d2"]]
      lam <- ch$trace$lambda[(BURN + 1):GIBBS_ITER]; sig <- ch$trace$sigma[(BURN + 1):GIBBS_ITER]; th3 <- ch$trace$theta3
      acc <- NA; secs <- ch$summ[["seconds"]]
    }
    keep <- GIBBS_ITER - BURN
    e <- c(d2 = ess(d2), loglam = ess(log(lam)), sigma = ess(sig), theta_min = min(apply(th3, 2, ess)), theta_med = median(apply(th3, 2, ess)))
    row <- data.frame(sampler = tk$sampler, b0lab = tk$b0lab, b0 = b0, n = n, seed = tk$seed, seconds = secs, acc = acc,
                      lam_mean = mean(lam), lam_median = median(lam), sig_mean = mean(sig), d2_mean = mean(d2),
                      centre_d2 = Delta2(pm - dat$theta_star), spread_d2 = spread,
                      lam_drift = log(mean(lam[-(1:(keep %/% 2))]) / mean(lam[1:(keep %/% 2)])),
                      t(setNames(e, paste0("ess_", names(e)))), t(setNames(e / keep, paste0("essps_", names(e)))),
                      t(setNames(e / secs, paste0("esspsec_", names(e)))), stringsAsFactors = FALSE)
    saveRDS(list(row = row, post_mean = pm, lam = lam, sig = sig, d2 = d2), tk$file)
    "ok"
  }, error = function(e) { cat(sprintf("task %s failed: %s\n", basename(tk$file), conditionMessage(e))); "fail" })
}, mc.cores = cores, mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
