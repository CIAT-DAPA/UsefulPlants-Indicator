

createBuffers <- function(spFile, outFolder, outName, buffDist, msk,robinson) {
  
  require(SDMTools)
  require(rgdal)
  require(maptools)
  require(raster)
  require(rgeos)
  
  ##LOADING CSV FILE
  
  cat("Reading coords","\n")
  
  occ<- read.csv(occ_file,header=T,sep=",")

  ##LOADING RASTER FILE
  
	msk <- raster(msk)
	proj4string(msk) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
 
  ##LOADING COORDS
 # xy_coords = as.data.frame(cbind(occ$final_lon,occ$final_lat))
 xy_coords = as.data.frame(cbind(occ$Longitude,occ$Latitude))
  xy_coords<-xy_coords[complete.cases(xy_coords),]
  colnames(xy_coords)<-c("x","y")
  coordinates(xy_coords)<-~x+y
  proj4string(xy_coords) <- CRS("+proj=longlat +datum=WGS84")
  
  
  
  if(robinson==T){
	##PROJECTING TO WORLD ROBINSON 
  cat("Projecting coords to World Robinson","\n")
  
  xy_coords <- spTransform(xy_coords,
                          CRS("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs "))
  
  ##BUFFERING USING POLYGONS
  
  cat("Buffering the points \n")
  
  buffer<-gBuffer(xy_coords, width = buffDist)
  # buffer2<-buffer
  
  ##PROJECTING FROM WORLD ROBINSON TO WGS84
  cat("Reprojecting coords to WGS84","\n")
  
  buffer<-spTransform(buffer,
                      CRS("+proj=longlat +datum=WGS84"))
  
  }else if(robinson==F){
    cat("USING LONLAT, NO PROJECTIONS CHOSEN","\n")
    
    ##BUFFERING USING POLYGONS
    
    cat("Buffering the points \n")
    
    buffer<-gBuffer(xy_coords, width = buffDist)
    # buffer2<-buffer

    }
  
  cat("Rasterizing buffers","\n")
 
  pa <- rasterize((buffer), msk)

 ##OMMITING NA AREAS
 
 cat("Ommiting No available areas","\n")
 
  pa[which(!is.na(pa[]))] <- 1
  pa[which(is.na(pa[]) & msk[] == 1)] <- 0
  pa[which(is.na(msk[]))] <- NA
    
 
 ##WRITING RASTER
 
 cat("Writing raster","\n")
 
  writeRaster(pa,paste0(outFolder,"/",outName,".asc"))
 
 cat("DONE!","\n")
 
}




occ_file<-"X:/DIST_RASTER/Andean.csv"
#msk<-"X:/DIST_RASTER/mask_global.asc" # ANERICAS
msk<-"X:/DIST_RASTER/mask_wb_c_ant.tif" # ANERICAS

outFolder<-"X:/DIST_RASTER"
outName<-"Andean"
#buffDist<-50000 #50 Km, use if you want to use Robinson projection.
buffDist<-0.5 #degress (NOT PROJECTED) more or less 50 Km
x<-createBuffers(occ_file, outFolder, outName, buffDist, msk,robinson=F)



