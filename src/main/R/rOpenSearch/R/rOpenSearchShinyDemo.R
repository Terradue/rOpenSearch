#' Runs a rOpenSearch demo as a Shiny app.
#'
#' This will start a Shiny server to interact with the different options available
#' in the \code{\link{Query}} function.
#'
#' @export
#' @import shiny

rOpenSearchShinyDemo <- function() {
  
  message('Hit <escape> to stop')

  require(shiny)

  shiny::runApp(system.file('shiny', package='rOpenSearch'))

}
