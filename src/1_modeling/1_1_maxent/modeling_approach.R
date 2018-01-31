# Modeling approach, pseudo-absences selection, calibration, and fitting models
# J. Soto, C. Sosa, H. Achicanoy
# CIAT, 2018

# Load libraries
library(tidyverse)
library(dismo)
library(velox)

# Occurrence points
occ_data <- read_csv(file = "//dapadfs/Projects_cluster_9/aichi/ENMeval_4/ocurrences/2979057.csv")
occ_data <- as.data.frame(occ_data)

# Determine background points
msk <- raster("//dapadfs/Workspace_cluster_9/Aichi13/parameters/world_mask/raster/mask.tif")
msk_pts <- raster::rasterToPoints(msk)
msk_pts <- as.data.frame(msk_pts)
msk_pts <- msk_pts[msk_pts$y > -60,]
msk_pts$mask <- NULL
names(msk_pts) <- c("lon", "lat")
msk_pts$cellID <- cellFromXY(object = msk, xy = msk_pts[,c("lon", "lat")])
occ_cellID <- cellFromXY(object = msk, xy = occ_data[,c("lon", "lat")])
msk_pts <- msk_pts[setdiff(msk_pts$cellID, occ_cellID),]; rm(occ_cellID)
rownames(msk_pts) <- 1:nrow(msk_pts)

if(nrow(occ_data) >= 50){
  set.seed(1234)
  smpl <- base::sample(x = 1:nrow(msk_pts), size = nrow(occ_data)*10, replace = F)
  bck_data <- msk_pts[smpl,]; rm(smpl)
} else {
  set.seed(1234)
  smpl <- base::sample(x = 1:nrow(msk_pts), size = nrow(occ_data)*100, replace = F)
  bck_data <- msk_pts[smpl,]; rm(smpl)
}
bck_data$cellID <- NULL
bck_data$species <- unique(occ_data$species)
bck_data <- bck_data[complete.cases(bck_data),] # Check this

# Load raster stack of climate variables
rst_dir <- "//dapadfs/Projects_cluster_9/aichi/biolayer_2.5"
rst_fls <- list.files(path = rst_dir, full.names = T)
rst_fls <- rst_fls[grep(pattern = "*.tif$", x = rst_fls)]
rst_fls <- raster::stack(rst_fls)
rst_fls_vx <- velox::velox(rst_fls)

# Calibration process
library(devtools)
if(!require(enmSdm)){
  install_github('adamlilith/omnibus')
  install_github('adamlilith/enmSdm')
  library(omnibus)
  library(enmSdm)
} else {
  library(omnibus)
  library(enmSdm)
}
transformInputData <- function(occ = occ_data, bck = bck_data, clim = rst_fls_vx){
  occ$y <- 1
  bck$y <- 0
  all_data <- rbind(occ, bck)
  all_data <- cbind(all_data, rst_fls_vx$extract_points(sp = sp::SpatialPoints(all_data[,c("lon", "lat")])))
  names(all_data)[5:ncol(all_data)] <- names(rst_fls)
  return(all_data)
}
all_data <- transformInputData(occ = occ_data, bck = bck_data, clim = rst_fls_vx)

maxent_calibration <- trainMaxEnt(data = all_data[,4:ncol(all_data)], regMult = seq(0, 6, 0.5), out = c('model', 'tuning'), verbose = TRUE)






















# ================================================================================================================================= #
# 
# # Load libraries
# library(tidyverse)
# library(dismo)
# 
# # Load calibration results
# load("//dapadfs/Projects_cluster_9/aichi/ENMeval_4/outputs/2979057.csv/2979057.csv.RData")
# 
# # Occurrence points
# optPars@occ.pts
# occ_data <- read_csv(file = "//dapadfs/Projects_cluster_9/aichi/ENMeval_4/ocurrences/2979057.csv")
# 
# # Background points
# optPars@bg.pts
# 
# # Obtain optimum parameters
# source("//dapadfs/Projects_cluster_9/aichi/scripts/CreateMXArgs.R")
# 
# # Load raster stack of climate variables
# rst_dir <- "//dapadfs/Projects_cluster_9/aichi/biolayer_2.5"
# rst_fls <- list.files(path = rst_dir, full.names = T)
# rst_fls <- rst_fls[grep(pattern = "*.tif$", x = rst_fls)]
# rst_fls <- raster::stack(rst_fls)
# 
# # Define output folder
# crossValDir <- "C:/Users/HAACHICANOY/Downloads/Model2"
# 
# # Run maxent
# tryCatch(expr={
#   fit <- dismo::maxent(x = rst_fls, # Climate
#                        p = optPars@occ.pts[,c("LON","LAT")], # Occurrences
#                        a = optPars@bg.pts[,c("LON","LAT")], # Pseudo-absences
#                        removeDuplicates = T,
#                        # args = c("nowarnings","replicates=5","linear=true","quadratic=true","product=true","threshold=true","hinge=true","pictures=false","plots=false"),
#                        args = c("nowarnings","replicates=5","pictures=false","plots=false",CreateMXArgs(optPars)),
#                        path = crossValDir)
# },
# error=function(e){
#   cat("Modeling process failed:",unique(occ_data$species),"\n")
#   return("Done\n")
# })
# 
# setwd(crossValDir)
# 
# files <- list.files(path = crossValDir, full.names = T)
# files_filtered <- files[grep(pattern = "*.lambdas$", x = files)]
# file.remove(setdiff(files, files_filtered))
# 
# # Obtain climate data information from raster
# 
# pnts <- vx$extract_points(sp = sp::Spatial(temp.dt$getCoordinates()))
# 
# temp.dt <- velox::velox(rst_fls)
# 
# system.time(expr = {pred1 <- predict(fit, rst_fls)})
# system.time(expr = {pred2 <- raster::stack(lapply(1:5, make.projections))})
# 
# 
# aic.opt <- optPars@models[[which(optPars@results$delta.AICc==0)]]
# aic.opt@results



