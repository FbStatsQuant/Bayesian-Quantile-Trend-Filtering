# E-10 joint check: J = 2 upper levels (0.75, 0.95), VS, Normal, n = 500, data seed 1, chain seed 1001, 30k / 10k,
# lambda ~ Gamma(1, b0), b0 from env E10_B0 (default 1e-5).  Usage: Rscript e10_joint_check.R <asis_q rule: poly | fixed | auto | head>
# env E10_JOINT_DIR: folder of the joint sampler (default method/joint); rule "head" = a pre-E-10 copy of the script (no asis_q argument)
suppressPackageStartupMessages(library(coda))
rule <- commandArgs(trailingOnly = TRUE)[1]; out <- Sys.getenv("E10_OUT", "engineering/E10_Lambda_Mixing/joint_check"); dir.create(out, showWarnings = FALSE, recursive = TRUE)
owd <- setwd(Sys.getenv("E10_JOINT_DIR", "method/joint")); L <- readLines("Joint_Sampler_PMALA_Augmented.R")
eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); load_box_cpp(); setwd(owd)
tl <- c(0.75, 0.95); dat <- simulate_data(1, 500L, tl, "VS", "Normal"); set.seed(1001)
b0j <- as.numeric(Sys.getenv("E10_B0", "1e-5"))
ja <- list(dat$y, tl, 2L, 1, b0j, 0.1, 0.1, 30000L, 10000L, delta_init, NULL, adapt_target, adapt_gain, adapt_kappa, delta_bounds,
           metric = "curv", c_fixed = 0, rho = NULL, iters = admm_iter, mh = TRUE, adapt = TRUE, warm = warm_sweeps, gamma_warm = gamma_warm,
           kappa = kappa_metric, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0, zeta_scale = zeta_scale, ctrl = box_ctrl, verbose = TRUE)
if (rule != "head") ja$asis_q <- rule
fit <- do.call(gibbs_joint_pmala, ja)
post <- 10001:30000; est <- apply(fit$theta, c(2, 3), mean); lo <- apply(fit$theta, c(2, 3), quantile, .025); hi <- apply(fit$theta, c(2, 3), quantile, .975)
cm <- crossing_metrics(est, fit$theta); mins <- fit$seconds / 60
ess_th <- apply(fit$theta, c(2, 3), function(v) as.numeric(effectiveSize(v)))
res <- data.frame(rule = rule, b0 = b0j, tau = tl, q_grid = paste(fit$asis_q_grid %||% 3, collapse = ","), minutes = round(mins, 1),
  lambda_mean = colMeans(fit$lambda[post, ]), lambda_ess = apply(fit$lambda[post, ], 2, function(v) as.numeric(effectiveSize(v))),
  sigma_ess = apply(fit$sigma[post, ], 2, function(v) as.numeric(effectiveSize(v))), theta_ess_median = apply(ess_th, 2, median),
  mse = colMeans((est - dat$truth)^2), coverage = colMeans(dat$truth >= lo & dat$truth <= hi), acc = fit$acc_post, asis_moved = fit$asis_moved_post,
  draws_any_cross = cm$adjacent$draws_any_cross[1], max_draw_violation = max(cm$adjacent$draws_max_violation), mean_curve_crossings = cm$all_pairs$n_cross[1])
res$lambda_ess_per_min <- res$lambda_ess / mins
print(res, digits = 4); write.csv(res, file.path(out, sprintf("joint_%s_b0_%g.csv", rule, b0j)), row.names = FALSE)
saveRDS(list(lambda = fit$lambda, sigma = fit$sigma), file.path(out, sprintf("joint_%s_b0_%g_traces.rds", rule, b0j)))
