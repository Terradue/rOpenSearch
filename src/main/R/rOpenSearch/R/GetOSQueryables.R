#' A function to return the OpenSearch queryables as a data frame
#'
#' @param opensearch.description URL pointing to the OpenSearch description document
#' @return a data frame with three columns: param, type, value (NAs) containing the queryables
#' @keywords utilities
#' @examples \dontrun{
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSQueryables(osd.url, "application/rdf+xml")
#' }
#'
#' @export
#' @import httr
#' @import stringr

GetOSQueryables <- function(opensearch.description, response.type) {
  
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
 
  # get the templare
  l <- parse_url(GetOSTemplate(opensearch.description, response.type=response.type))$query
  df.full.template <- do.call(rbind.data.frame,l)

  # get a column with the named list name
  df.full.template$param <- rownames(df.full.template)
  
  # cleanup the rownames
  rownames(df.full.template) <- NULL
  
  # there are invalid templates out there!
  # e.g. ?}&loc={geo:name&}&startdate={time:start?}&
  df.full.template <- df.full.template[!(is.na(df.full.template[,1]) | df.full.template[,1]==""), ]

  value <- df.full.template[ ,1]

  # remove the {, }, ? from the type
  df.template <- as.data.frame(sapply(df.full.template, function(x) {
    x <- str_replace_all(x, "([\\{\\}\\?])", "")
  }))

  df.template[, 3] <-  as.data.frame(t(t(sapply(value, function(x) {
    x <- str_replace_all(x, "([\\{\\}\\?])", NA)
  }))))

  # set the column names to type/value, it will be very useful for the Query function params argument
  colnames(df.template) <- c("type", "param", "value")

  return(df.template)

}

