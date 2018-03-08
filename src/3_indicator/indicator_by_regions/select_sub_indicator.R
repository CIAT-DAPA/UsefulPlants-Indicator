##########################################   Start Functions    ###############################################
# This function takes a list of subregions, selects those species from the file
# "subregions.csv" and then runs the calc_indicator.R function, which in turn
# calculates the proportion of species in different categories (HP, MP, LP, SC).
# The output is returned as a data.frame.
# @param (string) reg_list: vector with list of subregion names
# @param (string) opt: which field(s) to calculate indicator for (min, max, mean)
# @return (data.frame): This function returns a data frame proportions of spp in each category,
#                       and with final indicator aggregated for the selected subregion


#base_dir = "//dapadfs" 
#source('D:/Repositorios/aichi13/src/config.R')
#source('D:/Repositorios/aichi13/src/3_indicator/indicator.R')

#base_dir="//dapadfs"
select_sub_indicator <- function(reg_list, opt=c("min","max","mean","ex","in")) {
  #load global config
  config(dirs=T)
  
  #load list of species-by-subregion
  wep_list1 <- read.csv(paste(par_dir,"/UNSD/subregions.csv",sep=""),sep=",",header=T)
  
  #select species following given filter
    spp_list <- wep_list1[which(wep_list1$SUBREGIONS %in% reg_list),]
    spp_list <- unique(paste(spp_list$taxonkey))
    
  #filter above list of species following those that have fcs_combined.csv
  spp_exist <- lapply(spp_list, FUN=function(x) {file.exists(paste(gap_dir,"/",x,"/",run_version,"/gap_analysis/combined/fcs_combined.csv",sep=""))})
  spp_exist <- unlist(unlist(spp_exist))
  spp_list <- spp_list[which(spp_exist)]
  
  if (length(spp_list) == 0) {
    indic_df <- NA
  } else {
    #create filename
    fname <- paste(paste("indicator_",reg_list,"_",Sys.Date(),sep=""),".csv",sep="")
    
    #calculate indicator for species list
    indic_df <- calc_indicator(spp_list, opt, fname)
    
  }
  
  #return object
  return(indic_df)
}

##########################testing function ########################################################################################
#base_dir <- "~/nfs"
#base_dir = "//dapadfs"

reg_list <- as.character(na.omit(unique(wep_list1$SUBREGIONS)))
indic_iso <-lapply(1:length(reg_list), function(i){
y <- select_sub_indicator(reg_list[[i]], opt=c("min","max","mean","ex","in"))
write.csv(y, paste0("//dapadfs/Workspace_cluster_9/Aichi13/indicator/subregions/","indicator_",reg_list[[i]],"_",Sys.Date(),".csv"),row.names=F, quote=F)
return(y)
})


#NOTE: no Polynesia and Micronesia