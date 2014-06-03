#' Runs a Rdclite4g demo as a Shiny app.
#'
#' This will start a Shiny server to interact with the different options available
#' in the \code{\link{Query}} function.
#'
#' @export
dclite4gShinyDemo <- function() {
message('Hit <escape> to stop')
require(shiny)
shiny::runApp(system.file('shiny', package='Rdclite4g'))
}
