function figPath = func_bareVSdark(dffile)
%% func_bareVSdark - Function to plot the relationship between maximum bare ice area and maximum dark ice area.
%
% Syntax:
%   figPath = func_bareVSdark(dffile)
%
% Input Arguments:
%   - dffile: A string specifying the file path of the input data file.
%
% Output Argument:
%   - figPath: A string specifying the file path of the saved figure.
%
% Description:
%   This function reads data from the specified file and performs linear regression analysis to determine the relationship between maximum bare ice area and maximum dark ice area. 
%   It then plots the regression lines, scatter plots, and adds relevant statistical information to the figure. The resulting figure is saved as a PDF file.
%
% Shunan Feng (shunan.feng@envs.au.dk)
    
df = readtable(dffile, "Sheet", "MODIS");
% convert area from m2 to km2
df.bareicearea = df.bareicearea/1e6;
df.area451 = df.area451/1e6;
df.area431 = df.area431/1e6;

mdl451 = fitlm(df.bareicearea, df.area451, "linear");
mdl431 = fitlm(df.bareicearea, df.area431, "linear");

f1 = figure;
f1.Position = [1000 729 747 509];

h1 = plot(mdl451);
hold on
h2 = plot(mdl431);

set(h1(2), "Color", "#395a62", "LineStyle","-", "LineWidth",1.5);
set(h1(3), "Color", "#395a62");
delete(h1(1));
set(h2(2), "Color", "#1062b4", "LineStyle","-", "LineWidth",1.5);
set(h2(3), "Color", "#395a62");
delete(h2(1));

s1 = scatter(df.bareicearea, df.area451, 'filled', 'MarkerFaceColor', '#395a62');
s2 = scatter(df.bareicearea, df.area431, 'filled', 'MarkerFaceColor', '#1062b4');

grid on
xlabel("maximum bare ice area (km^2)", "Interpreter", "tex");
ylabel("maximum dark ice area (km^2)", "Interpreter", "tex");
title("");
pbaspect([1 1 1]);
legend([s1 s2], "\alpha < 0.451", "\alpha < 0.431", "Location", "northwest");

text(0.1, 0.15,sprintf("\\alpha<0.451: r^2:%.2f, p-value<%.2f, n:%.0f", mdl451.Rsquared.Ordinary, mdl451.ModelFitVsNullModel.Pvalue, mdl451.NumObservations), "Units", "normalized");
text(0.1, 0.10,sprintf("\\alpha<0.431: r^2:%.2f, p-value<%.2f, n:%.0f", mdl431.Rsquared.Ordinary, mdl431.ModelFitVsNullModel.Pvalue, mdl431.NumObservations), "Units", "normalized");

fontsize(f1, 14, "points");

% Save the figure
figPath = fullfile("..\print", 'bareVSdark.pdf');
exportgraphics(f1, figPath, 'Resolution', 300);

end