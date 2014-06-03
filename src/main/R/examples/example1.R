library(devtools)
install_github("Rdclite4g", username="Terradue", subdir="/src/main/R/Rdclite4g")

# the OpenSearch description document
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"

# create filter
value <- c(100, "2010-01-10", "2010-01-31")
type <- c("count", "time:start", "time:end")
df.params <- data.frame(type, value)

res <- Query(osd.url, "application/rdf+xml", df.params)

dataset <- xmlToDataFrame(nodes = getNodeSet(res, 
    "//dclite4g:DataSet"), stringsAsFactors = FALSE)
  

# create a SpatialPolygonsDataFrame with the first element of res$dataset
poly.sp <- SpatialPolygonsDataFrame(readWKT(data.frame(res$dataset$spatial)[1,]), res$dataset[1,])

# iterate through the remaining dataset
for (n in 2:nrow(res$dataset)) {
  poly.sp <- rbind(poly.sp,
    SpatialPolygonsDataFrame(readWKT(data.frame(res$dataset$spatial)[n,],id=n), res$dataset[n,]))
}

# load rgdal for OGR
library(rgdal)

# write the geojson file
writeOGR(poly.sp, 'example1.geojson','dataMap', driver='GeoJSON')
