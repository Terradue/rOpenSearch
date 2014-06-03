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
  
  res <- as.character(xpathApply(doc=osd.xml, xslt.expression))
  
  return(res)
  
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
  
  return(c("application/rdf+xml"))

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

  df.template[, 3] <- NA

  # set the column names to type/value, it will be very useful for the Query function params argument 
  colnames(df.template) <- c("param", "type", "value")

  return(df.template)

}


Query <- function(opensearch.description, df.params) {

  # get the queryables template, strip the value ([,2]) column 
  df.template <- subset(GetOSQueriables(osd.url), select = c("type", "param"))
print("#1")
print(df.template)
  # use the RDF response type 
  response.type <- "application/rdf+xml"
  
  # get the OpenSearch template
  #os.template <- GetOSTemplate(opensearch.description, response.type)
  
  
  access.point <- GetOSAccessPoint(opensearch.description, response.type)
  
  # get the QueryString template
  #template <- strsplit(os.template, paste0(access.point, "?"), fixed=TRUE)[[1]][2]

  # create a data.frame of with the template
  #l <- strsplit(strsplit(template, "&", fixed=TRUE)[[1]], "=", fixed=TRUE)
  #df.template <- data.frame(matrix(unlist(l), nrow=length(l), byrow=T), stringsAsFactors=FALSE)

  # set the column names
  #colnames(df.template) <- c("param", "type")
 
  # from Factor to Character
  ##df.template <- CastCharacter(df.template)
  
  # remove the {, }, ? from the type
  #df.template <- as.data.frame(sapply(df.template, function(x) {
  #        x <- str_replace_all(x, "([\\{\\}\\?])", "")
  #      }))
  
  df.params <- CastCharacter(df.params)
print("#2")
  print(df.params)
  
  # merge the template and the parameters
  df.query <- subset(merge(df.template, df.params, by.y=c("type")), select = c("param", "value")) #, all.y=TRUE) #[,2-3]

print("#3")  
  print(df.query)
  return(df.query)
  
  # from Factor to Character
  ##CastCharacter(df.query)
  
  # create a named list
  params <- as.list(df.query$value)
  names(params) <- df.query$param
  
  # submit the form
  response <- xmlParse(getForm(access.point, .params=params))
  
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
