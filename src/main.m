%% This script calls the functions to generate figures and perform analysis on the AWS, HSA, and MODIS data.

% 1. Plot mean albedo +- 1 std over different AWS groups and find abrupt changes in mean and linear trend.
[~] = func_threshold_analysis("..\data\AWS_reprocessed.csv");

% 2. Calculate the albedo, dark ice area and duration from MODIS data and save the results in Excel files. 
% Generate figures of time series of dark ice area, transition days, and duration days.
% MODIS data are not included in the repository, but can be downloaded using GEE (MODISgeeExport.js).
[~] = func_darkiceMODIS("H:\AU\darkice\MOD10A1_daily");

% 3. Plot the statistics of dark ice area and duration days over different years.
[~] = func_darkareaMODIS("..\data\MODIS", "..\print", ...
    "...\data\areacount.xlsx");

% 4. Plot boxplots of dark ice area and time series of dark ice areas in day of year.
[~] = func_timeseries_daily("..\data", "..\print");

% [~] = func_timeseries_yearly("..\data", "..\print");

% 5. Optional function to plot time series maps of HSA for KAN_M from 2019-06-01 to 2019-08-31.
% The HSA data are not included in the repository, but can be downloaded using GEE (https://github.com/fsn1995/Remote-Sensing-of-Albedo).
[~] = func_HSA_timeseries("H:\AU\promiceaws\HSA\KAN_M");
% 6. Generate a figure showing the relationship between albedo and HSA for a specific time period.
[~] = func_aws_hsa("..\data", "H:\AU\promiceaws\HSA\KAN_M");

% 7. Generate a figure showing the relationship between maximum bare ice area and maximum dark ice area.
[~] = func_bareVSdark("..\data\areacount.xlsx");