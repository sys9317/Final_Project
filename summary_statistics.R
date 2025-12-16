library(tidyverse)
library(lubridate)

# bring CSV file and mutate date
bike_data <- read_csv("daily_bike_usage_22_25_weather.csv") |>
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

# 6. Compute total rides per day by summing across all station columns
bike_data <- bike_data |>
  mutate(total_rides = rowSums(across(all_of(station_cols)), na.rm = TRUE))

# Daily total ride and daily activity summary
daily_totals <- bike_long |>
  group_by(date) |>
  summarise(total_rides = sum(rides, na.rm = TRUE))

daily_summary <- daily_totals |>
  summarise(
    mean_rides   = mean(total_rides, na.rm = TRUE),
    median_rides = median(total_rides, na.rm = TRUE),
    sd_rides     = sd(total_rides, na.rm = TRUE),
    min_rides    = min(total_rides, na.rm = TRUE),
    max_rides    = max(total_rides, na.rm = TRUE)
  )

print(daily_summary)

# 7. Monthly trends: aggregate daily totals by year‑month
monthly_summary <- daily_totals |>
  mutate(month = floor_date(date, "month")) |>
  group_by(month) |>
  summarise(
    monthly_rides = sum(total_rides),
    mean_daily    = mean(total_rides)
  ) |>
  arrange(month)

print(monthly_summary)

# I googled how to use floor_date, not sure if that's fine lol

# Maybe we can look up correlation..?