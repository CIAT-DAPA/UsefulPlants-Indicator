#Maria Victoria Diaz Lopez
#CIAT 2018

################################### TO GRAPH ############################
#Function to make a summary of the main priority (or comprehensiveness) indicators for each subregion

# @param (string) sub_dir: The folder where the indicators are located
# @param (char) date: Creation date of the indicator to summarize.
# @param (string) feature: Choose 1,2,3,4 and/or 5:  1=min, 2=max, 3=mean, 4=exsitu, 5=insitu. 
# @param (string) priority: Choose: "P_HP", "P_MP",and/or "P_LP_SC"(comprehensiveness indicator).
# @param (string) prior_name: if priority is "P_HP": prior_name = "HP". "P_MP":  prior_name ="MP". "P_LP_SC": prior_name = "LP_SC". 
# @param (string) feat_name: if feature 1: feat_name="min". 2: feat_name="max", 3: feat_name="mean", 4: feat_name="exsitu", 5: feat_name="insitu"  
# @param (logical) richness: FALSE by default. TRUE if you want to know the species richness in each subregion. 
# @return (dataframe): This function return .csv file with the summary of the priority (or comprehensiveness) indicator for all subregions

####################### START ########################################



require(raster);require(countrycode);require(maptools);require(rgdal)

base_dir = "//dapadfs"
config(dirs=T)
#load(file=paste0(par_dir, "/gadm/shapefile/gadm28ISO.RDS"))
#config(dirs=F, cleaning=T, insitu=T, exsitu=T, modeling=T, premodeling=T)

sub_dir<-paste0(root,"/indicator/subregions")
#names_subreg<-countrycode(countries_sh$ISO, origin="iso3c", destination = "region")
#names_subreg[which(is.na(names_subreg))]<-""
#countries_sh$REG<-names_subreg

item<-function(sub_dir, date, feature,priority,prior_name,feat_name){
  
  ind_subregions<-list.files(sub_dir,pattern = ".csv$",full.names = F)
  ind_subregions_un<-ind_subregions
  ind_subregions_un<-gsub("indicator_","",ind_subregions_un)
  ind_subregions_un<-gsub(".csv","",ind_subregions_un)
  ind_subregions_un<-gsub( date,"",ind_subregions_un)
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
    z[[i]]<-cbind(as.character(unique(s[[i]][,4])), unique(s[[i]][,5]))
  }
  
  zz<-do.call(rbind, z)
  
  
  if(length(priority)==3){
    
    
    sub_list<-lapply(1:length(ind_subregions),function(i){
      x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
      x<-x[feature,priority]
      #x<-t(x)
      x<-as.data.frame(cbind(zz[i,1],x))
      colnames(x)<-c("Sub continents",priority)
      return(x)
    })
    
    
    
    sub_list<-do.call(rbind,sub_list)
    write.csv(sub_list,paste(sub_dir,"/to_graph/all_cat_",feat_name,"1.csv", sep=""),row.names=F,quote=F,na="")
    
    
    regions<-c("America","Africa","Asia","Europe","Caribbean", "Melanesia", "Micronesia", "Polynesia","Australia")
    
    filter<-list()
    for(i in 1:length(regions)){
      filter[[i]]<- grep(regions[i], sub_list$`Sub continents`, ignore.case=TRUE)
      
    }
    
    f<-unlist(filter)
    sub_list<- sub_list[f,]
    
    
    
    ## 1.FIRST ... 
    
    # regions<-read.csv("//dapadfs/Workspace_cluster_9/Aichi13/parameters_201802/UNSD/SUBREGIONS-CONTINENTS1.csv", header = T)
    # count_reg<-read.csv("//dapadfs/Workspace_cluster_9/Aichi13/parameters_201802/UNSD/counts_regions.csv", header = T)
    
    r<-c()
    mp<-c()
    hp<-c()
    lp<-c()
    # cont<-list()
    # cont1<-c()
    # counts<-c()
    
    
    for(i in 1:nrow(sub_list)){
      cat(i,"\n")
      
      r[i]<-gsub(sub_list$`Sub continents`[i], paste0("['",sub_list$`Sub continents`[i],"',"), sub_list$`Sub continents`[i])
      lp[i]<-gsub(sub_list$P_LP_SC[i], paste0(sub_list$P_LP_SC[i],","), sub_list$P_LP_SC[i])
      mp[i]<-gsub(sub_list$P_MP[i], paste0(sub_list$P_MP[i],","), sub_list$P_MP[i])
      hp[i]<-gsub(sub_list$P_HP[i], paste0(sub_list$P_HP[i], ","), sub_list$P_HP[i])
      #counts[i]<-count_reg[which(as.character(count_reg$region) %in% as.character(sub_list$`sub continents`[i])),"number_species"]
      #counts[i]<-gsub(counts[i], paste0(counts[i],"],"), counts[i])
      #cont[[i]]<-subset(regions, as.character(regions$SUBREGIONS) %in% as.character(sub_list$`sub continents`[i]))
      #cont1[i]<-unique(as.character(cont[[i]]$continent))
      #cont1[i]<-gsub(cont1[i], paste0("'",cont1[i],"'],"), cont1[i])
      
      
    }
    
    new1<-rep("'bar {'+'stroke-width: 10;' +'stroke-color: #E54D24}'],", nrow(sub_list))
    new1.1<-rep("'bar {'+'stroke-width: 10;' +'stroke-color: #F0CB69}',", nrow(sub_list))
    new<-rep("'bar {'+'stroke-width: 10;' +'stroke-color: #12A356}',", nrow(sub_list))
    
    
    
    sub_list1<-cbind(r, lp)
    sub_list1<-cbind(sub_list1,new,mp,new1.1,hp,new1)
    
    colnames(sub_list1)<-c("var data=[['Sub-continent',", " 'Low Priority and Sufficiently Conserved',","{ role: 'style' },","'Medium Priority', ","{ role: 'style' },","'High Priority',", " { role: 'style' }],")
    rm(new1,new1.1,new)
    
    
    # write.table(sub_list1,paste(sub_dir,"/to_graph/all_cat_",feature ,"1.js", sep=""),row.names=F,quote=F,na="") 
    
    
    ## 2.SECOND ...
    
    ########## INSITU ##########
    
    feature1=4
    
    
    sub_list<-lapply(1:length(ind_subregions),function(i){
      
      x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
      x<-x[feature1,priority]
      x<-as.data.frame(cbind(zz[i,1],x))
      colnames(x)<-c("Sub continents",priority)
      return(x)
    })
    
    sub_list<-do.call(rbind,sub_list)
    write.csv(sub_list,paste(sub_dir,"/to_graph/all_cat_insitu","1.csv", sep=""),row.names=F,quote=F,na="")
    
    filter<-list()
    for(i in 1:length(regions)){
      filter[[i]]<- grep(regions[i], sub_list$`Sub continents`, ignore.case=TRUE)
      
    }
    
    f<-unlist(filter)
    sub_list<- sub_list[f,]
    
    
    ##########################
    ### CREATE A JS OBJECT TO MAKE A BAR CHART FOR SUMMARIZING THE RESULTS
    ### IT'S GOING TO JOIN ONE FEATURE (min,max or mean),WITH in-situ FEATURE, TO COMPARE THE RESULTS
    ##########################
    
    r<-c()
    mp<-c()
    hp<-c()
    lp<-c()
    
    for(i in 1:nrow(sub_list)){
      cat(i,"\n")
      
      r[i]<-gsub(sub_list$`Sub continents`[i], paste0("['",sub_list$`Sub continents`[i]," (in situ)',"), sub_list$`Sub continents`[i])
      lp[i]<-gsub(sub_list$P_LP_SC[i], paste0(sub_list$P_LP_SC[i],","), sub_list$P_LP_SC[i])
      mp[i]<-gsub(sub_list$P_MP[i], paste0(sub_list$P_MP[i],","), sub_list$P_MP[i])
      hp[i]<-gsub(sub_list$P_HP[i], paste0(sub_list$P_HP[i],","), sub_list$P_HP[i])
      
    }
    new1<-rep("'',", nrow(sub_list))
    new<-rep("''],", nrow(sub_list))
    sub_list1.1<-cbind(r,lp )
    sub_list1.1<-cbind(sub_list1.1,new1,mp,new1,hp,new)
    
    
    sub_list1.1[22,"new"]<-gsub("],", "]];", sub_list1.1[22,"new"])
    colnames(sub_list1.1)<-c("var data=[['Sub-continent',", " 'Low Priority and Sufficiently Conserved',","{ role: 'style' },","'Medium Priority', ","{ role: 'style' },","'High Priority',", " { role: 'style' }],")
    
    #   write.table(sub_list1.1,paste(sub_dir,"/to_graph/all_cat_",feature1, ".js", sep=""),row.names=F,quote=F,na="")
    
    
    rm(new1,new)
    
    
    
    ## 3.THIRD ...
    
    ########## EXSITU ##########
    
    feature1=5
    
    
    sub_list<-lapply(1:length(ind_subregions),function(i){
      
      x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
      x<-x[feature1,priority]
      x<-as.data.frame(cbind(zz[i,1],x))
      colnames(x)<-c("Sub continents",priority)
      return(x)
    })
    
    sub_list<-do.call(rbind,sub_list)
    write.csv(sub_list,paste(sub_dir,"/to_graph/all_cat_exsitu","1.csv", sep=""),row.names=F,quote=F,na="")
    
    filter<-list()
    for(i in 1:length(regions)){
      filter[[i]]<- grep(regions[i], sub_list$`Sub continents`, ignore.case=TRUE)
      
    }
    
    f<-unlist(filter)
    sub_list<- sub_list[f,]
    
    
    ##########################
    ### CREATE A JS OBJECT TO MAKE A BAR CHART FOR SUMMARIZING THE RESULTS
    ### IT'S GOING TO JOIN ONE FEATURE (min,max or mean),WITH ex-situ FEATURE, TO COMPARE THE RESULTS
    ##########################
    
    
    r<-c()
    mp<-c()
    hp<-c()
    lp<-c()
    
    for(i in 1:nrow(sub_list)){
      cat(i,"\n")
      
      r[i]<-gsub(sub_list$`Sub continents`[i], paste0("['",sub_list$`Sub continents`[i]," (ex situ)',"), sub_list$`Sub continents`[i])
      lp[i]<-gsub(sub_list$P_LP_SC[i], paste0(sub_list$P_LP_SC[i],","), sub_list$P_LP_SC[i])
      mp[i]<-gsub(sub_list$P_MP[i], paste0(sub_list$P_MP[i],","), sub_list$P_MP[i])
      hp[i]<-gsub(sub_list$P_HP[i], paste0(sub_list$P_HP[i], ","), sub_list$P_HP[i])
      
    }
    new1<-rep("'',", nrow(sub_list))
    new<-rep("''],", nrow(sub_list))
    sub_list1.2<-cbind(r,lp )
    sub_list1.2<-cbind(sub_list1.2,new1,mp,new1,hp,new)
    
    
    #sub_list1.2[22,"new"]<-gsub("],", "]];", sub_list1.2[22,"new"])
    colnames(sub_list1.2)<-c("var data=[['Sub-continent',", " 'Low Priority and Sufficiently Conserved',","{ role: 'style' },","'Medium Priority', ","{ role: 'style' },","'High Priority',", " { role: 'style' }],")
    
    #  write.table(sub_list1.2,paste(sub_dir,"/to_graph/all_cat_",feature1, ".js", sep=""),row.names=F,quote=F,na="")
    
    rm(new1,new)
    
    ## 4.FOURTH ...
    
    ########## JOIN ##########
    
    new<-rep(",''],", nrow(sub_list))
    new1<-rep("['',", nrow(sub_list))
    new2<-rep(0, nrow(sub_list))
    new3<-rep(",'',", nrow(sub_list))
    new_row<-cbind(new1,new2,new3,new2,new3,new2,new)
    new_row<-as.data.frame(new_row)
    colnames(new_row)<-colnames(sub_list1)
    sub_list1.1<-as.data.frame(sub_list1.1);sub_list1.2<-as.data.frame(sub_list1.2);sub_list1<-as.data.frame(sub_list1)
    sub_list_n<-data.frame()
    
    for(i in 1:nrow(sub_list1)){
      
      sub_list_n<-rbind(sub_list_n,new_row[i,],sub_list1[i,],new_row[i,],new_row[i,],sub_list1.2[i,],new_row[i,],sub_list1.1[i,],new_row[i,],new_row[i,],new_row[i,])
      
    }
    
    sub_list_n<-sub_list_n[-c(220,219,218),]
    sub_list_n<-as.data.frame(sub_list_n)
    rm(new,new1,new2,new3)
    
    #NOTE: You have to delete "]];" in Social indicator row, and relaplace it for "],"
    
    write.table(sub_list_n,paste(sub_dir,"/to_graph/all_cat_comb.js", sep=""),row.names=F,quote=F,na="")
    
    
    
    
  }else{ if(length(feature)==1){
    
    
    sub_list<-lapply(1:length(ind_subregions),function(i){
      
      x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
      x<-x[feature1,priority]
      x<-as.data.frame(cbind(zz[i,1],x))
      colnames(x)<-c("Sub continents",priority)
      return(x)
    })
    
    sub_list<-do.call(rbind,sub_list)
    
    regions<-c("America","Africa","Asia","Europe","Caribbean", "Melanesia", "Micronesia", "Polynesia","Australia")
    
    filter<-list()
    for(i in 1:length(regions)){
      filter[[i]]<- grep(regions[i], sub_list$`Sub continents`, ignore.case=TRUE)
      
    }
    
    f<-unlist(filter)
    sub_list<- sub_list[f,]
    
    write.csv(sub_list,paste(sub_dir,"/to_graph/", prior_name, "/",feat_name, ".csv", sep=""),row.names=F,quote=F,na="")
    
    
    
    
  }else{
    
    
    sub_list<-lapply(1:length(ind_subregions),function(i){
      
      x<-read.csv(paste0(sub_dir,"/",ind_subregions[[i]]),header=T)
      x1<-x[feature ,priority]
      x1<-t(x1)
      x1<-as.data.frame(cbind(zz[i,1],x1))
      colnames(x1)<-c("Sub continents",as.character(x[feature,"opt"]))
      return(x1)
    })
    
    sub_list<-do.call(rbind,sub_list)
    
    regions<-c("America","Africa","Asia","Europe","Caribbean", "Melanesia", "Micronesia", "Polynesia","Australia")
    
    filter<-list()
    for(i in 1:length(regions)){
      filter[[i]]<- grep(regions[i], sub_list$`Sub continents`, ignore.case=TRUE)
      
    }
    
    f<-unlist(filter)
    sub_list<- sub_list[f,]
    
    write.csv(sub_list,paste(sub_dir,"/to_graph/", prior_name, "/regions_all.csv", sep=""),row.names=F,quote=F,na="")
    
    
  }
    
    
    
    
    
    
    
  }
  
}







#####TEST THE FUNCTION ##########

#item(sub_dir, date="2018-05-15", feature=4, priority = "P_HP",prior_name ="HP", feat_name = "exsitu")
#item(sub_dir, date="2018-05-15", feature=3, priority = c("P_HP","P_MP","P_LP_SC"),feat_name="mean")
#item(sub_dir, date="2018-05-15", feature=c(2,3), priority = "P_HP",prior_name ="HP", feat_name = "exsitu")


