function outputFigurePath = func_timeseries_yearly(dfFolder, imoutputfolder)
% This function creates a timeseries plot of yearly mean and standard deviation of bare to dark ice transition days and dark ice duration days.
% The data is read from the excel file in the dfFolder and the output figure is saved in the imoutputfolder.
% The function returns the path of the output figure.
% Shunan Feng (shunan.feng@envs.au.dk)

    dfyearly = readtable(fullfile(dfFolder, "areacount.xlsx"), "Sheet", "MODIS");

    f1 = figure;
    f1.Position = [ 1023 400 855 636];
    t = tiledlayout(2,1, "TileSpacing", "compact", "Padding", "compact");

    ax1 = nexttile; % transtion days
    errorbar(ax1, dfyearly.imyear, dfyearly.meanTranstion431, dfyearly.stdTranstion431, ...
        '-o', 'Color', '#1062b4', 'DisplayName', '\alpha<0.431', 'LineWidth',2);
    hold on
    errorbar(ax1, dfyearly.imyear, dfyearly.meanTranstion451, dfyearly.stdTranstion451, ...
        '-o', 'Color', '#395a62', 'DisplayName', '\alpha<0.451','LineWidth',2);
    grid on
    xlim(ax1, [min(dfyearly.imyear)-0.5 max(dfyearly.imyear)+0.5]);
    ylim(ax1, [0 20]);
    ylabel(ax1, "bare to dark ice transition (days)");
    legend(ax1, 'Location', 'southoutside', 'numcolumns', 2);
    text(ax1, 0.02, 0.9, 'a)', 'Units', 'normalized');

    % ax3 = nexttile; % correlation between transition and duration days for alpha < 0.431
    % mdl = fitlm(dfyearly.meanTranstion431, dfyearly.meanDuration431, "linear");
    % h3 = plot(ax3, mdl);
    % hold on
    % grid on
    % set(h3(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
    % set(h3(3), "Color", "k");
    % scatter(ax3, dfyearly, "meanTranstion431", "meanDuration431", 'filled', ...
    %     'ColorVariable', "imyear");
    % crameri("nuuk", height(dfyearly));
    % title(ax3, ''); 
    % xlabel(ax3, "bare to dark ice transition (days)");
    % ylabel(ax3, "dark ice duration (days)");
    % legend off
    % pbaspect([1 1 1]);
    % text(ax3, 0.05, 0.9, sprintf("c) r^2:%.2f,\n p-value=%.2f", ...
    %     mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue), 'Units', 'normalized');

    ax2 = nexttile; % duration days
    errorbar(ax2, dfyearly.imyear, dfyearly.meanDuration431, dfyearly.stdDuration431, ...
        '-o', 'Color', '#1062b4', 'DisplayName', '\alpha<0.431', 'LineWidth',2);
    hold on
    errorbar(ax2, dfyearly.imyear, dfyearly.meanDuration451, dfyearly.stdDuration451, ...
        '-o', 'Color', '#395a62', 'DisplayName', '\alpha<0.451','LineWidth',2);
    grid on
    xlim(ax2, [min(dfyearly.imyear)-0.5 max(dfyearly.imyear)+0.5]);
    ylim(ax2, [0 40]);
    xlabel(ax2, "year");
    ylabel(ax2, "dark ice duration (days)");
    legend off
    text(ax2, 0.02, 0.9, 'b)', 'Units', 'normalized');

    linkaxes([ax1, ax2], 'x');

    % ax4 = nexttile; % correlation between transition and duration days for alpha < 0.451
    % mdl = fitlm(dfyearly.meanTranstion451, dfyearly.meanDuration451, "linear");
    % h4 = plot(ax4, mdl);
    % hold on
    % grid on
    % set(h4(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
    % set(h4(3), "Color", "k");
    % scatter(ax4, dfyearly, "meanTranstion451", "meanDuration451", 'filled', ...
    %     'ColorVariable', "imyear");
    % crameri("nuuk", height(dfyearly));
    % title(ax4, '');
    % xlabel(ax4, "bare to dark ice transition (days)");
    % ylabel(ax4, "dark ice duration (days)");
    % legend off
    % pbaspect([1 1 1]);
    % text(ax4, 0.05, 0.9, sprintf("d) r^2:%.2f,\n p-value=%.2f", ...
    %     mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue), 'Units', 'normalized');

    % c = colorbar(ax4);
    % c.Label.String = "year";
    % c.Layout.Tile = "east";

    fontsize(t, 14, "points");

    outputFigurePath = fullfile(imoutputfolder, "darkice_yearly_MODIS.pdf");
    % if figfile exist, delete it
    if isfile(outputFigurePath)
        delete(outputFigurePath);
    end
    exportgraphics(f1, outputFigurePath, 'Resolution', 300);
end
