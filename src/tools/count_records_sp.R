#María Victoria Díaz, Chrystian Sossa
#CIAT, 2018
#Function to know the species that has been modeled
#@param (string) species_list: vector with list species IDs
#@return (data frame): This function returns a csv file with the number of ocurrences by species and the ID.

species_list<-list.files("//dapadfs/Workspace_cluster_9/Aichi13/parameters/occurrences/no_sea - Copy", pattern= ".csv$")

species <- "2650133"

uni<-function(species){
  data <- read.csv(paste("//dapadfs/Workspace_cluster_9/Aichi13/parameters/occurrences/no_sea - Copy/",species, sep=""),header=T)
  data <- data[which(!is.na(data$lon)),]
  data <- unique(data[,c("lon","lat")])
  rowsc <- nrow(data)
  base <- cbind(species, rowsc)
  return(base)
  
}


y <- lapply(1:length(species_list),function(i){
  #cat(i, "\n")
  x<- uni(species_list[[i]])
  return(x)
  
  
})

x1<-write.csv(data, "//dapadfs/Workspace_cluster_9/Aichi13/runs/results/records.csv")




