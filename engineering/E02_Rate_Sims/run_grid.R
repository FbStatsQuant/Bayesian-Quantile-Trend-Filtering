# E-02 grid runner (restartable).  Usage:
#   Rscript run_grid.R <phase> [cores]
# phases: p1 = tau 0.5, Gaussian, all truths x all a x n 250..32000, 20 reps
#         p2 = the rest of the default grid (t2 noise and/or tau 0.9)
#         lamcurve = spread-vs-lambda curve at fixed n (2000, 8000)
#         T3    = Theory T-03 spec: lambda = n^a (raw scale), sigma = sigma0; truths sin (S) and PQT; N(0,0.25^2) primary,
#                 tau 0.9 secondary, Cauchy(0,0.1) arm; a in {1.5, 2, 15/7, 9/4, 7/3, 2.5}
#         T3lam = Theory P1: dense lambda sweep at fixed n in {1000, 4000}: lambda = 10^(3, 3.5, ..., 9)
#         lamlearn = learned lambda (sigma fixed at sigma0), lambda ~ Gamma(1, b0) with b0 in {1 (paper pilot), n^-2, n^-2.5};
#                    sin truth, N(0, 0.25^2), tau 0.5, n in {500, 2000, 8000}, 10 reps (Felipe / HQ request)
#         lamlearn2 = Theory's learned arm: b0 = 1e-3 for sin; b0 in {1, 1e-3, n^-2, n^-2.5} for PQT
#         lamlearn3 = quadratic truth, N(0, 0.5^2) (kappa = 4), b0 = n^-2; start lambda = m ("Bn2") or 0.3 n^(9/4) ("Bn2i")
#         kink83 = a = 8/3 (HQ request: kinked-truth disagreement between Theory and the VP): calibrated grid (pq only;
#                  n to 32k) and raw lambda = n^a (PQT, n to 16k)
#         lamlong = discriminator cells re-run long (30k kept after 3k burn-in), started at the first-pass median lambda (Theory)
#         lamxl = HQ-approved extra-long chains for the deciding learned-lambda cells: b0 = n^-2.5, sin and PQT, n = 2k (100k kept, 10x)
#                 and 8k (250k kept, 25x), started at the first-pass median lambda
#         kink25 = calibrated pq at a = 5/2 (completes the kinked-truth set; p1x was cancelled for budget)
#         kink2426 = calibrated grid, kinked truth (pq), a in {2.4, 2.6} to bracket the risk minimiser (Theory)
#         twin  = Gaussian twin (scale-mixture variances frozen at 2/lambda^2), paired with T3/kink83/T3s83 Laplace runs (seeds 1-10)
#         T3s83 = Laplace sin at lambda = n^(8/3) (the twin's missing Laplace pair)
#         p1x   = default grid with the extra orders a in {1.5, 2, 2.5};  Qlam = quadratic-truth lambda sweep (P1, V = 0)
# One .rds per task under /home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E02/grid/<phase>/; existing outputs are skipped, so a re-run resumes.
args <- commandArgs(trailingOnly = TRUE)
phase <- if (length(args)) args[1] else "p1"
cores <- if (length(args) > 1) as.integer(args[2]) else as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2"))
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims")
OUT_BASE <- Sys.getenv("E02_OUT", "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E02")          # NOTS: /projects/ml75/fb31/BQTF/runs/E02-<phase>-<date>
source(file.path(E02_DIR, "e02_lib.R")); load_kernel()
cal <- readRDS(Sys.getenv("E02_CAL", "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E02/calibration.rds"))
A <- c(a1 = 1, a15_7 = 15/7, a9_4 = 9/4, a7_3 = 7/3, a3 = 3, a1.5 = 1.5, a2 = 2, a2.5 = 2.5, a8_3 = 8/3, a2.4 = 2.4, a2.6 = 2.6)
A_MAIN <- c("a1", "a15_7", "a9_4", "a7_3", "a3"); A_EXTRA <- c("a1.5", "a2", "a2.5")   # extra orders requested by Theory
NS <- c(250, 500, 1000, 2000, 4000, 8000, 16000, 32000)
REPS <- 1:20
out_root <- file.path(OUT_BASE, "grid", phase)
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)

tasks <- switch(phase,
  p1 = expand.grid(truth = c("quad", "sin", "pq"), noise = "gauss", tau = 0.5, a = A_MAIN, n = NS, seed = REPS, stringsAsFactors = FALSE),
  p1x = expand.grid(truth = c("quad", "sin", "pq"), noise = "gauss", tau = 0.5, a = A_EXTRA, n = NS, seed = REPS, stringsAsFactors = FALSE),
  p2 = rbind(expand.grid(truth = c("quad", "sin", "pq"), noise = "t2",    tau = c(0.5, 0.9), a = A_MAIN, n = NS[NS <= 16000], seed = 1:10, stringsAsFactors = FALSE),
             expand.grid(truth = c("quad", "sin", "pq"), noise = "gauss", tau = 0.9,          a = A_MAIN, n = NS[NS <= 16000], seed = 1:10, stringsAsFactors = FALSE)),
  Qlam = expand.grid(truth = "quad", noise = c("gauss", "g25"), tau = 0.5, a = sprintf("e%.1f", seq(3, 9, by = 0.5)), n = c(1000, 4000), seed = 1:10, stringsAsFactors = FALSE),
  lamlearn2 = rbind(expand.grid(truth = "sin", noise = "g25", tau = 0.5, a = "B1e3", n = c(500, 2000, 8000), seed = 1:10, stringsAsFactors = FALSE),
                    expand.grid(truth = "PQT", noise = "g25", tau = 0.5, a = c("B1", "B1e3", "Bn2", "Bn25"), n = c(500, 2000, 8000), seed = 1:10, stringsAsFactors = FALSE)),
  lamlearn3 = expand.grid(truth = "quad", noise = "gauss", tau = 0.5, a = c("Bn2", "Bn2i"), n = c(500, 2000, 8000), seed = 1:10, stringsAsFactors = FALSE),
  T3 = rbind(expand.grid(truth = c("sin", "PQT"), noise = "g25", tau = 0.5, a = c("b1.5", "b2", "b15_7", "b9_4", "b7_3", "b2.5"), n = c(250, 500, 1000, 2000, 4000, 8000, 16000), seed = REPS, stringsAsFactors = FALSE),
             expand.grid(truth = c("sin", "PQT"), noise = "g25", tau = 0.9, a = c("b1.5", "b2", "b15_7", "b9_4", "b7_3", "b2.5"), n = c(250, 500, 1000, 2000, 4000), seed = REPS, stringsAsFactors = FALSE),
             expand.grid(truth = c("sin", "PQT"), noise = "cauchy10", tau = 0.5, a = c("b1.5", "b2", "b15_7", "b9_4", "b7_3", "b2.5"), n = c(250, 500, 1000, 2000, 4000), seed = 1:10, stringsAsFactors = FALSE)),
  T3lam = expand.grid(truth = c("sin", "PQT"), noise = "g25", tau = 0.5, a = sprintf("e%.1f", seq(3, 9, by = 0.5)), n = c(1000, 4000), seed = 1:10, stringsAsFactors = FALSE),
  lamlearn = expand.grid(truth = "sin", noise = "g25", tau = 0.5, a = c("B1", "Bn2", "Bn25"), n = c(500, 2000, 8000), seed = 1:10, stringsAsFactors = FALSE),
  kink83 = rbind(expand.grid(truth = "pq", noise = "gauss", tau = 0.5, a = "a8_3", n = NS, seed = REPS, stringsAsFactors = FALSE),
                 expand.grid(truth = "PQT", noise = "g25", tau = 0.5, a = "b8_3", n = c(250, 500, 1000, 2000, 4000, 8000, 16000), seed = REPS, stringsAsFactors = FALSE)),
  lamlong = expand.grid(truth = c("sin", "PQT"), noise = "g25", tau = 0.5, a = c("Bn2", "Bn25"), n = c(500, 2000, 8000), seed = 1:10, stringsAsFactors = FALSE),
  lamxl = expand.grid(truth = c("sin", "PQT"), noise = "g25", tau = 0.5, a = "Bn25", n = c(8000, 2000), seed = 1:10, stringsAsFactors = FALSE),
  kink25 = expand.grid(truth = "pq", noise = "gauss", tau = 0.5, a = "a2.5", n = NS, seed = REPS, stringsAsFactors = FALSE),
  kink2426 = expand.grid(truth = "pq", noise = "gauss", tau = 0.5, a = c("a2.4", "a2.6"), n = NS, seed = REPS, stringsAsFactors = FALSE),
  twin = expand.grid(truth = c("sin", "PQT"), noise = "g25", tau = 0.5, a = c("b2", "b9_4", "b2.5", "b8_3"), n = c(1000, 4000, 16000), seed = 1:10, stringsAsFactors = FALSE),
  T3s83 = expand.grid(truth = "sin", noise = "g25", tau = 0.5, a = "b8_3", n = c(1000, 4000, 16000), seed = 1:10, stringsAsFactors = FALSE),
  lamcurve = expand.grid(truth = c("quad", "sin", "pq"), noise = "gauss", tau = 0.5, a = sprintf("L%02d", 1:11), n = c(2000, 8000), seed = REPS, stringsAsFactors = FALSE),
  stop("unknown phase"))
# lamcurve: Lam = Lam15/7(n) * 10^g, g in -2..+2 (11 points), i.e. two decades either side of Padilla's tuning.
B_EXP <- c(b1.5 = 1.5, b2 = 2, b15_7 = 15/7, b9_4 = 9/4, b7_3 = 7/3, b2.5 = 2.5, b8_3 = 8/3)
# returns lambda*sigma; labels: aXX = calibrated c_a n^a on lambda*sigma; bXX = lambda = n^a (Theory); eX.X = lambda = 10^X; LXX = lamcurve
lam_sigma <- function(a, n, sig) {
  if (startsWith(a, "b")) return(n^B_EXP[[a]] * sig)
  if (startsWith(a, "e")) return(10^as.numeric(substring(a, 2)) * sig)
  lam_fun(a, n)
}
lam_fun <- function(a, n) {
  if (startsWith(a, "L")) { g <- seq(-2, 2, length.out = 11)[as.integer(substring(a, 2))]; return(cal$Lstar * (n / 500)^(15/7) * 10^g) }
  cal$Lstar * (n / 500)^A[[a]]                       # lambda * sigma = c_a n^a with c_a = Lstar / 500^a
}
tasks$file <- file.path(out_root, sprintf("%s_%s_t%03d_%s_n%05d_s%03d.rds", tasks$truth, tasks$noise, round(100 * tasks$tau), tasks$a, tasks$n, tasks$seed))
todo <- tasks[!file.exists(tasks$file), ]
todo <- todo[order(-todo$n, todo$seed), ]             # largest first for load balance
# Slurm array slicing: task k of K takes every K-th remaining task (outputs are per task, so slices never collide)
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
if (K > 1) todo <- todo[(seq_len(nrow(todo)) - 1L) %% K == (k %% K), ]
cat(sprintf("[%s] phase %s: %d tasks, %d to do, %d cores\n", format(Sys.time()), phase, nrow(tasks), nrow(todo), cores))
burn_keep <- function(n) list(burn = 1000L, keep = 5000L, thin = 5L)
B0 <- function(a, n) switch(a, B1 = 1, B1e3 = 1e-3, Bn2 = n^-2, Bn2i = n^-2, Bn25 = n^-2.5)
LAM0 <- function(a, n) if (a == "Bn2i") 0.3 * n^(9/4) else n - 3          # initial lambda (Theory's suggestion for Bn2i)
LEARN <- phase %in% c("lamlearn", "lamlearn2", "lamlearn3", "lamlong", "lamxl")
# first-pass (lamlearn/lamlearn2) median lambda per cell, used as the lamlong start (a legitimate start; it does not bias the target)
LAM_FIRST <- list(sin = list(Bn2 = c(`500` = 1.11e5, `2000` = 3.85e6, `8000` = 1.10e8), Bn25 = c(`500` = 1.13e5, `2000` = 3.89e6, `8000` = 1.24e8)),
                  PQT = list(Bn2 = c(`500` = 3.46e5, `2000` = 1.00e7, `8000` = 2.37e8), Bn25 = c(`500` = 6.92e5, `2000` = 1.71e7, `8000` = 4.05e8)))

res <- parallel::mclapply(seq_len(nrow(todo)), function(i) {
  tk <- todo[i, ]; bk <- burn_keep(tk$n)
  r <- tryCatch({
    dat <- make_data(tk$truth, tk$noise, tk$tau, tk$n, tk$seed)
    sig <- sigma0(tk$noise, tk$tau)
    if (LEARN) {                                         # start at lambda = m (the paper's initial value), MAP at that penalty
      LONG <- phase %in% c("lamlong", "lamxl")
      lam <- if (LONG) LAM_FIRST[[tk$truth]][[tk$a]][[as.character(tk$n)]] else LAM0(tk$a, tk$n); Lam <- lam * sig; b0 <- B0(tk$a, tk$n)
      start <- qtf_map_best(dat$y, tk$tau, Lam)
      set.seed(tk$seed + 1000L)
      ch <- run_gibbs_frozen(dat$y, dat$theta_star, tk$tau, lam, sig, start, burn = 3000L, keep = if (phase == "lamxl") (if (tk$n >= 8000) 250000L else 100000L) else if (LONG) 30000L else 10000L,
                             thin = if (phase == "lamxl") (if (tk$n >= 8000) 250L else 100L) else if (LONG) 30L else 10L,
                             learn_lambda = TRUE, a0 = 1, b0 = b0, asis = TRUE)
      lam <- ch$summ[["lam_mean"]]; Lam <- lam * sig     # MAP error reported at the posterior-mean lambda
      t0 <- proc.time()[["elapsed"]]; map <- qtf_map_best(dat$y, tk$tau, Lam); t_map <- proc.time()[["elapsed"]] - t0
    } else {
      Lam <- lam_sigma(tk$a, tk$n, sig); lam <- Lam / sig
      t0 <- proc.time()[["elapsed"]]; map <- qtf_map_best(dat$y, tk$tau, Lam); t_map <- proc.time()[["elapsed"]] - t0
      set.seed(tk$seed + 1000L)
      ch <- run_gibbs_frozen(dat$y, dat$theta_star, tk$tau, lam, sig, map, burn = bk$burn, keep = bk$keep, thin = bk$thin, twin = (phase == "twin"))
    }
    row <- data.frame(truth = tk$truth, noise = tk$noise, tau = tk$tau, a = tk$a, n = tk$n, seed = tk$seed, sigma = sig, Lam = Lam, lambda = lam,
                      map_d2 = Delta2(map - dat$theta_star), map_mse = mse(map - dat$theta_star), map_solver = attr(map, "solver"),
                      map_pen_ratio = lam * sum(abs(D3(map))) / (tk$n - 3), pm_vs_map_d2 = Delta2(ch$post_mean - map), t_map = t_map,
                      t(ch$summ), t(spline_bias(dat$theta_star, dat$y, kappa_eff(tk$noise, tk$tau), lam)), twin = (phase == "twin"), stringsAsFactors = FALSE)
    saveRDS(list(row = row, trace = ch$trace, post_mean = ch$post_mean, map = as.numeric(map)), tk$file)
    "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("[%s] task %s failed: %s\n", format(Sys.time()), basename(tk$file), r))
  r
}, mc.cores = cores, mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
