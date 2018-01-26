#-------------------------------------
#Function for removing sea coordinates
#Jonatan Soto
#Based on Jeison & Alejandra advises
#-------------------------------------

require(raster)
require(maptools)
require(dplyr)
require(parallel)
require(microbenchmark)

folderin <- "//dapadfs/Projects_cluster_9/aichi/occurrences_GH/"
ready <- paste0(folderin,"cleansea/")

countries_sh <- shapefile("//dapadfs/Projects_cluster_9/aichi/world_mask/all_countries.shp") ##mask shp
files <- list.files(ready, pattern = '\\.csv$')



cleansea <- function(files){
  
  spp<- read.csv(paste0(ready, files), header = TRUE) ##read file
  cat("loading", files, "file", "\n")
  coordinates(spp)= ~lon+lat ###to rasterdataframe
  crs(spp)= crs(countries_sh)####add to mask
  over=over(spp, countries_sh) ### over()
  country_name=over$ISO2####select ISO for match
  rm(over)
  k=as.numeric(is.na(country_name))#### identify NA's (coords over the sea)
  j= which(as.character(country_name)!= as.character(spp$country))##### different countrys (border effect)
  cbind(country_name, spp$country) [j,]
  cat("Removing NA's on", files, "file", "\n")
  ###remove NA's
  
  spp1=as.data.frame(spp)
  spp1=cbind(spp1, k)
  
  spp1 <- spp1[which(spp1$k == 0),] 
  spp1 <- spp1[, -ncol(spp1)]
  
  
  cat("writing new", files, "file", "\n")
  write.csv(spp1, paste0(ready,"nosea/", files), row.names = FALSE)
  rm(spp1)
  rm(spp)
  cat("DONE", "\n")
  
}

#--------------Run in parallel---------------
ncores <- detectCores()-12 #change according available server resources
c1 <- makeCluster(ncores)
clusterEvalQ(c1, lapply(c("raster", "maptools"), library, character.only= TRUE))
clusterExport(c1, c("folderin", "ready", "countries_sh", "files"))
microbenchmark(parLapply(c1, files, cleansea),times = 1L) 
