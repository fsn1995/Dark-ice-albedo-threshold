
yearList = 2002:10:2022;
imfolder = "..\data\MODIS";
i = yearList(2);

% load .mat file for each year
imfile = fullfile(imfolder, sprintf("MODIS_%d.mat", i));
load(imfile);
imdate = string(i);

% get bare ice areas
minA(minA >= 0.565) = NaN;
bareicearea = 500 * 500 * sum(~isnan(minA), "all"); % area of bare ice in m^2

% mask images
days451(days451 == 0) = NaN;
minA(minA >= 0.451) = NaN;
minA(isnan(days451)) = NaN;
days451(isnan(minA)) = NaN;
darkduration451(isnan(minA)) = NaN;
meanalbedo451 = mean(minA, "all", "omitmissing");

figfile = figure;
greenland('k');
hold on
mapshow(minA, R, "DisplayType", "surface");
clim([0 0.451]);
colormap(cmocean('ice'));
axis off
ylabel("\alpha < 0.451");
c1 = colorbar('Location', 'eastoutside');
c1.Label.String = "minimum \alpha";
% text(0.15, 0.1, 'a)', 'Units', 'normalized');
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
exportgraphics(figfile, "..\print\revision\darkzone1.png", "Resolution", 300);
close(figfile)
% ax1.YAxis.Label.Visible='on';

figfile = figure;
greenland('k');
hold on
mapshow(darkduration451, R, "DisplayType", "surface");
clim([1 70]);
colormap(cmocean('thermal'))
axis off
c2 = colorbar('Location', 'eastoutside');
c2.Label.String = "dark ice duration (days)";
% text(0.15, 0.1, 'b)', 'Units', 'normalized');
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
exportgraphics(figfile, "..\print\revision\darkzone2.png", "Resolution", 300);
close(figfile);

figfile = figure;
greenland('k');
hold on
mapshow(days451, R, "DisplayType", "surface");
clim([1 40]);
colormap(cmocean('speed'));
axis off
c3 = colorbar('Location', 'eastoutside');
c3.Label.String = "bare-dark ice duration (days)";
% text(0.15, 0.1, 'c)', 'Units', 'normalized');
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
exportgraphics(figfile, "..\print\revision\darkzone3.png", "Resolution", 300);
close(figfile);

% mask images
days431(days431 == 0) = NaN;
minADiff = minA;
minA(minA >= 0.431) = NaN;
minADiff(~isnan(minA)) = NaN;   
minADiff(~isnan(minADiff)) = 1;
minA(isnan(days431)) = NaN;
days431(isnan(minA)) = NaN;
darkduration431(isnan(minA)) = NaN;
meanalbedo431 = mean(minA, "all", "omitmissing");

figfile = figure;
greenland('k');
hold on
mapshow(minA, R, "DisplayType", "surface");
clim([0 0.451]);
colormap(cmocean('ice'));
axis off
ylabel("\alpha < 0.431");
c4 = colorbar('Location', 'eastoutside');
c4.Label.String = "minimum \alpha";
% text(0.15, 0.1, 'd)', 'Units', 'normalized');
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
exportgraphics(figfile, "..\print\revision\darkzone4.png", "Resolution", 300);
close(figfile);

figfile = figure;
greenland('k');
hold on
mapshow(darkduration431, R, "DisplayType", "surface");
clim([1 70]);
colormap(cmocean('thermal'));
axis off
c5 = colorbar('Location', 'eastoutside');
c5.Label.String = "dark ice duration (days)";
% text(0.15, 0.1, 'e)', 'Units', 'normalized');
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
exportgraphics(figfile, "..\print\revision\darkzone5.png", "Resolution", 300);
close(figfile);

figfile = figure;
greenland('k');
hold on
mapshow(days431, R, "DisplayType", "surface");
clim([1 40]);
colormap(cmocean('speed'));
axis off
c6 = colorbar('Location', 'eastoutside');
c6.Label.String = "bare-dark ice duration (days)";
% text(0.15, 0.1, 'f)', 'Units', 'normalized');
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
exportgraphics(figfile, "..\print\revision\darkzone6.png", "Resolution", 300);
close(figfile);

clearvars