function figfile = func_aws_hsa(dfFolder, tifFolder)
% func_aws_hsa - Generate a figure showing the relationship between albedo and HSA 
% for a specific time period.
%
% Syntax:
%   figfile = func_aws_hsa(dfFolder, tifFolder)
%
% Input Arguments:
%   - dfFolder: The folder path containing the data files for AWS and HSA.
%   - tifFolder: The folder path containing the TIFF image files.
%
% Output Argument:
%   - figfile: The file path of the generated figure in PDF format.
%
% Description:
% This function reads the AWS and HSA data files from the specified folder, 
% filters the data for a specific time period, and generates a figure showing the relationship 
% between albedo and HSA. The figure includes two subplots: the first subplot displays the albedo 
% and HSA data points, along with two reference lines for albedo values of 0.451 and 0.431; 
% the second subplot displays two satellite images with corresponding albedo and contour plots.
% 
% Shunan Feng (shunan.feng@envs.au.dk)


    dfaws = readtable(fullfile(dfFolder, "AWS_reprocessed.csv"));
    dfhsa = readtable(fullfile(dfFolder, "HSA_reprocessed.csv"));
    dfaws = dfaws(dfaws.aws == "KAN_M" & dfaws.time >= datetime(2019,6,1) & dfaws.time <= datetime(2019,8,31), :);
    dfhsa = dfhsa(dfhsa.aws == "KAN_M" & dfhsa.time >= datetime(2019,6,1) & dfhsa.time <= datetime(2019,8,31), :);

    dfcount = readtable(fullfile(dfFolder, "areacount.xlsx"), "Sheet", "KANM");
    dfcount = dfcount(dfcount.imcount431 > 0 & dfcount.imcount451 > 0, :);

    tiffiles = dir(fullfile(tifFolder, "\**\*.tif"));

    f1 = figure;
    f1.Position = [666 376 1252 644];
    t = tiledlayout(2,4, "TileSpacing", "compact", "Padding", "compact");

    % albedo and HSA
    ax1 = nexttile([1 2]);
    p1 = plot(ax1, dfaws, "time", "albedo", "LineWidth", 2, "DisplayName", "AWS", "Color", "k");
    hold on
    p2 = scatter(ax1, dfhsa, "time", "hsa", "filled", "DisplayName","HSA");
    xlim(ax1, [datetime(2019, 6, 1) datetime(2019, 8, 31)]);
    yline(ax1, 0.451, "--", "\alpha = 0.451", "Color", "#395a62", ...
        "LineWidth", 1.5, 'LabelHorizontalAlignment','right');
    yline(ax1, 0.431, "-.", "\alpha = 0.431", "Color", "#1062b4", ...
        "LineWidth", 1.5, 'LabelHorizontalAlignment','left', 'LabelVerticalAlignment','bottom');
    hold off
    grid on

    df = innerjoin(dfhsa, dfaws, "Keys", "time");
    mdl = fitlm(df.albedo, df.hsa, "linear");

    legend(ax1, [p1 p2], "Location", "north", "NumColumns", 2);
    xlabel(ax1, "");
    ylabel(ax1, "albedo (\alpha)");

    % statistics of albedo thresholds
    dfcount.validratio = (dfcount.imcounttotal - dfcount.imcountmasked)./dfcount.imcounttotal;
    dfcount.overestimation = (dfcount.imcount451 - dfcount.imcount431)./dfcount.imcount431;
    ax6 = nexttile([1 2]);
    p6 = scatter(ax6, dfcount, "imdate", "overestimation", "filled", "colorvariable", "validratio");
    colormap(ax6, crameri("roma"));
    c6 = colorbar(ax6, "eastoutside");
    c6.Label.String = "valid/total pixel ratio";
    grid on
    ylabel(ax6, "dark ice overestimation");
    xlabel(ax6, "");
    xlim(ax6, [datetime(2019, 6, 1) datetime(2019, 8, 31)]);
    

    % map satellite images and albedo
    imfile = tiffiles(30); % 2019-06-13
    [A, R] = readgeoraster(fullfile(imfile.folder, imfile.name));
    imalbedo = A(:,:,end);

    immask = ones(size(imalbedo));
    immask(A(:,:,end) == 0) = nan;
    A = A.*immask;
    imrgb = A(:,:,3:-1:1);
    imrgb(isnan(imrgb)) = 255;
    imalbedo = A(:,:,end);

    [mapx, mapy] = projfwd(R.ProjectedCRS, dfaws.gps_lat(30), dfaws.gps_lon(30));

    ax2 = nexttile;
    mapshow(ax2, imrgb, R, "DisplayType", "image");
    mapshow(ax2, mapx, mapy, "DisplayType","point", ...
            "Marker","o", "MarkerEdgeColor","k", "MarkerFaceColor","r");
    scalebarpsn('location', 'se');

    ax3 = nexttile;
    mapshow(imalbedo, R, "DisplayType", "surface");
    colormap(ax3, func_dpcolor());
    clim(ax3, [0 1]);
    hold on
    contmap = mapshow(imalbedo, R, "DisplayType", "contour", "LineColor", "#1062b4", "LineWidth", 1);
    contmap.LevelList = [0.431 0.431];
    contmap = mapshow(imalbedo, R, "DisplayType", "contour", "LineColor", "#395a62", "LineWidth", 1);
    contmap.LevelList = [0.451 0.451];

    imfile = tiffiles(64); % 2019-08-02
    [A, R] = readgeoraster(fullfile(imfile.folder, imfile.name));
    imalbedo = A(:,:,end);

    immask = ones(size(imalbedo));
    immask(A(:,:,end) == 0) = nan;
    A = A.*immask;
    imrgb = A(:,:,3:-1:1);
    imrgb(isnan(imrgb)) = 255;
    imalbedo = A(:,:,end);

    ax4 = nexttile;
    mapshow(ax4, imrgb, R, "DisplayType", "image");
    mapshow(ax4, mapx, mapy, "DisplayType","point", ...
            "Marker","o", "MarkerEdgeColor","k", "MarkerFaceColor","r");
    scalebarpsn('location', 'se');

    ax5 = nexttile;
    mapshow(imalbedo, R, "DisplayType", "surface");
    colormap(ax5, func_dpcolor());
    c = colorbar(ax5);
    c.Label.String = "\alpha";
    clim(ax5, [0 1]);
    hold on
    contmap = mapshow(imalbedo, R, "DisplayType", "contour", "LineColor", "#1062b4", "LineWidth", 1);
    contmap.LevelList = [0.431 0.431];
    contmap = mapshow(imalbedo, R, "DisplayType", "contour", "LineColor", "#395a62", "LineWidth", 1);
    contmap.LevelList = [0.451 0.451];

    % add text to subplots
    text(ax1, 0.25, 0.8, sprintf("a) r^2 = %.2f, p-value = %.2f", ...
        mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue), "Units", "normalized");
    text(ax6, 0.05, 0.9, "b) $\frac{area (\alpha<0.451) - area (\alpha<0.431)}{area (\alpha<0.431)}$", ...
        "Units", "normalized", "Interpreter", "latex");
    text(ax2, 0, -0.1, "c)", "Units", "normalized");
    text(ax2, 1, 1.2, "2019-06-13", "Units", "normalized");
    text(ax3, 0, -0.1, "d)", "Units", "normalized");
    text(ax4, 0, -0.1, "e)", "Units", "normalized");
    text(ax4, 1, 1.2, "2019-08-02", "Units", "normalized");
    text(ax5, 0, -0.1, "f)", "Units", "normalized");

    fontsize(t, 14, "points");

    imoutputfolder = "..\print";
    figfile = fullfile(imoutputfolder, "aws_hsa.pdf");
    exportgraphics(f1, figfile, 'Resolution', 300);
end
