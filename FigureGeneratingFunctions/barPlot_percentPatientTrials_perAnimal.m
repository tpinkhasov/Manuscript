function allPercentPatient = barPlot_percentPatientTrials_perAnimal(TE, selectTrials, varargin)

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

allPercentPatient = NaN(nLines, nGroups);

for n = 1:nLines
    trials = selectTrials & contains(TE.(s.linePer),linePer{n});
    allPercentPatient(n,:) = get_percentPatientTrials(TE, trials, 'splitBy', s.splitBy);
end

if contains(s.splitBy, 'TrialTypes')
    bigs = allPercentPatient(:,2);
    smalls = allPercentPatient(:,1);

    allPercentPatient(:,1) = bigs;
    allPercentPatient(:,2) = smalls;

    groupNames = [{'Big'}, {'Small'}, {'None'}];
legend
else
    groupNames = num2cell(num2str(groups));
end

%% Plotting

% load colors
load("C:\Users\Kepecs\MATLAB\Projects\DAManuscript\FigureGeneratingFunctions\BarPlotColors.mat")

fig = figure();
barFigData = bar(nanmean(allPercentPatient), 'FaceColor', 'flat', 'FaceAlpha', 0.8, 'BarWidth', 1);
hold on
lineFigData = plot(allPercentPatient', 'k', 'LineWidth', 0.5, 'Color', [0 0 0 0.45]);

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
ylabel('% patient trials')

xlim([0.35 3.65])
set(gca, 'FontName', 'Arial', 'TickLength', [0.04 0.04], 'LineWidth', 0.25, 'TickDir','out', 'box', 'off', 'FontSize', 20);
%daspect([1 3.5 1])

%Statistics
dataTable = table(linePer,allPercentPatient(:,1), allPercentPatient(:,2), allPercentPatient(:,3));
dataTable.Properties.VariableNames = ["animal", "big", "small", "none"];
rm = fitrm(dataTable, 'big-none ~1', WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [-1 0 1]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
disp(fVal) 
disp(pVal)

end