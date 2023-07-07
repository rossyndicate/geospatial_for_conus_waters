# Geospatial Data Puller for Waters in the Contiguous US (CONUS)

This workflow pulls geospatial data for selected waterbody sites in CONUS and their watersheds. Data in this workflow comes from the following sources:

1) [National Hydrography Dataset (NHD) Plus V2 Data](https://nhdplus.com/NHDPlus/NHDPlusV2_home.php)
2) [StreamCat Data](https://www.epa.gov/national-aquatic-resource-surveys/streamcat-dataset)
3) [Omernik Ecoregion Data](https://www.epa.gov/eco-research/level-iii-and-iv-ecoregions-continental-united-states)
4) [Aridity Index Data](https://figshare.com/articles/dataset/Global_Aridity_Index_and_Potential_Evapotranspiration_ET0_Climate_Database_v2/7504448/6)

For every site, NHD comids are used as the basis for watershed delineation. Subsequently, the resolution of these watershed statistics is at the NHDPlusV2 catchment level. 
