# An R code to calculate the areas of potential distribution range, herbarium buffered samples, germplasm
# buffered samples and convex hulls for crop wild relatives.
#
# "Adapting crops to climate change: collecting, protecting and preparing crop wild relatives"
# www.cwrdiversity.org
#
# J. Ramirez, N. Castaneda,  H. Achicanoy - 2013

require(rgdal)
require(raster)
require(sp)
require(maptools)
library(snowfall)

source(paste(src.dir,"/000.zipRead.R",sep=""))
source(paste(src.dir,"/000.zipWrite.R",sep=""))
source(paste(src.dir,"/000.bufferPoints.R",sep=""))

#Calculate the size of the DR, of the convexhull in km2, of the native area, and of the herbarium samples
#based on the area of the cells

sizeDR <- function(bdir, crop, spID) {
	idir <- paste(bdir, "/maxent_modeling", sep="")
	ddir <- paste(bdir, "/samples_calculations", sep="")
	naDir = paste(bdir, "/biomod_modeling/native-areas/polyshps", sep="") #Now restrict data to known native areas
	
	#Creating the directories
	if (!file.exists(ddir)) {
		dir.create(ddir)
	}
	
	spOutFolder <- paste(ddir, "/", spID, sep="")
	if (!file.exists(spOutFolder)) {
		dir.create(spOutFolder)
	}
  
  #Start estimating areas
	cat("Taxon", spID, "\n")
	
	mskArea <- paste(bdir, "/masks/cellArea.asc", sep="")
	mskArea <- raster(mskArea, values=T)
	msk <- paste(bdir, "/masks/mask.asc", sep="")
	msk <- raster(msk)
	
	#Size of the convex-hull
	cat("Reading occurrences \n")
  occ <- paste(bdir, "/occurrence_files_narea/", spID, ".csv", sep="")
  if(file.exists(occ)){
    occ <- read.csv(occ) #Only uses records within native area
    
    #   if (!file.exists(paste(spOutFolder, "/convex-hull.asc.gz",sep=""))) {
    cat("Creating the convex hull \n")
    #     ch <- occ[chull(occ$lon,occ$lat)]
    ch <- occ[chull(cbind(occ$lon,occ$lat)),1:2]
    
    #   	ch <- occ[chull(cbind(occ$lon, occ$lat)),2:3]
    ch <- rbind(ch, ch[1,])
    
    cat("Transforming to polygons \n")
    pol <- SpatialPolygons(list(Polygons(list(Polygon(ch)), 1)))
    grd <- rasterize(pol, msk)
    
    cat("Final fixes \n")
    grd[which(!is.na(grd[]))] <- 1
    grd[which(is.na(grd[]) & msk[] == 1)] <- 0
    grd[which(is.na(msk[]))] <- NA
    
    cat("Writing convex hull \n")
    chName <- zipWrite(grd, spOutFolder, "convex-hull.asc.gz")
    #   } 
    #   else {
    #     cat("Loading the convex hull \n")
    #     grd <- zipRead(spOutFolder, "convex-hull.asc.gz")
    #   }
    #   
    cat("Size of the convex hull \n")
    grd <- grd * mskArea
    areaCH <- sum(grd[which(grd[] != 0)])
    rm(grd)
    
  } else {
    areaCH <- NA
  }
	
	# Size of the native area
	cat("Reading native area \n")
	naFolder <- paste(bdir, "/biomod_modeling/native-areas/asciigrids/", spID, sep="")
	
	if (file.exists(paste(naFolder, "/narea.asc.gz", sep=""))) {
	  grd <- zipRead(naFolder, "narea.asc.gz")
	  cat("Size of the native area \n")
	  grd <- grd * mskArea
	  areaNA <- sum(grd[which(grd[] != 0)])
	  rm(grd)
	} else {
	  areaNA <- NA
	}
	
	#Load all occurrences
	allOcc <- read.csv(paste(bdir, "/occurrences/",crop,".csv", sep=""))
	allOcc <- allOcc[which(allOcc$Taxon == spID),]
	
	#Size of the herbarium samples CA50
	cat("Size of the h-samples buffer \n")
	hOcc <- allOcc[which(allOcc$H == 1),]
	if (nrow(hOcc) != 0) {
	  xy <- cbind(hOcc$lon, hOcc$lat)
	  occ <- SpatialPoints(xy)
	  
	  cat("Loading", spID, "native areas \n")
	  narea = paste(naDir, "/", spID, "/narea.shp", sep="")
    if(!file.exists(narea)){
      hOcc <- as.data.frame(cbind(as.character(hOcc$Taxon), hOcc$lon, hOcc$lat))
      names(hOcc) <- c("taxon", "lon", "lat")
      write.csv(hOcc, paste(spOutFolder, "/hsamples.csv", sep=""), quote=F, row.names=F)
      grd <- createBuffers(paste(spOutFolder, "/hsamples.csv", sep=""), spOutFolder, "hsamples-buffer.asc", 50000, paste(bdir, "/masks/mask.asc", sep=""))
    }else{
      narea = readShapeSpatial(narea)
      cat ("Projecting files \n")
      proj4string(occ) = CRS("+proj=longlat +datum=WGS84")
      proj4string(narea) = CRS("+proj=longlat +datum=WGS84")
      cat("Selecting occurrences within native area \n")
      x <- over(narea, occ)
      x <- sum(x, na.rm=T)
      if(x==0){
        cat("No points within native area \n")
      } else {
        occ = occ[narea]
        occ = as.data.frame(occ)
        names(occ) = c("lon","lat")
        occ["taxon"] <- spID
        write.csv(occ, paste(spOutFolder, "/hsamples.csv", sep=""), quote=F, row.names=F)
        grd <- createBuffers(paste(spOutFolder, "/hsamples.csv", sep=""), spOutFolder, "hsamples-buffer.asc", 50000, paste(bdir, "/masks/mask.asc", sep=""))
      }
    }
	}
    rm(hOcc)
	#	rm(occ)
    
    if (file.exists(paste(spOutFolder, "/hsamples-buffer.asc.gz",sep=""))) {
      grd <- zipRead(spOutFolder,"hsamples-buffer.asc.gz")
      grd <- grd * mskArea
      areaHB <- sum(grd[which(grd[] != 0)])
    } else {
      areaHB <- 0
    }
	  
	#Size of the germplasm samples CA50
	cat("Size of the g-samples buffer \n")
	gOcc <- allOcc[which(allOcc$G == 1),]
	if (nrow(gOcc) != 0) {
		xy <- cbind(gOcc$lon, gOcc$lat)
		occ <- SpatialPoints(xy)
		
		cat("Loading", spID, "native areas \n")
		narea = paste(naDir, "/", spID, "/narea.shp", sep="")
		if(!file.exists(narea)){
		  gOcc <- as.data.frame(cbind(as.character(gOcc$Taxon), gOcc$lon, gOcc$lat))
		  names(gOcc) <- c("taxon", "lon", "lat")
		  write.csv(gOcc, paste(spOutFolder, "/gsamples.csv", sep=""), quote=F, row.names=F)
		  grd <- createBuffers(paste(spOutFolder, "/gsamples.csv", sep=""), spOutFolder, "gsamples-buffer.asc", 50000, paste(bdir, "/masks/mask.asc", sep=""))
		}else{
		  narea = readShapeSpatial(narea)
		  cat ("Projecting files \n")
		  proj4string(occ) = CRS("+proj=longlat +datum=WGS84")
		  proj4string(narea) = CRS("+proj=longlat +datum=WGS84")
		  cat("Selecting occurrences within native area \n")
		  x <- over(narea, occ)
		  x <- sum(x, na.rm=T)
		  if(x==0){
		    cat("No points within native area \n")
		  } else {
		    occ = occ[narea]
		    occ = as.data.frame(occ)
		    names(occ) = c("lon","lat")
		    occ["taxon"] <- spID
		    write.csv(occ, paste(spOutFolder, "/gsamples.csv", sep=""), quote=F, row.names=F)
		    grd <- createBuffers(paste(spOutFolder, "/gsamples.csv", sep=""), spOutFolder, "gsamples-buffer.asc", 50000, paste(bdir, "/masks/mask.asc", sep=""))
		  }
		}
	}
		rm(gOcc)
		#rm(occ)
    
		if (file.exists(paste(spOutFolder,"/gsamples-buffer.asc.gz",sep=""))) {
		  grd <- zipRead(spOutFolder,"gsamples-buffer.asc.gz")
		  grd <- grd * mskArea
		  areaGB <- sum(grd[which(grd[] != 0)])
		} else {
		  areaGB <- 0
		}
  
	#Size of the DR
	spFolder <- paste(bdir, "/maxent_modeling/models/", spID, sep="")
	projFolder <- paste(spFolder, "/projections", sep="")
	spList <- read.csv(paste(bdir, "/summary-files/taxaForRichness.csv", sep=""))
	isValid <- spList$IS_VALID[which(spList$TAXON == paste(spID))]
	
	if (isValid == 1){
	  cat("Reading raster files \n")
	  grd <- paste(spID, "_worldclim2_5_EMN_PA.asc.gz", sep="")
	  grd <- zipRead(projFolder, grd)
    
	  cat("Size of the DR \n")
	  grd <- grd * mskArea
	  areaDR <- sum(grd[which(grd[] != 0)])
	  rm(grd) 
	  
	} else {
	  areaDR <- NA
	}
	
	outDF <- data.frame(DRSize=areaDR, CHSize=areaCH, NASize=areaNA, HBSize=areaHB, GBSize=areaGB)
	write.csv(outDF, paste(spOutFolder, "/areas.csv", sep=""), quote=F, row.names=F)
# 	return(outDF)
}

sizeDRProcess <- function(inputDir, ncpu, crop){

	spList <- list.files(paste(inputDir, "/occurrence_files", sep=""),pattern=".csv$")

	sizeDRwrapper <- function(i) {
	  library(SDMTools)
    library(rgdal)
		library(raster)
		library(sp)
		library(maptools)
		sp <- spList[i]
		sp <- unlist(strsplit(sp, ".csv", fixed=T))[1]
# 		cat("\n")
# 		cat("...Species", sp, "\n")
		out <- sizeDR(bdir=inputDir, crop=crop, spID=sp)
	}

	library(snowfall)
	sfInit(parallel=T,cpus=ncpu)

	sfExport("zipRead")
	sfExport("zipWrite")
  sfExport("createBuffers")
  sfExport("inputDir")
  sfExport("crop")
	sfExport("sizeDR")
  sfExport("spList")
  sfExport("sizeDRwrapper")
	
	#run the control function
	system.time(sfSapply(as.vector(1:length(spList)), sizeDRwrapper))
	
	#stop the cluster
	sfStop()
	
	return("Done!")
}