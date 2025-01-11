%%
dfaws = readtable("..\data\AWS_reprocessed.csv");
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :); % limit to JJA
awsgroup = ["G", "L", "M", "U"];
awsgroupColor = ["#41b4ee", "#cdb47b", "#395a62", "#186294", "#737b7b", "#1062b4"]; % gyarados

df = groupsummary(dfaws, {'m', 'd', 'awsgroup'}, "all", "albedo");
df.y = repmat(2023, height(df), 1);
df.mean_albedoH = df.mean_albedo + df.std_albedo;
df.mean_albedoL = df.mean_albedo - df.std_albedo;
df.time = datetime(2023, df.m, df.d); % assign a random y for plotting
% Initialize table to store results
% results = table('Size', [0 4], 'VariableTypes', {'string', 'int32', 'double', 'double'}, ...
%     'VariableNames', {'AWS', 'Year', 'MeanThreshold', 'LinearThreshold'});

% writetable(results, '..\data\albedo_thresholds_revision.csv', 'WriteRowNames', true, 'WriteMode', 'overwrite');
%% Plot mean albedo over different AWS groups
f1 = figure;
f1.Position = [488   245   917   376];
t = tiledlayout(1, 3, "TileSpacing","compact", "Padding","compact");
ax1 = nexttile(t);
A = imread("..\print\aoi_allAWS.png");
imshow(A);
text(ax1, 80, 1600, "a)", "FontSize", 12, "Color", "w");
ax2 = nexttile([1 2]); %ax2 = nexttile([1 2]);

hold on

plotAWSGroup(ax2, df, awsgroup, awsgroupColor);
ax2.XTickLabel = ax2.XTickLabel;
text(ax2, datetime(2023, 6, 3), 0.2, "b)", "FontSize", 12);
ylim(ax2, [0.15 0.9]);
ylabel(ax2, "albedo (\alpha)");
fontsize(f1, 12, "points");
exportgraphics(f1, "..\print\allAWS.pdf", "Resolution", 300);

%% Analysis of abrupt change in mean and linear trend for each AWS group

for i = 1:numel(awsgroup)
    G = awsgroup(i);
    index = df.awsgroup == G;
    dfawsstat = df(index, :);

    % find abrupt change in mean
    [TF,~,~] = ischange(dfawsstat.mean_albedo, "mean", "MaxNumChanges", 3);
    % time_change = dfawsstat.time(TF);
    albedo_change = dfawsstat.mean_albedo(TF);
    albedo_threshold_mean = mean(albedo_change(2:3));

    fprintf("AWS group %s: mean threshold = %.3f\n", G, albedo_threshold_mean);

    % find abrupt change in linear
    [TF,~,~] = ischange(dfawsstat.mean_albedo, "linear", "MaxNumChanges", 3);
    time_change = dfawsstat.time(TF);
    albedo_change = dfawsstat.mean_albedo(TF);
    albedo_threshold_linear = mean(albedo_change(2:3));

    fprintf("AWS group %s: linear threshold = %.3f\n", G, albedo_threshold_linear);
end

%% functions
function plotAWSGroup(figax, df, awsgroup, awsgroupColor)
    % hold on
    ax = zeros(numel(awsgroup), 1);
    for i = 1:numel(awsgroup)
        index = df.awsgroup == awsgroup(i);
        dfawsplot = df(index, :);
        if isempty(dfawsplot)
            continue
        end
        ax(i) = plot(dfawsplot.time, dfawsplot.mean_albedo, ...
            "LineWidth", 2, "DisplayName", awsgroup(i), "Color", awsgroupColor(i));
        plotci(figax, dfawsplot.time, dfawsplot.mean_albedoH, dfawsplot.mean_albedoL, ...
            awsgroupColor(i));
    end
    yline(figax, 0.565,       '--', '\alpha = 0.565',         ...
        'Color', 'k', 'LineWidth', 1.5, 'LabelHorizontalAlignment','right'); 
    % yline(figax, 0.565+0.109, '--', '\alpha = 0.565+1\sigma', ...
    %     'Color', 'k', 'LineWidth', 1);
    % yline(figax, 0.565-0.109, '--', '\alpha = 0.565-1\sigma', ...
    %     'Color', 'k', 'LineWidth', 1);
    xlim([datetime(unique(df.y), 6, 1) datetime(unique(df.y), 8, 31)]);
    % hold off
    legend(figax, ax(ax>0), "NumColumns", numel(awsgroup));
    grid on
    % clearvars ax
end

function plotci(ax, x, meanH, meanL, colorcode)

index = isnan(meanH);
p = fill(ax, [x(~index); flipud(x(~index))], [meanH(~index); flipud(meanL(~index))], 'k');
p.FaceColor = colorcode;
p.EdgeColor = "none";
p.FaceAlpha = 0.2;

end