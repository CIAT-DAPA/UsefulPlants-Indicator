##########################################   Start Functions    ###############################################
# This function calculates the combined ex-situ and in-situ FCS (FCSc)
# It searches for the species, then loads the summary.csv from both ex-situ FCSex and in-situ FCSin 
# then computes the FCSc and outputs a file fcs_combined.csv
# @param (string) species: species ID
# @return (data.frame): This function returns a data frame with the combined FCS of the ex-situ and in-situ
#                       gap analysis. It contains four columns: Species_ID, FCSex, FCSin, FCSc_min, 
#                       FCSc_max, FCSc_mean, and the priority class (HP, MP, LP, SC) for each combined version.
fcs_combine <- function(species) {
  #load global config
  config(dirs=T)
  
  #in-situ and ex-situ summary files
  sp_dir <- paste(gap_dir,"/",species,sep="")
  file_in <- paste(sp_dir,"/",run_version,"/gap_analysis/insitu/summary.csv",sep="")
  file_ex <- paste(sp_dir,"/",run_version,"/gap_analysis/exsitu/summary.csv",sep="")
  
  #read data from in-situ and ex-situ files
  data_in <- read.csv(file_in, sep=",", header=T)
  data_ex <- read.csv(file_ex, sep=",", header=T)
  
  #compute FCSc_min and FCSc_max
  data_comb <- data.frame(ID=species, FCSex=data_ex$FCS, FCSin=data_in$FCS)
  data_comb$FCSc_min <- min(c(data_ex$FCS,data_in$FCS),na.rm=T)
  data_comb$FCSc_max <- max(c(data_ex$FCS,data_in$FCS),na.rm=T)
  data_comb$FCSc_mean <- mean(c(data_ex$FCS,data_in$FCS),na.rm=T)
  
  #assign classes (min)
  if (data_comb$FCSc_min < 25) {
    data_comb$FCSc_min_class <- "HP"
  } else if (data_comb$FCSc_min >= 25 & data_comb$FCSc_min < 50) {
    data_comb$FCSc_min_class <- "MP"
  } else if (data_comb$FCSc_min >= 50 & data_comb$FCSc_min < 75) {
    data_comb$FCSc_min_class <- "LP"
  } else {
    data_comb$FCSc_min_class <- "SC"
  }
  
  #assign classes (max)
  if (data_comb$FCSc_max < 25) {
    data_comb$FCSc_max_class <- "HP"
  } else if (data_comb$FCSc_max >= 25 & data_comb$FCSc_max < 50) {
    data_comb$FCSc_max_class <- "MP"
  } else if (data_comb$FCSc_max >= 50 & data_comb$FCSc_max < 75) {
    data_comb$FCSc_max_class <- "LP"
  } else {
    data_comb$FCSc_max_class <- "SC"
  }
  
  #assign classes (mean)
  if (data_comb$FCSc_mean < 25) {
    data_comb$FCSc_mean_class <- "HP"
  } else if (data_comb$FCSc_mean >= 25 & data_comb$FCSc_mean < 50) {
    data_comb$FCSc_mean_class <- "MP"
  } else if (data_comb$FCSc_mean >= 50 & data_comb$FCSc_mean < 75) {
    data_comb$FCSc_mean_class <- "LP"
  } else {
    data_comb$FCSc_mean_class <- "SC"
  }
  
  #create output directory if it doesnt exist
  comb_dir <- paste(sp_dir,"/",run_version,"/gap_analysis/combined",sep="")
  if (!file.exists(comb_dir)) {dir.create(comb_dir)}
  
  #save output file and return
  write.csv(data_comb, paste(comb_dir,"/fcs_combined.csv",sep=""), row.names=F)
  return(data_comb)
}

#testing function
#base_dir <- "~/nfs"
#fcsc <- fcs_combine("2686262")
