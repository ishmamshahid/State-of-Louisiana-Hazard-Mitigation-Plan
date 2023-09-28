library(raster)
library(rgdal)
library(sf)
library(sp)
library(rgeos)
library(terra)


setwd("E:/SHMP/Data/Drought/Reclassified_rasters")
# Get a list of all rasters in the directory
raster_list_ <- list.files(pattern = "\\.tif$")



##Read all the individual rasters from file

raster_brick_list = c()

# Initializes the progress bar
pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = length(raster_list_), # Maximum value of the progress bar
                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                     width = 50,   # Progress bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar


#Read the reclassified rasters and assign
for(i in 1:length(raster_list_)) { 
 
  assign(paste0("raster_", i), brick(raster_list_[[i]]))
  setTxtProgressBar(pb,i)
}


# List objects in the global environment
object_names <- ls(envir = globalenv())

# Create an empty list to store the raster objects
raster_list <- list()

# Iterate through the object names and check if they are RastersBrick
for (name in object_names) {
  obj <- get(name)
  if (is(obj, "RasterBrick") || inherits(obj, "RasterBrick")) {
    raster_list[[name]] <- obj
  }
  
}

#Read the reference raster of whose extent to be enforced upon all the rasters

ref_raster <- brick("E:/SHMP/Data/Drought/Reclassified_rasters/reclass_raster_clipped_USDM_20000104.tif")



#Resample to the extent of the reference raster so that extent of all the rasters are the same.
#In this case the first raster has the full extent, so it has been used as the reference raster.

resampled_rasters <- list()

# Loop through the raster bricks and resample each one
for (i in seq_along(raster_list)) {
  resampled_rasters[[i]] <- resample(raster_list[[i]], ref_raster, 
                                    method = "bilinear")
  setTxtProgressBar(pb,i)
}





#plot(resampled_rasters[[3]])



#Replace all the NA value within the extent of all the rasters

for (i in seq_along(raster_list)) {
  resampled_rasters[[i]][is.na(resampled_rasters[[i]][])] <- 0
  setTxtProgressBar(pb,i)
}

#plot(resampled_rasters[[3]])



#Stack all the rasters from the Reclassified_rasters folder

stacked_raster <- stack(resampled_rasters)

raster_sum <- calc(stacked_raster, sum)

#plot(raster_sum)

#Clip to Louisiana Shapefile Boundary

LA_shapefile <- shapefile("E:/SHMP/Risk Assesment/Shapefile/LA_50mi_buffer.shp")
raster_sum <- crop(raster_sum, extent(LA_shapefile))
raster_sum <- mask(raster_sum, LA_shapefile)

plot(raster_sum)


setwd("E:/SHMP/Data/Drought/Output_rasters")
writeRaster(raster_sum, "raster_sum.tif")




