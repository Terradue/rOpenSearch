#' A function to return the OpenSearch access point
#'
#' @param opensearch.description URL pointing to the OpenSearch description document
#' @param response.type OpenSearch response type
#' @return the OpenSearch access point for the provided response type
#' @keywords utilities
#' @examples \dontrun{
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSAccessPoint(osd.url, "application/rdf+xml")
#' }
#'
#' @export

GetOSAccessPoint <- function(opensearch.description, response.type) {
  
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
  
  os.template <- GetOSTemplate(opensearch.description, response.type)
  
  return(strsplit(os.template,"?", fixed=TRUE)[[1]][1])
  
}
