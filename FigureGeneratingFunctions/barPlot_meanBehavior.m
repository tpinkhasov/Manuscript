%% barPlot_meanBehavior
% plots the mean specified behavioral measure

function allBeh = barPlot_meanBehavior(TE, selectTrials, varargin)

defaults = {...
    'behVar', 'CS2RT';... %what behavioral variable do you want the avergae of?
    'linePer', 'animalID';...%do you want to plot the line for each animal
    'splitBy', 'TrialTypes';... %What groups do you want to compare
    };
[s, ~] = parse_args(defaults, varargin{:});

linePer = unique(TE.(s.linePer)); 
nLines = length(linePer);
groups = unique(TE.(s.splitBy));
nGroups = length(groups);

allBeh = NaN(nLines, nGroups);

behData = TE.(s.behVar);

for n = 1:nLines
    for g = 1:nGroups
        trials = selectTrials & contains(TE.(s.linePer),linePer{n}) & TE.(s.splitBy)==groups(g);
        allBeh(n,g) = nanmean(behData(trials));
    end
end

% If you are splitting by trial type, change the order of data so that column 1 is big reward, column 2 is
% small, and 3 is none
if contains(s.splitBy, 'TrialTypes')
    bigs = allBeh(:,2);
    smalls = allBeh(:,1);

    allBeh(:,1) = bigs;
    allBeh(:,2) = smalls;

    groupNames = [{'Big'}, {'Small'}, {'None'}];
else
    groupNames = num2cell(num2str(groups));
end

%% Plotting

% load colors
load("C:\Users\Kepecs\MATLAB\Projects\DAManuscript\FigureGeneratingFunctions\BarPlotColors.mat")

fig = figure();
barFigData = bar(nanmean(allBeh), 'EdgeColor', 'k', 'FaceColor', 'flat', 'FaceAlpha', 0.8, 'BarWidth', 1);
hold on
lineFigData = plot(allBeh', 'k', 'LineWidth', 0.5, 'Color', [0 0 0 0.45]);

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

xlabel(s.splitBy)
xticklabels(groupNames)
ylabel(s.behVar)

xlim([0.35 3.65])
set(gca, 'FontName', 'Arial', 'TickLength', [0.04 0.04], 'LineWidth', 0.25, 'TickDir','out', 'box', 'off', 'FontSize', 20);
%daspect([1 3.5 1])

%Statistics
dataTable = table(linePer,allBeh(:,1), allBeh(:,2), allBeh(:,3));
dataTable.Properties.VariableNames = ["animal", "big", "small", "none"];
rm = fitrm(dataTable, 'big-none ~1', WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [-1 0 1]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
disp(fVal) 
disp(pVal)

end