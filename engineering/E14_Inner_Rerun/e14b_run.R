# S-only E-14 rerun at the common lambda prior rate.
e14b_tasks <- function() {
  grid <- e14_tasks()
  tasks <- grid[grid$signal == "S", ]
  tasks$index <- seq_len(nrow(tasks)) - 1L
  tasks
}

e14b_fit <- function(task, code, smoke) {
  # In E-14, S begins at zero-based index 1500.
  e14_fit(task, code, smoke, b0 = 1e-3, chain_seed = 11501L + task$index,
          save_posterior_means = TRUE)
}

if (sys.nframe() == 0L) {
  script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(dirname(script), "e14_run.R"))
  quit(status = e14_main(commandArgs(TRUE), e14b_tasks(), e14b_fit))
}
