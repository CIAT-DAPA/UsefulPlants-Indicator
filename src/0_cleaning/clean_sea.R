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
require(rgdal)

##source()
config(dirs=T, cleaning=T)



files <- list.files(folderin, pattern = '\\.csv$')
sum_count <- matrix(ncol = 2, nrow = length(files))
colnames(sum_count) <- c("Taxon", "count")
count_spp <- 1:length(files)


cleansea <- function(files){
  
  spp<- read.csv(paste0(folderin,files), header = FALSE, sep="\t") ##read file
  colnames(spp)<- c("lon", "lat", "country", "type", "native")
  cat("loading", files, "file", "\n")
  coordinates(spp)= ~lon+lat ###to rasterdataframe
  crs(spp)= crs(countries_sh)####add to mask
  over=over(spp, countries_sh) ### over()
  country_name=over$ISO####select ISO for match
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
  write.csv(spp1, paste0(folderout,"/", files), row.names = FALSE)
  
  cat("DONE", "\n")
  
  
  cat("COUNTING", files ,"ocurrences","\n")
  
  sum_count[count_spp,1] <- files[count_spp]
  sum_count[count_spp,2] <- base::nrow(spp1)
  
  count_spp <- count_spp + 1
  
  rm(spp1)
  rm(spp)
  
  cat("DONE", "\n")
  
}

sum_count<-as.data.frame(sum_count)
write.csv(sum_count, paste0(par_dir, "/summary_count.csv"), quote = FALSE, row.names = FALSE)

#--------------Run in parallel---------------
ncores <- detectCores()-12 #change according available server resources
c1 <- makeCluster(ncores)
clusterEvalQ(c1, lapply(c("raster", "maptools"), library, character.only= TRUE))
clusterExport(c1, c("folderin", "countries_sh", "files", "folderout", "sum_count", "count_spp"))
microbenchmark(parLapply(c1, files, cleansea),times = 1L) 



