# Usage: Rscript --vanilla make_tables.R INDIVIDUAL_SUMMARY_DIR JOINT_SUMMARY_DIR OUT_DIR
# Combines the processed individual and joint campaigns into the tables for tau = 0.96-0.99:
#   MSE, average neighbouring crossings, average crossings with all other reported levels,
# one table per baseline (VS, S) with a block per noise, as CSV and LaTeX (booktabs).
# Each crossing entry is the average over seeds of the number of indices (out of n) at which the
# posterior-mean curve crosses the neighbouring (or all other) reported levels' curves.
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) stop("Usage: make_tables.R INDIVIDUAL_SUMMARY_DIR JOINT_SUMMARY_DIR OUT_DIR")
read_summary <- function(d) {
  stopifnot(file.exists(file.path(d, "SUCCESS")))
  check <- system2("sha256sum", c("--check", "--quiet", shQuote(file.path(d, "OUTPUT_SHA256SUMS"))), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(check, "status"))) stop("summary hash check failed: ", d)
  readRDS(file.path(d, "results.rds"))
}
ind <- read_summary(normalizePath(args[1], mustWork = TRUE))
jnt <- read_summary(normalizePath(args[2], mustWork = TRUE))
out <- args[3]; dir.create(out, recursive = TRUE, showWarnings = FALSE)
stopifnot(identical(ind$report_taus, jnt$report_taus), ind$config$n == jnt$config$n,
          identical(sort(ind$config$seeds), sort(jnt$config$seeds)))
# Both campaigns must have fitted the identical response and truth for every (baseline, noise, seed).
stopifnot(identical(sort(names(ind$y)), sort(names(jnt$y))))
for (k in names(ind$y)) stopifnot(identical(ind$y[[k]], jnt$y[[k]]))
for (k in intersect(names(ind$truth), names(jnt$truth))) stopifnot(identical(ind$truth[[k]], jnt$truth[[k]]))

s <- rbind(ind$summary, jnt$summary)
labels <- c(onizuka_lap = "Onizuka (Laplace)", onizuka_hs = "Onizuka (Horseshoe)", pmala = "Bayesian-PMALA",
            admm = "ADMM", joint = "Joint sampler (non-crossing)")
s$label <- labels[s$method]
taus <- ind$report_taus
write.csv(s, file.path(out, "summary_all_methods.csv"), row.names = FALSE)

wide <- function(base, value, digits) {
  blocks <- lapply(c("Beta", "Mixed", "Normal"), function(nz) {
    d <- s[s$baseline == base & s$noise == nz, ]
    m <- t(vapply(names(labels), function(me) vapply(taus, function(t) d[[value]][d$method == me & abs(d$tau - t) < 1e-12], numeric(1)), numeric(length(taus))))
    data.frame(baseline = base, noise = nz, method = unname(labels), m, check.names = FALSE, row.names = NULL)
  })
  w <- do.call(rbind, blocks); names(w)[4:(3 + length(taus))] <- sprintf("%.2f", taus); w
}
noise_name <- c(Beta = "Beta", Mixed = "Mixed normal", Normal = "Gaussian")
latex <- function(w, caption, label, digits) {
  fmt <- function(v) formatC(v, format = "f", digits = digits)
  lines <- c("\\begin{table}[!htbp]", "\\centering", "\\small", sprintf("\\caption{%s}", caption), sprintf("\\label{%s}", label),
             sprintf("\\begin{tabular}{l%s}", strrep("r", length(taus))), "\\toprule")
  for (nz in c("Beta", "Mixed", "Normal")) {
    if (nz != "Beta") lines <- c(lines, "\\midrule")
    lines <- c(lines, paste0(noise_name[[nz]], " & ", paste(sprintf("$%.2f$", taus), collapse = " & "), " \\\\"), "\\midrule")
    d <- w[w$noise == nz, ]
    for (i in seq_len(nrow(d))) lines <- c(lines, paste0(d$method[i], " & ", paste(fmt(unlist(d[i, 4:(3 + length(taus))])), collapse = " & "), " \\\\"))
  }
  c(lines, "\\bottomrule", "\\end{tabular}", "\\end{table}")
}
spec <- list(
  list(value = "mean_MSE", stem = "mse", digits = 6,
       caption = "Mean squared error at extreme upper quantiles for the %s signal, $n=500$ and $k=2$, averaged over 100 replications."),
  list(value = "mean_crossings_neighbor", stem = "crossings_neighbor", digits = 2,
       caption = "Average number of indices (out of $n=500$) at which the estimate crosses the adjacent reported levels, %s signal."),
  list(value = "mean_crossings_all", stem = "crossings_all", digits = 2,
       caption = "Average number of indices (out of $n=500$) at which the estimate crosses any other reported level, %s signal."))
for (base in c("VS", "S")) for (sp in spec) {
  w <- wide(base, sp$value, sp$digits)
  write.csv(w, file.path(out, sprintf("%s_%s.csv", sp$stem, base)), row.names = FALSE)
  writeLines(latex(w, sprintf(sp$caption, base), sprintf("tab:ext_%s_%s", tolower(base), sp$stem), sp$digits),
             file.path(out, sprintf("%s_%s.tex", sp$stem, base)))
}
cat("TABLES_SUCCESS", normalizePath(out), "\n")
