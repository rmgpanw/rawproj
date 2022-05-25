library(targets)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.
library(tarchetypes)
# needed for rendering .Rmd documents

# # Define custom functions and other global objects.
# # This is where you write source(\"R/functions.R\")
# # if you keep your functions in external scripts.
# summ <- function(dataset) {
#   summarize(dataset, mean_x = mean(x))
# }

# # Set target-specific options such as packages.
# tar_option_set(packages = "dplyr")

# End this file with a list of target objects.

list(

  # FILE PATHS ---------------------------------------------------------

  tar_target(
    RENVIRON,
    ".Renviron",
    format = "file"
  ),


  # INTERIM OBJECTS ---------------------------------------------------------

  # tar_target(
  #   processed_data,
  #   {
  #     read.csv(INTPUT_DATA_CSV)
  #   }
  # ),

  # RMARKDOWN DOCS ----------------------------------------------------------

  ## workflowr notebooks -----------------------------------------------------
  tar_target(INDEX_RMD,
             command = {
               !!tar_knitr_deps_expr(file.path("analysis", "index.Rmd"))
               suppressMessages(workflowr::wflow_build(file.path("analysis", "index.Rmd"), verbose = FALSE))
               c(file.path("analysis", "index.Rmd"),
                 file.path("public", "index.html"))
             },
             format = "file"),

  tar_target(ABOUT_RMD,
             command = {
               !!tar_knitr_deps_expr(file.path("analysis", "about.Rmd"))
               suppressMessages(workflowr::wflow_build(file.path("analysis", "about.Rmd"), verbose = FALSE))
               c(file.path("analysis", "about.Rmd"),
                 file.path("public", "about.html"))
             },
             format = "file"),

  tar_target(LICENSE_RMD,
             command = {
               !!tar_knitr_deps_expr(file.path("analysis", "license.Rmd"))
               suppressMessages(workflowr::wflow_build(file.path("analysis", "license.Rmd"), verbose = FALSE))
               c(file.path("analysis", "license.Rmd"),
                 file.path("public", "license.html"))
             },
             format = "file")
)
