# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): status of directory creation
create_sp_dirs <- function(species) {
  #load config
  config(dirs=T)
  
  #create species dir
  sp_dir <- paste(gap_dir,"/",species,"/",run_version,sep="")
  if (!file.exists(sp_dir)) {dir.create(sp_dir,recursive=T)}
  
  #create other directories
  if (!file.exists(paste(sp_dir,"/bioclim",sep=""))) {dir.create(paste(sp_dir,"/bioclim",sep=""))}
  if (!file.exists(paste(sp_dir,"/gap_analysis/combined",sep=""))) {dir.create(paste(sp_dir,"/gap_analysis/combined",sep=""),recursive=T)}
  if (!file.exists(paste(sp_dir,"/gap_analysis/exsitu",sep=""))) {dir.create(paste(sp_dir,"/gap_analysis/exsitu",sep=""),recursive=T)}
  if (!file.exists(paste(sp_dir,"/gap_analysis/insitu",sep=""))) {dir.create(paste(sp_dir,"/gap_analysis/insitu",sep=""),recursive=T)}
  if (!file.exists(paste(sp_dir,"/modeling/alternatives",sep=""))) {dir.create(paste(sp_dir,"/modeling/alternatives",sep=""),recursive=T)}
  if (!file.exists(paste(sp_dir,"/modeling/maxent",sep=""))) {dir.create(paste(sp_dir,"/modeling/maxent",sep=""),recursive=T)}
  if (!file.exists(paste(sp_dir,"/occurrences",sep=""))) {dir.create(paste(sp_dir,"/occurrences",sep=""),recursive=T)}
  
  #return
  return(species)
}
