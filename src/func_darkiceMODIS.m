function outputFolder = func_darkiceMODIS(imfolder)
% FUNC_DARKICEMODIS Calculate the minimum albedo and the days for bare ice to become dark
% using MODIS images.
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
        darkduration451(imindex) = darkduration451(imindex) + 1;
        imindex = (A < darkiceThreshold) | (imcount1 > 0);
        imcount1 = imcount1 + imindex;
        A(imindex) = NaN;
        imindex = (A < bareiceThreshold) & (A >= darkiceThreshold);
        days451(imindex) = days451(imindex) + 1;

        % when dark ice threshold is albedo < 0.431
        darkiceThreshold = 0.431;
        imindex = A < darkiceThreshold;
        darkduration431(imindex) = darkduration431(imindex) + 1;
        imindex = (A < darkiceThreshold) | (imcount2 == 0);
        imcount2 = imcount2 + imindex;
        A(imindex) = NaN;
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