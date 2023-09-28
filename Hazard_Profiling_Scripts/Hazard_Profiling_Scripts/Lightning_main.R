library(rgdal)
library(raster)
library(sf)
library(data.table)




setwd("E:/SHMP/Data/Lightning")
write_xlsx(nldn_2022, "Lightning_USA_2022.xlsx")

#Delete the first two lines from all the downloaded csv files and put into another
#directory

# Specify the directory containing the CSV files
input_directory <- "E:/SHMP/Data/Lightning/downloaded_csv"

# Specify the directory to save the modified CSV files
output_directory <- "E:/SHMP/Data/Lightning/working_csv"


# Get a list of all CSV files in the input directory
csv_files <- list.files(path = input_directory, pattern = "*.csv", full.names = TRUE)

# Initializes the progress bar
pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = length(csv_files), # Maximum value of the progress bar
                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                     width = 50,   # Progress bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar



step = 0 #To be initialized prior each iteration
# Iterate over each CSV file
for (file_path in csv_files) {
  # Read the CSV file using readlines to preserve the headers
  lines <- readLines(file_path)
  
  # Remove the first two rows
  lines <- lines[-c(1, 2)]
  
  # Create the output file path
  output_file_path <- file.path(output_directory, basename(file_path))
  
  # Write the modified lines to a new CSV file
  writeLines(lines, con = output_file_path)
  
  step = step + 1
  
  setTxtProgressBar(pb,step)
}


# Read the LA_50_mile buffer grid shapefile
setwd("E:/SHMP/Data/Lightning/shp")
LA_50_mile_grids <- st_read("LA_50mi_grid_pts.shp")
#Drop unnecessary columns
LA_50_mile_grids <- LA_50_mile_grids[, -c(1,4)]



# Specify the directory containing the CSV files
input_directory <- "E:/SHMP/Data/Lightning/working_csv"

# Get a list of all CSV files in the input directory
csv_files <- list.files(path = input_directory, pattern = "*.csv", full.names = TRUE)




# Open the modified CSV file in R
step = 0 #To be initialized prior each iteration
sq_mile_conversion = 47.66 #To be checked
start_year = 1987 #need to change
# Iterate over each CSV file
for (file_path in csv_files) {
  # Read the CSV file
  nldn_data <- read.csv(file_path)
  
  # Select rows from nldn_data with matching latitude and longitude values in LA_25_miles_grid
  nldn_data <- nldn_data[nldn_data$CENTERLON %in% LA_50_mile_grids$CENTERLON & nldn_data$CENTERLAT %in% LA_50_mile_grids$CENTERLAT, ]
  
  # Dissolve rows with similar latitude and longitude, aggregating other columns
  nldn_data <- aggregate(. ~ CENTERLON + CENTERLAT, data = nldn_data, FUN = sum)
  
  nldn_data <- nldn_data[,-3]
  
  nldn_raster <- rasterFromXYZ(nldn_data)  #Convert first two columns as lon-lat and third as value                
  
  crs(nldn_raster) <- CRS('+init=EPSG:4326')
  
  #Replace NA values by zero
  nldn_raster <- reclassify(nldn_raster, cbind(NA, 0))
  
  #Raster_Calc
  nldn_raster <- nldn_raster / sq_mile_conversion
  
  setwd("E:/SHMP/Data/Lightning/created_rasters")
  
  writeRaster(nldn_raster, paste("nldn_", step + start_year, ".tif" ))
  
  step = step + 1
  
  setTxtProgressBar(pb,step)

}


setwd("E:/SHMP/Data/Lightning/created_rasters")

raster_files <- list.files(pattern = "\\.tif$")

sum_raster <- NULL

for (file in raster_files) {
  current_raster <- raster(file)
  if (is.null(sum_raster)) {
    sum_raster <- current_raster
  } else {
    sum_raster <- sum_raster + current_raster
  }
}

summed_raster <- sum(sum_raster)

plot(summed_raster)

lightning_per_sq_mile_yr <- summed_raster / 36

plot(lightning_per_sq_mile_yr)

writeRaster(lightning_per_sq_mile_yr, "Lightning_per_sq_mile_yr.tif")


