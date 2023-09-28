# Load the raster package
library(raster)

setwd("C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/created_rasters_1km_buffered_100m")
# List all raster files in the directory
raster_files <- list.files(pattern = ".tif$", full.names = TRUE)


# Create a variable for the output folder for the rasters
output_folder <- "C:/LSU/Summer/State_Hazard_Plan/Data/Drought_analysis_R/Reclassified_rasters"


# Loop over each raster file for the reclassification
for (file in raster_files) {
  # Read the raster dataset
  
  
  raster_data <- raster(file)
  
  # Reclassify NA and zero values to 0, and other values to 1
  reclassified_raster <- raster_data
  reclassified_raster[is.na(raster_data) | raster_data == 0] <- 0
  reclassified_raster[raster_data > 0] <- 1
  

  
  # Create the output filename
  output_filename <- file.path(output_folder, paste0("reclass_", basename(file)))
  
  writeRaster(reclassified_raster, filename = output_filename, format = "GTiff")
  
}














