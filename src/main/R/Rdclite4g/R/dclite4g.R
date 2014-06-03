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
#' @examples
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSTemplate(osd.url, "application/rdf+xml")
#'
#' @export
GetOSTemplate <- function(opensearch.description, response.type) {
  
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
  
  os.template <- GetOSTemplate(opensearch.description, response.type)
  
  return(strsplit(os.template,"?", fixed=TRUE)[[1]][1])
  
}

#' A function to return the OpenSearch response formats
#'
#' @param opensearch.description URL pointing to the OpenSearch decription document
#' @return the list of OpenSearch response types 
#' @keywords utilities
#' @examples
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
#' @examples
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' GetOSQueryables(osd.url)
#'
#' @export
GetOSQueryables <- function(opensearch.description) {
  
  # use the template from the first reponse format of the OpenSearch description document
  response.type <- GetOSResponseFormats(opensearch.description)[1]
  
  os.template <- GetOSTemplate(osd.url, response.type)
  
  # strip the OpenSearch access point and transform it to a data frame
  access.point <- GetOSAccessPoint(opensearch.description, response.type)
  template <- strsplit(os.template, paste0(access.point, "?"), fixed=TRUE)[[1]][2]

  l <- strsplit(strsplit(template, "&", fixed=TRUE)[[1]], "=", fixed=TRUE)
  df.full.template <- data.frame(matrix(unlist(l), nrow=length(l), byrow=T), stringsAsFactors=FALSE)

  # remove the {, }, ? from the type
  df.template <- as.data.frame(sapply(df.full.template, function(x) {
    x <- str_replace_all(x, "([\\{\\}\\?])", "")
  }))

  # add a third column with NAs, this column can be filled with query values 
  df.template[, 3] <- NA

  # set the column names to type/value, it will be very useful for the Query function params argument 
  colnames(df.template) <- c("param", "type", "value")

  return(df.template)

}

#' A function to query an OpenSearch search engine using the OpenSearch description document URL, 
#' a response type and a data frame with queryables' type and values (NAs are be removed) 
#'
#' @param opensearch.description URL pointing to the OpenSearch decription document
#' @param response.type OpenSearch response type 
#' @return the OpenSearch response
#' @keywords utilities
#' @examples
#' osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
#' df.params <- GetOSQueryables(osd.url)
#' df.params$value[df.params$type == "count"] <- 30 
#' df.params$value[df.params$type == "time:start"] <- "2010-01-10"
#' df.params$value[df.params$type == "time:end"] <- "2010-01-31"
#' res <- Query(osd.url, "application/rdf+xml", df.params)
#' @export
Query <- function(opensearch.description, response.type, df.params) {

  # remove the NAs if any and keep columns type and value
  df.params <-  subset(df.params[complete.cases(df.params),], select=c("type", "value"))

  # avoid factors
  # TODO: is this really needed after all? 
  df.params <- CastCharacter(df.params)

  # get the queryables template, drop the value column 
  # since the value column will come from the df.params when doing the merge 
  df.template <- subset(GetOSQueryables(osd.url), select = c("type", "param"))

  # merge the template and the parameters
  df.query <- subset(merge(df.template, df.params, by.y=c("type")), select = c("param", "value"))
  print(df.query)
  
  # create a named list
  params <- as.list(df.query$value)
  names(params) <- df.query$param
  
  # get the access point and submit the form with curl
  access.point <- GetOSAccessPoint(opensearch.description, response.type)

  return(getForm(access.point, .params=params))

}
