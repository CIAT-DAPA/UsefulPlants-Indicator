require(dismo);require(raster)

#run_version<-"v1"
#gap_dir<-"//dapadfs/Workspace_cluster_9/Aichi13/gap_analysis"
null_model_AUC<-function(species){
  ####LOADING CALIBRATION OCCURRENCES AND NATIVE AREA MASK
  narea_mask<-raster(paste0(gap_dir,"/",species,"/",run_version,"/","bioclim/narea_mask.tif"))
  #load(paste0(gap_dir, "/", species, "/", run_version, "/modeling/maxent/", species, ".csv.RData"))
  occs<-read.csv(paste0(occ_dir,"/","no_sea","/",species,".csv"))
  occs <- unique(occs[,c("lon","lat")])
  
 # narea_mask<-raster("//dapadfs/Workspace_cluster_9/Aichi13/gap_analysis/2653304/v1/bioclim/narea_mask.tif")

  ####ADJUSTING AN UNIQUE SET.SEED TO GET THE SAME KFOLD SPLIT
  
  set.seed(1235)
 # occs<-optPars@occ.pts
  training<-occs[which(kfold(occs, k=3)!=3),]
  rownames(training) <- 1:nrow(training)
  colnames(training)<-c("lon","lat")
  
  set.seed(1235)
  testing  <- occs[which(kfold(occs, k=3)==3),]
  rownames(testing) <- 1:nrow(testing)
  colnames(testing)<-c("lon","lat")
  
  ####PERFORMING NULL MODEL USING GEODIST FUNCTION AND 10000 PSEUDOABSENCES
  Null_model <- geoDist(training, lonlat=T)
  
  # Step 4: Evaluate model
  count<-length(narea_mask[which(narea_mask[]==1)])
  
  
  if(count>=10000){
    pabs <- randomPoints(mask=narea_mask, n=10000)
    pabs <- as.data.frame(pabs)
    
  }else{
    
    msk_narea <- narea_mask
    msk_pts_narea <- raster::rasterToPoints(msk_narea)
    msk_pts_narea <- as.data.frame(msk_pts_narea)
    msk_pts_narea <- msk_pts_narea[which(msk_pts_narea$y > -60),]
    msk_pts_narea$mask <- NULL
    names(msk_pts_narea) <- c("lon", "lat")
    msk_pts_narea <- msk_pts_narea[complete.cases(msk_pts_narea),]
    msk_pts_narea$cellID <- cellFromXY(object = msk_narea, xy = msk_pts_narea[,c("lon", "lat")])
    #occ_cellID <- cellFromXY(object = msk, xy = optPars@occ.pts[,c("LON","LAT")])
    occ_cellID_narea <- cellFromXY(object = msk_narea, xy = occs[,c("lon","lat")])
    #msk_pts_narea <- msk_pts_narea[setdiff(msk_pts_narea$cellID, occ_cellID),]; rm(occ_cellID)
    msk_pts_narea <- msk_pts_narea[which(!msk_pts_narea$cellID %in% occ_cellID_narea),]
    msk_pts_narea <- msk_pts_narea[,c("lon","lat")]
    rownames(msk_pts_narea) <- 1:nrow(msk_pts_narea); rm(msk_narea)
    pabs <- as.data.frame(msk_pts_narea)
    
  }
  
  names(pabs) <- c("lon", "lat")
  eval <- dismo::evaluate(p=testing, a=pabs, model=Null_model)
  AUC <- eval@auc
  
  
  return(AUC)
}

#x<-null_model_AUC(2653304)
