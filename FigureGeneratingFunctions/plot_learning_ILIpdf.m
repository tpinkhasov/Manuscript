

function plot_learning_ILIpdf(TE, varargin)

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
    shadedErrorBar(nanmean(pdfPerMouse.x{sesh}), nanmean(pdfPerMouse.y{sesh}), sem(pdfPerMouse.y{sesh}), {'color', [colors(sesh,:)]}); hold on
   % lgd(sesh) = legend(strcat('session #', num2str(sesh)), 'TextColor', colors(sesh,:));
end
set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'FontSize', 15);
xlabel('Time (s)')
ylabel('Probability density')
%lgd = legend(strcat('session #', num2str([1:nSessions]')));


end