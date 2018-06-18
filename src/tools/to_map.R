#Maria Victoria Diaz Lopez
#CIAT 2018

################################### TO MAP ############################
#Function to make a summary of the main priority (or comprehensiveness) indicators at country level, in order to map the results.

# @param (string) ind_dir: The folder where the indicators are located
# @param (char) date: Creation date of the indicator to summarize.
# @param (string) feature: Choose 1,2,3,4 or 5:  1=min, 2=max, 3=mean, 4=exsitu, 5=insitu. 
# @param (string) priority: Choose: "P_HP", "P_MP", "P_LP_SC"(comprehensiveness indicator). Or a vector with all priority levels
# @param (string) folder: Folder name where the summary will be save
# @param (string) name_f: if feature is 1: name_f = min. 2:  name_f =max. 3: name_f = mean. 4: name_f = exsitu. 5: name_f = insitu. 
# @param (logical) richness: FALSE by default. TRUE if you want to know the species richness in each country and the continent and subregion it is located. 
# @return (dataframe): This function return .csv file with the summary of the priority (or comprehensiveness) indicator for all countries

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

iso2c_shp<- countrycode(countries_sh$ISO,"iso3c","iso2c")
iso2c_shp[which(is.na(iso2c_shp))]<-""
countries_sh$ISO2<-iso2c_shp

item<-function(ind_dir,date,feature,priority,folder,name_f,richness=F){
  
  ind_iso_dir<-paste0(ind_dir,"/","countries") 
  ind_countries<-list.files(ind_iso_dir,pattern= ".csv$",full.names = F)
  ind_countries_iso2<-gsub("_","",ind_countries) 
  ind_countries_iso2<-gsub(date,"",ind_countries_iso2) 
  ind_countries_iso2<-gsub(".csv","",ind_countries_iso2)
  
  countries<-lapply(1:length(ind_countries), function(i){
    
    x<-read.csv(paste0(ind_iso_dir,"/",ind_countries[[i]]),header=T)
    
    if(length(priority)== 1){
      x<-x[feature,priority]
      x<-t(x)
      x<-base::as.data.frame(cbind(as.character(ind_countries_iso2[[i]]),x))
      colnames(x)<-c("iso2c","index")
      
    }else{
      x<-x[feature,priority]
      x<-base::as.data.frame(cbind(as.character(ind_countries_iso2[[i]]),x))
      colnames(x)<-c("iso2c",priority)
    }
    
    
    return(x)
    
  })  
  count_list<-do.call(rbind,countries)
  coun2<-merge(countries_sh,count_list,by.x="ISO2",by.y="iso2c") 
  write.csv(coun2@data,paste0(ind_iso_dir,"/to_graph/",folder,"/countries_",name_f,".csv"),row.names=F,quote=F,na="")
  
  coun2@data$ISO2
  ######### write .js object ###########
  
  if(length(priority)==1){
    
    regions<-read.csv(paste0(par_dir,"/UNSD/countries-continents-regions.csv"), header = T)
    
    r<-c()
    index<-c()
    country<-c()
    for(j in 1:nrow(coun2@data)){
      
      r[j]<-gsub(coun2@data$ISO2[j], paste0("['",coun2@data$ISO2[j],"',"), coun2@data$ISO2[j])
      index[j]<-gsub(coun2@data$index[j], paste0(coun2@data$index[j],"],"), coun2@data$index[j])
      
      if(coun2@data$ISO[j] %in% regions$ISO3){
        
        country[j]<-unique(as.character(regions[which(regions$ISO3 == coun2@data$ISO[j]), "Country.Name"]))
        country[j]<-gsub(country[j], paste0(" \" ", as.character(country[j])," \" ", ","),country[j])
        
        
        
      }
      
    }
    
    #country[256]<-gsub("],", "]];", country[256])
    index[256]<-gsub("],", "]];", index[256])
    
    data<-cbind(r,country,index)
    # data<-cbind(data,index)
    #  data<-data[,-c(2,3,4)]
    # colnames(data)<-c("var data=[['ISO2',", paste0("'", priority, "',"), "'country name'],") 
    colnames(data)<-c("var data=[['ISO2',","'country name',", "'indicator'],") 
    
    x<-which(!is.na(data[,2]))
    data<-data[x,]
    
    write.table(data,paste0(ind_iso_dir,"/to_graph/",folder,"/countries_",name_f,".js"),row.names=F,quote=F,na="", qmethod = "double")
    
    
  }else{ if(length(priority)==3){
    r<-c()
    mp<-c()
    hp<-c()
    lp<-c()
    for(j in 1:nrow(coun2@data)){
      
      r[j]<-gsub(coun2@data$ISO2[j], paste0("['",coun2@data$ISO2[j],"',"), coun2@data$ISO2[j])
      lp[j]<-gsub(coun2@data$P_LP_SC[j], paste0(coun2@data$P_LP_SC[j],"],"), coun2@data$P_LP_SC[j])
      mp[j]<-gsub(coun2@data$P_MP[j], paste0(coun2@data$P_MP[j],","), coun2@data$P_MP[j])
      hp[j]<-gsub(coun2@data$P_HP[j], paste0(coun2@data$P_HP[j],","), coun2@data$P_HP[j])
    }
    
    lp[256]<-gsub("],", "]];", lp)
    data<-coun2@data[,-2]
    data<-cbind(r,data,hp,mp,lp)
    data<-data[,-c(2,3,4,5)]
    colnames(data)<-c("var data=[['country',","'HP',","'MP',", "'LP_SC'],")
    x<-complete.cases(data)
    cou<-data[x,]
    
    write.table(cou,paste0(ind_iso_dir,"/to_graph/",folder,"/countries_",name_f,".js"),row.names=F,quote=F,na="")
    
    
  }
  }
  
  if(richness & length(priority)==3){
    
    ############### write .js object summary of scores and comprehensiveness indicator, and add richness, continent and subregions for each country ######
    
    regions<-read.csv(paste0(par_dir,"/UNSD/SUBREGIONS-CONTINENTS1.csv"), header = T)
    countries<-read.csv(paste0(par_dir,"/UNSD/counts_countries.csv"), header = T)
    
    r<-c()
    mp<-c()
    hp<-c()
    lp<-c()
    cont<-c()
    aptos<-list()
    counts<-c()
    subr<-c()
    
    for(i in 1:nrow(coun2@data)){
      
      
      r[i]<-gsub(coun2@data$ISO2[i], paste0("['",coun2@data$ISO2[i],"',"), coun2@data$ISO2[i])
      lp[i]<-gsub(coun2@data$P_LP_SC[i], paste0(coun2@data$P_LP_SC[i],","), coun2@data$P_LP_SC[i])
      mp[i]<-gsub(coun2@data$P_MP[i], paste0(coun2@data$P_MP[i],","), coun2@data$P_MP[i])
      hp[i]<-gsub(coun2@data$P_HP[i], paste0(coun2@data$P_HP[i],","), coun2@data$P_HP[i])
      aptos[[i]]<-subset(regions, as.character(regions$ISO3) %in% as.character(coun2@data$ISO[i]))
      
      if(coun2@data$ISO2[i] %in% countries$country ){
        
        counts[i]<-as.numeric(countries[which(as.character(countries$country) == coun2@data$ISO2[i]),"number_species"])
        counts[i]<-gsub(counts[i], paste0(counts[i],","), counts[i])
      }
      if(nrow(aptos[[i]]) != 0){
        cont[i]<-unique(as.character(aptos[[i]]$continent))
        subr[i]<-unique(as.character(aptos[[i]]$SUBREGIONS))
        cont[i]<-gsub(cont[i], paste0("'",cont[i],"',"), cont[i])
        subr[i]<-gsub(subr[i], paste0("'",subr[i],"'],"), subr[i])
        
        
      }else{cont[i]<-NA
      subr[i]<-NA
      }
      
      
      
    }
    
    #WARNING: Namibia's ISO2 is "NA", so, you have to run these 2 lines to include the richness of this country:
    counts[160]<-as.numeric(countries[which(is.na(countries$country)),"number_species"])
    counts[160]<-gsub(counts[160], paste0(counts[160],","), counts[160])
    
    subr[256]<-gsub("],", "]];", subr)
    data<-coun2@data[,-2]
    data<-cbind(r,data,hp,mp,lp)
    data<-cbind(data,counts,cont,subr)
    data<-data[,-c(2,3,4,5)]
    colnames(data)<-c("var data=[['country',","'HP',", "'MP',", "'LP_SC',","'Richness',", "'Continent',", "'Subregions'],")
    x<-which(!is.na(data[,2]))
    data<-data[x,]
    
    
    write.table(data,paste0(ind_dir,"/","countries/to_graph/all_cat_",name_f, ".js"),row.names=F,quote=F,na="") 
    
    
  }
  
  
}


#####TEST THE FUNCTION ########

#ind_dir<-paste0(root,"/","indicator")
#item(ind_dir,date="2018-05-14",feature=4, priority="P_LP_SC", folder="Exsitu", name_f="exs")
#item(ind_dir,date="2018-04-30",feature=2, priority=c("P_HP","P_MP","P_LP_SC"), folder="ALL",name_f="max",richness=T)


