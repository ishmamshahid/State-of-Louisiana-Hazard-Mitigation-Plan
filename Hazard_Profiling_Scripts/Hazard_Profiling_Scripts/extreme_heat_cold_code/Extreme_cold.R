#Filter out TMIN (0 - 80)
MIN_temp_checked <- data_without_NA[data_without_NA$TMIN > 0 & data_without_NA$TMIN < 80,]
summary(MIN_temp_checked)

#Delete pairs where Tmin>Tmax
MIN_temp_checked <- MIN_temp_checked[MIN_temp_checked$TMIN <= MIN_temp_checked$TMAX, ]



#Check the number of observed days for each station in the NA removed data
MIN_temp_checked_num_observed_days <- as.data.frame(table(as.matrix(MIN_temp_checked$STATION)))



#Number of stations that have no NA value in TMAX and TMIN, passed the MIN_temp_check
length(unique(MIN_temp_checked_num_observed_days$Var1))


#Percent of Days Reporting (PDR) check. Discard the station which if it is
#less than 90 percent.

number_of_observed_days <- number_of_observed_days_raw[number_of_observed_days_raw$Var1 %in% MIN_temp_checked_num_observed_days$Var1,]

Ratio <- MIN_temp_checked_num_observed_days$Freq / number_of_observed_days$Freq

number_of_observed_days <- cbind(MIN_temp_checked_num_observed_days, Ratio)

#Select the stations having more than 5 years of daily observations and the
#Percent of days reporting ratio of >0.9

selected_stations <- number_of_observed_days[number_of_observed_days$Freq > 1825 & number_of_observed_days$Ratio >= 0.9, ]

selected_stations_lat_long <- GHCN_US_stations[GHCN_US_stations$STATION %in% selected_stations$Var1,]






#Number of days for each station TMIN < 32 
length(unique(MIN_temp_checked$STATION))
#First filter out the TMAX checked stations that had the PDR ratio of less than 0.9 
TMIN_data_sel <- MIN_temp_checked[MIN_temp_checked$STATION %in% selected_stations$Var1,]

length(unique(TMIN_data_sel$STATION))

summary(TMIN_data_sel)

count_stations_TMIN_st_32 <- aggregate(TMIN ~ STATION, 
                                       TMIN_data_sel, function(x) sum(x < 32))

sum(count_stations_TMIN_st_32$TMIN)

#Check 
sum(TMIN_data_sel$TMIN < 32)

#See how many years of data is available for the selected stations

# Extract year from Date column
TMIN_data_sel$Year <- format(TMIN_data_sel$Date, "%Y")

# Calculate the number of years of data for each station
count_stations_TMIN_st_32$years_data_available <- aggregate(Year ~ STATION, 
                                                            data = TMIN_data_sel, 
                                                            FUN = function(x) length(unique(x)))

colnames(count_stations_TMIN_st_32)[colnames(count_stations_TMIN_st_32) == "TMIN"] <- "Number of times TMIN below 32"

#For each station calculate the number of days per year that TMAX > 95
count_stations_TMIN_st_32$num_days_per_year <- count_stations_TMIN_st_32$`Number of times TMIN below 32` / count_stations_TMIN_st_32$years_data_available$Year


count_stations_TMIN_st_32 <- cbind(count_stations_TMIN_st_32, selected_stations_lat_long$LAT,selected_stations_lat_long$LONG )


write.csv(count_stations_TMIN_st_32, "number_of_days_per_yr_st_32.csv")

