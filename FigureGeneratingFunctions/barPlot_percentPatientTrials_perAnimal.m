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
    allPercentPatient(n,:) = get_percentPatientTrials(TE, trials, TE.(s.splitBy));
end

if contains(s.splitBy, 'TrialTypes')
    bigs = allPercentPatient(:,2);
    smalls = allPercentPatient(:,1);

    allPercentPatient(:,1) = bigs;
    allPercentPatient(:,2) = smalls;

    groupNames = [{'Big'}, {'Small'}, {'None'}];

else
    groupNames = num2cell(num2str(groups));
end

figure()
bar(nanmean(allPercentPatient))
hold on
plot(allPercentPatient', 'k')

xlabel(s.splitBy)
xticklabels(groupNames)
ylabel('% patient trials')
set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'FontSize', 15);

%Statistics
dataTable = table(linePer,allPercentPatient(:,1), allPercentPatient(:,2), allPercentPatient(:,3));
dataTable.Properties.VariableNames = ["animal", "big", "small", "none"];
rm = fitrm(dataTable, 'big-none ~1', WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [1 0 -1]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
text(3, 15, fVal); hold on
text(3, 14, pVal)

end