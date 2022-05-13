#' Read .Renviron file to list
#'
#' Reads environmental variables defined by a `.Renviron` file to a named list.
#'
#' @param path Path to directory containing a `.Renviron` file.
#' @param suffix Optional suffix to append to names of objects extracted from
#'   `.Renviron`.
#'
#' @return A named list.
#' @export
#'
#' @examples
#' # create `.Renviron` in `tempdir()` and read to current R session
#' temp_dotrenviron <- file.path(tempdir(), ".Renviron")
#' cat("KEY=value", file = temp_dotrenviron)
#' readRenviron(temp_dotrenviron)
#'
#' # get environmental variables specified by `.Renviron` to a named list
#' renviron_to_list(path = tempdir())
renviron_to_list <- function(path,
                             suffix = "_RENV") {
  file_path <- file.path(path, ".Renviron")

  stopifnot(file.exists(file_path))

  result <- file_path %>%
    readr::read_lines() %>%
    purrr::keep( ~ stringr::str_detect(.x, "=") &
                   stringr::str_detect(.x, "#", negate = TRUE)) %>%
    stringr::str_remove("=.*$") %>%
    purrr::set_names() %>%
    purrr::map( ~ Sys.getenv(.x))

  if (!is.null(suffix)) {
    names(result) <- paste0(names(result), suffix)
  }

  result
}
