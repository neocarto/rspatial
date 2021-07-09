# Tous les chemins menent à Rome

# Data Import
library(sf)
lau2 = st_read("https://gisco-services.ec.europa.eu/distribution/v2/lau/geojson/LAU_RG_01M_2020_4326.geojson")

# Data handling
dots = st_centroid(lau2[lau2$CNTR_CODE == "FR",])

dots = cbind(dots,st_coordinates(dots))
dots = dots[,c("id","POP_2020","AREA_KM2","X","Y")] %>% st_drop_geometry()
colnames(dots) = c("id","pop","area","lon","lat")
dots = dots[dots$lat > 40.93,]




write.csv(dots,"data/TimeDistToRoma.csv", row.names = FALSE )

# Coordinates and ids
coords = paste(paste(dots$lon,dots$lat,sep=","), collapse = ";")
ids = dots$id

# destination
target = "FR_75056"
destination <- match(target, dots$id) - 1

# Get a matrix
router = "http://0.0.0.0:5000"
query = paste0(router,"/table/v1/driving/",coords,"?destinations=",destination,"&annotations=duration")
response = RCurl::getURL(query)

# Data Handling
output = rjson::fromJSON(response)
output = data.frame(output$duration)
output = cbind(id = ids, output)
colnames(output) = c("id","duration")

# Export data
write.csv(output,"data/TimeDistToRoma.csv", row.names = FALSE )
