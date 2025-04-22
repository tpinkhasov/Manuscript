
function percentFail = get_percentFailTrials(TE, selectTrials, varargin)

defaults = {...
    'splitBy', 'TrialTypes';...%do you want to plot the line for each animal vs trial type, etc.
    'taskType', 'Control';...
    };
[s, ~] = parse_args(defaults, varargin{:});

if contains(s.splitBy, 'none')
    nGroups = 1;
else 
    nGroups = length(unique(TE.(s.splitBy)));
end

percentFail = NaN(nGroups,1);

if contains(s.taskType, 'LW')
    for g = 1:nGroups
        if contains(s.splitBy, 'none')
            trials = selectTrials;
        else
            trials = selectTrials & TE.(s.splitBy) == g;
        end
        failTrials = trials & TE.SoundDur>29;
        percentFail(g, 1) = (sum(failTrials)/sum(trials))*100;
    end
elseif contains(s.taskType, 'Control')
    nonStopLickTrials = getNonStopLickTrials(TE);
    for g = 1:nGroups
        if contains(s.splitBy, 'none')
            trials = selectTrials;
        else
            trials = selectTrials & TE.(s.splitBy) == g;
        end
        failTrials = trials & nonStopLickTrials ==1;
        percentFail(g, 1) = (sum(failTrials)/sum(trials))*100;
    end
end

end