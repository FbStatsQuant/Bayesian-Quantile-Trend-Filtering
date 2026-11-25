# E-06 rate validation grid.  Usage: Rscript e06_run.R <phase>   (phase = main | supp | smoke)
#   main : primary schedule at both sigma arms; fallback at Abar (both tau); Padilla at Abar (tau = 1/2)     -> 70 configs
#   supp : fallback and Padilla at S0; Padilla at Abar, tau = 0.9                                             -> 50 configs
#   smoke: 2 small fits per law, to check the pipeline
# Each config runs n = 1k .. 32k (doubling) x seeds 1..20; seed s gives the same data across schedules and sigma arms.
# Output per fit: one small .rds (summary row + thinned Delta2 and ||.||_n^2 traces, 1000 draws each).
args <- commandArgs(trailingOnly = TRUE); phase <- if (length(args)) args[1] else "smoke"
E06_DIR <- Sys.getenv("E06_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E06_Rate_Validation")
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims")
OUT <- Sys.getenv("E06_OUT", "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E06")
source(file.path(E02_DIR, "e02_lib.R")); source(file.path(E06_DIR, "e06_lib.R")); load_kernel()
cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2"))
cal <- readRDS(file.path(OUT, "calibration.rds"))
NOISES <- names(STD); TRUTHS <- c("pq", "sin"); NS <- 1000 * 2^(0:5); SEEDS <- 1:20
g <- function(sched, arm, tau, n = NS, seed = SEEDS, noise = NOISES)
  expand.grid(truth = TRUTHS, noise = noise, tau = tau, sched = sched, arm = arm, n = n, seed = seed, stringsAsFactors = FALSE)
tasks <- switch(phase,
  main  = rbind(g("primary", c("Abar", "S0"), c(0.5, 0.9)), g("fallback", "Abar", c(0.5, 0.9)), g("padilla", "Abar", 0.5)),
  supp  = rbind(g(c("fallback", "padilla"), "S0", c(0.5, 0.9)), g("padilla", "Abar", 0.9)),
  supp_r = g("padilla", "Abar", 0.9),                       # HQ 2026-11-23: reduced supp only (10 configs, guard 26 core-h)
  smoke = g("primary", "Abar", c(0.5, 0.9), n = 1000, seed = 1),
  stop("unknown phase"))
out_root <- file.path(OUT, "grid", phase); dir.create(out_root, recursive = TRUE, showWarnings = FALSE)
tasks$file <- file.path(out_root, sprintf("%s_%s_t%03d_%s_%s_n%05d_s%03d.rds", tasks$truth, tasks$noise, round(100 * tasks$tau),
                                          tasks$sched, tasks$arm, tasks$n, tasks$seed))
todo <- tasks[!file.exists(tasks$file), ]
todo <- todo[order(-todo$n, todo$seed), ]                    # largest first for load balance
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
if (K > 1) todo <- todo[(seq_len(nrow(todo)) - 1L) %% K == (k %% K), ]
cat(sprintf("[%s] E-06 phase %s: %d tasks, %d to do here, %d cores\n", format(Sys.time()), phase, nrow(tasks), nrow(todo), cores))
thin_idx <- seq(5L, 5000L, by = 5L)

res <- parallel::mclapply(seq_len(nrow(todo)), function(i) {
  tk <- todo[i, ]
  r <- tryCatch({
    dat <- make_data(tk$truth, tk$noise, tk$tau, tk$n, tk$seed)
    sig <- sigma_arm(tk$arm, tk$noise, tk$tau); sc <- SCHED[SCHED$sched == tk$sched, ]
    Ls <- cal$Lam_star[cal$truth == tk$truth & cal$noise == tk$noise & cal$tau == tk$tau]
    Lam <- Ls * (tk$n / N0)^sc$a; lam <- Lam / sig
    t0 <- proc.time()[["elapsed"]]; map <- qtf_map_best(dat$y, tk$tau, Lam); t_map <- proc.time()[["elapsed"]] - t0
    set.seed(tk$seed + 1000L)
    ch <- run_gibbs_frozen(dat$y, dat$theta_star, tk$tau, lam, sig, map, burn = 1000L, keep = 5000L, thin = 5L, return_draws = TRUE)
    # rough component (Theory): Delta2 of P_perp(theta - theta*), the quadratic (null-space) part projected out, per thinned draw
    X <- qr.Q(qr(cbind(1, dat$u, dat$u^2)))
    Dl <- sweep(ch$draws, 2, dat$theta_star); ch$draws <- NULL
    Dl <- Dl - (Dl %*% X) %*% t(X)
    d2r <- rowMeans(pmin(abs(Dl), Dl^2)); rm(Dl)
    cr <- ch$post_mean - dat$theta_star; cr <- cr - X %*% crossprod(X, cr)
    row <- data.frame(tk[setdiff(names(tk), "file")], a = sc$a, pred = sc$pred, sigma = sig, sigma_bar = sigma_bar(tk$noise, tk$tau),
                      Lam = Lam, lambda = lam, map_d2 = Delta2(map - dat$theta_star), map_mse = mse(map - dat$theta_star),
                      map_solver = attr(map, "solver"), t_map = t_map,
                      t(ch$summ), mse_q95 = unname(quantile(ch$trace$ms, 0.95)),
                      d2r_mean = mean(d2r), d2r_q95 = unname(quantile(d2r, 0.95)), centre_d2r = Delta2(cr), stringsAsFactors = FALSE)
    saveRDS(list(row = row, d2 = ch$trace$d2[thin_idx], ms = ch$trace$ms[thin_idx], d2r = d2r), tk$file)
    "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("[%s] task %s failed: %s\n", format(Sys.time()), basename(tk$file), r))
  r
}, mc.cores = cores, mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
