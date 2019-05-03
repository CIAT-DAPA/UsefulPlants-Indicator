#Maria Victoria Diaz Lopez
#CIAT 2018

################################### TO MAP ############################
#Function to make a summary of the main priority (or comprehensiveness) indicators at country level, in order to map the results.

# @param (string) shape: countries_sh 
# @return (dataframe): This function return .csv file with the summary of the priority (or comprehensiveness) indicator for all countries

####################### START ########################################



#Load the packages
require(raster);require(countrycode);require(maptools);require(rgdal); require(rJava); require(rChoiceDialogs)


base_dir = "//dapadfs"
repo_dir = "//dapadfs/Workspace_cluster_9/Aichi13/runs/src"


countries<-function(shape = countries_sh){
  
  cat(paste0("Please select the folder with the country indicators..."), "\n")
  
  setwd(paste0(root, "/indicator"))
  
  ind_dir<-paste0(root, "/indicator")
  ind_iso_dir<- jchoose.dir() 
  
  date<-Sys.Date()
  #date<-"2019-04-24"
  
  
  
  cat(paste0("Listing files ..."), "\n")
  
  ind_countries<-list.files(ind_iso_dir,pattern= ".csv$",full.names = F)
  ind_countries_iso2<-gsub("ind_","",ind_countries) 
  ind_countries_iso2<-gsub(".csv","",ind_countries_iso2)
  ind_countries_iso2<- ind_countries_iso2[-which(ind_countries_iso2 %in% c("AS", "NF"))]
  ind_countries<- ind_countries[-which(ind_countries %in% c("ind_AS.csv", "ind_NF.csv"))]
  
  
  warning("please write the priority level you want to show", immediate. = TRUE, noBreaks. = T)
  
  priority <- readline(prompt="write the priority level you want to show: ") 

  
  
  warning("please write the component you want to show (insitu, exsitu, mean, max or min)", immediate. = TRUE, noBreaks. = T)
  
  component <- readline(prompt="please write the component you want to show: ") 
  
  feature<- ifelse(component == "min", 1,
                   ifelse(component == "max", 2, 
                          ifelse(component == "mean", 3,
                                 ifelse(component == "exsitu", 4,
                                        ifelse(component == "insitu", 5, NA
                                               )))))
 
   
  cat(paste0("Organizing indicator values per country"), "\n")
  
  
  countries<-lapply(1:length(ind_countries), function(i){
    
    cat(i , "\n")
    
    x<-read.csv(paste0(ind_iso_dir,"/",ind_countries[[i]]),header=T)
    
      x<-x[feature,priority]
      x<-t(x)
      x<-base::as.data.frame(cbind(as.character(ind_countries_iso2[[i]]),x))
      colnames(x)<-c("iso2","indicator")
   
    return(x)
    
  })  
  
  count_list<-do.call(rbind,countries)
  coun2<-merge(shape,count_list,by.x="ISO2",by.y="iso2") 
  
  
  cat(paste0("Writing the csv file"), "\n")
  
 if(!file.exists(paste0(ind_dir,"/countries/to_graph/",date))){ dir.create(paste0(ind_dir,"/countries/to_graph/",date))}
 if(!file.exists(paste0(ind_dir,"/countries/to_graph/",date, "/", component))){dir.create(paste0(ind_dir,"/countries/to_graph/",date, "/", component))}
  
  
  write.csv(coun2@data,paste0(ind_dir,"/countries/to_graph/",date, "/", component,"/countries_",component,"_",Sys.Date(),".csv"),row.names=F,quote=F,na="")
    
    
    
  cat(paste0("Preparing the json file"), "\n")
  
    regions<-read.csv(paste0(par_dir,"/UNSD/countries-continents-regions.csv"), header = T)
    
    
    base<-coun2@data[,-2]
    base$Country<-NA
    
    
    
    a<-lapply(1:nrow(base), function(i){
      

      a<-gsub(base$ISO2[i], paste0("['",base$ISO2[i],"',"), base$ISO2[i])
      b<-gsub(base$indicator[i], paste0(base$indicator[i],"],"), base$indicator[i])
      
      if(base$ISO2[i] %in% regions$ISO2){
        
        c<- unique(as.character(regions[which(regions$ISO2 %in% base$ISO2[i]), "Country.Name"]))
        
        c<-gsub(c, paste0("\"", as.character(c),"\"", ","),c)
        #c<-gsub(c, paste0(" \" ", as.character(c)," \" ", ","),c)

      }
      
      if(i == nrow(base)){
        
        d<-gsub("],", "]];",  d)
        
      }
      
      base<-data.frame(a,c,b)
      
      colnames(base)<-c("var data=[['ISO2',", "'Country',",  paste0("'", priority, "'],")) 
      
      
      return(base)
      
  })
    
    

    data<-do.call(rbind, a)
    
    #x<-which(!is.na(data[,2]) |!is.na(data[,3])  )
    
    data<-data[complete.cases(data),]

    
    
    cat(paste0("Writing the json file"), "\n")
    
    
    write.table(data,paste0(ind_dir,"/countries/to_graph/",date, "/", component,"/countries_",component,".js"),row.names=F,quote=F,na="", qmethod = "double")
    
    
    
  }
