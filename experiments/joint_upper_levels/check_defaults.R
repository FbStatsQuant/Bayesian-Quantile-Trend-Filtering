# Verify configuration against the supplied sampler's Settings block.
# Call from the code directory before submitting; every sampler parameter,
# including the lambda prior, must match the current source settings.
check_sampler_defaults <- function(config) {
  old <- getwd(); on.exit(setwd(old))
  setwd(file.path(old, "source", "Joint"))
  lines <- readLines("Joint_Sampler_PMALA_Augmented.R")
  main <- grep("^# ---- Main", lines)
  stopifnot(length(main) == 1L)
  env <- new.env(parent = globalenv())
  eval(parse(text = lines[seq_len(main - 1L)]), envir = env)
  map <- c(order="order", a0="a0", b0="b0", a_sigma="a_sigma", b_sigma="b_sigma",
    gibbs_iter="gibbs_iter", gibbs_burn="gibbs_burn", delta_init="delta_init",
    lambda_init="lambda_init", adapt_target="adapt_target", adapt_gain="adapt_gain",
    adapt_kappa="adapt_kappa", delta_bounds="delta_bounds", metric="metric",
    c_fixed="c_metric", rho="admm_rho", iters="admm_iter", mh="mh_correct",
    adapt="adapt_delta", warm="warm_sweeps", gamma_warm="gamma_warm",
    kappa="kappa_metric", adapt_all="adapt_all", K="K_theta", asis="asis_lambda",
    tol="admm_tol", zeta_scale="zeta_scale", ctrl="box_ctrl")
  for (key in names(map)) {
    stopifnot(isTRUE(all.equal(config$sampler[[key]], env[[map[[key]]]])))
    cat("DEFAULT_MATCH", key, "\n")
  }
  stopifnot(config$n == env$n, config$baseline == env$baseline_id,
    config$sampler$keep_every == 1L, isTRUE(config$sampler$verbose))
  cat("PRIOR: source shape", env$a0, "rate", env$b0,
      "| configured shape", config$sampler$a0, "rate", config$sampler$b0, "\n")
  invisible(TRUE)
}
