\name{GetOSTemplate}
\alias{GetOSTemplate}
\title{A function to return the full OpenSearch template made of the}
\usage{
GetOSTemplate(opensearch.description, response.type)
}
\arguments{
  \item{opensearch.description}{URL pointing to the
  OpenSearch description document}

  \item{response.type}{OpenSearch response type}
}
\value{
the OpenSearch URL template
}
\description{
A function to return the full OpenSearch template made of
the
}
\examples{
\dontrun{
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
GetOSTemplate(osd.url, "application/rdf+xml")
}
}
\keyword{utilities}

