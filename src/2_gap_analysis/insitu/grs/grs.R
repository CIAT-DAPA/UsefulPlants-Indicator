##########################################  Start Install Packages  ###############################################

# install.packages(c("raster","sp","rgdal","rgeos","sf","shapefiles", "snowfall"))

##########################################   End Install Packages  ###############################################


##########################################  Start Requirements  ###############################################

# Load the libraries
require(raster)
require(rgdal)
require(sf)
library(snowfall)

##########################################   End Requirements  ###############################################


##########################################  Start Set Parameters  ###############################################

# Global configuration
rasterOptions(tmpdir = "D:/TEMP/hsotelo")
setwd("//dapadfs/Projects_cluster_9/aichi/")

# Set the path of the file with global protected areas
pa.path = "WDPA/areas_protected_geographic.tif"
# Load the raster file with global protected areas
pa.raster = raster(pa.path)
# Remove the zeros (0) from raster
pa.raster[which(pa.raster[] == 0)] <- NA
# Load the species list to execute process
species.dir = "ENMeval_2/outputs/"
species.list = list.dirs(species.dir,full.names = FALSE, recursive = FALSE)

##########################################   End Set Parameters  ###############################################


##########################################   Start Functions    ###############################################

# This function calculate the GRS by every specie.
# It searches the specie, then load the specie distribution from raster file. 
# With the specie distribution intersectes with the protected areas raster and calculate
# the area from the specie distribution, overlay and the proportion between both.
# It creates two files with the result (result.csv, intersect.tif)
# @param (string) specie: Code of the specie
# @return (void): This function does not return nothing
calculate_grs = function(specie){
  
  message = "Ok"
  status = TRUE
  
  tryCatch({
    print(paste0("Start ",specie))
    
    # Set the global
    specie.dir = paste0(species.dir, specie, "/")
    specie = gsub(".csv", "", specie)
    
    # Load the specie raster (specie distribution)
    specie.distribution = raster(paste0(specie.dir, "concenso_mss.tif"))
    # Remove the zeros (0) from raster
    specie.distribution[which(specie.distribution[]==0)]<-NA
    
    print("Loaded the specie distribution file (raster)")
    
    # Intersect betwenn specie distribution and protected areas
    origin(pa.raster) <- origin(specie.distribution)
    overlay = pa.raster * specie.distribution
    
    print("Intersected the specie distribution and global protected areas")
    
    # Get pixels with data from intersect
    a = which(!is.na(overlay[]))
    # Get pixels with data from specie distribution
    b = which(!is.na(specie.distribution[]))
    
    # Calculating the area in kilometer for each pixel
    area = res(specie.distribution)[1] * res(specie.distribution)[2]
    gra = 111.11*111.11
    res = area * gra 
    
    # Calculate areas for the specie distribution and intersect
    overlay.area <- length(a) * res
    specie.area <- length(b) * res
    
    # Calculate proportion area
    proportion = (overlay.area / specie.area) * 100
    
    print("Calculated the areas and proportions")
    
    # Join the results
    df <- data.frame(specie_distribution_a = specie.area, species_protected_area_a = overlay.area, units_a = c("km2"), proportion = proportion, units_proportion = c("percentage"))
    
    # Create output dirs
    if(!dir.exists(paste0(specie.dir,"gap_analysis"))){
      dir.create(paste0(specie.dir,"gap_analysis"))
    }
    if(!dir.exists(paste0(specie.dir,"gap_analysis/insitu"))){
      dir.create(paste0(specie.dir,"gap_analysis/insitu"))
    }
    # Save the results
    species.output = paste0(specie.dir,"gap_analysis/insitu/grs")
    dir.create(species.output)
    write.csv(df, paste0(species.output,"/result.csv"), row.names = FALSE, quote = FALSE)
    writeRaster(overlay, paste0(species.output,"/intersect.tif"),overwrite=T )
    return (data.frame(specie = specie, status = status, message = message))
    
  }, 
  error = function(e) {
    
    message = e
    status = FALSE
    return (data.frame(specie = specie, status = status, message = message[[1]]))
  }, finally = {
    
    # Remove temp files
    removeTmpFiles(h=0)
    
    print(paste0("End ",specie))
  })
}
##########################################    End Functions    ###############################################


##########################################   Start Process    ###############################################

# sfInit(parallel = T, cpus = 20)
# sfLibrary(raster)
# sfLibrary(rgdal)
# sfLibrary(sf)
# sfExportAll()
# sfExport("calculate_grs")
# 
# sfLapply(species.list,calculate_grs)

# specie = species.list[7]
# lapply(species.list[7],calculate_grs)
result = lapply(species.list,calculate_grs)
