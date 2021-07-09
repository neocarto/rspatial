# Import data
library(sf)
isere = st_read("data/isere.geojson")
isere = isere[,c("id","name","lon", "lat")] %>% st_drop_geometry()

# Coordinates and ids
coords = paste(paste(isere$lon,isere$lat,sep=","), collapse = ";")
ids = isere$id

# Get a matrix
router = "http://0.0.0.0:5000"
query = paste0(router,"/table/v1/driving/",coords,"?annotations=duration")
response = RCurl::getURL(query)

# Data Handling
output = rjson::fromJSON(response)
output = data.frame(output$duration)
colnames(output) = ids
output = cbind(id = ids, output)

# Export data
write.csv(output,"data/TimeDistCarIsere.csv", row.names = FALSE )

