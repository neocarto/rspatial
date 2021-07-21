library("raster")
library("geometry")
library("rgl")
library("sf")
library("geosphere")
library("smoothr")
library("magick")

# -------------
# IMPORTS & COMPUTATION
# -------------

r <- raster("files/geoid30.tif")
ctr <- densify(st_read("shp/land.shp"), n = 3)
grat <- st_read("shp/ne_50m_graticules_20.shp")

m <- st_coordinates(ctr)
m <- m[,c("X","Y")]
m <- cbind(m, extract(r, m))

m2 <- st_coordinates(grat)
m2 <- m2[,c("X","Y")]
m2 <- cbind(m2, extract(r, m2))

llh <- data.frame(randomCoordinates(100000))
llh$h <- extract(r, llh[,1:2])
## just spherical
llh2xyz <- function(lonlatheight, rad = 500, exag = 1) {
  cosLat = cos(lonlatheight[,2] * pi / 180.0)
  sinLat = sin(lonlatheight[,2] * pi / 180.0)
  cosLon = cos(lonlatheight[,1] * pi / 180.0)
  sinLon = sin(lonlatheight[,1] * pi / 180.0)
  
  x = rad * cosLat * cosLon
  y = rad * cosLat * sinLon
  z = (lonlatheight[,3] * exag) + rad * sinLat
  
  cbind(x, y, z)
}
## triangulate first in lonlat

tbr <- delaunayn(llh[,1:2])
tri.ind <- as.vector(t(tbr))

# colour mapping scale
scl <- function(x, nn = 50) {
  1 + (nn-1) * ((x[!is.na(x)] - min(x,na.rm = TRUE))/diff(range(x, na.rm = TRUE)))
}

n <- 150
## those colours, closer to original
jet.colors <-
  colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
                     "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

jet.colors(1)


plotmap <- function(myexag = 20000){
  theta = 0
  phi = 0
  r3dDefaults$windowRect <- c(335, 142,1096,1008) 
  clear3d()
  myrad <- 6378137
  xyz <- llh2xyz(llh, rad = myrad, exag = myexag)
  mxyz <- llh2xyz(m,rad = myrad + 10000, exag = myexag)
  mxyz2 <- llh2xyz(m2,rad = myrad + 5000, exag = myexag)
  rgl.triangles(xyz[tri.ind,1], xyz[tri.ind,2], xyz[tri.ind,3],col = jet.colors(n)[scl(llh[tri.ind, 3], nn = n)])
  pch3d(mxyz2[,1], mxyz2[,2], mxyz2[,3], pch = 20, color = "white", cex = 0.018)
  pch3d(mxyz[,1], mxyz[,2], mxyz[,3], pch = 20, color = "#403f3e", cex = 0.015)
}



# -------------
# BUILD MAPS
# -------------

r3dDefaults$windowRect <- c(0, 0,800,800) 
open3d()
bg3d("white")



drawgeoid <- function(nb = 180, exag = 10000, zoom = 0.62){

    uM0 <- rotationMatrix(-pi/2, 1, 0, 0) %>%
    transform3d(rotationMatrix(-2, 0, 0, 1)) %>%
    transform3d(rotationMatrix(-pi/12, 1, 0, 0))
  
  angle.rad <- seq(0, 2*pi, length.out = nb)
  plotmap(exag)
  r3dDefaults$windowRect <- c(0, 0,800,800) 
  rgl.viewpoint(theta = 0, phi = 0, fov = 0, zoom = zoom,
                userMatrix = uM0)
  
  text3d(x = 100, y = 100, text = paste0("Exaggeration x",exag), adj = 0.5, cex = 1)
  
  nb <- nb -1
  for (i in 1:nb) {
    #uMi <- transform3d(uM0, rotationMatrix(-angle.rad[i], 0, 0, 1))
    uMi <- transform3d(uM0, rotationMatrix(angle.rad[i], 0, 0, 1))
    rgl.viewpoint(theta = 0, phi = 0, fov = 0, zoom = zoom,
                  userMatrix = uMi)
    
    if (i <= 9){j <- paste0("00",i)}
    if (i >= 10){j <- paste0("0",i)}
    if (i >= 100){j <- i}
    
    folder = paste0("img/",exag)
    if (!file.exists(folder)){dir.create(folder)}
    
    filename <- paste0(folder, "/geoid_",j, ".jpg")
    rgl.snapshot(filename)    
    
    # low definition

    
    img <- image_read(filename) # %>% image_scale("800x")
    image_write(img, path = filename, format = "jpeg", quality = 75) 
  }
  
}

# -------------
# GO !!!!!!!!!!
# -------------

for (i in 0:25){
  drawgeoid(nb = 45, exag = i * 1000, zoom = 0.70)
}
