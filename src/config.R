#Maria Victoria 
#NOTE: base_dir will have to be specified in the master code

config <- function(dirs=F, cleaning=F, insitu=F, exsitu=F) {
  #version
  run_version <<- "v1"
  
  ###FOLDERS FOR RUNNING##
  if (dirs) {
    root<<-paste(base_dir,"/workspace_cluster_9/Aichi13",sep="")
    gap_dir<<-paste0(root, "/gap_analysis");if(!file.exists(gap_dir)){dir.create(gap_dir)}
    par_dir<<-paste0(root, "/parameters");if(!file.exists(par_dir)){dir.create(par_dir)}
    occ_dir<<-paste0(par_dir,"/","occurrences");if(!file.exists(occ_dir)){dir.create(occ_dir)}
  }
  
  ####################################### 1.CLEANING ################################################
  # used by functions: clean_sea.R  and split_occs_srs.R #####
  if (cleaning) {
    require(raster)
    ##INPUT FILES TO CLEAN SEA##
    folderin <<- paste0(occ_dir, "/raw")
    
    ##COUNTRIES SHAPEFILES##
    countries_sh <<- shapefile(paste0(par_dir, "/gadm/shapefile/gadm28ISO.shp")) 
    
    ##OUTPUT FOLDER##
    folderout <<- paste0(occ_dir,"/","no_sea")
    if(!file.exists(folderout)){dir.create(folderout)}
  }
                      
  ####################################### 2. GAP ANALYSIS ################################################
  ######## EX SITU #######
  if (exsitu) {
     bio_dir <<- paste0(par_dir, "/biolayer_2.5/raster")
    
  }
  
  ######## IN SITU #######
  if (insitu) {
    species.dir <<- gap_dir
    
    #PATH TO PROTECTED AREAS RASTER
    pa.path <<- paste0(par_dir, "/protected_areas/raster/areas_protected_geographic.tif")
    pa.raster <<- raster(pa.path)
  }
  
  ######## BOTH IN-SITU AND EX-SITU #######
  if (insitu | exsitu) {
    #PATH TO WWF WORLD ECOREGIONS
    eco.path <<-paste0(par_dir, "/ecosystems/raster/wwf_eco_terr_geo.tif")
    eco.raster = raster(eco.path)
  }
}
