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
Drought_raster <- raster("Drought_Probability.tif")

setwd("E:/SHMP/Risk Assesment/Shapefile")
LA_census_blocks_2020 <- st_read("Louisiana_Census_Blocks_2020.shp")


LA_census_blocks_2020$Drought <- exact_extract(Drought_raster, LA_census_blocks_2020, 'mean')


setwd("E:/SHMP/Block_historical_hazard_intensity_shapefiles")
st_write(LA_census_blocks_2020, "LA_blocks_2020_Drought.shp")
