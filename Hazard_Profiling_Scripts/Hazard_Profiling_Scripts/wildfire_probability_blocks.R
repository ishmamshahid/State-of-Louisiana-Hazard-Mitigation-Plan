library(raster)
library(rgdal)
library(sf)
library(sp)
library(rgeos)
library(terra)
library(readxl)
library(dplyr)
library(exactextractr)

options(scipen=999)

setwd("D:/LSU/Summer/State_Hazard_Plan/Data/Wildfire/raster")

fsim <- brick("LA_fsim_5km.tif")

extent(fsim)

small_fires <- brick("small_fire_prob.tif")

extent(small_fires)


small_fires_resampled <- resample(small_fires, fsim, 
                                   method = "bilinear")

plot(small_fires_resampled)

small_fires_resampled[is.na(small_fires_resampled[])] <- 0

plot(fsim)

fsim[is.na(fsim[])] <- 0

plot(fsim)


total_prob <- fsim + small_fires_resampled 
plot(total_prob)


#Clip to Louisiana 5km buffer Shapefile Boundary

setwd("D:/LSU/Summer/State_Hazard_Plan/Risk Assesment/Shapefile")
LA_5km_shapefile <- shapefile("Louisiana5KM_albers.shp")
total_prob <- crop(total_prob, extent(LA_5km_shapefile))
total_prob <- mask(total_prob, LA_5km_shapefile)

plot(total_prob)

setwd("D:/LSU/Summer/State_Hazard_Plan/Data/Wildfire/raster")
writeRaster(total_prob, "total_wildfire_prob.tif")



setwd("D:/LSU/Summer/State_Hazard_Plan/Risk Assesment/hazard_profile_rasters")
wildfire_raster <- raster("total_wildfire_prob.tif")

setwd("D:/LSU/Summer/State_Hazard_Plan/Risk Assesment/Shapefile")
LA_census_blocks_2020 <- st_read("Louisiana_Census_Blocks_2020.shp")


LA_census_blocks_2020$Wildfire <- exact_extract(wildfire_raster, LA_census_blocks_2020, 'mean')


setwd("D:/LSU/Summer/State_Hazard_Plan/Risk Assesment/Block_historical_hazard_intensity_shapefiles")
st_write(LA_census_blocks_2020, "LA_blocks_2020_wildfire.shp")










