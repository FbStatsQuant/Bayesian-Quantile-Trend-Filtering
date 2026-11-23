# JOINT GATE (HQ): Felipe's ORIGINAL joint non-crossing sampler (method/joint, unmodified, paper settings incl. 30k sweeps / 10k burn) vs
# joint v3 (exact reflective-HMC per level, e07_joint_v3.R), on the paper's joint design: VS, n = 500, tau 0.90..0.99, a0 = 1, b0 = 0.01,
# IG(0.1, 0.1); noises Normal, Beta, Mixed; seed 1 (JG_SEEDS). ARM = "F" or "V3" (V3 runs 2 chains of 30k sweeps / 10k burn).
CODE <- Sys.getenv("CODE"); OUT <- file.path(Sys.getenv("E07_OUT"), "joint_gate"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
ARM <- Sys.getenv("ARM", "V3"); SEEDS <- eval(parse(text = Sys.getenv("JG_SEEDS", "1")))
SET <- Sys.getenv("JG_SET", "tail"); BL <- strsplit(Sys.getenv("JG_BL", "VS"), ";")[[1]]
# the paper's joint designs: tail = experiments/extreme_quantiles (levels 0.90..0.99; b0 VS 0.01, S 0.001);
#                            central = experiments/interior_quantiles/joint_nots batch t50 (levels 0.2..0.8; b0 0.01)
taus <- if (SET == "tail") c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99) else c(0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80)
b0_of <- function(bl) if (SET == "tail" && bl == "S") 0.001 else 0.01
suppressPackageStartupMessages(library(posterior))
src <- readLines(file.path(CODE, "e02", "Individual_Sampler_PMALA_Augmented.R")); i0 <- grep("^simulate_data <- function", src); i1 <- grep("^# ---- Model pieces", src) - 1
eval(parse(text = src[i0:i1]))
if (ARM == "F") {
  L <- readLines(file.path(CODE, "ejoint", "Joint_Sampler_PMALA_Augmented.R")); k <- grep("^# ---- Main", L)[1]; E <- new.env(parent = globalenv())
  fname <- file.path(CODE, "ejoint", "Joint_Sampler_PMALA_Augmented.R"); E$commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", fname))
  eval(parse(text = L[seq_len(k - 1)]), E); E$load_box_cpp(file.path(CODE, "ejoint"), file.path(CODE, "e02"))
} else { Sys.setenv(E07_DIR = file.path(CODE, "sampler"), E07V3_DIR = CODE); source(file.path(CODE, "e07_joint_v3.R")); e07v3_load(cache = Sys.getenv("E07_CACHE")) }
tasks <- expand.grid(bl = BL, noise = c("Normal", "Beta", "Mixed"), seed = SEEDS, chain = if (ARM == "F") 1L else 1:2, stringsAsFactors = FALSE)
tasks$file <- file.path(OUT, ifelse(SET == "tail" & tasks$bl == "VS", sprintf("%s_%s_s%d_c%d.rds", ARM, tasks$noise, tasks$seed, tasks$chain),   # (first VS-tail run's names)
                                    sprintf("%s_%s_%s_%s_s%d_c%d.rds", SET, tasks$bl, ARM, tasks$noise, tasks$seed, tasks$chain))); tasks <- tasks[!file.exists(tasks$file), ]
cat(sprintf("[%s] joint gate %s: %d tasks\n", format(Sys.time()), ARM, nrow(tasks)))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]
  r <- tryCatch({
    y <- simulate_data(tk$seed, 500L, taus[1], tk$bl, tk$noise)$y; truths <- sapply(taus, function(t) simulate_data(tk$seed, 500L, t, tk$bl, tk$noise)$truth); b0 <- b0_of(tk$bl)
    if (ARM == "F") { options(bqtf.metric_cap = 1e8); set.seed(tk$seed + 1000L)
      fit <- E$gibbs_joint_pmala(y, taus, order = 2L, a0 = 1, b0 = b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = 30000L, gibbs_burn = 10000L,
        delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), metric = "curv",
        c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, warm = 200L, gamma_warm = 1e4, kappa = 3, adapt_all = TRUE, K = 1L,
        asis = TRUE, tol = 0, zeta_scale = 1, ctrl = c(method = 1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0), verbose = FALSE, keep_every = 1L)
      est <- apply(fit$theta, c(2, 3), mean); cross <- sum(apply(fit$theta, 1, function(M) sum(apply(M, 1, is.unsorted))))
      lam <- fit$lambda[10001:30000, , drop = FALSE]; secs <- fit$seconds
    } else {
      f <- bqtf_joint3(y, taus, 1, b0, 0.1, 0.1, 30000L, 10000L, chain_id = tk$chain, seed = tk$seed, init = "smooth", stack = FALSE, tblock = FALSE)
      est <- f$mean; cross <- sum(f$crossings); lam <- f$lambda[10001:30000, , drop = FALSE]; secs <- f$seconds
    }
    saveRDS(list(set = SET, bl = tk$bl, noise = tk$noise, taus = taus, b0 = b0, est = est, truths = truths, lam = lam[seq(1, nrow(lam), by = 10), , drop = FALSE], ess_loglam = apply(log(lam), 2, function(x) as.numeric(coda::effectiveSize(x))),
                 seconds = secs, crossings = cross, mse = colMeans((est - truths)^2)), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
