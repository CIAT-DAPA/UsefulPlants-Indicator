#María Victoria Díaz
#CIAT,2018

# This function takes a list of the uses of the species, and calculate the proportion of species with that uses in all categories (HP, MP, LP, SC).
# The output is returned as a value.
# @param (string) usess: Vector list with the uses that is given to the species
# @param (string) opt: which field(s) to calculate indicator for (min, max, mean)
# @return (dataframe): This function returns a data frame with the indicator requested for the list of uses provided.

#base_dir = "//dapadfs" 
#source('D:/Repositorios/aichi13/src/config.R')
#source('D:/Repositorios/aichi13/src/3_indicator/indicator.R')
config(dirs=T)

indicator_cat <- function(usess, opt=c("min","max","mean","ex","in")){
  
uses_sp<<- read.csv(paste0(par_dir,"/uses/uses.csv"), sep=",", header=T)

spp_list <- uses_sp[which(uses_sp$USE.1 %in% usess | uses_sp$USE.2 %in% usess | uses_sp$USE.3 %in% usess | uses_sp$USE.4 %in% usess | uses_sp$USE.5 %in% usess | uses_sp$USE.6 %in% usess | uses_sp$USE.7 %in% usess ),]
spp_list<-as.character(unique(spp_list$Taxon_key))

spp_exist <- lapply(spp_list, FUN=function(x) {file.exists(paste(gap_dir,"/",x,"/",run_version,"/gap_analysis/combined/fcs_combined.csv",sep=""))})
spp_exist <- unlist(unlist(spp_exist))
spp_list <- spp_list[which(spp_exist)]

if (length(spp_list) == 0) {
  indic_df <- NA
} else {
  #create filename
  fname <- paste(paste("indicator_",usess,"_",Sys.Date(),sep=""),".csv",sep="")
  
  #calculate indicator for species list
  indic_df <- calc_indicator(spp_list, opt, fname)
  
}

return(indic_df)


}


###########testing the function############
usess<- c("Additive", "Animal_Food", "Bee_Plants", "Environmental", "Fuels", "Genetic_Sources", "Human_Food", "Materials", "Medicine", "Pesticide", "Social" )
indic_df <- lapply(1:length(usess), function(i){
cat(i, "\n")

#  if(file.exists(paste0("//dapadfs/Workspace_cluster_9/Aichi13/indicator/uses/indicator_",usess[i],".csv"))){
#   cat(paste0("indicator for ", usess[i], " already exists"  ),"\n")
#  x=NULL
#}else{
 x<- indicator_cat(usess[i], opt = c("min","max","mean","in","ex"))
 write.csv(x, paste0("//dapadfs/Workspace_cluster_9/Aichi13/indicator/uses/indicator_",usess[i],"_",Sys.Date(), ".csv"),row.names=F, quote=F)
#}
return(x)

})

#indicator_cat(usess="Animal_Food")








