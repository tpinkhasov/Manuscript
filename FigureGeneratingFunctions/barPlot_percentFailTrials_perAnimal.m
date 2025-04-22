
function allPercentFails = barPlot_percentFailTrials_perAnimal(TE, selectTrials, varargin)

defaults = {...
    'linePer', 'animalID';...%do you want to plot the line for each animal vs trial type, etc.
    'splitBy', 'TrialTypes';...
    'openFigure','on';...
    };
[s, ~] = parse_args(defaults, varargin{:});

linePer = unique(TE.(s.linePer));
nLines = length(linePer);
groups = unique(TE.(s.splitBy));
nGroups = length(groups);

allPercentFails = NaN(nLines, nGroups);

for n = 1:nLines
    trials = selectTrials & contains(TE.(s.linePer),linePer{n});
    allPercentFails(n,:) = get_percentFailTrials(TE, trials, 'splitBy', s.splitBy);
end

if contains(s.splitBy, 'TrialTypes')
    bigs = allPercentFails(:,2);
    smalls = allPercentFails(:,1);

    allPercentFails(:,1) = bigs;
    allPercentFails(:,2) = smalls;

    groupNames = [{'Big'}, {'Small'}, {'None'}];

else
    groupNames = num2cell(num2str(groups));
end

% load colors
load("C:\Users\Kepecs\MATLAB\Projects\DAManuscript\FigureGeneratingFunctions\BarPlotColors.mat")

fig = figure();
barFigData = bar(nanmean(allPercentFails), 'FaceColor', 'flat', 'FaceAlpha', 0.8, 'BarWidth', 1);
hold on
lineFigData = plot(allPercentFails', 'k', 'LineWidth', 0.8, 'Color', [0 0 0 0.45]);

% use colors depending on task type
if contains(TE.filename{1}, 'LW')
    barFigData.CData(1,:) = BarPlotColors.LWTask.Big;
    barFigData.CData(2,:) = BarPlotColors.LWTask.Small;
    barFigData.CData(3,:) = BarPlotColors.LWTask.None;
else
    barFigData.CData(1,:) = BarPlotColors.ControlTask.Big;
    barFigData.CData(2,:) = BarPlotColors.ControlTask.Small;
    barFigData.CData(3,:) = BarPlotColors.ControlTask.None;
end

xlim([0.35 3.65])

xlabel(s.splitBy)
xticklabels(groupNames)
ylabel('% fail trials')
set(gca, 'FontName', 'Arial', 'TickLength', [0.04 0.04], 'LineWidth', 0.4, 'TickDir','out', 'box', 'off', 'FontSize', 20);
%daspect([1 3 1]);

%Statistics
dataTable = table(linePer,allPercentFails(:,1), allPercentFails(:,2), allPercentFails(:,3));
dataTable.Properties.VariableNames = ["animal", "big", "small", "none"];
rm = fitrm(dataTable, 'big-none ~1', WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [1 0 -1]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
text(3, 15, fVal); hold on
text(3, 14, pVal)

end