library(raster)
library(rgdal)
library(sf)
library(sp)
library(rgeos)
library(terra)


# Set the working directory where your shapefiles are located
setwd("E:/SHMP/Data/Drought/clipped_shp")


# Get a list of all shapefiles in the directory
shapefile_list <- list.files(pattern = "\\.shp$")


#Delete the empty shapefiles
# Set the directory path
directory <- "E:/SHMP/Data/Drought/clipped_shp_cleaned"


#Now manually copy and paste all the files from "clipped_shp" folder to "clipped_shp_cleaned" folder


# Get a list of all shapefiles in the directory (prior deleting)
shapefiles <- list.files(directory, pattern = "\\.shp$", full.names = TRUE)



# Iterate over each shapefile
for (shapefile in shapefiles) {
  # Read the shapefile
  shp <- st_read(shapefile)
  
  # Check if the shapefile is empty
  if (nrow(shp) == 0) {
    # Delete the shapefile
    file.remove(shapefile)
    cat("Deleted:", shapefile, "\n")
  }
}


# Set the working directory where the reduced number of shapefiles are located
setwd("E:/SHMP/Data/Drought/clipped_shp_cleaned")


# Create a variable for the output folder for the rasters
output_folder <- "E:/SHMP/Data/Drought/created_rasters_50mi_buffered_100m"


# Get a list of all shapefiles in the directory
shapefile_list_ <- list.files(pattern = "\\.shp$")


# Loop through the shapefile list and convert each shapefile to raster
for (shapefile in shapefile_list_) {
  shp <- readOGR(shapefile)
  r <- raster(nrow = 4200 , ncols = 4200, ext = extent(shp))
  r <- rasterize(shp, r, "DM")
  
  # Create the output filename
  output_filename <- file.path(output_folder, paste0("raster_", basename(shapefile)))
  
  writeRaster(r, filename = output_filename, format = "GTiff")
  
}  


