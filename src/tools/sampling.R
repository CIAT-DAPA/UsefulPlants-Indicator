#Maria Victoria Diaz
#CIAT, 2018

# This function makes a stratified sampling of the species that have more than 2000 ocurrences
# @param (string) species: Species ID.
# @return (dataFrame): This function return a DataFrame with a sample of the total records of the species. 

#species="5358748"
#library(devtools)
#install_github("DFJL/SamplingUtil")
#library(SamplingUtil)

sampling<-function(species){
  
  config(dirs=T, cleaning=T)
  
  ocurr_sp<- read.csv(paste0(folder_nosea, "/original/", species, "_original.csv"), header=T,sep=",")
  ocurr_sp<-as.data.frame(ocurr_sp)
  count_occ<-nrow(ocurr_sp)
  # ocurr_sp$num<-NA
  # ocurr_sp$num<-seq(from=1,to=count_occ,by=1)
  #ocurr_sp<-cbind(ocurr_sp,ocurr_sp$num )
  countries<- unique(na.omit(ocurr_sp$country))
  p<-c()
  n<-c()
  x<-data.frame()
  y<-c()
  muestra<-list()
  
  
  for(i in 1:length(countries)){
    
    n[i]<-nrow(ocurr_sp[which(ocurr_sp$country==countries[i]),])
    p[i]<-n[i]/count_occ
    
  }
  if(count_occ>=2100){
    
    nsizeProp<-nstrata(n=2000,wh=p,method="proportional")
    smple<-list()
    for(i in 1:length(countries)){
      smple[[i]]<-sample(rownames(ocurr_sp[which(ocurr_sp$country==countries[i]),]), size=nsizeProp[i], replace=F)
      muestra[[i]]<-ocurr_sp[smple[[i]],]
      
    }
    
    muestra<- do.call(rbind, muestra)
    
    
  }else{
    
    muestra<-ocurr_sp
  }
  
  ocurr_sp_out<-data.frame(muestra)
  write.csv(ocurr_sp_out, paste0(folder_nosea,"/",species, ".csv"), quote = F, row.names = F)
  return(ocurr_sp_out)
  
  
}

#Testing the function##
#sampling(species)




