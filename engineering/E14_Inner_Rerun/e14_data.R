# Source this file from a checkout that includes the original campaign snapshot.
e14_make_data <- local({
  source_files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  source_dir <- dirname(normalizePath(tail(source_files, 1L)[[1L]], mustWork = TRUE))
  snapshot <- file.path(source_dir, "..", "..", "experiments", "interior_quantiles",
    "individual_nots_20261003", "source", "Individual_Sampler_PMALA_Augmented.R")
  # Load only the original generator definition, without any sampler setup.
  definitions <- parse(snapshot, keep.source = FALSE)
  generator <- Filter(function(expr) {
    is.call(expr) && identical(expr[[1L]], quote(`<-`)) &&
      identical(expr[[2L]], quote(simulate_data))
  }, as.list(definitions))
  stopifnot(length(generator) == 1L)
  eval(generator[[1L]])

  function(signal, noise, seed, tau) {
    stopifnot(length(signal) == 1L, signal %in% c("VS", "S"),
      length(noise) == 1L, noise %in% c("Normal", "Gaussian", "Beta", "Mixed"),
      is.numeric(seed), length(seed) == 1L, seed %in% 1:100,
      is.numeric(tau), length(tau) == 1L, tau %in% c(0.05, 0.25, 0.50, 0.75, 0.95))
    if (noise == "Gaussian") noise <- "Normal"
    simulate_data(seed = seed, n = 500L, tau = tau, baseline_id = signal, noise_id = noise)
  }
})
