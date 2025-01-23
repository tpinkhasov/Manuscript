function plot_ILIpdf(TE, lickStruct, selectTrials, varargin)

%% requires the use of getCorrectedInterLicks to generate the correct data structure

defaults = {...
    'plotBy', TE.animalID;...%do you want to plot the pdf for each animal vs trial type, etc.
    'lickVar', 'realInterLicks';,...%do you want to plot pdf for interlick intervals, time to first lick, etc.
    };
[s, ~] = parse_args(defaults, varargin{:});

loopBy = unique(s.plotBy(selectTrials));
figure()
for f = 1:length(loopBy)
    if ischar(loopBy{f}) == 1
        trials = contains(s.plotBy, loopBy{f}) & selectTrials;
        licks = cell2mat(lickStruct.(s.lickVar)(trials));
        [d,xi] = ksdensity(licks, 'BandWidth', 0.12, 'Function','pdf');
        plot(xi,(d));
        hold on
    end
end
