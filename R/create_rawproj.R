#' Create a new project based on workflowr and targets
#'
#' Builds on the workflowr and targets packages. Also includes R package
#' infrastructure.
#'
#' @inheritParams workflowr::wflow_start
#' @inheritParams usethis::create_package
#'
#' @return Called for side effects.
#' @export
#'
#' @examples
#' \dontrun{
#'  create_rawproj(tempdir())
#' }
create_rawproj <- function(directory,
                           user.name,
                           user.email,
                           name = NULL,
                           git = TRUE,
                           existing = FALSE,
                           overwrite = FALSE,
                           change_wd = TRUE,
                           disable_remote = FALSE,
                           dry_run = FALSE,
                           fields = list(),
                           rstudio = rstudioapi::isAvailable(),
                           roxygen = TRUE,
                           check_name = TRUE,
                           open = FALSE) {

  # set working directory to current one on exit
  current_workdir <- getwd()
  on.exit(setwd(current_workdir))

  # create workflowr project
  workflowr::wflow_start(directory,
                         name = name,
                         git = git,
                         existing = existing,
                         overwrite = overwrite,
                         change_wd = change_wd,
                         disable_remote = disable_remote,
                         dry_run = dry_run,
                         user.name = user.name,
                         user.email = user.email)

  # use gitlab
  workflowr::wflow_use_gitlab(username = user.name,
                              project = directory)

  # adapt workflowr setup - remove unused directories
  c("data",
    "code") %>%
    purrr::walk( ~ unlink(file.path(directory, .x),
                          recursive = TRUE))

  # add R package infrastructure
  usethis::create_package(path = directory,
                          fields = fields,
                          rstudio = rstudio,
                          roxygen = roxygen,
                          check_name = check_name,
                          open = open)

  # copy template files to root dir
  c("_targets.R",
    "_pkg_dependencies.R",
    ".Renviron",
    ".gitlab-ci.yml") %>%
    purrr::walk( ~ file.copy(
      fs::path_package(package = "rawproj", "templates", .x),
      file.path(directory, .x)
    ))

  # copy template files to analysis dir
  c("about.Rmd") %>%
    purrr::walk( ~ file.copy(
      fs::path_package(package = "rawproj", "templates", .x),
      file.path(directory, "analysis", .x),
      overwrite = TRUE
    ))

  # use test_that
  usethis::use_testthat()

  # use pkgdown
  usethis::use_pkgdown(config_file = "_pkgdown.yml",
                       destdir = file.path("public", "pkgdown_site"))

  # add to .gitignore
  usethis::use_git_ignore(c("output/*"))

  # add to .Rbuildignore
  usethis::use_build_ignore(files  = c("_targets.R",
                                       "_pkg_dependencies.R",
                                       "_targets/*",
                                       "_workflowr.yml",
                                       "analysis/*",
                                       "docs/*",
                                       "public/*",
                                       "output/*"),
                            escape = TRUE)

  # activate renv
  renv::init(restart = FALSE)
}


# PRIVATE -----------------------------------------------------------------

## Wrapper function to enhance RStudio Project Template

create_rawproj_rstudio <- function(directory,
                                name = "",
                                git = TRUE,
                                existing = FALSE,
                                overwrite = FALSE,
                                user.name = "",
                                user.email = "") {

  directory_rs <- directory

  # Check if name is blank, use NULL if true
  if (name == "") {
    name_rs <- NULL
  } else {
    name_rs <- name
  }

  git_rs <- git

  existing_rs <- existing

  overwrite_rs <- overwrite

  # Check if user.name is blank, use NULL if true
  if (user.name == "") {
    user.name_rs <- NULL
    workflowr:::check_git_config(directory, custom_message = "the RStudio Project Template")
  } else {
    user.name_rs <- user.name
  }

  # Check if user.email is blank, use NULL if true
  if (user.email == "") {
    user.email_rs <- NULL
    workflowr:::check_git_config(directory, custom_message = "the RStudio Project Template")
  } else {
    user.email_rs <- user.email
  }

  create_rawproj(directory = directory_rs,
              name = name_rs,
              git = git_rs,
              existing = existing_rs,
              overwrite = overwrite_rs,
              user.name = user.name_rs,
              user.email = user.email_rs)
}
