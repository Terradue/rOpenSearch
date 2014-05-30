CastCharacter <- function(d) {
  
  return(data.frame(lapply(d, as.character), stringsAsFactors=FALSE))
  
}

GetOSTemplate <- function(opensearch.description, response.type) {
  
  osd.xml <- xmlInternalTreeParse(opensearch.description)
  
  xslt.expression <- paste0("/*[local-name()='OpenSearchDescription']/*[local-name()='Url' and @type='", 
      response.type ,"']/@template")
  
  res <- as.character(xpathApply(doc=osd.xml, xslt.expression))
  
  return(res)
  
}

GetOSAccessPoint <- function(opensearch.description, response.type) {
  
  os.template <- GetOSTemplate(opensearch.description, response.type)
  
  return(strsplit(os.template,"?", fixed=TRUE)[[1]][1])
  
}

Query <- function(opensearch.description, df.params) {
  
  # use the RDF response type 
  response.type <- "application/rdf+xml"
  
  # get the OpenSearch template
  os.template <- GetOSTemplate(opensearch.description, response.type)
  
  
  access.point <- GetOSAccessPoint(opensearch.description, response.type)
  
  # get the QueryString template
  template <- strsplit(os.template, paste0(access.point, "?"), fixed=TRUE)[[1]][2]

  # create a data.frame of with the template
  l <- strsplit(strsplit(template, "&", fixed=TRUE)[[1]], "=", fixed=TRUE)
  df.template <- data.frame(matrix(unlist(l), nrow=length(l), byrow=T), stringsAsFactors=FALSE)

  # set the column names
  colnames(df.template) <- c("param", "type")
 
  # from Factor to Character
  ##df.template <- CastCharacter(df.template)
  
  # remove the {, }, ? from the type
  df.template <- as.data.frame(sapply(df.template, function(x) {
          x <- str_replace_all(x, "([\\{\\}\\?])", "")
        }))
  
  df.params <- CastCharacter(df.params)
  
  # merge the template and the parameters
  df.query <- merge(df.template, df.params, by.y=c("type"), all.y=TRUE)[,2-3]
  
  # from Factor to Character
  ##CastCharacter(df.query)
  
  # create a named list
  params <- as.list(df.query$value)
  names(params) <- df.query$param
  
  # submit the form
  response <- xmlParse(getForm(access.point, .params=params))
  
  series <- xmlToDataFrame(nodes = getNodeSet(response,
      "//dclite4g:Series"), stringsAsFactors = FALSE)
      
  dataset <- xmlToDataFrame(nodes = getNodeSet(response,
      "//dclite4g:DataSet"), stringsAsFactors = FALSE)
  

  
  res <- list(series, dataset)
  names(res) <- c("series", "dataset")
  return(res)
}
