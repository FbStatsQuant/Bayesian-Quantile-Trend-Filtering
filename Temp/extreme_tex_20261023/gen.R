# Rebuild the two extreme-quantile MSE tables of sections/simulations.tex with all six levels (Oct 7 runs).
d <- read.csv("C:/Users/felip/OneDrive/Documents/Quantile Regression/Simulations/Extreme/tables_20261023/mse_consolidated_oct7.csv")
meth <- c("Onizuka Laplace", "Onizuka HS", "Indiv. PMALA", "ADMM (eBIC)", "Joint PMALA")
lab  <- c("Onizuka (Laplace)", "Onizuka (Horseshoe)", "Bayesian-PMALA", "ADMM", "Joint sampler (non-crossing)")
nzs <- c(Beta = "Beta", Mixed = "Mixed normal", Normal = "Gaussian")
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)
bs <- "\\"; nl <- paste0(" ", bs, bs)
blk <- function(b, cap, lbl) {
  hdr <- paste(sprintf("$%.2f$", taus), collapse = " & ")
  out <- c(paste0(bs, "begin{table}[!htbp]"), paste0(bs, "centering"), paste0(bs, "small"),
           paste0(bs, "caption{", cap, "}"), paste0(bs, "label{", lbl, "}"),
           paste0(bs, "begin{tabular}{lrrrrrr}"), paste0(bs, "toprule"))
  for (k in seq_along(nzs)) {
    if (k > 1) out <- c(out, paste0(bs, "midrule"))
    out <- c(out, paste0(nzs[[k]], " & ", hdr, nl), paste0(bs, "midrule"))
    for (i in seq_along(meth)) {
      v <- sapply(taus, function(t) d$mean_MSE[d$baseline == b & d$noise == names(nzs)[k] &
                                               d$method == meth[i] & abs(d$tau - t) < 1e-9])
      stopifnot(is.numeric(v), length(v) == 6)
      out <- c(out, paste0(lab[i], " & ", paste(sprintf("%.4f", v), collapse = " & "), nl))
    }
  }
  c(out, paste0(bs, "bottomrule"), paste0(bs, "end{tabular}"), paste0(bs, "end{table}"))
}
f <- "sections/simulations.tex"; x <- readLines(f, encoding = "UTF-8")
sec <- grep("label{sec:sim:extreme}", x, fixed = TRUE)
s <- grep(paste0(bs, "begin{table}"), x, fixed = TRUE); s <- s[s > sec]
e <- grep(paste0(bs, "end{table}"), x, fixed = TRUE); e <- e[e > s[1]]
stopifnot(length(sec) == 1, length(s) == 2, length(e) == 2)
cv <- paste("Mean squared error at extreme upper quantiles for the %s signal, $n=500$ and $k=2$.",
            "The joint sampler fits the six levels together; the other methods fit each level separately.")
new <- c(x[1:(s[1] - 1)], blk("VS", sprintf(cv, "VS"), "tab:vs_ext_upper_mse"), "",
         blk("S", sprintf(cv, "S"), "tab:s_ext_upper_mse"))
if (e[2] < length(x)) new <- c(new, x[(e[2] + 1):length(x)])
writeLines(new, f, useBytes = TRUE)
cat("OK", length(x), "->", length(new), "lines\n")
