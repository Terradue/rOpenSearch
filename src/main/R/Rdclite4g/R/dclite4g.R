CastCharacter <- function(d) {
  
  # this function casts factors to strings, useful 
  # when you don't know what comes in  
  
  return(data.frame(lapply(d, as.character), stringsAsFactors=FALSE))
  
}

GetOSTemplate <- function(opensearch.description, response.type) {
  
  # this function returns the full OpenSearch template made of the 
  # acces point and queryables template for a given response type
  
  osd.xml <- xmlInternalTreeParse(opensearch.description)
  
  xslt.expression <- paste0("/*[local-name()='OpenSearchDescription']/*[local-name()='Url' and @type='", 
      response.type ,"']/@template")
  
  return(as.character(xpathApply(doc=osd.xml, xslt.expression)))
  
}

GetOSAccessPoint <- function(opensearch.description, response.type) {
  
  # this function returns the OpenSearch access point  
  # for a given response type (e.g. application/rdf+xml)
  # this function basically removes from full the OpenSearch template everything after '?' 
  # this function is useful for the curl GET request
  
  os.template <- GetOSTemplate(opensearch.description, response.type)
  
  return(strsplit(os.template,"?", fixed=TRUE)[[1]][1])
  
}

GetOSResponseFormats <- function(opensearch.description) {
  
  # this function lists the response formats exposed in the OpenSearch description document
  
  osd.xml <- xmlInternalTreeParse(opensearch.description)
  
  xslt.expression <- "//*[local-name()='Url']/@type" 

  return(as.character(xpathApply(doc=osd.xml, xslt.expression)))

}

GetOSQueriables <- function(opensearch.description) {
  
  # this function returns the OpenSearch description document queriables as a data frame
  # the data.frame can later be filled and used as input in the Query function
  
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


Query <- function(opensearch.description, response.type, df.params) {

  # avoid factors
  # TODO: is this really needed after all? 
  df.params <- CastCharacter(df.params)

  # get the queryables template, drop the value column 
  # since the value column will come from the df.params when doing the merge 
  df.template <- subset(GetOSQueriables(osd.url), select = c("type", "param"))

  # merge the template and the parameters
  df.query <- subset(merge(df.template, df.params, by.y=c("type")), select = c("param", "value"))
  
  # create a named list
  params <- as.list(df.query$value)
  names(params) <- df.query$param
  
  # get the access point and submit the form with curl
  access.point <- GetOSAccessPoint(opensearch.description, response.type)
  response <- xmlParse(getForm(access.point, .params=params))

  # TODO: what happens if the response type is not "application/rdf+xml"
  description <- xmlToDataFrame(nodes = getNodeSet(response, 
    "//rdf:Description"), stringsAsFactors = FALSE)
  
  series <- xmlToDataFrame(nodes = getNodeSet(response,
    "//dclite4g:Series"), stringsAsFactors = FALSE)
  
  dataset <- xmlToDataFrame(nodes = getNodeSet(response, 
    "//dclite4g:DataSet"), stringsAsFactors = FALSE)
  
  res <- list(description, series, dataset)
  names(res) <- c("description", "series", "dataset")
  return(res)

}
