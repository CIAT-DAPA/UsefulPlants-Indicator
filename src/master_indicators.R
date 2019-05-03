


master_indicators<-function(opt, shapefile, species, iso_list, usess){

  cat("Calculating indicator per species list...", "\n")
     
     first <- lapply(1:length(species), function(i){
       
       cat(i, "\n")
       calc_indicator(species[[i]], opt = opt, save_file = TRUE)
       
     }) 
     
     

     
     cat("Calculating indicator per countries list...", "\n")
     
     
     second <- lapply(1:length(iso_list[[1]]), function(i){
       cat(round(i/length(iso_list[[1]])*100,3), "\n")
       
       select_spp_indicator(iso_list[[1]][i], opt=opt, level = "country")
       
       
       
       
     }) 

     select_spp_indicator(iso_list= "ALL", opt=opt, level = "country")
     
     
     second_json <- countries(shape = shapefile)
     
     
     
     cat("Calculating indicator per subregions list...", "\n")
     
     
     third <- lapply(1:length(iso_list[[2]]), function(i){
       
       cat(round(i/length(iso_list[[2]])*100,3), "\n")
       
       select_spp_indicator(iso_list[[2]][i], opt=opt, level = "region")
       
     }) 
     
     
     
     third_json <- regions()
     
     
     cat("Calculating indicator per uses list...", "\n")
     
 
     fourth <- lapply(1:length(usess), function(i){
       cat(round(i/length(usess)*100,3), "\n")
       
       indicator_cat(usess[[i]], opt=opt)
       
     }) 
     
      

     fourth_json <- uses()
     
     
     
     cat("Finishing the process", "\n")
     
       
       
  
  
  
}