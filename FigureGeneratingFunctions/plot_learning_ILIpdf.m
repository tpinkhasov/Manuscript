

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

end