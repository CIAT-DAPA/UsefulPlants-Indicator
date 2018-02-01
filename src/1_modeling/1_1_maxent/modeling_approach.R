# Modeling approach, pseudo-absences selection, calibration, and fitting models
# J. Soto, C. Sosa, H. Achicanoy
# CIAT, 2018

# Load libraries
library(tidyverse)
library(dismo)
library(velox)

# Important scripts
# Obtain optimum parameters: Using ENMevaluate
source("//dapadfs/Projects_cluster_9/aichi/scripts/CreateMXArgs.R") # URL
source("do_projections.R") # URL

# --------------------------------------------------------------------- #
# Function
# --------------------------------------------------------------------- #
# Vary through species

# Inputs
# Load calibration results
load(paste0(gap_dir, "/2653304/", run_version, "/modeling/maxent/2653304.csv.RData"))

# Define output folder
# crossValDir <- "//dapadfs/Projects_cluster_9/aichi/ENMeval_4/outputs/2979057.csv/modeling_results"
crossValDir <- paste0(gap_dir, "/2653304/", run_version, "/modeling/maxent")

# Native area to project
# load("//dapadfs/Projects_cluster_9/aichi/ENMeval_4/outputs/2979057.csv/narea/crop_narea.RDS")
load(paste0(gap_dir, "/2653304/", run_version, "/bioclim/crop_narea.RDS"))

# Fitting final model
tryCatch(expr = {
  fit <- dismo::maxent(x = rst_fls, # Climate
                       p = optPars@occ.pts[,c("LON","LAT")], # Occurrences
                       a = optPars@bg.pts[,c("LON","LAT")], # Pseudo-absences
                       removeDuplicates = T,
                       # args = c("nowarnings","replicates=5","linear=true","quadratic=true","product=true","threshold=true","hinge=true","pictures=false","plots=false"),
                       args = c("nowarnings","replicates=5","pictures=false","plots=false",CreateMXArgs(optPars)),
                       path = crossValDir)
},
error = function(e){
  cat("Modeling process failed:", unique(occ_data$species), "\n")
  return("Done\n")
})



# Extract climate data
system.time(expr = {
  pnts <- rasterToPoints(x = biolayers_cropc)
  pnts <- as.data.frame(pnts)
  pnts$cellID <- cellFromXY(object = biolayers_cropc[[1]], xy = pnts[,1:2])
})
# system.time(expr = {
#   tst_vx <- velox::velox(biolayers_cropc)
#   pnts2 <- tst_vx$extract_points(sp = sp::Spatial(tst_vx$getCoordinates()))
#   pnts2 <- as.data.frame(pnts2)
# })



setwd(crossValDir)

# Do projections
system.time(expr = {
  pred <- raster::stack(lapply(1:5, function(x) make.projections(x, pnts = pnts, tmpl_raster = biolayers_cropc[[1]])))
})
system.time(expr = {pred2 <- predict(fit, biolayers_cropc)})

par(mfrow = c(2,3))
for(i in 1:5){
  hist(pred[[i]][!is.na(pred[[i]][])] - pred2[[i]][!is.na(pred2[[i]][])])
}

j.size <- "-mx8000m"
maxentApp <- "C:/Users/HAACHICANOY/Documents/R/win-library/3.4/dismo/java/maxent.jar"
projLayers <- "C:/Users/HAACHICANOY/Downloads/Climate"

# outDir <- "C:/Users/HAACHICANOY/Downloads/Climate"
# for(i in 1:nlayers(biolayers_cropc)){
#   writeRaster(x = biolayers_cropc[[i]], filename = paste0(outDir, "/", names(biolayers_cropc)[i], ".asc"))
# }

for(i in 1:5){
  lambdaFile <- paste0("C:/Users/HAACHICANOY/Downloads/Model2/species_", i-1, ".lambdas")
  outGrid <- paste0("C:/Users/HAACHICANOY/Desktop/fold", i-1, ".asc")
  system(paste("java", j.size, "-cp", maxentApp, "density.Project", lambdaFile, projLayers, outGrid, "nowarnings", "fadebyclamping", "-r", "-a", "-z"), wait=TRUE)
}

lambdaFile <- paste0("C:/Users/HAACHICANOY/Downloads/Model2/species_0.lambdas")
outGrid <- paste0("C:/Users/HAACHICANOY/Desktop/fold0.asc")
system(paste("java", j.size, "-cp", maxentApp, "density.Project", lambdaFile, projLayers, outGrid, "nowarnings", "fadebyclamping", "-r", "-a", "-z"), wait=TRUE)

javaFold_0 <- raster::raster("C:/Users/HAACHICANOY/Desktop/fold0.asc")
javaFold_1 <- raster::raster("C:/Users/HAACHICANOY/Desktop/fold1.asc")

summary(javaFold_0[!is.na(javaFold_0[])] - pred[[1]][!is.na(pred[[1]][])])
summary(javaFold_0[!is.na(javaFold_0[])] - pred2[[1]][!is.na(pred2[[1]][])])

summary(javaFold_1[!is.na(javaFold_1[])] - pred[[2]][!is.na(pred[[2]][])])
summary(javaFold_1[!is.na(javaFold_1[])] - pred2[[2]][!is.na(pred2[[2]][])])


# ================================================================================================================================= #
# Another calibration approach
# ================================================================================================================================= #
# 
# # Occurrence points
# occ_data <- read_csv(file = "//dapadfs/Projects_cluster_9/aichi/ENMeval_4/ocurrences/2979057.csv")
# occ_data <- as.data.frame(occ_data)
# 
# # Determine background points
# msk <- raster("//dapadfs/Workspace_cluster_9/Aichi13/parameters/world_mask/raster/mask.tif")
# msk_pts <- raster::rasterToPoints(msk)
# msk_pts <- as.data.frame(msk_pts)
# msk_pts <- msk_pts[msk_pts$y > -60,]
# msk_pts$mask <- NULL
# names(msk_pts) <- c("lon", "lat")
# msk_pts$cellID <- cellFromXY(object = msk, xy = msk_pts[,c("lon", "lat")])
# occ_cellID <- cellFromXY(object = msk, xy = occ_data[,c("lon", "lat")])
# msk_pts <- msk_pts[setdiff(msk_pts$cellID, occ_cellID),]; rm(occ_cellID)
# rownames(msk_pts) <- 1:nrow(msk_pts)
# 
# if(nrow(occ_data) >= 50){
#   set.seed(1234)
#   smpl <- base::sample(x = 1:nrow(msk_pts), size = nrow(occ_data)*10, replace = F)
#   bck_data <- msk_pts[smpl,]; rm(smpl)
# } else {
#   set.seed(1234)
#   smpl <- base::sample(x = 1:nrow(msk_pts), size = nrow(occ_data)*100, replace = F)
#   bck_data <- msk_pts[smpl,]; rm(smpl)
# }
# bck_data$cellID <- NULL
# bck_data$species <- unique(occ_data$species)
# bck_data <- bck_data[complete.cases(bck_data),] # Check this
# 
# # Load raster stack of climate variables
# if(!file.exists("//dapadfs/Workspace_cluster_9/Aichi13/gap_analysis/climate_vx.RDS")){
#   rst_dir <- "//dapadfs/Projects_cluster_9/aichi/biolayer_2.5"
#   rst_fls <- list.files(path = rst_dir, full.names = T)
#   rst_fls <- rst_fls[grep(pattern = "*.tif$", x = rst_fls)]
#   rst_fls <- raster::stack(rst_fls)
#   rst_fls_vx <- velox::velox(rst_fls)
#   saveRDS(object = rst_fls_vx, file = "//dapadfs/Workspace_cluster_9/Aichi13/gap_analysis/climate_vx.RDS")
# } else {
#   rst_fls_vx <- readRDS("//dapadfs/Workspace_cluster_9/Aichi13/gap_analysis/climate_vx.RDS")
# }
# 
# # Calibration process
# transformInputData <- function(occ = occ_data, bck = bck_data, clim = rst_fls_vx){
#   occ$y <- 1
#   bck$y <- 0
#   all_data <- rbind(occ, bck)
#   all_data <- cbind(all_data, rst_fls_vx$extract_points(sp = sp::SpatialPoints(all_data[,c("lon", "lat")])))
#   names(all_data)[5:ncol(all_data)] <- names(rst_fls)
#   return(all_data)
# }
# all_data <- transformInputData(occ = occ_data, bck = bck_data, clim = rst_fls_vx)
# library(devtools)
# if(!require(enmSdm)){
#   install_github('adamlilith/omnibus')
#   install_github('adamlilith/enmSdm')
#   library(omnibus)
#   library(enmSdm)
# } else {
#   library(omnibus)
#   library(enmSdm)
# }
# 
# library(microbenchmark)
# # system.time(expr = {maxent_calibration <- enmSdm::trainMaxEnt(data = all_data[,4:ncol(all_data)], regMult = seq(0.5, 4, 0.5), out = c('tuning'), verbose = TRUE, jackknife = F)})
# microbenchmark("Default" = {maxent_calibration <- enmSdm::trainMaxEnt(data = all_data[,4:ncol(all_data)], regMult = seq(0.5, 4, 0.5), out = c('tuning', 'model'), verbose = TRUE)},
#                "PO some things" = {maxent_calibration <- enmSdm::trainMaxEnt(data = all_data[,4:ncol(all_data)], regMult = seq(0.5, 4, 0.5), out = c('tuning'), verbose = TRUE, jackknife = F)})
