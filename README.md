# Final_Project

## QMD #1: reorg_cap_data_test

In this QMD, we start by downloading the monthly Capital Bikeshare CSVs from
January 2022-November 2025. This totals 47 CSVs. We then narrow down the 
variables to just the ones relevant to our project (i.e. started_at, 
start_station_name, start_station_id, end_station_name, end_station_id) 
and ***CLARIFY WITH RONIN*** reorganize the data so that each of the 47 CSVs has
one row per day. We get rid of bikes that depart or arrive at non-stations, 
meaning those that were not parked at a station. 

We then split the data into two: first, the station where bikes started their 
routes and second, the station where bikes ended their routes. This allows us to
know, for any given station, how many rides started vs. ended there. We then 
reshape each half of the data so that each of the 47 CSVs has one row per day, 
and there is one column with the number of bikes that started at a given station
and one column with the number of bikes that ended at that station. This means 
there are two columns for each station. We then merge the two halves of the data
back together, but we add the number of bikes that started at a given station 
with the number of bikes that ended at that same station in a "merged counts"
variable. It then calculates a "net activity" count by doing "bike ends - bike 
starts." This means that if more bikes start (or depart) from a station than end
(or arrive) at a station, net activity will be negative. Net positive would mean
that more bikes arrived at a station than departed. We did it this way so that
a negative net number would indicate the potential need for vans to refill said
station. 

After running that data process on all 47 CSVs, we then combine the rows from
all 47 CSVs into one file so that we have all of the data, from January 2022 to
November 2025, in one dataset and save it as a new CSV: 
net_daily_bike_usage_22_25.csv.

We then call on that new dataset and read in two weather CSVs that have weather
predictions for our entire time frame. ***JUNK CODE??*** We then merge our net 
activity column back onto our original dataset.

## QMD#2: summary stats.qmd

In this QMD, we start by making the date column of our dataset function as a 
date instead of a string of characters. We then make all of our station
variables numeric. Next, we reshape our data to appear as long instead of wide 
so we can look at activity by station. We calculate each stations total rides, 
average rides, and days with usage. Rides include bikes leaving from a station
and bikes arriving at a station. 

To identify the most active or popular stations, we sort by the highest amount
of activity. We then compute the total rides per day for each station
***CLARIFY WITH YOSUP IF IT'S PER STATION OR ACROSS ALL STATIONS***. Lastly, we 
look for monthly trends

