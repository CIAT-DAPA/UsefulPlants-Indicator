# Modeling approach, pseudo-absences selection, calibration, and fitting models
# J. Soto, C. Sosa, H. Achicanoy
# CIAT, 2018

# R options
# g <- gc(reset = T); rm(list = ls()); options(warn = -1); options(scipen = 999)

# Load libraries
suppressMessages(library(tidyverse))
suppressMessages(library(dismo))
suppressMessages(library(velox))
suppressMessages(library(ff))
suppressMessages(library(data.table))

# # Important scripts
# source(paste(repo_dir,"/1_modeling/1_1_maxent/create_mx_args.R",sep=""))
# source(paste(repo_dir,"/1_modeling/1_1_maxent/do_projections.R",sep=""))
# source(paste(repo_dir,"/1_modeling/1_1_maxent/evaluating.R",sep=""))
# source(paste(repo_dir,"/1_modeling/1_1_maxent/nullModelAUC.R",sep=""))
# source(paste(repo_dir,"/1_modeling/1_2_alternatives/create_buffers.R",sep=""))

# From config file
# run_version <- "v1"
# gap_dir <- "//dapadfs/Workspace_cluster_9/Aichi13/gap_analysis"

# --------------------------------------------------------------------- #
# Modeling function
# --------------------------------------------------------------------- #

spModeling <- function(species){
  # run config function
  config(dirs=T,modeling=T)
  
  if (file.exists(paste(occ_dir,"/no_sea/",species,".csv",sep=""))) {
    # Load calibration results
    if (file.exists(paste0(gap_dir, "/", species, "/", run_version, "/modeling/maxent/", species, ".csv.RData"))) {
      load(paste0(gap_dir, "/", species, "/", run_version, "/modeling/maxent/", species, ".csv.RData"))
    } else {
      optPars <- NULL
    }
    
    # Native area for projecting
    biolayers_cropc = readRDS(paste0(gap_dir, "/", species, "/", run_version, "/bioclim/crop_narea.RDS"))
    
    #load occurrence points
    xy_data <- read.csv(paste(occ_dir,"/no_sea/",species,".csv",sep=""),header=T)
    xy_data <- unique(xy_data[,c("lon","lat")])
    
    # Run alternatives #paste(sp_dir,"/bioclim/narea_mask.tif",sep="")
    if(!file.exists(paste0(gap_dir, "/", species, "/", run_version, "/modeling/alternatives/ca50_total_narea.tif"))){
      #xy_data <- optPars@occ.pts[,c("LON","LAT")]; xy_data <- as.data.frame(xy_data)
      #names(xy_data) <- c("lon", "lat")
      create_buffers(xy = xy_data,
                     msk = raster(paste(gap_dir,"/",species,"/",run_version,"/bioclim/narea_mask.tif",sep="")), # cambiar a mask de native area
                     buff_dist = 0.5,
                     format = "GTiff",
                     filename = paste0(gap_dir, "/", species, "/", run_version, "/modeling/alternatives/ca50_total_narea.tif"))
    }
    
    # Output folder
    crossValDir <- paste0(gap_dir, "/", species, "/", run_version, "/modeling/maxent")
    
    if(nrow(xy_data) >= 10){
      if(!file.exists(paste0(crossValDir, "/modeling_results.", species, ".RDS"))){
        #cat("Starting modeling process for species:", species, "\n")
        
        # ---------------- #
        # Inputs
        # ---------------- #
        
        # Loading climate worldwide rasters
        # rst_dir <- "//dapadfs/Workspace_cluster_9/Aichi13/parameters/biolayer_2.5/raster" PLEASE REVIEW
        #rst_dir <- paste(par_dir,"/biolayer_2.5/raster",sep="")
        rst_fls <- list.files(path = rst_dir, full.names = T)
        rst_fls <- rst_fls[grep(pattern = "*.tif$", x = rst_fls)]
        rst_fls <- raster::stack(rst_fls)
        
        # Determine background points
        #cat("Creating background for: ", sp, "\n")
        # msk <- raster("//dapadfs/Workspace_cluster_9/Aichi13/parameters/world_mask/raster/mask.tif") PLEASE REVIEW
        msk <- msk_global
        msk_pts <- raster::rasterToPoints(msk)
        msk_pts <- as.data.frame(msk_pts)
        msk_pts <- msk_pts[which(msk_pts$y > -60),]
        msk_pts$mask <- NULL
        names(msk_pts) <- c("lon", "lat")
        msk_pts <- msk_pts[complete.cases(msk_pts),]
        msk_pts$cellID <- cellFromXY(object = msk, xy = msk_pts[,c("lon", "lat")])
        #occ_cellID <- cellFromXY(object = msk, xy = optPars@occ.pts[,c("LON","LAT")])
        occ_cellID <- cellFromXY(object = msk, xy = xy_data[,c("lon","lat")])
        #msk_pts <- msk_pts[setdiff(msk_pts$cellID, occ_cellID),]; rm(occ_cellID)
        msk_pts <- msk_pts[which(!msk_pts$cellID %in% occ_cellID),]
        rownames(msk_pts) <- 1:nrow(msk_pts); rm(msk)
        
        if(nrow(xy_data) >= 50){
          set.seed(1234)
          smpl <- base::sample(rownames(msk_pts), nrow(xy_data)*10, replace = F)
          bck_data <- msk_pts[na.omit(match(smpl, rownames(msk_pts))),]; rm(smpl)
        } else {
          set.seed(1234)
          smpl <- base::sample(rownames(msk_pts), nrow(xy_data)*100, replace = F)
          bck_data <- msk_pts[na.omit(match(smpl, rownames(msk_pts))),]; rm(smpl)
        }
        bck_data$cellID <- NULL
        bck_data$species <- species
        
        #extract bio variables to check that no NAs are present
        bck_data_bio <- cbind(bck_data, rst_vx$extract_points(sp = sp::SpatialPoints(bck_data[,c("lon", "lat")])))
        bck_data_bio <- bck_data_bio[complete.cases(bck_data_bio),]
        bck_data <- bck_data_bio[,c("lon","lat","species")]
        
        #do the same for presences
        xy_data_bio <- cbind(xy_data, rst_vx$extract_points(sp = sp::SpatialPoints(xy_data[,c("lon", "lat")])))
        xy_data_bio <- xy_data_bio[complete.cases(xy_data_bio),]
        xy_data <- xy_data_bio[,c("lon","lat")]
        
        #put together both datasets
        bck_data_bio$species <- NULL
        xy_mxe <- rbind(bck_data_bio, xy_data_bio)
        xy_mxe <- xy_mxe[,c(3:ncol(xy_mxe))]
        names(xy_mxe) <- names(rst_fls)
        row.names(xy_mxe) <- 1:nrow(xy_mxe)
        
        # ---------------- #
        # Modeling
        # ---------------- #
        
        # Fitting final model
        
        #cat("Loading tunned parameters to perform MaxEnt modeling  for: ", sp, "\n")
        tryCatch(expr = {
          #fit maxent
          fit <- dismo::maxent(x = xy_mxe, # Climate
                               #p = optPars@occ.pts[,c("LON","LAT")], # Occurrences
                               #p = xy_data[,c("lon","lat")], # Occurrences
                               p = c(rep(0,nrow(bck_data_bio)),rep(1,nrow(xy_data_bio))),
                               #a = bck_data[,c("lon","lat")], # Pseudo-absences
                               removeDuplicates = T,
                               # args = c("nowarnings","replicates=5","linear=true","quadratic=true","product=true","threshold=true","hinge=true","pictures=false","plots=false"),
                               args = c("nowarnings","replicates=5","pictures=false","plots=false", CreateMXArgs(optPars)),
                               #path = crossValDir,
                               silent = F)
          
          #copy maxent files from temp dir
          mxe_outdir <- fit@html
          mxe_outdir <- gsub("/maxent.html","",mxe_outdir,fixed=T)
          mxe_fls <- list.files(mxe_outdir,pattern=".lambdas$",full.names=T)
          xs <- file.copy(mxe_fls, crossValDir)
        },
        error = function(e){
          cat("Modeling process failed:", species, "\n")
          return("Done\n")
        })
        
        #fls.rm <- list.files(crossValDir, full.names = T)
        #fls.rm <- fls.rm[setdiff(1:length(fls.rm), c(grep(pattern = paste0(sp, ".csv.RData"), fls.rm), grep(pattern = "*.lambdas$", fls.rm)))]
        #file.remove(fls.rm)
        
        # ---------------- #
        # Outputs
        # ---------------- #
        
        # Extract climate data for projecting
        pnts <- rasterToPoints(x = biolayers_cropc)
        pnts <- as.data.frame(pnts)
        pnts$cellID <- cellFromXY(object = biolayers_cropc[[1]], xy = pnts[,1:2])
        
        # Fix crossvalidation path
        setwd(crossValDir)
        
        # Do projections
        # k: corresponding fold
        # pnts: data.frame with climate data for all variables on projecting zone
        # tmpl_raster: template raster to project
        #cat("Performing projections using lambda files for: ", species, "\n")
        
        pred <- raster::stack(lapply(1:5, function(x) make.projections(x, pnts = pnts, tmpl_raster = biolayers_cropc[[1]])))
        
        # Saving results
        results <- list(model = fit,
                        projections = pred,
                        occ_predictions = raster::extract(x = pred, y = xy_data[,c("lon","lat")]),
                        bck_predictions = raster::extract(x = pred, y = bck_data[,c("lon","lat")]))
        
        #cat("Saving RDS File with Models outcomes for: ", species, "\n")
        saveRDS(object = results, file = paste0(crossValDir, "/modeling_results.", species, ".RDS"))
        
        #cat("Saving Median and SD rasters for: ", species, "\n")
        spMedian <- raster::calc(pred, fun = function(x) median(x, na.rm = T))
        raster::writeRaster(x = spMedian, filename = paste0(crossValDir, "/spdist_median.tif"))
        spSD <- raster::calc(pred, fun = function(x) sd(x, na.rm = T))
        raster::writeRaster(x = spSD, filename = paste0(crossValDir, "/spdist_sd.tif"))
        
        # ---------------- #
        # Evaluation metrics
        # ---------------- #
        
        # Extracting metrics for 5 replicates
        #cat("Gathering replicate metrics  for: ", species, "\n")
        evaluate_table <- metrics_function(species)
        #evaluate_table<-read.csv(paste0(crossValDir,"/","eval_metrics_rep.csv"),header=T)
  
        # Apply threshold from evaluation
        #cat("Thresholding using Max metrics  for: ", species, "\n")
        thrsld <- as.numeric(mean(evaluate_table[,"Threshold"],na.rm=T))
        if (!file.exists(paste0(crossValDir, "/spdist_thrsld.tif"))) {
          spThrsld <- spMedian
          spThrsld[which(spThrsld[] >= thrsld)] <- 1
          spThrsld[which(spThrsld[] < thrsld)] <- 0
          raster::writeRaster(x = spThrsld, filename = paste0(crossValDir, "/spdist_thrsld.tif"))
        } else {
          spThrsld <- raster(paste0(crossValDir, "/spdist_thrsld.tif"))
        }
        
        # Gathering final evaluation table
        x <- evaluate_function(species, evaluate_table)
        #return(cat("Process finished successfully for specie:", species, "\n"))
      } else {
        cat("Species:", species, "has been already modeled\n")
      }
    } else {
      cat("Species:", species, "only has", nrow(xy_data), "coordinates, it is not appropriate for modeling\n")
    }
  }
  return(species)
}



# ================================================================================================================================= #
# Evaluate projections results
# ================================================================================================================================= #
# 
# # Do projections
# system.time(expr = {
#   pred <- raster::stack(lapply(1:5, function(x) make.projections(x, pnts = pnts, tmpl_raster = biolayers_cropc[[1]])))
# })
# system.time(expr = {pred2 <- predict(fit, biolayers_cropc)})
# 
# par(mfrow = c(2,3))
# for(i in 1:5){
#   hist(pred[[i]][!is.na(pred[[i]][])] - pred2[[i]][!is.na(pred2[[i]][])])
# }
# 
# j.size <- "-mx8000m"
# maxentApp <- "C:/Users/HAACHICANOY/Documents/R/win-library/3.4/dismo/java/maxent.jar"
# projLayers <- "C:/Users/HAACHICANOY/Downloads/Climate"
# 
# # outDir <- "C:/Users/HAACHICANOY/Downloads/Climate"
# # for(i in 1:nlayers(biolayers_cropc)){
# #   writeRaster(x = biolayers_cropc[[i]], filename = paste0(outDir, "/", names(biolayers_cropc)[i], ".asc"))
# # }
# 
# for(i in 1:5){
#   lambdaFile <- paste0("C:/Users/HAACHICANOY/Downloads/Model2/species_", i-1, ".lambdas")
#   outGrid <- paste0("C:/Users/HAACHICANOY/Desktop/fold", i-1, ".asc")
#   system(paste("java", j.size, "-cp", maxentApp, "density.Project", lambdaFile, projLayers, outGrid, "nowarnings", "fadebyclamping", "-r", "-a", "-z"), wait=TRUE)
# }
# 
# lambdaFile <- paste0("C:/Users/HAACHICANOY/Downloads/Model2/species_0.lambdas")
# outGrid <- paste0("C:/Users/HAACHICANOY/Desktop/fold0.asc")
# system(paste("java", j.size, "-cp", maxentApp, "density.Project", lambdaFile, projLayers, outGrid, "nowarnings", "fadebyclamping", "-r", "-a", "-z"), wait=TRUE)
# 
# javaFold_0 <- raster::raster("C:/Users/HAACHICANOY/Desktop/fold0.asc")
# javaFold_1 <- raster::raster("C:/Users/HAACHICANOY/Desktop/fold1.asc")
# 
# summary(javaFold_0[!is.na(javaFold_0[])] - pred[[1]][!is.na(pred[[1]][])])
# summary(javaFold_0[!is.na(javaFold_0[])] - pred2[[1]][!is.na(pred2[[1]][])])
# 
# summary(javaFold_1[!is.na(javaFold_1[])] - pred[[2]][!is.na(pred[[2]][])])
# summary(javaFold_1[!is.na(javaFold_1[])] - pred2[[2]][!is.na(pred2[[2]][])])

