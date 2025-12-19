library(tidyverse)
library(lubridate)

# bring CSV file and mutate date
bike_data <- read_csv("net_daily_bike_usage_22_25_weather.csv") |>
  mutate(date = as.Date(date))

#  Convert station columns to numeric 
bike_data <- bike_data |>
  mutate(across(2:952, as.numeric))

# It says Warning: There was 1 warning in `mutate()`.
# ℹ In argument: `across(2:952, as.numeric)`.
# Caused by warning:
# ! NAs introduced by coercion

# Pivot long
bike_long <- bike_data %>%
  pivot_longer(
    cols = 2:952,   # station columns by position
    names_to = "station",
    values_to = "rides"
  )

# Summarise usage per station
station_summary <- bike_long |>
  group_by(station) |>
  summarise(
    total_rides      = sum(rides, na.rm = TRUE),
    mean_daily_rides = mean(rides, na.rm = TRUE),
    days_with_usage  = sum(!is.na(rides))
  ) |>
  arrange(desc(total_rides))

# top 10 most‑used stations from entire data
top_10_stations <- head(station_summary, 10)
print(top_10_stations)

# Daily summary of ride activity by each station
station_daily_summary <- bike_long |>
  group_by(station) |>
  summarise(
    mean_rides   = mean(rides, na.rm = TRUE),
    median_rides = median(rides, na.rm = TRUE),
    sd_rides     = sd(rides, na.rm = TRUE),
    min_rides    = min(rides, na.rm = TRUE),
    max_rides    = max(rides, na.rm = TRUE)
  )
