%% getSessionIndex

function sessionIndex = getSessionIndex(TE)

uniqueSessions = unique(TE.filename, 'stable'); % get all the unique session names, keep the original order
nSessions = length(uniqueSessions);
nTrials = length(TE.filename);

sessionIndex = NaN(nTrials,1); % initialize output array

for s = 1:nSessions
    trials = contains(TE.filename, uniqueSessions{s});
    sessionIndex(trials) = s;
end

end