# rOpenSearch

R interface to OpenSearch

## Installing the package

__Development version__  

```coffee
# If you don't already have the devtools package installed, run
# install.packages("devtools")
# unlike most packages, devtools requires additional non-R dependencies depending on your OS. 
# See → http://www.rstudio.com/products/rpackages/devtools/
library(devtools)
install_github("rOpenSearch", username="Terradue", subdir="/src/main/R/rOpenSearch")
```

## Getting Started 

#### Query the European Space Agency ERS-1/2 SAR and Envisat ASAR [virtual archive](http://eo-virtual-archive4.esa.int/) 

###### Query the Envisat ASAR Image Mode source packets Level 0 (ASA_IM__0P) series

Return the 100 first dataset spanning time interval 2010-01-01 to 2010-01-31

```coffee
# load the libraries
library(devtools)
library(rgdal)
library(rgeos)

install_github("rOpenSearch", username="Terradue", subdir="/src/main/R/rOpenSearch")
library(rOpenSearch)

# define the OpenSearch description URL
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
response.type <- "application/rdf+xml"

# get the queryables dataframe from the OpenSearch description URL
df.params <- GetOSQueryables(osd.url, response.type)

# define the values for the queryables
df.params$value[df.params$type == "count"] <- 30 
df.params$value[df.params$type == "time:start"] <- "2010-01-10"
df.params$value[df.params$type == "time:end"] <- "2010-01-31"

# submit the query
res <- Query(osd.url, response.type, df.params)

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
```

The GeoJSON file can be see here:
https://github.com/Terradue/rOpenSearch/blob/master/src/main/R/examples/example1.geojson

## Questions, bugs, and suggestions

Please file any bugs or questions as [issues](https://github.com/Terradue/rOpenSearch/issues/new) or send in a pull request.


