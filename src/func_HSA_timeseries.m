function figfile = func_HSA_timeseries(tifFolder)
    tiffiles = dir(fullfile(tifFolder, "\**\*.tif"));
    tiffiles = tiffiles(22:83); % 2019-06-01 to 2019-08-31

    imoutputfolder = "..\print\";

    % if figfile exist, delete it
    if isfile(fullfile(imoutputfolder, "supplement_HSA_KAN_M.pdf"))
        delete(fullfile(imoutputfolder, "supplement_HSA_KAN_M.pdf"));
    end

    df = array2table(zeros(0, 5), 'VariableNames', ...
        ["imdate", "imcount431", "imcount451", "imcounttotal", "imcountmasked"]);
    writetable(df, fullfile(dfFolder, "areacount.xlsx"), ...
        "WriteVariableNames", true, "WriteMode", "overwrite", "Sheet", "KANM");

    for i = 1:height(tiffiles)

        imdate = datetime(extractBefore(tiffiles(i).name, ".tif"),...
            "InputFormat", "uuuu-MM-dd");
        [A, R] = readgeoraster(fullfile(tiffiles(i).folder, tiffiles(i).name));
        imalbedo = A(:,:,end);

        immask = ones(size(imalbedo));
        immask(A(:,:,end) == 0) = nan;
        A = A.*immask;
        imrgb = A(:,:,3:-1:1);
        imrgb(isnan(imrgb)) = 255;
        imalbedo = A(:,:,end);

        % count areas with albedo < 0.431 and < 0.451, respectively
        imcount431 = sum(imalbedo < 0.431, "all", "omitmissing");
        imcount451 = sum(imalbedo < 0.451, "all", "omitmissing");
        % count total area and ares masked out
        imcounttotal = numel(imalbedo);
        imcountmasked = sum(isnan(imalbedo), "all");

        % save the daily dark ice area to excel
        df = table(imdate, imcount431, imcount451, imcounttotal, imcountmasked);
        writetable(df, fullfile(dfFolder, "areacount.xlsx"), ...
            "WriteMode", "append", "WriteVariableNames", false, "Sheet", "KANM");


        figfile = figure;

        t = tiledlayout(1, 2, 'TileSpacing','compact','Padding','compact');

        ax1 = nexttile;
        mapshow(ax1, imrgb, R, "DisplayType", "image");
        scalebarpsn('location', 'se');

        ax2 = nexttile;
        mapshow(imalbedo, R, "DisplayType", "surface");
        colormap(ax2, func_dpcolor());
        c = colorbar(ax2);
        c.Label.String = "\alpha";
        clim(ax2, [0 1]);

        hold on

        contmap = mapshow(imalbedo, R, "DisplayType", "contour", "LineColor", "#1062b4", "LineWidth", 1);
        contmap.LevelList = [0.431 0.431];
        contmap = mapshow(imalbedo, R, "DisplayType", "contour", "LineColor", "#395a62", "LineWidth", 1);
        contmap.LevelList = [0.451 0.451];

        title(t, "KAN\_M " + string(imdate), "FontWeight", "normal");

        exportgraphics(figfile, fullfile(imoutputfolder, "supplement_HSA_KAN_M.pdf"), ...
            "Resolution", 300, "Append", true);

        close(figfile);
    end
end
