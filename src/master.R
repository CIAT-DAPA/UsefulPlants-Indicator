# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): status of run

base_dir <- "~/nfs"
repo_dir <- "~/Repositories/aichi13/src"
species <- "2686262"

master_run <- function(species, base_dir, repo_dir) {
  #load config
  source(paste(repo_dir,"/config.R",sep=""))
  config(dirs=T)
  
  #step 0-clean sea
  
  #step 1-create native area
  #source(paste(repo_dir,"/1_modeling/nat_area_mask.R",sep=""))
  #nat_area_shp <- somefunction(xx)
  
  #step 2-crop bioclim
  source(paste(repo_dir,"/1_modeling/nat_area_mask.R",sep=""))
  cropbio <- nat_area_mask(species)
  
  #step 3-modeling
  
  #step 4.1-exsitu gap analysis
  
  #step 4.2-insitu gap analysis
  
  #step 4.3-combine insitu and exsitu
  
}

