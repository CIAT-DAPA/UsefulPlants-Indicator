CreateMXArgs<-function(enmeval.obj){
  mxnt.args<- c("linear=TRUE")
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
  return(mxnt.args)
}