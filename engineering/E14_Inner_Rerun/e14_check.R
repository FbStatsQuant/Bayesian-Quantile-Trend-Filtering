# Rscript e14_check.R RUN_DIR [THROTTLE]
args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% c(1L, 2L)) stop("Usage: Rscript e14_check.R RUN_DIR [THROTTLE]")
if (length(args) == 2L && !grepl("^[1-9][0-9]*$", args[2L]))
  stop("THROTTLE must be a positive integer")

script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
source(file.path(dirname(script), "e14_run.R"))
run <- normalizePath(args[1L], mustWork = TRUE)
out <- file.path(run, "out")
tasks <- e14_tasks()
missing <- tasks[!file.exists(file.path(out, paste0(tasks$id, ".rds"))), ]
failures <- list.files(out, pattern = "\\.fail\\.rds$")

cat(sprintf("Complete: %d / %d\n", nrow(tasks) - nrow(missing), nrow(tasks)))
cat(sprintf("Missing IDs: %d\n", nrow(missing)))
if (nrow(missing)) write.table(missing[c("index", "id")], row.names = FALSE, quote = FALSE)
cat(sprintf("Failure files: %d\n", length(failures)))
if (length(failures)) writeLines(failures)

if (nrow(missing)) {
  indices <- missing$index
  starts <- indices[c(TRUE, diff(indices) != 1L)]
  ends <- indices[c(diff(indices) != 1L, TRUE)]
  ranges <- ifelse(starts == ends, starts, paste(starts, ends, sep = "-"))
  array <- paste(ranges, collapse = ",")
  if (length(args) == 2L) array <- paste0(array, "%", args[2L])
  cat("Resubmit missing tasks:\n")
  cat(sprintf("sbatch --array=%s --export=%s --output=%s %s\n",
              shQuote(array), shQuote(paste0("ALL,RUN=", run)),
              shQuote(file.path(run, "logs", "%x_%A_%a.out")),
              shQuote(file.path(run, "code", "engineering", "E14_Inner_Rerun", "e14.slurm"))))
}

quit(status = as.integer(nrow(missing) > 0L || length(failures) > 0L))
