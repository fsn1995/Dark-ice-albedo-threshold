function outputFigurePath = func_timeseries_daily(dfFolder, imoutputfolder)
% func_timeseries_daily plot daily dark ice area with standard deviation    
%   Input:
%       dfFolder: string, the folder containing the darkice_daily_MODIS.csv
%       imoutputfolder: string, the folder to save the output figure
%   Output:
%       outputFigurePath: string, the path of the output figure
%
%   Shunan Feng (shunan.feng@envs.au.dk)
    
    dfdaily = readtable(fullfile(dfFolder, "MODIS\darkice_daily_MODIS.csv"));
    % dfyearly = readtable(fullfile(dfFolder, "areacount.xlsx"), "Sheet", "MODIS");

    dfdaily.doy = day(dfdaily.date, "dayofyear");
    dfdaily.year = year(dfdaily.date);
    dfdaily.darkice_area451 = dfdaily.darkice_area451 / 1e6; % convert to km^2
    dfdaily.darkice_area431 = dfdaily.darkice_area431 / 1e6; % convert to km^2
    % statistics
    dfdailystat_mean = grpstats(dfdaily, "year", "mean", ...
        "DataVars", ["darkice_area451", "darkice_area431"]);
    dfdailystat_doy = grpstats(dfdaily, "doy", ["mean", "std"], ...
        "DataVars", ["darkice_area451", "darkice_area431"]);    
    yearList = unique(dfdaily.year);

    %% plot daily dark ice area with standard deviation
    f1 = figure;
    f1.Position = [366 55 865 706];
    t = tiledlayout(2,1, "TileSpacing", "compact", "Padding", "compact");
    ax1 = nexttile;
    l1 = plot(ax1, dfdailystat_doy.doy, dfdailystat_doy.mean_darkice_area431, ...
        'Color', '#1062b4', 'DisplayName', 'mean dark ice area (\alpha<0.431)', 'LineWidth',2);
    hold on
    plotci(ax1, dfdailystat_doy.doy, dfdailystat_doy.mean_darkice_area431 + dfdailystat_doy.std_darkice_area431, ...
        dfdailystat_doy.mean_darkice_area431 - dfdailystat_doy.std_darkice_area431, '#1062b4');
    l2 = plot(ax1, dfdailystat_doy.doy, dfdailystat_doy.mean_darkice_area451, ...
        'Color', '#395a62', 'DisplayName', 'mean dark ice area (\alpha<0.451)','LineWidth',2);
    plotci(ax1, dfdailystat_doy.doy, dfdailystat_doy.mean_darkice_area451 + dfdailystat_doy.std_darkice_area451, ...
        dfdailystat_doy.mean_darkice_area451 - dfdailystat_doy.std_darkice_area451, '#395a62');
    grid on
    xlim(ax1, [min(dfdailystat_doy.doy) max(dfdailystat_doy.doy)]);
    xlabel(ax1, "day of year");
    ylabel(ax1, "daily dark ice area (km^2)");
    legend(ax1, [l1, l2], 'Location', 'best');

    %% plot as boxplot
    dfdaily = [dfdaily; dfdaily]; % 
    dfdaily.darkice_area = ones(height(dfdaily), 1);
    dfdaily.darkice_area(1:height(dfdaily)/2) = dfdaily.darkice_area451(1:height(dfdaily)/2);
    dfdaily.darkice_area(height(dfdaily)/2+1:end) = dfdaily.darkice_area431(height(dfdaily)/2+1:end);
    dfdaily.darkice_threshold = string(ones(height(dfdaily), 1));
    dfdaily.darkice_threshold(1:height(dfdaily)/2) = "\alpha<0.451";
    dfdaily.darkice_threshold(height(dfdaily)/2+1:end) = "\alpha<0.431";
    dfdaily = removevars(dfdaily, {'darkice_area451', 'darkice_area431'});

    ax2 = nexttile;
    b1 = boxchart(ax2, dfdaily.year, dfdaily.darkice_area, "GroupByColor", dfdaily.darkice_threshold, ...
        "Notch", "on");
    hold on

    scatter(ax2, dfdailystat_mean.year, dfdailystat_mean.mean_darkice_area431,...
     'filled', 'MarkerFaceColor', '#1062b4', 'DisplayName', 'mean dark ice area (\alpha<0.431)');
    scatter(ax2, dfdailystat_mean.year, dfdailystat_mean.mean_darkice_area451,...
     'filled', 'MarkerFaceColor', '#395a62', 'DisplayName', 'mean dark ice area (\alpha<0.451)');

    b1(1).BoxFaceColor = "#1062b4";
    b1(2).BoxFaceColor = "#395a62";
    b1(1).MarkerColor = "#1062b4";
    b1(2).MarkerColor = "#395a62";
    xlim(ax2, [min(yearList)-0.5 max(yearList)+0.5]);
    xlabel(ax2, "year");
    ylabel(ax2, "daily dark ice area (km^2)")
    grid(ax2, 'on');
    legend(ax2, 'numcolumns', 2, 'Location', 'best');

    text(ax1, 0.95, 0.9, 'a)', 'Units', 'normalized');
    text(ax2, 0.95, 0.9, 'b)', 'Units', 'normalized');
    fontsize(t, 14, "points");

    outputFigurePath = fullfile(imoutputfolder, "darkice_daily_MODIS.pdf");
    % if figfile exist, delete it
    if isfile(outputFigurePath)
        delete(outputFigurePath);
    end
    exportgraphics(f1, outputFigurePath, 'Resolution', 300);

    %% Nested function to plot confidence interval
    function plotci(ax, x, meanH, meanL, colorcode)
        index = isnan(meanH);
        p = fill(ax, [x(~index); flipud(x(~index))], [meanH(~index); flipud(meanL(~index))], 'k');
        p.FaceColor = colorcode;
        p.EdgeColor = "none";
        p.FaceAlpha = 0.3;
    end
end
