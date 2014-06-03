library(devtools)
library(rgdal)
library(rgeos)

install_github("Rdclite4g", username="Terradue", subdir="/src/main/R/Rdclite4g")
library(Rdclite4g)

# the OpenSearch description document
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"

# get the queryables dataframe from the OpenSearch description URL
df.params <- GetOSQueriables(osd.url)

# define the values for the queryables
df.params$value[df.params$type == "count"] <- 30 
df.params$value[df.params$type == "time:start"] <- "2010-01-10"
df.params$value[df.params$type == "time:end"] <- "2010-01-31"

# submit the query
res <- Query(osd.url, "application/rdf+xml", df.params)

# get the dataset
dataset <- xmlToDataFrame(nodes = getNodeSet(xmlParse(res), 
  "//dclite4g:DataSet"), stringsAsFactors = FALSE)

# create a SpatialPolygonsDataFrame with the first element of res$dataset
poly.sp <- SpatialPolygonsDataFrame(readWKT(data.frame(dataset$spatial)[1,]), dataset[1,])

# iterate through the remaining dataset
for (n in 2:nrow(dataset)) {
  poly.sp <- rbind(poly.sp,
    SpatialPolygonsDataFrame(readWKT(data.frame(dataset$spatial)[n,],id=n), dataset[n,]))
}

# write the geojson file
writeOGR(poly.sp, 'example1.geojson','dataMap', driver='GeoJSON')
