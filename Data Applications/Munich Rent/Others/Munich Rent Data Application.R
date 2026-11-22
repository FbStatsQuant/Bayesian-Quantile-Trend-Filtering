# Munich rent real-data application for the individual sampler.
#
# Full run (defaults inherited from the original sampler):
#   Rscript "Munich Rent Data Application.R"
#
# Short smoke test:
#   DATA_APP_GIBBS_ITER=30 DATA_APP_GIBBS_BURN=10 Rscript "Munich Rent Data Application.R"

script_directory <- function() {
  # 1. Rscript "file.R"  -> the path is in --file=
  command_arguments <- commandArgs(trailingOnly = FALSE)
  file_argument <- grep("^--file=", command_arguments, value = TRUE)
  if (length(file_argument) > 0L) {
    return(dirname(normalizePath(sub("^--file=", "", file_argument[1L]))))
  }
  # 2. source("file.R") -> the path is in the calling frame
  frame_file <- tryCatch(sys.frame(1L)$ofile, error = function(e) NULL)
  if (!is.null(frame_file)) {
    return(dirname(normalizePath(frame_file)))
  }
  # 3. Running line by line / Ctrl+Enter in RStudio -> ask RStudio which
  #    file is open in the editor. (The two cases above return nothing here,
  #    which is why the script used to fall back to getwd() and fail.)
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    editor_path <- tryCatch(
      rstudioapi::getSourceEditorContext()$path,
      error = function(e) ""
    )
    if (!is.null(editor_path) && nzchar(editor_path)) {
      return(dirname(normalizePath(editor_path)))
    }
  }
  # 4. Last resort: the working directory.
  normalizePath(getwd())
}

require_application_file <- function(directory, file_name) {
  path <- file.path(directory, file_name)
  if (!file.exists(path)) {
    stop(
      "Cannot find '", file_name, "' in\n  ", directory, "\n",
      "This script must live in the same folder as that file. Either run it ",
      "with Rscript / source(), or in RStudio use ",
      "Session > Set Working Directory > To Source File Location and re-run.",
      call. = FALSE
    )
  }
  path
}

environment_integer <- function(name, default) {
  value <- Sys.getenv(name, unset = "")
  if (!nzchar(value)) {
    return(as.integer(default))
  }
  parsed <- suppressWarnings(as.integer(value))
  if (is.na(parsed)) {
    stop("Environment variable ", name, " must be an integer.")
  }
  parsed
}

application_dir <- script_directory()
data_applications_dir <- dirname(application_dir)
source(require_application_file(
  data_applications_dir,
  "Individual Sampler Data Application.R"
))

set.seed(800)
gibbs_iter <- environment_integer("DATA_APP_GIBBS_ITER", 6000L)
gibbs_burn <- environment_integer("DATA_APP_GIBBS_BURN", 1000L)
gibbs_thin <- environment_integer("DATA_APP_GIBBS_THIN", 1L)
progress_every <- environment_integer("DATA_APP_PROGRESS_EVERY", 500L)
if (gibbs_burn >= gibbs_iter) {
  stop("DATA_APP_GIBBS_BURN must be smaller than DATA_APP_GIBBS_ITER.")
}

data_dir <- file.path(application_dir, "data")
results_dir <- file.path(application_dir, "results")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

# This is the exact 2,035-row version documented by the spmrf project and used
# by Onizuka et al. The local copy is bundled, with this URL as a fallback.
munich_url <- paste0(
  "https://raw.githubusercontent.com/",
  "jrfaulkner/spmrf/master/data/munich.rda"
)
munich_file <- file.path(data_dir, "munich.rda")
if (!file.exists(munich_file)) {
  message("Downloading Munich rent data from the spmrf repository...")
  utils::download.file(munich_url, munich_file, mode = "wb")
}

data_environment <- new.env(parent = baseenv())
loaded_objects <- load(munich_file, envir = data_environment)
if (!"munich" %in% loaded_objects) {
  stop("The downloaded file does not contain an object named 'munich'.")
}
munich <- get("munich", envir = data_environment)

required_columns <- c("rent", "fsize")
if (!all(required_columns %in% names(munich))) {
  stop("Munich data must contain columns named 'rent' and 'fsize'.")
}
munich <- munich[
  stats::complete.cases(munich[, required_columns]),
  ,
  drop = FALSE
]
munich <- munich[order(munich$fsize), , drop = FALSE]
row.names(munich) <- NULL

locations <- sort(unique(munich$fsize))
obs_index <- match(munich$fsize, locations)
if (nrow(munich) != 2035L || length(locations) != 134L) {
  warning(
    "Expected 2,035 observations and 134 floor-size locations; found ",
    nrow(munich), " and ", length(locations), "."
  )
}
utils::write.csv(
  munich,
  file.path(data_dir, "munich_processed.csv"),
  row.names = FALSE
)

initial_theta <- vapply(
  split(munich$rent, obs_index),
  stats::median,
  numeric(1L)
)
# ---------------------------------------------------------------------------
# WHAT GOES INTO THE SAMPLER. Printed before any sampling so there is no doubt.
# ---------------------------------------------------------------------------
y_in <- munich$rent          # response, one entry per apartment
x_in <- locations            # grid: the distinct floor sizes, sorted
idx  <- obs_index            # which entry of x_in each y_in belongs to

cat("\n==================== SAMPLER INPUTS (Munich) ====================\n")
cat("y  = munich$rent   length:", length(y_in),
    "  (one rent per apartment, sorted by floor size)\n")
cat("x  = locations     length:", length(x_in),
    "  (distinct floor sizes, sorted; theta has this length)\n")
cat("obs_index          length:", length(idx),
    "  (integer in 1..", length(x_in), ", same length as y)\n", sep = "")
cat("\nx (all", length(x_in), "grid values):\n"); print(x_in)
cat("\nFirst 12 observations as (covariate, response) pairs:\n")
print(data.frame(row = 1:12,
                 covariate = x_in[idx][1:12],
                 response  = y_in[1:12],
                 obs_index = idx[1:12]),
      row.names = FALSE)
cat("\nCheck: x[obs_index] reproduces the raw fsize column for every row:",
    identical(as.numeric(x_in[idx]), as.numeric(munich$fsize)), "\n")
cat("Observations per grid point (min / median / max):",
    min(tabulate(idx)), "/", stats::median(tabulate(idx)), "/", max(tabulate(idx)), "\n")
cat("Example, x = 20 (grid position 3): rents =",
    paste(y_in[idx == 3L], collapse = ", "), "\n")
cat("initial_theta       length:", length(initial_theta),
    "  (per-size sample median, starting value only)\n")
cat("initial_theta[1:6]:", round(initial_theta[1:6], 2), "\n")
cat("=================================================================\n\n")

quantile_levels <- c(0.10, 0.30, 0.50, 0.70, 0.90)
fits <- vector("list", length(quantile_levels))
names(fits) <- paste0("q", round(100 * quantile_levels))

for (index in seq_along(quantile_levels)) {
  tau <- quantile_levels[index]
  message("\nFitting Munich rent quantile ", round(100 * tau), "%...")
  fits[[index]] <- fit_individual_sampler_data_application(
    y = munich$rent,
    x = locations,
    obs_index = obs_index,
    tau = tau,
    order = 2L,
    a = 1,
    b = 1,
    a_sigma = 0.01,
    b_sigma = 0.01,
    gamma = 0.1,
    delta = 0.1,
    eps = 0.01,
    gibbs_iter = gibbs_iter,
    gibbs_burn = gibbs_burn,
    thin = gibbs_thin,
    theta_init = initial_theta,
    sigma_init = max(stats::IQR(munich$rent) / 1.349, 0.05),
    lambda_init = 20,
    progress_every = progress_every
  )
  saveRDS(
    fits[[index]],
    file.path(results_dir, sprintf("fit_tau_%02d.rds", round(100 * tau)))
  )
}

posterior_summary <- do.call(
  rbind,
  lapply(fits, posterior_summary_data_application)
)
row.names(posterior_summary) <- NULL
utils::write.csv(
  posterior_summary,
  file.path(results_dir, "posterior_summary.csv"),
  row.names = FALSE
)

diagnostics <- data.frame(
  tau = quantile_levels,
  delta = 0.04,
  lambda_prior_shape = 1,
  lambda_prior_rate = 1,
  acceptance_rate = vapply(fits, `[[`, numeric(1L), "acceptance_rate"),
  lambda_posterior_mean = vapply(fits, `[[`, numeric(1L), "lambda_estimate"),
  sigma_posterior_mean = vapply(fits, `[[`, numeric(1L), "sigma_estimate"),
  saved_draws = vapply(fits, function(fit) nrow(fit$theta_samples), integer(1L)),
  gibbs_iter = gibbs_iter,
  gibbs_burn = gibbs_burn,
  thin = gibbs_thin
)
utils::write.csv(
  diagnostics,
  file.path(results_dir, "sampler_diagnostics.csv"),
  row.names = FALSE
)

panel_spec <- data.frame(
  tau = quantile_levels,
  panel = c(
    "10% and 90% quantiles",
    "30% and 70% quantiles",
    "50% quantile",
    "30% and 70% quantiles",
    "10% and 90% quantiles"
  ),
  stringsAsFactors = FALSE
)
panel_spec$panel <- factor(
  panel_spec$panel,
  levels = c(
    "10% and 90% quantiles",
    "30% and 70% quantiles",
    "50% quantile"
  )
)

quantile_colors <- c(
  "10%" = "#F15A60",
  "30%" = "#67B85C",
  "50%" = "#2196F3",
  "70%" = "#2CCED2",
  "90%" = "#E229C2"
)
munich_plot <- build_onizuka_style_plot(
  observed_x = munich$fsize,
  observed_y = munich$rent,
  posterior_summary = posterior_summary,
  panel_spec = panel_spec,
  title = "Individual sampler",
  x_label = "floor size",
  y_label = "rent",
  quantile_colors = quantile_colors,
  add_rug = TRUE
)

ggplot2::ggsave(
  filename = file.path(results_dir, "munich_individual_sampler.png"),
  plot = munich_plot,
  width = 7.2,
  height = 9.0,
  dpi = 220,
  bg = "white"
)
ggplot2::ggsave(
  filename = file.path(results_dir, "munich_individual_sampler.pdf"),
  plot = munich_plot,
  width = 7.2,
  height = 9.0,
  device = grDevices::cairo_pdf,
  bg = "white"
)

saveRDS(fits, file.path(results_dir, "all_quantile_fits.rds"))
if (interactive()) {
  print(munich_plot)
}
message("\nMunich application complete. Results: ", results_dir)
