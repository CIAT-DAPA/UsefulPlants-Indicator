# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): status of run

base_dir <- "~/nfs"
repo_dir <- "~/Repositories/aichi13/src"
species <- "2686262"

master_run <- function(species, base_dir, repo_dir) {
  #error message
  message = "OK"
  status = TRUE
  
  tryCatch({
    print(paste0("Start ",species))
  
    #load config function
    source(paste(repo_dir,"/config.R",sep=""))
    
    #step 2.1-clean sea
    source(paste(repo_dir,"/0_cleaning/clean_sea.R",sep=""))
    spp_clean <- clean_sea(species)
    
    #step 2.2-create native area
    source(paste(repo_dir,"/1_modeling/nat_area_shp.R",sep=""))
    narea_shp <- nat_area_shp(species)
    
    #step 2.3-crop bioclim
    source(paste(repo_dir,"/1_modeling/nat_area_mask.R",sep=""))
    crop_bio <- nat_area_mask(species)
    
    #step 3-modeling (#only calibration)
    
    #step 4.1-exsitu gap analysis
    
    #step 4.2-insitu gap analysis
    
    #step 4.3-combine insitu and exsitu
    
    #return status data.frame
    return (data.frame(species = species, status = status, message = message))
  },error = function(e) {
    print(paste0("Error ",species))
    message = e
    status = FALSE
    return(data.frame(species = species, status = status, message = message[[1]]))
  }, finally = {
    print(paste0("End ",species))
  })
}

