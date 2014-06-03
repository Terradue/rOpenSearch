\name{GetOSQueryables}
\alias{GetOSQueryables}
\title{A function to return the OpenSearch queryables as a data frame}
\usage{
GetOSQueryables(opensearch.description, response.type)
}
\arguments{
  \item{opensearch.description}{URL pointing to the
  OpenSearch decription document}
}
\value{
a data frame with three columns: param, type, value (NAs)
containing the queryables
}
\description{
A function to return the OpenSearch queryables as a data
frame
}
\examples{
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
GetOSQueryables(osd.url, "application/rdf+xml")
}
\keyword{utilities}

