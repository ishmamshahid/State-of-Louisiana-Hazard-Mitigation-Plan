library(raster)
library(rgdal)
library(sf)
library(sp)
library(rgeos)
library(terra)
library(lubridate)
library(openxlsx)


GHCN_US_stations <- read.csv("stations.csv")
raw_data <- read.csv("raw_data.csv")

stations_at_50mi_NAD_83 <- readOGR("D:/LSU/Summer/State_Hazard_Plan/Data/Extreme_heat_cold/Heat_Cold/shapefile/stations_at_50mi_NAD83.shp",
                            "stations_at_50mi_NAD83")


LA_shp_NAD_83 <- readOGR("D:/LSU/Summer/State_Hazard_Plan/Data/Extreme_heat_cold/Heat_Cold/shapefile/LA_NAD83.shp",
                      "LA_NAD83")

plot(stations_at_50mi_NAD_83, pch = 16 )
plot(LA_shp_NAD_83, col = "transparent", add = TRUE, border = "red", lwd = 1)

#Stations that were selected from the 50mi buffer in ArcGIS
stations_to_take <- stations_at_50mi_NAD_83$STATION



#Remove whitespace
GHCN_US_stations <- as.data.frame(apply(GHCN_US_stations,2, function(x) gsub("\\s+", "", x)))


#Subset raw data to selected stations
raw_data_subset <- raw_data[raw_data$STATION %in% stations_to_take,]


#Drop the TMAX and TMIN attributes column
raw_data_subset <- raw_data_subset[,-c(8,10)]

length(unique(raw_data_subset$STATION))

#summary(raw_data_subset)



#Convert to date object from character
Date <- ymd(raw_data_subset$DATE)

raw_data_subset <- cbind(raw_data_subset, Date)

class(raw_data_subset$Date)
class(raw_data_subset$DATE)

raw_data_subset <- raw_data_subset[,-6]
summary(raw_data_subset)




#Check the number of observed days for each station in the raw data
number_of_observed_days_raw <- as.data.frame(table(as.matrix(raw_data_subset$STATION)))




# Subset the dataframe to remove rows with NA values in specified columns
data_without_NA <- raw_data_subset[complete.cases(raw_data_subset[6:7]),]
summary(data_without_NA)

