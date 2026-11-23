# E-07 R1 (HQ-approved, 6.4 core-h): proximal candidates INSIDE Felipe's original sampler (R1 copy = E-05 copy + numeric-init hook),
# paired against the sigma sprint's L fits (learned sigma, paper settings) on identical data and seeds.
#   P1: ASIS on for S (his flag; the paper runs S with ASIS off)                                  S cells, seeds 1-5
#   P2: proximal warm start: theta0 = QTF MAP at the Koenker-SIC penalty (25-point grid), sigma0, z0, lambda0 from conditionals
#       (paper ASIS setting per signal)                                                           S seeds 1-5, VS seeds 1-3
#   P3: his joint (lambda, theta) proximal jump (lamjump = TRUE; ASIS as in the paper)            S cells, seeds 1-5
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); E05 <- Sys.getenv("E05_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "r1"); LDIR <- file.path(Sys.getenv("E07_OUT"), "sigma_sprint")
source(file.path(E02, "e02_lib.R")); load_kernel()
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
pl <- readLines(file.path(E07, "Individual_Sampler_PMALA_Augmented_E07R1copy.R")); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]
PAPER <- new.env(parent = globalenv())
local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", file.path(E02, "Individual_Sampler_PMALA_Augmented.R"))) }, envir = PAPER)
eval(parse(text = pl), envir = PAPER); PAPER$load_prox_cpp(file.path(E02, "prox_admm_metric.cpp"))
paper_cfg <- function(bl) if (bl == "VS") list(b0 = 1e-3, asis = TRUE, it = 30000L, burn = 10000L) else list(b0 = 5e-4, asis = FALSE, it = 20000L, burn = 5000L)
sigma_bar <- function(noise, tau, n = 500L) {                     # tau(1-tau) / min_i f_{u_i}(q_{u_i}), u_i = i/n (the paper's design)
  u <- seq_len(n) / n
  f <- switch(noise,
    Normal = dnorm(qnorm(tau)) / ((1 + u^2) / 4),
    Beta   = { b <- 11 - 10 * u; dbeta(qbeta(tau, 1, b), 1, b) },
    Mixed  = sapply(u, function(xi) { q <- uniroot(function(t) xi * pnorm(t, -.2, sqrt(.5)) + (1 - xi) * pnorm(t, .2, sqrt(.5)) - tau, c(-10, 10), tol = 1e-12)$root
                                      xi * dnorm(q, -.2, sqrt(.5)) + (1 - xi) * dnorm(q, .2, sqrt(.5)) }))
  tau * (1 - tau) / min(f)
}
g <- function(arm, bl, seeds) expand.grid(arm = arm, bl = bl, noise = c("Normal", "Beta", "Mixed"), tau = c(0.05, 0.5, 0.95), seed = seeds, stringsAsFactors = FALSE)
RPH <- Sys.getenv("R_PHASE", "R1"); CAND <- strsplit(Sys.getenv("CAND", "P1"), ",")[[1]]
g3 <- function(arm, seeds) expand.grid(arm = arm, bl = c("VS", "S"), noise = c("Normal", "Beta", "Mixed"), tau = c(0.05, 0.25, 0.5, 0.75, 0.95), seed = seeds, stringsAsFactors = FALSE)
tasks <- if (RPH == "R1") rbind(g("P1", "S", 1:5), g("P2", "S", 1:5), g("P2", "VS", 1:3), g("P3", "S", 1:5)) else if (RPH == "R1b")
  rbind(g("L2x", "S", 1:5), g("P3", "VS", 1:5)) else if (RPH == "R1c") g("L4x", "S", 1:5) else if (RPH == "R1d") g("L2x", "VS", 1:5) else       # R1b: equal-wall-time control (his sampler, 2x sweeps) on S; P3 on VS; R1c: his sampler at 4x on S (HQ: plateau)
  rbind(g3("L", 1:10), do.call(rbind, lapply(CAND, function(a) g3(a, 1:10))))   # R3: full interior grid, 10 seeds (existing fits are skipped)
if (RPH == "R3") { OUT <- file.path(Sys.getenv("E07_OUT"), "r3"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE) }
sic_start <- function(y, tau) {                       # Koenker SIC over a 25-point penalty grid; QTF MAP by the exact solver
  n <- length(y); best <- NULL
  for (L in 10^seq(-1, 5, length.out = 25)) { th <- qtf_map_best(y, tau, L); df <- sum(abs(diff(th, differences = 3L)) > 1e-6 * max(1, sd(y))) + 3
    sic <- log(mean(rho_tau(y - th, tau))) + df * log(n) / (2 * n); if (is.null(best) || sic < best$sic) best <- list(sic = sic, theta = th, Lam = L) }
  best }
tasks$file <- file.path(OUT, sprintf("%s_%s_%s_t%03d_s%d.rds", tasks$arm, tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$seed))
prev <- function(tk) { if (RPH != "R3") return(character(0)); f <- sprintf("%s_%s_%s_t%03d_s%d.rds", tk$arm, tk$bl, tk$noise, round(100 * tk$tau), tk$seed)
  c(file.path(LDIR, f), file.path(Sys.getenv("E07_OUT"), "r1", f)) }
have <- sapply(seq_len(nrow(tasks)), function(i) file.exists(tasks$file[i]) || any(file.exists(prev(tasks[i, ]))))
tasks <- tasks[!have, ]
tasks <- tasks[order(tasks$bl != "VS", tasks$seed), ]                                  # VS (30k sweeps) first
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
if (K > 1) tasks <- tasks[(seq_len(nrow(tasks)) - 1L) %% K == (k %% K), ]
cat(sprintf("[%s] sigma sprint: %d tasks here, %s cores\n", format(Sys.time()), nrow(tasks), Sys.getenv("SLURM_CPUS_PER_TASK")))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) {
  tk <- tasks[i, ]
  r <- tryCatch({
    d <- PAPER$simulate_data(tk$seed, 500L, tk$tau, tk$bl, tk$noise); pc <- paper_cfg(tk$bl); sb <- sigma_bar(tk$noise, tk$tau)
    if (tk$arm == "L2x") { pc$it <- 2L * pc$it; pc$burn <- 2L * pc$burn }
    if (tk$arm == "L4x") { pc$it <- 4L * pc$it; pc$burn <- 4L * pc$burn }   # his sampler unchanged, twice the sweeps (P3 costs ~2x per sweep)
    a0 <- 1; b0 <- pc$b0; lam_c <- NA; init <- "y"; asis <- pc$asis; lamjump <- FALSE
    if (tk$arm == "P1") asis <- TRUE
    if (tk$arm == "P3") lamjump <- TRUE
    if (tk$arm == "P2") { t0s <- proc.time()[["elapsed"]]; st <- sic_start(d$y, tk$tau); init <- st$theta; lam_c <- st$Lam; t_start <- proc.time()[["elapsed"]] - t0s } else t_start <- 0
    options(bqtf.metric_cap = 1e8); set.seed(tk$seed + 1000L)
    fit <- PAPER$gibbs_pmala_aug(d$y, tk$tau, 2L, a0 = a0, b0 = b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = pc$it, gibbs_burn = pc$burn,
             delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
             control = PAPER$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = init,
             warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = asis, tol = 0,
             lamjump = lamjump, verbose = FALSE)
    post <- (pc$burn + 1):pc$it; TH <- fit$theta; lam <- fit$lambda[post]; sig <- fit$sigma[post]
    est <- colMeans(TH); med <- apply(TH, 2, median); lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
    row <- data.frame(tk[1:5], sigma_bar = sb, a0 = a0, b0 = b0, lam_c = lam_c, sweeps = pc$it, seconds = fit$seconds + t_start, t_start = t_start, acc = mean(fit$acc[post], na.rm = TRUE),
                      lam_mean = mean(lam), sig_mean = mean(sig), lamsig_mean = mean(lam * sig),
                      ess_loglam = as.numeric(coda::effectiveSize(log(lam))), ess_sig = if (tk$arm == "L") as.numeric(coda::effectiveSize(sig)) else NA,
                      mse = mean((est - d$truth)^2), mad = mean(abs(est - d$truth)), mse_med = mean((med - d$truth)^2),
                      mciw = mean(hi - lo), cover = mean(d$truth >= lo & d$truth <= hi), stringsAsFactors = FALSE)
    saveRDS(list(row = row, y = d$y, truth = d$truth, mean = est, median = med, lo = lo, hi = hi), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
