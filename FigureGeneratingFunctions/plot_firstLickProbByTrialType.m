%% Plot probability of  time to first lick above or below set threshold compared between trial types
% Will plot bar graph of average across mice and line plots of each mouse's average
% Will run linear contrast rm ANOVA analysis
% Input is TE data struct and "animals" as a list of chars

function plot_firstLickProbByTrialType(TE, animals, varargin)

defaults = {'lickThresh', 0.5; 'speed', 'slow'};
[s, ~] = parse_args(defaults, varargin{:});

if ~isfield(TE, 'lickInfo_tone')
    TE.lickInfo_tone = getCorrectedInterLicks(TE, cellfun(@(x) x(1,1), TE.SoundCue,  'UniformOutput', false), cellfun(@(x) x(end,end), TE.SoundCue,  'UniformOutput', false), .05);
end

firstLick = cellfun(@(x,y) x(1)-y(1,1), TE.lickInfo_tone.realLicks, TE.SoundCue);

nAnimals = length(animals);
big_firstLick = NaN(length(animals), 1);
small_firstLick = NaN(length(animals), 1);
none_firstLick = NaN(length(animals), 1);

for a = 1:nAnimals

    if contains(s.speed, 'slow')
    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 2;
    allLicks = firstLick(trials);
    big_firstLick(a,1) = sum(allLicks>s.lickThresh & allLicks<2.1)/sum(allLicks<2.1);

    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 1;
    allLicks = firstLick(trials);    
    small_firstLick(a,1) = sum(allLicks>s.lickThresh & allLicks<2.1)/sum(allLicks<2.1);   
   
    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 3;
    allLicks = firstLick(trials);
    none_firstLick(a,1) = sum(allLicks>s.lickThresh & allLicks<2.1)/sum(allLicks<2.1);   

    elseif contains(s.speed, 'fast')
    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 2;
    allLicks = firstLick(trials);
    big_firstLick(a,1) = sum(allLicks<s.lickThresh & allLicks<2.1)/sum(allLicks<2.1);

    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 1;
    allLicks = firstLick(trials);    
    small_firstLick(a,1) = sum(allLicks<s.lickThresh & allLicks<2.1)/sum(allLicks<2.1);   
   
    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.TrialTypes == 3;
    allLicks = firstLick(trials);
    none_firstLick(a,1) = sum(allLicks<s.lickThresh & allLicks<2.1)/sum(allLicks<2.1); 
    end
end

% load colors
load("C:\Users\Kepecs\MATLAB\Projects\DAManuscript\FigureGeneratingFunctions\BarPlotColors.mat")

data = [big_firstLick, small_firstLick, none_firstLick] .* 100;
varNames = [{'big'}, {'small'}, {'none'}];
barFigData = bar([1:3], nanmean(data), 'BarWidth', 1, 'FaceColor', 'flat', 'FaceAlpha', 0.8);
hold on
plot([1:3], data, 'k')
set(gca, 'FontName', 'Arial', 'TickLength', [0.04 0.04], 'LineWidth', 0.25, 'TickDir','out', 'box', 'off', 'FontSize', 20);
xticklabels(varNames)
xlim([0.35 3.65])
xlabel('Expected reward size')
ylabel('Probability of long time to first lick')

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

%Statistics
dataTable = table(animals,big_firstLick, small_firstLick, none_firstLick);
rm = fitrm(dataTable, "big_firstLick-none_firstLick ~ 1", WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [1 0 -1]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
text(3, 0.35, fVal); hold on
text(3, 0.3, pVal)
end