src <- readLines("engineering/E14_Inner_Rerun/e14_run.R")
eval(parse(text = src[1:grep("^}", src)[1]]))   # e14_tasks
tasks <- e14_tasks()
de <- new.env(); source("engineering/E14_Inner_Rerun/e14_data.R", local = de)
out <- "runs/E14-inner-rerun-20261125/out"
f <- list.files(out, pattern = "\\.rds$", full.names = TRUE)
res <- do.call(rbind, lapply(f, function(p) {
  x <- readRDS(p); t <- tasks[x$index + 1, ]
  d <- de$e14_make_data(as.character(t$signal), as.character(t$noise), t$seed, t$tau)
  data.frame(index = x$index, signal = x$signal, noise = x$noise, host = x$hostname,
             identical = identical(d$truth, x$truth), maxabs = max(abs(d$truth - x$truth)),
             maxrel = max(abs(d$truth - x$truth) / pmax(abs(x$truth), 1e-300)))
}))
write.csv(res, "engineering/E19_Default_Prior/preflight/truth_owls_vs_e14.csv", row.names = FALSE)
print(table(res$identical)); print(aggregate(cbind(identical, maxabs, maxrel) ~ noise + signal, res, function(v) c(mean = mean(v), max = max(v))))
res$hostfam <- sub("[0-9].*", "", res$host); print(table(res$hostfam, res$identical))
