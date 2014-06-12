\name{Query}
\alias{Query}
\title{A function to query an OpenSearch search engine using the OpenSearch description document URL,
a response type and a data frame with queryables' type and values (NAs are removed)}
\usage{
Query(opensearch.description, response.type, df.params)
}
\arguments{
  \item{opensearch.description}{URL pointing to the
  OpenSearch description document}

  \item{response.type}{OpenSearch response type (e.g.
  application/rdf+xml)}
}
\value{
the OpenSearch response
}
\description{
A function to query an OpenSearch search engine using the
OpenSearch description document URL, a response type and a
data frame with queryables' type and values (NAs are
removed)
}
\examples{
\dontrun{
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
df.params <- GetOSQueryables(osd.url, "application/rdf+xml")
df.params$value[df.params$type == "count"] <- 30
df.params$value[df.params$type == "time:start"] <- "2010-01-10"
df.params$value[df.params$type == "time:end"] <- "2010-01-31"
res <- Query(osd.url, "application/rdf+xml", df.params)
}
}
\keyword{utilities}

