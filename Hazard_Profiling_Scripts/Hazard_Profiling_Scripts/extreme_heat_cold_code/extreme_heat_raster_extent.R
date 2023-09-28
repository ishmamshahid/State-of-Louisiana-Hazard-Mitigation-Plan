library(raster)
library(rgdal)
library(sf)
library(sp)
library(rgeos)
library(terra)
library(readxl)
library(dplyr)
library(exactextractr)


#Reference for extent

setwd("D:/LSU/Summer/State_Hazard_Plan/Data/Wildfire/raster")
fsim <- brick("LA_fsim_5km.tif")

setwd("D:/LSU/Summer/State_Hazard_Plan/Risk Assesment/Shapefile")
LA_5km <- st_read("LouisianaOutlineBuffer5KM.shp")


setwd("D:/LSU/Summer/State_Hazard_Plan/Data/Extreme_heat_cold/Heat_Cold/Raster")
extreme_heat <- brick("heat_95F_to_be_corrected_albers.tif")

extreme_heat

extreme_heat[extreme_heat < 0] <- 0

extreme_heat

extent(LA_5km)

extent(fsim)

extent(extreme_heat)


extreme_heat <- resample(extreme_heat, fsim, 
                                  method = "bilinear")

plot(extreme_heat)

extreme_heat[is.na(extreme_heat[])] <- 0

plot(extreme_heat)





#Clip to Louisiana 5km buffer Shapefile Boundary

setwd("D:/LSU/Summer/State_Hazard_Plan/Risk Assesment/Shapefile")
LA_5km_shapefile <- shapefile("Louisiana5KM_albers.shp")
extreme_heat <- crop(extreme_heat, extent(LA_5km_shapefile))
extreme_heat <- mask(extreme_heat, LA_5km_shapefile)

plot(extreme_heat)

setwd("D:/LSU/Summer/State_Hazard_Plan/Data/Extreme_heat_cold/Heat_Cold/Raster")
writeRaster(extreme_heat, "extreme_heat_95F.tif")








