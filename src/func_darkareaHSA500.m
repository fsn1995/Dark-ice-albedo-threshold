imfolder = "H:\AU\darkice\HSA500";
imfiles = dir(fullfile(imfolder, "HSA_minAlbedo_*.tif"));
imdate = string({imfiles.name}.');
imdate = extractBetween(imdate, "HSA_minAlbedo_", ".tif");

% if figfile exist, delete it
if isfile(fullfile(imfolder, "supplement_HSA500_yearly.pdf"))
    delete(fullfile(imfolder, "supplement_HSA500_yearly.pdf"));
end


for i = 1:length(imdate)
    fprintf("Processing %s\n", imdate(i));
    
    [A, R] = readgeoraster(fullfile(imfolder, imfiles(i).name));
    A(A >= 0.451) = NaN;

    figfile = figure;
    ax = gca;

    greenland('k');
    hold on
    mapshow(ax, A, R, "DisplayType", "surface");
    clim(ax, [0 0.451]);
    colormap(ax, cmocean('ice'));
    axis off
    scalebarpsn('location', 'se');
    ylabel(ax, "minimum \alpha < 0.451");
    ax.YAxis.Label.Visible='on';
    title(ax, imdate(i), 'FontWeight', 'normal');
    c1 = colorbar(ax, 'location', 'eastoutside');
    c1.Label.String = '\alpha';

    % save the figure
    outputFigurePath = fullfile(imfolder, "supplement_HSA500_yearly.pdf");
    exportgraphics(figfile, outputFigurePath, 'Resolution', 300, 'Append', true);

    close(figfile);

end