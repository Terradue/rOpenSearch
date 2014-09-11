#' A function to return the full OpenSearch template made of the
# access point and queryables URL template for a given response type
#'
#' @param opensearch.description URL pointing to the OpenSearch description document
#' @param response.type OpenSearch response type
#' @return the OpenSearch URL template
#' @keywords utilities
#' @examples \dontrun{
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSTemplate(osd.url, "application/rdf+xml")
#' }
#'
#' @export 
#' @import XML

GetOSTemplate <- function(opensearch.description, response.type) {
  
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
 
  
  
  osd.xml <- xmlInternalTreeParse(getURL(opensearch.description, ssl.verifypeer = FALSE))
  
  xslt.expression <- paste0("/*[local-name()='OpenSearchDescription']/*[local-name()='Url' and @type='",
      response.type ,"']/@template")
  
  return(as.character(xpathApply(doc=osd.xml, xslt.expression)))
  
}
