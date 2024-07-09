function [f1] = func_threshold_analysis(dfaws)
% func_threshold_analysis plot mean albedo +- 1 std over different AWS groups
% It also detects abrupt change in mean albedo and plot the change points
%   Input:
%       dfaws: table, output from data preprocessing
%   Output:
%       f1: figure handle
%   
% Shunan Feng (shunan.feng@envs.au.dk)

if isstring(dfaws)
    dfaws = readtable(dfaws);
end
dfaws = dfaws(dfaws.awsgroup == "M", :);
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :); % limit to JJA
% awsgroup = ["U", "M", "L", "G"];
% awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados
% awsgroup = ["G", "L", "M", "U"];
awsgroupColor = ["#41b4ee", "#cdb47b", "#395a62", "#186294", "#737b7b", "#1062b4"]; % gyarados

%% plot mean albedo over different AWS groups

% average over all years
df = groupsummary(dfaws, {'m', 'd', 'awsgroup'}, "all", "albedo");
df.y = repmat(2023, height(df), 1);
df.mean_albedoH = df.mean_albedo + df.std_albedo;
df.mean_albedoL = df.mean_albedo - df.std_albedo;
df.time = datetime(2023, df.m, df.d); % assign a random y for plotting

% assign day of year to data
dfaws.doy = day(dfaws.time, "dayofyear");
df.doy = day(df.time, "dayofyear");
dfstat = df(df.awsgroup == "M", :);


f1 = figure;
f1.Position = [488   245   917   376];
t = tiledlayout(1, 3, "TileSpacing","compact", "Padding","compact");
ax1 = nexttile(t);
A = imread("..\print\aoi.png");
imshow(A);
text(ax1, 80, 1600, "a)", "FontSize", 12, "Color", "w");
ax2 = nexttile([1 2]); %ax2 = nexttile([1 2]);

% find abrupt change in mean
[TF,~,~] = ischange(dfstat.mean_albedo, "mean", "MaxNumChanges", 3);
% [TF,S1,S2] = ischange(dfstat.mean_albedo, "linear", "MaxNumChanges", 3);
time_change = dfstat.time(TF);
albedo_change = dfstat.mean_albedo(TF);
albedo_threshold = mean(albedo_change(2:3));
plot(ax2, [time_change(1) time_change(1)], [0 albedo_change(1)], ...
    [dfstat.time(1) time_change(1)], [albedo_change(1) albedo_change(1)], ...
    [time_change(2) time_change(2)], [0 albedo_change(2)], ...
    [dfstat.time(1) time_change(2)], [albedo_change(2) albedo_change(2)], ...
    [time_change(3) time_change(3)], [0 albedo_change(3)], ...
    [dfstat.time(1) time_change(3)], [albedo_change(3) albedo_change(3)], ...
    "LineStyle", "-.", "LineWidth", 1.5, "Color", awsgroupColor(3));
hold on
scatter(ax2, time_change, albedo_change, ...
    "filled", "MarkerFaceColor", awsgroupColor(3));
line1 = yline(ax2, albedo_threshold, '-.', sprintf('\\alpha (mean) = %.3f', albedo_threshold),...
        'Color', awsgroupColor(3), 'LineWidth', 1.5, 'LabelHorizontalAlignment','right', ...
        "DisplayName", "abrupt change in mean");

% find abrupt change in linear
[TF,~,~] = ischange(dfstat.mean_albedo, "linear", "MaxNumChanges", 3);
time_change = dfstat.time(TF);
albedo_change = dfstat.mean_albedo(TF);
albedo_threshold = mean(albedo_change(2:3));
plot(ax2, [time_change(1) time_change(1)], [0 albedo_change(1)], ...
    [dfstat.time(1) time_change(1)], [albedo_change(1) albedo_change(1)], ...
    [time_change(2) time_change(2)], [0 albedo_change(2)], ...
    [dfstat.time(1) time_change(2)], [albedo_change(2) albedo_change(2)], ...
    [time_change(3) time_change(3)], [0 albedo_change(3)], ...
    [dfstat.time(1) time_change(3)], [albedo_change(3) albedo_change(3)], ...
    "LineStyle", "--", "LineWidth", 1.5, "Color", awsgroupColor(6));
scatter(ax2, time_change, albedo_change, ...
    "filled", "MarkerFaceColor", awsgroupColor(6));
line2 = yline(ax2, albedo_threshold, '--', sprintf('\\alpha (linear) = %.3f', albedo_threshold),...
        'Color', awsgroupColor(6), 'LineWidth', 1.5, 'LabelHorizontalAlignment','left', ...
        "DisplayName", "abrupt change in linear regime");

line3 = plot(dfstat.time, dfstat.mean_albedo, "LineWidth", 2, ...
    "DisplayName", "\alpha \pm 1\sigma", "Color", awsgroupColor(5));
plotci(ax2, dfstat.time, dfstat.mean_albedoH, dfstat.mean_albedoL, ...
            awsgroupColor(5));
text(ax2, datetime(2023, 6, 3), 0.2, "b)", "FontSize", 12);
ylim(ax2, [0.15 0.9]);
xlim(ax2, [datetime(2023,6,1) datetime(2023,8,31)]);
ylabel(ax2, "albedo (\alpha)");
ax2.XTickLabel = ax2.XTickLabel;
grid on
legend([line3 line1 line2], "Location", "northeast");
fontsize(f1, 12, "points");
exportgraphics(f1, "..\print\fig1_aoi.pdf", "Resolution", 300);


%% functions

function plotci(ax, x, meanH, meanL, colorcode)
% plot confidence interval
index = isnan(meanH);
p = fill(ax, [x(~index); flipud(x(~index))], [meanH(~index); flipud(meanL(~index))], 'k');
p.FaceColor = colorcode;
p.EdgeColor = "none";
p.FaceAlpha = 0.2;

end
end

