require(shapefiles);require(raster);library(rgeos);require(rgdal)



countries_sh<-readOGR(dsn=path.expand(countries_sh), layer=layer_name)

splist<-unique(tkdist$taxonkey)


shapeNatives <- function(species){
 
  
  config(dirs=T, premodeling=T)
  
  x<-subset(tkdist,tkdist$taxonkey==species)
  countries<-factor(as.character(unique(x$ISO3)))
  
  shp_NA3 <- subset(countries_sh, ISO %in% countries)
  
  
  
  
  output_dir<-paste0(gap_dir,"/",species,"/",run_version,"/bioclim")

  
  if(!file.exists(paste0(output_dir, "/narea.shp"))){
    
    cat("Doing", species, "\n")
    
    writeOGR(obj=shp_NA3, dsn=output_dir, layer="narea", driver="ESRI Shapefile") # this is in geographical projection
    
    cat("Writing png image for ",species,"\n")
    
    png(filename=paste0(output_dir,"/",species,"_COUNTRY.png"),
        width = 800, height = 800,unit="px")
    plot(shp_NA3,col="red")
    dev.off()
    rm(list = c("species", "shp_NA3", "x", "countries"))
    
  } else {cat(species, "Done before", "\n")}
  
  rm(list = c("species", "shp_NA3", "x", "countries"))
}


