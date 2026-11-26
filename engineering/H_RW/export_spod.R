# Convert the verified E-18 RDS into the public, round-trip-safe CSV.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
x <- readRDS(args[1L])
stopifnot(length(x$offsets) == 8640L, sum(x$imputed) == 19L)
tab <- data.frame(
  offset_seconds = x$offsets, n_readings = x$counts,
  imputed = as.integer(x$imputed),
  pid_block_mean_counts = sprintf("%.17g", x$block_mean),
  pid_standardized = sprintf("%.17g", x$standardized)
)
write.table(tab, args[2L], sep = ",", row.names = FALSE, quote = FALSE, eol = "\n")
got <- read.csv(args[2L])
stopifnot(identical(got$offset_seconds, x$offsets),
          identical(got$n_readings, x$counts),
          identical(as.logical(got$imputed), x$imputed),
          identical(got$pid_block_mean_counts, x$block_mean),
          identical(got$pid_standardized, x$standardized))
