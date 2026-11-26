# Munich rent application: Onizuka et al. Bayesian quantile trend filtering,
# horseshoe prior, MCMC (Gibbs) version.
#
# The sampler is BQTF.MCMC.HS.multi from the authors' BQTF-function.R, copied
# below unchanged (it already handles repeated observations on an irregular
# grid, which is exactly the Munich situation). Everything else in this file
# is the same data processing, quantile loop, summaries and plots as
# Munich_PMALA.R, so the two methods are compared on identical footing:
# same data, same tau grid, same k = 2, same number of retained draws.
#
# Note on the difference operator at k = 2: the authors' code weights BOTH
# recursion steps by TForder, diag(TForder/diff(location)) and
# diag(TForder/diff(location, lag = 2)), whereas Munich_PMALA_k2.R uses the
# recursion index, diag(k/(x_{j+k} - x_j)) with k = 1 then k = 2. At k = 2 the
# two operators therefore differ by a factor of 2 in one step, which is a
# rescaling of the penalty absorbed by each method's own prior on its
# smoothing parameter. At k = 1 they coincide exactly. Each sampler is left
# with its authors' own convention.
#
# Run with the working directory set to this script's folder
# (Data Applications/Munich Rent), e.g. in RStudio:
# Session > Set Working Directory > To Source File Location.

library(MASS)
library(GIGrvg)
library(invgamma)
library(ggplot2)
library(dplyr)
library(tidyr)

set.seed(800)

# Parameters
taus    <- c(0.10, 0.30, 0.50, 0.70, 0.90)
TForder <- 2        # k = 2: piecewise quadratic trend
mc      <- 6000     # total Gibbs iterations (the function has no burn-in argument)
burn    <- 1000     # draws discarded afterwards, so 5000 are retained as in Munich_PMALA.R

results_dir <- "results_onizuka_k2"
dir.create(results_dir, showWarnings = FALSE)

# MUNICH RENT DATA (identical to Munich_PMALA.R)
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

y         <- munich$rent
locations <- sort(unique(munich$fsize))
obs_index <- match(munich$fsize, locations)

n_obs <- length(y)
n_loc <- length(locations)

cat("Munich data:", n_obs, "rents at", n_loc, "distinct floor sizes\n\n")

# ONIZUKA ET AL. SAMPLER (verbatim from BQTF-function.R)
# Arguments: X = covariate per observation, Y = response per observation,
# TForder = k, pp = quantile level, mc = number of Gibbs iterations.
# Returns an mc x n matrix of theta draws, n = number of distinct X values.

BQTF.MCMC.HS.multi <- function(X, Y, TForder, pp=0.5, mc=1000, sparse=F, sig.init=c(1,1)){

  Data <- data.frame(cbind(X,Y))
  colnames(Data) <- c("X","Y")
  Data <- Data[order(Data$X),]
  X <- Data$X
  Y <- Data$Y
  location <- unique(Data$X)
  n <- length(location)
  N <- length(Y)
  Ni <- rep(NA, n)
  y <- rep(NA, n)
  ymax <- rep(NA, n)
  num <- rep(0, n+1)
  for (i in 1:n) {
    data <- subset(Data, Data$X == location[i])
    Ni[i] <- length(data$Y)
    y[i] <- sum(data$Y)
    num[i+1] <- num[i]+Ni[i]
    ymax[i] <- max(data$Y)
  }

  ## settings
  psi <- (1-2*pp)/(pp*(1-pp))
  t2 <- 2/(pp*(1-pp))

  # difference operator
  D1 <- matrix(0, n-1,n)
  for (i in 1:n-1) {
    for (j in 1:n) {
      if(i == j){
        D1[i,j] <- 1
      }
      if(i+1 == j){
        D1[i,j] <- -1
      }
    }
  }
  if(TForder == 0){
    DD <- D1
    D <- rbind(c(1,rep(0, n-1)),DD)
  }
  if(TForder == 1){
    DD <- D1[1:(n-2),1:(n-1)]%*%diag(TForder/diff(location))%*%D1
    D <- rbind(t(matrix(c(1,rep(0, n-1),
                          0,1,rep(0, n-2)), n, 2)),DD)
  }
  if(TForder == 2){
    D2 <- D1[1:(n-2),1:(n-1)]%*%diag(TForder/diff(location))%*%D1
    DD <- D1[1:(n-3),1:(n-2)]%*%diag(TForder/diff(location,lag=2))%*%D2
    D <- rbind(t(matrix(c(1,rep(0, n-1),
                          0,1,rep(0, n-2),
                          0,0, 1, rep(0, n-3)), n, 3)),DD)
  }

  TD <- t(D)
  if(sparse){
    TD <- as(TD, "sparseMatrix")
    D <- as(D, "sparseMatrix")
  }


  ## MCMC box
  th.pos <- matrix(NA, mc, n)
  sig.pos <- c()

  ## initial value
  th <- y
  sig2 <- 1
  IGa_w <- rep(1, TForder+1)
  IGb_w <- rep(1, TForder+1)
  ww <- rep(1, n)   # local parameter in HS
  lower <- 10^(-6)   # lower bound
  upper <- 10^6   # upper bound
  tau2 <- 1   # global parameter in HS
  tau2vec <- rep(1,n)
  nu <- rep(1, n-TForder-1)   # latent parameter in HS
  xi <- 1   # latent parameter in HS
  vv <- rep(1, N)   # latent parameter in asymmetric Laplace,Exp(sig2)
  IGa <- sig.init[1]   # parameter of sig2 prior
  IGb <- sig.init[2]   # parameter of sig2 prior

  ## MCMC replications
  for(k in 1:mc){

    # theta
    cc <- rep(0, n)
    cc <- as.vector(sapply(split(vv^(-1), X), sum))/t2
    A <- solve(TD%*%diag(1/(ww*tau2vec))%*%D + diag(cc) )
    A <- (t(A) + A)/2
    B <- as.vector(sapply(split((Y-psi*vv)/vv, X), sum))/t2
    th <- mvrnorm(1, A%*%B, sig2*A)
    th.pos[k,] <- th

    ## asymmetric Laplace
    # sig2
    eta <- as.vector(D%*%th)
    bb <- rep(0, N)
    for (i in 2:(n+1)) {
      bb[(num[i-1]+1):num[i]] <- Y[(num[i-1]+1):num[i]]-th[i-1]
    }
    cc <- sum(((bb-psi*vv)^2)/vv)/(2*t2) + sum(eta^2/(ww*tau2vec))/2 + sum(vv) + IGb
    sig2 <- rinvgamma(1, (n+3*N)/2+IGa, cc)
    sig.pos[k] <- sig2

    # vv
    bb2 <- bb^2/(t2*sig2)
    cc <- 2/sig2 + psi^2/(t2*sig2)
    vv <- tapply(bb2, 1:N, rgig, n=1, lambda=1/2, psi=cc)
    vv[vv<lower] <- lower

    ## HS latent variables
    # ww
    bb <- eta^2/(2*tau2vec*sig2)
    ww[1:(TForder+1)] <- rinvgamma(TForder+1, 1/2+IGa_w, bb[1:(TForder+1)]+IGb_w)
    ww[(TForder+2):n] <- rinvgamma(n-TForder-1, 1, bb[(TForder+2):n]+1/nu)
    ww[ww<lower] <- lower
    ww[ww>upper] <- upper

    # nu
    nu <- rinvgamma(n-TForder-1, 1/2, 1+1/ww[(TForder+2):n])

    # tau2
    bbb <- sum(eta[(TForder+2):n]^2/(ww[(TForder+2):n]*sig2))/2 + 1/xi
    tau2 <- min(max(rinvgamma(1, (n-TForder)/2, bbb), 10^(-5)), 10^5)
    tau2vec <- c(rep(1,TForder+1), rep(tau2, n-TForder-1))

    # xi
    xi <- rinvgamma(1, 1/2, 1+1/tau2)
  }

  return(th.pos)
}

# RUN: one independent chain per quantile
fits <- list()
for (tau in taus) {
  cat("Onizuka MCMC-HS, tau =", tau, "...\n")
  t0 <- Sys.time()
  theta_draws <- BQTF.MCMC.HS.multi(X = munich$fsize, Y = y,
                                    TForder = TForder, pp = tau, mc = mc)
  theta_draws <- theta_draws[(burn + 1):mc, ]   # drop burn-in
  cat("  done in", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 2), "min\n")

  fits[[paste0("q", 100 * tau)]] <- list(
    tau                 = tau,
    theta_mean_estimate = colMeans(theta_draws),
    theta_lower         = apply(theta_draws, 2, quantile, probs = 0.025),
    theta_upper         = apply(theta_draws, 2, quantile, probs = 0.975),
    theta_samples       = theta_draws
  )
  saveRDS(fits[[paste0("q", 100 * tau)]],
          file.path(results_dir, sprintf("fit_tau_%02d.rds", 100 * tau)))
}
saveRDS(fits, file.path(results_dir, "all_quantile_fits.rds"))

# SUMMARY
summary_table <- do.call(rbind, lapply(fits, function(fit) {
  data.frame(
    tau        = fit$tau,
    frac_below = mean(y < fit$theta_mean_estimate[obs_index])
  )
}))
row.names(summary_table) <- NULL

cat("\n=== FINAL RESULTS (one chain per quantile) ===\n")
print(summary_table)

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

# PLOTS (identical routine to Munich_PMALA.R)
df_data <- tibble(fsize = munich$fsize, rent = y)
df_fits <- as_tibble(posterior_summary) %>%
  mutate(quantile = factor(paste0(100 * tau, "%"),
                           levels = paste0(100 * sort(taus), "%")))

quantile_colors <- c("10%" = "#F15A60", "30%" = "#67B85C", "50%" = "#2196F3",
                     "70%" = "#2CCED2", "90%" = "#E229C2")

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

for (name in c("munich_onizuka_q10_q90", "munich_onizuka_q30_q50_q70")) {
  p <- if (name == "munich_onizuka_q10_q90") p_10_90 else p_30_50_70
  ggsave(file.path(results_dir, paste0(name, ".pdf")), p, width = 8.5, height = 5.2, bg = "white")
  ggsave(file.path(results_dir, paste0(name, ".png")), p, width = 8.5, height = 5.2, dpi = 220, bg = "white")
}

if (interactive()) {
  dev.new(); print(p_10_90)
  dev.new(); print(p_30_50_70)
}
