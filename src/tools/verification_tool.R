


# Loading base dir
base_dir = "//dapadfs"

# Loading Local repository path
repo_dir = "D:/Repositorios/aichi13/src"

# Load the sources scripts
source.files = list.files(repo_dir, "\\.[rR]$", full.names = TRUE, recursive = T)
source.files = source.files[ !grepl("run", source.files) ]
source.files = source.files[ !grepl("calibration", source.files) ]
lapply(source.files, source)



# Load massive climate file
config(dirs=T)


# Load species to be verified
species_list <- list.dirs(gap_dir,recursive = F,full.names = F)

# Calling FCS file information
valid_species<-lapply(1:length(species_list),function(i){
  
  x <- as.data.frame(matrix(ncol=3,nrow = 1)) 
  colnames(x) <- c("Species","Path","Creation_date")
  
  
#species <- 2683969       
  species <-  species_list[[i]]        
  if (file.exists(paste0(gap_dir,"/",species,"/",run_version,"/","gap_analysis/combined/fcs_combined.csv"))){
  
  
  x$Species <- as.character(species)
    x$Path <- paste0(gap_dir,"/",species,"/",run_version,"/","gap_analysis/combined/fcs_combined.csv")
  x$Creation_date <- as.character(file.info(paste0(gap_dir,"/",species,"/",run_version,"/","gap_analysis/combined/fcs_combined.csv"))$ctime)
  
} else {
  
  
  x$Species <- as.character(species)
  x$Path <- NA
  x$Creation_date <- NA 
        }
  return(x)
})



valid_species <- do.call(rbind,valid_species)
#valid_species2 <- valid_species

# Gathering species with FCS file

valid_species <- valid_species[complete.cases(valid_species),]

valid_species2 <- lapply(1:nrow(valid_species),function(j){
  
  x<-read.csv(valid_species$Path[[j]],header=T)
  return(x)
})

valid_species2 <- do.call(rbind,valid_species2)

# Saving Species with FCS valid file
write.csv(valid_species,paste0(root,"/","runs","/","results","/","Verified","_",Sys.Date(),".csv"),row.names=F,quote=F)

# Saving Combined FCS file
write.csv(valid_species2,paste0(root,"/","runs","/","results","/","FCS_Combined","_",Sys.Date(),".csv"),row.names=F,quote=F)

