#María Victoria Díaz
#CIAT,2018

# This function summarizes the "min","max","mean","exsitu","insitu" values for each subregion where the species are located
# @param (string) ind_subregions: Choose only one subregions where the species are located
# @return (ind_subregions): This function return a dataframe with the  "min","max","mean","exsitu","insitu" values as columns and subregions as rows

#base_dir = "//dapadfs"
#repo_dir = "D:/Repositorios/aichi13/src"
#config(dirs=T)

require(raster);require(countrycode);require(maptools);require(rgdal)

base_dir = "//dapadfs"
config(dirs=T)

config(dirs=T)
load(file=paste0(par_dir, "/gadm/shapefile/gadm28ISO.RDS"))
config(dirs=F, cleaning=T, insitu=T, exsitu=T, modeling=T, premodeling=T)

sub_dir<-paste0(root,"/indicator/subregions")
names_subreg<-countrycode(countries_sh$ISO, origin="iso3c", destination = "region")
names_subreg[which(is.na(names_subreg))]<-""
countries_sh$REG<-names_subreg

ind_subregions<-list.files(sub_dir,pattern = ".csv$",full.names = F)
ind_subregions_un<-ind_subregions
ind_subregions_un<-gsub("indicator_","",ind_subregions_un)
ind_subregions_un<-gsub(".csv","",ind_subregions_un)
ind_subregions_un<-gsub( "2018-04-03","",ind_subregions_un)
ind_subregions_un<-gsub( "_","",ind_subregions_un)


unsd <<- read.csv(paste0(par_dir,"/UNSD/UNSD_Methodology.csv"), sep=",", header=T)
sub <- read.csv(paste0(par_dir,"/UNSD/subregions1.csv"), sep="," , header=T)

y<-list()
src<-list()
irc<-list()

for( i in 1:length(ind_subregions_un)){
    
  y[[i]]<-subset(unsd,tolower(unsd$Intermediate.Region.Name)==tolower(ind_subregions_un[i]) |tolower(unsd$Sub.region.Name)==tolower(ind_subregions_un[i]))
    src[[i]]<-unique(na.omit(y[[i]]$Sub.region.Code))
    irc[[i]]<-unique(na.omit(y[[i]]$Intermediate.Region.Code))
 }

n<-cbind(irc,src)
irc[[1]]=irc[[4]]=irc[[6]]=irc[[10]]=irc[[13]]=irc[[16]]=irc[[19]]=irc[[7]]=irc[[8]]=irc[[17]]=irc[[20]]=irc[[11]]=0
n[which(n[,1]==0),1]<- n[which(n[,1]==0) ,2]
nn<-n[,1]

s<-list()
z<-list()
for( i in 1:length(ind_subregions_un)){
  s[[i]]<-subset(sub,sub$SUBREGIONS %in% ind_subregions_un[i])
  z[[i]]<-cbind(as.character(unique(s[[i]][,6])), unique(s[[i]][,7]))
 }


zz<-do.call(rbind, z)


sub_list<-lapply(1:length(ind_subregions),function(i){
  x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
  x<-x[,"P_LP_SC"]
  x<-t(x)
  x<-as.data.frame(cbind(zz[i,1],as.numeric(zz[i,2]),x))
  colnames(x)<-c("subregions","codes","min","max","mean","exsitu","insitu")
  return(x)
})

sub_list<-do.call(rbind,sub_list)

write.csv(sub_list,paste(sub_dir,"/regions", ".csv", sep=""),row.names=F,quote=F,na="",sep=",")

subr<-c()
index<-c()
for(i in 1:nrow(sub_list)){
  
  subr[i]<-gsub(sub_list$subregions[i], paste0("['",sub_list$subregions[i],"',"), sub_list$subregions[i])
  index[i]<-gsub(sub_list$mean[i], paste0(sub_list$mean[i],"],"), sub_list$mean[i])
}

sub_list<-sub_list[,c(1,2,5)]
sub_list<-cbind(subr,sub_list)
sub_list<-cbind(sub_list,index)
sub_list<-sub_list[,-c(2,4)]
x<-which(!is.na(sub_list$index))
opt_list<-opt_list[x,]
colnames(sub_list)<-c("['regions',","'codes'", "'index'],")

write.table(sub_list,paste(sub_dir,"/to_graph/regions", ".js", sep=""),row.names=F,quote=F,na="")

