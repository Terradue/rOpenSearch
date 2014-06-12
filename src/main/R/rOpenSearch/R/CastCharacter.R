#' A function to cast factors to strings in a data frame
#'
#' @param d data frame
#' @return a data frame with columns as character
#' @keywords utilities

CastCharacter <- function(d) {
  
  return(data.frame(lapply(d, as.character), stringsAsFactors=FALSE))
  
}

