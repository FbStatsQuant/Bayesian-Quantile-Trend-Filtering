# Use the campaign's original generator for every level, including the Oct. 21 extension.
e15_load_data <- function(code) {
  legacy <- file.path(code, "experiments", "extreme_quantiles", "packages", "Extreme_Individual")
  original <- new.env(parent = globalenv())
  sys.source(file.path(legacy, "common_extreme.R"), envir = original)
  function(signal, noise, seed, tau) {
    data <- original$simulate_extreme(seed, 500L, signal, noise, tau)
    list(y = data$y, truth = unname(data$truth[, 1L]))
  }
}
