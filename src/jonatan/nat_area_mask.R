require(shapefiles);require(raster);library(rgeos);require(rgdal); require(parallel)

#make source

#load config function
config(dirs=T, premodeling=T)

setwd("root")

biolayers <- stack(list.files(pattern = '\\.tif$'))

ocurs <- list.dirs(outfol, recursive = FALSE, full.names = FALSE)



cropsC <- function(species){
  
 
    narea <- paste0(outfol,species, "/narea")
    cat("doing", species, "\n")
    shapean <- readOGR(dsn = narea, layer = "narea")
    #biolayers_cropc<-crop(biolayers, shapean) # variables predictoras cortadas al poligono de ocurrencias.
    load(paste0(outfol,species,"/narea/crop_narea.RDS"))
    biolayers_cropc<-mask(biolayers_cropc, shapean) # variables predictoras cortadas al poligono de ocurrencias.

    
    rm(shapean)
    save(biolayers_cropc, file = paste0(narea, "/", "crop_narea.RDS"))
    

  rm(biolayers_cropc)
  rm(narea)
  
  gc(reset=TRUE)
  
}


#--------------Run in parallel---------------
ncores <- 8 #change according available server resources
c1 <- makeCluster(ncores)
clusterEvalQ(c1, lapply(c("shapefiles", "raster", "rgeos", "rgdal"), library, character.only= TRUE))
clusterExport(c1, c("outfol", "ocurs"))
parLapply(c1, ocurs[1:200], cropsC)
