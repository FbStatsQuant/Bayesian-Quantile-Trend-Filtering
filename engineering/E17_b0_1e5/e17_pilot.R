# Usage: Rscript --vanilla e17_pilot.R INTERIOR_PILOT EXTREME_PILOT ACCOUNTING_CSV
e17_pilot_indices <- list(
  interior = c(0L, 700L, 1400L, 1599L, 2300L, 2999L),
  extreme = c(500L, 700L, 1600L, 1899L, 2600L, 3599L)
)

e17_check_pilot <- function(runs, accounting, repo) {
  workers <- e17_workers(repo)
  required <- do.call(rbind, lapply(names(e17_pilot_indices), function(design) {
    data.frame(design, index = e17_pilot_indices[[design]])
  }))
  fields <- c("design", "index", "cpu_seconds", "state", "exit_code")
  key <- function(d) paste(d$design, d$index)
  stopifnot(identical(names(accounting), fields), !anyDuplicated(key(accounting)),
    setequal(key(accounting), key(required)), all(accounting$state == "COMPLETED"),
    all(accounting$exit_code == "0:0"), is.numeric(accounting$cpu_seconds),
    all(is.finite(accounting$cpu_seconds) & accounting$cpu_seconds > 0))

  checked <- lapply(names(e17_pilot_indices), function(design) {
    grid <- e17_tasks(workers, design)
    indices <- e17_pilot_indices[[design]]
    pilot <- grid[match(indices, grid$index), ]
    files <- file.path(runs[[design]], "out", paste0(pilot$id, ".rds"))
    recorded <- list.files(file.path(runs[[design]], "out"), pattern = "[.]rds$", full.names = TRUE)
    stopifnot(setequal(recorded, files))
    for (i in seq_along(files)) {
      x <- readRDS(files[i])
      fields <- c("id", "index", "seed", "signal", "noise", "tau")
      stopifnot(all(vapply(fields, function(key) identical(x[[key]], pilot[[key]][i]), logical(1L))),
        x$commit == e17_sampler_commit, x$b0 == e17_rate, x$sweeps == 30000L,
        x$burn == 10000L, x$chain_seed == 10001L + pilot$index[i],
        x$n_sigma_guard == 0L, x$acc_post >= .4, x$acc_post <= .6)
    }
    cpu <- accounting$cpu_seconds[accounting$design == design]
    data.frame(design, tasks = nrow(grid), pilot_tasks = length(cpu),
      pilot_core_hours = sum(cpu) / 3600, projected_production_core_hours = nrow(grid) * mean(cpu) / 3600)
  })
  checked <- do.call(rbind, checked)
  print(checked, row.names = FALSE)
  total <- sum(checked$pilot_core_hours + checked$projected_production_core_hours)
  cat(sprintf("Projected total including the pilot: %.3f core-hours\n", total))
  stopifnot(checked$projected_production_core_hours[checked$design == "interior"] <= 150,
    total <= 330)
  invisible(checked)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 3L) {
    stop("Usage: e17_pilot.R INTERIOR_PILOT EXTREME_PILOT ACCOUNTING_CSV")
  }
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  folder <- dirname(normalizePath(script, mustWork = TRUE))
  source(file.path(folder, "e17_run.R"))
  repo <- file.path(folder, "..", "..")
  accounting <- read.csv(args[3L], colClasses = c(exit_code = "character"))
  e17_check_pilot(setNames(args[1:2], c("interior", "extreme")), accounting, repo)
}
