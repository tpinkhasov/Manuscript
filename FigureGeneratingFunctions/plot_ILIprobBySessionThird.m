%% Plot probability of long interlick interval (>0.5s) compared between session third
% Will plot bar graph of average across mice and line plots of each mouse's average
% Will run linear contrast rm ANOVA analysis
% Input is TE data struct and "animals" as a list of chars

function plot_ILIprobBySessionThird(TE, animals)

nAnimals = length(animals);
firstThird_ILI = NaN(length(animals), 1);
secondThird_ILI = NaN(length(animals), 1);
thirdThird_ILI = NaN(length(animals), 1);

for a = 1:nAnimals
    
    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.sessionThird == 3;
    allLicks = cell2mat(TE.lickInfo_tone.realInterLicks(trials)');
    thirdThird_ILI(a,1) = sum(allLicks>0.5 & allLicks<2)/sum(allLicks<2);
    
    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.sessionThird == 1;
    allLicks = cell2mat(TE.lickInfo_ITI.realInterLicks(trials)');
    firstThird_ILI(a,1) = sum(allLicks>0.5)/length(allLicks);    

    trials = contains(TE.animalID, animals{a}) & TE.satietyState == 0 & TE.sessionThird == 2;
    allLicks = cell2mat(TE.lickInfo_Reward.realInterLicks(trials)');
    secondThird_ILI(a,1) = sum(allLicks>0.5)/length(allLicks);   
end
data = [firstThird_ILI, secondThird_ILI, thirdThird_ILI];
varNames = [{'1st'}, {'2nd'}, {'3rd'}];
bar([1:3], nanmean(data),'BarWidth', 0.95)
hold on
plot([1:3], data, 'k')
set(gca, 'FontName', 'Arial', 'TickLength', [0.04 0.04], 'LineWidth', 0.25, 'TickDir','out', 'box', 'off', 'FontSize', 20);
xticklabels(varNames)
xlim([0.2 3.8])
xlabel('Session Tertile')
ylabel('Probability of long ILI')

%Statistics
dataTable = table(animals,firstThird_ILI, secondThird_ILI, thirdThird_ILI);
rm = fitrm(dataTable, "firstThird_ILI-thirdThird_ILI ~ 1", WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [1 0 -1]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
text(3, 0.35, fVal); hold on
text(3, 0.3, pVal)
end