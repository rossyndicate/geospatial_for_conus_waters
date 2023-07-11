# This function creates maps of each site in relationship to the NHD flowline it is associated with,
# as well as the watershed that was delineated for it using `getWatersheds()`. 
# This allows users to verify that the correct flowline was selected for their sites.
# Flowlines can be determined using the `getNHDcomid()` function.
 
getMaps <- function(x = sites$site, y = sites$comid){
  
  flowlines <- st_read('data/site_flowlines.gpkg', quiet = T) %>% filter(comid == y)
  watersheds <- dplyr::filter(site_watersheds, site == x)
  points <- dplyr::filter(sites, site == x)
  
  
  plot <- mapview(watersheds, col.regions = "#56B4E9", alpha.regions = 0.2, lwd = 3, layer.name = "Watershed") + 
          mapview(flowlines, lwd = 8, color = "red", layer.name = "Flowline") + 
          mapview(points, cex = 8, col.region = "black", layer.name = paste0(x))
  
  mapshot(plot, file = paste0('data/maps/', x, '.jpg'))

  }
