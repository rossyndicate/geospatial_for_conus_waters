# This function pulls NHD flowlines based on a table of COMIDS. Output flowlines are in CRS 4269.

getNHDcomid <- function(df = sites){
  
  #Select NHD flowlines that df are located on, subsequently getting NHD metadata for each sample location.
  subset_nhdplus(comids = df$comid,
                 output_file = 'data/site_flowlines.gpkg',
                 nhdplus_data = 'download',
                 overwrite = TRUE,
                 return_data = FALSE,
                 flowline_only = TRUE,
                 out_prj = 4269)
  
  
  df_points <- st_read('data/site_flowlines.gpkg', quiet = T)
  
  coords <- vector("list", length = nrow(df_points))
  
  for(i in 1:nrow(df_points)){
    
    coords[[i]] <- df_points[i,] %>%
      st_coordinates() %>%
      as_tibble() %>%
      head(., 1)
  }
  
  coords <- bind_rows(coords) %>%
    cbind(df, .) %>%
    select(site, comid, longitude = X, latitude = Y) %>%
    st_as_sf(., coords = c('longitude','latitude'), crs = 4269)
  
  # Link NHD hydrologic unit code (HUC, essentially sub-watershed polygons) data to each sample.
  site_hucs <- list()
  
  for(i in 1:nrow(coords)){
    site_hucs[[i]] <- get_huc12(coords[i,], t_srs=4269)
  }
  
  site_hucs <- do.call('rbind',site_hucs) %>%
    mutate(huc2 = paste0('HUC-',str_sub(huc12,end = 2)),
           huc4 = paste0('HUC-',str_sub(huc12,end = 4)),
           huc6 = paste0('HUC-',str_sub(huc12,end = 6)),
           huc8 = paste0('HUC-',str_sub(huc12,end = 8)),
           huc10 = paste0('HUC-',str_sub(huc12,end = 10)),
           huc12 = paste0('HUC-',huc12)) %>%
    select(huc2,huc4,huc6,huc8,huc10,huc12)
  
  
  site_lines <- st_read('data/site_flowlines.gpkg', quiet = T) %>%
    #if necessary, remove duplicates that happen due to multiple samples on the same NHD feature:
    distinct(comid,.keep_all=TRUE) %>% 
    st_join(.,site_hucs) %>%
    distinct(comid,.keep_all=TRUE) %>%
    as_tibble()
  
  #join site points to NHD data
  coords <- coords %>%
    left_join(site_lines,by='comid') %>%
    select(-c(geometry, geom)) %>%
    mutate(across(1:145, as.character)) %>%
    mutate(comid = as.integer(comid))
  
  print(paste0(nrow(coords), " locations linked to the NHD."))
  
  return(coords)
  
}

