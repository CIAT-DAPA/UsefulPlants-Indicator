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

# This function calculate the ERS by every species.
# It searches the specie, then load the specie distribution from raster file. 
# With the specie distribution intersectes with the native area, then with ecosystems raster, with this
# new raster makes a new intersectes with protected areas and calculate the number of ecosystems
# in the specie distribution and number ecosystem into protected areas
# It creates three files with the result (ers_result.csv, ers_specie_ecosystems.tif, ers_specie_ecosystems_pa.tif)
# @param (string) specie: Code of the specie
# @param (bool) debug: Specifies whether to save the raster files. By default is FALSE
# @return (data.frame): This function return a dataframe with the results about the process. 
#                       It has three columns, the first has the specie code; the second has a status
#                       of process, if value is "TRUE" the process finished good, if the result is "FALSE"
#                       the process had a error; the third column has a description about process
calculate_ers = function(species, debug=F){
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
    
    #load counts
    sp_counts <- read.csv(paste(gap_dir,"/",species,"/counts.csv",sep=""),sep="\t")
    
    if (file.exists(paste(occ_dir,"/no_sea/",species,".csv",sep="")) & sp_counts$totalUseful != 0) {
      # Validation if the maxent model is good or not
      # to do the insitu gap analysis
      alternative.path = paste0(species.dir,"modeling/alternatives/ca50_total_narea.tif")
      maxent.path = paste0(species.dir,"modeling/maxent/spdist_thrsld.tif")
      model.selected = read.csv(paste0(species.dir,"modeling/maxent/eval_metrics.csv"), header = T, sep=",")
      if(model.selected$VALID){
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
      # Remove differents values from raster to get only the native area
      #species.mask[which(!is.na(species.mask[]))]<-1
      species.mask <- raster(paste(species.dir,"bioclim/narea_mask.tif",sep=""))
      
      #print("Loaded the native area of the species (mask)")
      
      # Intersect between species distribution and mask
      origin(species.distribution) <- origin(species.mask)
      overlay.distribution <- species.distribution * species.mask
      
      # Intersect between species distribution and ecosystem
      origin(eco.raster) <- origin(overlay.distribution)
      overlay.eco <- eco.raster * overlay.distribution
      
      #print("Intersected the species distribution and ecosystem")
      
      # Intersect between overlay eco specie  and protected areas
      origin(pa.raster) <- origin(overlay.eco)
      overlay.eco.pa = pa.raster * overlay.eco
      
      #print("Intersected the overlapping (species distribution and ecosystems) and global protected areas")
      
      # Intersect between for the species distribution and intersect
      eco.species.distribution.count = length(unique(overlay.eco[],na.rm=T))
      eco.species.distribution.pa.count  = length(unique(overlay.eco.pa[],na.rm=T))
      
      # Calculate proportion number ecosystems
      proportion = min(c(100, (eco.species.distribution.pa.count / (eco.species.distribution.count)) * 100))
      
      #print("Calculated ecosystems numbers")
    } else {
      proportion <- 0
      eco.species.distribution.count <- eco.species.distribution.pa.count <- NA
    }
    
    # Join the results
    df <- data.frame(ID=species, SPP_N_ECO = eco.species.distribution.count, SPP_WITHIN_PA_N_ECO = eco.species.distribution.pa.count, ERS = proportion)
    
    # Save the results
    if (debug) {
      save_results_ers(df, overlay.eco, overlay.eco.pa, species.dir)
    } else {
      save_results_ers(df, NULL, NULL, species.dir)
    }
    return (data.frame(species = species, status = status, message = message))
  },
  error = function(e) {
    
    message = e
    status = FALSE
    
    # Join the results
    df <- data.frame(ID=species, SPP_N_ECO = NA, SPP_WITHIN_PA_N_ECO = NA, ERS = NA)
    
    # Save the results
    save_results_ers(df, NULL, NULL, species.dir, debug)
    
    return (data.frame(species = species, status = status, message = message[[1]]))
  }, finally = {
    
    # Remove temp files
    removeTmpFiles(h=0)
    
    #print(paste0("End ",species))
  })
}

# This function save the results of analysis grs.
# This saves the raster of the intersect and analysis table
# @param (data.frame) df: data.frame with the analysis of protected areas
# @param (raster) overlay.ecosystem: Intersect between species distribution and ecosystem
# @param (raster) overlay.pa: Intersect between species distribution ecosystem and protected areas
# @param (string) species.dir: Path where the files should be saved
# @return (void)
save_results_ers = function(df,overlay.ecosystem, overlay.pa, species.dir){
  # Create output dirs
  if(!dir.exists(paste0(species.dir,"gap_analysis"))){
    dir.create(paste0(species.dir,"gap_analysis"))
  }
  if(!dir.exists(paste0(species.dir,"gap_analysis/insitu"))){
    dir.create(paste0(species.dir,"gap_analysis/insitu"))
  }
  # Save the results
  species.output = paste0(species.dir,"gap_analysis/insitu/")
  write.csv(df, paste0(species.output,"/ers_result.csv"), row.names = FALSE, quote = FALSE)
  if(!is.null(overlay.ecosystem)){
    writeRaster(overlay.ecosystem, paste0(species.output,"/ers_pa_narea_ecosystems.tif"),overwrite=T)  
  }
  if(!is.null(overlay.pa)){
    writeRaster(overlay.pa, paste0(species.output,"/ers_pa_PAs_narea_ecosystems.tif"),overwrite=T)  
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
# # species = species.list[7]
# # lapply(species.list[7],calculate_ers)
# # result = lapply(species.list,calculate_ers)
# 
# # Get the results for all species
# df <- ldply(result, data.frame)
# write.csv(df, paste0("C:/Users/HSOTELO/Desktop/summary.csv"), row.names = FALSE, quote = FALSE)
