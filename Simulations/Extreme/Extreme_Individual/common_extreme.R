# Shared code for the extreme-quantile campaigns (individual and joint jobs).
# An identical copy lives in Extreme_Joint_Sampler/; validation checks that the two copies match.

utc <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

atomic_rds <- function(x, path, compress = TRUE) {
  tmp <- paste0(path, ".tmp-", Sys.getpid())
  saveRDS(x, tmp, compress = compress)
  if (!file.rename(tmp, path)) stop("Cannot finalize ", path)
}

hash_files <- function(files, destination) {
  hashes <- system2("sha256sum", shQuote(files), stdout = TRUE)
  if (!is.null(attr(hashes, "status"))) stop("Output hashing failed")
  writeLines(hashes, destination)
}

tau_label <- function(tau) sprintf("%.2f", tau)

# Data generator: the same code and RNG convention as simulate_data() in
# Individual_Sampler_PMALA_Augmented.R and Joint_Sampler_PMALA_Augmented.R.
# The response depends only on (seed, baseline, noise); truth has one column per tau.
simulate_extreme <- function(seed, n, baseline, noise, taus) {
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  x <- seq_len(n); xs <- x / n
  base <- switch(baseline,
    VS = 2 + sin(4 * xs - 2) + 2 * exp(-30 * (4 * xs - 2)^2),
    S  = sin(2 * pi * x / n),
    stop("Unknown baseline ", baseline))
  if (noise == "Mixed") {
    eps <- vapply(xs, function(xi) if (runif(1) < xi) rnorm(1, -.2, sqrt(.5)) else rnorm(1, .2, sqrt(.5)), numeric(1))
    q <- vapply(taus, function(t) vapply(xs, function(xi) uniroot(function(u) xi * pnorm(u, -.2, sqrt(.5)) +
                  (1 - xi) * pnorm(u, .2, sqrt(.5)) - t, c(-10, 10))$root, numeric(1)), numeric(n))
  } else if (noise == "Beta") {
    eps <- vapply(xs, function(xi) rbeta(1, 1, 11 - 10 * xi), numeric(1))
    q <- vapply(taus, function(t) qbeta(t, 1, 11 - 10 * xs), numeric(n))
  } else if (noise == "Normal") {
    s <- (1 + xs^2) / 4
    eps <- rnorm(n, 0, s)
    q <- vapply(taus, function(t) qnorm(t) * s, numeric(n))
  } else stop("Unknown noise ", noise)
  q <- matrix(q, n, length(taus), dimnames = list(NULL, tau_label(taus)))
  list(x = x, y = base + eps, baseline = base, truth = base + q, taus = taus)
}

# Crossings between posterior-mean curves at the reported levels only.
# est: n x J matrix, columns in increasing tau. A crossing between levels a < b at index i is
# est[i, a] > est[i, b] (ties are not crossings). For level j, "neighbor" sums the crossings with
# the adjacent reported levels (j - 1, j + 1); "all" sums the crossings with every other reported level.
crossing_counts <- function(est, taus) {
  J <- ncol(est); stopifnot(J == length(taus), all(diff(taus) > 0))
  pair <- matrix(0L, J, J, dimnames = list(tau_label(taus), tau_label(taus)))
  for (a in seq_len(J - 1L)) for (b in (a + 1L):J) pair[a, b] <- pair[b, a] <- sum(est[, a] > est[, b])
  neighbor <- vapply(seq_len(J), function(j) {
    nb <- intersect(c(j - 1L, j + 1L), seq_len(J)); sum(pair[j, nb])
  }, numeric(1))
  list(per_level = data.frame(tau = taus, crossings_neighbor = neighbor, crossings_all = rowSums(pair)),
       pairs = pair)
}

# Per-task framework: lock, attempt directory, result file, output hashes, SUCCESS marker.
# fit_fun(dat, row) must return list(est = numeric(n), diag = list(...)).
run_extreme_task <- function(run_root, code_root, row, task_root, cfg, report_taus, fit_fun, method) {
  dir.create(task_root, recursive = TRUE, showWarnings = FALSE)
  if (file.exists(file.path(task_root, "SUCCESS"))) stop("Task complete; refusing to overwrite ", task_root)
  lock <- file.path(task_root, "worker.lock")
  if (!dir.create(lock, showWarnings = FALSE)) stop("Task locked; confirm the old job has ended before removing ", lock)
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  attempt <- file.path(task_root, paste0("attempt_", format(Sys.time(), "%Y%m%dT%H%M%S", tz = "UTC"),
    "_", Sys.getenv("SLURM_JOB_ID", "manual"), "_", Sys.getpid()))
  stopifnot(dir.create(attempt))
  meta <- list(started_utc = utc(), host = Sys.info()[["nodename"]], pid = Sys.getpid(),
    command = commandArgs(), method = method, task = row,
    slurm = Sys.getenv(c("SLURM_JOB_ID", "SLURM_ARRAY_JOB_ID", "SLURM_ARRAY_TASK_ID")),
    threads = Sys.getenv(c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS")))
  dput(meta, file = file.path(attempt, "metadata.txt"))
  status <- tryCatch({
    dat <- simulate_extreme(row$seed, cfg$n, row$baseline, row$noise, report_taus)
    started <- proc.time()[["elapsed"]]
    out <- fit_fun(dat, row)
    seconds <- proc.time()[["elapsed"]] - started
    est <- out$est
    if (is.null(dim(est))) est <- matrix(est, ncol = 1L)
    stopifnot(nrow(est) == cfg$n, all(is.finite(est)))
    truth <- dat$truth[, tau_label(row_taus(row, report_taus)), drop = FALSE]
    stopifnot(ncol(est) == ncol(truth))
    colnames(est) <- colnames(truth)
    result <- list(schema_version = 1L, method = method, task = row, config = cfg,
      y = dat$y, truth = truth, est = est, MSE = colMeans((est - truth)^2),
      diag = out$diag, seconds = seconds,
      source_sha256 = readLines(file.path(code_root, "SHA256SUMS")),
      started_utc = meta$started_utc, finished_utc = utc(), host = meta$host, slurm = meta$slurm,
      attempt = attempt)
    atomic_rds(result, file.path(attempt, "result.rds"))
    capture.output(sessionInfo(), file = file.path(attempt, "sessionInfo.txt"))
    writeLines(c("exit_status=0", paste0("finished_utc=", utc())), file.path(attempt, "exit_status.txt"))
    hash_files(list.files(attempt, full.names = TRUE), file.path(attempt, "OUTPUT_SHA256SUMS"))
    marker <- file.path(task_root, paste0("SUCCESS.tmp-", Sys.getpid()))
    writeLines(attempt, marker)
    stopifnot(file.rename(marker, file.path(task_root, "SUCCESS")))
    cat(sprintf("WORKER_SUCCESS %s %s | MSE %s | %.0fs\n", method, basename(task_root),
                paste(sprintf("%.6f", result$MSE), collapse = "/"), seconds))
    0L
  }, error = function(e) {
    writeLines(c("exit_status=1", paste0("finished_utc=", utc()), paste0("error=", conditionMessage(e))),
               file.path(attempt, "exit_status.txt"))
    stop(e)
  })
  invisible(status)
}

# Individual tasks fit one level; joint tasks report all levels of report_taus.
row_taus <- function(row, report_taus) if (!is.null(row$tau)) row$tau else report_taus

# Scalar diagnostics kept in the per-task table (method-specific; NA where not applicable).
task_diag_row <- function(x) {
  d <- x$diag; first <- function(v) if (is.null(v)) NA_real_ else as.numeric(v)[1]
  data.frame(seconds = x$seconds,
    pmala_acc_post = if (x$method == "pmala") first(d$acc_post) else NA_real_,
    pmala_lambda_mean = if (x$method == "pmala") first(d$lambda_mean) else NA_real_,
    admm_lambda = if (x$method == "admm") first(d$lambda) else NA_real_,
    admm_boundary = if (x$method == "admm") isTRUE(d$boundary) else NA,
    admm_failed_candidates = if (x$method == "admm") first(d$n_failed) else NA_real_,
    joint_min_acc_post = if (x$method == "joint") min(d$acc_post) else NA_real_,
    joint_max_outside_post = if (x$method == "joint") max(d$outside_post) else NA_real_)
}

# Shared processing: verifies every task, recomputes MSE from the saved estimate and truth, checks that
# every method saw the identical response for each (baseline, noise, seed), computes crossings among
# the reported levels, and refuses to write any averages when a task is missing or invalid.
process_campaign <- function(run_root, cfg, grid, task_root_of, report_taus) {
  code_root <- file.path(run_root, "code")
  manifest <- readLines(file.path(code_root, "SHA256SUMS"))
  out_dir <- file.path(run_root, "summary", paste0("attempt_", format(Sys.time(), "%Y%m%dT%H%M%S", tz = "UTC"), "_", Sys.getpid()))
  stopifnot(dir.create(out_dir, recursive = TRUE))
  problems <- character(nrow(grid)); per_task <- vector("list", nrow(grid))
  est <- list(); y_ref <- list(); truth_ref <- list()
  for (i in seq_len(nrow(grid))) {
    row <- grid[i, , drop = FALSE]
    per_task[[i]] <- tryCatch({
      x <- read_task_result(task_root_of(run_root, row))
      stopifnot(identical(x$config, cfg), identical(x$task, row), identical(x$source_sha256, manifest),
                length(x$y) == cfg$n, nrow(x$est) == cfg$n, all(is.finite(x$est)))
      taus <- row_taus(row, report_taus)
      stopifnot(identical(colnames(x$est), tau_label(taus)), identical(colnames(x$truth), tau_label(taus)))
      mse <- colMeans((x$est - x$truth)^2)
      stopifnot(isTRUE(all.equal(unname(mse), unname(x$MSE), tolerance = 1e-12)))
      dkey <- paste(row$baseline, row$noise, row$seed, sep = "|")
      if (is.null(y_ref[[dkey]])) y_ref[[dkey]] <- x$y else stopifnot(identical(y_ref[[dkey]], x$y))
      for (t in colnames(x$truth)) {
        tkey <- paste(row$baseline, row$noise, row$seed, t, sep = "|")
        if (is.null(truth_ref[[tkey]])) truth_ref[[tkey]] <- x$truth[, t] else stopifnot(identical(truth_ref[[tkey]], x$truth[, t]))
      }
      ekey <- paste(row$method, dkey, sep = "|")
      if (is.null(est[[ekey]])) est[[ekey]] <- matrix(NA_real_, cfg$n, length(report_taus), dimnames = list(NULL, tau_label(report_taus)))
      est[[ekey]][, colnames(x$est)] <- x$est
      data.frame(method = row$method, baseline = row$baseline, noise = row$noise, tau = taus,
                 seed = row$seed, MSE = unname(mse), task_diag_row(x), row.names = NULL)
    }, error = function(e) { problems[i] <<- conditionMessage(e); NULL })
    if (i %% 500L == 0L) cat("INSPECTED", i, "of", nrow(grid), utc(), "\n")
  }
  write.csv(cbind(grid, valid = problems == "", problem = problems), file.path(out_dir, "task_status.csv"), row.names = FALSE)
  if (any(nzchar(problems))) stop(sum(nzchar(problems)), " incomplete/invalid tasks; no averages written: ", out_dir)
  per_task <- do.call(rbind, per_task)
  cross <- do.call(rbind, lapply(names(est), function(k) {
    e <- est[[k]]; stopifnot(all(is.finite(e)))
    p <- strsplit(k, "|", fixed = TRUE)[[1]]
    data.frame(method = p[1], baseline = p[2], noise = p[3], seed = as.integer(p[4]),
               crossing_counts(e, report_taus)$per_level)
  }))
  se <- function(v) sd(v) / sqrt(length(v))
  cells <- unique(per_task[c("method", "baseline", "noise", "tau")])
  summary <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
    c0 <- cells[i, , drop = FALSE]
    m <- merge(c0, per_task); cr <- merge(c0, cross)
    stopifnot(nrow(m) == length(cfg$seeds), nrow(cr) == length(cfg$seeds), identical(sort(m$seed), sort(cfg$seeds)))
    data.frame(c0, n_seeds = nrow(m), mean_MSE = mean(m$MSE), se_MSE = se(m$MSE),
               mean_crossings_neighbor = mean(cr$crossings_neighbor), se_crossings_neighbor = se(cr$crossings_neighbor),
               mean_crossings_all = mean(cr$crossings_all), se_crossings_all = se(cr$crossings_all),
               mean_seconds = mean(m$seconds), max_seconds = max(m$seconds),
               mean_pmala_acc_post = mean(m$pmala_acc_post), admm_boundary_share = mean(m$admm_boundary),
               admm_failed_candidates_total = sum(m$admm_failed_candidates),
               min_joint_acc_post = min(m$joint_min_acc_post), max_joint_outside_post = max(m$joint_max_outside_post),
               row.names = NULL)
  }))
  write.csv(per_task, file.path(out_dir, "per_task_metrics.csv"), row.names = FALSE)
  write.csv(cross, file.path(out_dir, "per_seed_crossings.csv"), row.names = FALSE)
  write.csv(summary, file.path(out_dir, "summary.csv"), row.names = FALSE)
  atomic_rds(list(config = cfg, report_taus = report_taus, per_task = per_task, crossings = cross, summary = summary,
                  est = est, y = y_ref, truth = truth_ref, source_sha256 = manifest, processed_utc = utc()),
             file.path(out_dir, "results.rds"))
  capture.output(sessionInfo(), file = file.path(out_dir, "sessionInfo.txt"))
  hash_files(list.files(out_dir, full.names = TRUE), file.path(out_dir, "OUTPUT_SHA256SUMS"))
  writeLines(utc(), file.path(out_dir, "SUCCESS"))
  print(summary[c("method", "baseline", "noise", "tau", "mean_MSE", "mean_crossings_neighbor", "mean_crossings_all")], row.names = FALSE)
  cat("PROCESS_SUCCESS", out_dir, utc(), "\n")
  invisible(out_dir)
}

# Verify one task's audited result (used by both processing scripts).
read_task_result <- function(task_root) {
  marker <- file.path(task_root, "SUCCESS")
  if (!file.exists(marker)) stop("missing SUCCESS marker")
  attempt <- readLines(marker)
  stopifnot(length(attempt) == 1L, normalizePath(dirname(attempt), mustWork = TRUE) == normalizePath(task_root, mustWork = TRUE))
  check <- system2("sha256sum", c("--check", "--quiet", shQuote(file.path(attempt, "OUTPUT_SHA256SUMS"))),
                   stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(check, "status"))) stop("output SHA256 verification failed: ", paste(check, collapse = "; "))
  readRDS(file.path(attempt, "result.rds"))
}
