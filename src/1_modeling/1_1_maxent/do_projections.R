# Do projections for MaxEnt runs with all type of features
# H. Achicanoy
# CIAT, 2018

suppressMessages(library(raster))
suppressMessages(library(ff))
suppressMessages(library(data.table))
suppressMessages(library(gtools))
#suppressMessages(library(velox))

make.projections <- function(k, pnts, tmpl_raster)
{
  lambdas.file <- readLines(paste('species_', k-1, '.lambdas', sep='')) # Read lambdas file by fold
  lambdas.file <- strsplit(x=lambdas.file, split=',', fixed=TRUE)
  lambdas.file <- lapply(1:length(lambdas.file),function(i){z <- data.frame(t(lambdas.file[[i]])); return(z)})
  identify.lmd <- unlist(lapply(1:length(lambdas.file),function(i){z <- ncol(lambdas.file[[i]])==4; return(z)}))
  paramet.file <- lambdas.file[!identify.lmd]
  lambdas.file <- lambdas.file[identify.lmd]
  paramet.file <- Reduce(function(...) rbind(..., deparse.level=1), paramet.file)
  lambdas.file <- Reduce(function(...) rbind(..., deparse.level=1), lambdas.file)
  names(paramet.file) <- c("variable","value")
  names(lambdas.file) <- c("feature","lambda","min","max")
  
  lambdas.file$feature <- as.character(lambdas.file$feature)
  lambdas.file$lambda <- as.numeric(as.character(lambdas.file$lambda))
  lambdas.file$min <- as.numeric(as.character(lambdas.file$min))
  lambdas.file$max <- as.numeric(as.character(lambdas.file$max))
  
  paramet.file$variable <- as.character(paramet.file$variable)
  paramet.file$value <- as.numeric(as.character(paramet.file$value))
  
  # Identify each type of feature
  t.feat <- grep(pattern="<", x=lambdas.file$feature, fixed=T) # Threshold features
  r.feat <- grep(pattern="`", x=lambdas.file$feature, fixed=T) # Reverse hinge features
  f.feat <- grep(pattern="'", x=lambdas.file$feature, fixed=T) # Forward hinge features
  q.feat <- grep(pattern="^2", x=lambdas.file$feature, fixed=T) # Quadratic features
  p.feat <- grep(pattern="*", x=lambdas.file$feature, fixed=T) # Product features
  l.feat <- setdiff(1:nrow(lambdas.file), c(t.feat, r.feat, f.feat, q.feat, p.feat)) # Linear features
  
  # Read climate variables to project
  cell <- cellFromXY(object = tmpl_raster, xy = pnts[,1:2])
  temp.dt <- pnts[,-c(1:2)]
  temp.dt <- as.ffdf(temp.dt)
  temp.dt <- as.data.frame(temp.dt)
  temp.dt <- data.table(temp.dt)
  
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  # Linear features
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  
  # Verify if linear features exist
  if(length(l.feat) > 0)
  {
    linear.calcs <- lapply(lambdas.file$feature[l.feat], function(var)
    {
      lambdas.file.l <- lambdas.file[l.feat,]
      eval(parse(text=paste('result.by.var.l <- lambdas.file.l$lambda[which(lambdas.file.l$feature==var)]*((temp.dt[,',var,']-lambdas.file.l$min[which(lambdas.file.l$feature==var)])/(lambdas.file.l$max[which(lambdas.file.l$feature==var)]-lambdas.file.l$min[which(lambdas.file.l$feature==var)]))',sep='')))
      result.by.var.l <- data.frame(result.by.var.l)
      return(result.by.var.l)
    })
    linear.calcs <- Reduce(function(...) cbind(..., deparse.level=1), linear.calcs)
    names(linear.calcs) <- lambdas.file$feature[l.feat]
    linear.calcs <- as.data.table(linear.calcs)
    linear.calcs <- linear.calcs[,rowSums(.SD,na.rm=FALSE)]
  } else {
    cat('Linear features do not exist.\n')
    linear.calcs <- rep(0, nrow(temp.dt))
  }
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  # Quadratic features
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  
  # Verify if quadratic features exist
  if(length(q.feat) > 0)
  {
    temp.name <- strsplit(x=lambdas.file$feature[q.feat],split="^",fixed=TRUE)
    temp.name <- unlist(lapply(temp.name,function(set){return(set[1])}))
    lambdas.file$feature[q.feat] <- temp.name; rm(temp.name)
    quadratic.calcs <- lapply(lambdas.file$feature[q.feat],function(var)
    {
      lambdas.file.q <- lambdas.file[q.feat,]
      eval(parse(text=paste('result.by.var.q <- lambdas.file.q$lambda[which(lambdas.file.q$feature==var)]*((temp.dt[,',var,']^2-lambdas.file.q$min[which(lambdas.file.q$feature==var)])/(lambdas.file.q$max[which(lambdas.file.q$feature==var)]-lambdas.file.q$min[which(lambdas.file.q$feature==var)]))',sep='')))
      result.by.var.q <- data.frame(result.by.var.q)
      return(result.by.var.q)
    })
    quadratic.calcs <- Reduce(function(...) cbind(..., deparse.level=1), quadratic.calcs)
    names(quadratic.calcs) <- lambdas.file$feature[q.feat]
    quadratic.calcs <- as.data.table(quadratic.calcs)
    quadratic.calcs <- quadratic.calcs[,rowSums(.SD,na.rm=FALSE)]
  } else {
    cat('Quadratic features do not exist.\n')
    quadratic.calcs <- rep(0, nrow(temp.dt))
  }
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  # Product features
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  
  # Verify if product features exist
  if(length(p.feat) > 0)
  {
    product.calcs <- lapply(lambdas.file$feature[p.feat],function(comb.var)
    {
      lambdas.file.p <- lambdas.file[p.feat,]
      eval(parse(text=paste('result.by.var.p <- lambdas.file.p$lambda[which(lambdas.file.p$feature==comb.var)]*((temp.dt[,',comb.var,']-lambdas.file.p$min[which(lambdas.file.p$feature==comb.var)])/(lambdas.file.p$max[which(lambdas.file.p$feature==comb.var)]-lambdas.file.p$min[which(lambdas.file.p$feature==comb.var)]))',sep='')))
      result.by.var.p <- data.frame(result.by.var.p)
      return(result.by.var.p)
    })
    product.calcs <- Reduce(function(...) cbind(..., deparse.level=1), product.calcs)
    names(product.calcs) <- lambdas.file$feature[p.feat]
    product.calcs <- as.data.table(product.calcs)
    product.calcs <- product.calcs[,rowSums(.SD,na.rm=FALSE)]
  } else {
    cat('Product features do not exist.\n')
    product.calcs <- rep(0, nrow(temp.dt))
  }
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  # Forward hinge features
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  
  if(length(f.feat) > 0)
  {
    forward.index <- lambdas.file$feature[f.feat]
    forward.index.c <- gsub(pattern="'", replacement="", forward.index)
    forward.calcs <- lapply(1:length(forward.index), function(i)
    {
      lambdas.file.f <- lambdas.file[f.feat,]
      eval(parse(text=paste('result.by.var.f <- ifelse(test=temp.dt[,',forward.index.c[i],']<lambdas.file.f$min[i], yes=0, no=lambdas.file.f$lambda[i]*(temp.dt[,',forward.index.c[i],']-lambdas.file.f$min[i])/(lambdas.file.f$max[i]-lambdas.file.f$min[i]))',sep='')))
      result.by.var.f <- data.frame(result.by.var.f)
      return(result.by.var.f)
    })
    forward.calcs <- Reduce(function(...) cbind(..., deparse.level=1), forward.calcs)
    names(forward.calcs) <- lambdas.file$feature[f.feat]
    forward.calcs <- as.data.table(forward.calcs)
    forward.calcs <- forward.calcs[,rowSums(.SD,na.rm=FALSE)]
  } else {
    cat('Forward hinge features do not exist.\n')
    forward.calcs <- rep(0, nrow(temp.dt))
  }
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  # Reverse hinge features
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  
  if(length(r.feat) > 0)
  {
    reverse.index <- lambdas.file$feature[r.feat]
    reverse.index.c <- gsub(pattern="`", replacement="", reverse.index)
    reverse.calcs <- lapply(1:length(reverse.index), function(i)
    {
      lambdas.file.r <- lambdas.file[r.feat,]
      eval(parse(text=paste('result.by.var.r <- ifelse(test=temp.dt[,',reverse.index.c[i],']<lambdas.file.r$max[i], yes=lambdas.file.r$lambda[i]*(lambdas.file.r$max[i] - temp.dt[,',reverse.index.c[i],'])/(lambdas.file.r$max[i]-lambdas.file.r$min[i]), no=0)',sep='')))
      result.by.var.r <- data.frame(result.by.var.r)
      return(result.by.var.r)
    })
    reverse.calcs <- Reduce(function(...) cbind(..., deparse.level=1), reverse.calcs)
    names(reverse.calcs) <- lambdas.file$feature[r.feat]
    reverse.calcs <- as.data.table(reverse.calcs)
    reverse.calcs <- reverse.calcs[,rowSums(.SD,na.rm=FALSE)]
  } else {
    cat('Reverse hinge features do not exist.\n')
    reverse.calcs <- rep(0, nrow(temp.dt))
  }
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  # Threshold features
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
  
  if(length(t.feat) > 0)
  {
    thresh.index <- lambdas.file$feature[t.feat]
    threshold    <- strsplit(thresh.index, split='<', fixed=TRUE)
    thresh.index.c <- unlist(lapply(1:length(threshold), function(i){z <- threshold[[i]][2]; return(z)}))
    threshold    <- unlist(lapply(1:length(threshold), function(i){z <- threshold[[i]][1]; return(z)}))
    thresh.index.c <- gsub(pattern=')', replacement='', thresh.index.c, fixed=TRUE)
    threshold    <- as.numeric(gsub(pattern='(', replacement='', threshold, fixed=TRUE))
    thresh.calcs <- lapply(1:length(thresh.index), function(i)
    {
      lambdas.file.t <- lambdas.file[t.feat,]
      eval(parse(text=paste('result.by.var.t <- ifelse(test=temp.dt[,',thresh.index.c[i],']<threshold[i], yes=0, no=lambdas.file.t$lambda[i])',sep='')))
      result.by.var.t <- data.frame(result.by.var.t)
      return(result.by.var.t)
    })
    thresh.calcs <- Reduce(function(...) cbind(..., deparse.level=1), thresh.calcs)
    names(thresh.calcs) <- lambdas.file$feature[t.feat]
    thresh.calcs <- as.data.table(thresh.calcs)
    thresh.calcs <- thresh.calcs[,rowSums(.SD,na.rm=FALSE)]
  } else {
    cat('Threshold features do not exist.\n')
    thresh.calcs <- rep(0, nrow(temp.dt))
  }
  
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
  cat('\nComputing output values\n\n')
  # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
  
  fx.calcs <- cbind(linear.calcs, quadratic.calcs, product.calcs, forward.calcs, reverse.calcs, thresh.calcs)
  rm(linear.calcs, quadratic.calcs, product.calcs, forward.calcs, reverse.calcs, thresh.calcs)
  
  # if(exists('linear.calcs') & exists('quadratic.calcs') & exists('product.calcs')) # Linear, quadratic and product
  # {
  #   fx.calcs <- cbind(linear.calcs, quadratic.calcs, product.calcs); rm(linear.calcs, quadratic.calcs, product.calcs)
  # } else {
  #   if(exists('linear.calcs') & exists('quadratic.calcs') & !exists('product.calcs')) # Linear and quadratic
  #   {
  #     fx.calcs <- cbind(linear.calcs, quadratic.calcs); rm(linear.calcs, quadratic.calcs)
  #   } else {
  #     if(exists('linear.calcs') & !exists('quadratic.calcs') & exists('product.calcs')) # Linear and product
  #     {
  #       fx.calcs <- cbind(linear.calcs, product.calcs); rm(linear.calcs, product.calcs)
  #     } else {
  #       if(exists('linear.calcs') & !exists('quadratic.calcs') & !exists('product.calcs')) # Linear only
  #       {
  #         cat('Projections do not available because model ran with linear features only.\n')
  #       }
  #     }
  #   }
  # }
  
  if(exists('fx.calcs')) # Verify if fx.calcs exists in order to calculate projections
  {
    
    fx.calcs <- as.data.table(fx.calcs)
    fx.calcs <- fx.calcs[,rowSums(.SD,na.rm=FALSE)]
    
    S.x <- fx.calcs - paramet.file$value[which(paramet.file$variable=="linearPredictorNormalizer")]
    Q.x <- exp(S.x)/paramet.file$value[which(paramet.file$variable=="densityNormalizer")]
    L.x <- (Q.x*exp(paramet.file$value[which(paramet.file$variable=="entropy")]))/(1+Q.x*exp(paramet.file$value[which(paramet.file$variable=="entropy")]))
    
    # First index corresponds to taxon information, Second index corresponds to climatic information model
    prj_fn <- tmpl_raster
    prj_fn[] <- NA
    prj_fn[cell] <- L.x
    
    return(prj_fn)
    cat("Projection done for fold:", k-1, "\n")
    
  } else {
    
    return(cat('Process finished for inaccurate results.\n'))
    
  }
  
}