# Quantile trend filtering of Brantley, Guinness and Chi (2020, AOAS), one quantile level:
#   minimise_theta  rho_tau(y - theta) + lambda ||D^(k+1) theta||_1                      (their eq. 1)
# with lambda chosen by their extended BIC (Sec. 3.2, p. 594):
#   eBIC = 2 rho_tau(y - theta_hat) / sigma + nu log n + 2 gamma log choose(P, nu),
#   sigma = (1 - |1 - 2 tau|) / 2, gamma = 1, P = n - k - 1, nu = #{nonzero entries of D theta_hat}.
# For n = 500 the problem is solved exactly, as their own simulation code does
# (detrendr::get_trend_BIC, called by detrendify/Code/Sim_detrendr.R): the windowed ADMM of their
# Algorithm 1 targets very long series, and Sec. 2.3.1 advises as few windows as the budget allows.
# LP in the detrendr::get_model form: x = (u+, u-, eta+, eta-) >= 0, D(u+ - u-) + (eta+ - eta-) = D y,
# cost tau 1'u+ + (1 - tau) 1'u- + lambda 1'(eta+ + eta-), theta = y - (u+ - u-).
# Solver: PIQP (interior point). detrendr's free LP backends were rejected after a local check:
# GLPK returned non-optimal status or slightly suboptimal points at large lambda, and lpSolve failed often.

qtf_D <- function(n, order) {
  d <- order + 1L; m <- n - d
  Matrix::sparseMatrix(i = rep(seq_len(m), d + 1L), j = unlist(lapply(0:d, function(j) seq_len(m) + j)),
                       x = rep((-1)^(d:0) * choose(d, 0:d), each = m), dims = c(m, n))
}

qtf_lp_solve <- function(y, tau, lambda, D, A, b, tol, max_iter) {
  n <- length(y); m <- nrow(D); N <- 2L * n + 2L * m
  mdl <- piqp::piqp(P = Matrix::Diagonal(N, 0), c = c(rep(tau, n), rep(1 - tau, n), rep(lambda, 2L * m)),
                    A = A, b = b, x_l = rep(0, N),
                    settings = list(verbose = FALSE, eps_abs = tol, eps_rel = tol,
                                    eps_duality_gap_abs = tol, eps_duality_gap_rel = tol, max_iter = max_iter),
                    backend = "sparse")
  f <- solve(mdl)
  x <- f$x
  list(status = f$info$status_desc, iterations = f$info$iter,
       theta = if (length(x) == N && all(is.finite(x))) y - (x[seq_len(n)] - x[n + seq_len(n)]) else NULL)
}

qtf_ebic_path <- function(y, tau, order, p) {
  n <- length(y); D <- qtf_D(n, order); m <- nrow(D)
  A <- cbind(D, -D, Matrix::Diagonal(m), -Matrix::Diagonal(m)); b <- as.numeric(D %*% y)
  sig <- (1 - abs(1 - 2 * tau)) / 2
  fits <- vector("list", length(p$lambda_grid))
  rows <- lapply(seq_along(p$lambda_grid), function(i) {
    lam <- p$lambda_grid[i]
    s <- qtf_lp_solve(y, tau, lam, D, A, b, p$piqp_tol, p$piqp_max_iter); retried <- FALSE
    if (s$status != "solved" || is.null(s$theta)) {
      s <- qtf_lp_solve(y, tau, lam, D, A, b, p$piqp_tol, p$piqp_retry_max_iter); retried <- TRUE
    }
    ok <- s$status == "solved" && !is.null(s$theta)
    if (!ok) return(data.frame(lambda = lam, status = s$status, retried = retried, iterations = s$iterations,
                               check_loss = NA_real_, objective = NA_real_, df = NA_integer_, ebic = NA_real_))
    fits[[i]] <<- s$theta
    r <- y - s$theta; loss <- sum(r * (tau - (r < 0))); dth <- as.numeric(D %*% s$theta)
    df <- sum(abs(dth) > p$df_tol)
    data.frame(lambda = lam, status = s$status, retried = retried, iterations = s$iterations,
               check_loss = loss, objective = loss + lam * sum(abs(dth)), df = df,
               ebic = 2 * loss / sig + log(n) * df + 2 * p$ebic_gamma * lchoose(m, df))
  })
  path <- do.call(rbind, rows)
  solved <- which(path$status == "solved")
  if (!length(solved)) stop("PIQP failed at every lambda")
  sel <- solved[which.min(path$ebic[solved])]
  list(est = fits[[sel]], path = path, selected = sel, lambda = path$lambda[sel],
       boundary = sel %in% c(1L, nrow(path)), n_failed = sum(path$status != "solved"),
       n_retried = sum(path$retried), piqp_version = as.character(utils::packageVersion("piqp")))
}
