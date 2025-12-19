# Final_Project

## QMD #1: reorg_cap_data_test.qmd

In this QMD, we start by downloading the monthly Capital Bikeshare CSVs from
January 2022-November 2025, which total 47 CSVs. We then create a function that 
narrows down the variables to just the ones relevant to our project (i.e. 
started_at, start_station_name, start_station_id, end_station_name, 
end_station_id) and get rid of bikes that depart or arrive at non-stations, 
meaning those that were not parked at a station. We apply that function to all
47 CSVs.

We then create a function that splits the data into two: first, the station 
where bikes started their routes and second, the station where bikes ended their 
routes. This allows us to know, for any given station, how many rides started 
vs. ended there. We then reshape each half of the data so there is one row per 
day, and there is a column with the number of bikes that started or ended at 
that station (depending on which half of the data it is). We then merge the two
halves of the data back together, but we add the number of bikes that started at
a given station with the number of bikes that ended at that same station in a 
"merged counts"variable. It then calculates a "net activity" count by doing 
"bike ends - bike starts." This means that if more bikes start (or depart) from
a station than end (or arrive) at a station, net activity will be negative. Net
positive would mean that more bikes arrived at a station than departed. We did
it this way so that a negative net number would indicate the potential need for
vans to refill a given station. 

After running that function on all 47 CSVs, we then combine the rows from
all 47 CSVs into one file so that we have all of the data, from January 2022 to
November 2025, in one dataset. In cases where the CSVs repeat days, we remove 
that and tally their totals. We then save our updated dataset as a new CSV: 
net_daily_bike_usage_22_25.csv.

We then call on that new dataset and read in two weather CSVs that have weather
predictions for our entire time frame. There are two weather CSVs because we
were unable to download predictions for our entire timeframe in one go, so we 
downloaded them separately and merged them. We then merge our weather dataset 
with our original dataset and save it as: 
"net_daily_bike_usage_22_25_weather.csv"

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

## QMD#3: finalproject_cleaning.qmd
After reading in the CSV we created in the reorg_cap_data_test.qmd and
downloading the necessary libraries, we begin our setup for the model. Our first
step is lagging the data by 3 weeks. This means that the data in the columns
for each station will represent the data from 3 weeks earlier. For example, 
in the row for 1-22-2022, the numbers in each station column actually depict 
ridership from 1-1-2022. The purpose of this is to create a "recency" X 
variable. Meaning, in the same way that, in predicting ridership (our Y 
variable) our model will consider weather and whether it's a holiday, another 
consideration will be what ridership has looked like recently. To concretize 
recency, we chose to focus on the data from 3 weeks ago.

To set the data up to lag by 3 weeks, we select the columns representing the 
different stations, we create a "ridership" variable that hones in our station 
of choice, the Capital Bikeshare station at New Hampshire & T Street. That means
that the only station we will be predicting data for is the New Hampshire & T 
Street station. We then reset our data to include the date, ridership variable, 
and the data for all stations. We then create another dataset, data_lead, that 
conducts the 3 week lag. To do so, we use the mutate function to tell R to 
create a "lead" of 21 days. This makes the data in the station columns for 
1-22-2022 actually represent the data from 3 weeks earlier, on 1-1-2022. We then
save our dataset as "lead_data.CSV."

Note: We chose a 3 week lag, but we could have chosen 2 weeks ago, 1 week ago, 
etc. We tested out the model with a 21, 14, 10, and 2-day lag, and ultimately 
got very comparable results, so we went wth 21 days, or 3 weeks.

We then merged our weather data onto our lead_data.CSV on the variable date and
saved this CSV as "lead_data_weather.CSV." Then, using this updated CSV, we 
force the date to be a proper date type so it is identifiably a date and not a
set of characters, for example. We then hone in on all columns besides for
ridership.

Then, we create a recipe using all variables (which we just set to be all 
variables besides ridership) that creates a new column for each of the following
holidays: Labor Day, New Years Day, Christmas Day, Easter, Good Friday, US 
Independence Day, US Memorial Day, US Thanksgiving Day, US Veterans Day, and US 
MLK's Birthday. Each column is set up as a dummy, coding each observation as 1 
if it fell on a given holiday. For example, 1-1-2022, 1-1-2023, 1-1-2024, and 
1-1-2025 are all coded as 1 for New Years Day. We then prepped the recipe and 
baked it, functionally applying the recipe. 

We then create two columns, one with a dummy variable for precip, or rain, and
the other with a dummy variable for snow. We do this so that we can later 
complement our general weather X variable with variables representing whether it
rained and whether it snowed. We then saved our dataset as:
"final_lead_data_weather.csv."

## QMD#4: model_making.qmd

After loading all of the necessary libraries, we use the date variable to 
extract weekday, month, and yearday (so January 2 would be yearday 2). These 
will be used as predictors in our model. We then split our data into modeling 
and implementation data. The modeling dataencompasses all variables from January
2022 - October 2025. The implementation data covers November 2025 and includes 
all variables except ridership. This is because our model will be predicting 
ridership for November 2025. We then split our modeling data into a training and
testing datasets. Next we  extract the training portion (which will later be 
used for fitting the model, tuning, and creating resampling folds) and the 
testing portion from the split data. Finally, we use the training dataset to 
create cross-validation resamples, repeating the ten fold split five times 
(totaling 50 folds).

Next, we create a recipe. Our recipe:
- treats date as an ID variable (not a 
predictor) 
- removes variables from the prediction that are the same for all (or 
nearly all) observations
- turns categorical variables into dummy variables (so 
the day of the week column would instead be treated as seven individual 0/1
columns)
- removes exact linear combinations ***EXPLAIN*** and removes highly correlated
predictors to reduce multicollinearity and overfitting
- normalizes predictors, setting the mean at 0 and the standard deviation at 1

After creating our recipe, we incorporate it into our various models: linear
regression, KNN, random forest, ridge, regression trees, and lasso. 

We hyperparameterize our:
- KNN model: we set k to be between 1 and 99 and test 10  values that are spaced
out the same way; for example, 2, 12, 22, 32 etc.
- random forest: 500 trees, which is a large enough forest that it should reduce
variance levels and improve the consistency of our prediction; at each split, 
the model considers between 1 and 10 randomly selected predictors and allows the
tree to keep splitting until the final groups contain at least 1 to 20 data 
points
- ridge: with a penalty of 30, which is very strong regularization
- regression tree: with a small value of 0.001 that should allow for a lot of 
splits, but produces a penalty on them to prevent overfitting
- lasso: with 30 evenly spaced penalty values ranging from 10^-4 to 10^2, the 
former of which produces very little penalty and the latter of which produces a
strong penalty

We then calculate the RMSEs for each of our different models. We identify the
random forest model as the best model, as it has the lowest RMSE. We then 
create a visual demonstrating how RMSE varies across different cross-validation
folds for our linear regression model.

We then create final_fit which uses the random forest model and fits the
workflow onto the training portion of data_split and evaluates it on the testing
portion of data_split. We create test_pred to generate predictions on the
testing dataset. We then attach those predictions to the testing dataset and 
compute RMSE, which compares the true values to the predicted values. Finally,
we extract our RMSE value for our date of interest.

Our last block of code, "Final Predictions," makes predictions for the 
implementation data and attaches those predictions to the dates we care about. 
We then attach the predictions to our results table, which has a column for
date, ridership, and predictions.

To identify the most active or popular stations, we sort by the highest amount
of activity. We then compute the total rides per day for each station
***CLARIFY WITH YOSUP IF IT'S PER STATION OR ACROSS ALL STATIONS***. Lastly, we 
look for monthly trends

[See our Bibliography](bibliography.md)
