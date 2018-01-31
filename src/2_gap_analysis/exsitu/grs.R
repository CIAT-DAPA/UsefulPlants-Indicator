##########################################   Start Functions    ###############################################
# This function calculates the combined ex-situ and in-situ FCS (FCSc)
# It searches the species, then loads the summary.csv from both ex-situ and in-situ 
# then computes the FCSc and outputs a file fcs_combined.csv
# @param (string) species: species ID
# @return (data.frame): This function returns a data frame with the combined FCS of the ex-situ and in-situ
#                       gap analysis. It contains four columns: Species_ID, FCSex, FCSin, FCSc_min, 
#                       FCSc_max, FCSc_mean, and the priority class (HP, MP, LP, SC) for each combined version.

##== calculate size of distributional range ==# (sizeDR2)
#source(paste(src.dir,"/008.sizeDR2.R",sep=""))
#sizeDRProcess(inputDir=crop_dir, ncpu=2, crop=crop)

##== summarise area files ==# (summarizeDR)
#source(paste(src.dir,"/008.summarizeDR.R",sep=""))
#summarizeDR(crop_dir)

