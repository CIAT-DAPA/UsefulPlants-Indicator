##########################################   Start Functions    ###############################################
# This function takes a species list and binds together all species to finally
# calculate the proportion of species in all categories (HP, MP, LP, SC).
# The output is returned as a value.
# @param (string) sp_list: vector with list species IDs
# @param (string) opt: which field(s) to calculate indicator for (min, max, mean)
# @return (data.frame): This function returns a data frame with the indicator requested
#                       for the list of species provided.
calc_indicator <- function(sp_list, opt=c("min","max","mean","insitu","exsitu"), filename="indicator.csv") {
  #load global config
  config(dirs=T)
  
  #go through species list and load files into a data.frame
  data_all <- lapply(sp_list, FUN=function(x) {read.csv(paste(gap_dir,"/",x,"/",run_version,"/gap_analysis/combined/fcs_combined.csv",sep=""))})
  data_all <- do.call(rbind, data_all)
  
  #make final counts for species list (combined)
  out_df <- data.frame()
  for (i in 1:length(opt)) {
    #i <- 1
    tvec <- paste(data_all[,paste("FCSc_",opt[i],"_class",sep="")])
    hp_n <- length(which(tvec %in% c("HP")))
    mp_n <- length(which(tvec %in% c("MP")))
    lp_n <- length(which(tvec %in% c("LP")))
    sc_n <- length(which(tvec %in% c("SC")))
    indic <- lp_n + sc_n
    tdf <- data.frame(opt=opt[i],N_HP=hp_n,N_MP=mp_n,N_LP=lp_n,N_SC=sc_n,N_LP_SC=indic)
    out_df <- rbind(out_df, tdf)
  }
  
  #assign classes (exsitu)
  data_all$FCSex_class <- NA
  for (i in 1:nrow(data_all)) {
    if (data_all$FCSex[i] < 25) {
      data_all$FCSex_class[i] <- "HP"
    } else if (data_all$FCSex[i] >= 25 & data_all$FCSex[i] < 50) {
      data_all$FCSex_class[i] <- "MP"
    } else if (data_all$FCSex[i] >= 50 & data_all$FCSex[i] < 75) {
      data_all$FCSex_class[i] <- "LP"
    } else {
      data_all$FCSex_class[i] <- "SC"
    }
  }
  
  #assign classes (insitu)
  data_all$FCSin_class <- NA
  for (i in 1:nrow(data_all)) {
    if (data_all$FCSin[i] < 25) {
      data_all$FCSin_class[i] <- "HP"
    } else if (data_all$FCSin[i] >= 25 & data_all$FCSin[i] < 50) {
      data_all$FCSin_class[i] <- "MP"
    } else if (data_all$FCSin[i] >= 50 & data_all$FCSin[i] < 75) {
      data_all$FCSin_class[i] <- "LP"
    } else {
      data_all$FCSin_class[i] <- "SC"
    }
  }
  
  #make final counts for species list (exsitu) if asked to
  if ("exsitu" %in% tolower(opt)) {
    tvec <- paste(data_all[,"FCSex_class"])
    hp_n <- length(which(tvec %in% c("HP")))
    mp_n <- length(which(tvec %in% c("MP")))
    lp_n <- length(which(tvec %in% c("LP")))
    sc_n <- length(which(tvec %in% c("SC")))
    indic <- lp_n + sc_n
    out_df_ex <- data.frame(opt="exsitu",N_HP=hp_n,N_MP=mp_n,N_LP=lp_n,N_SC=sc_n,N_LP_SC=indic)
    out_df <- rbind(out_df, out_df_ex)
  }
  
  #make final counts for species list (insitu)
  if ("insitu" %in% tolower(opt)) {
    tvec <- paste(data_all[,"FCSin_class"])
    hp_n <- length(which(tvec %in% c("HP")))
    mp_n <- length(which(tvec %in% c("MP")))
    lp_n <- length(which(tvec %in% c("LP")))
    sc_n <- length(which(tvec %in% c("SC")))
    indic <- lp_n + sc_n
    out_df_in <- data.frame(opt="insitu",N_HP=hp_n,N_MP=mp_n,N_LP=lp_n,N_SC=sc_n,N_LP_SC=indic)
    out_df <- rbind(out_df, out_df_in)
  }
  
  #calculate percentages
  out_df$P_HP <- out_df$N_HP / nrow(data_all) * 100
  out_df$P_MP <- out_df$N_MP / nrow(data_all) * 100
  out_df$P_LP <- out_df$N_LP / nrow(data_all) * 100
  out_df$P_SC <- out_df$N_SC / nrow(data_all) * 100
  out_df$P_LP_SC <- out_df$N_LP_SC / nrow(data_all) * 100
  
  #save file
  write.csv(out_df, paste(root,"/indicator/",filename,sep=""), row.names=F)
  
  #return data.frame
  return(out_df)
}

#testing function
#base_dir <- "~/nfs"
#indic_df <- calc_indicator(sp_list=c("2686262","7230716","2686276"), opt=c("min","max","mean"), filename="indicator.csv")

