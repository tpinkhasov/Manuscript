
function percentPatient = get_percentPatientTrials(TE, selectTrials, varargin)

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

percentPatient = NaN(nGroups,1);

if contains(s.taskType, 'LW')
    for g = 1:nGroups
        if contains(s.splitBy, 'none')
            trials = selectTrials;
        else
            trials = selectTrials & TE.(s.splitBy) == g;
        end
        patientTrials = trials & TE.SoundDur <2.1;
        percentPatient(g, 1) = (sum(patientTrials)/sum(trials))*100;
    end
elseif contains(s.taskType, 'Control')
    for g = 1:nGroups
        if contains(s.splitBy, 'none')
            trials = selectTrials;
        else
            trials = selectTrials & TE.(s.splitBy) == g;
        end
        patientTrials = trials & TE.lickInfo_tone.noLickTrials ==1;
        percentPatient(g, 1) = (sum(patientTrials)/sum(trials))*100;
    end
end

end