# This function runs the entire process for a selected species
# @param (chr) species: species ID
# @return (dir): shapefile with native area
nat_area_shp <- function(species) {
  #load packages
  require(shapefiles); require(raster)
  require(rgeos); require(rgdal)
  
  #load config
  config(dirs=T, premodeling=T)
  
  #load species list
  splist <- unique(tkdist$taxonkey)
  x <- subset(tkdist, tkdist$taxonkey==species)
  countries <- factor(as.character(unique(x$ISO3)))
  shp_NA3 <- subset(countries_sh, ISO %in% countries)
  
  #define output directory for native area shp
  output_dir <- paste0(gap_dir,"/",species,"/",run_version,"/bioclim")

  if (!file.exists(paste0(output_dir, "/narea.shp"))) {
    #cat("Doing", species, "\n")
    gwd <- getwd(); setwd(output_dir)
    writeOGR(obj=shp_NA3, dsn="narea.shp", layer="narea", driver="ESRI Shapefile") # this is in geographical projection
    setwd(gwd)
    
    #cat("Writing png image for ",species,"\n")
    if (!file.exists(paste0(output_dir,"/",species,"_COUNTRY.png"))) {
      png(filename=paste0(output_dir,"/",species,"_COUNTRY.png"), width = 800, height = 800,unit="px")
      plot(shp_NA3,col="red")
      dev.off()
    }
    rm(list = c("species", "x", "countries"))
  } else {
    gwd <- getwd(); setwd(output_dir)
    shp_NA3 <- shapefile(paste0(output_dir, "/narea.shp"))
    setwd(gwd)
  }
  return(shp_NA3)
}
