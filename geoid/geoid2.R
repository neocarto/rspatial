library("magick")


map <- function(deformation, rotation){
  
  file =   paste0("img/",deformation,"/geoid_",rotation,".jpg")
  
  legend = image_read("img/legend.png")
  signature = image_read_svg("img/signature_black.svg", width = 50)
  font = 'Helvetica'
  img = image_read(file)
  legpos = 520
  img = image_composite(img, legend, offset = paste0("+10+",legpos))
  img = image_annotate(img, "Bosses", size = 17, color = "#52514a", font = font, location = paste0("+9+",legpos - 20), style="Bold")
  img = image_annotate(img, "Creux", size = 17, color = "#52514a", font = font, location = paste0("+9+",legpos + 255), style="Bold")
  img = image_annotate(img, "Variation", size = 19, color = "#52514a", font = font, location = paste0("+45+",legpos + 90), style="Italic")
  img = image_annotate(img, "du géoïde", size = 19, color = "#52514a", font = font, location = paste0("+45+",legpos + 110), style="Italic")
  img = image_annotate(img, "terrestre", size = 19, color = "#52514a", font = font, location = paste0("+45+",legpos + 130), style="Italic")
  img = image_annotate(img, paste0("Déformation exagérée ",deformation," fois"), size = 30, color = "#52514a", font = font, boxcolor = "#ebd757", gravity = "south", location = "+0+15")
  img = image_annotate(img, "Source : Earth Gravitational Model 2008 (EGM2008). Cartographie : Nicolas Lambert, 2021", size = 9, color = "#52514a", font = font, gravity = "south", location = "+0+2")
  img = image_composite(img, signature, gravity = "SouthEast", offset = "+5+5")
  
  img = image_annotate(img, "La Terre", size = 50, color = "#52514a", font = font, location = "+7+12", style="Bold")
  img = image_annotate(img, "est-elle", size = 50, color = "#52514a", font = font, location = "+7+62", style="Bold")
  img = image_annotate(img, "vraiment", size = 50, color = "#52514a", font = font, location = "+7+112", style="Bold")
  img = image_annotate(img, "ronde", size = 50, color = "#52514a", font = font, location = "+7+162", style="Bold")
  img = image_annotate(img, "?", size = 50, color = "#52514a", font = font, location = "+7+212", style="Bold")
  
  img = image_annotate(img, "La Terre", size = 50, color = "white", font = font, location = "+5+10", style="Bold")
  img = image_annotate(img, "est-elle", size = 50, color = "white", font = font, location = "+5+60", style="Bold")
  img = image_annotate(img, "vraiment", size = 50, color = "white", font = font, location = "+5+110", style="Bold")
  img = image_annotate(img, "ronde", size = 50, color = "white", font = font, location = "+5+160", style="Bold")
  img = image_annotate(img, "?", size = 50, color = "white", font = font, location = "+5+210", style="Bold")
  
  folder = paste0("maps/",deformation)
  if (!file.exists(folder)){dir.create(folder)}
  newfile =   paste0("maps/",deformation,"/geoid_",rotation,".jpg")
  
  image_write(img, path = newfile, format = "jpg", quality = 75) 
}

# Export

for(d in 0:25){

  for (i in 1:44){
    if (i <= 9){j <- paste0("00",i)}
    if (i >= 10){j <- paste0("0",i)}
    if (i >= 100){j <- i}
    map(d*1000, j)
  }
}

#map("0", "001")
