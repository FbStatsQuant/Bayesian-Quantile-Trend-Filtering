# Munich rent application of Individual_Sampler_Scale.R
#
# Self-contained copy of the three-block Gibbs sampler (theta, lambda, sigma).
# The simulated data has been removed and replaced by the Munich rent data.
# All five quantiles (10%, 30%, 50%, 70%, 90%) are fitted in one run.
#
# What had to change relative to Individual_Sampler_Scale.R (and why):
# Munich has 2,035 rents observed at only 134 distinct floor sizes, and the
# floor sizes are not equally spaced. So:
#   1. theta lives on the 134 distinct floor sizes; obs_index says which
#      floor size each rent belongs to, and theta[obs_index] expands theta
#      to observation level wherever the loss or gradient needs it.
#   2. The gradient of the smooth loss is computed per observation and then
#      summed within each floor size (rowsum).
#   3. The prox calls glmgen::trendfilter with x = locations so it solves
#      the trend filtering problem on the irregular grid.
#   4. D is the Onizuka adjusted difference matrix for an irregular grid;
#      on an equally spaced grid it reduces to diff(diag(n), order + 1),
#      which is exactly the D_matrix() of the original script.
# Everything else (proposal, acceptance ratio, lambda and sigma updates)
# is line-for-line the same logic as Individual_Sampler_Scale.R.
#
# Run with the working directory set to this script's folder
# (Data Applications/Munich Rent), e.g. in RStudio:
# Session > Set Working Directory > To Source File Location.

library(glmgen)
library(ggplot2)
library(dplyr)
library(tidyr)

set.seed(800)

# Parameters
taus  <- c(0.10, 0.30, 0.50, 0.70, 0.90)
order <- 2
eps   <- 0.01
delta <- 0.1
gamma <- 0.1

a <- 1
b <- 1

a_sigma <- 0.01
b_sigma <- 0.01

gibbs_iter <- 6000
gibbs_burn <- 1000

results_dir <- "results_individual_scale"
dir.create(results_dir, showWarnings = FALSE)

# MUNICH RENT DATA (replaces the simulated data of the original script)
# 2,035 apartments: rent (response) and fsize (floor size in square meters).
# Same file used by spmrf / Onizuka et al.
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

y         <- munich$rent                   # one rent per apartment (n = 2035)
locations <- sort(unique(munich$fsize))    # distinct floor sizes (134), sorted
obs_index <- match(munich$fsize, locations) # floor size of each apartment, as 1..134

n_obs <- length(y)
n_loc <- length(locations)

cat("Munich data:", n_obs, "rents at", n_loc, "distinct floor sizes\n")
cat("Observations per floor size (min/median/max):",
    min(tabulate(obs_index)), "/", median(tabulate(obs_index)), "/",
    max(tabulate(obs_index)), "\n\n")

# FUNCTIONS

# Adjusted (order + 1) difference operator for an irregular grid
# (Remark 1 of Onizuka et al.). Equally spaced grid -> diff(diag(n), order+1).
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

  # Accept/reject
  accepted <- (log(runif(1)) < log_alpha)

  list(theta = if (accepted) theta_proposal else theta_current,
       accepted = accepted)
}

# Inverse-Gamma sampler: if X ~ Gamma(a, rate=b), then 1/X ~ IG(a, b)
rinvgamma <- function(n, shape, rate) {
  1 / rgamma(n, shape = shape, rate = rate)
}

gibbs_three_block <- function(y, tau, a, b, a_sigma, b_sigma,
                              gamma, D, delta, gibbs_iter, gibbs_burn,
                              eps, theta_init, sigma_init, lambda_init, order) {

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

  cat("Starting three-block Gibbs sampler for tau =", tau, "\n")
  cat("Initial: lambda =", lambda_current, ", sigma =", round(sigma_current, 3), "\n")

  for (i in 1:gibbs_iter) {

    # --- 1. Sample theta | y, lambda, sigma via P-MALA ---
    pmala_result <- pmala_single_sample(
      y = y, tau = tau,
      lambda = lambda_current, sigma = sigma_current,
      gamma = gamma, D = D, delta = delta, eps = eps,
      theta_current = theta_current, order = order
    )
    theta_current <- pmala_result$theta
    if (pmala_result$accepted) acceptance_count <- acceptance_count + 1

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
          "| Acc Rate:", round(acceptance_count / i, 3), "\n")
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
    acceptance_rate       = acceptance_count / gibbs_iter
  )
}

# RUN: one independent fit per quantile
theta_init_smart <- as.numeric(tapply(y, obs_index, median))  # per-floor-size median
sigma_init       <- max(IQR(y) / 1.349, 0.05)

fits <- list()
for (tau in taus) {
  cat("\n==============================================\n")
  fits[[paste0("q", 100 * tau)]] <- gibbs_three_block(
    y = y, tau = tau,
    a = a, b = b,
    a_sigma = a_sigma, b_sigma = b_sigma,
    gamma = gamma, D = D, delta = delta,
    gibbs_iter = gibbs_iter, gibbs_burn = gibbs_burn,
    eps = eps,
    theta_init = theta_init_smart,
    sigma_init = sigma_init,
    lambda_init = 20,
    order = order
  )
  saveRDS(fits[[paste0("q", 100 * tau)]],
          file.path(results_dir, sprintf("fit_tau_%02d.rds", 100 * tau)))
}
saveRDS(fits, file.path(results_dir, "all_quantile_fits.rds"))

# SUMMARY
summary_table <- do.call(rbind, lapply(fits, function(fit) {
  data.frame(
    tau             = fit$tau,
    lambda_estimate = fit$lambda_estimate,
    sigma_estimate  = fit$sigma_estimate,
    acceptance_rate = fit$acceptance_rate,
    frac_below      = mean(y < fit$theta_mean_estimate[obs_index])
  )
}))
row.names(summary_table) <- NULL

cat("\n=== FINAL RESULTS (one fit per quantile) ===\n")
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

# PLOT: all five quantile curves with 95% bands over the data
df_data <- tibble(fsize = munich$fsize, rent = y)
df_fits <- as_tibble(posterior_summary) %>%
  mutate(quantile = factor(paste0(100 * tau, "%"),
                           levels = paste0(100 * sort(taus), "%")))

quantile_colors <- c("10%" = "#F15A60", "30%" = "#67B85C", "50%" = "#2196F3",
                     "70%" = "#2CCED2", "90%" = "#E229C2")

p_munich <- ggplot() +
  geom_point(data = df_data, aes(x = fsize, y = rent),
             shape = 1, color = "grey67", alpha = 0.5, size = 1) +
  geom_ribbon(data = df_fits,
              aes(x = location, ymin = lower, ymax = upper, fill = quantile),
              alpha = 0.25) +
  geom_line(data = df_fits,
            aes(x = location, y = estimate, color = quantile),
            linewidth = 0.9) +
  scale_color_manual(values = quantile_colors) +
  scale_fill_manual(values = quantile_colors) +
  labs(title = "Munich rent: individual sampler, all quantiles",
       x = "floor size", y = "rent", color = NULL, fill = NULL) +
  theme_minimal() +
  theme(legend.position = "top")

ggsave(file.path(results_dir, "munich_all_quantiles.png"), p_munich,
       width = 9, height = 6, dpi = 220, bg = "white")
ggsave(file.path(results_dir, "munich_all_quantiles.pdf"), p_munich,
       width = 9, height = 6, bg = "white")

windows(); print(p_munich)

# PLOT: 10%-90% sandwich (grey band between the two outer quantile curves)
df_sandwich <- subset(df_fits, tau %in% c(0.10, 0.90))
df_band <- data.frame(
  location = locations,
  q10 = subset(df_sandwich, tau == 0.10)$estimate,
  q90 = subset(df_sandwich, tau == 0.90)$estimate
)

p_sandwich <- ggplot() +
  geom_ribbon(data = df_band, aes(x = location, ymin = q10, ymax = q90),
              fill = "grey80", alpha = 0.45) +
  geom_point(data = df_data, aes(x = fsize, y = rent),
             shape = 1, color = "grey55", alpha = 0.5, size = 1) +
  geom_ribbon(data = df_sandwich,
              aes(x = location, ymin = lower, ymax = upper, fill = quantile),
              alpha = 0.25) +
  geom_line(data = df_sandwich,
            aes(x = location, y = estimate, color = quantile),
            linewidth = 1) +
  scale_color_manual(values = quantile_colors) +
  scale_fill_manual(values = quantile_colors) +
  labs(title = "Munich rent: 10% and 90% quantile sandwich",
       x = "floor size", y = "rent", color = NULL, fill = NULL) +
  theme_minimal() +
  theme(legend.position = "top")

ggsave(file.path(results_dir, "munich_sandwich_10_90.png"), p_sandwich,
       width = 9, height = 6, dpi = 220, bg = "white")
ggsave(file.path(results_dir, "munich_sandwich_10_90.pdf"), p_sandwich,
       width = 9, height = 6, bg = "white")

windows(); print(p_sandwich)
