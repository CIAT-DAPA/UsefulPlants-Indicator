#Maria Victoria Diaz Lopez
#CIAT 2018

################################### TO GRAPH ############################
#Function to make a summary of the main priority (or comprehensiveness) indicators for each catgeorie of uses in the species

# @param (string) ind_dir: The folder where the indicators are located
# @param (char) date: Creation date of the indicator to summarize.
# @param (string) feature: Choose 1,2,3,4 and/or 5:  1=min, 2=max, 3=mean, 4=exsitu, 5=insitu. 
# @param (string) priority: Choose: "P_HP", "P_MP",and/or "P_LP_SC"(comprehensiveness indicator).
# @param (string) prior_name: if priority is "P_HP": prior_name = "HP". "P_MP":  prior_name ="MP". "P_LP_SC": prior_name = "LP_SC". 
# @param (string) feat_name: if feature 1: feat_name="min". 2: feat_name="max", 3: feat_name="mean", 4: feat_name="exsitu", 5: feat_name="insitu"  
# @return (dataframe): This function return .csv file with the summary of the priority (or comprehensiveness) indicator for all uses

####################### START ########################################

base_dir = "//dapadfs"
repo_dir = "//dapadfs/Workspace_cluster_9/Aichi13/runs/src"

# Load the sources script
source(paste0(repo_dir,"/config.R"))
config(dirs = T)
ind_dir<-paste0(root,"/","indicator")

item<-function(ind_dir, date,feature,priority,prior_name,feat_name){
  
  ind_us_dir<-paste0(ind_dir,"/uses")
  ind_uses<-list.files(ind_us_dir,pattern = ".csv$",full.names = F)
  ind_uses1<-gsub("indicator_","",ind_uses)
  ind_uses1<-gsub(".csv","",ind_uses1)
  ind_uses1<-gsub(date,"",ind_uses1)
  ind_uses1<-gsub("_","",ind_uses1)
  
  if(length(priority)==3){
    
    opt_list<-lapply(1:length(ind_uses),function(i){
      
      u<-read.csv(paste0(ind_us_dir,"/",ind_uses[[i]]),header=T)
      u<-u[feature,priority]
      u<-as.data.frame(cbind(as.character(ind_uses1[[i]]),u))
      colnames(u)<-c("uses",priority)
      return(u)
    })
    
    opt_list<-do.call(rbind,opt_list)
    write.csv(opt_list,paste(ind_us_dir,"/to_graph/ALL/uses11.csv",sep = ""),row.names=F,quote=F,na="")
    
    ## 1.FIRST ... 
    
    hp<-c()
    mp<-c()
    Uses<-c()
    index<-c()
    for(i in 1:nrow(opt_list)){
      
      Uses[i]<-gsub(opt_list$uses[i], paste0("['",opt_list$uses[i],"',"), opt_list$uses[i])
      hp[i]<-gsub(opt_list$P_HP[i], paste0(opt_list$P_HP[i],","), opt_list$P_HP[i])
      mp[i]<-gsub(opt_list$P_MP[i], paste0(opt_list$P_MP[i],","), opt_list$P_MP[i])
      index[i]<-gsub(opt_list$P_LP_SC[i], paste0(opt_list$P_LP_SC[i],","), opt_list$P_LP_SC[i])
    }
    
    new1<-rep("'bar {'+'stroke-width: 10;' +'stroke-color: #E54D24}',", nrow(opt_list))
    new1.1<-rep("'bar {'+'stroke-width: 10;' +'stroke-color: #F0CB69}',", nrow(opt_list))
    new<-rep("'bar {'+'stroke-width: 10;' +'stroke-color: #12A356}'],", nrow(opt_list))
    opt_list1<-cbind(Uses, hp)
    opt_list1<-cbind(opt_list1,new1,mp,new1.1,index,new)
    
    opt_list1[11,"new"]<-gsub("],", "]];", opt_list1[11,"new"])
    colnames(opt_list1)<-c("var data=[['uses',", " '%HP species',","{ role: 'style' },","'%MP species', ","{ role: 'style' },","'%LP&SC species',", " { role: 'style' }],")
    rm(new1,new1.1,new)
    
    ## 2.SECOND ...
    ########## INSITU ##########
    
    feature1=4
    opt_list<-lapply(1:length(ind_uses),function(i){
      
      u<-read.csv(paste0(ind_us_dir,"/",ind_uses[[i]]),header=T)
      u<-u[feature1,priority]
      u<-as.data.frame(cbind(as.character(ind_uses1[[i]]),u))
      colnames(u)<-c("uses",priority)
      return(u)
    })
    
    opt_list<-do.call(rbind,opt_list)
    
    ##########################
    ### CREATE A JS OBJECT TO MAKE A BAR CHART FOR SUMMARIZING THE RESULTS
    ### IT'S GOING TO JOIN ONE FEATURE (min,max or mean),WITH in-situ FEATURE, TO COMPARE THE RESULTS
    ##########################
    
    hp<-c()
    mp<-c()
    Uses<-c()
    index<-c()
    for(i in 1:nrow(opt_list)){
      
      Uses[i]<-gsub(opt_list$uses[i], paste0("['",opt_list$uses[i]," in situ',"), opt_list$uses[i])
      hp[i]<-gsub(opt_list$P_HP[i], paste0(opt_list$P_HP[i],","), opt_list$P_HP[i])
      mp[i]<-gsub(opt_list$P_MP[i], paste0(opt_list$P_MP[i],","), opt_list$P_MP[i])
      index[i]<-gsub(opt_list$P_LP_SC[i], paste0(opt_list$P_LP_SC[i],","), opt_list$P_LP_SC[i])
    }
    
    new1.2<-rep("'',", nrow(opt_list))
    new1.3<-rep("''],", nrow(opt_list))
    opt_list1.1<-cbind(Uses, hp)
    opt_list1.1<-cbind(opt_list1.1,new1.2,mp,new1.2,index,new1.3)
    
    
    opt_list1.1[11,"new1.3"]<-gsub("],", "]];", opt_list1.1[11,"new1.3"])
    colnames(opt_list1.1)<-c("var data=[['uses',", " '%HP species',","{ role: 'style' },","'%MP species', ","{ role: 'style' },","'%LP&SC species',", " { role: 'style' }],")
    rm(new1.2,new1.3)
    
    ## 3.THIRD ...
    ########## EXSITU ##########
    
    feature1=5
    opt_list<-lapply(1:length(ind_uses),function(i){
      
      u<-read.csv(paste0(ind_us_dir,"/",ind_uses[[i]]),header=T)
      u<-u[feature1,priority]
      u<-as.data.frame(cbind(as.character(ind_uses1[[i]]),u))
      colnames(u)<-c("uses",priority)
      return(u)
    })
    
    opt_list<-do.call(rbind,opt_list)
    
    ##########################
    ### CREATE A JS OBJECT TO MAKE A BAR CHART FOR SUMMARIZING THE RESULTS
    ### IT'S GOING TO JOIN ONE FEATURE (min,max or mean),WITH ex-situ FEATURE, TO COMPARE THE RESULTS
    ##########################
    
    
    hp<-c()
    mp<-c()
    Uses<-c()
    index<-c()
    for(i in 1:nrow(opt_list)){
      
      Uses[i]<-gsub(opt_list$uses[i], paste0("['",opt_list$uses[i]," ex situ',"), opt_list$uses[i])
      hp[i]<-gsub(opt_list$P_HP[i], paste0(opt_list$P_HP[i],","), opt_list$P_HP[i])
      mp[i]<-gsub(opt_list$P_MP[i], paste0(opt_list$P_MP[i],","), opt_list$P_MP[i])
      index[i]<-gsub(opt_list$P_LP_SC[i], paste0(opt_list$P_LP_SC[i],","), opt_list$P_LP_SC[i])
    }
    
    new1.4<-rep("'',", nrow(opt_list))
    new1.5<-rep("''],", nrow(opt_list))
    opt_list1.2<-cbind(Uses, hp)
    opt_list1.2<-cbind(opt_list1.2,new1.4,mp,new1.4,index,new1.5)
    
    
    opt_list1.2[11,"new1.5"]<-gsub("],", "]];", opt_list1.2[11,"new1.5"])
    colnames(opt_list1.2)<-c("var data=[['uses',", " '%HP species',","{ role: 'style' },","'%MP species', ","{ role: 'style' },","'%LP&SC species',", " { role: 'style' }],")
    
    rm(new1.4,new1.5)
    
    ## 4.FOURTH ...
    ########## JOIN ##########
    
    new<-rep(",''],", nrow(opt_list))
    new1<-rep("['',", nrow(opt_list))
    new2<-rep(0, nrow(opt_list))
    new3<-rep(",'',", nrow(opt_list))
    new_row<-cbind(new1,new2,new3,new2,new3,new2,new)
    new_row<-as.data.frame(new_row)
    colnames(new_row)<-colnames(opt_list1)
    opt_list1.1<-as.data.frame(opt_list1.1);opt_list1.2<-as.data.frame(opt_list1.2);opt_list1<-as.data.frame(opt_list1)
    opt_list_n<-data.frame()
    
    for(i in 1:nrow(opt_list1)){
      
      opt_list_n<-rbind(opt_list_n,new_row[i,],opt_list1[i,],new_row[i,],new_row[i,],opt_list1.1[i,],new_row[i,],opt_list1.2[i,],new_row[i,],new_row[i,],new_row[i,],new_row[i,])
      
    }
    
    opt_list_n<-opt_list_n[-c(118,119,120,121),]
    opt_list_n<-as.data.frame(opt_list_n)
    rm(new,new1,new2,new3)
    
    #NOTE: You have to delete "]];" in Social indicator row, and relaplace it for "],"
    
    write.table(opt_list_n,paste(ind_us_dir,"/to_graph/all/uses_comb11", ".js", sep=""),row.names=F,quote=F,na="")
    
    
  }else{ if(length(feature)==1){
    
    opt_list<-lapply(1:length(ind_uses),function(i){
      u<-read.csv(paste0(ind_us_dir,"/",ind_uses[[i]]),header=T)
      u<-u[feature,priority]
      u<-as.data.frame(cbind(as.character(ind_uses1[[i]]),u))
      colnames(u)<-c("uses",priority)
      return(u)
    })
    
    opt_list<-do.call(rbind,opt_list)
    write.csv(opt_list,paste(ind_us_dir,"/to_graph/",feat_name,"/",prior_name,"1.csv",sep = ""),row.names=F,quote=F,na="")
    
    
  }else{
    
    opt_list<-lapply(1:length(ind_uses),function(i){
      
      u<-read.csv(paste0(ind_us_dir,"/",ind_uses[[i]]),header=T)
      u1<-u[feature ,priority]
      u1<-t(u1)
      u1<-as.data.frame(cbind(as.character(ind_uses1[[i]]),u1))
      colnames(u1)<-c("uses",as.character(u[feature,"opt"]))
      return(u1)
    })
    
    opt_list<-do.call(rbind,opt_list)
    write.csv(opt_list,paste(ind_dir,"/to_graph/",prior_name,"/uses_all1.csv",sep = ""),row.names=F,quote=F,na="")
    
    
  }
    
    
  }
  
}




#####TEST THE FUNCTION ##########

#item(ind_dir, date="2018-04-30", feature=4, priority = "P_HP",prior_name ="HP", feat_name = "exsitu")
#item(ind_dir, date="2018-04-30", feature=1, priority = c("P_HP","P_MP","P_LP_SC"))
