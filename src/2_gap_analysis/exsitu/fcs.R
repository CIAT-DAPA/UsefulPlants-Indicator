##########################################   Start Functions    ###############################################
# This function calculates the FCSex. It loads srs.csv, grs.csv, ers.csv and
# calculates FCS. It saves output in summary.csv
# @param (string) species: species ID
# @return (data.frame): This function returns a data frame with ID, SRS, GRS, ERS, FCS
#                       for a given species.
fcs_exsitu <- function(species) {
  #load config
  config(dirs=T,exsitu=T)
  
  #directory for species
  sp_dir <- paste(gap_dir,"/",species,"/",run_version,sep="")
  
  #load SRS, GRS, and ERS file
  sp_srs <- read.csv(paste(sp_dir,"/gap_analysis/exsitu/srs_result.csv",sep=""))
  sp_grs <- read.csv(paste(sp_dir,"/gap_analysis/exsitu/grs_result.csv",sep=""))
  sp_ers <- read.csv(paste(sp_dir,"/gap_analysis/exsitu/ers_result.csv",sep=""))
  
  #FCS=0 when G==0 (in this case SRS, GRS, and ERS will already be 0)
  #FCS=0 when H==0 (in this case SRS, GRS and ERS will already be 0, 
  #                 i.e. we already included these caveats in grs.R, and ers.R)
  sp_fcs <- mean(c(sp_srs$SRS,sp_grs$GRS,sp_ers$ERS), na.rm=T)
  
  #create data.frame with output
  out_df <- data.frame(ID=species, SRS=sp_srs$SRS, GRS=sp_grs$GRS, ERS=sp_ers$ERS, FCS=sp_fcs)
  write.csv(out_df,paste(sp_dir,"/gap_analysis/exsitu/summary.csv",sep=""),row.names=F)
  
  #return object
  return(out_df)
}

#testing the function
#base_dir <- "~/nfs"
#source("~/Repositories/aichi13/src/config.R")
#fcs_exsitu("2686262")

