function outputFolder = func_darkiceMODIS(imfolder)
% FUNC_DARKICEMODIS Calculate albedo, the days for bare ice to become dark,
% and dark ice duration using MODIS images.
%
% Shunan Feng (shunan.feng@envs.au.dk)

imfiles = dir(fullfile(imfolder, '*.tif'));
imdate = string({imfiles.name}.');
imdate = datetime(extractBetween(imdate, "_", ".tif"),...
    "InputFormat", "uuuu-MM-dd");
[y, ~, ~] = ymd(imdate);

[immask, ~] = readgeoraster("..\data\greenland_ice_mask.tif");

outputFolder = fullfile("..\data", "MODIS");
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
df = array2table(zeros(0, 3), 'VariableNames', ["date", "darkice_area451", "darkice_area431"]);
writetable(df, fullfile(outputFolder, "darkice_daily_MODIS.csv"), ...
    "WriteVariableNames", true, "WriteMode", "overwrite");

for i = min(y):1:max(y)

    index = y == i;
    imfiles_year = imfiles(index, :);

    % create a new image by reading the first image
    [minA, R] = readgeoraster(fullfile(imfolder, imfiles_year(1).name), "OutputType", "single");
    minA = NaN(size(minA), "single");
    days451 = zeros(size(minA), "single"); % days when the bare ice (albedo < 0.565) becomes dark
    days431 = zeros(size(minA), "single"); % days when the bare ice (albedo < 0.565) becomes dark
    imcount1 = zeros(size(minA), "single"); % to mark the images that have albedo < 0.451
    imcount2 = zeros(size(minA), "single"); % to mark the images that have albedo < 0.431
    darkduration431 = zeros(size(minA), "single"); % duration of dark ice (albedo < 0.431)
    darkduration451 = zeros(size(minA), "single"); % duration of dark ice (albedo < 0.451)

    % loop through all images to find the minimum value
    for j = 1:height(imfiles_year)

        fprintf("Processing %s\n", imfiles_year(j).name);
        [A, ~] = readgeoraster(fullfile(imfolder, imfiles_year(j).name), "OutputType", "single");
        A = A/100;
        A(A == 0) = NaN;
        minA = min(A, minA, "omitmissing");

        % calculate the days for bare ice to become dark
        bareiceThreshold = 0.565;

        % when dark ice threshold is albedo < 0.451
        darkiceThreshold = 0.451;
        imindex = A < darkiceThreshold;
        
        % save the daily dark ice area to csv
        date = datetime(extractBetween(imfiles_year(j).name, "_", ".tif"),...
            "InputFormat", "uuuu-MM-dd");
        darkice_area451 = sum(imindex, "all") * 500 * 500;
        df = table(date, darkice_area451);
        % writetable(df, fullfile(outputFolder, "darkice_daily_MODIS.csv"), ...
        %     "WriteMode", "append", "WriteVariableNames", false);

        darkduration451(imindex) = darkduration451(imindex) + 1;
        % imindex = (A < darkiceThreshold) ;
        imcount1 = imcount1 + imindex;
        A(imcount1>0) = NaN;
        imindex = (A < bareiceThreshold) & (A >= darkiceThreshold);
        days451(imindex) = days451(imindex) + 1;

        % when dark ice threshold is albedo < 0.431
        [A, ~] = readgeoraster(fullfile(imfolder, imfiles_year(j).name), "OutputType", "single");
        A = A/100;
        A(A == 0) = NaN;
        darkiceThreshold = 0.431;
        imindex = A < darkiceThreshold;

        % save the daily dark ice area to csv
        df.darkice_area431 = sum(imindex, "all") * 500 * 500;
        writetable(df, fullfile(outputFolder, "darkice_daily_MODIS.csv"), ...
            "WriteMode", "append", "WriteVariableNames", false);

        darkduration431(imindex) = darkduration431(imindex) + 1;
        % imindex = (A < darkiceThreshold);
        imcount2 = imcount2 + imindex;
        A(imcount2>0) = NaN;
        imindex = (A < bareiceThreshold) & (A >= darkiceThreshold);
        days431(imindex) = days431(imindex) + 1;

    end

    % mask the image
    minA(immask == 0) = NaN;
    days451(immask == 0) = NaN;
    days431(immask == 0) = NaN;
    darkduration431(immask == 0) = NaN;
    darkduration451(immask == 0) = NaN;

    % save the variables
    save(fullfile(outputFolder, "MODIS_" + string(i) + ".mat"),...
     "minA", "R", "days431", "days451", "darkduration431", "darkduration451");

end
end