library(raster)
library(rgdal)
library(sf)
library(sp)
library(terra)
library(readxl)
library(dplyr)
library(exactextractr)

options(scipen=999)

setwd("D:/LSU/Summer/State_Hazard_Plan/Data/Hazard_Profile_Rasters")
tornado_raster <- raster("Tornado.tif")

setwd("D:/LSU/Summer/State_Hazard_Plan/Risk Assesment/Shapefile")
LA_census_blocks_2020 <- st_read("Louisiana_Census_Blocks_2020.shp")


LA_census_blocks_2020$Tornado <- exact_extract(tornado_raster, LA_census_blocks_2020, 'mean')


setwd("D:/LSU/Summer/State_Hazard_Plan/Data/Block_historical_hazard_intensity_shapefiles")
st_write(LA_census_blocks_2020, "LA_blocks_2020_tornado.shp")
