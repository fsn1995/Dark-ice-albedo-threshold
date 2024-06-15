function outputFigurePath = func_darkareaMODIS(imfolder, outputfolder)
    imfiles = dir(fullfile(imfolder, "MODIS_*.mat"));
    imdate = string({imfiles.name}.');
    imdate = extractBetween(imdate, "MODIS_", ".mat");

    % if figfile exist, delete it
    if isfile(fullfile(outputfolder, "supplement_MODIS_yearly.pdf"))
        delete(fullfile(outputfolder, "supplement_MODIS_yearly.pdf"));
    end

    for i = 1:length(imdate)
        fprintf("Processing %s\n", imdate(i));
        load(fullfile(imfolder, imfiles(i).name), "minA", "R", "days431", "days451");

        % mask images
        days431(days431 == 0) = NaN;
        days451(days451 == 0) = NaN;

        figfile = figure;
        figfile.Position = [1265 204 854 814];

        t = tiledlayout(2, 2, 'TileSpacing','compact','Padding','compact');

        % plot the minimum albedo (albedo < 0.451)
        minA(minA >= 0.451) = NaN;
        minA(isnan(days451)) = NaN;
        days451(isnan(minA)) = NaN;
        ax1 = nexttile;
        greenland('k');
        hold on
        mapshow(ax1, minA, R, "DisplayType", "surface");
        colormap(ax1, func_dpcolor)
        clim(ax1, [0 1]);
        axis off
        scalebarpsn('location', 'se');
        title(ax1, "\alpha < 0.451", "FontWeight", "normal");

        % plot the minimum albedo (albedo < 0.431)
        minA(minA >= 0.431) = NaN;
        minA(isnan(days431)) = NaN;
        days431(isnan(minA)) = NaN;
        ax2 = nexttile;
        greenland('k');
        hold on
        mapshow(ax2, minA, R, "DisplayType", "surface");
        colormap(ax2, cmocean("ice"));
        clim(ax2, [0 1]);
        axis off
        % scalebarpsn('location', 'se');
        title(ax2, "\alpha < 0.431", "FontWeight", "normal");

        % plot the days for albedo < 0.451
        ax3 = nexttile;
        greenland('k');
        hold on
        mapshow(ax3, days451, R, "DisplayType", "surface");
        % colormap(ax3, func_dpcolor)
        % clim(ax3, [0 100]);
        axis off
        % scalebarpsn('location', 'se');

        % plot the days for albedo < 0.431
        ax4 = nexttile;
        greenland('k');
        hold on
        mapshow(ax4, days431, R, "DisplayType", "surface");
        % colormap(ax4, func_dpcolor)
        % clim(ax4, [0 100]);
        axis off
        % scalebarpsn('location', 'se');

        % add colorbars
        c1 = colorbar(ax1, 'Location', 'westoutside');
        c1.Label.String = "\alpha";
        c3 = colorbar(ax3, 'Location', 'westoutside');
        c3.Label.String = "days for bare-dark ice transition";

        % add subfigure labels
        text(ax1, 0.15, 0.1, 'a)', 'Units', 'normalized');
        text(ax2, 0.15, 0.1, 'b)', 'Units', 'normalized');
        text(ax3, 0.15, 0.1, 'c)', 'Units', 'normalized');
        text(ax4, 0.15, 0.1, 'd)', 'Units', 'normalized');

        fontsize(t, 16, "points");

        % calculate the area of dark ice
        areaK = 500*500; % 500m x 500m resolution
        fprintf("%d, %d\n", sum(~isnan(days431), "all") * areaK, ...
            sum(~isnan(days451), "all") * areaK);

        % save the figure
        outputFigurePath = fullfile(outputfolder, "supplement_MODIS_yearly.pdf");
        exportgraphics(t, outputFigurePath, 'Resolution', 300, 'Append', true);
    end
end