%% getSessionIndex
%% Indexes all sessions in a TE struct

function trialNumber = getTrialNumber(TE)

uniqueSessions = unique(TE.filename, 'stable'); % get all the unique session names, keep the original order
nSessions = length(uniqueSessions);
totTrials = length(TE.filename);

trialNumber = NaN(totTrials,1); % initialize output array

for s = 1:nSessions
    trials = contains(TE.filename, uniqueSessions{s});
    trialNumber(trials) = 1:sum(trials);
end

end