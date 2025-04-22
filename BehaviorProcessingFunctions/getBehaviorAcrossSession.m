%% getBehaviorAcrossSessions
% outputs the average of a selected behavioral variable for each selected
% subject across a session. It does so by binning trials into an equal
% number of bins and averaging across those. 
function [trialEdges, allMeans] = getBehaviorAcrossSession(TE, selectTrials, varargin)

defaults = {...
    'splitBy', 'animalID';...%do you want to plot the pdf for each animal vs trial type, etc.
    'trialEdgeWidth', 0.1;...
    'behVar', 'SoundDur';...
    };
[s, ~] = parse_args(defaults, varargin{:});

trialNum_reScaled = reScaleTrialNumber(TE);
trialEdges = 0:s.trialEdgeWidth:1;
binIdx = discretize(trialNum_reScaled, trialEdges);

splitVar = unique(TE.(s.splitBy));
nMeans = length(splitVar);

allMeans = NaN(nMeans, length(trialEdges));

for n = 1:nMeans
    if ischar(splitVar{1})
        trials = selectTrials & contains(TE.(s.splitBy), splitVar{n});
    else
        trials = selectTrials & TE.(s.splitBy) == splitVar(n);
    end

    for bin = 1:length(trialEdges)
        allMeans(n,bin) = nanmean(TE.(s.behVar)(trials & binIdx==bin));
    end
end
end
    


