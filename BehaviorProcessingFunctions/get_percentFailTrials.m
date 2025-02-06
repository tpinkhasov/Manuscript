
function percentFail = get_percentFailTrials(TE, selectTrials, splitBy)

maxDur = 29;
nGroups = length(unique(splitBy));
percentFail = NaN(nGroups,1);

for s = 1:nGroups
    trials = selectTrials & splitBy == s;
    failTrials = trials & TE.SoundDur >29;
    percentFail(s, 1) = (sum(failTrials)/sum(trials))*100;
end

end