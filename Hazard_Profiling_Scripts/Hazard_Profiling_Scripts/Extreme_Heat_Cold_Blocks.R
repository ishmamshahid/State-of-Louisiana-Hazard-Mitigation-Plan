library(raster)
library(rgdal)
library(sf)
library(sp)
library(terra)
library(readxl)
library(dplyr)
library(exactextractr)

options(scipen=999)

setwd("E:/SHMP/Hazard_Profile_Rasters")
Heat_raster <- raster("Num_days_per_yr_gt_95F.tif")

setwd("E:/SHMP/Risk Assesment/Shapefile")
LA_census_blocks_2020 <- st_read("Louisiana_Census_Blocks_2020.shp")


LA_census_blocks_2020$Heat <- exact_extract(Heat_raster, LA_census_blocks_2020, 'mean')


setwd("E:/SHMP/Block_historical_hazard_intensity_shapefiles")
st_write(LA_census_blocks_2020, "LA_blocks_2020_Extreme_Heat.shp")





setwd("E:/SHMP/Hazard_Profile_Rasters")
Cold_raster <- raster("Num_days_per_yr_st_32F.tif")

setwd("E:/SHMP/Risk Assesment/Shapefile")
LA_census_blocks_2020 <- st_read("Louisiana_Census_Blocks_2020.shp")


LA_census_blocks_2020$Cold <- exact_extract(Cold_raster, LA_census_blocks_2020, 'mean')


setwd("E:/SHMP/Block_historical_hazard_intensity_shapefiles")
st_write(LA_census_blocks_2020, "LA_blocks_2020_Extreme_Cold.shp")
