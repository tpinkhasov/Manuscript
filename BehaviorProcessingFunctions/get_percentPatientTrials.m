
function percentPatient = get_percentPatientTrials(TE, selectTrials, splitBy)

nGroups = length(unique(splitBy));
percentPatient = NaN(nGroups,1);

for s = 1:nGroups
    trials = selectTrials & splitBy == s;
    patientTrials = trials & TE.SoundDur <2.1;
    percentPatient(s, 1) = (sum(patientTrials)/sum(trials))*100;
end

end