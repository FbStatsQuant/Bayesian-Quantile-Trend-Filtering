# Joint gate analysis: Felipe's original joint sampler (F; 30k/10k, 1 chain) vs joint v3 (exact reflective HMC; 2 chains x 30k/10k), same data,
# priors and ordering constraint. Per config and level: paired MSE ratio V3/F, crossings, Rhat(log lambda) (V3, 2 chains), ESS(log lambda)/s, wall time.
# Usage: Rscript joint_gate_analyze.R <joint_gate dir> <out dir> <Individual_Sampler_PMALA_Augmented.R (for simulate_data)>
.libPaths(c("/home/fb31/R/e02lib", .libPaths())); suppressPackageStartupMessages({ library(ggplot2); library(posterior) })
a <- commandArgs(TRUE); IN <- a[1]; OUT <- a[2]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE); options(width = 220)
src <- readLines(a[3]); i0 <- grep("^simulate_data <- function", src); i1 <- grep("^# ---- Model pieces", src) - 1; eval(parse(text = src[i0:i1]))
fs <- list.files(IN, pattern = "\\.rds$", full.names = TRUE)
meta <- function(f) { b <- basename(f); o <- readRDS(f)
  if (!is.null(o$set)) list(set = o$set, bl = o$bl, noise = o$noise, arm = if (grepl("_F_", b)) "F" else "V3", chain = as.integer(sub(".*_c(\\d+)\\.rds", "\\1", b)), o = o)
  else { p <- strsplit(sub("\\.rds$", "", b), "_")[[1]]; list(set = "tail", bl = "VS", noise = p[2], arm = p[1], chain = as.integer(sub("c", "", p[4])), o = o) } }
M <- lapply(fs, meta)
key <- function(x) paste(x$set, x$bl, x$noise)
cfgs <- unique(sapply(M, key))
rows <- list(); for (cf in cfgs) {
  G <- M[sapply(M, key) == cf]; Fm <- G[sapply(G, `[[`, "arm") == "F"]; Vm <- G[sapply(G, `[[`, "arm") == "V3"]
  if (!length(Fm) || !length(Vm)) next
  Fo <- Fm[[1]]$o; taus <- if (!is.null(Fo$taus)) Fo$taus else c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)
  Vest <- Reduce(`+`, lapply(Vm, function(x) x$o$est)) / length(Vm); truths <- Fo$truths
  mseF <- colMeans((Fo$est - truths)^2); mseV <- colMeans((Vest - truths)^2)
  rh <- sapply(seq_along(taus), function(j) if (length(Vm) > 1) rhat(sapply(Vm, function(x) log(x$o$lam[, j]))) else NA)
  essV <- Reduce(`+`, lapply(Vm, function(x) x$o$ess_loglam)); secV <- sum(sapply(Vm, function(x) x$o$seconds))
  rows[[cf]] <- data.frame(set = G[[1]]$set, bl = G[[1]]$bl, noise = G[[1]]$noise, tau = taus, mse_F = mseF, mse_V3 = mseV, ratio = mseV / mseF,
    cross_F = Fo$crossings, cross_V3 = sum(sapply(Vm, function(x) x$o$crossings)), rhat_V3 = rh, esss_F = Fo$ess_loglam / Fo$seconds, esss_V3 = essV / secV,
    sec_F = Fo$seconds, sec_V3_total = secV, chains_V3 = length(Vm))
  # figure: data, truth, his joint means, v3 means (all levels)
  bl <- G[[1]]$bl; noise <- G[[1]]$noise; y <- simulate_data(1L, 500L, taus[1], bl, noise)$y; u <- (1:500) / 500
  L <- do.call(rbind, lapply(seq_along(taus), function(j) rbind(data.frame(u = u, v = truths[, j], what = "True quantile", tau = taus[j]),
        data.frame(u = u, v = Fo$est[, j], what = "Felipe's joint sampler", tau = taus[j]), data.frame(u = u, v = Vest[, j], what = "Joint v3 (exact HMC)", tau = taus[j]))))
  L$what <- factor(L$what, levels = c("True quantile", "Felipe's joint sampler", "Joint v3 (exact HMC)")); L$grp <- paste(L$what, L$tau)
  sub <- paste(sprintf("τ=%s: %.3g→%.3g", format(taus), mseF, mseV), collapse = "  ·  ")
  g <- ggplot() + geom_point(data = data.frame(u = u, y = y), aes(u, y), colour = "grey75", size = 0.4, alpha = 0.5) +
    geom_line(data = L, aes(u, v, colour = what, linetype = what, group = grp), linewidth = 0.45) +
    scale_colour_manual(values = c(`True quantile` = "black", `Felipe's joint sampler` = "#0072B2", `Joint v3 (exact HMC)` = "#D55E00"), name = NULL) +
    scale_linetype_manual(values = c(`True quantile` = "22", `Felipe's joint sampler` = "solid", `Joint v3 (exact HMC)` = "solid"), name = NULL) +
    labs(title = sprintf("%s · %s · joint levels %s–%s (%s set)", bl, c(Normal = "Gaussian", Beta = "Beta", Mixed = "Mixed normal")[[noise]], format(min(taus)), format(max(taus)), G[[1]]$set),
         subtitle = paste("MSE his→v3:", sub), x = "u", y = "y") +
    theme_minimal(base_size = 10) + theme(legend.position = "bottom", plot.title = element_text(face = "bold"), plot.subtitle = element_text(size = 6.5, colour = "grey25"))
  ggsave(file.path(OUT, sprintf("joint_%s_%s_%s.png", G[[1]]$set, bl, noise)), g, width = 8, height = 5, dpi = 300, device = "png", type = "cairo")
}
R <- do.call(rbind, rows); write.csv(R, file.path(OUT, "joint_gate_levels.csv"), row.names = FALSE)
print(R, digits = 3, row.names = FALSE)
cat(sprintf("\nALL levels: median ratio V3/F %.3f, max %.3f, levels > 1.25: %d of %d; crossings F %d, V3 %d; max Rhat V3 %.3f; median ESS/s ratio %.0f\n",
            median(R$ratio), max(R$ratio), sum(R$ratio > 1.25), nrow(R), sum(R$cross_F), sum(R$cross_V3), max(R$rhat_V3, na.rm = TRUE), median(R$esss_V3 / R$esss_F)))
for (s in unique(R$set)) { x <- R[R$set == s, ]; cat(sprintf("%s set: median %.3f, max %.3f, levels < 1: %d/%d\n", s, median(x$ratio), max(x$ratio), sum(x$ratio < 1), nrow(x))) }
