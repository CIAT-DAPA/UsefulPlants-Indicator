##########################################  Start Install Packages  ###############################################

# install.packages(c("raster","sp","rgdal","rgeos","sf","shapefiles", "snowfall"))

##########################################   End Install Packages  ###############################################


##########################################  Start Requirements  ###############################################

# Load the libraries
# require(raster)
require(rgdal)
require(sf)
# library(snowfall)
# library(plyr)

##########################################   End Requirements  ###############################################


##########################################  Start Set Parameters  ###############################################

# Global configuration
# rasterOptions(tmpdir = "D:/TEMP/hsotelo")
# setwd("//dapadfs/Projects_cluster_9/aichi/")

# # Set the path of the file with global protected areas
# pa.path = "parameters/protected_areas/raster/areas_protected_geographic.tif"
# # Load the raster file with global protected areas
# pa.raster = raster(pa.path)
# # Remove the zeros (0) from raster
# pa.raster[which(pa.raster[] == 0)] <- NA
# Load the species list to execute process
# species.dir = "gap_analysis/"
# species.list = list.dirs(species.dir,full.names = FALSE, recursive = FALSE)
# # Set the path of the file with global ecosystem
# eco.path = "parameters/ecosystems/raster/wwf_eco_terr_geo.tif"
# eco.raster = raster(eco.path)

##########################################   End Set Parameters  ###############################################


##########################################   Start Functions    ###############################################

# This function calculate the ERS by every specie.
# It searches the specie, then load the specie distribution from raster file. 
# With the specie distribution intersectes with the native area, then with ecosystems raster, with this
# new raster makes a new intersectes with protected areas and calculate the number of ecosystems
# in the specie distribution and number ecosystem into protected areas
# It creates three files with the result (ers_result.csv, ers_specie_ecosystems.tif, ers_specie_ecosystems_pa.tif)
# @param (string) specie: Code of the specie
# @return (data.frame): This function return a dataframe with the results about the process. 
#                       It has three columns, the first has the specie code; the second has a status
#                       of process, if value is "TRUE" the process finished good, if the result is "FALSE"
#                       the process had a error; the third column has a description about process
calculate_ers = function(specie){

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
    #   df <- data.frame(specie_distribution_ecosystem_count = c(0), specie_distribution_ecosystem_pa_count = c(0), proportion = c(0))
    #   # Save the results
    #   save_results_ers(df,NULL,NULL, specie.dir)
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
    
    # Intersect between specie distribution and ecosystem
    origin(eco.raster) <- origin(overlay.distribution)
    overlay.eco = eco.raster * overlay.distribution
    
    print("Intersected the specie distribution and ecosystem")
    
    # Intersect between overlay eco specie  and protected areas
    origin(pa.raster) <- origin(overlay.eco)
    overlay.eco.pa = pa.raster * overlay.eco
    
    print("Intersected the overlapping (specie distribution and ecosystems) and global protected areas")
    
    # Intersect between for the specie distribution and intersect
    eco.specie.distribution.count = length(unique(overlay.eco))
    eco.specie.distribution.pa.count  = length(unique(overlay.eco.pa))
    
    # Calculate proportion number ecosystems
    proportion = (eco.specie.distribution.pa.count / (eco.specie.distribution.count) ) * 100
    
    print("Calculated ecosystems numbers")
    
    # Join the results
    df <- data.frame(specie_distribution_ecosystem_count = eco.specie.distribution.count, specie_distribution_ecosystem_pa_count = eco.specie.distribution.pa.count, proportion = proportion)
    
    # Save the results
    save_results_ers(df,overlay.eco,overlay.eco.pa, specie.dir)
    return (data.frame(specie = specie, status = status, message = message))
  },
  error = function(e) {
    
    message = e
    status = FALSE
    
    # Join the results
    df <- data.frame(specie_distribution_ecosystem_count = c(0), specie_distribution_ecosystem_pa_count = c(0), proportion = c(0))
    
    # Save the results
    save_results_ers(df,NULL,NULL, specie.dir)
    
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
# @param (raster) overlay.ecosystem: Intersect between specie distribution and ecosystem
# @param (raster) overlay.pa: Intersect between specie distribution ecosystem and protected areas
# @param (string) specie.dir: Path where the files should be saved
# @return (void)
save_results_ers = function(df,overlay.ecosystem, overlay.pa, specie.dir){
  # Create output dirs
  if(!dir.exists(paste0(specie.dir,"gap_analysis"))){
    dir.create(paste0(specie.dir,"gap_analysis"))
  }
  if(!dir.exists(paste0(specie.dir,"gap_analysis/insitu"))){
    dir.create(paste0(specie.dir,"gap_analysis/insitu"))
  }
  # Save the results
  specie.output = paste0(specie.dir,"gap_analysis/insitu/")
  write.csv(df, paste0(specie.output,"/ers_result.csv"), row.names = FALSE, quote = FALSE)
  if(!is.null(overlay.ecosystem)){
    writeRaster(overlay.ecosystem, paste0(specie.output,"/ers_specie_ecosystems.tif"),overwrite=T )  
  }
  if(!is.null(overlay.pa)){
    writeRaster(overlay.pa, paste0(specie.output,"/ers_specie_ecosystems_pa.tif"),overwrite=T )  
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
# sfExport("calculate_ers")
# 
# # Run function in parallel for all species
# result = sfLapply(species.list,calculate_ers)
# 
# # specie = species.list[7]
# # lapply(species.list[7],calculate_ers)
# # result = lapply(species.list,calculate_ers)
# 
# # Get the results for all species
# df <- ldply(result, data.frame)
# write.csv(df, paste0("C:/Users/HSOTELO/Desktop/summary.csv"), row.names = FALSE, quote = FALSE)
