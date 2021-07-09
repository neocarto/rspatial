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

# Coordinates and ids
coords = paste(paste(dots$lon,dots$lat,sep=","), collapse = ";")
ids = dots$id

# destination
target = "FR_75056"
destination <- match(target, dots$id) - 1

getdist = function(start){

# source
end = start + 999
if(end > dim(dots)[1]){end = dim(dots)[1]-1}
source = paste(rep(start:end), collapse = ";")

# Get a matrix
router = "http://0.0.0.0:5000"
query = paste0(router,"/table/v1/driving/",coords,"?destinations=",destination,"&sources=",source,"&annotations=duration")
start_time <- Sys.time()
response = RCurl::getURL(query)
end_time <- Sys.time()
end_time - start_time

# Data Handling
output = rjson::fromJSON(response)
output = data.frame(output$duration)


output = cbind(id = ids[(start+1):(end+1)], output)
colnames(output) = c("id","duration")

# Export data
file = paste0("tmp/TimeDistToParis_",start,"_",end,".csv")
write.csv(output,file, row.names = FALSE )
}

for(i in seq(from=0, to=34000, by=1000)){
getdist(i)
}


