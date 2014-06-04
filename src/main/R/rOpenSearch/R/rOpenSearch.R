#' A function to cast factors to strings in a data frame
#'
#' @param d data frame
#' @return a data frame with columns as character 
#' @keywords utilities
CastCharacter <- function(d) {
  
  return(data.frame(lapply(d, as.character), stringsAsFactors=FALSE))
  
}

#' A function to check if URL is invalid
#'
#' @param URL URL to be tested
#' @return boolean 
#' @keywords utilities
IsURLInvalid <- function(URL) {

  return(inherits(try(url(URL)), "try-error"))
  
}



#' A function to returns the full OpenSearch template made of the 
#  access point and queryables URL template for a given response type
#'
#' @param opensearch.description URL pointing to the OpenSearch decription document
#' @param response.type OpenSearch response type 
#' @return the OpenSearch URL template
#' @keywords utilities
#' @examples \dontrun{
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSTemplate(osd.url, "application/rdf+xml")
#'
#' @export
GetOSTemplate <- function(opensearch.description, response.type) {
  
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
 
  osd.xml <- xmlInternalTreeParse(opensearch.description)
  
  xslt.expression <- paste0("/*[local-name()='OpenSearchDescription']/*[local-name()='Url' and @type='", 
      response.type ,"']/@template")
  
  return(as.character(xpathApply(doc=osd.xml, xslt.expression)))
  
}

#' A function to return the OpenSearch access point
#'
#' @param opensearch.description URL pointing to the OpenSearch decription document
#' @param response.type OpenSearch response type 
#' @return the OpenSearch access point for the provided response type 
#' @keywords utilities
#' @examples
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSAccessPoint(osd.url, "application/rdf+xml")
#'
#' @export
GetOSAccessPoint <- function(opensearch.description, response.type) {
  
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
  
  os.template <- GetOSTemplate(opensearch.description, response.type)
  
  return(strsplit(os.template,"?", fixed=TRUE)[[1]][1])
  
}

#' A function to return the OpenSearch response formats
#'
#' @param opensearch.description URL pointing to the OpenSearch decription document
#' @return the list of OpenSearch response types 
#' @keywords utilities
#' @examples \dontrun{
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSResponseFormats(osd.url)
#'
#' @export
GetOSResponseFormats <- function(opensearch.description) {
 
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
 
  osd.xml <- xmlInternalTreeParse(opensearch.description)
  
  xslt.expression <- "//*[local-name()='Url']/@type" 

  return(as.character(xpathApply(doc=osd.xml, xslt.expression)))

}

#' A function to return the OpenSearch queryables as a data frame 
#'
#' @param opensearch.description URL pointing to the OpenSearch decription document
#' @return a data frame with three columns: param, type, value (NAs) containing the queryables 
#' @keywords utilities
#' @examples \dontrun{
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSQueryables(osd.url, "application/rdf+xml")
#'
#' @export
GetOSQueryables <- function(opensearch.description, response.type) {
  
  if(IsURLInvalid(opensearch.description)) { stop("Invalid OpenSearch description document") }
 
  #os.template <- GetOSTemplate(opensearch.description, response.type)
  
  # strip the OpenSearch access point and transform it to a data frame
  #access.point <- GetOSAccessPoint(opensearch.description, response.type)
  #template <- strsplit(os.template, paste0(access.point, "?"), fixed=TRUE)[[1]][2]

  l <- parse_url(GetOSTemplate(opensearch.description, response.type=response.type))$query
  df.full.template <- do.call(rbind.data.frame,l)

  # get a column with the named list name
  df.full.template$param <- rownames(df.full.template)
  
  # cleanup the rownames
  rownames(df.full.template) <- NULL
  
  # there are invalid templates out there!
  # e.g. ?}&loc={geo:name&}&startdate={time:start?}&
  df.full.template <- df.full.template[!(is.na(df.full.template[,1]) | df.full.template[,1]==""), ]

  # remove the {, }, ? from the type
  df.template <- as.data.frame(sapply(df.full.template, function(x) {
    x <- str_replace_all(x, "([\\{\\}\\?])", "")
  }))

  # add a third column with NAs, this column can be filled with query values 
  df.template[, 3] <- NA

  # set the column names to type/value, it will be very useful for the Query function params argument 
  colnames(df.template) <- c("type", "param", "value")

  return(df.template)

}
