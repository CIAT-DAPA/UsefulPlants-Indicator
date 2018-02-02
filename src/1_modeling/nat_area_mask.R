##########################################   Start Functions    ###############################################
# This function takes a shapefile of native areas and crops the biolayers, and creates a mask
# with the shapefile.
# @param (string) species: species ID
# @return (string): species ID
nat_area_mask <- function(species) {
  #required packages
  require(shapefiles); require(raster); library(rgeos)
  require(rgdal) #; require(parallel)
  
  #load config function
  config(dirs=T, premodeling=T)
  
  #native area folder
  narea_dir <- paste0(gap_dir, "/",species, "/", run_version ,"/bioclim")
  
  #load native area shapefile
  if (!file.exists(paste0(narea_dir, "/narea.shp"))) {
    cat("Shapefile for species ID=", species,"native area doesn't exist", "\n")
  } else {
    #cat("doing", species, "\n")
    if (!file.exists(paste0(narea_dir, "/", "crop_narea.RDS"))) {
      #load native area shapefile
      setwd(narea_dir)
      shapean <- readOGR(dsn = "narea.shp", layer = "narea", verbose=F)
      
      #crop and mask biolayers
      biolayers_cropc <- crop(biolayers, shapean) # predictor variables cropped to native area extent
      biolayers_cropc <- mask(biolayers_cropc, shapean) # predictor variables masked to native area polygon
      biolayers_cropc <- stack(biolayers_cropc)
      biolayers_cropc <- readAll(biolayers_cropc)
      
      #if mask doesnt exist then create and write it
      if (!file.exists(paste0(narea_dir, "/", "narea_mask.tif"))) {
        na_msk <- biolayers_cropc[[1]]
        na_msk[which(!is.na(na_msk[]))] <- 1
        writeRaster(na_msk, paste0(narea_dir, "/", "narea_mask.tif"), format="GTiff")
        rm(na_msk)
      }
      
      #save cropped biolayers dataset
      saveRDS(object=biolayers_cropc, file=paste0(narea_dir, "/crop_narea.RDS"))
      #rm(narea_dir); rm(shapean); rm(biolayers_cropc)
    }
    #clean memory and return species ID
    gc(reset=TRUE)
    return(species)
  }
}

# testing
# ncores <- 8 #change according available server resources
# c1 <- makeCluster(ncores)
# clusterEvalQ(c1, lapply(c("shapefiles", "raster", "rgeos", "rgdal"), library, character.only= TRUE))
# clusterExport(c1, c("outfol", "ocurs"))
# parLapply(c1, ocurs[1:200], cropsC)
