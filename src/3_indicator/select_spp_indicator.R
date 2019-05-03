##########################################   Start Functions    ###############################################
# This function takes a list of countries or subregions, selects those species from the file
# "WEP_taxonkey_distribution.csv" and then runs the calc_indicator.R function, which in turn
# calculates the proportion of species in different categories (HP, MP, LP, SC).
# The output is returned as a data.frame.
# @param (string) iso_list: vector with list of country ISO's or the name of the regions
# @param (string) opt: which field(s) to calculate indicator for (min, max, mean)
# @param (string) level: the level of the analysis (country or subregion)
# @return (data.frame): This function returns a data frame proportions of spp in each category,
#                       and with final indicator aggregated for the selected country (or region)

select_spp_indicator <- function(iso_list="ALL", opt=c("min","max","mean","ex","in"), level) {
  #load global config
  config(dirs=T)
  
  if(level == "country"){
  #load list of species-by-country
  wep_list <- read.csv(paste(par_dir,"/WEP/WEP_taxonkey_distribution_ISO3.csv",sep=""),sep="\t",header=T)

  #select species following given filter
  if (toupper(iso_list) == "ALL") {
    spp_list <- unique(paste(wep_list$taxonkey))
  } else {
    
       if(iso_list == "NA"){
       
         spp_list <- wep_list[which(wep_list$ISO3 %in% "NAM"),] #ISO3  to generate Namibia indicator.
         spp_list <- unique(paste(spp_list$taxonkey))
       
     }else{
       
       spp_list <- wep_list[which(wep_list$ISO2 %in% toupper(iso_list)),] #ISO3  to generate Namibia indicator.
       spp_list <- unique(paste(spp_list$taxonkey))
       
     }
    
  }
  
  #filter above list of species following those that have fcs_combined.csv
  spp_exist <- lapply(spp_list, FUN=function(x) {file.exists(paste(gap_dir,"/",x,"/",run_version,"/gap_analysis/combined/fcs_combined.csv",sep=""))})
  spp_exist <- unlist(unlist(spp_exist))
  spp_list <- spp_list[which(spp_exist)]
  
  
  if (length(spp_list) == 0) {
    indic_df <- NA
  } else {
    #calculate indicator for species list
    
    indic_df <- calc_indicator(spp_list, opt, save_file = F)
    
  }
  
  #return object

  date = Sys.Date()
  
  if(!file.exists(paste0(root,"/indicator/countries/",date))){dir.create(paste0(root,"/indicator/countries/",date))}
  
  
  
  if(iso_list == "ALL"){

    write.csv(indic_df, paste(root,"/indicator/ALL/indicator_ALL_",date, ".csv",sep=""), row.names=F, quote=F)
    
  }else{ if(iso_list =="NA" ){
    
    
    write.csv(indic_df, paste(root,"/indicator/countries/",date, "/ind_NA.csv",sep=""), row.names=F, quote=F)
    
  }else{
    
    write.csv(indic_df, paste(root,"/indicator/countries/",date, "/ind_",iso_list, ".csv",sep=""), row.names=F, quote=F)
    
  }
    
    
  }
  
  
  return(indic_df)
  
  }else{
    
    
    wep_list <- read.csv(paste(par_dir,"/UNSD/subregions.csv",sep=""),sep=",",header=T)
    
    #select species following given filter
    spp_list <- wep_list[which(wep_list$SUBREGIONS %in% iso_list),]
    spp_list <- unique(paste(spp_list$taxonkey))
    
    #filter above list of species following those that have fcs_combined.csv
    spp_exist <- lapply(spp_list, FUN=function(x) {file.exists(paste(gap_dir,"/",x,"/",run_version,"/gap_analysis/combined/fcs_combined.csv",sep=""))})
    spp_exist <- unlist(unlist(spp_exist))
    spp_list <- spp_list[which(spp_exist)]
    
    if (length(spp_list) == 0) {
      indic_df <- NA
    } else {
      #calculate indicator for species list
      
      indic_df <- calc_indicator(spp_list, opt, save_file = F)
      
    }
    
    #return object
    
    date = Sys.Date()
    
    if(!file.exists(paste0(root,"/indicator/subregions/",date))){dir.create(paste0(root,"/indicator/subregions/",date))}
    
    
    write.csv(out_df, paste(root,"/indicator/subregions/",date, "/ind_",iso_list, ".csv",sep=""), row.names=F, quote=F)
      
    
    #return object
    return(indic_df)
    
    
    
    
  }
}

##########################testing function ########################################################################################



#AS,NF ARE IN NA

##Generate Namibia indicator.##
#iso_list <- "NAM"
#indic_iso <- select_spp_indicator(iso_list, opt=c("min","max","mean","ex","in"))
#write.csv(indic_iso,paste0("//dapadfs/Workspace_cluster_9/Aichi13/indicator/countries/2018-11-16/NA","_",Sys.Date(),".csv"),row.names=F, quote=F)
