%% plot_learning_ILIpdf
% gets the pdf kernel densities across mice for each learning session
% Functions used:
%   - parse-args
%   - plot_ILIpdf
%   - shadedErrorBar
%   - kstest2 (from MATLAB statistics toolbox)
%   - slanCM
% Inputs:
%   - TE struct, which must contain a "lickInfo_tone" field as generated by
%   getCorrectedInterlicks function
%   - 'maxSessions', which is the number of sequential learning sessions
%   you want to plot
%   - 'lickVar', the subfield of TE.lickInfo_tone you want to analyze

function stats = plot_learning_ILIpdf(TE, varargin)

defaults = {...
    'maxSessions',3;...
    'lickVar', 'realInterLicks';,...%do you want to plot pdf for interlick intervals, time to first lick, etc.
    };
[s, ~] = parse_args(defaults, varargin{:});

%animals = unique(TE.animalID);
animals = [{'Dat3-6'},{'DatCre30'},{'DatCre31'},{'DatCre32'},{'DatCre33'},{'DatSilk1'},{'DatSilk2'},{'DatSilk3'}];
nAnimals = length(animals);

for a = 1:nAnimals
    %get trial indices for current animal and for specified learning
    %sessions
    selectTrials = contains(TE.animalID, animals{a}) & TE.sessionOrder<(s.maxSessions+1);
    nSessions = max(unique(TE.sessionOrder(selectTrials)));
    %get pdfs for each learning session 
    [pdfVals, xBins] = plot_ILIpdf(TE, TE.lickInfo_tone, selectTrials, 'lickVar', s.lickVar, 'plotBy', 'sessionOrder', 'bandWidth', 0.12, 'openFigure', 'off');
    %save mean pdfs for current animal
    for sesh = 1:nSessions
        pdfPerMouse.x{sesh}(a,:) = (xBins(sesh,:));
        pdfPerMouse.y{sesh}(a,:) = (pdfVals(sesh,:));
    end
end

figure()
colors = slanCM('cool',nSessions);
for sesh = 1:nSessions
    figData(sesh) = shadedErrorBar(nanmean(pdfPerMouse.x{sesh}), nanmean(pdfPerMouse.y{sesh}), sem(pdfPerMouse.y{sesh}), {'color', [colors(sesh,:)]}); hold on
end
set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'FontSize', 15);
xlabel('Time (s)')
ylabel('Probability density')

%statistics by comparing pdf averaged across animals from different
%training sessions using 2 sample kolmogorov-smirnov test
combos = combinations([1:nSessions], [1:nSessions]);
repeats = combos.Var1 == combos.Var2;
testCombos = table2array(combos(repeats==0,:));
[~, uIdx] = unique(sum(testCombos,2));
testCombos = testCombos(uIdx,:);

for f = 1:length(testCombos)
    stats(f).comparison = [(strcat('session#', num2str(testCombos(f,1)))), (strcat('session#', num2str(testCombos(f,2))))];
    [h, p, k] = kstest2(figData(testCombos(f,1)).mainLine.YData,figData(testCombos(f,2)).mainLine.YData);
    stats(f).h = h;
    stats(f).p = p;
    stats(f).k = k;
end

% slowProb = NaN(nAnimals, s.maxSessions);
% licks = TE.lickInfo_tone.(s.lickVar);
% for a = 1:nAnimals
%     for sesh = 1:s.maxSessions
%         trials = contains(TE.animalID, animals{a}) & TE.sessionOrder == sesh;
%         allLicks = cell2mat(licks(trials)');
%         slowProb(a,sesh) = sum(allLicks>0.5)/length(allLicks);
%     end
% end
% 
% figure()
% varNames = num2str([1:s.maxSessions]');
% bar([1:s.maxSessions], nanmean(slowProb))
% hold on
% plot([1:s.maxSessions], slowProb, 'k')
% set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'FontSize', 15);
% xticklabels(varNames)
% xlabel('Training session #')
% ylabel('Probability of long ILI')

end