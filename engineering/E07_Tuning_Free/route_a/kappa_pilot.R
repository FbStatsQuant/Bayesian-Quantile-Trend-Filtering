# kappa-hat(l) pilot (Theory, theory/T06_Alignment/FABLE_B_Arule_gauss.md section 8; HQ pre-approved <= 1 core-h; INTERNAL).
# Fixed lambda = l, sigma learned ~ IG(0.1, 0.1) (E-02 exact frozen Gibbs, learn_sigma = TRUE), paper Gaussian heteroscedastic design,
# truths S and VS, n in {500, 2000}, tau in {0.5, 0.25, 0.05, 0.97}, l on a 10-point log grid from 4 to 2 / b_n, b_n = 1 / (5500 (n/500)^{5/2}).
# Output per (cell, l): kappa_hat = m - l * mean ||D3 theta||_1 = m (1 - mean pen) with pen = l ||D3 theta||_1 / m, MCSE = m sd(pen) / sqrt(ESS).
E02 <- Sys.getenv("E02_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "kappa_pilot"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
source(file.path(E02, "e02_lib.R")); load_kernel()
src <- readLines(file.path(E02, "Individual_Sampler_PMALA_Augmented.R")); i0 <- grep("^simulate_data <- function", src); i1 <- grep("^# ---- Model pieces", src) - 1
eval(parse(text = src[i0:i1]))
g <- expand.grid(bl = c("S", "VS"), n = c(500L, 2000L), tau = c(0.5, 0.25, 0.05, 0.97), li = 1:10, stringsAsFactors = FALSE)
g$file <- file.path(OUT, sprintf("%s_n%05d_t%03d_l%02d.rds", g$bl, g$n, round(100 * g$tau), g$li)); g <- g[!file.exists(g$file), ]; g <- g[order(-g$n), ]
cat(sprintf("[%s] kappa pilot: %d chains\n", format(Sys.time()), nrow(g)))
res <- parallel::mclapply(seq_len(nrow(g)), function(i) { tk <- g[i, ]
  r <- tryCatch({
    d <- simulate_data(1L, tk$n, tk$tau, tk$bl, "Normal"); m <- tk$n - 3L; bn <- 1 / (5500 * (tk$n / 500)^2.5)
    l <- exp(seq(log(4), log(2 / bn), length.out = 10))[tk$li]
    s0 <- mean(rho_tau(d$y - median(d$y), tk$tau)); th0 <- qtf_map_best(d$y, tk$tau, l * s0); set.seed(7000L + i)
    ch <- run_gibbs_frozen(d$y, d$truth, tk$tau, l, s0, th0, burn = 1000L, keep = 3000L, thin = 10L, learn_sigma = TRUE, a_sigma = 0.1, b_sigma = 0.1)
    pen <- ch$trace$pen; ess <- as.numeric(coda::effectiveSize(pen))
    row <- data.frame(tk[1:4], ell = l, b_n = bn, ell_bn = l * bn, m = m, kappa_hat = m * (1 - mean(pen)), mcse = m * sd(pen) / sqrt(ess), ess_pen = ess,
                      sigma_mean = mean(ch$trace$sigma[-(1:1000)]), d2_mean = ch$summ[["d2_mean"]], seconds = ch$summ[["seconds"]])
    saveRDS(row, tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
R <- do.call(rbind, lapply(list.files(OUT, full.names = TRUE), readRDS)); write.csv(R[order(R$bl, R$n, R$tau, R$li), ], file.path(OUT, "kappa_pilot.csv"), row.names = FALSE)
