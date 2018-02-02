# ################################################################
# ##CALCULATE AREA FOR A MASK USING LATLONG RASTER APPROACH
# #################################################################
# 
# require(raster)
# 
# #loading mask
# mask<-raster("//dapadfs/Workspace_cluster_9/Aichi13/parameters/world_mask/raster/mask.tif")
# mask<-trim(mask)
# #calculating area
# am<-raster::area(mask,na.rm=T)
# #saving raster
# writeRaster(am,"//dapadfs/Workspace_cluster_9/Aichi13/parameters/world_mask/raster/area.tif")
