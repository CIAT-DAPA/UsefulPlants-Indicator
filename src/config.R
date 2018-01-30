##REQUIRE##

require(raster)

###FOLDERS FOR RUNNING##

root<-"//dapadfs/Workspace_cluster_9/Aichi13"
gap_dir<-paste0(root, "/gap_analysis");if(!file.exists(gap_dir)){dir.create(gap_dir)}
par_dir<-paste0(root, "/parameters");if(!file.exists(par_dir)){dir.create(par_dir)}
occ_dir<-paste0(par_dir,"/","occurrences");if(!file.exists(occ_dir)){dir.create(occ_dir)}
scr_dir<-paste0(gap_dir,"/","_scripts");if(!file.exists(scr_dir)){dir.create(scr_dir)}

####################################### 1.CLEANING ################################################

                                ###### clean_sea.R  and split_occs_srs.R #####
##INPUT FILES TO CLEAN SEA##

folderin <- paste0(occ_dir, "/raw")

##COUNTRIES SHAPEFILES##

countries_sh <- shapefile(paste0(par_dir, "/gadm/shapefile/gadm28ISO.shp")) 

##OUTPUT FOLDER##

folderout <- paste0(occ_dir,"/","no_sea")

if(!file.exists(folderout)){
  dir.create(folderout)
  }

                    
####################################### 2. GAP ANALYSIS ################################################

######## insitu #######

pa.path = paste0(par_dir, "/protected_areas/raster/areas_protected_geographic.tif")

pa.raster = raster(pa.path)












####################################### PROTECTED AREAS ################################################




eco.path = "parameters/ecosystems/raster/wwf_eco_terr_geo.tif"
eco.raster = raster(eco.path)

