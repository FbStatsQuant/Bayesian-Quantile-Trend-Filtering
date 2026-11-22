# Static equivalence checks, run by validate.sh from a validation snapshot's code directory (cwd = RUN/code).
# 1. common_air.R (simulate_air and the metric/processing code) is byte-identical to the file of the production run
#    air_n500_100seeds_20261008 (sha256 below), and its simulate_air() is textually identical to the definition in the
#    reference script Onizuka/source/onizuka_air_sim.R.
# 2. Onizuka/source/BQTF-function.R is byte-identical to the unchanged file used by Extreme_Onizuka and Air_sim/Onizuka (sha256 below),
#    and contains BQTF.MCMC.Lap.multi with the expected signature.
# 3. cfg agrees with the Laplace specification: n = 500, sd_eps = 0.25, TForder = 2, mc 8000 / burn 2000, sig.init (1, 1),
#    sparse = FALSE, 300 tasks in the seed-fastest / tau order, method onizuka_lap only.
# 4. The worker calls the sampler with exactly the specified arguments (static scan of the worker source).
options(warn = 1)
suppressPackageStartupMessages(library(splines))
source("Driver/config.R"); source("Driver/common_air.R")
sha <- function(f) strsplit(system2("sha256sum", shQuote(f), stdout = TRUE), " ")[[1]][1]
COMMON_AIR_SHA   <- "b12396de72540d518cf92ed279ae765236774bad349ea1d3086d76efb1ad21ac"   # Air_sim/Individual/common_air.R
BQTF_SHA         <- "58e073e2da8297ff6bacfcf598252c2a429cbd9e276252b4522f910185633553"   # Extreme_Onizuka/source and Air_sim/Onizuka/source
stopifnot(identical(sha("Driver/common_air.R"), COMMON_AIR_SHA))
cat("CHECK_OK Driver/common_air.R sha256 == production run's common_air.R", COMMON_AIR_SHA, "\n")
fun_def <- function(file, name) {
  ex <- parse(file, keep.source = FALSE)
  hit <- which(vapply(ex, function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name(name)), logical(1)))
  stopifnot(length(hit) == 1L)
  paste(deparse(ex[[hit]][[3]], width.cutoff = 500L), collapse = "\n")
}
stopifnot(identical(fun_def("Driver/common_air.R", "simulate_air"), fun_def("Onizuka/source/onizuka_air_sim.R", "simulate_air")))
cat("CHECK_OK simulate_air in common_air.R == definition in Onizuka/source/onizuka_air_sim.R\n")
dat <- simulate_air(1L, cfg$n, cfg$sd_eps)
cat(sprintf("  seed 1, n = %d: spline df %d, %d peaks, %d points with s > 0.5\n", cfg$n, dat$df, nrow(dat$peaks), sum(dat$s > 0.5)))
stopifnot(identical(sha("Onizuka/source/BQTF-function.R"), BQTF_SHA))
cat("CHECK_OK Onizuka/source/BQTF-function.R sha256 ==", BQTF_SHA, "\n")
ex <- parse("Onizuka/source/BQTF-function.R", keep.source = FALSE)
lap <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("BQTF.MCMC.Lap.multi")), as.list(ex))
stopifnot(length(lap) == 1L, identical(names(formals(eval(lap[[1]][[3]]))), c("X", "Y", "TForder", "pp", "mc", "sparse", "sig.init")))
cat("CHECK_OK BQTF.MCMC.Lap.multi(X, Y, TForder, pp, mc, sparse, sig.init) found\n")
# cfg
o <- cfg$onizuka
stopifnot(identical(o$sampler, "BQTF.MCMC.Lap.multi"), identical(o$sparse, FALSE), identical(o$sig.init, c(1, 1)),
          cfg$n == 500L, cfg$sd_eps == 0.25, cfg$order == 2L, cfg$sampler_seed_offset == 1000L, identical(cfg$methods, "onizuka_lap"),
          identical(cfg$taus, c(0.01, 0.05, 0.10)), cfg$signal_threshold == 0.5, identical(cfg$caa_thresholds, c(0.5, 0.75, 1, 1.2)))
if (!isTRUE(cfg$validation)) {
  stopifnot(o$mc == 8000L, o$burn == 2000L)
  g <- task_grid(cfg)
  if (!isTRUE(cfg$pilot)) {
    stopifnot(nrow(g) == 300L, identical(g$seed, rep(1:100, 3)), identical(g$tau, rep(c(0.01, 0.05, 0.10), each = 100)),
              identical(g$index, 1:300), all(g$method == "onizuka_lap"))
    cat("CHECK_OK production grid: 300 tasks, seed fastest then tau (1-100 tau 0.01, 101-200 tau 0.05, 201-300 tau 0.10)\n")
  }
}
# worker source: the exact call
w <- readLines("Onizuka/worker_onizuka_lap.R")
need <- c("env[[o$sampler]](X = seq_len(cfg$n), Y = dat$y, TForder = cfg$order, pp = row$tau,",
          "mc = o$mc, sparse = o$sparse, sig.init = o$sig.init)", "set.seed(row$seed + cfg$sampler_seed_offset)")
for (s in need) stopifnot(any(grepl(s, w, fixed = TRUE)))
iset <- grep("set.seed(row$seed + cfg$sampler_seed_offset)", w, fixed = TRUE); stopifnot(length(iset) == 1L)
stopifnot(grepl("rng_before", w[iset + 1L]), grepl("env[[o$sampler]]", w[iset + 2L], fixed = TRUE))   # nothing random between set.seed and the call
cat("CHECK_OK worker: set.seed(seed + 1000) immediately before BQTF.MCMC.Lap.multi(X = seq_len(n), Y = y, TForder = 2, pp = tau, mc, sparse = FALSE, sig.init = c(1, 1))\n")
cat("VERSIONS R", R.version.string, "| MASS", as.character(packageVersion("MASS")), "| GIGrvg", as.character(packageVersion("GIGrvg")),
    "| invgamma", as.character(packageVersion("invgamma")), "| MCMCpack", as.character(packageVersion("MCMCpack")),
    "| Bessel", if (requireNamespace("Bessel", quietly = TRUE)) as.character(packageVersion("Bessel")) else "absent (skipped by the worker shim)", "\n")
cat("VALIDATE_CHECKS_SUCCESS\n")
