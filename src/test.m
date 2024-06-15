% close all

load("..\data\MODIS\MODIS_2002.mat");
days
minA(minA>=0.451) = nan;
figure
mapshow(days431, R, "DisplayType", "surface");
















% df = readtable("..\data\AWS_reprocessed.csv");
% fid = fopen("..\data\changepoint.csv", "w");
% fprintf(fid, "awsid,year,albedo_change_mean,albedo_change_linear\n");
% awslist = unique(df.aws);
% 
% for i = 1:numel(awslist)
%     awsid = string(awslist(i));
%     disp(awsid);
% 
%     dfaws = df(df.aws == awsid, :);
%     [dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
%     dfaws = dfaws(dfaws.m > 5 & dfaws.m < 9, :);
% 
%     % iterate over years
%     years = unique(dfaws.y);
%     for y = min(years):max(years)
% 
%         index = dfaws.y == y;
%         dfawsplot = dfaws(index, :);
% 
%         % remove incomplete observations in JJA
%         if height(dfawsplot) < 92
%             fprintf("incomplete observations \n");
%             continue
%         elseif min(dfawsplot.albedo) >=0.565
%             fprintf("no bare ice \n");
%             continue
%         end
% 
%         f1 = figure;
%         plot(dfawsplot.time, dfawsplot.albedo, 'LineWidth',2);
%         hold on
%         grid on
%         ylim([0 1]);
%         legend("Location", "southoutside");
%         xlim([datetime(y, 6, 1) datetime(y, 8, 31)]);
%         xlabel("");
%         ylabel("albedo");
%         text(datetime(y, 6, 1), 0.9, sprintf("AWS: %s %d", insertBefore(awsid, '_', '\'), y));
% 
%         % find change point in mean albedo
%         [TF,S1,S2] = ischange(dfawsplot.albedo, "mean", "MaxNumChanges", 3);
%         time_change = dfawsplot.time(TF);
%         albedo_change = dfawsplot.albedo(TF);
%         if numel(albedo_change) < 3
%             fprintf("no or not enoughchange point \n");
%             close all
%             continue
%         end
%         albedo_threshold = mean(albedo_change(2:3));
% 
%         plot([time_change(1) time_change(1)], [0 albedo_change(1)], ...
%         [dfawsplot.time(1) time_change(1)], [albedo_change(1) albedo_change(1)], ...
%         [time_change(2) time_change(2)], [0 albedo_change(2)], ...
%         [dfawsplot.time(1) time_change(2)], [albedo_change(2) albedo_change(2)], ...
%         [time_change(3) time_change(3)], [0 albedo_change(3)], ...
%         [dfawsplot.time(1) time_change(3)], [albedo_change(3) albedo_change(3)], ...
%         "LineStyle", "-.", "LineWidth", 1, "Color", "#399ccd"); % omanyte
%         y1 = yline(albedo_threshold, '-.', sprintf('\\alpha = %.3f', albedo_threshold),...
%             'Color', '#399ccd', 'LineWidth', 1.5, 'LabelHorizontalAlignment','right',...
%             'DisplayName', 'change point (mean)');
%         fprintf(fid, "%s,%d,%.3f,", awsid, y, albedo_threshold);
% 
%         % find change in slope and intercept
%         [TF,S1,S2] = ischange(dfawsplot.albedo, "linear", "MaxNumChanges", 3);
%         time_change = dfawsplot.time(TF);
%         albedo_change = dfawsplot.albedo(TF);
%         if numel(albedo_change) < 3
%             fprintf("no or not enoughchange point \n");
%             fprintf(fid, "\n");
%             close all
%             continue
%         end
%         albedo_threshold = mean(albedo_change(2:3));
% 
%         plot([time_change(1) time_change(1)], [0 albedo_change(1)], ...
%         [dfawsplot.time(1) time_change(1)], [albedo_change(1) albedo_change(1)], ...
%         [time_change(2) time_change(2)], [0 albedo_change(2)], ...
%         [dfawsplot.time(1) time_change(2)], [albedo_change(2) albedo_change(2)], ...
%         [time_change(3) time_change(3)], [0 albedo_change(3)], ...
%         [dfawsplot.time(1) time_change(3)], [albedo_change(3) albedo_change(3)], ...
%         "LineStyle", "--", "LineWidth", 1, "Color", "#9c6a6a"); % primeape
%         y2= yline(albedo_threshold, '--', sprintf('\\alpha = %.3f', albedo_threshold),...
%             'Color', '#9c6a6a', 'LineWidth', 1.5, 'LabelHorizontalAlignment','left',...
%             'DisplayName', 'change point (linear)');
%         fprintf(fid, "%.3f\n", albedo_threshold);
% 
%         legend([y1 y2], 'Location', 'best');
%         fontsize(f1, 12, "points");
% 
%         exportgraphics(f1, "print\" + awsid + string(y) + ".png", 'Resolution', 300);
%         close(f1)
% 
%     end
% end
% fclose(fid);