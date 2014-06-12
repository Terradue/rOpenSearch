\name{GetOSAccessPoint}
\alias{GetOSAccessPoint}
\title{A function to return the OpenSearch access point}
\usage{
GetOSAccessPoint(opensearch.description, response.type)
}
\arguments{
  \item{opensearch.description}{URL pointing to the
  OpenSearch description document}

  \item{response.type}{OpenSearch response type}
}
\value{
the OpenSearch access point for the provided response type
}
\description{
A function to return the OpenSearch access point
}
\examples{
\dontrun{
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
GetOSAccessPoint(osd.url, "application/rdf+xml")
}
}
\keyword{utilities}

