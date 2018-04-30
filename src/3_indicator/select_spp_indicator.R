##########################################   Start Functions    ###############################################
# This function takes a list of countries, selects those species from the file
# "WEP_taxonkey_distribution.csv" and then runs the calc_indicator.R function, which in turn
# calculates the proportion of species in different categories (HP, MP, LP, SC).
# The output is returned as a data.frame.
# @param (string) iso_list: vector with list of country ISOs
# @param (string) opt: which field(s) to calculate indicator for (min, max, mean)
# @return (data.frame): This function returns a data frame proportions of spp in each category,
#                       and with final indicator aggregated for the selected country

select_spp_indicator <- function(iso_list="ALL", opt=c("min","max","mean","ex","in")) {
  #load global config
  config(dirs=T)
  
  #load list of species-by-country
  wep_list <- read.csv(paste(par_dir,"/WEP/WEP_taxonkey_distribution_ISO3.csv",sep=""),sep="\t",header=T)
  
  #select species following given filter
  if (toupper(iso_list) == "ALL") {
    spp_list <- unique(paste(wep_list$taxonkey))
  } else {
    spp_list <- wep_list[which(wep_list$ISO3 %in% toupper(iso_list)),]
    spp_list <- unique(paste(spp_list$taxonkey))
  }
  
  #filter above list of species following those that have fcs_combined.csv
  spp_exist <- lapply(spp_list, FUN=function(x) {file.exists(paste(gap_dir,"/",x,"/",run_version,"/gap_analysis/combined/fcs_combined.csv",sep=""))})
  spp_exist <- unlist(unlist(spp_exist))
  spp_list <- spp_list[which(spp_exist)]
  
  if (length(spp_list) == 0) {
    indic_df <- NA
  } else {
    #create filename
    fname <- paste(paste("indicator_",iso_list,"_",Sys.Date(),sep=""),".csv",sep="")
    
    #calculate indicator for species list
    indic_df <- calc_indicator(spp_list, opt, fname)
    
  }
  
  #return object
  return(indic_df)
}

##########################testing function ########################################################################################
#base_dir <- "~/nfs"
#base_dir = "//dapadfs"

iso_list="ALL"
indic_iso <- select_spp_indicator(iso_list, opt=c("min","max","mean","ex","in"))
write.csv(indic_iso,paste0(root,"/indicator/ALL/" ,"indicator_",iso_list,"_",Sys.Date(),".csv"), quote=F, row.names = F)



iso_list <- as.character(na.omit(unique(wep_list$ISO3)))
indic_iso <-lapply(1:length(iso_list), function(i){
  y <- select_spp_indicator(iso_list[[i]], opt=c("min","max","mean","ex","in"))
  write.csv(y,paste0(root,"/indicator/countries/" ,"indicator_",iso_list[[i]],"_",Sys.Date(),".csv"), quote=F, row.names = F)
  return(y)
})
