%% getSessionThird
% splits session into 3 equal parts

function sessionThird = getSessionThird(TE)

%create sessionIndex field if doesn't already exist
if ~isfield(TE, 'sessionIndex')
    TE.sessionIndex = getSessionIndex(TE);
end

nSessions = max(TE.sessionIndex); %get total # of sessions

sessionThird = NaN(size(TE.TrialTypes)); %initialize output

for s = 1:nSessions
    trials = TE.sessionIndex == s;
    third = floor(sum(trials)/3);
    trialIdx = [find(trials,1),find(trials,1)+third,  find(trials,1)+third+third];
    sessionThird(trialIdx(1):trialIdx(2)) = 1;
    sessionThird(trialIdx(2)+1:trialIdx(3)) = 2;
    sessionThird(trialIdx(3)+1:end) = 3;
end

end
