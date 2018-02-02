##########################################   Start Functions    ###############################################
# This function calculates the ex-situ GRS. It loads occurrences if they exist, then
# loads the presence/absence surface, creates the G buffer (i.e. CA50) and finally
# outputs the GRS and areas in a data.frame (which is written into a file).
# @param (string) species: species ID
# @param (logical) debug: whether to save or not the intermediate raster outputs
# @return (data.frame): This function returns a data frame with GRS and areas of G buffer (i.e. CA50)
#                       and of the presence/absence surface.
grs_exsitu <- function(species, debug=F) {
  #packages
  require(raster)
  
  #load config
  config(dirs=T,exsitu=T)
  
  #directory for species
  sp_dir <- paste(gap_dir,"/",species,"/",run_version,sep="")
  
  #load counts
  sp_counts <- read.csv(paste(gap_dir,"/",species,"/counts.csv",sep=""),sep="\t", header=T)
  
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
      
      #calculate area of presence/absence (note area in km2)
      pa_area <- crop(global_area, pa_spp)
      pa_area <- pa_spp * pa_area
      if (debug & !file.exists(paste(sp_dir,"/gap_analysis/exsitu/grs_pa_narea_areakm2.tif",sep=""))) {
        pa_area <- writeRaster(pa_area, paste(sp_dir,"/gap_analysis/exsitu/grs_pa_narea_areakm2.tif",sep=""), format="GTiff")
      }
      pa_area <- sum(pa_area[], na.rm=T) #in km2
      
      #calculate area of g_buffer
      gbuf_area <- crop(global_area, g_buffer)
      gbuf_area <- g_buffer * gbuf_area
      if (debug & !file.exists(paste(sp_dir,"/gap_analysis/exsitu/grs_gbuffer_narea_areakm2.tif",sep=""))) {
        gbuf_area <- writeRaster(gbuf_area, paste(sp_dir,"/gap_analysis/exsitu/grs_gbuffer_narea_areakm2.tif",sep=""), format="GTiff")
      }
      gbuf_area <- sum(gbuf_area[], na.rm=T) #in km2
    } else {
      gbuf_area <- 0
    }
    
    #calculate GRS
    grs <- min(c(100, gbuf_area/pa_area*100))
  } else {
    grs <- 0
    g_area <- 0
    #pa_area <- NA
    pa_area <- crop(global_area, pa_spp)
    pa_area <- pa_spp * pa_area
    if (debug & !file.exists(paste(sp_dir,"/gap_analysis/exsitu/grs_pa_narea_areakm2.tif",sep=""))) {
      pa_area <- writeRaster(pa_area, paste(sp_dir,"/gap_analysis/exsitu/grs_pa_narea_areakm2.tif",sep=""), format="GTiff")
    }
    pa_area <- sum(pa_area[], na.rm=T) #in km2
  }
  
  #create data.frame with output
  out_df <- data.frame(ID=species, SPP_AREA_km2=pa_area, G_AREA_km2=gbuf_area, GRS=grs)
  write.csv(out_df,paste(sp_dir,"/gap_analysis/exsitu/grs_result.csv",sep=""),row.names=F)
  
  #return object
  return(out_df)
}

# testing the function
# base_dir <- "~/nfs"
# source("~/Repositories/aichi13/src/config.R")
# source("~/Repositories/aichi13/src/1_modeling/1_2_alternatives/create_buffers.R")
# grs_sp <- grs_exsitu("2686262")
