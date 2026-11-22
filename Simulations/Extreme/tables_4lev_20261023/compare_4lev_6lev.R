# 4-level vs 6-level joint P-MALA, with the four individual methods, at tau = 0.96-0.99. Usage:
#   Rscript --vanilla compare_4lev_6lev.R JOINT4_SUMMARY JOINT4_PER_TASK JOINT6_SUMMARY JOINT6_PER_TASK INDIV_SUMMARY OUT_DIR
# Joint-4: fit at 0.96-0.99 (2026-10-23 run). Joint-6: fit at 0.90-0.99, reported at 0.96-0.99 (2026-10-07).
# Individual methods from the 2026-10-07 individual run. Crossings for every method are counted over the
# n = 500 design points among the reported levels 0.96-0.99 (common_extreme.R::crossing_counts).
# The data y depend only on (baseline, noise, seed), so joint-4 and joint-6 share data: the paired
# difference uses per-seed MSE.
args <- commandArgs(TRUE)
stopifnot(length(args) == 6L, all(file.exists(args[1:5])))
out_dir <- args[6]; dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

labels <- c(joint4 = "Joint PMALA, 4 levels", joint6 = "Joint PMALA, 6 levels (Oct 7)",
            pmala = "Indiv. PMALA", admm = "ADMM (eBIC)", onizuka_lap = "Onizuka Laplace",
            onizuka_hs = "Onizuka HS")
keep <- c("method", "baseline", "noise", "tau", "n_seeds", "mean_MSE", "se_MSE", "mean_crossings_neighbor",
          "se_crossings_neighbor", "mean_crossings_all", "se_crossings_all")
j4 <- read.csv(args[1]); j6 <- read.csv(args[3]); ind <- read.csv(args[5])
stopifnot(all(j4$method == "joint"), all(j6$method == "joint"))
j4$method <- "joint4"; j6$method <- "joint6"
all <- rbind(j4[keep], j6[keep], ind[keep])
taus <- c(0.96, 0.97, 0.98, 0.99); noises <- c("Normal", "Beta", "Mixed"); bases <- c("VS", "S")
stopifnot(setequal(unique(all$method), names(labels)), all(all$n_seeds == 100L),
          !anyDuplicated(all[c("method", "baseline", "noise", "tau")]),
          nrow(all) == length(labels) * 2L * 3L * 4L, all(round(all$tau, 2) %in% taus))
all$tau <- round(all$tau, 2)

# Paired per-seed difference joint4 - joint6 (same data, same seeds).
p4 <- read.csv(args[2]); p6 <- read.csv(args[4])
p4$tau <- round(p4$tau, 2); p6$tau <- round(p6$tau, 2)
p6 <- p6[p6$tau %in% taus, ]
pk <- c("baseline", "noise", "tau", "seed")
pm <- merge(p4[c(pk, "MSE")], p6[c(pk, "MSE")], by = pk, suffixes = c("_4", "_6"))
stopifnot(nrow(pm) == 2L * 3L * 4L * 100L, nrow(p4) == nrow(pm), !anyNA(pm$MSE_4), !anyNA(pm$MSE_6))
se <- function(x) sd(x) / sqrt(length(x))
pd <- do.call(rbind, lapply(split(pm, pm[c("baseline", "noise", "tau")], drop = TRUE), function(d)
  data.frame(baseline = d$baseline[1], noise = d$noise[1], tau = d$tau[1], n_pairs = nrow(d),
             mean_diff_4minus6 = mean(d$MSE_4 - d$MSE_6), se_diff_4minus6 = se(d$MSE_4 - d$MSE_6),
             share_seeds_4_better = mean(d$MSE_4 < d$MSE_6))))
# The paired means must reproduce the summary means.
chk <- merge(pd, merge(j4[c("baseline", "noise", "tau", "mean_MSE")], j6[c("baseline", "noise", "tau", "mean_MSE")],
                       by = c("baseline", "noise", "tau"), suffixes = c("_4", "_6")))
stopifnot(nrow(chk) == 24L, max(abs(chk$mean_diff_4minus6 - (chk$mean_MSE_4 - chk$mean_MSE_6))) < 1e-12)

# Best (lowest mean MSE) per (baseline, noise, tau) among all six methods.
cell <- interaction(all$baseline, all$noise, all$tau, drop = TRUE)
all$best <- ave(all$mean_MSE, cell, FUN = function(v) v == min(v)) == 1
all$method_label <- unname(labels[all$method])
all <- all[order(match(all$baseline, bases), match(all$noise, noises), all$tau, match(all$method, names(labels))), ]
all <- merge(all, pd, by = c("baseline", "noise", "tau"), all.x = TRUE, sort = FALSE)
pair_cols <- c("n_pairs", "mean_diff_4minus6", "se_diff_4minus6", "share_seeds_4_better")
all[all$method != "joint4", pair_cols] <- NA
all <- all[order(match(all$baseline, bases), match(all$noise, noises), all$tau, match(all$method, names(labels))), ]
write.csv(all[c("baseline", "noise", "tau", "method", "method_label", keep[-(1:4)], "best", pair_cols)],
          file.path(out_dir, "comparison_4lev_6lev_individual.csv"), row.names = FALSE)

# Markdown: per baseline and noise, rows = methods, columns = tau.
f <- function(m, s, d = 5) sprintf(paste0("%.", d, "f (%.", d, "f)"), m, s)
md <- c("# Joint P-MALA 4 levels vs 6 levels, with the individual methods, tau = 0.96-0.99",
        "", "MSE, mean (SE) over 100 seeds; **bold** marks the lowest mean in each (baseline, noise, tau).",
        "Joint-4 fits 0.96-0.99 only (2026-10-23); joint-6 fits 0.90-0.99 (2026-10-07). n = 500, k = 2.", "")
for (b in bases) {
  md <- c(md, paste0("## Baseline ", b, ": MSE"), "")
  for (nz in noises) {
    md <- c(md, paste0("### ", nz), "", paste0("| Method | ", paste(sprintf("%.2f", taus), collapse = " | "), " |"),
            paste0("|---|", strrep("---|", length(taus))))
    for (m in names(labels)) {
      r <- all[all$baseline == b & all$noise == nz & all$method == m, ]; r <- r[order(r$tau), ]
      cells <- ifelse(r$best, paste0("**", f(r$mean_MSE, r$se_MSE), "**"), f(r$mean_MSE, r$se_MSE))
      md <- c(md, paste0("| ", labels[[m]], " | ", paste(cells, collapse = " | "), " |"))
    }
    md <- c(md, "")
  }
}
md <- c(md, "## Paired difference, joint-4 minus joint-6 (same data and seeds)", "",
        "Mean (SE) of per-seed MSE difference; negative means 4 levels is better. Share = fraction of seeds where 4 levels has lower MSE.", "",
        paste0("| Baseline | Noise | ", paste(sprintf("%.2f", taus), collapse = " | "), " |"),
        paste0("|---|---|", strrep("---|", length(taus))))
for (b in bases) for (nz in noises) {
  r <- pd[pd$baseline == b & pd$noise == nz, ]; r <- r[order(r$tau), ]
  md <- c(md, paste0("| ", b, " | ", nz, " | ",
                     paste(sprintf("%s, share %.2f", f(r$mean_diff_4minus6, r$se_diff_4minus6), r$share_seeds_4_better),
                           collapse = " | "), " |"))
}
md <- c(md, "", "## Crossings among the reported levels 0.96-0.99", "",
        "Mean (SE) over seeds of the per-level crossing count over the 500 design points: all = against every other reported level; neighbour = against the adjacent reported levels.", "")
for (b in bases) {
  md <- c(md, paste0("### Baseline ", b), "",
          paste0("| Noise | Method | ", paste(paste0("all ", sprintf("%.2f", taus)), collapse = " | "), " | ",
                 paste(paste0("nbr ", sprintf("%.2f", taus)), collapse = " | "), " |"),
          paste0("|---|---|", strrep("---|", 2L * length(taus))))
  for (nz in noises) for (m in names(labels)) {
    r <- all[all$baseline == b & all$noise == nz & all$method == m, ]; r <- r[order(r$tau), ]
    md <- c(md, paste0("| ", nz, " | ", labels[[m]], " | ",
                       paste(f(r$mean_crossings_all, r$se_crossings_all, 2), collapse = " | "), " | ",
                       paste(f(r$mean_crossings_neighbor, r$se_crossings_neighbor, 2), collapse = " | "), " |"))
  }
  md <- c(md, "")
}
writeLines(md, file.path(out_dir, "comparison_4lev_6lev_individual.md"))
wins <- table(all$method_label[all$best])
cat("rows:", nrow(all), "\nbest counts:\n"); print(wins)
cat("COMPARE_SUCCESS", out_dir, "\n")
