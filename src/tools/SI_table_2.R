
## María Victoria Díaz
## CIAT, 2019

####################################################
### Function to create on of the Supplementary tables
#####################################################

species_summary <- function(iso_list){
 
  if(file.exists(paste0("//dapadfs/Workspace_cluster_9/Aichi13/indicator/countries/2019-04-24/ind_",iso_list, ".csv"))){
    
    
  x<-read.csv(paste0("//dapadfs/Workspace_cluster_9/Aichi13/indicator/countries/2019-04-24/ind_",iso_list, ".csv"))
  
  
  if(nrow(x) >1){
    
  wep_list <- read.csv(paste(par_dir,"/WEP/WEP_taxonkey_distribution_ISO3.csv",sep=""),sep="\t",header=T)
  
  countries<-read.csv("//dapadfs/Workspace_cluster_9/Aichi13/parameters_201802/UNSD/countries-continents-regions.csv"); condicion = which(countries$ISO2  %in% iso_list)
  
  if(length(condicion) == 0){
    
    countries<- NA
    
  }else{
    
    countries<-countries[condicion, "Country.Name"]
    
    countries<-unique(countries)
    
  }
  
  wep_list1 <- wep_list[which(wep_list$ISO2 %in% toupper(iso_list)),] #ISO3  to generate Namibia indicator.

  
  
cat(paste0("Checking counts of  ",nrow(wep_list1)," species of  ", iso_list ), "\n")


spp_exist <- lapply(wep_list1$taxonkey, FUN=function(x) {file.exists(paste(gap_dir,"/",x,"/",run_version,"/gap_analysis/combined/fcs_combined.csv",sep=""))})
spp_exist <- unlist(unlist(spp_exist))
wep_list1 <- wep_list1[which(spp_exist),]

  
spp_exist <- lapply(1:nrow(wep_list1), FUN=function(i) { 
  
  cat(i, "\n")
    
    counts<-read.csv(paste0("//dapadfs/Workspace_cluster_9/Aichi13/gap_analysis_201802/", wep_list1$taxonkey[i], "/counts.csv"), sep = "\t")
    counts<- counts$totalUseful == 0
    return(counts)
                     
 })

spp_exist <- unlist(unlist(spp_exist))
wep_listx<-wep_list1$taxonkey[which(spp_exist)]
  
summ_table <- as.data.frame(matrix(ncol = 16, nrow = 5))
  
  colnames(summ_table) <- c("Country", "Country_code_(ISO2)","Conservation_type" ,"Number_of_species_with_coordinates",
                            "Number_of_species_withouth_coordinates_or_no_data", "Total_number_of_species", "Number_of_high_priority",	
                            "Proportion_of_species_high_priority", "Number_of_medium_priority",	"Proportion_of_species_medium_priority",
                            "Number_of_low_priority",	"Proportion_of_species_low_priority","Number_of_sufficiently_conserved",
                            "Proportion_of_species_sufficienly_conserved",	"Number_of_low_priority_and_sufficiently_conserved",
                            "Proportion_of_species_low_priority_and_sufficiently_conserved_(INDICATOR)")

  
for(i in 1:nrow(summ_table)){
    
    summ_table$`Country_code_(ISO2)`[i]<- as.character(iso_list)
   
    summ_table$Country[i]<- as.character(countries)
      
    summ_table$Conservation_type[i] <- as.character(x$opt[i])
    
    summ_table$Number_of_species_with_coordinates[i]<- x$N_HP[1] + x$N_MP[1] + x$N_LP[1] + x$N_SC[1] 
   
    summ_table$Number_of_species_withouth_coordinates_or_no_data[i]<-length(wep_listx)
    
    summ_table$Total_number_of_species[i]<-summ_table$Number_of_species_with_coordinates[i] +  summ_table$Number_of_species_withouth_coordinates_or_no_data[i]
    
    summ_table$Number_of_high_priority[i]<-x$N_HP[i]
    
    summ_table$Number_of_medium_priority[i]<-x$N_MP[i]
    
    summ_table$Number_of_low_priority[i]<-x$N_LP[i]
    
    summ_table$Number_of_sufficiently_conserved[i]<-x$N_SC[i]
    
    summ_table$Number_of_low_priority_and_sufficiently_conserved[i]<-x$N_LP_SC[i]
    
    summ_table$Proportion_of_species_high_priority[i]<-x$P_HP[i]
    
    summ_table$Proportion_of_species_low_priority[i]<-x$P_LP[i]
    
    summ_table$Proportion_of_species_medium_priority[i]<-x$P_MP[i]
    
    summ_table$Proportion_of_species_sufficienly_conserved[i]<-x$P_SC[i]
    
    summ_table$`Proportion_of_species_low_priority_and_sufficiently_conserved_(INDICATOR)`[i]<-x$P_LP_SC[i]
    

}
  

  return(summ_table)
  
  }else{
    
    cat(paste0(iso_list, " is not a native area"), "\n")
    
    
  }
  

  }else{
    
   cat(paste0(iso_list, " is not a native area"), "\n")
  
    
}
  
}



###############################

iso_list<-readRDS("//dapadfs/workspace_cluster_9/Aichi13/indicator/countries/iso_list.RDS")[[1]]

species_table<-lapply(1:length(iso_list), function(i){
  cat(i, "\n")
  pt<-species_summary(iso_list = iso_list[[i]])
  return(pt)
  
})

species_table1 <- do.call(rbind, species_table)
utils::write.csv(species_table1, paste0(root, "/indicator/countries/SI_table_2_",Sys.Date() ,".csv"), row.names = FALSE, quote = FALSE)
