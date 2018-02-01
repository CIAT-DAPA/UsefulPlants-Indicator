##########################################  Start Install Packages  ###############################################

# install.packages(c("raster","sp","rgdal","rgeos","sf","shapefiles", "snowfall"))

##########################################   End Install Packages  ###############################################


##########################################  Start Requirements  ###############################################

# Load the libraries
# require(raster)
# require(rgdal)
# require(sf)
# library(snowfall)
# library(plyr)

##########################################   End Requirements  ###############################################


##########################################  Start Set Parameters  ###############################################

# Global configuration
# rasterOptions(tmpdir = "D:/TEMP/hsotelo")
# setwd("//dapadfs/Workspace_cluster_9/Aichi13/")

# # Set the path of the file with global protected areas
# pa.path = "parameters/protected_areas/raster/areas_protected_geographic.tif"
# # Load the raster file with global protected areas
# pa.raster = raster(pa.path)
# # Remove the zeros (0) from raster
# pa.raster[which(pa.raster[] == 0)] <- NA
# Load the species list to execute process
# species.dir = "gap_analysis/"
# species.list = list.dirs(species.dir,full.names = FALSE, recursive = FALSE)

##########################################   End Set Parameters  ###############################################


##########################################   Start Functions    ###############################################

# This function calculate the GRS by every species.
# It searches the species, then load the species distribution from raster file. 
# With the species distribution intersectes with the native area, then with the protected areas raster and calculate
# the area from the species distribution, overlay and the proportion between both.
# It creates two files with the result (grs_result.csv, grs_intersect.tif)
# @param (string) specie: Code of the specie
# @param (bool) debug: Specifies whether to save the raster files. By default is FALSE
# @return (data.frame): This function return a dataframe with the results about the process. 
#                       It has three columns, the first has the specie code; the second has a status
#                       of process, if value is "TRUE" the process finished good, if the result is FALSE
#                       the process had a error; the third column has a description about process
calculate_grs = function(species, debug=T) {
  #required packages
  require(rgdal)
  
  #source config
  config(dirs=T, insitu=T)
  
  # Defined vars about process
  message = "Ok"
  status = TRUE
  
  # Set the global
  species.dir = paste0(species.glob.dir, "/", species, "/", run_version, "/")
  species.distribution = NULL
  
  tryCatch({
    #print(paste0("Start ",species))
    # Validation if the maxent model is good or not
    # to do the gap analysis insitu
    alternative.path = paste0(species.dir,"modeling/alternatives/ca50_total_narea.tif")
    maxent.path = paste0(species.dir,"modeling/maxent/spdist_median.tif")
    model.selected = read.csv(paste0(species.dir,"modeling/maxent/eval_metrics.csv"), header = T, sep=",")
    if(model.selected$VALID == TRUE){
      species.distribution = raster(maxent.path)
    } else{
      species.distribution = raster(alternative.path) 
    }
    
    # Remove the zeros (0) from raster
    species.distribution[which(species.distribution[]==0)] <- NA
    
    #print("Loaded the species distribution file (raster)")
    # Load the specie mask of native area
    #species.mask.path = paste0(species.dir,"bioclim/crop_narea.RDS")
    #load(species.mask.path)
    #species.mask = biolayers_cropc[[1]]
    species.mask <- raster(paste(species.dir,"bioclim/narea_mask.tif",sep=""))
    
    # Remove differents values from raster to get only the native area
    #specie.mask[which(!is.na(species.mask[]))]<-1
    
    #print("Loaded the native area of the species (mask)")
    
    # Intersect between species distribution and native area mask
    origin(species.distribution) <- origin(species.mask)
    overlay.distribution = species.distribution * species.mask
    
    # Intersect between species distribution (native area) and protected areas
    origin(pa.raster) <- origin(overlay.distribution)
    overlay = pa.raster * overlay.distribution
    
    # Intersect between species in protected areas and world area raster
    origin(world.area) <- origin(overlay)
    overlay.intersect = world.area * overlay #values in km2
    
    # Intersect between species distribution areas and world area raster
    origin(world.area) <- origin(species.distribution)
    overlay.species.area = world.area * overlay.distribution #values in km2
    
    #print("Intersected the species distribution (native area) and global protected areas")
    
    # # Get pixels with data from intersect
    # a = which(!is.na(overlay[]))
    # # Get pixels with data from species distribution
    # b = which(!is.na(overlay.distribution[]))
    # 
    # # Calculating the area in kilometer for each pixel
    # area = res(overlay.distribution)[1] * res(overlay.distribution)[2]
    # gra = 111.11*111.11
    # res = area * gra 
    # 
    # Calculate areas for the species distribution and intersect
    # overlay.area <- length(a) * res
    # species.area <- length(b) * res
    
    overlay.area = sum(overlay.intersect[],na.rm=T) #area within PAs
    species.area = sum(overlay.species.area[], na.rm=T) #total sp dist. area
    # Calculate proportion area
    proportion = (overlay.area / (a_insitu * species.area) ) * 100
    
    #print("Calculated the areas and proportions")
    
    # Join the results
    df <- data.frame(ID = species, SPP_AREA_km2 = species.area, SPP_WITHIN_PA_AREA_km2 = overlay.area, GRS = proportion)
    
    # Save the results
    if (debug) {
      save_results_grs(df, overlay.intersect, species.dir)
    } else {
      save_results_grs(df, NULL, species.dir)
    }
    return (data.frame(species = species, status = status, message = message))
  },
  error = function(e) {
    
    message = e
    status = FALSE
    
    # Join the results
    df <- data.frame(ID = species, SPP_AREA_km2 = NA, SPP_WITHIN_PA_AREA_km2 = NA, GRS = NA)
    
    # Save the results
    save_results_grs(df, NULL, species.dir)
    
    return (data.frame(species = species, status = status, message = message[[1]]))
  }, finally = {
    
    # Remove temp files
    removeTmpFiles(h=0)
    
    #print(paste0("End ",species))
  })
}

# This function save the results of analysis grs.
# This saves the raster of the intersect and analysis table
# @param (data.frame) df; Data.frame with the analysis of protected areas
# @param (raster) overlay: Intersect between species distribution and protected areas
# @param (string) specie.dir: Path where the files should be saved
# @param (bool) save: Specifies whether to save the raster files. By default is FALSE
# @return (void)
save_results_grs = function(df, overlay, species.dir){
  # Create output dirs
  if(!dir.exists(paste0(species.dir,"gap_analysis"))){
    dir.create(paste0(species.dir,"gap_analysis"))
  }
  if(!dir.exists(paste0(species.dir,"gap_analysis/insitu"))){
    dir.create(paste0(species.dir,"gap_analysis/insitu"))
  }
  # Save the results
  species.output = paste0(species.dir,"gap_analysis/insitu/")
  write.csv(df, paste0(species.output,"/grs_result.csv"), row.names = FALSE, quote = FALSE)
  if(!is.null(overlay) & !file.exists(paste0(species.output,"/grs_pa_PAs_narea_areakm2.tif"))) {
    writeRaster(overlay, paste0(species.output,"/grs_pa_PAs_narea_areakm2.tif"),overwrite=F)  
  }
}
##########################################    End Functions    ###############################################


##########################################   Start Process    ###############################################

# # Set a configuration to parallel the execution of function
# sfInit(parallel = T, cpus = 20)
# sfLibrary(raster)
# sfLibrary(rgdal)
# sfLibrary(sf)
# sfExportAll()
# sfExport("calculate_grs")
# 
# # Run function in parallel for all species
# result = sfLapply(species.list,calculate_grs)
# 
# # species = species.list[7]
# # lapply("2686262",calculate_grs)
# # result = lapply(species.list,calculate_grs)
# 
# # Get the results for all species
# df <- ldply(result, data.frame)
# write.csv(df, paste0("C:/Users/HSOTELO/Desktop/summary.csv"), row.names = FALSE, quote = FALSE)
