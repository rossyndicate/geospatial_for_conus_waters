# Geospatial Data Puller for Waters in the Contiguous US (CONUS)

This workflow pulls geospatial data for selected waterbody sites in CONUS and their watersheds. Data in this workflow comes from the following sources:

1)  [National Hydrography Dataset (NHD) Plus V2 Data](https://nhdplus.com/NHDPlus/NHDPlusV2_home.php)
2)  [StreamCat Data](https://www.epa.gov/national-aquatic-resource-surveys/streamcat-dataset)
3)  [Omernik Ecoregion Data](https://www.epa.gov/eco-research/level-iii-and-iv-ecoregions-continental-united-states)
4)  [Aridity Index Data](https://figshare.com/articles/dataset/Global_Aridity_Index_and_Potential_Evapotranspiration_ET0_Climate_Database_v2/7504448/6)

The complete workflow can be deployed by running the `geospatial_for_conus_waters_workflow.Rmd`. Functions used within this workflow are found in the `src` folder; descriptions of each function can also be found in each function's unique .R file. 

For every site, NHD comids are used as the basis for watershed delineation. Subsequently, the resolution of these watershed statistics is at the NHDPlusV2 catchment level. 

# Setting up your site data set

For this code to run properly, your site data **must** be configured as follows:

1)  Each site is identified with a unique site name. In the data set, this column must be called `site`.
2)  Each site has coordinates, with column names `longitude` and `latitude`. Knowledge of coordinate projection required.
    <br>
    **OR:** Each site has their known COMID, with column name `comid`.
4)  Site data table is a CSV, and stored in the `data/` folder.

I have included an example data set called `placeholder.csv` in the `data` folder.

#### Downloading necessary data sets

Currently, this workflow requires downloading several data sets locally for much speedier run times. This includes: PRISM climate & aridity rasters and CONUS-wide NHD catchments (which we suggest when working with many different sites across CONUS). All data sets should be stored in the `data` folder and organized/named as follows:

Aridity: `data/Global-AI_ET0_v3_annual/ai_v3_yr.tif`

Mean precipitation: ``` data/PRISM_ppt_30yr_normal_800mM4_annual_bil/PRISM_ppt_30yr_normal_800mM4_annual_bil.bil ```

Maximum temperature: ``` data/PRISM_tmax_30yr_normal_800mM4_annual_bil/PRISM_tmax_30yr_normal_800mM4_annual_bil.bil ```

Minimum temperature: ``` data/PRISM_tmin_30yr_normal_800mM4_annual_bil/PRISM_tmin_30yr_normal_800mM4_annual_bil.bil ```

Mean temperature: ``` data/PRISM_tmean_30yr_normal_800mM4_annual_bil/PRISM_tmean_30yr_normal_800mM4_annual_bil.bil ```

NHDPlusV2 catchment layer: `data/us_catchments.RDS`

For the complete set of `data` to run this workflow, you can also contact Kathryn Willi at [kathryn.willi\@colostate.edu](mailto:kathryn.willi@colostate.edu).

### Site data assumptions

This analysis is only appropriate for locations along adequately-sized streams. Some streams are too small to be captured by NHDPlusV2; it is also common for coordinates to fall in the wrong catchment (especially for big rivers). For that reason, review each site and make sure that the NHD feature attributes were appropriately captured.
