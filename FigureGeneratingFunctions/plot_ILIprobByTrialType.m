%% Plot probability of long interlick interval (>0.5s) compared between trial types
% Will plot bar graph of average across mice and line plots of each mouse's average
% Will run linear contrast rm ANOVA analysis
% Input is TE data struct and "animals" as a list of chars

function plot_ILIprobByTrialType(TE, animals)

if ~isfield(TE, 'lickInfo_tone')
    TE.lickInfo_tone = getCorrectedInterLicks(TE, cellfun(@(x) x(1,1), TE.SoundCue,  'UniformOutput', false), cellfun(@(x) x(end,end), TE.SoundCue,  'UniformOutput', false), .05);
end

nAnimals = length(animals);
big_ILI = NaN(length(animals), 1);
small_ILI = NaN(length(animals), 1);
none_ILI = NaN(length(animals), 1);

for a = 1:nAnimals
    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 2;
    allLicks = cell2mat(TE.lickInfo_tone.realInterLicks(trials)');
    big_ILI(a,1) = sum(allLicks>0.5 & allLicks<2.1)/sum(allLicks<2.1);

    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 1;
    allLicks = cell2mat(TE.lickInfo_tone.realInterLicks(trials)');
    small_ILI(a,1) = sum(allLicks>0.5 & allLicks<2.1)/sum(allLicks<2.1);   

    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 3;
    allLicks = cell2mat(TE.lickInfo_tone.realInterLicks(trials)');
    none_ILI(a,1) = sum(allLicks>0.5 & allLicks<2.1)/sum(allLicks<2.1);   
end

data = [big_ILI, small_ILI, none_ILI];
varNames = [{'big'}, {'small'}, {'none'}];
bar([1:3], nanmean(data))
hold on
plot([1:3], data, 'k')
set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'FontSize', 15);
xticklabels(varNames)
xlabel('Expected reward size')
ylabel('Probability of long ILI')

%Statistics
dataTable = table(animals,big_ILI, small_ILI, none_ILI);
rm = fitrm(dataTable, "big_ILI-none_ILI ~ 1", WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [1 0 -1]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
text(3, 0.35, fVal); hold on
text(3, 0.3, pVal)
end