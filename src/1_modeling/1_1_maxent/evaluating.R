require(PresenceAbsence);require(raster);require(dismo);library(tidyverse)

#speciesecies=2653304

metrics_function<-function(species){
  #########
  crossValDir <- paste0(gap_dir, "/", species, "/", run_version, "/modeling/maxent")
  maxn <- readRDS(paste0(crossValDir,"/modeling_results.",species,".RDS"))
  #########

  occ<-as.data.frame(maxn$occ_prediction[complete.cases(maxn$occ_prediction),])
  bg<-as.data.frame(maxn$bck_predictions[complete.cases(maxn$bck_predictions),])
  
  
  if(ncol(occ)>=5 &  nrow(occ)>5 & ncol(bg)>=5 &  nrow(bg)>5){
    occ$observed<-NA;occ$observed<-rep(1,nrow(occ))
    bg$observed<-NA;bg$observed<-rep(0,nrow(bg))
  
  
  #######################################################################################
  #ASD 15
  #############################
  #esdCpt <- raster(paste0(crossValDir, "/speciesdist_sd.tif"))
  rep_number<-length(maxn$model@models)
  evaluate_table <- as.data.frame(matrix(nrow = (rep_number),ncol=12))
  colnames(evaluate_table)<-c("species","replicate","training","testing","Background","ATAUC","STAUC",
                              "Threshold","Sensitivity","Specificity","TSS","PCC")
  z <- rbind(occ,bg); names(z)[1:rep_number] <- paste(c(1:rep_number))
  z <- z[complete.cases(z),]
  z$plotID<-NA; z$plotID<-as.character(1:nrow(z))
  #z <- z %>% select(plotID, observed, 1:rep_number)
  z <- z[,c("plotID","observed",paste(c(1:5)))]
  
  #maxent model results
  x <- as.data.frame(maxn$model@results)
  
  #SP
  evaluate_table[,"species"]<-rep(as.character(species),nrow(evaluate_table))
  
  #REPLICATE
  evaluate_table[,"replicate"]<-as.character(c(1:rep_number))
  
  #TRAINING
  evaluate_table[,"training"]<-as.numeric(x[row.names(x)=="X.Training.samples",][1:rep_number])
  
  #TESTING
  evaluate_table[,"testing"]<-as.numeric(x[row.names(x)=="X.Test.samples",][1:rep_number])
  
  #BACKGROUND
  evaluate_table[,"Background"]<-as.numeric(x[row.names(x)=="X.Background.points",][1:rep_number])
  
  ##ATAUC
  evaluate_table[,"ATAUC"]<-as.numeric(unlist(lapply(1:rep_number,function(i){  x<-PresenceAbsence::auc(z,which.model=i)[1];return(x)})))
  
  ##STAUC
  evaluate_table[,"STAUC"]<-as.numeric(unlist(lapply(1:rep_number,function(i){  x<-PresenceAbsence::auc(z,which.model=i,st.dev = T)[2];return(x)})))
  
  ##THRESHOLD
  evaluate_table[,"Threshold"]<-as.numeric(unlist(lapply(1:rep_number,function(i){  x<-PresenceAbsence::optimal.thresholds(z,which.model=i,opt.methods = 3)[2];return(x)})))
  
  ##SENSITIVITY
  evaluate_table[,"Sensitivity"]<-as.numeric(unlist(lapply(1:rep_number,function(i){  x<-PresenceAbsence::sensitivity(cmx(z,which.model=i))[1];return(x)})))
  
  ##SPECIFICITY
  evaluate_table[,"Specificity"]<-as.numeric(unlist(lapply(1:rep_number,function(i){  x<-PresenceAbsence::specificity(cmx(z,which.model=i))[1];return(x)})))
  
  ##TSS
  evaluate_table[,"TSS"]<-(evaluate_table[1:rep_number,"Sensitivity"]+evaluate_table[1:rep_number,"Specificity"])-1
  
  ##PCC
  evaluate_table[,"PCC"]<-as.numeric(unlist(lapply(1:rep_number,function(i){  x<-PresenceAbsence::pcc(cmx(z,which.model = i))[1];return(x)})))

  write.csv(evaluate_table,paste0(crossValDir,"/","eval_metrics_rep.csv"),quote = F,row.names = F)
  
  
    } else {
    
    rep_number<-length(maxn$model@models)
    evaluate_table <- as.data.frame(matrix(nrow = (rep_number),ncol=12))
    colnames(evaluate_table)<-c("species","replicate","training","testing","Background","ATAUC","STAUC",
                                "Threshold","Sensitivity","Specificity","TSS","PCC")
    
    #maxent model results
    x <- as.data.frame(maxn$model@results)
    
    #SP
    evaluate_table[,"species"]<-rep(as.character(species),nrow(evaluate_table))
    
    #REPLICATE
    evaluate_table[,"replicate"]<-as.character(c(1:rep_number))
    
    #TRAINING
    evaluate_table[,"training"]<-as.numeric(x[row.names(x)=="X.Training.samples",][1:rep_number])
    
    #TESTING
    evaluate_table[,"testing"]<-as.numeric(x[row.names(x)=="X.Test.samples",][1:rep_number])
    
    #BACKGROUND
    evaluate_table[,"Background"]<-as.numeric(x[row.names(x)=="X.Background.points",][1:rep_number])
    
    ##ATAUC
    evaluate_table[,"ATAUC"]<-0.5
    
    ##STAUC
    evaluate_table[,"STAUC"]<-1
    
    ##THRESHOLD
    evaluate_table[,"Threshold"]<-0.5
    
    ##SENSITIVITY
    evaluate_table[,"Sensitivity"]<-NA
    
    ##SPECIFICITY
    evaluate_table[,"Specificity"]<-NA
    
    ##TSS
    evaluate_table[,"TSS"]<-NA
    
    ##PCC
    evaluate_table[,"PCC"]<-NA
    
  write.csv(evaluate_table,paste0(crossValDir,"/","eval_metrics_rep.csv"),quote = F,row.names = F)
    
  }
  ################
  return(evaluate_table)
}

evaluate_function <- function(species, evaluate_table){
  
  crossValDir <- paste0(gap_dir, "/", species, "/", run_version, "/modeling/maxent")
  evaluate_table_f<-as.data.frame(matrix(nrow = 1,ncol=15))
  colnames(evaluate_table_f)<-c("species","training","testing","Background","ATAUC","STAUC",
                              "Threshold","Sensitivity","Specificity","TSS","PCC","nAUC","cAUC","ASD15","VALID")
  
  ###ASD15
  esdCpt <- raster(paste0(crossValDir, "/spdist_sd.tif"))
  dumm <- raster(paste0(crossValDir, "/spdist_thrsld.tif"))
  
  esdCpt[which(dumm[] < 0.001)] <- NA
  
  #create 0,1 raster with areas below 0.15 STD (below=1, above=0)
  esdCpt_ref <- esdCpt
  esdCpt_ref[which(!is.na(esdCpt[]))] <- 1
  
  #create 0,1 raster with areas above 0.15 STD (below=0, above=1)
  esdCpt_a15 <- esdCpt
  esdCpt_a15[which(esdCpt[] >= 0.15)] <- 1
  esdCpt_a15[which(esdCpt[] < 0.15)] <- 0
  
  #make a raster of area
  dist_area <- area(esdCpt)
  
  #calculate size of distribution within native area, and within thresholded distribution
  #total, and above 0.15 STD.
  szCpt <- dist_area * esdCpt_ref
  szCptUncertain <- dist_area * esdCpt_a15
  rateCpt <- sum(szCptUncertain[],na.rm=T) / sum(szCpt[],na.rm=T) * 100
  
  #############################
  rm(dumm,esdCpt)
  #############################
  
  #SP
  evaluate_table_f[,"species"]<-as.character(species)
  
  #TRAINING
  evaluate_table_f[,"training"]<-as.numeric(mean(evaluate_table[,"training"],na.rm=T))
  
  #TESTING
  evaluate_table_f[,"testing"]<-as.numeric(mean(evaluate_table[,"testing"],na.rm=T))
  
  #BACKGROUND
  evaluate_table_f[,"Background"]<-as.numeric(mean(evaluate_table[,"Background"],na.rm=T))
  
  ##ATAUC
  evaluate_table_f[,"ATAUC"]<-as.numeric(mean(evaluate_table[,"ATAUC"],na.rm=T))
  
  ##STAUC
  evaluate_table_f[,"STAUC"]<-as.numeric(mean(evaluate_table[,"STAUC"],na.rm=T))
  
  ##THRESHOLD
  evaluate_table_f[,"Threshold"]<-as.numeric(mean(evaluate_table[,"Threshold"],na.rm=T))
  
  ##SENSITIVITY
  evaluate_table_f[,"Sensitivity"]<-as.numeric(mean(evaluate_table[,"Sensitivity"],na.rm=T))
  
  ##SPECIFICITY
  evaluate_table_f[,"Specificity"]<-as.numeric(mean(evaluate_table[,"Specificity"],na.rm=T))
  
  ##TSS
  evaluate_table_f[,"TSS"]<-as.numeric(mean(evaluate_table[,"TSS"],na.rm=T))
  
  ##PCC
  evaluate_table_f[,"PCC"]<-as.numeric(mean(evaluate_table[,"PCC"],na.rm=T))
  
  ###nAUC
  evaluate_table_f[,"nAUC"] <- null_model_AUC(species)
  
  ###cAUC
  evaluate_table_f[,"cAUC"]<-evaluate_table_f[,"ATAUC"]+.5-max(c(.5,evaluate_table_f[,"nAUC"],na.rm=T))
  
  ####ASD15
  evaluate_table_f[,"ASD15"]<-rateCpt
  
  if (evaluate_table_f[,"ATAUC"]>=0.7 &
     evaluate_table_f[,"STAUC"]<0.15 &
     evaluate_table_f[,"ASD15"]<=10 &
     evaluate_table_f[,"cAUC"]>=0.4
  ) {
    evaluate_table_f[,"VALID"]  <-TRUE 
  } else {
    evaluate_table_f[,"VALID"]  <-FALSE 
  }
  
  #write output table
  write.csv(evaluate_table_f,paste0(crossValDir,"/","eval_metrics.csv"),quote = F,row.names = F)
  
  #return
  return(evaluate_table_f)
}
