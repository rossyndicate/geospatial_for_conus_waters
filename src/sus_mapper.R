# This function identifies all NHDPlusV2 flowline and catchment features near a site.
# This function can be used to explore nearby NHD features, especially when a site's coordinates
# technically place it in the wrong catchment. Requires a shapefile of site locations in CRS 4269.

sus_mapper <- function(x){
  
  nearby_catchments <- vector("list",length = nrow(x))
  nearby_flowlines <-  vector("list",length = nrow(x))
  
  for(i in 1:nrow(x)){
    
    nearby_flowlines[[i]] <- get_nhdplus(AOI = x[i,],
                                         realization = "flowline",
                                         t_srs = 4269) %>%
      dplyr::select(comid)
    
    nearby_catchments[[i]] <- get_nhdplus(AOI = x[i,], 
                                          realization = "catchment",
                                          t_srs = 4269) %>%
      dplyr::select(comid = featureid)
    
  }
  
  nearby_catchments <- bind_rows(nearby_catchments)
  nearby_flowlines <- bind_rows(nearby_flowlines)
  
  return(list(nearby_flowlines, nearby_catchments))
  
}