#María Victoria Díaz
#CIAT,2018

################################### REGIONS TO MAP ############################

# This function summarizes the "min","max","mean","exsitu",or "insitu" (or all) values for each subregion where the species are located

# @param (string) ind_dir: The folder where the indicators are located
# @param (char) date: Creation date of the indicator to summarize.
# @param (int) feature: Choose 1,2,3,4 or 5:  1=min, 2=max, 3=mean, 4=exsitu, 5=insitu. 
# @param (string) priority: Choose: "P_HP", "P_MP", "P_LP_SC"(comprehensiveness indicator). Or a vector with all priority levels
# @param (string) folder: Folder name where the summary will be save
# @param (string) name_f: if feature is 1: name_f = min. 2:  name_f =max. 3: name_f = mean. 4: name_f = exsitu. 5: name_f = insitu. 
# @param (logical) richness: FALSE by default. TRUE if you want to know the species richness in each subregion and the continent it is located. 
# @return (dataframe): This function return .csv file with the summary of the priority (or comprehensiveness) indicator for all subregions

####################### START ########################################

#Load the packages
require(raster);require(countrycode);require(maptools);require(rgdal)

base_dir = "//dapadfs"
repo_dir = "//dapadfs/Workspace_cluster_9/Aichi13/runs/src"

# Load the sources script
source(paste0(repo_dir,"/config.R"))

#Load world shapefile
config(dirs=T)
load(file=paste0(par_dir, "/gadm/shapefile/gadm28ISO.RDS"))
config(dirs=F, cleaning=T, insitu=T, exsitu=T, modeling=T, premodeling=T)


names_subreg<-countrycode(countries_sh$ISO, origin="iso3c", destination = "region")
names_subreg[which(is.na(names_subreg))]<-""
countries_sh$REG<-names_subreg



item<-function(sub_dir,date,feature,priority,folder,name_f,richness=F ){
  
  ind_subregions<-list.files(sub_dir,pattern = ".csv$",full.names = F)
  ind_subregions_un<-gsub("indicator_","",ind_subregions)
  ind_subregions_un<-gsub(".csv","",ind_subregions_un)
  ind_subregions_un<-gsub( date,"",ind_subregions_un)
  ind_subregions_un<-gsub( "_","",ind_subregions_un)
  
  unsd <<- read.csv(paste0(par_dir,"/UNSD/UNSD_Methodology.csv"), sep=",", header=T)
  sub <- read.csv(paste0(par_dir,"/UNSD/subregions1.csv"), sep="," , header=T)
  
  y<-list(); src<-list(); irc<-list()
  
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
    z[[i]]<-cbind(as.character(unique(s[[i]][,4])), unique(s[[i]][,5]))
  }
  
  
  zz<-do.call(rbind, z)
  
  
  sub_list<-lapply(1:length(ind_subregions),function(i){
    if(length(priority)==1){
      x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
      x<-x[feature,priority]
      x<-t(x)
      x<-as.data.frame(cbind(as.character(zz[i,2]),zz[i,1],x))
      colnames(x)<-c("Region codes","sub continents","index") 
      
      #  x<-as.data.frame(cbind(zz[i,1],x)) ## Run if you don't want to know the Region code
      # colnames(x)<-c("sub continents","index") 
      
    }else{if(length(priority)==3){
      
      x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
      x<-x[feature,priority] #when priority=c("P_HP","P_MP", "P_LP_SC")
      x<-as.data.frame(cbind(as.character(zz[i,2]),zz[i,1],x))
      colnames(x)<-c("Region codes","sub continents","HP","MP","LP_SC")
    }}
    return(x)
  })
  
  sub_list<-do.call(rbind, sub_list)
  write.csv(sub_list,paste(sub_dir,"/to_graph/",folder,"/regions_",name_f,".csv", sep=""),row.names=F,quote=F,na="",sep=",")
  
  ############## write a js object #################
  
  if(length(priority)==1){
    subr<-c()
    index<-c()
    for(i in 1:nrow(sub_list)){
      
      subr[i]<-gsub(sub_list$`Region codes`[i], paste0("['",sub_list$`Region codes`[i],"','"), sub_list$`Region codes`[i])
      index[i]<-gsub(sub_list$mean[i], paste0("',",sub_list$mean[i],"],"), sub_list$mean[i])
    }
    
    index[22]<-gsub("],", "]];", index)
    sub_list_js<-sub_list[,c(1,2,5)]
    sub_list_js<-cbind(subr,sub_list_js)
    sub_list_js<-cbind(sub_list_js,index)
    sub_list_js<-sub_list_js[,-c(2,4)]
    x<-which(!is.na(sub_list_js$index))
    sub_list_js<-sub_list_js[x,]
    colnames(sub_list_js)<-c("var data=[['Region codes',","'Sub continents',", "'Index'],")
    
    write.table(sub_list_js,paste(sub_dir,"/to_graph/",folder,"/regions_",name_f,".js", sep=""),row.names=F,quote=F,na="")
    
  }else{if(length(priority)==3 & richness){
    
    ############### write .js object summary of scores and comprehensiveness indicator, and add richness (and/or continent)  for each region ######
    
    regions<-read.csv("//dapadfs/Workspace_cluster_9/Aichi13/parameters_201802/UNSD/SUBREGIONS-CONTINENTS1.csv", header = T)
    count_reg<-read.csv("//dapadfs/Workspace_cluster_9/Aichi13/parameters_201802/UNSD/counts_regions.csv", header = T)
    
    r<-c();mp<-c();hp<-c();lp<-c();cont<-list();cont1<-c();counts<-c()
    
    
    for(i in 1:nrow(sub_list)){
      cat(i,"\n")
      
      r[i]<-gsub(sub_list$`sub continents`[i], paste0("['",sub_list$`sub continents`[i],"'"), sub_list$`sub continents`[i])
      lp[i]<-gsub(sub_list$LP_SC[i], paste0(sub_list$LP_SC[i],","), sub_list$LP_SC[i])
      mp[i]<-gsub(sub_list$MP[i], paste0(",",sub_list$MP[i],","), sub_list$MP[i])
      hp[i]<-gsub(sub_list$HP[i], paste0(",",sub_list$HP[i]), sub_list$HP[i])
      counts[i]<-count_reg[which(as.character(count_reg$region) %in% as.character(sub_list$`sub continents`[i])),"number_species"]
      counts[i]<-gsub(counts[i], paste0(counts[i],"],"), counts[i])
      #cont[[i]]<-subset(regions, as.character(regions$SUBREGIONS) %in% as.character(sub_list$`sub continents`[i]))
      #cont1[i]<-unique(as.character(cont[[i]]$continent))
      #cont1[i]<-gsub(cont1[i], paste0("'",cont1[i],"'],"), cont1[i])
      
      
    }
    
    counts[22]<-gsub("],", "]];", counts[22])
    sub_list<-cbind(r,sub_list,hp,mp,lp)
    sub_list<-cbind(sub_list,counts)
    sub_list<-sub_list[,-c(2,3,4,5,6)]
    colnames(sub_list)<-c("var data=[['Sub-continent',","'HP',", "'MP',", "'LP_SC',","'Richness'],")
    
    write.table(sub_list,paste(sub_dir,"/to_graph/all_cat_",name_f, ".js", sep=""),row.names=F,quote=F,na="") #change acording to mean, min, max,exsitu or insitu score you want to analyze
    
    
    
  }}
  
  
}



#### TEST THE FUNCTION ######

#sub_dir<-paste0(root,"/indicator/subregions")
#item(sub_dir, date="2018-04-30", feature=1, priority=c("P_HP","P_MP","P_LP_SC"), folder = "ALL", name_f = "min", richness = T)












