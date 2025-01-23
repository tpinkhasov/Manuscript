function plot_ILIpdf(TE, lickStruct, selectTrials, varargin)

%% requires the use of getCorrectedInterLicks to generate the correct data structure

defaults = {...
    'plotBy', 'animalID';...%do you want to plot the pdf for each animal vs trial type, etc.
    'lickVar', 'realInterLicks';,...%do you want to plot pdf for interlick intervals, time to first lick, etc.
    };
[s, ~] = parse_args(defaults, varargin{:});

loopBy = unique(TE.(s.plotBy)(selectTrials));
figure()
for f = 1:length(loopBy)
    if ischar(loopBy{f}) == 1
        trials = contains(TE.(s.plotBy), loopBy{f}) & selectTrials;
        if iscell(lickStruct.(s.lickVar))
            licks = cell2mat(lickStruct.(s.lickVar)(trials)');
        else
            licks = lickStruct.(s.lickVar)(trials)';
        end
        [d,xi] = ksdensity(licks, 'BandWidth', 0.12, 'Function','pdf');
        plot(xi,(d));
        hold on
    end
end

set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'FontSize', 15);
xlabel('Time (s)')
ylabel('Probability density')
legend(loopBy)