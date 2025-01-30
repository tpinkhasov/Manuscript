%% plot_ILIpdf
% requires the use of getCorrectedInterLicks to generate the correct data structure
% uses slanCM function to generate 'cool' color palatte

function [pdfVals, xBins] = plot_ILIpdf(TE, lickStruct, selectTrials, varargin)

defaults = {...
    'plotBy', 'animalID';...%do you want to plot the pdf for each animal vs trial type, etc.
    'bandWidth', 0.12;...
    'openFigure','on';...
    'lickVar', 'realInterLicks';,...%do you want to plot pdf for interlick intervals, time to first lick, etc.
    };
[s, ~] = parse_args(defaults, varargin{:});

loopBy = unique(TE.(s.plotBy)(selectTrials));

%initialize output arrays with dummy inputs to determine size of outputs
[d,xi] = ksdensity(rand(1,20), 'BandWidth', s.bandWidth, 'Function','pdf');
pdfVals = NaN(length(loopBy), length(d));
xBins = NaN(length(loopBy), length(d));

% initialize figure and colors if 'openFigure' is set as 'on'
if contains(s.openFigure, 'on')
    colors = slanCM('cool',length(loopBy));
    figure()
end

% loop through desired variable to get output values
for f = 1:length(loopBy)
    %get trials
    if iscell(loopBy(f)) == 1 & ischar(loopBy{f}) == 1
        trials = contains(TE.(s.plotBy), loopBy{f}) & selectTrials;
    else
        trials = TE.(s.plotBy) == loopBy(f) & selectTrials;
    end
    %get lick values
    if iscell(lickStruct.(s.lickVar))
        licks = cell2mat(lickStruct.(s.lickVar)(trials)');
    else
        licks = lickStruct.(s.lickVar)(trials)';
    end
    %calculate pdf
    [d,xi] = ksdensity(licks, 'BandWidth', s.bandWidth, 'Function','pdf');
    pdfVals(f,:) = d;
    xBins(f,:) = xi;
    %plot if 'openFigure' is 'on'
    if contains(s.openFigure, 'on')
        plot(xi,(d), 'Color', [colors(f,:)], 'LineWidth', 2);
        hold on
    end
end

%set plot features if 'openFigure' is 'on'
if contains(s.openFigure, 'on')
    set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'FontSize', 15);
    xlabel('Time (s)')
    ylabel('Probability density')
    %set legend
    if iscell(loopBy(f)) == 1 & ischar(loopBy{f}) == 1
        legend(loopBy)
    elseif isa(loopBy,'double') == 1
        legend(strcat(s.plotBy, num2str(loopBy)))
    end
end

end