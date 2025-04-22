

function allInterBursts = plot_sequentialInterBurstIntervals(TE, selectTrials, varargin)

defaults = {...
    'linePer', 'animalID';...%do you want to plot the pdf for each animal vs trial type, etc.
    'nBursts', 5;...
    };

[s, ~] = parse_args(defaults, varargin{:});

if ~isfield(TE, 'lickInfo_tone')
    TE.lickInfo_tone = getCorrectedInterLicks(TE, cellfun(@(x) x(1,1), TE.SoundCue,  'UniformOutput', false), cellfun(@(x) x(end,end), TE.SoundCue,  'UniformOutput', false), .05);
end

if contains(s.linePer, 'trialNumber')
    trials = selectTrials & TE.lickInfo_tone.numBursts > s.nBursts;
    linePer = num2str(TE.trialNumber(trials));
    allInterBursts = NaN(sum(trials), s.nBursts);
    for b = 1:s.nBursts
        allInterBursts(:,b) = cellfun(@(x) x(b), TE.lickInfo_tone.interBursts(trials));
    end
else

    linePer = unique(TE.(s.linePer)(selectTrials));
    nLines = length(linePer);

    allInterBursts = NaN(nLines, s.nBursts);

    for a = 1:nLines
        if ischar(linePer{1})
            trials = selectTrials & contains(TE.(s.linePer), linePer{a}) & TE.lickInfo_tone.numBursts > s.nBursts;
        elseif isnumeric(linePer)
            trials = selectTrials & TE.(s.linePer) == linePer(a) & TE.lickInfo_tone.numBursts > s.nBursts;
        end

        for b = 1:s.nBursts
            allInterBursts(a,b) = nanmean(cellfun(@(x) x(b), TE.lickInfo_tone.interBursts(trials)));
        end
    end
end
colors = slanCM('cool', s.nBursts);
colors(end, :) = [1	0.3	0.55];

figure()
vs = violinplot(allInterBursts, 3, 'ShowMean', false, 'ShowMedian', true, 'MedianMarkerSize', 150, 'ViolinColor', colors, 'MarkerSize', 20, 'EdgeColor', [1 1 1], 'ViolinAlpha', 0.3);
set(gca, 'FontName', 'Arial', 'TickLength', [0.04 0.04], 'LineWidth', 0.25, 'TickDir','out', 'box', 'off', 'FontSize', 20);
xlim([0.5 5.5])
xlabel('Premature lick burst #')
ylabel('Interburst interval (s)')

%Statistics
dataTable = table(linePer,allInterBursts(:,1), allInterBursts(:,2), allInterBursts(:,3), allInterBursts(:,4), allInterBursts(:,5));
dataTable.Properties.VariableNames = ["animal", "burst1", "burst2", "burst3", "burst4", "burst5"];
rm = fitrm(dataTable, 'burst1-burst5 ~1', WithinModel = 'orthogonalcontrasts');
stats = ranova(rm, 'WithinModel', [-2 -1 0 1 2]');

fVal = strcat('F(', num2str(stats.DF(1)), ', ', num2str(stats.DF(2)), ') = ', num2str(stats.F(1)));
pVal = strcat('p =', num2str(stats.pValue(1)));
disp(fVal) 
disp(pVal)

end



