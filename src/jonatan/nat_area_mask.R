require(shapefiles);require(raster);library(rgeos);require(rgdal); require(parallel)

#make source

#load config function
config(dirs=T, premodeling=T)

setwd("root")

biolayers <- stack(list.files(pattern = '\\.tif$'))

ocurs <- list.dirs(outfol, recursive = FALSE, full.names = FALSE)

cropsC <- function(species){
  
  narea <- paste0(outfol,species, run_version ,"/bioclim")
  
  if(!file.exists(paste0(narea, "/", "narea.shp"))){
    
    cat("Shapefile for", species,"native area doesn't exist", "\n")
    
  }else{
  
    cat("doing", species, "\n")
    shapean <- readOGR(dsn = narea, layer = "narea")
    biolayers_cropc<-crop(biolayers, shapean) # variables predictoras cortadas al poligono de ocurrencias.
    biolayers_cropc<-mask(biolayers_cropc, shapean) # variables predictoras cortadas al poligono de ocurrencias.

    raster1<- biolayers_cropc[[1]]
    raster1[Which(!is.na(raster1[]))] <- 1
    
    writeRaster(raster1, paste0(narea, "/", "narea_mask.tif"))
    save(biolayers_cropc, file = paste0(narea, "/", "crop_narea.RDS"))
    
    
    rm(narea)
    rm(shapean)
    rm(biolayers_cropc)
    rm(raster1)
}
  
  gc(reset=TRUE)
  
}


#--------------Run in parallel---------------
ncores <- 8 #change according available server resources
c1 <- makeCluster(ncores)
clusterEvalQ(c1, lapply(c("shapefiles", "raster", "rgeos", "rgdal"), library, character.only= TRUE))
clusterExport(c1, c("outfol", "ocurs"))
parLapply(c1, ocurs[1:200], cropsC)
