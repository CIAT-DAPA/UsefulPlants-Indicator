root<-"//dapadfs/Projects_cluster_9/aichi"
sourcedir <- paste0(root,"/scripts")
Maxentdir<-paste0(root,"/","ENMeval_2/outputs") #change according ENMeval folder and accurate Maxent models
#names_list <- read.csv(paste0(Maxentdir, "/","valid_models_ASD15.csv"),header = TRUE)
#names_list <- as.character(names_list[,1])
#names_list <- sub(".csv","",names_list)
#names_list <- list.dirs(Maxentdir, recursive = FALSE)
#names_list<-sub(paste0(Maxentdir,"/"),"",names_list)
ocurdir<- paste0(root,"/occurrences_GH/cleansea/nosea")
names_list <- list.files(ocurdir, pattern = '\\.csv$')

names_list <- names_list[1]
names_list <- sub(".csv", "", names_list)
splitspps <- function(names_list){
  
gapfolder <- paste0(Maxentdir,"/",names_list,".csv/","gap_analysis")

if(file.exists(gapfolder)) {cat("gap_analysis folder exists","\n")}else{dir.create(gapfolder)}

#read sppurrences
spp <- read.csv(paste0(ocurdir,"/",names_list,".csv"), header = TRUE)


spp$H <- ifelse(spp$type =="H",1,0)
spp$G <- ifelse(spp$type =="G",1,0)

write.csv(spp,paste0(gapfolder,"/","all_",names_list,".csv",sep=""),quote=F,row.names=F)

spp <- spp[which(!is.na(spp$lat)),]
spp <- spp[which(!is.na(spp$lon)),]

h <- spp[which(spp$H==1),]
g <- spp[which(spp$G==1),]

write.csv(h,paste0(gapfolder,"/",names_list,"_h.csv",sep=""),quote=F,row.names=F)
write.csv(g,paste(gapfolder,"/",names_list,"_g.csv",sep=""),quote=F,row.names=F)

#----------------- SRS CALCULATION -----------------

srs <- (base::nrow(g)/(base::nrow(g)+base::nrow(h)))*10
write.csv(srs, paste0(gapfolder, "/srs.csv"), row.names = FALSE)

rm(list = c("g", "h", "spp"))
}

lapply(names_list, splitspps)
