# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): status of run

base_dir <- "~/nfs"
source("~/Repositories/aichi13/src/config.R")
species <- "2686262"

master_run <- function(species, base_dir) {
  #load config
  config(dirs=T)
  
  #step 1-create native area
  
  #step 2-crop bioclim
  
  #step 3-modeling
  
  #step 4.1-exsitu gap analysis
  
  #step 4.2-insitu gap analysis
  
  #step 4.3-combine insitu and exsitu
  
}

