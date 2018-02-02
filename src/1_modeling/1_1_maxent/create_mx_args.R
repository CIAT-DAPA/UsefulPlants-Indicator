# This function runs the entire process for a selected species
# @param (ENMevaluation or NULL) enmeval.obj: object of ENMeval package
# @return (chr): mxnt.args, vector of parameters
CreateMXArgs <- function(enmeval.obj=NULL){
  mxnt.args<- c("linear=TRUE")
  
  if (!is.null(enmeval.obj)) {
    best.ind<- which.min(enmeval.obj@results$delta.AICc)
    features <- enmeval.obj@results$features[best.ind]
    betamultiplier <- enmeval.obj@results$rm[best.ind]
    if(grepl("Q", features)){
      mxnt.args <- c(mxnt.args, "quadratic=TRUE")
    } else {
      mxnt.args <- c(mxnt.args, "quadratic=FALSE")
    }
    if(grepl("H", features)){
      mxnt.args <- c(mxnt.args, "hinge=TRUE")
    } else {
      mxnt.args <- c(mxnt.args, "hinge=FALSE")
    }
    if(grepl("P", features)){
      mxnt.args <- c(mxnt.args, "product=TRUE")
    } else {
      mxnt.args <- c(mxnt.args, "product=FALSE")
    }
    if(grepl("T", features)){
      mxnt.args <- c(mxnt.args, "threshold=TRUE")
    } else {
      mxnt.args <- c(mxnt.args, "threshold=FALSE")
    }
    mxnt.args <- c(mxnt.args, paste0("betamultiplier=",betamultiplier))
  } else {
    mxnt.args <- c(mxnt.args, "quadratic=TRUE", "hinge=TRUE", "product=TRUE", "threshold=FALSE", "betamultiplier=1.0")
  }
  return(mxnt.args)
}
