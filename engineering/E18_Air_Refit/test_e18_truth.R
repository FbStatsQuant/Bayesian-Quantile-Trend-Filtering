# Run from repo root with Rscript --vanilla.
source("engineering/E18_Air_Refit/e18_common.R")
offsets <- e18_table2_offsets(".")
stopifnot(identical(sprintf("%a", offsets),
  c("-0x1.29c5c4630ff0ep-1", "-0x1.a515209676abbp-2", "-0x1.4813c36e26d33p-2")))
archive <- e18_table2_archive(".")
baseline <- archive$data[[1L]]$theta
audit <- read.csv("engineering/E18_Air_Refit/table2_data_sha256.csv")
stopifnot(identical(e18_vector_sha(baseline), audit$baseline_sha256[1L]))

for (j in seq_along(e18_taus)) {
  offset <- offsets[j]
  q <- 4 * offset
  ulp <- .Machine$double.eps * 2^floor(log2(abs(q)))
  alternate <- q + ulp
  col <- sprintf("q%02d_sha256", round(100 * e18_taus[j]))
  truth <- baseline + e18_checked_offset(offset, q)
  stopifnot(!identical(baseline + .25 * alternate, truth, num.eq = FALSE),
    identical(baseline + e18_checked_offset(offset, alternate), truth, num.eq = FALSE),
    identical(baseline + e18_checked_offset(offset, qnorm(e18_taus[j])), truth, num.eq = FALSE),
    identical(e18_vector_sha(truth), audit[[col]][1L]),
    inherits(try(e18_checked_offset(offset, q + 1024 * ulp), silent = TRUE), "try-error"))
}
cat("E-18 sealed truth and one-ULP portability tests passed.\n")
