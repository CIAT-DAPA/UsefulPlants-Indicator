#Maria Victoria Diaz
#CIAT, 2018

# This function makes a stratified sampling of the species that have more than 2000 ocurrences
# @param (string) species: Species ID.
# @return (dataFrame): This function return a DataFrame with a sample of the total records of the species. 

#species="2703705"
base_dir="//dapadfs"
source('C:/Users/MVDIAZ/Desktop/src/config.R')



sampling<-function(species){
  
  config(dirs=T, cleaning=T)
  
  ocurr_sp<- read.csv(paste0(folder_nosea, "/", species, ".csv"), header=T,sep=",")
  ocurr_sp<-as.data.frame(ocurr_sp)
 # count_occ<-nrow(ocurr_sp)
 # ocurr_sp$num<-NA
 # ocurr_sp$num<-seq(from=1,to=count_occ,by=1)
#  ocurr_sp<-cbind(ocurr_sp,ocurr_sp$num )
  Estratos<- unique(na.omit(ocurr_sp$country))
  
  p<-c()
  n<-c()
  x<-data.frame()
  y<-c()
  
  for(i in 1:length(Estratos)){
    
    n[i]<-nrow(ocurr_sp[which(ocurr_sp$country==Estratos[i]),])
    p[i]<-n[i]/count_occ
    x<-ocurr_sp[which(ocurr_sp$country==Estratos[i]),]
    y[i]<-round(nrow(x)*p[i]) 
    if(y[i]==0){y[i]=1}
    
  }
  if(count_occ>=2100){
    
    smple<-strata(ocurr_sp, stratanames = c("country"), size = y, method = "srswor")
    ocurr_sp<-ocurr_sp[smple$ID_unit,]
    
  }else{
    
    ocurr_sp<-ocurr_sp
  }
  
  ocurr_sp_out<-data.frame(ocurr_sp)
  s<-paste0(folder_nosea, "/", "sampling"); if(!file.exists(s)){dir.create(s)}
  write.csv(ocurr_sp_out, paste0(s,"/",species, ".csv"), quote = F, row.names = F, sep=",")
  

}

#Testing the function##
#sampling(species)




  