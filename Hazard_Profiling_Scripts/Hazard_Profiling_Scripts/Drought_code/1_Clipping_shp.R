library(raster)
library(rgdal)
library(sf)
library(sp)
library(rgeos)
library(terra)


sf_use_s2(TRUE)
#Read the whole USA shapefile, it is in NAD83 projection
USA_shp<-readOGR("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/USA_shp/cb_2018_us_state_20m.shp",
                 "cb_2018_us_state_20m")


#Clip the Louisiana shapefile
LA_shp <- USA_shp[USA_shp$STATEFP ==22, ]



#Take a 1km buffer
LA_shp_ <- st_as_sf(LA_shp)
LA_shp_ <- st_transform(LA_shp_, "+proj=longlat +datum=NAD83 +no_defs")
LA_1_km_buffer <- st_buffer(LA_shp_, 1000)


#Write the created Louisiana boundary to a shapefile and read that again
st_write(LA_shp_, "C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_shp.shp")
LA_shp<-readOGR("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_shp.shp",
                         "LA_shp")


#Write the created 1km buffer to a shapefile and read that again
st_write(LA_1_km_buffer, "C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_1_km_buffer.shp")
LA_1_km_buffer<-readOGR("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_1_km_buffer.shp",
                 "LA_1_km_buffer")


#Change the projection system of the created Louisiana shapefile to wgs84
LA_shp <- spTransform(LA_shp, CRS("+init=epsg:4326"))


#Change the projection system of the created 25km buffer shapefile to wgs84
LA_1_km_buffer <- spTransform(LA_1_km_buffer, CRS("+init=epsg:4326"))


#Write the 1km buffer shapefile which is in wgs84 to a shapefile
LA_1_km_buffer_ <- st_as_sf(LA_1_km_buffer)
st_write(LA_1_km_buffer_, "C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_1_km_buffer_wgs.shp")


#Plot the Louisiana 1km buffer
LA_1_km_buffer_wgs <- readOGR("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_1_km_buffer_wgs.shp",
                               "LA_1_km_buffer_wgs")
plot(LA_1_km_buffer_wgs, col = "transparent", border = "black", lwd = 1)


#Write the Louisiana boundary shapefile which is in wgs84 to a shapefile
LA_shp_ <- st_as_sf(LA_shp)
st_write(LA_shp_, "C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_shp_wgs.shp")


#Plot the Louisiana boundary 
LA_shp_wgs <- readOGR("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_shp_wgs.shp",
                               "LA_shp_wgs")
plot(LA_shp_wgs, col = "transparent",add = TRUE, border = "red", lwd = 1)




#Clip all the files in the directory to LA 25km buffer shapefile, and put the created shapefiles
#in a new directory

sf_use_s2(FALSE)
# Set the working directory
setwd("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/drought_shp")


# Create a variable for the output folder
output_folder <- "C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/clipped_shp"

#List all the shapefiles from the drought_shp folder (current working directory)
shapefiles <- list.files(pattern = "\\.shp$")



# Loop through each shapefile
for (file in shapefiles) {
  # Read the shapefile
  shp <- st_read(file)
  
  # Perform the clipping operation (using the 1km buffer shapefile)
  clipping_polygon <- st_read("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_shp/LA_1_km_buffer_wgs.shp")
  
  clipped <- st_intersection(shp, clipping_polygon)
  
  # Create the output filename
  output_filename <- file.path(output_folder, paste0("clipped_", basename(file)))
  
  # Save the clipped shapefile
  st_write(clipped, output_filename)
}



