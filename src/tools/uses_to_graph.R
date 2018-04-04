#María Victoria Diaz
#CIAT,2018

# This function summarizes the "min","max","mean","exsitu","insitu" values for each catgeorie of uses in the species
# @param (string) uses: Choose only one categorie of the uses of the species
# @return (dataframe): This function return a dataframe with the  "min","max","mean","exsitu","insitu" values as columns and categories as rows

#base_dir = "//dapadfs"
#repo_dir = "D:/Repositorios/aichi13/src"
#config(dirs=T)

ind_dir<-paste0(root,"/","indicator")
uses_sp<-c("Additive", "Animal_Food", "Bee_Plants", "Environmental", "Fuels", "Genetic_Sources", "Human_Food", "Materials", "Medicine", "Pesticide", "Poison","Social")

ind_us_dir<-paste0(ind_dir,"/uses")
ind_uses<-list.files(ind_us_dir,pattern = ".csv$",full.names = F)
ind_uses1<-ind_uses
ind_uses1<-gsub("indicator_","",ind_uses)
ind_uses1<-gsub(".csv","",ind_uses1)
ind_uses1<-gsub("2018-04-03","",ind_uses1)
ind_uses1<-gsub("_","",ind_uses1)



opt_list<-lapply(1:length(ind_uses),function(i){
  
  
  u<-read.csv(paste0(ind_us_dir,"/",ind_uses[[i]]),header=T)
  u<-u[,"P_LP_SC"]
  u<-t(u)
  u<-as.data.frame(cbind(as.character(ind_uses1[[i]]),u))
  colnames(u)<-c("uses","min","max","mean","exsitu","insitu")
  return(u)
})

opt_list<-do.call(rbind,opt_list)

write.csv(opt_list,paste(ind_dir,"/indicator_uses",Sys.Date(),".csv",sep = ""),row.names=F,quote=F,na="")

########CREATE A .JS OBJECT ##############

Uses<-c()
index<-c()
for(i in 1:nrow(opt_list)){
  
  Uses[i]<-gsub(opt_list$uses[i], paste0("['",opt_list$uses[i],"',"), opt_list$uses[i])
  index[i]<-gsub(opt_list$mean[i], paste0(opt_list$mean[i],",''],"), opt_list$mean[i])
}

index[11]<-gsub(opt_list$mean[i], paste0(opt_list$mean[i],",'']];"), opt_list$mean[i])
opt_list<-opt_list[,c(1,4)]
opt_list<-cbind(Uses,opt_list)
opt_list<-cbind(opt_list,index)
opt_list<-opt_list[,-c(2,3)]
x<-which(!is.na(opt_list$index))
opt_list<-opt_list[x,]
colnames(opt_list)<-c("['country',", "'index'],")

write.table(opt_list,paste(ind_us_dir,"to_graph/uses", ".js", sep=""),row.names=F,quote=F,na="")




