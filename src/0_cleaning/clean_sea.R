# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (data.frame): data.frame with filtered species records
#-------------------------------------
#Function for removing sea coordinates
#Jonatan Soto
#Based on Jeison & Alejandra advice
#-------------------------------------
clean_sea <- function(species) {
  #load packages
  require(raster)
  require(maptools)
  require(rgdal)
  
  ##source config
  config(dirs=T, cleaning=T)
  
  #load raw species occurrences
  spp <- read.csv(paste0(folderin_raw,"/",species,".csv"), header = FALSE, sep="\t") ##read file
  colnames(spp) <- c("lon", "lat", "country", "type", "native")
  #cat("loading species ID=", species, "file", "\n")
  
  #transform spp data.frame into SpatialPointsDataFrame
  coordinates(spp) <- ~lon+lat ###to SpatialPointsDataFrame
  crs(spp) <- crs(countries_sh) ####add to mask
  over_spp <- over(spp, countries_sh) ### over() #overlay
  
  ###remove NAs
  #cat("Removing NA's for species ID", species, "file", "\n")
  spp1 <- as.data.frame(spp)
  spp1 <- cbind(spp1, over_spp)
  spp1 <- spp1[which(!is.na(spp1$ISO)),]
  spp1$ISO <- NULL
  
  #cat("writing new", files, "file", "\n")
  write.csv(spp1, paste0(folder_nosea,"/", species, ".csv"), row.names = FALSE)
  #cat("DONE", "\n")
  
  rm(spp)
  return(spp1)
}

# #--------------Run in parallel---------------
# ncores <- detectCores()-12 #change according available server resources
# c1 <- makeCluster(ncores)
# clusterEvalQ(c1, lapply(c("raster", "maptools"), library, character.only= TRUE))
# clusterExport(c1, c("folderin", "countries_sh", "files", "folderout", "sum_count", "count_spp"))
# microbenchmark(parLapply(c1, files, cleansea),times = 1L) 
# 

