# =============================================================================
# Air-quality-like simulation (Brantley, Guinness & Chi 2020, Section 4.2 "Peak detection")
#
#   y_i = theta_i + s_i + eps_i,   i = 1, ..., n,   eps_i ~ N(0, 0.25^2)
#
#   theta (drift): natural cubic spline basis on x = (i - 0.5)/n with df ~ Poisson(n/100) + 1,
#                  coefficients ~ Exp(rate 1)
#   s (signal):    sum of Gaussian-density peaks; #peaks ~ Bin(n, 0.005), centers ~ U(1, n-1) (rounded),
#                  bandwidths ~ U(2, 12), each scaled by an area ~ N(20, 4^2)
#
# Generator transcribed from the authors' detrendr package, R/simluate_peaks.R (generate_peaks),
# https://github.com/halleybrantley/detrendr -- note the "+ 1" on the spline df, which the paper text omits.
# Identical to generate_peaks_design() in the authors' simulation code (detrendify repo, Code/sim_generating_functions.R).
#
# Fit: the individual sampler (Individual_Sampler_PMALA_Augmented.R) on the whole series y, one independent chain per tau.
# Target: the tau-quantile of y - s = theta + eps, i.e. theta_tau = theta + 0.25 * qnorm(tau)  (paper lines 745-746;
#         authors' Code/Fig8_sim_peaks_rmse.R: mean((trend - (df$baseline + qnorm(tau, sd = 0.25)))^2)).
# RMSE(tau) = sqrt( mean_i (theta_hat_tau,i - theta_tau,i)^2 ) over all n points (peaks not masked).
# =============================================================================

suppressPackageStartupMessages({ library(splines); library(ggplot2) })

# ---- Settings ---------------------------------------------------------------
seed   <- 1
n      <-500L
sd_eps <- 0.25
taus   <- c(0.1)   # paper's levels for the peaks design (Section 4.2)

# Sampler settings: defaults of Individual_Sampler_PMALA_Augmented.R, except order.
order        <- 2L         # k = 2: piecewise quadratic, D = 3rd differences (paper Section 2.2; the authors fit
                           # get_trend_BIC(y, tau, k = 3) in Code/Sim_detrendr.R, where detrendr's k is the differencing order)
prior_scale  <- "none"
a0 <- n;  b0 <- 0.01
a_sigma <- 0.1; b_sigma <- 0.1
gibbs_iter   <- 20000
gibbs_burn   <- 5000
delta_init   <- 0.2
adapt_target <- 0.55
adapt_gain   <- 1.0
adapt_kappa  <- 0.6
delta_bounds <- c(1e-8, 100)
lambda_init  <- NULL
metric       <- "curv"
kappa_metric <- 3
c_metric     <- 1e4
theta_init   <- "y"
mh_correct   <- TRUE
adapt_delta  <- TRUE
adapt_all    <- TRUE
warm_sweeps  <- 200L
gamma_warm   <- 1e4
admm_iter    <- 150L
admm_tol     <- 0
K_theta      <- 1L
lamjump      <- FALSE
lamjump_s    <- 0.3
asis_lambda  <- FALSE
admm_rho     <- NULL

# ---- Data -------------------------------------------------------------------
simulate_air <- function(seed, n, sd_eps = 0.25) {
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  x  <- seq(0.5, n, 1) / n
  df <- rpois(1, n / 100) + 1
  B  <- ns(x, df = df)                                  # n x df natural cubic spline basis
  beta  <- rexp(ncol(B), 1)
  theta <- as.numeric(B %*% beta)

  n_peaks <- rbinom(1, n, 0.005)
  centers <- round(runif(n_peaks) * (n - 2) + 1)
  areas   <- rnorm(n_peaks, 20, 4)
  widths  <- runif(n_peaks) * 10 + 2
  s <- numeric(n)
  for (j in seq_len(n_peaks)) s <- s + areas[j] * dnorm(seq_len(n), mean = centers[j], sd = widths[j])

  eps <- sd_eps * rnorm(n)
  list(t = seq_len(n), x = x, y = theta + s + eps, theta = theta, s = s, eps = eps,
       df = df, B = B, beta = beta, peaks = data.frame(center = centers, area = areas, width = widths))
}

dat <- simulate_air(seed, n, sd_eps)
cat(sprintf("n = %d | spline df = %d | peaks = %d\n", n, dat$df, nrow(dat$peaks)))
print(dat$peaks)

# ---- Plots ------------------------------------------------------------------
pd <- data.frame(t = dat$t, y = dat$y, theta = dat$theta, s = dat$s, eps = dat$eps)

print(ggplot(pd, aes(t, theta)) + geom_line(linewidth = 0.8) +
        labs(title = sprintf("Drift theta: natural cubic spline, df = %d, Exp(1) coefficients", dat$df),
             x = "t", y = expression(theta)) + theme_bw())

print(ggplot(pd, aes(t, s)) + geom_line(linewidth = 0.6, colour = "firebrick") +
        labs(title = sprintf("Signal s: %d Gaussian peaks", nrow(dat$peaks)), x = "t", y = "s") + theme_bw())

print(ggplot(pd, aes(t, eps)) + geom_point(size = 0.6, colour = "grey40") +
        labs(title = sprintf("Noise eps ~ N(0, %.2f^2)", sd_eps), x = "t", y = expression(epsilon)) + theme_bw())

print(ggplot(pd, aes(t, s + eps)) + geom_point(size = 0.6, colour = "grey40") +
        labs(title = "s + eps (y with the drift removed)", x = "t", y = expression(s + epsilon)) + theme_bw())

print(ggplot(pd, aes(t, y)) + geom_point(size = 0.6, colour = "grey50") +
        labs(title = "y = theta + s + eps", x = "t", y = "y") + theme_bw())

# ---- Sampler ----------------------------------------------------------------
# Load the function definitions of Individual_Sampler_PMALA_Augmented.R (everything above its "# ---- Main" block)
# into their own environment, so its pilot run does not execute and its settings do not overwrite the ones above.
.this_dir <- function() {
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)                                   # Rscript
  if (length(a)) return(dirname(normalizePath(sub("^--file=", "", a[[1L]]))))
  f <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)                               # source()
  if (!is.null(f)) return(dirname(normalizePath(f)))
  if (requireNamespace("rstudioapi", quietly = TRUE) && isTRUE(rstudioapi::isAvailable())) { # RStudio: Run
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(dirname(normalizePath(p)))
  }
  getwd()
}
sampler_file <- file.path(.this_dir(), "Individual_Sampler_PMALA_Augmented.R")
stopifnot(file.exists(sampler_file))
src <- readLines(sampler_file)
smp <- new.env(parent = globalenv())
eval(parse(text = src[seq_len(grep("^# ---- Main", src)[1L] - 1L)]), envir = smp)
smp$load_prox_cpp(smp$cpp_src)

# ---- Fit: one independent chain per tau, on the whole series y ---------------
res <- vector("list", length(taus)); qd <- vector("list", length(taus))
for (j in seq_along(taus)) {
  tau <- taus[j]
  cat(sprintf("\n==== tau = %.2f ====\n", tau))
  set.seed(seed + 1000)
  fit <- smp$gibbs_pmala_aug(dat$y, tau, order, a0, b0, a_sigma, b_sigma,
                             gibbs_iter, gibbs_burn, delta_init, lambda_init,
                             adapt_target, adapt_gain, adapt_kappa, delta_bounds, smp$tf_control,
                             metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                             mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm,
                             K = K_theta, asis = asis_lambda, tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s,
                             prior_scale = prior_scale, cmap = FALSE, kappa = kappa_metric, adapt_all = adapt_all)

  truth <- dat$theta + sd_eps * qnorm(tau)                      # theta_tau: tau-quantile of y - s
  est   <- colMeans(fit$theta)                                  # posterior mean of theta_tau
  lo    <- apply(fit$theta, 2, quantile, 0.025); hi <- apply(fit$theta, 2, quantile, 0.975)
  post  <- (gibbs_burn + 1):gibbs_iter
  res[[j]] <- data.frame(tau = tau, rmse = sqrt(mean((est - truth)^2)), mad = mean(abs(est - truth)),
                         coverage = mean(truth >= lo & truth <= hi), mciw = mean(hi - lo),
                         acc_post = fit$acc_post, lambda_mean = mean(fit$lambda[post]),
                         sigma_mean = mean(fit$sigma[post]), seconds = fit$seconds)
  qd[[j]] <- data.frame(t = dat$t, tau = tau, truth = truth, est = est, lo = lo, hi = hi)
}
res <- do.call(rbind, res)
print(res, digits = 4)

# ---- Plot: true vs estimated quantile ---------------------------------------
qd <- do.call(rbind, qd)
qd$panel <- factor(sprintf("tau = %.2f   |   RMSE = %.4f", qd$tau, res$rmse[match(qd$tau, res$tau)]),
                   levels = sprintf("tau = %.2f   |   RMSE = %.4f", res$tau, res$rmse))

print(ggplot(qd, aes(t)) +
        geom_ribbon(aes(ymin = lo, ymax = hi), fill = "firebrick", alpha = 0.2) +
        geom_line(aes(y = truth, colour = "true", linetype = "true"), linewidth = 0.7) +
        geom_line(aes(y = est, colour = "estimated", linetype = "estimated"), linewidth = 0.7) +
        facet_wrap(~ panel, ncol = 1, scales = "free_y") +
        scale_colour_manual(NULL, breaks = c("true", "estimated"), values = c(true = "black", estimated = "firebrick"),
                            labels = c(true = expression(theta[tau] == theta + 0.25 * Phi^-1 * (tau)),
                                       estimated = "posterior mean (95% band)")) +
        scale_linetype_manual(NULL, breaks = c("true", "estimated"), values = c(true = "solid", estimated = "dashed"),
                              labels = c(true = expression(theta[tau] == theta + 0.25 * Phi^-1 * (tau)),
                                         estimated = "posterior mean (95% band)")) +
        labs(title = sprintf("True vs estimated quantile trend (n = %d, seed = %d, k = %d)", n, seed, order),
             x = "t", y = "quantile") +
        theme_bw() + theme(legend.position = "top"))
