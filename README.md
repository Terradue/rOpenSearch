# Rdclite4g

R package for dclite4g 

## Installing the package

__Development version__  

```coffee
# If you don't already have the devtools package installed, run
# install.packages("devtools")
# unlike most packages, devtools requires additional non-R dependencies depending on your OS. 
# See → https://github.com/ropensci/rOpenSci/wiki/Installing-devtools
library(devtools)
install_github("Rdclite4g", username="Terradue", subdir="/src/main/R/Rdclite4g")
```

## Getting Started 

#### Query the European Space Agency ERS-1/2 SAR and Envisat ASAR [virtual archive](http://eo-virtual-archive4.esa.int/) 

###### Query the Envisat ASAR Image Mode source packets Level 0 (ASA_IM__0P) series

Return three datasets from the time interval 2010-01-10 to 2010-01-31

```coffee
# load the library
library(Rdclite4g)
# define the OpenSearch description URL
osd.url <- "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"
# define the query terms as a data frame
value <- c(3, "2010-01-10", "2010-01-31")
type <- c("count", "time:start", "time:end")
df.params <- data.frame(type, value)
# query the OpenSearch catalogue
res <- Query(osd.url, df.params)
# access the series (as data frame)
df.series <- res$series
# access the dataset (as data frame)
df.dataset <- res$dataset
```

Save the dataset as GeoJson

```coffee
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
```

## Known issues

**Series**
 
The field values for description and link are not returned

**Dataset**

The field values for series, relation and onlineResource are not returned

## Questions, bugs, and suggestions

Please file any bugs or questions as [issues](https://github.com/Terradue/rOpenSearch/issues/new) or send in a pull request.


