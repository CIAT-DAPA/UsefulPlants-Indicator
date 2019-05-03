#Maria Victoria Diaz Lopez
#CIAT 2018

################################### TO GRAPH ############################
#Function to make a summary of the main priority (or comprehensiveness) indicators for each catgeorie of uses in the species

# @param (string) priority: write P_LP_SC, P_MP, P_HP 
# @param (string) component: write mean (or min, max), and exsitu and insitu 

# @return (dataframe): This function return .csv file with the summary of the priority (or comprehensiveness) indicator for all uses

####################### START ########################################



uses<-function(...){

  cat(paste0("Please select the folder with the uses indicators..."), "\n")
  
  setwd(paste0(root, "/indicator"))
  
  ind_dir<-paste0(root, "/indicator")
  ind_us_dir<- jchoose.dir() 
  
  date<-Sys.Date()
  #date<-"2019-04-24"
  
  
  cat(paste0("Listing files ..."), "\n")
  
  
  ind_uses1<-list.files(ind_us_dir,pattern = ".csv$",full.names = F)
  ind_uses<-gsub("ind_","",ind_uses1)
  ind_uses<-gsub(".csv","",ind_uses)

  
  warning("please write the priority levels in the order you want to see", immediate. = TRUE, noBreaks. = T)
  
  priority1 <- readline(prompt="write the first priority level you want to show: ") 
  priority2 <- readline(prompt="write the second priority level you want to show: ") 
  priority3 <- readline(prompt="write the third priority level you want to show: ") 
  

  priority<-c(priority1, priority2, priority3) ; rm(priority1, priority2, priority3)
  
  
  warning("please write the three components in the order you want to see (ex: mean, exsitu, insitu)", immediate. = TRUE, noBreaks. = T)
  
  component1 <- readline(prompt="please write the first component you want to show: ") 
  component2 <- readline(prompt="please write the second component you want to show: ") 
  component3 <- readline(prompt="please write the third component you want to show: ") 
  

  component<-c(component1, component2, component3) ; rm(component1, component2, component3)
  
for_uses<-lapply(1:length(ind_uses), function(j){ 
  
opt_list<-  lapply(1:length(component), function(i){
    
    
    feature<- ifelse(component[i] == "min", 1,
                     ifelse(component[i] == "max", 2, 
                            ifelse(component[i] == "mean", 3,
                                   ifelse(component[i] == "exsitu", 4,
                                          ifelse(component[i] == "insitu", 5, NA
                                          )))))
    
    cat(paste0("Organizing indicator values per uses"), "\n")
    
    
      u<-read.csv(paste0(ind_us_dir,"/",ind_uses1[j]),header=T)
      u<-u[feature,priority]
      u<-as.data.frame(cbind(as.character(ind_uses[j]),u))
      colnames(u)<-c("Uses",priority)
      
      
     
      
      
      cat(paste0("Preparing the json file for ", component[i]), "\n")
      
      
      first_row <- data.frame("['',", as.numeric(0), ",'',", as.numeric(0), ",'',", as.numeric(0), ",''],", stringsAsFactors=FALSE)
     
      d<-gsub(u[1,2], paste0(u[1,2],","), u[1,2])
      c<-gsub(u[1,3], paste0(u[1,3],","), u[1,3])
      b<-gsub(u[1,4], paste0(u[1,4],","), u[1,4])
      
      
      
      if(component[i] == "mean"){
        
  
        a<-gsub(u$Uses, paste0("['",u$Uses,"',"), u$Uses)
           
        
        col_1<- "'bar {'+'stroke-width: 10;' +'stroke-color: #E54D24}'],"
        col_2<- "'bar {'+'stroke-width: 10;' +'stroke-color: #F0CB69}',"
        col_3<- "'bar {'+'stroke-width: 10;' +'stroke-color: #12A356}',"
        
        opt_list<-data.frame(a,d,col_3,c, col_2, b, col_1, stringsAsFactors=FALSE)

        colnames(first_row)<-colnames(opt_list)
        
        opt_list<-rbind(first_row, opt_list, first_row, first_row)
        
        
      
      
      }else{
        
         
        col_1<- "'',"
        col_2<- "'',"
        col_3<- "''],"
        
      if(component[i] == "exsitu"){
        
        
        a<-gsub(u$Uses, paste0("['",u$Uses," ex situ',"), u$Uses)
          
        opt_list<-data.frame(a,d,col_1,c, col_2, b, col_3, stringsAsFactors=FALSE)
        
        colnames(first_row)<-colnames(opt_list)
        
        opt_list<-rbind(opt_list, first_row)
        
        
      } else{
        
        a<-gsub(u$Uses, paste0("['",u$Uses," in situ',"), u$Uses)
        
        opt_list<-data.frame(a,d,col_1,c, col_2, b, col_3, stringsAsFactors=FALSE)
        
        colnames(first_row)<-colnames(opt_list)
        
        opt_list<-rbind(opt_list, first_row, first_row, first_row)
        
        
      }
      
      
      }
      
      colnames(opt_list)<-c("var data=[['uses',", " 'Low Priority and Sufficiently Conserved',","{ role: 'style' },","'Medium Priority', ","{ role: 'style' },","'High Priority',", " { role: 'style' }],")
      
      rm(a,b,c,d,col_1,col_2,col_3, first_row)
      

      for_csv<-u
      for_js<-opt_list
      
      
      return(list(JS = for_js, CSV = for_csv))
      
    
  })


JS<-do.call(rbind, list(opt_list[[1]]$JS, opt_list[[2]]$JS, opt_list[[3]]$JS))

CSV<-list(mean = opt_list[[1]]$CSV, exsitu = opt_list[[2]]$CSV, insitu = opt_list[[3]]$CSV)

X<-list(JS = JS,CSV = CSV)

return(X)

})




for(k in 1:length(component)){
  
  
  if(!file.exists(paste0(ind_dir,"/uses/to_graph/",date))){ dir.create(paste0(ind_dir,"/uses/to_graph/",date))}
  if(!file.exists(paste0(ind_dir,"/uses/to_graph/",date, "/", component[k]))){dir.create(paste0(ind_dir,"/uses/to_graph/",date, "/", component[k]))}
  
  
  
  CSV<-lapply(1:length(for_uses), function(h){
    
    
    CSV<-for_uses[[h]][[2]][[which(names(for_uses[[h]][[2]]) %in% component[k])]]
    
    return(CSV)
    
  })
  
  
  CSV<-do.call(rbind, CSV)
  
  cat(paste0("Writing the csv file"), "\n")
  
  
  write.csv(CSV,paste0(ind_dir,"/uses/to_graph/",date, "/", component[k],"/indicator",".csv"),row.names=F,quote=F,na="")
  
  
  

  JS<-lapply(1:length(for_uses), function(h){
    
    
    JS<-for_uses[[h]][[1]]
    
    return(JS)
    
  })
  
  
  JS<-do.call(rbind, JS)
  JS[nrow(JS),ncol(JS)]<-gsub("],", "]];", JS[nrow(JS),ncol(JS)])
  
  
  
  cat(paste0("Writing the json file"), "\n")
  
  
  write.table(JS,paste0(ind_dir,"/uses/to_graph/",date, "/combined_indicator", ".js"),row.names=F,quote=F,na="")
  
  
  
}




}
