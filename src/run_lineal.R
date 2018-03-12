##########################################  Start Install Packages  ###############################################

# install.packages(c("snowfall","raster","maptools","rgdal","ff","data.table","gtools","velox","PresenceAbsence","rJava","dismo","tidyverse","SDMTools","rgeos","shapefiles","plyr", "sp"))

##########################################   End Install Packages  ###############################################


##########################################  Start Dependences  ###############################################

library(raster)
library(maptools)
library(rgdal)
library(ff)
library(data.table)
library(gtools)
library(velox)
library(PresenceAbsence)
library(rJava)
library(dismo)
library(tidyverse)
library(SDMTools)
library(rgeos)
library(shapefiles)
library(sp)
library(plyr)
library(devtools)
#install_github("DFJL/SamplingUtil")
library(SamplingUtil)

# Load massive climate file
base_dir = "//dapadfs"
repo_dir = "C:/Users/HSOTELO/Desktop/src"
temp_dir= "D:/Temp"
if(!file.exists(temp_dir)){dir.create(temp_dir)}
raster::rasterOptions(tmpdir=temp_dir)


# Load the sources scripts
source.files = list.files(repo_dir, "\\.[rR]$", full.names = TRUE, recursive = T)
source.files = source.files[ !grepl("run", source.files) ]
source.files = source.files[ !grepl("calibration", source.files) ]
source.files = source.files[ !grepl("indicator", source.files) ]
source.files = source.files[ !grepl("to_map", source.files) ]
source.files = source.files[ !grepl("count_records_sp.R", source.files) ]
source.files = source.files[ !grepl("verification_tool.R", source.files) ]
source.files = source.files[ !grepl("sampling.R", source.files) ]

#lapply(source.files, source)
for(i in 1:length(source.files)){
  cat(i,"\n")
  source(source.files[i])
  
}

# Load massive climate file
config(dirs=T)
rst_vx <- readRDS(paste(par_dir,"/biolayer_2.5/climate_vx.RDS",sep=""))
load(file=paste0(par_dir, "/gadm/shapefile/gadm28ISO.RDS"))
config(dirs=F, cleaning=T, insitu=T, exsitu=T, modeling=T, premodeling=T)
##########################################  End Dependences  ###############################################

##########################################  Start Set Parameters  ###############################################

setwd(root)

server.number = "1"
server.species = read.csv(paste0("runs/species/server",server.number,".csv"),sep = ",")

##########################################   End Set Parameters  ###############################################


##########################################   Start Process    ###############################################

# Run function in parallel for all species
result_master = lapply(server.species$taxonkey, master_run)

# Stop cluster
# sfStop()

df = ldply(result_master, data.frame)
write.csv(df, paste0("runs/results/server_",server.number,".csv"), row.names = FALSE, quote = FALSE)

##########################################   End Process    ###############################################