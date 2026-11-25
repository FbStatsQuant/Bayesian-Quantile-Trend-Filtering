#!/usr/bin/env Rscript
# Run through Owls after the pilot. Generates the immutable task list for dispatch.
entry <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[[1L]])
source(file.path(dirname(entry), "design.R"))
stopifnot(identical(Sys.getenv("OWLS_ENV_SOURCED"), "1"))
run_dir <- run_directory()
pilot_dir <- file.path(run_dir, "pilot")
plan_file <- file.path(run_dir, "plan.tsv")
tasks <- make_tasks()
pilot <- c(
  "joint_VS_s1_b1e-05_c1001", "ind_VS_s1_b1e-05_t50", "ind_VS_s1_b1e-05_t90"
)

measure <- function(id) {
  result <- readRDS(file.path(pilot_dir, paste0(id, ".rds")))
  if (result$crashed) stop("Pilot sampler error in ", id, " (", result$error, ")")
  path <- file.path(pilot_dir, paste0(id, ".time"))
  resources <- readLines(path)
  resources <- resources[lengths(strsplit(resources, "\t", fixed = TRUE)) == 5L]
  attempts <- do.call(rbind, lapply(strsplit(resources, "\t", fixed = TRUE), as.numeric))
  last <- attempts[nrow(attempts), ]
  stopifnot(last[5L] == 0, result$iter >= 1200L)
  cpu <- sum(last[1:2])
  cpu_rate <- result$sampler_cpu_seconds / result$iter
  wall_rate <- result$seconds / result$iter
  rss_gib <- last[4L] / 1024^2
  levels <- length(result$tau)
  draws_added <- (full_iter - full_burn) - (result$iter - result$burn)
  draw_gib <- draws_added * n_observations * levels * 8 / 1024^3
  data.frame(
    id = id, kind = result$task$kind, sweeps = result$iter, cpu_seconds_per_sweep = cpu_rate,
    elapsed_seconds_per_sweep = wall_rate, peak_rss_gib = rss_gib,
    projected_cpu_seconds = cpu_rate * full_iter + max(0, cpu - result$sampler_cpu_seconds) + 30,
    projected_elapsed_seconds = wall_rate * full_iter + max(0, last[3L] - result$seconds) + 30,
    reserve_gib = ceiling(rss_gib + 2 * draw_gib + 0.75),
    used_cpu_seconds = sum(attempts[, 1:2])
  )
}

rates <- do.call(rbind, lapply(pilot, measure))
joint <- tasks$kind == "joint"
seconds <- function(kind, field) max(rates[rates$kind == kind, field])
core_hours <- function(keep) {
  (sum(rates$used_cpu_seconds) + sum(keep & joint) * seconds("joint", "projected_cpu_seconds") +
     sum(keep & !joint) * seconds("ind", "projected_cpu_seconds")) / 3600
}
reference_sets <- list(
  "all levels and seeds" = rep(TRUE, nrow(tasks)),
  "levels 0.5 and 0.9 at all seeds" = joint | tasks$tau %in% c(0.5, 0.9),
  "levels 0.5 and 0.9 at seeds 1–3" = joint | (tasks$tau %in% c(0.5, 0.9) & tasks$data_seed <= 3),
  "joint runs only" = joint
)
estimates <- vapply(reference_sets, core_hours, numeric(1))
write.csv(rates, file.path(pilot_dir, "measurements.csv"), row.names = FALSE)
print(rates, row.names = FALSE)
print(estimates)
# Account for the dispatcher's budget margin.
fit <- which(estimates < 160 - 360 / 3600)
if (!length(fit)) stop("Joint runs alone project to ", round(tail(estimates, 1), 2), " core-hours")
chosen <- fit[1]
keep <- reference_sets[[chosen]]
cat(sprintf("Plan: 60 joint runs plus %d individual runs (%s), projected %.2f core-hours\n",
            sum(keep & !joint), names(reference_sets)[chosen], estimates[chosen]))
if (file.exists(plan_file)) {
  recorded <- read.delim(plan_file, stringsAsFactors = FALSE)
  stopifnot(identical(recorded$id, tasks$id[keep]))
} else {
  temporary <- tempfile("plan-", tmpdir = run_dir)
  write.table(tasks[keep, ], temporary, sep = "\t", row.names = FALSE, quote = FALSE)
  if (!file.rename(temporary, plan_file)) stop("Could not publish task list")
}
