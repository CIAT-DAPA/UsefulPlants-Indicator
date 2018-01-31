##########################################  Start Install Packages  ###############################################


##########################################   End Install Packages  ###############################################


##########################################  Start Requirements  ###############################################


##########################################   End Requirements  ###############################################


##########################################  Start Set Parameters  ###############################################

# Global configuration
# setwd("//dapadfs/Projects_cluster_9/aichi/")

# # Set the path of the file with global protected areas
# pa.path = "parameters/protected_areas/raster/areas_protected_geographic.tif"
# # Load the raster file with global protected areas
# pa.raster = raster(pa.path)
# # Remove the zeros (0) from raster
# pa.raster[which(pa.raster[] == 0)] <- NA
# Load the species list to execute process
# species.dir = "ENMeval_4/outputs/"
# species.list = list.dirs(species.dir,full.names = FALSE, recursive = FALSE)
# # Set the path of the file with global ecosystem
# eco.path = "parameters/ecosystems/raster/wwf_eco_terr_geo.tif"
# eco.raster = raster(eco.path)

##########################################   End Set Parameters  ###############################################


##########################################   Start Functions    ###############################################

# This function calculate the FCS by every specie.
# It searches the specie, then load the result from grs and ers (insitu) and calculate
# the FCS
# @param (string) specie: Code of the specie
# @return (data.frame): This function return a dataframe with the results about the process. 
#                       It has three columns, the first has the specie code; the second has a status
#                       of process, if value is "TRUE" the process finished good, if the result is "FALSE"
#                       the process had a error; the third column has a description about process
calculate_fcs = function(specie){
  
  # Defined vars about process
  message = "Ok"
  status = TRUE
  
  # Set the global
  specie.dir = paste0(species.dir, specie, "/", run_version, "/")
  
  tryCatch({
    print(paste0("Start ",specie))
  
    # Read results of insitu analysis
    grs.path = paste0(specie.dir, "gap_analysis/insitu/grs_result.csv")
    ers.path = paste0(specie.dir, "gap_analysis/insitu/ers_result.csv")
    
    grs = read.csv(grs.path,header = T, sep=",")
    ers = read.csv(ers.path,header = T, sep=",")
    
    print("Loaded files")
    
    grs.value = grs$proportion
    ers.value = ers$proportion
    fcs.value = (grs.value + ers.value)/2
    
    print("Calculated FCS")
    
    # Join the results
    df <- data.frame(ID = specie, GRS = grs.value, ERS = ers.value, FCS = fcs.value)
    
    # Save the results
    save_results_fcs(df,specie.dir)
    return (data.frame(specie = specie, status = status, message = message))
  },
  error = function(e) {
    
    message = e
    status = FALSE
    
    # Join the results
    df <- data.frame(ID = c(specie), GRS = c(0), ERS = c(0), FCS = c(0))
    
    # Save the results
    save_results_fcs(df,specie.dir)
    
    return (data.frame(specie = specie, status = status, message = message[[1]]))
  }, finally = {
    
    # Remove temp files
    removeTmpFiles(h=0)
    
    print(paste0("End ",specie))
  })
}

# This function save the results of analysis ers.
# @param (data.frame) df; Data.frame with the analysis of FCS
# @param (string) specie.dir: Path where the files should be saved
# @return (void)
save_results_fcs = function(df,specie.dir){
  # Create output dirs
  if(!dir.exists(paste0(specie.dir,"gap_analysis"))){
    dir.create(paste0(specie.dir,"gap_analysis"))
  }
  if(!dir.exists(paste0(specie.dir,"gap_analysis/insitu"))){
    dir.create(paste0(specie.dir,"gap_analysis/insitu"))
  }
  # Save the results
  specie.output = paste0(specie.dir,"gap_analysis/insitu/")
  write.csv(df, paste0(specie.output,"/summary.csv"), row.names = FALSE, quote = FALSE)
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
