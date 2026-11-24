# E-08 analysis. Usage: Rscript e08_analyze.R FITS_DIR OUT_DIR
# Reads <arm>_t<100tau>.rds from FITS_DIR (missing fits are tolerated: NA entries) and writes
# e08_table.csv, e08_table.md, e08_fits.png in OUT_DIR.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: Rscript e08_analyze.R FITS_DIR OUT_DIR")
fits_dir <- args[1]; out_dir <- args[2]
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
taus <- c(0.05, 0.25, 0.50, 0.75, 0.95); arms <- c("new", "paper")
get <- function(arm, tau) {
  p <- file.path(fits_dir, sprintf("%s_t%d.rds", arm, as.integer(round(100 * tau))))
  if (file.exists(p)) readRDS(p) else NULL
}
fits <- lapply(arms, function(a) lapply(taus, function(t) get(a, t))); names(fits) <- arms
mse <- function(f) if (is.null(f)) NA_real_ else mean((f$theta_mean - f$truth)^2)
med <- function(f, what) if (is.null(f)) NA_real_ else switch(what,
  lam = median(f$lambda), lamsig = median(f$lambda * f$sigma))
pick <- function(f, nm) if (is.null(f)) NA_real_ else f[[nm]]

tab <- do.call(rbind, lapply(seq_along(taus), function(i) {
  n <- fits$new[[i]]; p <- fits$paper[[i]]
  data.frame(tau = taus[i],
    MSE_new = mse(n), MSE_paper = mse(p), MSE_ratio = mse(n) / mse(p),
    lambda_med_new = med(n, "lam"), lambda_med_paper = med(p, "lam"),
    lamsig_med_new = med(n, "lamsig"), lamsig_med_paper = med(p, "lamsig"),
    ESS_lambda_new = pick(n, "ess_lambda"), ESS_lambda_paper = pick(p, "ess_lambda"),
    ESS_theta_med_new = pick(n, "ess_theta_median"), ESS_theta_med_paper = pick(p, "ess_theta_median"),
    seconds_new = pick(n, "seconds"), seconds_paper = pick(p, "seconds"))
}))
write.csv(tab, file.path(out_dir, "e08_table.csv"), row.names = FALSE)

fmt <- function(v, d = 3) ifelse(is.na(v), "NA", formatC(v, format = "g", digits = d))
md <- c("| tau | MSE new | MSE paper | ratio new/paper | median lambda new | median lambda paper | median lambda*sigma new | median lambda*sigma paper | ESS(lambda) new | ESS(lambda) paper | med ESS(theta) new | med ESS(theta) paper |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(tab))) with(tab[i, ], md <<- c(md, paste0("| ", paste(c(
  sprintf("%.2f", tau), fmt(MSE_new, 4), fmt(MSE_paper, 4), fmt(MSE_ratio, 3),
  fmt(lambda_med_new), fmt(lambda_med_paper), fmt(lamsig_med_new), fmt(lamsig_med_paper),
  fmt(ESS_lambda_new, 3), fmt(ESS_lambda_paper, 3), fmt(ESS_theta_med_new, 3), fmt(ESS_theta_med_paper, 3)), collapse = " | "), " |")))
writeLines(md, file.path(out_dir, "e08_table.md"))
print(tab, digits = 4)

# ---- Figure ----
# Okabe-Ito: vermilion = new (b0 = 1e-5), blue = paper (b0 = 1e-3)
cols <- c(new = "#D55E00", paper = "#0072B2")
labs <- c(new = "new: b0 = 1e-5", paper = "paper: b0 = 1e-3")
png_path <- file.path(out_dir, "e08_fits.png")
# a panel is drawable if at least one arm exists
ref <- lapply(seq_along(taus), function(i) if (!is.null(fits$new[[i]])) fits$new[[i]] else fits$paper[[i]])
panel_title <- function(t) sprintf("VS · Normal · τ = %.2f", t)
panel_sub <- function(i) sprintf("MSE new = %s, paper = %s", fmt(tab$MSE_new[i], 3), fmt(tab$MSE_paper[i], 3))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  pts <- do.call(rbind, lapply(seq_along(taus), function(i) if (is.null(ref[[i]])) NULL else
    data.frame(panel = i, x = ref[[i]]$x, y = ref[[i]]$y, truth = ref[[i]]$truth)))
  lns <- do.call(rbind, lapply(seq_along(taus), function(i) do.call(rbind, lapply(arms, function(a) {
    f <- fits[[a]][[i]]; if (is.null(f)) NULL else data.frame(panel = i, x = f$x, fit = f$theta_mean, arm = labs[[a]])
  }))))
  lab <- vapply(seq_along(taus), function(i) paste0(panel_title(taus[i]), "\n", panel_sub(i)), "")
  pts$panel <- factor(lab[pts$panel], levels = lab)
  if (!is.null(lns)) lns$panel <- factor(lab[lns$panel], levels = lab)
  p <- ggplot() +
    geom_point(data = pts, aes(x, y), colour = "grey75", size = 0.5, alpha = 0.7) +
    geom_line(data = pts, aes(x, truth), colour = "black", linewidth = 0.7) +
    { if (!is.null(lns)) geom_line(data = lns, aes(x, fit, colour = arm, linetype = arm), linewidth = 0.8) } +
    scale_colour_manual(NULL, values = setNames(cols, labs)) +
    scale_linetype_manual(NULL, values = setNames(c("solid", "longdash"), labs)) +
    facet_wrap(~panel, nrow = 2, scales = "free_y") +
    labs(x = "i", y = "y", caption = "grey points: data; black: true tau-quantile") +
    theme_bw(base_size = 10) +
    theme(legend.position = "bottom", strip.text = element_text(size = 8, hjust = 0), panel.grid.minor = element_blank())
  ggsave(png_path, p, width = 10, height = 6, dpi = 150, bg = "white")
} else {
  png(png_path, width = 1500, height = 900, res = 150)
  op <- par(mfrow = c(2, 3), mar = c(3.2, 3.2, 3.2, 0.8), mgp = c(2, 0.6, 0)); on.exit(par(op))
  for (i in seq_along(taus)) {
    r <- ref[[i]]
    if (is.null(r)) { plot.new(); title(panel_title(taus[i])); next }
    yl <- range(r$y, r$truth)
    plot(r$x, r$y, pch = 16, cex = 0.3, col = "grey75", ylim = yl, xlab = "i", ylab = "y",
         main = panel_title(taus[i]), cex.main = 0.9)
    mtext(panel_sub(i), 3, 0.2, cex = 0.65)
    lines(r$x, r$truth, col = "black", lwd = 1.5)
    for (a in arms) { f <- fits[[a]][[i]]; if (!is.null(f)) lines(f$x, f$theta_mean, col = cols[[a]], lwd = 1.5, lty = if (a == "new") 1 else 2) }
  }
  plot.new(); legend("center", c("data", "true quantile", labs), col = c("grey75", "black", cols), pch = c(16, NA, NA, NA),
                     lty = c(NA, 1, 1, 2), lwd = 1.5, bty = "n")
  dev.off()
}
cat("wrote", file.path(out_dir, c("e08_table.csv", "e08_table.md", "e08_fits.png")), sep = "\n")
