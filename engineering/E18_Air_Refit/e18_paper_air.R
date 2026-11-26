# Rscript --vanilla e18_paper_air.R SIM_REPORT REAL_RUN [OUTPUT_DIR]
args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% 2:3) stop("Usage: e18_paper_air.R SIM_REPORT REAL_RUN [OUTPUT_DIR]")
code <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))))
source(file.path(code, "e18_common.R"))
source(file.path(code, "e18_report_common.R"))
sim <- normalizePath(args[1L])
run <- normalizePath(args[2L])
real <- file.path(run, "report")
out <- if (length(args) == 3L) args[3L] else file.path(code, "results_a0_n")
load_csv <- function(dir, name) read.csv(file.path(dir, paste0(name, ".csv")))
emit <- function(x, dir, name) {
  numeric <- vapply(x, is.numeric, FALSE)
  x[numeric] <- lapply(x[numeric], function(v) ifelse(is.na(v), NA, sprintf("%.17g", v)))
  write.table(x, file.path(dir, paste0(name, ".csv")), sep = ",", row.names = FALSE,
    col.names = TRUE, quote = which(!numeric), qmethod = "double")
}

chain <- load_csv(real, "spod_chain_health")
cell <- load_csv(real, "spod_cell_health")
grid <- e18_grid("real-prime")
stopifnot(nrow(chain) == nrow(grid), !anyDuplicated(chain$index),
  setequal(chain$id, grid$id), nrow(cell) == nrow(grid) / 2L,
  all(chain$a0 == 8640L), all(cell$a0 == 8640L))
chain <- chain[match(grid$index, chain$index), ]
stopifnot(identical(chain$id, grid$id))

accounting <- file.path(run, c("slurm_accounting.psv", "E18_ACCOUNTING.psv"))
accounting <- accounting[file.exists(accounting)]
if (length(accounting)) {
  records <- strsplit(readLines(accounting[1L]), "|", fixed = TRUE)
  tasks <- Filter(function(row) grepl("^[0-9]+_[0-9]+$", row[1L]), records)
  ids <- vapply(tasks, `[`, "", 1L)
  index <- as.integer(sub("^[0-9]+_", "", ids))
  stopifnot(!anyDuplicated(index), setequal(index, chain$index),
    all(vapply(tasks, `[`, "", 2L) == "COMPLETED"))
  cpu_hours <- function(value) {
    if (!grepl("^([0-9]+-)?([0-9]+:)?[0-9]+:[0-9]+([.][0-9]+)?$", value))
      stop("Invalid Slurm TotalCPU: ", value)
    parts <- strsplit(value, "-", fixed = TRUE)[[1L]]
    clock <- rev(as.numeric(strsplit(tail(parts, 1L), ":", fixed = TRUE)[[1L]]))
    days <- if (length(parts) == 2L) as.numeric(parts[1L]) else 0
    (sum(clock * 60^(seq_along(clock) - 1L)) + 86400 * days) / 3600
  }
  chain$fit_core_hours <- vapply(tasks, function(row) cpu_hours(row[3L]), 0)[match(chain$index, index)]
} else {
  warning("Slurm accounting is absent. Stage 2-prime core-hours are NA.")
  chain$fit_core_hours <- NA_real_
}
for (seed in 1:2) {
  z <- chain[chain$seed == seed, ]
  hit <- match(paste(cell$tau, cell$b0), paste(z$tau, z$b0))
  cell[[paste0("fit_core_hours_chain_", seed)]] <- z$fit_core_hours[hit]
  for (k in e18_warm_fields) cell[[paste0(k, "_chain_", seed)]] <- z[[k]][hit]
  cell[[paste0("theta_ess_p05_chain_", seed)]] <- z$ess_theta_p05[hit]
}
cell$fit_core_hours <- cell$fit_core_hours_chain_1 + cell$fit_core_hours_chain_2
emit(cell[order(cell$tau, -cell$b0), ], real, "spod_diagnostics_by_cell")

selected <- load_csv(sim, "selected_b0")
stopifnot(identical(selected$tau, e18_taus), all(selected$a0 == 500L),
  all(selected$b0 == 1e-2), all(selected$branch == "i"))
real_selected <- cell[cell$selected_for_real, ]
stopifnot(nrow(real_selected) == 3L, setequal(real_selected$tau, e18_taus),
  all(real_selected$b0 == 1e-2))
if (any(chain$STOP_stall) || any(cell$STOP_rhat))
  stop("STOP: Stage 2-prime diagnostics require HQ review before export.")
curves <- load_csv(real, "spod_curves")
stopifnot(nrow(curves) == 8640L, identical(names(curves), c("time", "y", "q01", "q05", "q10",
  "q01_lo", "q01_hi", "q05_lo", "q05_hi", "q10_lo", "q10_hi")))

fits <- load_csv(sim, "per_fit")
stopifnot(nrow(fits) == 1500L, all(fits$a0 == 500L), !anyDuplicated(fits[c("tau", "b0", "seed")]))
pmala <- fits[fits$b0 == 1e-2 & !fits$failed, ]
admm <- load_csv(sim, "admm-sim_per_fit")
laplace <- load_csv(sim, "onizuka-lap_per_fit")
hs <- load_csv(code, "published_stage1")
hs <- hs[hs$method == "onizuka_hs", ]
stopifnot(identical(hs$tau, e18_taus), nrow(laplace) == 300L, nrow(admm) == 299L,
  !anyDuplicated(admm[c("tau", "seed")]), !anyDuplicated(laplace[c("tau", "seed")]),
  identical(sort(setdiff(paste(laplace$tau, laplace$seed), paste(admm$tau, admm$seed))), "0.05 62"))

metrics <- c("MSE", "CL", paste0("CAA_", e18_h))
names(metrics) <- c("mse", metrics[-1L])
average <- function(x) {
  x <- x[is.finite(x)]
  c(mean = if (length(x)) mean(x) else NA_real_, se = if (length(x) > 1L) sd(x) / sqrt(length(x)) else NA_real_)
}
table_row <- function(tau, method, d, archived_aggregate = FALSE) {
  row <- data.frame(tau = tau, method = method)
  for (k in names(metrics)) {
    key <- metrics[[k]]
    stats <- if (archived_aggregate) unlist(d[paste0(c("mean_", "se_"), key)], use.names = FALSE)
      else average(d[[k]])
    row[[key]] <- stats[1L]
    row[[paste0(key, "_se")]] <- stats[2L]
  }
  row$n <- if (archived_aggregate) d$n_seeds else nrow(d)
  row$n_CAA_defined <- if (archived_aggregate) d$n_CAA_defined else sum(is.finite(d[["CAA_0.5"]]))
  row
}
paper <- do.call(rbind, lapply(e18_taus, function(tau) rbind(
  table_row(tau, "Bayesian-PMALA", pmala[pmala$tau == tau, ]),
  table_row(tau, "Onizuka (HS)", hs[hs$tau == tau, ], TRUE),
  table_row(tau, "Onizuka (Laplace)", laplace[laplace$tau == tau, ]),
  table_row(tau, "ADMM", admm[admm$tau == tau, ]))))

pairs <- merge(pmala[c("tau", "seed", names(metrics))], admm[c("tau", "seed", names(metrics))],
  by = c("tau", "seed"), suffixes = c("_pmala", "_admm"))
differences <- do.call(rbind, lapply(e18_taus, function(tau) {
  d <- pairs[pairs$tau == tau, ]
  do.call(rbind, lapply(names(metrics), function(k) {
    delta <- d[[paste0(k, "_pmala")]] - d[[paste0(k, "_admm")]]
    stats <- average(delta)
    data.frame(tau = tau, metric = metrics[[k]], n_pairs = sum(is.finite(delta)),
      mean_pmala_minus_admm = stats[["mean"]], paired_se = stats[["se"]])
  }))
}))

warm <- function(stage, d, by, keep) {
  groups <- split(seq_len(nrow(d)), d[by], drop = TRUE)
  do.call(rbind, lapply(groups, function(i) data.frame(stage = stage,
    d[i[1L], by, drop = FALSE], n_requested = length(i), n_success = sum(keep[i]),
    e18_warm_summary(d[i[keep[i]], , drop = FALSE]))))
}
chain$chain <- c("A", "B")[chain$seed]
group <- c("tau", "b0", "a0", "chain")
warmup <- rbind(warm("Stage 1 prime", fits, setdiff(group, "chain"), !fits$failed) |>
    transform(chain = NA_character_),
  warm("Stage 2 prime", chain, group, rep(TRUE, nrow(chain))))
warmup <- warmup[order(warmup$stage, warmup$tau, -warmup$b0, warmup$chain),
  c("stage", group, setdiff(names(warmup), c("stage", group)))]
stopifnot(nrow(paper) == 12L, nrow(differences) == 18L, nrow(warmup) == 45L)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
emit(paper, out, "paper_air_table")
emit(differences, out, "paired_pmala_minus_admm")
emit(warmup, out, "warmup_counters_by_cell")
emit(curves, out, "spod_curves")
