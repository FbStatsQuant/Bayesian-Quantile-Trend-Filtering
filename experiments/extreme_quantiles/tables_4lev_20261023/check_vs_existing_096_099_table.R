new <- read.csv("Simulations/Extreme/tables_4lev_20261023/comparison_4lev_6lev_individual.csv"); new$tau <- round(new$tau, 2)
map <- c("Onizuka (Laplace)"="onizuka_lap","Onizuka (Horseshoe)"="onizuka_hs","Bayesian-PMALA"="pmala","ADMM"="admm","Joint sampler (non-crossing)"="joint6")
old <- do.call(rbind, lapply(c("VS","S"), function(b) {x <- read.csv(sprintf("Simulations/Extreme/tables_20261008/mse_%s.csv", b), check.names=FALSE)
  do.call(rbind, lapply(c("0.96","0.97","0.98","0.99"), function(t) data.frame(baseline=x$baseline, noise=x$noise, method=map[x$method], tau=as.numeric(t), old=x[[t]])))}))
m <- merge(old, new[c("baseline","noise","tau","method","mean_MSE")]); cat("csv rows", nrow(m), "max diff", max(abs(m$old-m$mean_MSE)), "\n")
tex <- readLines("PMALA version Tex Project/sections/simulations.tex")
s <- c(grep("label{tab:vs_ext_upper_mse}", tex, fixed=TRUE)[1], grep("label{tab:s_ext_upper_mse}", tex, fixed=TRUE)[1])
nz <- c("Beta"="Beta","Mixed normal"="Mixed","Gaussian"="Normal"); bad <- 0; n <- 0
for (k in seq_along(s)) { b <- c("VS","S")[k]; cur <- NA
  for (l in tex[s[k]:(s[k]+32)]) { f <- trimws(strsplit(strsplit(l, "\\", fixed=TRUE)[[1]][1], "&", fixed=TRUE)[[1]])
    if (length(f) == 0) next
    if (f[1] %in% names(nz)) cur <- nz[[f[1]]] else if (f[1] %in% names(map) && length(f)==7) for (j in 1:4) {
      v <- new$mean_MSE[new$baseline==b & new$noise==cur & new$method==map[[f[1]]] & new$tau==c(.96,.97,.98,.99)[j]]
      n <- n+1; if (sprintf("%.4f", v) != f[j+3]) {bad <- bad+1; cat("MISMATCH", b, cur, f[1], j, f[j+3], v, "\n")}}}}
cat("paper cells", n, "mismatches", bad, "\n")
for (wj in c(FALSE, TRUE)) { d <- new[new$method != "joint4" | wj, ]
  w <- do.call(rbind, lapply(split(d, d[c("baseline","noise","tau")], drop=TRUE), function(z) z[which.min(z$mean_MSE), c("baseline","noise","tau","method")]))
  cat(if (wj) "WITH joint4\n" else "EXISTING (no joint4)\n"); print(xtabs(~method+baseline, w)) }
j <- reshape(new[new$method %in% c("joint4","joint6"), c("baseline","noise","tau","method","mean_MSE")], idvar=c("baseline","noise","tau"), timevar="method", direction="wide")
r <- function(meth) sapply(seq_len(nrow(j)), function(i) { z <- new[new$baseline==j$baseline[i] & new$noise==j$noise[i] & new$tau==j$tau[i] & new$method %in% c(meth,"onizuka_lap","onizuka_hs","pmala","admm"),]; rank(z$mean_MSE)[z$method==meth]})
j$rank6 <- r("joint6"); j$rank4 <- r("joint4"); j$pct <- round(100*(j$mean_MSE.joint4/j$mean_MSE.joint6-1),1)
j <- j[order(match(j$baseline,c("VS","S")), match(j$noise,c("Beta","Mixed","Normal")), j$tau),]; print(j, row.names=FALSE, digits=4)
