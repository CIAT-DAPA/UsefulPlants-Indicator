# An R function to summarize all individual area files calculated for each taxon in step 008.sizeDR
#
# "Adapting crops to climate change: collecting, protecting and preparing crop wild relatives"
# www.cwrdiversity.org
#
# J. Ramirez - 2013

summarizeDR <- function(bdir) {
  
  ddir <- paste(bdir, "/samples_calculations", sep="")
  
  odir <- paste(bdir, "/maxent_modeling/summary-files", sep="")
  if (!file.exists(odir)) {
    dir.create(odir)
  }
  
  spList <- list.files(paste(bdir, "/occurrence_files", sep=""))
  
  sppC <- 1
  for (spp in spList) {
    spp <- unlist(strsplit(spp, ".", fixed=T))[1]
    fdName <- spp #paste("sp-", spp, sep="")
    spFolder <- paste(bdir, "/maxent_modeling/models/", fdName, sep="")
    spOutFolder <- paste(ddir, "/", spp, sep="")
    
    if (file.exists(spFolder)) {
      
#       res <- sizeDR(bdir, spap)
      
      metFile <- paste(spOutFolder, "/areas.csv", sep="")
      metrics <- read.csv(metFile)
      metrics <- cbind(taxon=spp, metrics)
      
      if (sppC == 1) {
        outSum <- metrics
      } else {
        outSum <- rbind(outSum, metrics)
      }
      sppC <- sppC + 1
    } else {
      cat("The taxon was never modeled \n")
    }
  }
  
  outFile <- paste(odir, "/areas.csv", sep="")
  write.csv(outSum, outFile, quote=F, row.names=F)
  return(outSum)
}