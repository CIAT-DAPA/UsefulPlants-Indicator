##########################################   Start Functions    ###############################################
# This function takes a shapefile of native areas and crops the biolayers, and creates a mask
# with the shapefile.
# @param (string) species: species ID
# @return (string): species ID
nat_area_mask <- function(species) {
  
  #Loading global mask
  global_mask<-raster(paste0(par_dir,"/","world_mask/raster/mask.tif")) ###ADD TO CONFIG
  
  #Loading Velox RDS climate object
  rst_vx <- readRDS(paste(par_dir,"/biolayer_2.5/climate_vx.RDS",sep="")) ###ADD TO CONFIG
  x<-rst_vx;rm(rst_vx)
  #required packages
  require(shapefiles); require(raster); library(rgeos);require(velox)
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
      shapean <- raster::shapefile(paste0(narea_dir,"/","narea.shp"))
      
      if (!file.exists(paste0(narea_dir, "/", "narea_mask.tif"))) {
        
        #shapean <- raster:shapefile(dsn = "narea.shp", layer = "narea", verbose=F)
        
        na_msk<-raster::rasterize(shapean,global_mask,field=2,silent=T)
        na_msk[which(!is.na(na_msk[]))]<-1
        
        writeRaster(na_msk, paste0(narea_dir, "/", "narea_mask.tif"), format="GTiff")
      } else {
        
        na_msk<-raster(paste0(narea_dir, "/", "narea_mask.tif"))
        
      }
      
      #crop and mask biolayers
      
      x$crop(extent(shapean))
      x$write(path=paste0(narea_dir, "/", "crop_narea.tif"),overwrite = F);
      biolayers_cropc<-stack(paste0(narea_dir, "/", "crop_narea.tif"))
      biolayers_cropc<-biolayers_cropc*narea_mask
      names(biolayers_cropc)<-names(biolayers)
      
      #save cropped biolayers dataset
      
      saveRDS(object=biolayers_cropc, file=paste0(narea_dir, "/crop_narea.RDS"))
      file.remove(paste0(narea_dir, "/", "crop_narea.tif"),showWarnings=F)
      
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