#' A function to return the OpenSearch response formats
#'
#' @param opensearch.description URL pointing to the OpenSearch description document
#' @return the list of OpenSearch response types
#' @keywords utilities
#' @examples \dontrun{
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSResponseFormats(osd.url)
#' }
#' 
#' @export

GetOSResponseFormats <- function(opensearch.description) {
 
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
 
  osd.xml <- xmlInternalTreeParse(opensearch.description)
  
  xslt.expression <- "//*[local-name()='Url']/@type"

  return(as.character(xpathApply(doc=osd.xml, xslt.expression)))

}
