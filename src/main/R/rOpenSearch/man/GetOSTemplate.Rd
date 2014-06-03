\name{GetOSTemplate}
\alias{GetOSTemplate}
\title{A function to returns the full OpenSearch template made of the}
\usage{
GetOSTemplate(opensearch.description, response.type)
}
\arguments{
  \item{opensearch.description}{URL pointing to the
  OpenSearch decription document}

  \item{response.type}{OpenSearch response type}
}
\value{
the OpenSearch URL template
}
\description{
A function to returns the full OpenSearch template made of
the
}
\examples{
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
GetOSTemplate(osd.url, "application/rdf+xml")
}
\keyword{utilities}

