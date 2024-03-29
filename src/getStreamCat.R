# This function pulls data from the EPA's StreamCat database, and requires a site data table that includes the sites' COMIDs.
# Code adapted from Simon Topp's LakeCat extraction [LakeCat](https://github.com/SimonTopp/USLakeClarityTrendr/blob/master/1_nhd_join_and_munge.Rmd).
# NOTE: This approach is  outdated. Instead, we recommend using https://github.com/USEPA/StreamCatTools.

getStreamCat <- function(sites = sites,
                         epa_categories = c("AgMidHiSlopes", "CoalMines", "CanalDensity", "ImperviousSurfaces", "NLCD2016", "Dams"),
                         save = TRUE){

### StreamCat extraction (adapted from Simon Topp's code)
# Code adapted from Simon Topp's LakeCat extraction [LakeCat](https://github.com/SimonTopp/USLakeClarityTrendr/blob/master/1_nhd_join_and_munge.Rmd).

# StreamCat is huge (600 possible variables). And While EPA has since made a programatically interact with StreamCat, which would make this code 1 billion times faster, it wasn't public when this code was written. So! We made a function below that:

# 1) Downloads StreamCat categories of data (e.g. dam density, urbanization) for all regions of CONUS.
# 2) Joins that data to our sites by their NHD comid.
# 3) Then, hilariously, deletes the large gigabytes of data we don't use and only keeps the data that matches our sites' NHD comids.

# The only way to get these names right is to look at the file structure of [StreamCat](https://gaftp.epa.gov/epadatacommons/ORD/NHDPlusLandscapeAttributes/StreamCat/HydroRegions/). This crashes Firefox and must be opened in a chromium browser (Chrome, Edge, etc.).

## 1) Download StreamCat data

subset_sites <- sites %>% #remove comid duplicates (i.e., samples located in the same catchment)
    distinct(comid,.keep_all=T)
  
hackastreamcat <- function(name){
  base_url = 'https://gaftp.epa.gov/epadatacommons/ORD/NHDPlusLandscapeAttributes/StreamCat/HydroRegions/'
  
  ## Manual list of regions, because they split up the huc-2s.
  regions = str_pad(c(1:2,4:9,11:18), 2, pad = '0') %>%
    c('03N', '03S', '03W', '10U', '10L') %>%
    sort(.)
  
  urls = paste0(base_url, name, '_Region', regions, '.zip')
  
  folder = paste0('data/temp_streamcat/', name)
  
  files = paste0(folder, '/', regions, '.zip')

  csvs = paste0(folder, '/', name, '_Region', regions, '.csv')

  if(!file.exists(folder)){
    dir.create(folder)}

  for(i in 1:length(urls)){
    if(!file.exists(csvs[i])){
      download.file(url = urls[i],
                    destfile = files[i])
      unzip(zipfile = files[i], exdir = folder)}}}

# Reminder that this approach is stupidly wasteful. 
# We suggest recreating this workflow using the EPA's API.


# Fill the `epa_categories` vector with the names of the categorized data sets you are interested in downloading 
# (a list of those data sets can be found [here](https://gaftp.epa.gov/epadatacommons/ORD/NHDPlusLandscapeAttributes/StreamCat/HydroRegions/)).

walk(epa_categories, hackastreamcat)



## 2) Linking StreamCat data to the site features, based on each site's comid.


kitten_folders <- list.files('data/temp_streamcat', full.names = T)
simple_folders <- list.files('data/temp_streamcat', full.names = F)

stream_kittens <- function(cat_file){
  temp_list <- list()
  for(i in 1:length(cat_file[[1]])){
    scat <- data.table::fread(cat_file[[1]][i])
    keep_cat <- scat[COMID %in% subset_sites$comid,]
    temp_list[[i]] <- keep_cat
  }
  out <- do.call('rbind', temp_list)
  return(out)
}

# Link all this data to each site of interest

stream_kitten <- function(cat_file){
  catcher <- function(file_name){
    data.table::fread(file_name) %>%
      .[COMID %in% subset_sites$comid,]
  }
  
  scat <- map_dfr(cat_file, catcher)
}

# This is impressively fast. It reads over 2.65 million records 20 times! All in 16 seconds!
bound_streamcat <- tibble(kitten_folders, simple_folders) %>%
  mutate(cat_files = map(kitten_folders, list.files, full.names = T, 
                         pattern = '.csv'),
         overlaps = map(cat_files,stream_kitten))

# Glorious reduce function to join all variables together, add to our site df
sites <- reduce(bound_streamcat$overlaps, inner_join, by = 'COMID') %>%
  select(-starts_with(c('CatPctFull.','CatAreaSqKm.','WsAreaSqKm.'))) %>%
  select(-ends_with('Cat')) %>%
  rename(comid = COMID) %>%
  inner_join(sites, .)

if(save == FALSE){
  unlink(file.path(getwd(), "/data/temp_streamcat/"), recursive = T)
  dir.create(file.path(getwd(), "/data/temp_streamcat/"), showWarnings = FALSE)
}

return(sites)

}
