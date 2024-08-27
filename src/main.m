[~] = func_threshold_analysis("..\data\AWS_reprocessed.csv");

[~] = func_darkiceMODIS("H:\AU\darkice\MOD10A1_daily");

[~] = func_darkareaMODIS("..\data\MODIS", "..\print", ...
    "C:\Users\au686295\GitHub\postdoc\Dark-ice-albedo-threshold\data\areacount.xlsx");

[~] = func_timeseries_daily("..\data", "..\print");

[~] = func_timeseries_yearly("..\data", "..\print");

[~] = func_HSA_timeseries("H:\AU\promiceaws\HSA\KAN_M");

[~] = func_aws_hsa("..\data", "H:\AU\promiceaws\HSA\KAN_M");

[~] = func_bareVSdark("..\data\areacount.xlsx");