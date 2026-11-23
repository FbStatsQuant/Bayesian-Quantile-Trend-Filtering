# Hyperparameter-spec screen (HQ 11-23; INTERNAL). Each spec defines a DIFFERENT posterior (Felipe's families, hyperparameters constant or
# functions of n; sigma ones may depend on tau; no data dependence). Its MSE is a property of that posterior, so we compute it with the exact
# augmented Gibbs (reaches the posterior; same family of targets as his sampler), on the SAME datasets as his runs and as the baseline posterior
# (his current priors, file prefix G_ in gibbs_vs/). Specs are listed in SPECS below; run selects SPEC_NAMES (comma list).
E07 <- Sys.getenv("E07_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "hyper"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
suppressPackageStartupMessages(library(posterior))
source(file.path(E07, "sampler", "e07_sampler.R")); e07_load(file.path(E07, "sampler"), Sys.getenv("E07_CACHE"))
pl <- readLines(file.path(E07, "Individual_Sampler_PMALA_Augmented_E07R1copy.R")); i <- grep("^simulate_data", pl); j <- i + which(pl[(i + 1):length(pl)] == "}")[1]
eval(parse(text = pl[i:j]))
b0_paper <- function(bl) if (bl == "VS") 1e-3 else 5e-4
# spec(bl, n, tau) -> list(a0, b0, a_s, b_s).  'bl' is used ONLY by the paper baseline (his per-signal b0); new specs must not use it.
SPECS <- list(
  H_FE  = function(bl, n, tau) list(a0 = n, b0 = 1, a_s = 0.001, b_s = 0.001),              # Felipe's example
  H_SIG = function(bl, n, tau) list(a0 = 1, b0 = b0_paper(bl), a_s = 0.001, b_s = 0.001),   # sigma hyperparameters only (lambda as paper)
  H_ONE = function(bl, n, tau) list(a0 = 1, b0 = 1e-3, a_s = 0.1, b_s = 0.1),                # one b0 for both signals (no per-signal tuning)
  A_H1  = function(bl, n, tau) list(a0 = 1, b0 = 1 / (5500 * (n / 500)^2.5), a_s = 0.1, b_s = 0.1),   # Astra: weak, centre L(n)
  A_H2  = function(bl, n, tau) list(a0 = 4, b0 = 4 / (5500 * (n / 500)^2.5), a_s = 0.1, b_s = 0.1),   # Astra: shape 4, same mean
  T_V2  = function(bl, n, tau) list(a0 = 1, b0 = b0_paper(bl) * (500 / n)^2.5, a_s = 0.1, b_s = 0.1),  # Theory H-V2 (= his method at n = 500)
  T_V2C = function(bl, n, tau) list(a0 = 1, b0 = 7e-4 * (500 / n)^2.5, a_s = 0.1, b_s = 0.1),          # Theory H-V2-common
  T_V2S2 = function(bl, n, tau) list(a0 = 2, b0 = 2 * b0_paper(bl) * (500 / n)^2.5, a_s = 0.1, b_s = 0.1)  # Theory H-V2-shape2
)
EXTRA <- Sys.getenv("SPEC_EXTRA")                                    # optional: R code defining more entries, e.g. 'SPECS$T1 <- function(bl,n,tau) ...'
if (nzchar(EXTRA)) eval(parse(text = EXTRA))
NAMES <- strsplit(Sys.getenv("SPEC_NAMES", paste(names(SPECS), collapse = ";")), "[;,]")[[1]]   # use ";" in sbatch --export (it splits on commas)
g <- function(n, bl, noise, tau, seeds) expand.grid(n = n, bl = bl, noise = noise, tau = tau, seed = seeds, stringsAsFactors = FALSE)
base <- rbind(g(500, c("VS", "S"), c("Normal", "Beta", "Mixed"), c(0.05, 0.5, 0.95), 1:5), g(1000, c("VS", "S"), "Normal", c(0.05, 0.5, 0.95), 1), g(2000, c("VS", "S"), "Normal", 0.5, 1))
tasks <- do.call(rbind, lapply(NAMES, function(s) cbind(spec = s, base, stringsAsFactors = FALSE)))
tasks$file <- file.path(OUT, sprintf("%s_n%05d_%s_%s_t%03d_s%d.rds", tasks$spec, tasks$n, tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$seed))
tasks <- tasks[!file.exists(tasks$file), ]; tasks <- tasks[order(-tasks$n), ]
cat(sprintf("[%s] spec screen: %d tasks (%s)\n", format(Sys.time()), nrow(tasks), paste(NAMES, collapse = ",")))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]
  r <- tryCatch({
    d <- simulate_data(tk$seed, tk$n, tk$tau, tk$bl, tk$noise); sp <- SPECS[[tk$spec]](tk$bl, tk$n, tk$tau); set.seed(tk$seed + 3000L)
    f <- bqtf_tf(d$y, tk$tau, move = "exact", standardize = FALSE, a0 = sp$a0, b0 = sp$b0, a_s = sp$a_s, b_s = sp$b_s, max_sweeps = 20000L)
    row <- data.frame(tk[1:6], a0 = sp$a0, b0 = sp$b0, a_s = sp$a_s, b_s = sp$b_s, seconds = f$seconds, sweeps = f$sweeps, converged = f$converged,
                      rhat_max = f$rhat_max, ess_loglam = f$ess_loglam, lam_med = median(f$lambda), sig_med = median(f$sigma),
                      mse = mean((f$mean - d$truth)^2), mciw = mean(f$hi - f$lo), cover = mean(d$truth >= f$lo & d$truth <= f$hi),
                      lam_q05 = unname(quantile(f$lambda, 0.05)), p_floor = mean(f$lambda < 1.6e-5 * tk$n^2.5))
    saveRDS(list(row = row, mean = f$mean, lo = f$lo, hi = f$hi), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
