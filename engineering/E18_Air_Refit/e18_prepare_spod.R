# Run from repo root. Rscript --vanilla e18_prepare_spod.R OUTPUT_RDS
# The source timestamps are local clock labels. UTC here preserves those labels.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Usage: e18_prepare_spod.R OUTPUT_RDS")
source("engineering/E18_Air_Refit/e18_common.R")

source_path <- file.path("applications", "Air Quality", "S08_2018-06-15.csv")
sha <- e18_sha(source_path)
stopifnot(sha == "6086e8bdc1260cb90ca9250262aa7fc612a5e6e2d91490b7696f3e44f95cd7c3")
raw <- read.csv(source_path, check.names = FALSE)
t <- as.POSIXct(raw[["TimeStamp"]], format = "%m/%d/%Y %H:%M:%S", tz = "UTC")
midnight <- as.POSIXct("2018-06-15 00:00:00", tz = "UTC")
s <- as.numeric(difftime(t, midnight, units = "secs"))
stopifnot(length(s) == 86213L, all(is.finite(s)), all(s == floor(s)))
day <- s >= 0 & s < 86400
pid <- raw[["d PID (counts)"]][day]
s <- s[day]
stopifnot(length(s) == 86209L, !anyDuplicated(s), all(is.finite(pid)))

n <- 8640L
block <- as.integer(s %/% 10L + 1L)
n_readings <- tabulate(block, nbins = n)
observed <- n_readings > 0L
totals <- rowsum(pid, group = block, reorder = TRUE)
stopifnot(identical(as.integer(rownames(totals)), which(observed)),
  sum(!observed) == 16L, sum(observed & n_readings < 10L) == 6L,
  observed[1L], observed[n])
block_mean <- rep(NA_real_, n)
block_mean[observed] <- totals[, 1L] / n_readings[observed]
block_mean[!observed] <- approx(which(observed), block_mean[observed], xout = which(!observed))$y
center <- mean(block_mean)
scale <- sd(block_mean)
stopifnot(all(is.finite(block_mean)), is.finite(scale), scale > 0)
out <- list(day = "2018-06-15", sensor = "d PID (counts)", source_sha = sha,
  offsets = seq.int(0L, by = 10L, length.out = n), counts = n_readings,
  imputed = !observed, block_mean = block_mean, center = center, scale = scale,
  standardized = (block_mean - center) / scale)
path <- args[1L]
stopifnot(dir.exists(dirname(path)), !file.exists(path))
e18_atomic(out, path)
cat(sprintf("June 15: %d readings; %d partial, %d interpolated, %d total blocks.\n",
  length(s), sum(observed & n_readings < 10L), sum(!observed), n))
cat(sprintf("Four June 16 readings excluded. Center %.12g; sample SD %.12g.\n", center, scale))
cat("Prepared-input SHA-256:", e18_sha(path), "\n")
