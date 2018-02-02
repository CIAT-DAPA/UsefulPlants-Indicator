# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): status of run

#base_dir <- "~/nfs"
#repo_dir <- "~/Repositories/aichi13/src"
#species <- "2686262"

master_run <- function(species) {
  #error message
  message = "OK"
  status = TRUE
  
  tryCatch({
    print(paste0("Start ",species))
  
    #load config function
    #source(paste(repo_dir,"/config.R",sep=""))
    
    #step 2.1-clean sea
    #source(paste(repo_dir,"/0_cleaning/clean_sea.R",sep=""))
    spp_clean <- clean_sea(species)
    
    #step 2.2-create native area
    #source(paste(repo_dir,"/1_modeling/nat_area_shp.R",sep=""))
    narea_shp <- nat_area_shp(species)
    
    #step 2.3-crop bioclim
    #source(paste(repo_dir,"/1_modeling/nat_area_mask.R",sep=""))
    crop_bio <- nat_area_mask(species)
    
    #step 3-modeling (#only calibration)
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/modeling_approach.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/create_mx_args.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/do_projections.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/evaluating.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/nullModelAUC.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_2_alternatives/create_buffers.R",sep=""))
    spmod <- spModeling(species)
    
    #step 4.1-exsitu gap analysis
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/srs.R",sep=""))
    srs_ex <- srs_exsitu(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/grs.R",sep=""))
    grs_ex <- grs_exsitu(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/ers.R",sep=""))
    ers_ex <- ers_exsitu(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/fcs.R",sep=""))
    fcs_ex <- fcs_exsitu(species)
    
    #step 4.2-insitu gap analysis
    #source(paste(repo_dir,"/2_gap_analysis/insitu/grs.R",sep=""))
    grs_in <- calculate_grs(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/insitu/ers.R",sep=""))
    ers_in <- calculate_ers(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/insitu/fcs.R",sep=""))
    fcs_in <- calculate_fcs(species)
    
    #step 4.3-combine insitu and exsitu
    #source(paste(repo_dir,"/2_gap_analysis/combined/fcs_combine.R",sep=""))
    fcs_comb <- fcs_combine(species)
    
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

