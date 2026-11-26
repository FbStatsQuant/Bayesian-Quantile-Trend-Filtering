e17_write_headlines <- function(path, cmp14, cmp15, cross14, cross15, health, low) {
  noise_names <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "mixed normal")
  extremes <- function(tau, design) {
    ifelse(design == "extreme" & tau == .99, "**0.99**", sprintf("%.2f", tau))
  }
  noise_list <- function(x) if (length(x)) paste(unname(noise_names[x]), collapse = ", ") else "—"
  ranking <- function(d, design) {
    d <- d[tolower(d$metric) == "mse", ]
    d <- d[order(match(d$signal, c("VS", "S")), d$tau, match(d$noise, names(noise_names))), ]
    groups <- unique(d[c("signal", "tau")])
    vapply(seq_len(nrow(groups)), function(i) {
      g <- groups[i, ]
      z <- d[d$signal == g$signal & d$tau == g$tau, ]
      sprintf("| %s | %s | %s | %s | %s |", design, g$signal, extremes(g$tau, design),
        noise_list(z$noise[z$b0_1e5 < pmin(z$published, z$b0_1e3)]),
        noise_list(z$noise[z$b0_1e5 > pmax(z$published, z$b0_1e3)]))
    }, character(1L))
  }
  ess <- lapply(c("VS", "S"), function(signal) {
    h <- health[health$design == "extreme" & health$signal == signal, ]
    vapply(list(h, subset(h, tau == .99)), function(d) {
      a <- median(d$lambda_ess[d$b0 == 1e-3])
      b <- median(d$lambda_ess[d$b0 == e17_rate])
      sprintf("| %s | %s | %.2f | %.2f | %+.1f%% |", signal,
        if (all(d$tau == .99)) "**0.99**" else "All", a, b, 100 * (b / a - 1))
    }, character(1L))
  })
  crossings <- function(d, design) {
    vapply(c("VS", "S"), function(signal) {
      z <- d[d$signal == signal, ]
      totals <- 100 * rbind(
        colSums(z[z$metric == "cross_nb", c("b0_1e3", "b0_1e5")]),
        colSums(z[z$metric == "cross_all", c("b0_1e3", "b0_1e5")])) / 2
      sprintf("| %s | %s | %.0f | %.0f | %.0f | %.0f |", design, signal,
        totals[1L, 1L], totals[1L, 2L], totals[2L, 1L], totals[2L, 2L])
    }, character(1L))
  }
  writeLines(c("# E-17 results for HQ", "",
    "## MSE versus both baselines", "",
    "The comparisons use the printed published mean and unrounded rerun means. A dash means no noise family meets the strict comparison.", "",
    "| Design | Signal | τ | Lower than both | Higher than both |",
    "| --- | --- | ---: | --- | --- |", ranking(cmp14, "interior"), ranking(cmp15, "extreme"), "",
    "## Extreme λ ESS", "",
    "| Signal | τ | Median at 1e-3 | Median at 1e-5 | Change |",
    "| --- | --- | ---: | ---: | ---: |", unlist(ess), "",
    "## Crossing totals", "",
    "Counts sum pointwise inversions over 300 noise/seed groups per signal, counting each level pair once. The interior uses all five reported levels. The extreme uses 0.96–0.99.", "",
    "| Design | Signal | Neighbor at 1e-3 | Neighbor at 1e-5 | All pairs at 1e-3 | All pairs at 1e-5 |",
    "| --- | --- | ---: | ---: | ---: | ---: |", crossings(cross14, "interior"),
    crossings(cross15, "extreme"), "", "## Health flags", "",
    sprintf("- %s `%s`, post-burn-in acceptance %.5f, λ ESS %.2f.",
      low$design, low$id, low$acc_post, low$lambda_ess)), path)
}
