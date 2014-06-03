\name{GetOSResponseFormats}
\alias{GetOSResponseFormats}
\title{A function to return the OpenSearch response formats}
\usage{
GetOSResponseFormats(opensearch.description)
}
\arguments{
  \item{opensearch.description}{URL pointing to the
  OpenSearch decription document}
}
\value{
the list of OpenSearch response types
}
\description{
A function to return the OpenSearch response formats
}
\examples{
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
GetOSResponseFormats(osd.url)
}
\keyword{utilities}

