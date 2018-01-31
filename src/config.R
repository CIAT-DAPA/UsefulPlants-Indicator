#Maria Victoria 
#NOTE: base_dir will have to be specified in the master code

config <- function(dirs=F, cleaning=F, insitu=F, exsitu=F, modeling=F) {
  #version
  run_version <<- "v1"
  
  ###FOLDERS FOR RUNNING##
  if (dirs) {
    root<<-paste(base_dir,"/workspace_cluster_9/Aichi13",sep="")
    gap_dir<<-paste0(root, "/gap_analysis");if(!file.exists(gap_dir)){dir.create(gap_dir)}
    par_dir<<-paste0(root, "/parameters");if(!file.exists(par_dir)){dir.create(par_dir)}
    occ_dir<<-paste0(par_dir,"/","occurrences");if(!file.exists(occ_dir)){dir.create(occ_dir)}
    scr_dir<-paste0(gap_dir,"/","_scripts");if(!file.exists(scr_dir)){dir.create(scr_dir)}
  }
  
  ####################################### 0.CLEANING ################################################
  # used by functions: clean_sea.R  and split_occs_srs.R #####
  if (cleaning) {
    require(raster)
    ##INPUT FILES TO CLEAN SEA##
    folderin <<- paste0(occ_dir, "/raw")
    
    ##COUNTRIES SHAPEFILES##
    countries_sh <<- shapefile(paste0(par_dir, "/gadm/shapefile/gadm28ISO.shp")) 
    
    ##OUTPUT FOLDER IN clean_sea FUNCTION, AND INPUT IN split_occs_srs FUNCTION##
    folderout <<- paste0(occ_dir,"/","no_sea")
    if(!file.exists(folderout)){dir.create(folderout)}
    
    }
                      
  ####################################### 1. MODELING ################################################
  #it's used by the functions: ElevationSlope.R , FunctionMaxent.R
  
  if(modeling){
    clim_dir <<- paste0(par_dir, "/biolayer_2.5/raster")
    #bio <<- list.files(bio_dir)
    #elev <- raster(paste0(par_dir,"/biolayer_2.5/raster/",bio))
    msk <- raster(paste0(par_dir,"/world_mask/raster/mask.tif"))
    rst_dir <-clim_dir
    
  }
  
  
  
  ####################################### 2. GAP ANALYSIS ################################################
 
   ######## EX SITU #######
   #used by functions: CropMask.R, BufferPoints.R
  if (exsitu) {
     folderout <<- paste0(occ_dir,"/","no_sea")
     clim_dir <<- paste0(par_dir, "/biolayer_2.5/raster") 
     #msk <- raster(paste0(par_dir,"/world_mask/raster/mask.tif")) 
   }
  
  ######## IN SITU #######
  #used by functions: ers.R , grs.R and fcs.R
  
  if (insitu) {
    #GLOBAL CONFIGURATION
    
    rasterOptions(tmpdir = "D:/TEMP/hsotelo")
    
    species.dir <<- gap_dir
    specie <<-list.files(species.dir)
    species.list <<- list.dirs(species.dir,full.names = FALSE, recursive = FALSE)
    specie.dir <<- paste0(species.dir, specie, "/", run_version, "/")
    
    #PATH TO PROTECTED AREAS RASTER
    pa.path <<- paste0(par_dir, "/protected_areas/raster/areas_protected_geographic.tif")
    pa.raster <<- raster(pa.path)
    
    #PATH TO MODELING ALTERNATIVES
    alternative.path <<- paste0(specie.dir, "modelling/alternatives/buffer_total.pdf")
    maxent.path <<- paste0(specie.dir,"modelling/maxent/concenso_mss.tif")
    
    #LOAD THE MASK OF THE SPECIE NATIVE AREA
    specie.mask.path <<- paste0(specie.dir,"bioclim/crop_narea.rds")
    
    #OUTPUT FOLDERS
    
    if(!dir.exists(paste0(specie.dir,"gap_analysis"))){
      dir.create(paste0(specie.dir,"gap_analysis"))
    }
    if(!dir.exists(paste0(specie.dir,"gap_analysis/insitu"))){
      dir.create(paste0(specie.dir,"gap_analysis/insitu"))
    }
    species.output <<- paste0(specie.dir, "gap_analysis/insitu")
    
    #PATH TO RESULTS INSITU ANALYSIS
    grs.path <- paste0(specie.dir, "gap_analysis/insitu/grs_result.csv")
    ers.path <- paste0(specie.dir, "gap_analysis/insitu/ers_result.csv")
   
  }
  
  ######## BOTH IN-SITU AND EX-SITU #######
  if (insitu | exsitu) {
    #PATH TO WWF WORLD ECOREGIONS
    eco.path <<-paste0(par_dir, "/ecosystems/raster/wwf_eco_terr_geo.tif")
    eco.raster <-raster(eco.path)
  }
}
