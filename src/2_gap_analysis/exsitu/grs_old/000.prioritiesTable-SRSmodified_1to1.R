#== create the priorities table ==#
# Note: The SRS score was modified to reflect updated concept of 1 G to 1 H as adequate
# 2016_1_8

priTable <- function (crop_dir) {
  
  #1. SRS=(GS/HS)*10
  table_base <- read.csv(paste(crop_dir,"/sample_counts/sample_count_table.csv",sep=""))
  table_base <- data.frame(Taxon=table_base$TAXON)
  table_base$HS <- NA; table_base$HS_RP <- NA
  table_base$GS <- NA; table_base$GS_RP <- NA
  table_base$TOTAL <- NA; table_base$TOTAL_RP <- NA
  table_base$ATAUC <- NA; table_base$STAUC <- NA; table_base$ASD15 <- NA; table_base$IS_VALID <- NA
  table_base$SRS <- NA; table_base$GRS <- NA; table_base$ERS <- NA
  table_base$ERTS <- NA; table_base$FPS <- NA; table_base$FPCAT <- NA
  
  #== reading specific tables ==#
  samples <- read.csv(paste(crop_dir,"/sample_counts/sample_count_table.csv",sep=""))
  model_met <- read.csv(paste(crop_dir,"/maxent_modeling/summary-files/modelsMets.csv",sep=""))
  rsize <- read.csv(paste(crop_dir,"/maxent_modeling/summary-files/areas.csv",sep=""))
  edist <- read.csv(paste(crop_dir,"/maxent_modeling/summary-files/edist_wwf.csv",sep=""))
  
  names(model_met)[1]="TAXON"
  names(rsize)[1]="TAXON"
  names(edist)[1]="TAXON"
  table_base <- samples
  
  #== read principal components weights and scale them to match 1 ==#
  #!!!!!!
  # w_pc1 <- 0.7
  # w_pc2 <- 0.3
  
  for (spp in table_base$TAXON) {
    cat("Processing species",paste(spp),"\n")
    
    #sampling and SRS
    hs <- samples$HNUM[which(samples$TAXON==paste(spp))]
    hs_rp <- samples$HNUM_RP[which(samples$TAXON==paste(spp))]
    gs <- samples$GNUM[which(samples$TAXON==paste(spp))]
    gs_rp <- samples$GNUM_RP[which(samples$TAXON==paste(spp))]
    total <- samples$TOTAL[which(samples$TAXON==paste(spp))]
    total_rp <- samples$TOTAL_RP[which(samples$TAXON==paste(spp))]
    srs.temp <- gs/hs*10
    if(srs.temp > 10){
      srs <- 10
    }else{
      srs <- gs/hs*10
    }
    
    table_base$HS[which(table_base$TAXON==paste(spp))] <- hs
    table_base$HS_RP[which(table_base$TAXON==paste(spp))] <- hs_rp
    table_base$GS[which(table_base$TAXON==paste(spp))] <- gs
    table_base$GS_RP[which(table_base$TAXON==paste(spp))] <- gs_rp
    table_base$TOTAL[which(table_base$TAXON==paste(spp))] <- total
    table_base$TOTAL_RP[which(table_base$TAXON==paste(spp))] <- total_rp
    table_base$SRS[which(table_base$TAXON==paste(spp))] <- srs
    
    #modelling metrics
    if(sum(model_met$TAXON==paste(spp))==0){atauc <- NA
                                            stauc <- NA
                                            asd15 <- NA
                                            isval <- NA}else{
                                              atauc <- model_met$ATAUC[which(model_met$TAXON==paste(spp))]
                                              stauc <- model_met$STAUC[which(model_met$TAXON==paste(spp))]
                                              asd15 <- model_met$ASD15[which(model_met$TAXON==paste(spp))]
                                              isval <- model_met$ValidModel[which(model_met$TAXON==paste(spp))]}
    
    table_base$ATAUC[which(table_base$TAXON==paste(spp))] <- atauc
    table_base$STAUC[which(table_base$TAXON==paste(spp))] <- stauc
    table_base$ASD15[which(table_base$TAXON==paste(spp))] <- asd15
    table_base$IS_VALID[which(table_base$TAXON==paste(spp))] <- isval
    
    #grs
    g_ca50 <- rsize$GBSize[which(rsize$TAXON==paste(spp))]
    
    if(sum(rsize$TAXON==paste(spp))==0){
      drsize=NA
      grs=NA
    } else {
      if (isval==1) {
        drsize <- rsize$DRSize[which(rsize$TAXON==paste(spp))]
      } else {
        drsize <- rsize$CHSize[which(rsize$TAXON==paste(spp))]
      }
      grs <- g_ca50/drsize*10
      
      if (!is.na(grs)) {
        if (grs>10) {grs <- 10}
      }
    }
    table_base$GRS[which(table_base$TAXON==paste(spp))] <- grs
    
    #ers
    if(sum(edist$TAXON==paste(spp))==0){
      ecg_ca50_pc1=NA
      #     ecg_ca50_pc2=NA
      dr_pc1=NA
      #     dr_pc2=NA
      ers_pc1=NA
      #     ers_pc1=NA
      ers=NA
    } else {
      ecg_ca50_pc1 <- edist$GBDist.PC1[which(edist$TAXON==paste(spp))]
      #       ecg_ca50_pc2 <- edist$GBDist.PC2[which(edist$TAXON==paste(spp))]
      if(isval==1){
        dr_pc1 <- edist$DRDist.PC1[which(edist$TAXON==paste(spp))]
        #         dr_pc2 <- edist$DRDist.PC2[which(edist$TAXON==paste(spp))]
        
      } else {
        dr_pc1 <- edist$CHDist.PC1[which(edist$TAXON==paste(spp))]
        #         dr_pc2 <- edist$CHDist.PC2[which(edist$TAXON==paste(spp))]
        
      }
      
      ers_pc1 <- ecg_ca50_pc1/dr_pc1*10
      if (!is.na(ers_pc1)) {
        if (ers_pc1 > 10) {ers_pc1 <- 10}
      }
      #       ers_pc2 <- ecg_ca50_pc2/dr_pc2*10
      #       if (!is.na(ers_pc2)) {
      #         if (ers_pc2 > 10) {ers_pc2 <- 10}
      #       }
      
      #       ers <- ers_pc1*w_pc1 + ers_pc2*w_pc2
      ers <- ers_pc1
      if (!is.na(ers))
        if (ers > 10) {ers <- 10}
    }
    table_base$ERS[which(table_base$TAXON==paste(spp))] <- ers
    
    #Final priority score
    if (gs==0) {
      fps <- 0
    } else if (hs==0 & gs<10) {
#     } else if (gs<=10) {
      fps <- 0
    } else {
      fps <- mean(c(srs,grs,ers),na.rm=T)
    }
    table_base$FPS[which(table_base$TAXON==paste(spp))] <- fps
    
    if (fps>=0 & fps<=2.5) { # New addition
      fpcat <- "HPS"
    } else if (fps>2.5 & fps<=5) { # New addition
      fpcat <- "MPS"
    } else if (fps>5 & fps<=7.5) {
      fpcat <- "LPS"
    } else {
      fpcat <- "NFCR"
    }
    table_base$FPCAT[which(table_base$TAXON==paste(spp))] <- fpcat
  }
  
  table_base=table_base[c(1,6:20)]
  
  if (!file.exists(paste(crop_dir,"/priorities",sep=""))) {
    dir.create(paste(crop_dir,"/priorities",sep=""))
  }
  
  table_base$IS_VALID[which(is.na(table_base$IS_VALID))]<-0
  
  write.csv(table_base,paste(crop_dir,"/priorities/priorities.csv",sep=""),row.names=F,quote=F)
}
