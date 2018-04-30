require(raster);require(countrycode);require(maptools);require(rgdal)

base_dir = "//dapadfs"
repo_dir = "D:/ccsosa/src"

# Load the sources scripts
source.files = list.files(repo_dir, "\\.[rR]$", full.names = TRUE, recursive = T)
source.files = source.files[ !grepl("run", source.files) ]
source.files = source.files[ !grepl("calibration", source.files) ]
lapply(source.files, source)
config(dirs=T)
load(file=paste0(par_dir, "/gadm/shapefile/gadm28ISO.RDS"))

config(dirs=F, cleaning=T, insitu=T, exsitu=T, modeling=T, premodeling=T)

setwd(root)
ind_dir<-paste0(root,"/","indicator")


 iso2c_shp<- countrycode(countries_sh$ISO,"iso3c","iso2c")
 iso2c_shp[which(is.na(iso2c_shp))]<-""
 countries_sh$ISO2<-iso2c_shp
 
 
 ind_iso_dir<-paste0(ind_dir,"/","countries")
 ind_countries<-list.files(ind_iso_dir,pattern = ".csv$",full.names = F)
 ind_countries_iso2<-ind_countries
 ind_countries_iso2<-gsub("indicator_","",ind_countries_iso2)
 ind_countries_iso2<-gsub(".csv","",ind_countries_iso2)
 ind_countries_iso2<-gsub("_2018-04-09","",ind_countries_iso2)
 
 count_list<-lapply(1:length(ind_countries),function(i){
   cat(i, "\n")
   x<-read.csv(paste0(ind_iso_dir,"/",ind_countries[[i]]),header=T)
   x<-x[,12]
   x<-t(x)
   x<-as.data.frame(cbind(as.character(ind_countries_iso2[[i]]),x))
   #x<-t(x)
   colnames(x)<-c("iso2c","min","max","mean","exsitu","insitu")
   return(x)
 })
 
 count_list<-do.call(rbind,count_list)
 
coun2<-merge(countries_sh,count_list,by.x="ISO2",by.y="iso2c")
#setwd(ind_dir)
coun2@data<-coun2@data[complete.cases(coun2@data),]
coun2@data<-coun2@data[,-c(2,3)]
write.csv(coun2@data,paste0(ind_iso_dir,"/","countries.csv"),row.names=F,quote=F,na="")

######### write .js object ###########

r<-c()
index<-c()
for(i in 1:nrow(coun2@data)){
  
  r[i]<-gsub(coun2@data$ISO2[i], paste0("['",coun2@data$ISO2[i],"',"), coun2@data$ISO2[i])
  index[i]<-gsub(coun2@data$mean[i], paste0(coun2@data$mean[i],"],"), coun2@data$mean[i])
}

index[256]<-gsub(",", "];", index)
coun2@data<-coun2@data[,c(1,5)]
coun2@data<-cbind(r,coun2@data)
coun2@data<-cbind(coun2@data,index)
coun2@data<-coun2@data[,-c(2,3)]
colnames(coun2@data)<-c("['country',", "'index'],")
x<-which(!is.na(coun2@data[,2]))
coun2@data<-coun2@data[x,]

write.table(coun2@data,paste(ind_iso_dir,"/to_graph/countries.js", sep=""),row.names=F,quote=F,na="")
