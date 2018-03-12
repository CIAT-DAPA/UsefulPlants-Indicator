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
  final_function= character()
  
  tryCatch({
    print(paste0("Start ",species))
  
    #load config function
    #source(paste(repo_dir,"/config.R",sep=""))
    
    #create directories
    #source(paste(repo_dir,"/tools/create_sp_dirs.R",sep=""))
    cat("...creating directories\n")
    spp_dirs <- create_sp_dirs(species)
    final_function = "0.create_sp_dirs was done"
    
    
    #step 2.1-clean sea
    #source(paste(repo_dir,"/0_cleaning/clean_sea.R",sep=""))
    cat("...cleaning species\n")
    spp_clean <- clean_sea(species)
    final_function = "1.clean_sea was done"
    
    #step 2.1.1-sampling ocurrences
    cat("...sampling ocurrence species\n") 
    spp_samp <- sampling(species)
    final_function = "1.1.sampling ocurrences was done"
    
    
    #step 2.2-create native area
    #source(paste(repo_dir,"/1_modeling/nat_area_shp.R",sep=""))
    cat("...creating native area shapefile\n")
    narea_shp <- nat_area_shp(species)
    final_function = "2.nat_area_sh was done"
    
    #step 2.3-crop bioclim
    #source(paste(repo_dir,"/1_modeling/nat_area_mask.R",sep=""))
    cat("...masking bioclim layers to native area\n")
    crop_bio <- nat_area_mask(species)
    final_function = "2.1.nat_area_mask was done"
    
    #step 3-modeling (#only calibration)
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/modeling_approach.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/create_mx_args.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/do_projections.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/evaluating.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_1_maxent/nullModelAUC.R",sep=""))
    #source(paste(repo_dir,"/1_modeling/1_2_alternatives/create_buffers.R",sep=""))
    cat("...maxent modelling\n")
    spmod <- spModeling(species)
    final_function = "3.spModeling was done"
    
    
    #step 4.1-exsitu gap analysis
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/srs.R",sep=""))
    cat("...exsitu srs\n")
    srs_ex <- srs_exsitu(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/grs.R",sep=""))
    cat("...exsitu grs\n")
    grs_ex <- grs_exsitu(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/ers.R",sep=""))
    cat("...exsitu ers\n")
    ers_ex <- ers_exsitu(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/exsitu/fcs.R",sep=""))
    cat("...exsitu fcs\n")
    fcs_ex <- fcs_exsitu(species)
    final_function = "4. fcs_exsitu was calculated"
    
    #step 4.2-insitu gap analysis
    #source(paste(repo_dir,"/2_gap_analysis/insitu/grs.R",sep=""))
    cat("...insitu grs\n")
    grs_in <- calculate_grs(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/insitu/ers.R",sep=""))
    cat("...insitu ers\n")
    ers_in <- calculate_ers(species)
    
    #source(paste(repo_dir,"/2_gap_analysis/insitu/fcs.R",sep=""))
    cat("...insitu fcs\n")
    fcs_in <- calculate_fcs(species)
    final_function = "5. fcs_in was calculated"    
    
    
    #step 4.3-combine insitu and exsitu
    #source(paste(repo_dir,"/2_gap_analysis/combined/fcs_combine.R",sep=""))
    cat("...combine exsitu and insitu fcs\n")
    fcs_comb <- fcs_combine(species)
    final_function = "6. fcs combined was calculated"
    
    
    #return status data.frame
  #  return (data.frame(species = species, status = status, message = message))
  },error = function(e) {
    print(paste0("Error ",species))
    message = e[[1]]
    status = FALSE
  }, finally = {
    print(paste0("End ",species))
    return(data.frame(species = species, status = status, message = message, final_function = final_function))
    
  })
}

