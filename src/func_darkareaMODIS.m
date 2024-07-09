function outputFigurePath = func_darkareaMODIS(imfolder, imoutputfolder, statisticsfile)
% This function creates a timeseries plot of yearly mean and standard deviation of bare to dark ice transition days and dark ice duration days.
% The data is read from the tif images and maps saved in imoutputfolder.
% It also calcaultes the statistics of dark ice area and save it to an excel file.
% The function returns the path of the output figure.
% Shunan Feng (shunan.feng@envs.au.dk)

    imfiles = dir(fullfile(imfolder, "MODIS_*.mat"));
    imdate = string({imfiles.name}.');
    imdate = extractBetween(imdate, "MODIS_", ".mat");

    % if figfile exist, delete it
    if isfile(fullfile(imoutputfolder, "supplement_MODIS_yearly.pdf"))
        delete(fullfile(imoutputfolder, "supplement_MODIS_yearly.pdf"));
    end
    % overwrite excel sheet
    df = array2table(zeros(0, 13), 'VariableNames', [
        "imyear", "area451", "area431", "meanalbedo451", "meanalbedo431", ...
        "meanDuration451", "meanDuration431", "stdDuration451", "stdDuration431", ...
        "meanTranstion451", "meanTranstion431", "stdTranstion451", "stdTranstion431"]);
    writetable(df, statisticsfile, ...
        "Sheet", "MODIS", "WriteMode", "overwritesheet", "WriteVariableNames", true);

    for i = 1:length(imdate)
        fprintf("Processing %s\n", imdate(i));
        load(fullfile(imfolder, imfiles(i).name));

        % mask images
        days451(days451 == 0) = NaN;
        minA(minA >= 0.451) = NaN;
        minA(isnan(days451)) = NaN;
        days451(isnan(minA)) = NaN;
        darkduration451(isnan(minA)) = NaN;
        meanalbedo451 = mean(minA, "all", "omitmissing");

        figfile = figure;
        figfile.Position = [165 44 1135 730];

        t = tiledlayout(2, 3, 'TileSpacing','compact','Padding','compact');

        % plot the minimum albedo (albedo < 0.451)
        ax1 = nexttile;
        greenland('k');
        hold on
        mapshow(ax1, minA, R, "DisplayType", "surface");
        clim(ax1, [0 0.451]);
        colormap(ax1, cmocean('ice'));
        axis off
        scalebarpsn('location', 'se');
        ylabel(ax1, "\alpha < 0.451");
        ax1.YAxis.Label.Visible='on';

        % plot the duration of dark ice (albedo < 0.451)
        ax2 = nexttile;
        greenland('k');
        hold on
        mapshow(ax2, darkduration451, R, "DisplayType", "surface");
        clim(ax2, [1 70]);
        colormap(ax2, cmocean('thermal'))
        axis off

        % plot the days for albedo < 0.451
        ax3 = nexttile;
        greenland('k');
        hold on
        mapshow(ax3, days451, R, "DisplayType", "surface");
        clim(ax3, [1 40]);
        colormap(ax3, cmocean('speed'));
        axis off
        % scalebarpsn('location', 'se');

        % mask images
        days431(days431 == 0) = NaN;
        minA(minA >= 0.431) = NaN;
        minA(isnan(days431)) = NaN;
        days431(isnan(minA)) = NaN;
        darkduration431(isnan(minA)) = NaN;
        meanalbedo431 = mean(minA, "all", "omitmissing");

        % plot the minimum albedo (albedo < 0.431)
        ax4 = nexttile;
        greenland('k');
        hold on
        mapshow(ax4, minA, R, "DisplayType", "surface");
        clim(ax4, [0 0.451]);
        colormap(ax4, cmocean('ice'));
        axis off
        ylabel(ax4, "\alpha < 0.431");
        ax4.YAxis.Label.Visible='on';

        % scalebarpsn('location', 'se');

        % plot the duration of dark ice (albedo < 0.431)
        ax5 = nexttile;
        greenland('k');
        hold on
        mapshow(ax5, darkduration431, R, "DisplayType", "surface");
        clim(ax5, [1 70]);
        colormap(ax5, cmocean('thermal'));
        axis off

        % plot the days for albedo < 0.431
        ax6 = nexttile;
        greenland('k');
        hold on
        mapshow(ax6, days431, R, "DisplayType", "surface");
        clim(ax6, [1 40]);
        colormap(ax6, cmocean('speed'));
        axis off
        % scalebarpsn('location', 'se');

        % add colorbars
        c1 = colorbar(ax1, 'Location', 'eastoutside');
        c1.Label.String = "minimum \alpha";
        c2 = colorbar(ax2, 'Location', 'eastoutside');
        c2.Label.String = "dark ice duration (days)";
        c3 = colorbar(ax3, 'Location', 'eastoutside');
        c3.Label.String = "bare-dark ice duration (days)";
        c4 = colorbar(ax4, 'Location', 'eastoutside');
        c4.Label.String = "minimum \alpha";
        c5 = colorbar(ax5, 'Location', 'eastoutside');
        c5.Label.String = "dark ice duration (days)";
        c6 = colorbar(ax6, 'Location', 'eastoutside');
        c6.Label.String = "bare-dark ice duration (days)";
        title(t, imdate(i), 'FontWeight', 'normal');

        % add subfigure labels
        text(ax1, 0.15, 0.1, 'a)', 'Units', 'normalized');
        text(ax2, 0.15, 0.1, 'b)', 'Units', 'normalized');
        text(ax3, 0.15, 0.1, 'c)', 'Units', 'normalized');
        text(ax4, 0.15, 0.1, 'd)', 'Units', 'normalized');
        text(ax5, 0.15, 0.1, 'e)', 'Units', 'normalized');
        text(ax6, 0.15, 0.1, 'f)', 'Units', 'normalized');

        fontsize(t, 16, "points");

        % save the figure
        outputFigurePath = fullfile(imoutputfolder, "supplement_MODIS_yearly.pdf");
        exportgraphics(t, outputFigurePath, 'Resolution', 300, 'Append', true);

        % statistics
        area451 = 500 * 500 * sum(~isnan(days451), "all"); % area of dark ice (albedo < 0.451) in m^2
        area431 = 500 * 500 * sum(~isnan(days431), "all"); % area of dark ice (albedo < 0.431) in m^2
        meanDuration451 = mean(darkduration451, "all", "omitmissing"); % mean days for bare ice to become dark (albedo < 0.451)
        meanDuration431 = mean(darkduration431, "all", "omitmissing"); % mean days for bare ice to become dark (albedo < 0.431)
        stdDuration451 = std(darkduration451(:),  "omitmissing"); % standard deviation of days for bare ice to become dark (albedo < 0.451)
        stdDuration431 = std(darkduration431(:), "omitmissing"); % standard deviation of days for bare ice to become dark (albedo < 0.431)
        meanTranstion451 = mean(days451, "all", "omitmissing"); % mean duration of dark ice (albedo < 0.451)
        meanTranstion431 = mean(days431, "all", "omitmissing"); % mean duration of dark ice (albedo < 0.431)
        stdTranstion451 = std(days451(:), "omitmissing"); % standard deviation of duration of dark ice (albedo < 0.451)
        stdTranstion431 = std(days431(:), "omitmissing"); % standard deviation of duration of dark ice (albedo < 0.431)"
        % create a table for statistics
        imyear = double(string(imdate(i)));
        df = table(imyear, area451, area431, meanalbedo451, meanalbedo431, ...
            meanDuration451, meanDuration431, stdDuration451, stdDuration431, ...
            meanTranstion451, meanTranstion431, stdTranstion451, stdTranstion431);
        % save the table
        writetable(df, statisticsfile, ...
            "Sheet", "MODIS", "WriteMode", "append", "WriteVariableNames", false);

        close(figfile);
    end
end