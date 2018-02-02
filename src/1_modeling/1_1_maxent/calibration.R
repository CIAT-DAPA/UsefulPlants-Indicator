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
