args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L)
root <- normalizePath(args[1], mustWork = TRUE)
x <- read.csv(file.path(root, "summary", "average_metrics_tau096_099.csv"))
ref <- read.csv(file.path(root, "paper_reference", "table2_mse.csv"))
stopifnot(nrow(x) == 12L, all(x$n_seeds == 100L), nrow(ref) == 12L,
          !anyDuplicated(ref[c("noise", "tau")]), !anyDuplicated(x[c("noise", "tau")]))
out <- merge(x, ref, by = c("noise", "tau"), all = TRUE)
stopifnot(nrow(out) == 12L, all(is.finite(as.matrix(out[, vapply(out, is.numeric, logical(1)), drop = FALSE]))))
out$joint_to_PMALA_ratio <- out$mean_MSE / out$paper_PMALA
out$MSE_change_vs_PMALA_pct <- 100 * (out$joint_to_PMALA_ratio - 1)
bench <- as.matrix(out[c("paper_PMALA", "paper_Laplace", "paper_Horseshoe", "paper_ADMM")])
out$paper_best_MSE <- apply(bench, 1, min)
out$paper_best_method <- colnames(bench)[max.col(-bench, ties.method = "first")]
out$joint_to_paper_best_ratio <- out$mean_MSE / out$paper_best_MSE
run_config <- readRDS(file.path(root, "metadata", "config.rds"))
out$joint_lambda_shape <- run_config$sampler$a0
out$joint_lambda_rate <- run_config$sampler$b0
out$paper_PMALA_lambda_rate <- 0.001
out <- out[order(match(out$noise, c("Normal", "Beta", "Mixed")), out$tau), ]
write.csv(out, file.path(root, "summary", "comparison_paper_table2.csv"), row.names = FALSE)
saveRDS(list(comparison = out, provenance = readLines(file.path(root, "paper_reference", "provenance.txt")),
  processed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE)), file.path(root, "summary", "comparison_paper_table2.rds"))
print(out[c("noise", "tau", "n_seeds", "mean_MSE", "paper_PMALA", "paper_Horseshoe",
            "paper_Laplace", "paper_ADMM", "MSE_change_vs_PMALA_pct")], row.names = FALSE)
cat("COMPARE_SUCCESS\n")
