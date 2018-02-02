##########################################  Start Install Packages  ###############################################

# install.packages(c("snowfall","raster","maptools","rgdal","ff","data.table","gtools","velox","PresenceAbsence","dismo","tidyverse","SDMTools","rgeos","shapefiles","ldply"))

##########################################   End Install Packages  ###############################################


##########################################  Start Dependences  ###############################################

library(snowfall)
library(raster)
library(maptools)
library(rgdal)
library(ff)
library(data.table)
library(gtools)
library(velox)
library(PresenceAbsence)
library(dismo)
library(tidyverse)
library(SDMTools)
library(rgeos)
library(shapefiles)
library(ldply)

# Load the sources scripts
repo.source = "G:/CIAT/Code/Aichi/aichi13/src"
source.files = list.files(repo.source, "\\.[rR]$", full.names = TRUE, recursive = T)
source.files = source.files[ !grepl("tools", source.files) ]
source.files = source.files[ !grepl("run", source.files) ]
lapply(source.files, source)

# Load massive climate file
config(dirs=T)
rst_vx <- readRDS(paste(par_dir,"/biolayer_2.5/climate_vx.RDS",sep=""))
load(file=paste0(par_dir, "/gadm/shapefile/gadm28ISO.RDS"))

#############
#############################  End Dependences  ###############################################

##########################################  Start Set Parameters  ###############################################

setwd("//dapadfs/Workspace_cluster_9/Aichi13/")

server.number = "1"
server.species = read.csv(paste0("runs/species/server_",server.number,".csv"),sep = ",")

cores = 2
sfInit(parallel = T, cpus = cores)


##########################################   End Set Parameters  ###############################################


##########################################   Start Exports    ###############################################

# Export libraries
sfLibrary(snowfall)
sfLibrary(raster)
sfLibrary(maptools)
sfLibrary(rgdal)
sfLibrary(ff)
sfLibrary(data.table)
sfLibrary(gtools)
sfLibrary(velox)
sfLibrary(PresenceAbsence)
sfLibrary(dismo)
sfLibrary(tidyverse)
sfLibrary(SDMTools)
sfLibrary(rgeos)
sfLibrary(shapefiles)

sfExportAll()

# Export sources scripts
lapply(source.files, sfSource)

# Export functions

# config
sfExport("config")

# master
sfExport("master_run")

# 0_cleaning
sfExport("clean_sea")

# 1_modeling
sfExport("nat_area_mask")

sfExport("nat_area_shp")

# 1_1_maxent
sfExport("make.projection")

sfExport("metrics_function")
sfExport("evaluate_function")

sfExport("spModeling")

sfExport("null_model_AUC")

# 1_2_alternatives
sfExport("create_buffers")

# 2_gap_analysis / combined
sfExport("fcs_combine")

# 2_gap_analysis / exsitu
sfExport("ers_exsitu")

sfExport("fcs_exsitu")

sfExport("grs_exsitu")

sfExport("srs_exsitu")

# 2_gap_analysis / insitu
sfExport("calculate_ers")
sfExport("save_results_ers")

sfExport("calculate_fcs")
sfExport("save_results_fcs")

sfExport("calculate_grs")
sfExport("save_results_grs")

# 3_indicator
sfExport("calc_indicator")

sfExport("select_spp_indicator")

sfExportAll()

# Export variables
sfExport( "rst_vx", local=FALSE )
sfExport( "countries_sh", local=FALSE )

sfExportAll()

##########################################   End Exports    ###############################################


##########################################   Start Process    ###############################################

# Run function in parallel for all species
result_master = sfLapply(server.species$ID, master_run)

# Stop cluster
sfStop()

df = ldply(result_master, data.frame)
write.csv(df, paste0("runs/results/server_",server.number,".csv"), row.names = FALSE, quote = FALSE)

##########################################   End Process    ###############################################