%%
dfaws = readtable("..\data\AWS_reprocessed.csv");
dfaws = dfaws(dfaws.awsgroup == "M", :);
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :); % limit to JJA
awsgroupColor = ["#41b4ee", "#cdb47b", "#395a62", "#186294", "#737b7b", "#1062b4"]; % gyarados

% Initialize table to store results
results = table('Size', [0 4], 'VariableTypes', {'string', 'int32', 'double', 'double'}, ...
    'VariableNames', {'AWS', 'Year', 'MeanThreshold', 'LinearThreshold'});

writetable(results, '..\data\albedo_thresholds_revision.csv', 'WriteRowNames', true, 'WriteMode', 'overwrite');
%% loop through each station and years to find abrupt change in mean and linear trend

G = findgroups(dfaws.aws, dfaws.y);
numaws = max(G);

for i = 1:numaws
    index = find(G == i);
    df = dfaws(index, :);
    
    % remove incomplete time series
    if height(df) < 92
        continue
    end
    f1 = figure;
    % f1.Position = [969 247 1123 795];

    % find abrupt change in mean
    [TF,~,~] = ischange(df.albedo, "mean", "MaxNumChanges", 3);
    if sum(TF) < 3
        continue
    end
    time_change = df.time(TF);
    albedo_change = df.albedo(TF);
    albedo_threshold_mean = mean(albedo_change(2:3));
    plot([time_change(1) time_change(1)], [0 albedo_change(1)], ...
        [df.time(1) time_change(1)], [albedo_change(1) albedo_change(1)], ...
        [time_change(2) time_change(2)], [0 albedo_change(2)], ...
        [df.time(1) time_change(2)], [albedo_change(2) albedo_change(2)], ...
        [time_change(3) time_change(3)], [0 albedo_change(3)], ...
        [df.time(1) time_change(3)], [albedo_change(3) albedo_change(3)], ...
        "LineStyle", "-.", "LineWidth", 1.5, "Color", awsgroupColor(3));
    hold on
    scatter(time_change, albedo_change, ...
        "filled", "MarkerFaceColor", awsgroupColor(3));
    line1 = yline(albedo_threshold_mean, '-.', sprintf('\\alpha (mean) = %.3f            ', albedo_threshold_mean),...
            'Color', awsgroupColor(3), 'LineWidth', 1.5, 'LabelHorizontalAlignment','right', ...
            "DisplayName", "abrupt change in mean");

    % find abrupt change in linear
    [TF,~,~] = ischange(df.albedo, "linear", "MaxNumChanges", 3);
    if sum(TF) < 3
        continue
    end
    time_change = df.time(TF);
    albedo_change = df.albedo(TF);
    albedo_threshold_linear = mean(albedo_change(2:3));
    plot([time_change(1) time_change(1)], [0 albedo_change(1)], ...
        [df.time(1) time_change(1)], [albedo_change(1) albedo_change(1)], ...
        [time_change(2) time_change(2)], [0 albedo_change(2)], ...
        [df.time(1) time_change(2)], [albedo_change(2) albedo_change(2)], ...
        [time_change(3) time_change(3)], [0 albedo_change(3)], ...
        [df.time(1) time_change(3)], [albedo_change(3) albedo_change(3)], ...
        "LineStyle", "-.", "LineWidth", 1.5, "Color", awsgroupColor(3));
    % hold on
    scatter(time_change, albedo_change, ...
        "filled", "MarkerFaceColor", awsgroupColor(3));
    line2 = yline(albedo_threshold_linear, '--', ...
        'Color', awsgroupColor(6), 'LineWidth', 1.5, ...
        "DisplayName", "abrupt change in linear regime");
    text(datetime(df.time(3)), 0.48, sprintf('\\alpha (linear) = %.3f', albedo_threshold_linear), "Color", awsgroupColor(5));
    
    line3 = plot(df.time, df.albedo, "Color", awsgroupColor(3), "LineWidth", 1.5);
    title(sprintf("AWS %s", string(df.awsgroup(1))));

    xlim([datetime(df.time(1)), datetime(df.time(end))]);
    fontsize(f1, 16, "points");
    grid on 

    % save figure
    exportgraphics(f1, "..\print\revision\individualAWS_" + string(df.aws(1)) + string(df.y(1)) + ".png",...
        "Resolution", 300);
    close(f1);
    

    % add results to table and save to csv without row names
    results = table(df.aws(1), df.y(1), albedo_threshold_mean, albedo_threshold_linear);
    writetable(results, '..\data\albedo_thresholds_revision.csv', 'WriteMode', 'append');
end

