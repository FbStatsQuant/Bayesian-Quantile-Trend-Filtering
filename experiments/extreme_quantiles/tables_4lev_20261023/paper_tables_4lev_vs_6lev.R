# Paper-format MSE tables (layout of tab:vs_ext_upper_mse / tab:s_ext_upper_mse) for the two joint designs:
#   option 4: joint fitted at 0.96-0.99 (2026-10-23 run), columns 0.96-0.99;
#   option 6: joint fitted at 0.90-0.99 (2026-10-07 run), columns 0.90-0.99 (the paper's current tables).
# Benchmarks: individual runs of 2026-10-07 (0.96-0.99) and 2026-10-21 (0.90/0.93), via mse_all_levels_all_methods.csv.
# Run from experiments/extreme_quantiles/. Writes paper_tables_{4lev,6lev}.{md,tex} into tables_4lev_20261023/.
all6 <- read.csv("tables_20261023/mse_all_levels_all_methods.csv")
j4 <- read.csv("tables_4lev_20261023/inputs/joint4_summary.csv")
all6 <- all6[all6$method != "joint_b0005_15k3k", ]
all6$method[all6$method == "joint_oct7_b001_30k10k"] <- "joint"
d4 <- rbind(all6[all6$method != "joint" & round(all6$tau, 2) >= 0.96, ], j4[names(all6)])
d6 <- all6
rows <- c(onizuka_lap = "Onizuka (Laplace)", onizuka_hs = "Onizuka (Horseshoe)", pmala = "Bayesian-PMALA",
          admm = "ADMM", joint = "Joint sampler (non-crossing)")
blocks <- c(Beta = "Beta", Mixed = "Mixed normal", Normal = "Gaussian")
cell <- function(d, b, nz, m, t) { v <- d$mean_MSE[d$baseline == b & d$noise == nz & d$method == m & round(d$tau, 2) == t]
  stopifnot(length(v) == 1L); v }
build <- function(d, taus, tag, joint_note) {
  stopifnot(all(d$n_seeds == 100L))
  md <- tex <- character()
  for (b in c("VS", "S")) {
    md <- c(md, sprintf("### %s signal (%s)", b, joint_note), "",
            paste0("| | ", paste(sprintf("%.2f", taus), collapse = " | "), " |"), paste0("|---|", strrep("---:|", length(taus))))
    tex <- c(tex, "\\begin{table}[!htbp]", "\\centering", "\\small",
             sprintf("\\caption{Mean squared error at extreme upper quantiles for the %s signal, $n=500$ and $k=2$. %s}", b, joint_note),
             sprintf("\\label{tab:%s_ext_upper_mse}", tolower(b)), sprintf("\\begin{tabular}{l%s}", strrep("r", length(taus))), "\\toprule")
    for (k in seq_along(blocks)) {
      nz <- names(blocks)[k]
      md <- c(md, paste0("| *", blocks[[k]], "* |", strrep(" |", length(taus))))
      tex <- c(tex, if (k > 1) "\\midrule", paste0(blocks[[k]], " & ", paste(sprintf("$%.2f$", taus), collapse = " & "), " \\\\"), "\\midrule")
      best <- sapply(taus, function(t) names(rows)[which.min(sapply(names(rows), function(m) cell(d, b, nz, m, t)))])
      for (m in names(rows)) {
        v <- sapply(taus, function(t) cell(d, b, nz, m, t)); s <- sprintf("%.4f", v)
        md <- c(md, paste0("| ", rows[[m]], " | ", paste(ifelse(best == m, paste0("**", s, "**"), s), collapse = " | "), " |"))
        tex <- c(tex, paste0(rows[[m]], " & ", paste(s, collapse = " & "), " \\\\"))
      }
    }
    md <- c(md, ""); tex <- c(tex, "\\bottomrule", "\\end{tabular}", "\\end{table}", "")
  }
  writeLines(md, sprintf("tables_4lev_20261023/paper_tables_%s.md", tag))
  writeLines(tex, sprintf("tables_4lev_20261023/paper_tables_%s.tex", tag))
  invisible(tex)
}
build(d4, c(0.96, 0.97, 0.98, 0.99), "4lev", "The joint sampler fits the four levels together; the other methods fit each level separately.")
tex6 <- build(d6, c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99), "6lev", "The joint sampler fits the six levels together; the other methods fit each level separately.")

# Check 1: option-6 table body equals the paper's current tables (numeric rows).
paper <- readLines("../../paper/sections/simulations.tex")
num_rows <- function(x) trimws(grep("^(Onizuka|Bayesian|ADMM|Joint)", trimws(x), value = TRUE))
p <- num_rows(paper[grep("label{tab:vs_ext_upper_mse}", paper, fixed = TRUE):(grep("label{tab:s_ext_upper_mse}", paper, fixed = TRUE) + 30)])
cat("6-level rows vs paper: identical =", identical(p, num_rows(tex6)), "(", length(p), "rows )\n")
# Check 2: option-4 numbers equal the verified comparison CSV.
cmp <- read.csv("tables_4lev_20261023/comparison_4lev_6lev_individual.csv")
cmp$method[cmp$method == "joint4"] <- "joint"; cmp <- cmp[cmp$method != "joint6", ]
x <- merge(cmp[c("baseline", "noise", "tau", "method", "mean_MSE")], d4[c("baseline", "noise", "tau", "method", "mean_MSE")],
           by = c("baseline", "noise", "tau", "method"))
cat("4-level cells vs verified CSV:", nrow(x), "max diff", max(abs(x$mean_MSE.x - x$mean_MSE.y)), "\n")
