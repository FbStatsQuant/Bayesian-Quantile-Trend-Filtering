# More seeds (HQ-approved): exact augmented Gibbs (G) vs Felipe's sampler (P) on the same posterior/datasets at n = 1000 (18 cells x seeds 1-3)
# and n = 2000 (VS, S x Normal x tau {0.05, 0.5, 0.95} x seeds 1-3). ARM = "P" or "G". Same per-fit outputs as gibbs_vs.R / variants.R.
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); ARM <- Sys.getenv("ARM", "G"); OUT <- file.path(Sys.getenv("E07_OUT"), "more_seeds"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
suppressPackageStartupMessages(library(posterior))
pl <- readLines(file.path(E07, "Individual_Sampler_PMALA_Augmented_E07R1copy.R"))
if (ARM == "G") { source(file.path(E07, "sampler", "e07_sampler.R")); e07_load(file.path(E07, "sampler"), Sys.getenv("E07_CACHE"))
  i <- grep("^simulate_data", pl); j <- i + which(pl[(i + 1):length(pl)] == "}")[1]; eval(parse(text = pl[i:j]))
} else { pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]; PAPER <- new.env(parent = globalenv()); fname <- file.path(E02, "Individual_Sampler_PMALA_Augmented.R")
  PAPER$commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", fname))
  eval(parse(text = pl), envir = PAPER); PAPER$load_prox_cpp(file.path(E02, "prox_admm_metric.cpp")); simulate_data <- PAPER$simulate_data }
paper_cfg <- function(bl) if (bl == "VS") list(b0 = 1e-3, asis = TRUE, it = 30000L, burn = 10000L) else list(b0 = 5e-4, asis = FALSE, it = 20000L, burn = 5000L)
g <- function(n, noise, seeds) expand.grid(n = n, bl = c("VS", "S"), noise = noise, tau = c(0.05, 0.5, 0.95), seed = seeds, stringsAsFactors = FALSE)
tasks <- rbind(g(1000, c("Normal", "Beta", "Mixed"), 1:3), g(2000, "Normal", 1:3))
tasks$file <- file.path(OUT, sprintf("%s_n%05d_%s_%s_t%03d_s%d.rds", ARM, tasks$n, tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$seed))
tasks <- tasks[!file.exists(tasks$file), ]; tasks <- tasks[order(-tasks$n, tasks$bl != "VS"), ]
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
if (K > 1) tasks <- tasks[(seq_len(nrow(tasks)) - 1L) %% K == (k %% K), ]
cat(sprintf("[%s] more_seeds %s: %d tasks here\n", format(Sys.time()), ARM, nrow(tasks)))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]
  r <- tryCatch({
    d <- simulate_data(tk$seed, tk$n, tk$tau, tk$bl, tk$noise); pc <- paper_cfg(tk$bl)
    if (ARM == "G") { set.seed(tk$seed + 3000L)
      f <- bqtf_tf(d$y, tk$tau, move = "exact", standardize = FALSE, a0 = 1, b0 = pc$b0, a_s = 0.1, b_s = 0.1, max_sweeps = 20000L)
      est <- f$mean; lo <- f$lo; hi <- f$hi; secs <- f$seconds; essl <- f$ess_loglam; lamm <- median(f$lambda); extra <- c(converged = f$converged, rhat_max = f$rhat_max)
    } else { options(bqtf.metric_cap = 1e8); set.seed(tk$seed + 1000L)
      fit <- PAPER$gibbs_pmala_aug(d$y, tk$tau, 2L, a0 = 1, b0 = pc$b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = pc$it, gibbs_burn = pc$burn,
               delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
               control = PAPER$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
               warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = pc$asis, tol = 0, lamjump = FALSE, verbose = FALSE)
      post <- (pc$burn + 1):pc$it; TH <- fit$theta; est <- colMeans(TH); lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
      secs <- fit$seconds; essl <- as.numeric(coda::effectiveSize(log(fit$lambda[post]))); lamm <- median(fit$lambda[post]); extra <- c(converged = NA, rhat_max = NA) }
    row <- data.frame(arm = ARM, tk[1:5], seconds = secs, ess_loglam = essl, lam_med = lamm, t(extra), mse = mean((est - d$truth)^2), mciw = mean(hi - lo),
                      cover = mean(d$truth >= lo & d$truth <= hi), stringsAsFactors = FALSE)
    saveRDS(list(row = row, mean = est, lo = lo, hi = hi), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
