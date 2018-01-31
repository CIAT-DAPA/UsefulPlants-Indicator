##########################################  Start Install Packages  ###############################################

# install.packages(c("raster","sp","rgdal","rgeos","sf","shapefiles", "snowfall"))

##########################################   End Install Packages  ###############################################


##########################################  Start Requirements  ###############################################

# Load the libraries
# require(raster)
require(rgdal)
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

# This function calculate the GRS by every specie.
# It searches the specie, then load the specie distribution from raster file. 
# With the specie distribution intersectes with the native area, then with the protected areas raster and calculate
# the area from the specie distribution, overlay and the proportion between both.
# It creates two files with the result (grs_result.csv, grs_intersect.tif)
# @param (string) specie: Code of the specie
# @return (data.frame): This function return a dataframe with the results about the process. 
#                       It has three columns, the first has the specie code; the second has a status
#                       of process, if value is "TRUE" the process finished good, if the result is "FALSE"
#                       the process had a error; the third column has a description about process
calculate_grs = function(specie){
  
  # It is a global factor to limits the goal of conservation to a percentage
  # 0 <= a <= 1
  a = 1.0;
  
  # Defined vars about process
  message = "Ok"
  status = TRUE
  
  # Set the global
  specie.dir = paste0(species.dir, specie, "/", run_version, "/")
  specie.distribution = NULL
  
  tryCatch({
    print(paste0("Start ",specie))
    
    # Validation if the maxent model is good or not
    # to do the gap analysis insitu
    alternative.path = paste0(specie.dir,"modeling/alternatives/buffer_total.tif")
    maxent.path = paste0(specie.dir,"modeling/maxent/concenso_mss.tif")
    model.selected = read.csv(paste0(specie.dir,"modeling/maxent/eval_metrics.csv"), header = T, sep=",")
    if(model.selected$VALID == TRUE){
      specie.distribution = raster(maxent.path)
    } else{
      specie.distribution = raster(alternative.path) 
    }
    # else{
    #   print("The specie doesn't have model distribution")
    #   # Join the results
    #   df <- data.frame(specie_distribution_a = c(0), species_protected_area_a = c(0), units_a = c("km2"), proportion = c(0), units_proportion = c("percentage"))
    #   # Save the results
    #   save_results_grs(df,NULL,specie.dir)
    #   return (data.frame(specie = specie, status = status, message = "The specie does not have distribution model"))
    # }
    # Remove the zeros (0) from raster
    specie.distribution[which(specie.distribution[]==0)]<-NA
    
    print("Loaded the specie distribution file (raster)")
    
    # Load the specie mask of native area
    specie.mask.path = paste0(specie.dir,"bioclim/crop_narea.RDS")
    load(specie.mask.path)
    specie.mask = biolayers_cropc[[1]]
    # Remove differents values from raster to get only the native area
    specie.mask[which(!is.na(specie.mask[]))]<-1
    
    print("Loaded the native area of the specie (mask)")
    
    # Intersect between specie distribution and mask
    origin(specie.distribution) <- origin(specie.mask)
    overlay.distribution = specie.distribution * specie.mask
    
    # Intersect between specie distribution (native area) and protected areas
    origin(pa.raster) <- origin(overlay.distribution)
    overlay = pa.raster * overlay.distribution
    
    # Intersect between specie in protected areas and world mask in areas
    origin(world.area) <- origin(overlay)
    overlay.intersect = world.area * overlay
    
    # Intersect between specie distribution areas and world mask in areas
    origin(world.area) <- origin(specie.distribution)
    overlay.specie.area = world.area * specie.distribution
    
    print("Intersected the specie distribution (native area) and global protected areas")
    
    # # Get pixels with data from intersect
    # a = which(!is.na(overlay[]))
    # # Get pixels with data from specie distribution
    # b = which(!is.na(overlay.distribution[]))
    # 
    # # Calculating the area in kilometer for each pixel
    # area = res(overlay.distribution)[1] * res(overlay.distribution)[2]
    # gra = 111.11*111.11
    # res = area * gra 
    # 
    # Calculate areas for the specie distribution and intersect
    # overlay.area <- length(a) * res
    # specie.area <- length(b) * res
    
    overlay.area = sum(overlay.intersect[],na.rm=T)
    specie.area = sum(overlay.specie.area[], na.rm=T) 
    # Calculate proportion area
    proportion = (overlay.area / (a*specie.area) ) * 100
    
    print("Calculated the areas and proportions")
    
    # Join the results
    df <- data.frame(specie_distribution_a = specie.area, species_protected_area_a = overlay.area, units_a = c("km2"), proportion = proportion, units_proportion = c("percentage"))
    
    # Save the results
    save_results_grs(df,overlay.intersect, specie.dir)
    return (data.frame(specie = specie, status = status, message = message))
  },
  error = function(e) {
    
    message = e
    status = FALSE
    
    # Join the results
    df <- data.frame(specie_distribution_a = c(0), species_protected_area_a = c(0), units_a = c("km2"), proportion = c(0), units_proportion = c("percentage"))
    
    # Save the results
    save_results_grs(df,NULL, specie.dir)
    
    return (data.frame(specie = specie, status = status, message = message[[1]]))
  }, finally = {
    
    # Remove temp files
    removeTmpFiles(h=0)
    
    print(paste0("End ",specie))
  })
}

# This function save the results of analysis grs.
# This saves the raster of the intersect and analysis table
# @param (data.frame) df; Data.frame with the analysis of protected areas
# @param (raster) overlay: Intersect between specie distribution and protected areas
# @param (string) specie.dir: Path where the files should be saved
# @return (void)
save_results_grs = function(df,overlay,specie.dir){
  # Create output dirs
  if(!dir.exists(paste0(specie.dir,"gap_analysis"))){
    dir.create(paste0(specie.dir,"gap_analysis"))
  }
  if(!dir.exists(paste0(specie.dir,"gap_analysis/insitu"))){
    dir.create(paste0(specie.dir,"gap_analysis/insitu"))
  }
  # Save the results
  specie.output = paste0(specie.dir,"gap_analysis/insitu/")
  write.csv(df, paste0(specie.output,"/grs_result.csv"), row.names = FALSE, quote = FALSE)
  if(!is.null(overlay)){
    writeRaster(overlay, paste0(specie.output,"/grs_intersect.tif"),overwrite=T )  
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
# # specie = species.list[7]
# # lapply("2686262",calculate_grs)
# # result = lapply(species.list,calculate_grs)
# 
# # Get the results for all species
# df <- ldply(result, data.frame)
# write.csv(df, paste0("C:/Users/HSOTELO/Desktop/summary.csv"), row.names = FALSE, quote = FALSE)
