#Gap analysis
#Based on Phaseolus study (Ramirez-Villegas et al., 2010)
#J. Ramirez
#CIAT
#March 2012

#-------------------------------------------------
# Run outside linux, only when new code is available
# cd /curie_data/ncastaneda/code/gap-analysis-cwr/gap-analysis/gap-code
# cp * /curie_data/ncastaneda/gap-analysis/gap_[crop_name]/_scripts
# cd /curie_data/ncastaneda/gap-analysis
#-------------------------------------------------

stop("Warning: do not run the whole thing")
crop<-"XX_allnew" ##CROP NAME

#basic stuff - where is the code
#src.dir <- paste("/curie_data/ncastaneda/gap-analysis/gap_",crop,"/_scripts",sep="") # !!! change accordingly !!!
src.dir <- paste("X:/GAP_ANALYSIS_US_2016/gap_analysis/gap_",crop,"/_scripts",sep="") # !!! change accordingly !!!

#src.dir <- paste("//dapadfs/workspace_cluster_6/CWR/CWR_PROJECT_CC_BD/ccsosa/GAP_ANALYSIS_US_2016/gap_analysis/gap_",crop,"/_scripts",sep="") # !!! change accordingly !!!

#gap.dir <-"/curie_data/ncastaneda/gap-analysis" # !!! change accordingly !!!

#gap.dir <-"//dapadfs/workspace_cluster_6/CWR/CWR_PROJECT_CC_BD/ccsosa/GAP_ANALYSIS_US_2016/gap_analysis" # !!! change accordingly !!!
gap.dir <-"X:/GAP_ANALYSIS_US_2016/gap_analysis" # !!! change accordingly !!!

#crop details
crop_dir <- paste(gap.dir,"/gap_",crop,sep="")

if (!file.exists(crop_dir)) {dir.create(crop_dir)}
setwd(crop_dir)

#basic stuff - creating folders
biomod <- paste(crop_dir,"/biomod_modeling",sep=""); if (!file.exists(biomod)) {dir.create(biomod)}

figs <- paste(crop_dir,"/figures",sep=""); if (!file.exists(figs)) {dir.create(figs)}

msks <- paste(crop_dir,"/masks",sep=""); if (!file.exists(msks)) {dir.create(msks)}
rm(msks)

narea <- paste(biomod,"/native-areas",sep=""); if (!file.exists(narea)) {dir.create(narea)}

# polys <- paste(narea,"/polyshps",sep=""); if (!file.exists(polys)) {dir.create(polys)}

ascis <- paste(narea,"/asciigrids",sep=""); if (!file.exists(ascis)) {dir.create(ascis)}

#== prepare taxonomic names for the analysis ==#
# source(paste(src.dir,"/000.fixTaxNames.R",sep=""))

#== compare germplasm vs. total records==#
source(paste(src.dir,"/01.countRecords.R",sep=""))

#== split H/G occurrences ==#
occ <- read.csv(paste("./occurrences/",crop,"_all.csv",sep=""))
occ <- occ[which(!is.na(occ$lat)),]
occ <- occ[which(!is.na(occ$lon)),]

h <- occ[which(occ$H==1),]
g <- occ[which(occ$G==1),]

write.csv(h,paste("./occurrences/",crop,"_h.csv",sep=""),quote=F,row.names=F)
write.csv(g,paste("./occurrences/",crop,"_g.csv",sep=""),quote=F,row.names=F)
write.csv(occ,paste("./occurrences/",crop,".csv",sep=""),quote=F,row.names=F)

#== samples densities comparison ==#
source(paste(src.dir,"/02.splitHG.R",sep=""))

#== prepare masks ==#
# source(paste(src.dir,"/000.prepareMasks.R",sep=""))
#set climate dir
#env_dir <- "/curie_data/ncastaneda/geodata/bio_2_5m" # !!! change accordingly !!!
env_dir <- "X:/GAP_ANALYSIS_US_2016/gap_analysis/bio_2_5m" # !!! change accordingly !!!
geo_data_dir<-"X:/GAP_ANALYSIS_US_2016/gap_analysis/geodata"
# msks <- paste(crop_dir,"/masks",sep="")
# x <- createMasks(msks,env_dir)

#== crop climate data to extent of interest==#
#eco_dir <- "/curie_data/ncastaneda/geodata/wwf_eco_terr" # !!! change accordingly !!!
eco_dir <- "X:/GAP_ANALYSIS_US_2016/gap_analysis/geodata/wwf_eco_terr" # !!! change accordingly !!!

#source(paste(src.dir,"/000.ExtractVariables.R",sep=""))
#x <- maskVariables(crop_dir,env_dir,eco_dir)

#== create SWD occurrence files ==#
source(paste(src.dir,"/001.createSWD.R",sep=""))

occ_dir <- paste(crop_dir,"/occurrences",sep="")
swd_dir <- paste(crop_dir,"/swd",sep="")
if (!file.exists(swd_dir)) {dir.create(swd_dir)}

sample_file = paste(crop,".csv", sep="")

x <- extractClimates(input_dir=occ_dir,sample_file=sample_file,env_dir=env_dir,
                     env_prefix="bio_",env_ext="",lonfield="lon",
                     latfield="lat",taxfield="Taxon",output_dir=swd_dir)

#== preparing kernel density files ==#
# source(paste(src.dir,"/000.kernelDensity.R", sep="")) NEEDS TO BE FIXED!

#== splitting the occurrence files for biomod==# THIS NEEDS TIME!
# source(paste(src.dir,"/003.createOccurrenceFilesBiomod.R",sep=""))
# oDir <- paste(crop_dir,"/biomod_modeling/occurrence_files",sep="")
# if (!file.exists(oDir)) {dir.create(oDir)}
# x <- createOccFilesBio(occ=paste(crop_dir,"/swd/occurrences_swd_ok.csv",sep=""),
# taxfield="Taxon", outDir=oDir, env.dir=paste(crop_dir, "/biomod_modeling/current-clim", sep=""))

#== splitting the occurrence files ==#
source(paste(src.dir,"/003.createOccurrenceFiles.R",sep=""))
oDir <- paste(crop_dir,"/occurrence_files",sep="")
if (!file.exists(oDir)) {dir.create(oDir)}
x <- createOccFiles(occ=paste(crop_dir,"/swd/occurrences_swd_ok_kernel.csv",sep=""),
                    taxfield="Taxon", outDir=oDir)

#== prepare native areas ==#
#source(paste(src.dir,"/004.createNARasters.R",sep=""))

#== making the pseudo-absences ==#
 source(paste(src.dir,"/002.selectBackgroundArea_SP.R",sep="")) # NEW
 fList <- list.files("./occurrence_files",pattern=".csv")
# 
MaxModDir <- paste(crop_dir,"/maxent_modeling",sep="")
if (!file.exists(MaxModDir)) {dir.create(MaxModDir)}

bkDir <- paste(crop_dir,"/maxent_modeling/background",sep="")
if (!file.exists(bkDir)) {dir.create(bkDir)}



# 
for (f in fList) {
   iFile <- paste("./occurrence_files/",f,sep="")
  oFile <- paste("./maxent_modeling/background/",f,sep="")
  x<-background_create(occFile=iFile,outBackName=oFile)
   }

#== perform Variables selection using NIPALS and VIF ==#

rasterOptions(tmpdir = "D:/TEMP/colin") # tmpDir()
# All the stuff
removeTmpFiles(h = 0)


  source(paste(src.dir,"/variable_selection.R",sep=""))

    source(paste(src.dir,"/005.modelingApproach_subset.R",sep=""))
 spList <- list.files(paste(inputDir=crop_dir, "/occurrence_files", sep=""),pattern=".csv")
 spList<-sub(".csv","",spList)
 # lapply(1:length(spList),function(i){
 # x<-theEntireProcess(spID=spList[[i]], OSys="linux", inputDir=crop_dir, j.size="-mx2000m")
 # })
 #  
#x<-GapProcess(inputDir=crop_dir, OSys="linux", ncpu=3, j.size="-mx8192m")#mx2000m
#x<-GapProcess(inputDir=crop_dir, OSys="linux", ncpu=3, j.size="-mx3500m")#mx2000m
x<-GapProcess(inputDir=crop_dir, OSys="windows", ncpu=4, j.size="-mx4000m")#mx2000m

#== perform the maxent modelling in parallel using Variables selection==#
# source(paste(src.dir,"/005.modelingApproach.R",sep=""))
 #GapProcess(inputDir=crop_dir, OSys="linux", ncpu=3, j.size="-mx8192m")

 #== Creating null model ==#
 
 source(paste(src.dir,"/","000.nullModel_COUNTY.R",sep=""))
 
#== perform Ensambling approach ==#
 source(paste(src.dir,"/000.UpperROC_THR.R",sep=""))
 
 spList <- list.dirs(paste(crop_dir, "/maxent_modeling/models", sep=""),recursive = F)
 spList<-sub(paste(crop_dir, "/maxent_modeling/models/", sep=""),"",spList)
 
source(paste(src.dir,"/Ensemble_test_model_COUNTY.R",sep=""))
 #x<-ENSEMBLE_FUNCTION_RASTER(inputDir=crop_dir,county=F,spList=spList)
 
#== summarise the models metrics ==#
source(paste(src.dir,"/006.summarizeMetricsThresholds.R",sep=""))
x <- summarizeMetrics(idir=crop_dir)


#== calculate area with SD<0.15 (aSD15) ==#
source(paste(src.dir,"/007.calcASD15.R",sep=""))
x <- summarizeASD15(idir=crop_dir)

#at this point, do files check - summary files look for any NAs

#== Getting metrics for different approaches ==#
source(paste(src.dir,"/CHOOSE_BEST_MODEL_COUNTY.R",sep=""))

#== create taxa for spp richness table ==#
table_base <- read.csv(paste(crop_dir,"/sample_counts/sample_count_table.csv",sep=""))
table_base <- data.frame(Taxon=table_base$TAXON)
table_base$IS_VALID <- NA

#== reading tables ==#
samples <- read.csv(paste(crop_dir,"/sample_counts/sample_count_table.csv",sep=""))
model_met <- read.csv(paste(crop_dir,"/maxent_modeling/summary-files/NAREAS/modelsMets.csv",sep=""))

names(model_met)[1]="TAXON"
table_base <- samples

for (spp in table_base$TAXON) {
  cat("Processing species",paste(spp),"\n")
  
  if(sum(model_met$TAXON==paste(spp))==0){
    approach<-NA
    atauc <- NA
    stauc <- NA
    asd15 <- NA
    tss    <-NA
    sensitivity<-NA
    specificity<-NA
    cAUC<-NA
    nAUC<-NA
    isvalid_ap<-NA
    isval <- NA
    
    }else{
      approach<-as.character(model_met$APPROACH[which(model_met$TAXON==paste(spp))])
      atauc <- model_met$ATAUC[which(model_met$TAXON==paste(spp))]
      stauc <- model_met$STAUC[which(model_met$TAXON==paste(spp))]
      asd15 <- model_met$ASD15[which(model_met$TAXON==paste(spp))]
      tss    <-model_met$TSS[which(model_met$TAXON==paste(spp))]
      sensitivity<-model_met$SENSITIVITY[which(model_met$TAXON==paste(spp))]
      specificity<-model_met$SPECIFICITY[which(model_met$TAXON==paste(spp))]
      cAUC<-model_met$cAUC[which(model_met$TAXON==paste(spp))]
      nAUC<-model_met$nAUC[which(model_met$TAXON==paste(spp))]
      isvalid_ap<-model_met$ValidModel_APPROACH[which(model_met$TAXON==paste(spp))]
      isval <- model_met$ValidModel[which(model_met$TAXON==paste(spp))]
    }
  
  table_base$APPROACH[which(table_base$TAXON==paste(spp))] <- approach
  table_base$ATAUC[which(table_base$TAXON==paste(spp))] <- atauc
  table_base$STAUC[which(table_base$TAXON==paste(spp))] <- stauc
  table_base$ASD15[which(table_base$TAXON==paste(spp))] <- asd15
  table_base$TSS[which(table_base$TAXON==paste(spp))] <- tss
  table_base$SENSITIVITY[which(table_base$TAXON==paste(spp))] <- sensitivity
  table_base$SPECIFICITY[which(table_base$TAXON==paste(spp))] <- specificity
  table_base$cAUC[which(table_base$TAXON==paste(spp))] <- cAUC
  table_base$nAUC[which(table_base$TAXON==paste(spp))] <- nAUC
  table_base$ValidModel_APPROACH[which(table_base$TAXON==paste(spp))] <- isvalid_ap
  table_base$IS_VALID[which(table_base$TAXON==paste(spp))] <- isval
  
  
}

#table_base=table_base[c(1,11)]

#table_base$IS_VALID[which(is.na(table_base$IS_VALID))]<-0

write.csv(table_base,paste(crop_dir,"/summary-files/taxaForRichness_NAREA.csv",sep=""),row.names=F,quote=F)

rm(table_base, samples, model_met)



#== Filtering occurrences by native area ==#
source(paste(src.dir,"/000.filterOccFilesByNArea.R",sep=""))
x <- OccFilterNArea(crop_dir)


source(paste(src.dir,"/000.filterOccFilesByNArea_COUNTY.R",sep=""))
x <- OccFilterNArea_COUNTY(crop_dir)


source(paste(src.dir,"/clean_maps_COUNTY.R",sep=""))  #uses land cover file to remove urban and other areas



source(paste(src.dir,"/MAPPING_CWR_SP_NAREA_COUNTY.R",sep=""))

######################################################################################### run to here

#== calculate size of distributional range ==#
source(paste(src.dir,"/008.sizeDR2.R",sep=""))
sizeDRProcess(inputDir=crop_dir, ncpu=2, crop=crop)

#== summarise area files ==#
source(paste(src.dir,"/008.summarizeDR.R",sep=""))
summarizeDR(crop_dir)

#== calculate environmental distance of distributional range ==#
source(paste(src.dir,"/009.edistDR.R",sep=""))
x <- summarizeDR_env(crop_dir)

#== calculate species richness ==#
source(paste(src.dir,"/010.speciesRichness2.R",sep=""))
x <- speciesRichness_alt(bdir=crop_dir)

#== create the priorities table ==#
source(paste(src.dir,"/000.prioritiesTable.R",sep=""))
x <- priTable(crop_dir)

#== calculate distance to populations ==#
source(paste(src.dir,"/011.distanceToPopulations2.R",sep=""))
ParProcess(crop_dir, ncpu=3)

#== calculate final gap richness ==#
source(paste(src.dir,"/012.gapRichness2.R",sep=""))
x <- gapRichness(bdir=crop_dir)

#== verify if gap map is available for each taxon ==#
priFile <- read.csv(paste(crop_dir, "/priorities/priorities.csv", sep=""))
newpriFile <- priFile
newpriFile$MAP_AVAILABLE <- NA

spList <- priFile$TAXON

for (spp in spList){
  fpcat <- priFile$FPCAT[which(priFile$TAXON==paste(spp))]
  if(file.exists(paste(crop_dir, "/gap_spp/", fpcat, "/", spp, ".asc.gz", sep=""))){
    newpriFile$MAP_AVAILABLE[which(newpriFile$TAXON==paste(spp))] <- 1
  } else {
    newpriFile$MAP_AVAILABLE[which(newpriFile$TAXON==paste(spp))] <- 0
  }
}

write.csv(newpriFile, paste(crop_dir, "/priorities/priorities.csv", sep=""), row.names=F, quote=F)
rm(newpriFile)

#== calculate distances to known populations ==#
source(paste(src.dir, "/000.maxpdistance.R", sep=""))
x <- maxpdist(crop_dir)

#== getting maps and figures ==#
source(paste(src.dir,"/013.mapsAndFigures.R",sep=""))

#== ensuring access to folders ==#
system(paste("chmod", "-R", "774", crop_dir))
