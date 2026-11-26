# Median/5th-pct ESS of log sigma and log lambda over the 666 thinned retained draws (run from runs/: Rscript <this> <run dirs...>).
# sigma's full conditional depends on theta only through the in-sample check loss, so sigma ESS proxies that curve summary. theta draws were not saved.
suppressMessages(library(coda))
r <- do.call(rbind, lapply(commandArgs(TRUE), function(d) { f <- list.files(file.path(d, "out"), pattern = "\\.rds$", full.names = TRUE)
  do.call(rbind, lapply(f, function(p) { x <- readRDS(p); k <- x$trace_sweep > x$burn
    data.frame(run = d, signal = x$signal, noise = x$noise, tau = x$tau, sess = as.numeric(effectiveSize(log(x$sigma[k]))),
               less = as.numeric(effectiveSize(log(x$lambda[k])))) })) }))
a <- aggregate(cbind(sess, less) ~ run + signal + noise + tau, r, median)
a <- a[order(a$sess), ]; print(head(a, 12), row.names = FALSE)
print(aggregate(cbind(sess, less) ~ run + signal, r, function(v) c(med = median(v), p05 = unname(quantile(v, .05)))))
