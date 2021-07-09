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



# -----------------------------------------------------------------------------------------------
# Tous les chemins menent à Rome

router = "http://0.0.0.0:5000"
origin = "2.3357296443276074,48.859048717711595"
destination = "5.3839617993956175,43.293713055285956"
output = "test.json"
query = paste0(router,"/route/v1/car/",origin,";",destination,"?geometries=geojson&overview=full")
curl::curl_download(query, output)



# Get a matrix
router = "http://0.0.0.0:5000"
query = paste0(router,"/table/v1/driving/",coords,"?annotations=duration")

response = curl::curl_download(query, "output/tmp.json")
timedist = rjson::fromJSON("output/tmp.json")
getwd()


json_file = getURL(query)
  
timedist = rjson::fromJSON(response)

timedistIsere = rjson::fromJSON(curl::curl(query))

toto = curl::curl(query)
rjson::fromJSON(toto)


rjson::fromJSON(curl::curl(query))
773/800*20

# -------------------
# All to grenoble
# ---------------------

destination <- match("Grenoble",isere$name) - 1
output = "all2grenoble.json"
query = paste0(router,"/table/v1/driving/",coords,"?destinations=",destination,"&annotations=duration")
curl::curl_download(query, output)


toto = fromJSON(curl::curl(query))
toto$durations


# ---------------------
# All to all
# ---------------------

output = "all2all.json"
query = paste0(router,"/table/v1/driving/",coords,"?annotations=duration")
curl::curl_fetch_echo(query, output)

toto = fromJSON(curl::curl(query))
View(toto$durations)

# Test parse json

library(rjson)
test = fromJSON("all2grenoble.json")

durations = test$durations

View(durations)

View(test.destinations)
test["destinations"]
