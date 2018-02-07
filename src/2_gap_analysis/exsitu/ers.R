##########################################   Start Functions    ###############################################
# This function calculates the ex-situ ERS It loads occurrences if they exist, then
# loads the presence/absence surface, creates the G buffer (i.e. CA50) and finally
# outputs the ERS and # eco classes in a data.frame (which is written into a file).
# @param (string) species: species ID
# @param (logical) debug: whether to save or not the intermediate raster outputs
# @return (data.frame): This function returns a data frame with ERS, # eco classes 
#                       of G buffer (i.e. CA50) and of the presence/absence surface.

species="2650747"
ers_exsitu <- function(species, debug=F) {
  #packages
  require(raster)
  
  #load config
  config(dirs=T,exsitu=T)
  
  #directory for species
  sp_dir <- paste(gap_dir,"/",species,"/",run_version,sep="")
  
  #load counts
  sp_counts <- read.csv(paste(gap_dir,"/",species,"/counts.csv",sep=""),sep="\t")
  
  #run only for spp with occ file
  if (file.exists(paste(occ_dir,"/no_sea/",species,".csv",sep="")) & sp_counts$totalHUseful != 0) {
    #load occurrence points
    occ_data <- read.csv(paste(occ_dir,"/no_sea/",species,".csv",sep=""),header=T)
    
    #load native area shapefile
    msk <- raster(paste(sp_dir,"/bioclim/narea_mask.tif",sep=""))
    
    #load maxent metrics file
    mx_metrics <- read.csv(paste(sp_dir,"/modeling/maxent/eval_metrics.csv",sep=""),header=T)
    if (mx_metrics$VALID) {
      pa_spp <- raster(paste(sp_dir,"/modeling/maxent/spdist_thrsld.tif",sep=""))
    } else {
      pa_spp <- raster(paste(sp_dir,"/modeling/alternatives/ca50_total_narea.tif",sep=""))
    }
    pa_spp[which(pa_spp[] == 0)] <- NA
    
    #select G samples and validate if G >= 1
    occ_g <- unique(occ_data[which(occ_data$type == "G"),c("lon","lat")])
    if (nrow(occ_g) >= 1) {
      if (!file.exists(paste(sp_dir,"/gap_analysis/exsitu/ca50_g_narea_pa.tif",sep=""))) {
        #generate G buffers within native area
        g_fname <- paste(sp_dir,"/gap_analysis/exsitu/ca50_g_narea.tif",sep="")
        g_buffer <- create_buffers(xy=occ_g, msk, buff_dist=0.5, format="GTiff", filename=g_fname)
        g_buffer <- crop(g_buffer, pa_spp)
        g_buffer <- pa_spp * g_buffer #limit g_buffer to where species actually is
        
        #write raster of g_buffer after overlaying with species distribution
        writeRaster(g_buffer, paste(sp_dir,"/gap_analysis/exsitu/ca50_g_narea_pa.tif",sep=""),format="GTiff")
      } else {
        g_buffer <- raster(paste(sp_dir,"/gap_analysis/exsitu/ca50_g_narea_pa.tif",sep=""))
      }
      
      #calculate number of classes for presence/absence
      pa_nclass <- crop(eco.raster, pa_spp)
      origin(pa_nclass)<-origin(pa_spp)
      pa_nclass <- pa_spp * pa_nclass
      if (debug & !file.exists(paste(sp_dir,"/gap_analysis/exsitu/ers_pa_narea_ecosystems.tif",sep=""))) {
        pa_nclass <- writeRaster(pa_nclass, paste(sp_dir,"/gap_analysis/exsitu/ers_pa_narea_ecosystems.tif",sep=""), format="GTiff")
      }
      pa_nclass <- length(unique(na.omit(pa_nclass[])))
      
      #calculate area of g_buffer
      g_buffer[which(g_buffer[] == 0)] <- NA
      gbuf_nclass <- crop(eco.raster, g_buffer)
      origin(gbuf_nclass)<-origin(g_buffer)
      gbuf_nclass <- g_buffer * gbuf_nclass
      gbuf_nclass[which(gbuf_nclass[]==0)]<-NA
      if (debug & !file.exists(paste(sp_dir,"/gap_analysis/exsitu/ers_gbuffer_narea_ecosystems.tif",sep=""))) {
        gbuf_nclass <- writeRaster(gbuf_nclass, paste(sp_dir,"/gap_analysis/exsitu/ers_gbuffer_narea_ecosystems.tif",sep=""), format="GTiff")
      }
      
      
      gbuf_nclass <- length(unique(na.omit(gbuf_nclass[])))
     
      #calculate ERS
      ers <- min(c(100, gbuf_nclass/pa_nclass*100))
    } else {
      ers <- 0
      gbuf_nclass <- 0
      pa_nclass <- NA
    }
    
    
  } else {
    ers <- 0
    gbuf_nclass <- 0
    pa_nclass <- NA
  }
  
  #create data.frame with output
  out_df <- data.frame(ID=species, SPP_N_ECO=pa_nclass, G_N_ECO=gbuf_nclass, ERS=ers)
  write.csv(out_df,paste(sp_dir,"/gap_analysis/exsitu/ers_result.csv",sep=""),row.names=F)
  
  #return object
  return(out_df)
}

#testing the function
#base_dir <- "~/nfs"
#source("~/Repositories/aichi13/src/config.R")
#source("~/Repositories/aichi13/src/1_modeling/1_2_alternatives/create_buffers.R")
#ers_exsitu(species)

