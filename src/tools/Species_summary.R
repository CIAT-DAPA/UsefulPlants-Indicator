
pri2 <- read.csv(paste0(root,"/Richness/priorities/priorities_ALL.csv"), header = TRUE)
scie_names <- read.csv(paste0(par_dir,"/scientific_names.csv"), header = TRUE)
scie_names$Taxon_key <- as.character(scie_names$Taxon_key)
scie_names$GBIF <- as.character(scie_names$GBIF)

#species <- especies
#species <- "2755489"

#species <- species[522]
species = pri2$Species
species_summary <- function(species){
  
  
  summ_table <- as.data.frame(matrix(ncol = 20, nrow = 1))
  colnames(summ_table) <- c("Taxon_key", "Scientific_Name", "Total_records", "Total_with_coords", "Total_G", "Total_G_with_coords", "Total_H", "Total_H_with_coords", "Model_type", "SRS", "GRS_ex", "ERS_ex", "FCS_ex", "GRS_in", "ERS_in", "FCS_in", "FCSc_min", "FCSc_max", "FCSc_mean", "Priority_category")
  
  summ_table$Taxon_key <- as.character(species)
  summ_table$Scientific_Name <- as.character(scie_names$GBIF[which(scie_names$Taxon_key==species)])
  
  if(file.exists(paste0(gap_dir,"/", species, "/counts.csv"))){
    counts <- read.csv(paste0(gap_dir,"/", species, "/counts.csv"), header = TRUE, sep = "\t")
    summ_table$Total_records <- counts$totalRecords
    summ_table$Total_with_coords <- counts$totalUseful
    summ_table$Total_G <- counts$totalGRecords
    summ_table$Total_G_with_coords <- counts$totalGUseful
    summ_table$Total_H <- counts$totalHRecords
    summ_table$Total_H_with_coords <- counts$totalHUseful
    
  }else{
    summ_table$Total_records <- NA
    summ_table$Total_with_coords <- NA
    summ_table$Total_G <- NA
    summ_table$Total_G_with_coords <- NA
    summ_table$Total_H <- NA
    summ_table$Total_H_with_coords <- NA
  
  }
  
  if (is.na(pri2$VALID[which(pri2$Species==species)])){
    summ_table$Model_type <- "NA"
  } else if(pri2$VALID[which(pri2$Species==species)]){
    summ_table$Model_type <- "SDM"
  }else if (pri2$VALID[which(pri2$Species==species)]==FALSE){
    summ_table$Model_type <- "CA50"
  }
  
  
  if(file.exists(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/exsitu/summary_fixed.csv"))){
    exsitu <- read.csv(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/exsitu/summary_fixed.csv"), header = TRUE)
    summ_table$SRS <- round(exsitu$SRS, 2)
    summ_table$GRS_ex <- round(exsitu$GRS, 2)
    summ_table$ERS_ex <- round(exsitu$ERS, 2)
    summ_table$FCS_ex <- round(exsitu$FCS, 2)
  }else{
    if(file.exists(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/exsitu/summary.csv"))){
      exsitu <- read.csv(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/exsitu/summary.csv"), header = TRUE)
      summ_table$SRS <- round(exsitu$SRS, 2)
      summ_table$GRS_ex <- round(exsitu$GRS, 2)
      summ_table$ERS_ex <- round(exsitu$ERS, 2)
      summ_table$FCS_ex <- round(exsitu$FCS, 2)
    }else{
      summ_table$SRS <- NA
      summ_table$GRS_ex <- NA
      summ_table$ERS_ex <- NA
      summ_table$FCS_ex <- NA
    }
   
  }
  
  if(file.exists(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/insitu/summary_fixed.csv"))){
    insitu <- read.csv(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/insitu/summary_fixed.csv"), header = TRUE)
    summ_table$GRS_in <- round(insitu$GRS, 2)
    summ_table$ERS_in <- round(insitu$ERS, 2)
    summ_table$FCS_in <- round(insitu$FCS, 2)
  } else {
    if(file.exists(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/insitu/summary.csv"))){
      insitu <- read.csv(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/insitu/summary.csv"), header = TRUE)
      summ_table$GRS_in <- round(insitu$GRS, 2)
      summ_table$ERS_in <- round(insitu$ERS, 2)
      summ_table$FCS_in <- round(insitu$FCS, 2)
    } else {
      summ_table$GRS_in <- NA
      summ_table$ERS_in <- NA
      summ_table$FCS_in <- NA
    }
    
    }
  
  if(file.exists(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/combined/fcs_combined_fixed.csv"))){
    combined <- read.csv(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/combined/fcs_combined_fixed.csv"), header = TRUE)
    summ_table$FCSc_min <- round(combined$FCSc_min, 2)
    summ_table$FCSc_max <- round(combined$FCSc_max, 2)
    summ_table$FCSc_mean <- round(combined$FCSc_mean, 2)
    summ_table$Priority_category <- as.character(combined$FCSc_mean_class)
  } else {
    if(file.exists(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/combined/fcs_combined.csv"))){
      combined <- read.csv(paste0(gap_dir,"/", species, "/", run_version, "/gap_analysis/combined/fcs_combined.csv"), header = TRUE)
      summ_table$FCSc_min <- round(combined$FCSc_min, 2)
      summ_table$FCSc_max <- round(combined$FCSc_max, 2)
      summ_table$FCSc_mean <- round(combined$FCSc_mean, 2)
      summ_table$Priority_category <- as.character(combined$FCSc_mean_class)
    } else {
      summ_table$FCSc_min <- NA
      summ_table$FCSc_max <- NA
      summ_table$FCSc_mean <- NA
      summ_table$Priority_category <- "HP"
    }
    
  }
  
  return(summ_table)
  
}

species_table<-lapply(1:length(species), function(i){
  cat(i, "\n")
  pt<-species_summary(species[[i]])
  return(pt)
  
})

species_table <- do.call(rbind, species_table)
utils::write.csv(species_table, paste0(root, "/indicator/species/summary/species_summary_",Sys.Date() ,".csv"), row.names = FALSE, quote = FALSE)


