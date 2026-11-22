# Munich rent application: individual P-MALA / Gibbs sampler (theta, lambda, sigma)
# ADAPTIVE-DELTA version, trend filtering order k = 2.
#
# Relation to the other files in this folder:
#   Munich_PMALA.R        fixed delta = 0.1, order k = 1   (previous run)
#   Munich_PMALA_k2.R     adaptive delta,   order k = 2    (this file)
#
# The sampler kernel is the one of
#   Simulations/My Samplers/Individual_Sampler_Scale_AdaptiveDelta.R
# with the Munich-specific adaptations already present in Munich_PMALA.R:
#   1. theta lives on the 134 distinct floor sizes; obs_index says which
#      floor size each rent belongs to, and theta[obs_index] expands theta
#      to observation level wherever the loss or gradient needs it.
#   2. The gradient of the smooth loss is computed per observation and then
#      summed within each floor size (rowsum).
#   3. The prox calls glmgen::trendfilter with x = locations so it solves
#      the trend filtering problem on the irregular grid.
#   4. D is the adjusted difference matrix for an irregular grid,
#      D^(k+1) = D^(1) diag{k / (x_{j+k} - x_j)} D^(k); on an equally spaced
#      grid it reduces to diff(diag(n), order + 1).
#
# Step size: Robbins-Monro on log(delta) (Andrieu & Thoms 2008, Sec. 4)
# during the burn-in, then FROZEN, so every retained draw comes from one
# fixed Markov kernel. delta_init is only a starting guess.
#
# Run with the working directory set to this script's folder
# (Data Applications/Munich Rent), e.g. in RStudio:
# Session > Set Working Directory > To Source File Location.

library(glmgen)

# Plotting is optional so the same file runs on a fitting-only host (e.g. owls,
# which has glmgen but not the tidyverse). When the packages are absent the
# script writes the fits and the CSV summaries and skips the figures; the
# figures are then produced from the CSVs by Munich_plots_k2.R.
has_plots <- all(vapply(c("ggplot2", "dplyr", "tidyr"), requireNamespace,
                        logical(1), quietly = TRUE))
if (has_plots) {
  library(ggplot2); library(dplyr); library(tidyr)
} else {
  message("ggplot2/dplyr/tidyr not available: fitting only, figures skipped ",
          "(run Munich_plots_k2.R to draw them from the CSVs).")
}

set.seed(800)

# Parameters
taus  <- c(0.10, 0.30, 0.50, 0.70, 0.90)
order <- 2          # k = 2: piecewise quadratic trend
eps   <- 0.01
gamma <- 0.1

a <- 1              # lambda ~ Gamma(a, b)
b <- 1

a_sigma <- 0.01
b_sigma <- 0.01

gibbs_iter <- 6000
gibbs_burn <- 1000

## --- ADAPTIVE DELTA: settings --------------------------------------------
delta_init   <- 0.01          # starting step size (order-of-magnitude guess)
adapt_delta  <- TRUE          # FALSE reproduces a fixed-delta sampler
delta_target <- 0.45          # target acceptance (midpoint of the 30%-60% band)
delta_band   <- c(0.30, 0.60) # acceptable range for post-burn-in acceptance
adapt_until  <- NULL          # last adapting iteration; NULL -> gibbs_burn
adapt_gain   <- 1.0           # gain constant c in gain_i = c / i^kappa
adapt_kappa  <- 0.6           # decay exponent, must lie in (0.5, 1]
delta_bounds <- c(1e-8, 10)   # hard clamp on delta
## -------------------------------------------------------------------------

results_dir <- "results_pmala_k2"
dir.create(results_dir, showWarnings = FALSE)

# MUNICH RENT DATA
# 2,035 apartments: rent (net rent per square meter, EUR/month) and
# fsize (floor size in square meters). Same file used by spmrf / Onizuka et al.
munich_file <- file.path("data", "munich.rda")
if (!file.exists(munich_file)) {
  dir.create("data", showWarnings = FALSE)
  download.file(
    "https://raw.githubusercontent.com/jrfaulkner/spmrf/master/data/munich.rda",
    munich_file, mode = "wb"
  )
}
load(munich_file)  # creates the data frame `munich`

munich <- munich[order(munich$fsize), ]

y         <- munich$rent                    # one rent per apartment (n = 2035)
locations <- sort(unique(munich$fsize))     # distinct floor sizes (134), sorted
obs_index <- match(munich$fsize, locations) # floor size of each apartment, 1..134

n_obs <- length(y)
n_loc <- length(locations)

cat("Munich data:", n_obs, "rents at", n_loc, "distinct floor sizes\n")
cat("Observations per floor size (min/median/max):",
    min(tabulate(obs_index)), "/", median(tabulate(obs_index)), "/",
    max(tabulate(obs_index)), "\n")
cat("Trend filtering order k =", order, "| lambda ~ Gamma(", a, ",", b, ")\n")
cat("Step size delta:", if (adapt_delta)
  "ADAPTIVE (Robbins-Monro on log delta during burn-in, frozen afterwards)"
  else "FIXED", "\n\n")

# FUNCTIONS

# Adjusted (order + 1) difference operator for an irregular grid.
# Equally spaced grid -> diff(diag(n), order + 1).
adjusted_difference_matrix <- function(x, order) {
  n <- length(x)
  D <- diff(diag(n))
  for (k in seq_len(order)) {
    weights <- k / (x[(k + 1):n] - x[1:(n - k)])
    D <- diff(diag(n - k)) %*% (diag(weights) %*% D)
  }
  D
}

D <- adjusted_difference_matrix(locations, order = order)
m <- nrow(D)
cat("Difference operator D:", m, "x", ncol(D), "\n\n")

rho_tau <- function(u, tau) ifelse(u >= 0, tau * u, (tau - 1) * u)

true_check_loss <- function(u, tau) rho_tau(u, tau)

# Gradient of the smoothed check loss with respect to theta:
# per-observation gradients, summed within each floor size.
grad_smooth_check <- function(y, theta, tau, sigma, eps) {
  u <- (y - theta[obs_index]) / sigma
  sigmoid <- 1 / (1 + exp(u / eps))
  obs_grad <- -(tau - sigmoid) / sigma
  grad <- numeric(n_loc)
  agg <- rowsum(obs_grad, obs_index)
  grad[as.integer(rownames(agg))] <- agg
  grad
}

neg_log_posterior_true <- function(theta, y, tau, lambda, sigma, D) {
  resid <- y - theta[obs_index]
  f_theta <- sum(true_check_loss(resid, tau)) / sigma
  g_theta <- lambda * sum(abs(D %*% theta))
  f_theta + g_theta
}

# Prox of gamma * lambda * ||D theta||_1: one trend filtering fit on the
# irregular floor-size grid.
prox_g <- function(z, gamma, lambda, order) {
  fit <- glmgen::trendfilter(
    x = locations, y = z, k = order, lambda = gamma * lambda,
    control = trendfilter.control.list(max_iter = 800L)
  )
  as.numeric(fit$beta)
}

grad_f_plus_g <- function(y, theta, tau, sigma, eps, gamma, lambda, order) {
  grad_f_theta <- grad_smooth_check(y, theta, tau, sigma, eps)
  x_tilde <- theta - gamma * grad_f_theta
  prox_step <- prox_g(x_tilde, gamma, lambda, order)
  (theta - prox_step) / gamma
}

# P-MALA SINGLE SAMPLE
# Also returns `alpha`, the MH acceptance probability min(1, exp(log_alpha)),
# which drives the step-size adaptation.
pmala_single_sample <- function(y, tau, lambda, sigma, gamma,
                                D, delta, eps, theta_current, order) {
  # Generate proposal
  grad <- grad_smooth_check(y, theta_current, tau, sigma, eps)
  z <- theta_current - delta * grad + sqrt(2 * delta) * rnorm(n_loc)
  theta_proposal <- prox_g(z, gamma, lambda, order)

  # Compute acceptance probability
  log_posterior_current  <- -neg_log_posterior_true(theta_current,  y, tau, lambda, sigma, D)
  log_posterior_proposal <- -neg_log_posterior_true(theta_proposal, y, tau, lambda, sigma, D)
  log_posterior_ratio <- log_posterior_proposal - log_posterior_current

  grad_psi_current <- grad_f_plus_g(y, theta_current, tau, sigma, eps, gamma, lambda, order)
  mu_current <- theta_current - delta * grad_psi_current

  grad_psi_proposal <- grad_f_plus_g(y, theta_proposal, tau, sigma, eps, gamma, lambda, order)
  mu_proposal <- theta_proposal - delta * grad_psi_proposal

  log_q_proposal_given_current <- -sum((theta_proposal - mu_current)^2) / (4 * delta)
  log_q_current_given_proposal <- -sum((theta_current - mu_proposal)^2) / (4 * delta)
  log_proposal_ratio <- log_q_current_given_proposal - log_q_proposal_given_current

  log_alpha <- min(0, log_posterior_ratio + log_proposal_ratio)
  if (!is.finite(log_alpha)) log_alpha <- -Inf   # NaN/Inf guard: treat as reject

  # Accept/reject
  accepted <- (log(runif(1)) < log_alpha)

  list(theta = if (accepted) theta_proposal else theta_current,
       accepted = accepted,
       alpha = exp(log_alpha))
}

# Inverse-Gamma sampler: if X ~ Gamma(a, rate=b), then 1/X ~ IG(a, b)
rinvgamma <- function(n, shape, rate) {
  1 / rgamma(n, shape = shape, rate = rate)
}

gibbs_three_block <- function(y, tau, a, b, a_sigma, b_sigma,
                              gamma, D, delta, gibbs_iter, gibbs_burn,
                              eps, theta_init, sigma_init, lambda_init, order,
                              adapt_delta = TRUE,
                              delta_target = 0.45,
                              delta_band = c(0.30, 0.60),
                              adapt_until = NULL,
                              adapt_gain = 1.0,
                              adapt_kappa = 0.6,
                              delta_bounds = c(1e-8, 10)) {

  ## --- ADAPTIVE DELTA: bookkeeping ---------------------------------------
  if (is.null(adapt_until)) adapt_until <- gibbs_burn
  if (adapt_delta && adapt_until > gibbs_burn) {
    warning("adapt_until > gibbs_burn: retained samples are drawn while delta is still changing.")
  }
  if (adapt_delta && (adapt_kappa <= 0.5 || adapt_kappa > 1)) {
    stop("adapt_kappa must lie in (0.5, 1] for a valid diminishing-adaptation schedule.")
  }
  delta_current  <- delta
  log_delta      <- log(delta_current)
  delta_chain    <- numeric(gibbs_iter)
  alpha_chain    <- numeric(gibbs_iter)
  accepted_chain <- logical(gibbs_iter)
  ## -----------------------------------------------------------------------

  gibbs_post <- gibbs_iter - gibbs_burn
  theta_gibbs_samples  <- matrix(NA, nrow = gibbs_post, ncol = n_loc)
  lambda_gibbs_samples <- numeric(gibbs_post)
  sigma_gibbs_samples  <- numeric(gibbs_post)

  lambda_gibbs_chain <- numeric(gibbs_iter)
  sigma_gibbs_chain  <- numeric(gibbs_iter)

  acceptance_count <- 0

  theta_current  <- theta_init
  lambda_current <- lambda_init
  sigma_current  <- sigma_init

  m <- nrow(D)

  cat("Starting three-block Gibbs sampler for tau =", tau, "\n")
  cat("Initial: lambda =", lambda_current, ", sigma =", round(sigma_current, 3),
      ", delta =", delta_current, "\n")
  if (adapt_delta) {
    cat("Adapting delta for iterations 1 ..", adapt_until,
        "| target acceptance =", delta_target,
        "| gain_i =", adapt_gain, "/ i^", adapt_kappa, "\n")
  }

  for (i in 1:gibbs_iter) {

    # --- 1. Sample theta | y, lambda, sigma via P-MALA ---
    pmala_result <- pmala_single_sample(
      y = y, tau = tau,
      lambda = lambda_current, sigma = sigma_current,
      gamma = gamma, D = D, delta = delta_current, eps = eps,
      theta_current = theta_current, order = order
    )
    theta_current <- pmala_result$theta
    if (pmala_result$accepted) acceptance_count <- acceptance_count + 1
    accepted_chain[i] <- pmala_result$accepted
    alpha_chain[i]    <- pmala_result$alpha

    ## --- ADAPTIVE DELTA: Robbins-Monro update on log(delta) --------------
    ## Uses the acceptance PROBABILITY alpha_i rather than the 0/1 indicator
    ## (same expectation, lower variance). Applied only while i <= adapt_until.
    delta_chain[i] <- delta_current            # delta used at this iteration
    if (adapt_delta && i <= adapt_until) {
      gain      <- adapt_gain / i^adapt_kappa
      log_delta <- log_delta + gain * (pmala_result$alpha - delta_target)
      log_delta <- min(max(log_delta, log(delta_bounds[1])), log(delta_bounds[2]))
      delta_current <- exp(log_delta)
    }
    ## ---------------------------------------------------------------------

    # --- 2. Sample lambda | y, theta, sigma ~ Gamma(a + m, b + S_D) ---
    S_D <- sum(abs(D %*% theta_current))
    lambda_current <- rgamma(1, shape = a + m, rate = b + S_D)

    # --- 3. Sample sigma | y, theta, lambda ~ IG(n + a_sigma, S_rho + b_sigma) ---
    S_rho <- sum(true_check_loss(y - theta_current[obs_index], tau))
    sigma_current <- rinvgamma(1, shape = n_obs + a_sigma, rate = S_rho + b_sigma)

    if (i %% 500 == 0) {
      cat("Iter", i,
          "| lambda =", round(lambda_current, 3),
          "| sigma =", round(sigma_current, 4),
          "| delta =", signif(delta_current, 4),
          "| Acc (cum):", round(acceptance_count / i, 3),
          "| Acc (last 500):", round(mean(accepted_chain[(i - 499):i]), 3),
          if (adapt_delta && i <= adapt_until) "| adapting" else "| frozen", "\n")
    }

    lambda_gibbs_chain[i] <- lambda_current
    sigma_gibbs_chain[i]  <- sigma_current

    if (i > gibbs_burn) {
      sample_idx <- i - gibbs_burn
      theta_gibbs_samples[sample_idx, ]  <- theta_current
      lambda_gibbs_samples[sample_idx]   <- lambda_current
      sigma_gibbs_samples[sample_idx]    <- sigma_current
    }
  }

  ## --- ADAPTIVE DELTA: post-burn-in acceptance check ----------------------
  acceptance_rate_post <- mean(accepted_chain[(gibbs_burn + 1):gibbs_iter])
  if (adapt_delta) {
    if (delta_current <= delta_bounds[1] * (1 + 1e-6) ||
        delta_current >= delta_bounds[2] * (1 - 1e-6)) {
      warning("delta pinned at its clamp: acceptance is not responding to the step size.")
    }
    if (acceptance_rate_post < delta_band[1] || acceptance_rate_post > delta_band[2]) {
      warning(sprintf("Post-burn-in acceptance rate %.3f is outside the band [%.2f, %.2f].",
                      acceptance_rate_post, delta_band[1], delta_band[2]))
    }
  }
  ## -----------------------------------------------------------------------

  list(
    tau                   = tau,
    theta_mean_estimate   = colMeans(theta_gibbs_samples),
    theta_median_estimate = apply(theta_gibbs_samples, 2, median),
    theta_lower           = apply(theta_gibbs_samples, 2, quantile, probs = 0.025),
    theta_upper           = apply(theta_gibbs_samples, 2, quantile, probs = 0.975),
    lambda_estimate       = mean(lambda_gibbs_samples),
    sigma_estimate        = mean(sigma_gibbs_samples),
    theta_samples         = theta_gibbs_samples,
    lambda_samples        = lambda_gibbs_samples,
    sigma_samples         = sigma_gibbs_samples,
    lambda_chain          = lambda_gibbs_chain,
    sigma_chain           = sigma_gibbs_chain,
    acceptance_rate       = acceptance_count / gibbs_iter,
    acceptance_rate_burn  = mean(accepted_chain[1:gibbs_burn]),
    acceptance_rate_post  = acceptance_rate_post,
    delta_final           = delta_current,
    delta_chain           = delta_chain,
    alpha_chain           = alpha_chain,
    accepted_chain        = accepted_chain,
    order                 = order,
    runtime_min           = NA_real_
  )
}

# RUN: one independent fit per quantile
theta_init_smart <- as.numeric(tapply(y, obs_index, median))  # per-floor-size median
sigma_init       <- max(IQR(y) / 1.349, 0.05)

fits <- list()
for (tau in taus) {
  cat("\n==============================================\n")
  t0 <- Sys.time()
  fit <- gibbs_three_block(
    y = y, tau = tau,
    a = a, b = b,
    a_sigma = a_sigma, b_sigma = b_sigma,
    gamma = gamma, D = D, delta = delta_init,
    gibbs_iter = gibbs_iter, gibbs_burn = gibbs_burn,
    eps = eps,
    theta_init = theta_init_smart,
    sigma_init = sigma_init,
    lambda_init = 20,
    order = order,
    adapt_delta  = adapt_delta,
    delta_target = delta_target,
    delta_band   = delta_band,
    adapt_until  = adapt_until,
    adapt_gain   = adapt_gain,
    adapt_kappa  = adapt_kappa,
    delta_bounds = delta_bounds
  )
  fit$runtime_min <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  cat("  done in", round(fit$runtime_min, 2), "min",
      "| delta:", delta_init, "->", signif(fit$delta_final, 4),
      "| acc (post burn-in):", round(fit$acceptance_rate_post, 3), "\n")
  fits[[paste0("q", 100 * tau)]] <- fit
  saveRDS(fit, file.path(results_dir, sprintf("fit_tau_%02d.rds", 100 * tau)))
}
saveRDS(fits, file.path(results_dir, "all_quantile_fits.rds"))

# SUMMARY
summary_table <- do.call(rbind, lapply(fits, function(fit) {
  data.frame(
    tau                  = fit$tau,
    order                = fit$order,
    lambda_estimate      = fit$lambda_estimate,
    sigma_estimate       = fit$sigma_estimate,
    delta_final          = fit$delta_final,
    acceptance_rate      = fit$acceptance_rate,
    acceptance_rate_burn = fit$acceptance_rate_burn,
    acceptance_rate_post = fit$acceptance_rate_post,
    frac_below           = mean(y < fit$theta_mean_estimate[obs_index]),
    runtime_min          = fit$runtime_min
  )
}))
row.names(summary_table) <- NULL

cat("\n=== FINAL RESULTS (one fit per quantile, k =", order, ") ===\n")
print(summary_table)
# frac_below should be close to tau: it is the fraction of rents that fall
# below the fitted quantile curve.

posterior_summary <- do.call(rbind, lapply(fits, function(fit) {
  data.frame(
    location = locations,
    tau      = fit$tau,
    estimate = fit$theta_mean_estimate,
    lower    = fit$theta_lower,
    upper    = fit$theta_upper
  )
}))
row.names(posterior_summary) <- NULL
write.csv(posterior_summary, file.path(results_dir, "posterior_summary.csv"),
          row.names = FALSE)
write.csv(summary_table, file.path(results_dir, "sampler_diagnostics.csv"),
          row.names = FALSE)

# Crossing check on the posterior-mean curves (the five fits are independent)
est_wide <- matrix(posterior_summary$estimate, nrow = n_loc)
colnames(est_wide) <- paste0("q", 100 * taus)
crossings <- sum(apply(est_wide, 1, function(r) any(diff(r) < 0)))
cat("\nLocations where the five posterior-mean curves are not ordered:",
    crossings, "of", n_loc, "\n")

# PLOTS (skipped when the tidyverse is unavailable; see Munich_plots_k2.R)
if (has_plots) {
df_data <- tibble(fsize = munich$fsize, rent = y)
df_fits <- as_tibble(posterior_summary) %>%
  mutate(quantile = factor(paste0(100 * tau, "%"),
                           levels = paste0(100 * sort(taus), "%")))

quantile_colors <- c("10%" = "#F15A60", "30%" = "#67B85C", "50%" = "#2196F3",
                     "70%" = "#2CCED2", "90%" = "#E229C2")

# Shared drawing routine: data, 95% bands, posterior-mean curves for the
# requested quantiles; sandwich = TRUE also shades between the first and
# last curve.
quantile_plot <- function(which_taus, sandwich = FALSE) {
  df <- filter(df_fits, tau %in% which_taus)
  p <- ggplot()
  if (sandwich) {
    lo <- filter(df, tau == min(which_taus))
    hi <- filter(df, tau == max(which_taus))
    band <- data.frame(location = lo$location, q_lo = lo$estimate, q_hi = hi$estimate)
    p <- p + geom_ribbon(data = band, aes(x = location, ymin = q_lo, ymax = q_hi),
                         fill = "grey80", alpha = 0.45)
  }
  p +
    geom_point(data = df_data, aes(x = fsize, y = rent),
               shape = 1, color = "grey55", alpha = 0.5, size = 1) +
    geom_ribbon(data = df, aes(x = location, ymin = lower, ymax = upper, fill = quantile),
                alpha = 0.25) +
    geom_line(data = df, aes(x = location, y = estimate, color = quantile),
              linewidth = 1) +
    scale_color_manual(values = quantile_colors) +
    scale_fill_manual(values = quantile_colors) +
    labs(x = "floor size (m2)", y = "rent (EUR per m2)", color = NULL, fill = NULL) +
    theme_minimal() +
    theme(legend.position = "top")
}

p_10_90    <- quantile_plot(c(0.10, 0.90), sandwich = TRUE)
p_30_50_70 <- quantile_plot(c(0.30, 0.50, 0.70))

for (name in c("munich_pmala_q10_q90", "munich_pmala_q30_q50_q70")) {
  p <- if (name == "munich_pmala_q10_q90") p_10_90 else p_30_50_70
  ggsave(file.path(results_dir, paste0(name, ".pdf")), p, width = 8.5, height = 5.2, bg = "white")
  ggsave(file.path(results_dir, paste0(name, ".png")), p, width = 8.5, height = 5.2, dpi = 220, bg = "white")
}
}

# Step-size and acceptance diagnostics, one row per quantile
delta_diag <- do.call(rbind, lapply(fits, function(fit) {
  data.frame(iter = seq_along(fit$delta_chain), tau = fit$tau,
             delta = fit$delta_chain,
             acc_roll = as.numeric(stats::filter(as.numeric(fit$accepted_chain),
                                                 rep(1 / 200, 200), sides = 1)))
}))
row.names(delta_diag) <- NULL
write.csv(delta_diag, file.path(results_dir, "delta_diagnostics.csv"), row.names = FALSE)

if (has_plots) {
p_delta <- ggplot(delta_diag, aes(x = iter, y = delta, color = factor(tau))) +
  geom_line() +
  geom_vline(xintercept = gibbs_burn, linetype = "dashed") +
  scale_y_log10() +
  labs(title = paste0("Munich, k = ", order,
                      ": adaptive delta (frozen after the dashed line)"),
       x = "Iteration", y = "delta (log scale)", color = "tau") +
  theme_minimal()

p_acc <- ggplot(delta_diag, aes(x = iter, y = acc_roll, color = factor(tau))) +
  geom_line() +
  geom_hline(yintercept = delta_target, linetype = "dotted") +
  geom_hline(yintercept = delta_band, linetype = "dashed", color = "gray40") +
  geom_vline(xintercept = gibbs_burn, linetype = "dashed") +
  coord_cartesian(ylim = c(0, 1)) +
  labs(title = "Rolling acceptance rate (window = 200 iterations)",
       x = "Iteration", y = "acceptance rate", color = "tau") +
  theme_minimal()

ggsave(file.path(results_dir, "munich_pmala_k2_delta_trace.png"), p_delta,
       width = 8.5, height = 4.5, dpi = 200, bg = "white")
ggsave(file.path(results_dir, "munich_pmala_k2_acceptance.png"), p_acc,
       width = 8.5, height = 4.5, dpi = 200, bg = "white")

if (interactive()) {
  dev.new(); print(p_10_90)
  dev.new(); print(p_30_50_70)
  dev.new(); print(p_delta)
  dev.new(); print(p_acc)
}
}

cat("\nDone. Fits and summaries in", results_dir,
    if (!has_plots) "(figures skipped: run Munich_plots_k2.R)" else "", "\n")
