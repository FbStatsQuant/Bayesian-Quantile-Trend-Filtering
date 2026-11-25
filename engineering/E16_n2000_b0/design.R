taus <- c(0.3, 0.5, 0.7, 0.9)
b0_values <- c(1e-5, 1e-3)
n_observations <- 2000L
full_iter <- 30000L
full_burn <- 10000L
warm_iter <- 200L
sampler_revision <- "63f2a56"

make_tasks <- function() {
  cells <- expand.grid(
    baseline = c("VS", "S", "PC"), data_seed = 1:5, b0 = b0_values,
    stringsAsFactors = FALSE
  )
  joint <- merge(cells, data.frame(chain = c(1001L, 1002L)))
  joint$kind <- "joint"
  joint$tau <- NA_real_
  individual <- merge(cells, data.frame(tau = taus))
  individual$chain <- 1001L
  individual$kind <- "ind"
  tasks <- rbind(joint, individual)
  cell_id <- sprintf("%s_s%d_b%.0e", tasks$baseline, tasks$data_seed, tasks$b0)
  tasks$id <- ifelse(
    tasks$kind == "joint", sprintf("joint_%s_c%d", cell_id, tasks$chain),
    sprintf("ind_%s_t%02d", cell_id, round(100 * tasks$tau))
  )
  tasks
}

script_directory <- function() {
  arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  dirname(normalizePath(sub("^--file=", "", arg[[1L]]), mustWork = TRUE))
}

run_directory <- function() {
  normalizePath(Sys.getenv("E16_RUN_DIR", unset = NA_character_), mustWork = TRUE)
}
