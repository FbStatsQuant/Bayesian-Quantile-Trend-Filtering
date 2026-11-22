# Isolated candidate. source() defines functions only; call load_unified_cpp() once.
.unified_dir <- dirname(normalizePath(sys.frame(1)$ofile, mustWork=TRUE))
.guarded <- new.env(parent=environment())
.lines <- readLines(file.path(.unified_dir, "guarded_reference.R"), warn=FALSE)
eval(parse(text=.lines[seq_len(grep("^# ---- Main ", .lines)[1]-1L)]), .guarded)
for (.nm in c("ald_const", "Dtheta", "rho_tau", "U_cond", "metric_dc", "rinvgauss",
               "draw_z", "draw_sigma", "null_basis", "simulate_data")) assign(.nm, .guarded[[.nm]])
load_unified_cpp <- function() {
  # Native optimizers: original unbounded ADMM, then bounded whole-U ADMM.
  .guarded$load_prox_cpp(file.path(.unified_dir, "prox_admm_metric.cpp"))
  load_bounded_cpp()
  invisible(TRUE)
}

source(file.path(.unified_dir,"bounded_helpers.R"),local=TRUE)

gibbs_unified <- function(y, tau, order=2L, gibbs_iter=30000L, gibbs_burn=10000L,
  delta_init=.2, lambda_init=NULL, adapt_target=.5, adapt_gain=1, adapt_kappa=.6,
  delta_bounds=c(1e-8,100), metric="curv", c_fixed=1e4, rho=NULL, iters=200L,
  adapt=TRUE, init="y", warm=200L, gamma_warm=1e4, kappa=3, K=1L,
  asis=TRUE, tol=0, verbose=TRUE, audit=NULL) {
  validate_unified(y,tau,order,gibbs_iter,gibbs_burn,warm,iters,K,init,delta_init,lambda_init,delta_bounds)
  a0 <- 1; b0 <- .001; a_sigma <- b_sigma <- .1
  n <- length(y); nq <- length(tau); m <- n-order-1L
  Q <- if (asis) null_basis(n,order) else NULL
  offsets <- if(nq==1L) 0 else max(sd(y),.1)*(qnorm(tau)-median(qnorm(tau)))
  states <- lapply(seq_len(nq),function(j) list(theta=if(nq==1L) y else y+offsets[j],
    z=rep(1,n),sigma=1,lambda=if(is.null(lambda_init)) m else lambda_init,delta=delta_init))
  if(nq>1L && any(vapply(seq_len(nq-1L),function(h)
      any(!is.finite(states[[h]]$theta)) || any(!is.finite(states[[h+1L]]$theta)) ||
      any(states[[h]]$theta>=states[[h+1L]]$theta),logical(1))))
    stop("Joint initialization collapsed numerically; rescale y or separate tau values")
  keep <- gibbs_iter-gibbs_burn
  theta_s <- array(NA_real_,c(keep,n,nq))
  lambda_s <- sigma_s <- delta_s <- acc_s <- SD_s <- matrix(0,gibbs_iter,nq)
  outside_s <- proposals_s <- accepted_s <- asis_moved_s <- integer(nq)
  audit_state <- function(stage,it,j) {
    if(nq>1L && any(vapply(seq_len(nq-1L),function(h) any(states[[h]]$theta>states[[h+1L]]$theta),logical(1))))
      stop("Noncrossing invariant failed")
    if(!is.null(audit)) audit(stage,it,j,states)
  }
  audit_state("initial",0L,0L)
  t0 <- proc.time()[["elapsed"]]
  # Gibbs sweep: visit quantiles in increasing order. Each neighbor box stays
  # fixed throughout this quantile's theta and interweaving updates.
  for(it in seq_len(gibbs_iter)) for(j in seq_len(nq)) {
    theta <- states[[j]]$theta; z <- states[[j]]$z; sigma <- states[[j]]$sigma
    lambda <- states[[j]]$lambda; delta <- states[[j]]$delta
    cst <- ald_const(tau[j])
    lower <- if(j==1L) rep(-Inf,n) else states[[j-1L]]$theta
    upper <- if(j==nq) rep(Inf,n) else states[[j+1L]]$theta
    lam_eff <- lambda  # Unscaled difference prior (prior_scale='none').
    # 1. Theta: discarded warmup optimization, then K Metropolis-corrected moves.
    if (it <= warm) {                                                          # warm start: optimisation step only
      a <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z                        # conditional MAP = weighted TF:
      theta <- box_prox(theta, a, r, lam_eff, gamma_warm, a, 0, order, lower, upper, rho = median(a), iters = iters)  # Euclidean-in-a prox, gamma large
      st <- list(theta = theta, accept = NA, log_alpha = NA)
    } else {                                                                   # Block 1: K P-MALA moves at fixed (z, lambda, sigma)
      acc_k <- la_k <- numeric(K)
      for (kk in seq_len(K)) {
        st <- box_pmala_step(theta, y, z, lam_eff, sigma, delta, cst, order, metric, c_fixed, rho, iters, TRUE, kappa, tol, lower, upper)
        theta <- st$theta
        proposals_s[j] <- proposals_s[j]+1L
        outside_s[j] <- outside_s[j]+as.integer(isTRUE(st$outside))
        accepted_s[j] <- accepted_s[j]+as.integer(st$accept)
        states[[j]]$theta <- theta; audit_state("theta_move",it,j)
        acc_k[kk] <- st$accept; la_k[kk] <- exp(st$log_alpha)
      }
      st <- list(theta = theta, accept = mean(acc_k), log_alpha = log(mean(la_k)))
    }
    states[[j]]$theta <- theta; audit_state("theta",it,j)
    # 2. Latent z conditional, retaining the individual sampler's guards.
    z      <- draw_z(y - theta, tau[j], sigma)                                     # Block 2
    SD     <- sum(abs(Dtheta(theta, order)))
    # 3. Lambda: conjugate Gamma draw in the sufficient parameterization.
    lambda <- rgamma(1, shape = a0 + m, rate = b0 + SD)  # Block 3 (sufficient parameterisation)
    # 4. Optional bounded ASIS: jointly rescale theta and lambda.
    if (asis && it > warm) {                                              # Block 3b: ancillary redraw, theta rescales
      a_ <- 1 / (cst$t2 * sigma * z); r_ <- y - cst$psi * z
      old_theta <- theta
      as_ <- box_asis_step(theta, lambda, a_, r_, a0, b0, Q, lower, upper); lambda <- as_$lambda; theta <- as_$theta
      asis_moved_s[j] <- asis_moved_s[j]+as.integer(any(theta != old_theta))
      SD <- sum(abs(Dtheta(theta, order)))
    }
    states[[j]]$theta <- theta; audit_state("interweaving",it,j)
    # 5. Sigma: inverse-Gamma conditional using the updated theta and lambda.
    sigma  <- draw_sigma(y, theta, z, cst, a_sigma, b_sigma,                    # Block 4
                         lambda_SD = 0, m = 0)
    # 6. Adapt delta through the final burn-in sweep, then freeze; save state.
    if (adapt && it > warm && it <= gibbs_burn) {                # adapt delta (diminishing gain)
      delta <- exp(log(delta) + adapt_gain * it^(-adapt_kappa) * (exp(st$log_alpha) - adapt_target))
      delta <- min(max(delta, delta_bounds[1]), delta_bounds[2])
    }
    if (!is.finite(sigma) || !is.finite(lambda) || !all(is.finite(theta)))
      stop(sprintf("non-finite state at sweep %d: sigma %g lambda %g theta finite %d", it, sigma, lambda, all(is.finite(theta))))
    states[[j]] <- list(theta=theta,z=z,sigma=sigma,lambda=lambda,delta=delta)
    lambda_s[it,j] <- lambda; sigma_s[it,j] <- sigma; delta_s[it,j] <- delta; acc_s[it,j] <- st$accept; SD_s[it,j] <- SD
    if(it>gibbs_burn) theta_s[it-gibbs_burn,,j] <- theta
    if(verbose && j==nq && it%%500L==0L) cat(sprintf("sweep %d/%d, quantiles %d\n",it,gibbs_iter,nq))
  }
  list(tau=tau,theta=theta_s,lambda=lambda_s,sigma=sigma_s,delta=delta_s,acc=acc_s,SD=SD_s,
    acc_post=colMeans(acc_s[(gibbs_burn+1L):gibbs_iter,,drop=FALSE]),
    delta_final=vapply(states,`[[`,numeric(1),"delta"),final_state=states,
    diagnostics=data.frame(tau=tau,proposals=proposals_s,outside=outside_s,accepted=accepted_s,asis_moved=asis_moved_s),
    seconds=proc.time()[["elapsed"]]-t0)
}

# Plotting/reporting is opt-in and does not change the sampling kernel.
source(file.path(.unified_dir,"unified_reporting.R"),local=TRUE)
