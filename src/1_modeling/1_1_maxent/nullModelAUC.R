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
  pabs <- randomPoints(mask=narea_mask, n=10000)
  pabs <- as.data.frame(pabs)
  names(pabs) <- c("lon", "lat")
  eval <- dismo::evaluate(p=testing, a=pabs, model=Null_model)
  AUC <- eval@auc
  
  
  return(AUC)
}

#x<-null_model_AUC(2653304)
