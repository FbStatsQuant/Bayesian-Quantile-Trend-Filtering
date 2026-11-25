# Run from the repo root: Rscript --vanilla e15_verify_data.R REPO_ROOT HASH_CSV
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
root <- normalizePath(args[1L], mustWork = TRUE)
e15 <- file.path(root, "engineering", "E15_Extreme_Individual")
source(file.path(e15, "e15_run.R"))
source(file.path(e15, "e15_data.R"))

package_dir <- file.path(root, "experiments", "extreme_quantiles", "packages")
individual <- file.path(package_dir, "Extreme_Individual")
joint <- file.path(package_dir, "Extreme_Joint_Sampler")
file_sha256 <- function(path) digest::digest(file = path, algo = "sha256")
archive <- readLines(file.path(root, "engineering", "E09_NOTS_Cleanup",
                              "quant_reg_archive", "MANIFEST.sha256"))
archive_hash <- function(path) {
  hit <- archive[endsWith(archive, paste0("  ", path))]
  stopifnot(length(hit) == 1L)
  substr(hit, 1L, 64L)
}
stopifnot(file_sha256(file.path(individual, "common_extreme.R")) ==
            "45f3eda22ef9e0f48428667ef84b56b6eb7c96a045fab3ecba8e6674de37ee2e",
          file_sha256(file.path(individual, "worker_pmala.R")) ==
            "68fcd4491130b858ce5cb2086ab25fa3b018fea1c39f5aa542b5c2ca299162f5")

individual_src <- file.path(individual, "source", "Individual_Sampler_PMALA_Augmented.R")
joint_src <- file.path(joint, "source", "Joint", "Joint_Sampler_PMALA_Augmented.R")
# The archived individual sampler was CRLF. The checkout uses LF.
bytes <- readBin(individual_src, "raw", n = file.info(individual_src)$size)
crlf <- charToRaw(gsub("\n", "\r\n", rawToChar(bytes), fixed = TRUE, useBytes = TRUE))
stopifnot(digest::digest(crlf, algo = "sha256", serialize = FALSE) ==
            "15f496a97422209c71723fe7b863f75405f774213fc66a15bf5054f6f48d215f")

verify_metadata <- function() {
  original <- new.env(parent = globalenv())
  sys.source(file.path(individual, "config.R"), envir = original)
  cfg <- original$cfg
  original_runs <- c("extreme_individual_VS_S_10k3k_20261007",
                     "extreme_individual_VS_S_10k3k_tau090_093_20261021")
  temp <- tempfile("e15-legacy-metadata-")
  stopifnot(dir.create(temp))
  on.exit(unlink(temp, recursive = TRUE), add = TRUE)
  for (run in original_runs) {
    prefix <- file.path("Extreme_Individual", "runs", run)
    hashes <- c("common_extreme.R", "worker_pmala.R", "source/Individual_Sampler_PMALA_Augmented.R")
    expected <- vapply(file.path(prefix, "code", "Extreme_Individual", hashes), archive_hash, character(1L))
    actual <- c(file_sha256(file.path(individual, hashes[1L])),
                file_sha256(file.path(individual, hashes[2L])),
                digest::digest(crlf, algo = "sha256", serialize = FALSE))
    stopifnot(identical(unname(expected), actual))

    if (run == original_runs[2L]) cfg$taus <- c(0.90, 0.93)
    dput(cfg, file.path(temp, "config.txt"))
    batches <- original$batch_table(cfg)
    batches$concurrency <- cfg$concurrency
    tables <- list(task_manifest = original$task_grid(cfg), batches = batches)
    for (name in names(tables)) {
      write.table(tables[[name]], file.path(temp, paste0(name, ".tsv")),
                  sep = "\t", quote = FALSE, row.names = FALSE)
    }
    for (name in c("config.txt", "task_manifest.tsv", "batches.tsv")) {
      hash <- file_sha256(file.path(temp, name))
      stopifnot(hash == archive_hash(file.path(prefix, "metadata", name)))
      cat(run, name, hash, "\n")
    }
  }
}
verify_metadata()

generator <- function(path) {
  assignment <- Filter(function(x) {
    is.call(x) && identical(x[[1L]], quote(`<-`)) && identical(x[[2L]], quote(simulate_data))
  }, as.list(parse(path, keep.source = FALSE)))
  stopifnot(length(assignment) == 1L)
  eval(assignment[[1L]][[3L]])
}
hash_vector <- function(x) {
  digest::digest(writeBin(as.double(x), raw(), size = 8L, endian = "little"),
                 algo = "sha256", serialize = FALSE)
}
original_individual <- generator(individual_src)
original_joint <- generator(joint_src)
generate_e15 <- e15_load_data(root)
tasks <- e15_tasks()
groups <- split(seq_len(nrow(tasks)), list(tasks$signal, tasks$noise, tasks$seed))
y_hash <- truth_hash <- character(nrow(tasks))
for (indices in groups) {
  group <- tasks[indices, ]
  joint_data <- original_joint(group$seed[1L], 500L, group$tau, group$signal[1L], group$noise[1L])
  response_hash <- hash_vector(joint_data$y)
  for (j in seq_along(indices)) {
    t <- group[j, ]
    candidate <- generate_e15(t$signal, t$noise, t$seed, t$tau)
    original <- original_individual(t$seed, 500L, t$tau, t$signal, t$noise)
    y_hash[indices[j]] <- hash_vector(candidate$y)
    truth_hash[indices[j]] <- hash_vector(candidate$truth)
    if (y_hash[indices[j]] != response_hash || hash_vector(original$y) != response_hash ||
        truth_hash[indices[j]] != hash_vector(original$truth) ||
        truth_hash[indices[j]] != hash_vector(joint_data$truth[, j])) {
      stop("Hash mismatch for ", t$id)
    }
  }
}
stopifnot(length(groups) == 600L, all(lengths(groups) == 6L))
write.csv(data.frame(tasks[c("id", "signal", "noise", "tau", "seed")],
                     y_sha256 = y_hash, truth_sha256 = truth_hash),
          args[2L], row.names = FALSE)
cat(sprintf("Verified %d response and truth hashes across %d six-level groups\n", nrow(tasks), length(groups)))
cat("Hash CSV SHA-256", file_sha256(args[2L]), "\n")
