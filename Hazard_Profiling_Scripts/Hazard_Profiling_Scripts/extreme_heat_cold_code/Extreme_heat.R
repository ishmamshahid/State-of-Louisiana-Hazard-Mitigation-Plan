#Filter out TMAX (50 - 120)
MAX_temp_checked <- data_without_NA[data_without_NA$TMAX > 50 & data_without_NA$TMAX < 120,]
summary(MAX_temp_checked)

#Delete pairs where Tmin>Tmax
MAX_temp_checked <- MAX_temp_checked[MAX_temp_checked$TMIN <= MAX_temp_checked$TMAX, ]



#Check the number of observed days for each station in the NA removed data
MAX_temp_checked_num_observed_days <- as.data.frame(table(as.matrix(MAX_temp_checked$STATION)))



#Number of stations that have no NA value in TMAX and TMIN, passed the MAX_temp_check
length(unique(MAX_temp_checked_num_observed_days$Var1))


#Percent of Days Reporting (PDR) check. Discard the station which if it is
#less than 90 percent.

number_of_observed_days <- number_of_observed_days_raw[number_of_observed_days_raw$Var1 %in% MAX_temp_checked_num_observed_days$Var1,]

Ratio <- MAX_temp_checked_num_observed_days$Freq / number_of_observed_days$Freq

number_of_observed_days <- cbind(MAX_temp_checked_num_observed_days, Ratio)

#Select the stations having more than 5 years of daily observations and the
#Percent of days reporting ratio of >0.9

selected_stations <- number_of_observed_days[number_of_observed_days$Freq > 1825 & number_of_observed_days$Ratio >= 0.9, ]

selected_stations_lat_long <- GHCN_US_stations[GHCN_US_stations$STATION %in% selected_stations$Var1,]






#Number of days for each station TMAX > 95 
length(unique(MAX_temp_checked$STATION))
#First filter out the TMAX checked stations that had the PDR ratio of less than 0.9 
TMAX_data_sel <- MAX_temp_checked[MAX_temp_checked$STATION %in% selected_stations$Var1,]

length(unique(TMAX_data_sel$STATION))

summary(TMAX_data_sel)

count_stations_TMAX_gt_95 <- aggregate(TMAX ~ STATION, 
                                       TMAX_data_sel, function(x) sum(x > 95))

sum(count_stations_TMAX_gt_95$TMAX)

#Check 
sum(TMAX_data_sel$TMAX > 95)

#See how many years of data is available for the selected stations

# Extract year from Date column
TMAX_data_sel$Year <- format(TMAX_data_sel$Date, "%Y")

# Calculate the number of years of data for each station
count_stations_TMAX_gt_95$years_data_available <- aggregate(Year ~ STATION, 
                                                            data = TMAX_data_sel, 
                                                            FUN = function(x) length(unique(x)))

colnames(count_stations_TMAX_gt_95)[colnames(count_stations_TMAX_gt_95) == "TMAX"] <- "Number of times TMAX exceeding 95"

#For each station calculate the number of days per year that TMAX > 95
count_stations_TMAX_gt_95$num_days_per_year <- count_stations_TMAX_gt_95$`Number of times TMAX exceeding 95` / count_stations_TMAX_gt_95$years_data_available$Year


count_stations_TMAX_gt_95 <- cbind(count_stations_TMAX_gt_95, selected_stations_lat_long$LAT,selected_stations_lat_long$LONG )


write.csv(count_stations_TMAX_gt_95, "number_of_days_per_yr_gt_95.csv")



