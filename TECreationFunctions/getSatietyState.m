%% getSatietyState
% Inputs:
% 1) TE = Data struct that contains the following fields:
%   - 'sessionIndex', generated with 'getSessionIndex' function
%   - 'CS2RT', generated with 'getCS2RT' function
% 2) trialType = value of 1, 2, or 3
%   - specifies what reward size trial type you consider for no licks to be
%   considered sated. 1 = small reward. 2 = large reward. 3 = no reward.
%   Choosing large reward trials makes the most sense. 
% 3) numNoLickTrials = # of no lick trials of the specified reward size 
% trial type in a row which you would consider sated. I typically pick 4. 
% Output:
% 1) satietyState = array of size nTrials x 1
%   - 0: thirsty trial
%   - 1: sated trial
%   - NaN: trial from invalid session 

function satietyState = getSatietyState(TE, trialType, numNoLickTrials)

nTrials = length(TE.sessionIndex); %get # of trials
nSessions = max(TE.sessionIndex); %get # of sessions
satietyState = zeros(nTrials,1); %initialize output array

for s = 1:nSessions
    %Get logical array indicating location of trials of the specified
    %reward type 
    trials = TE.sessionIndex == s & TE.TrialTypes == trialType;
    %if there are no such trials, session is not valid
    if sum(trials) == 0
        satietyState(TE.sessionIndex == s) = NaN;
        continue
    end
    %Get logical array indicating subset of above trials in which mouse did
    %not retrieve reward
    noLickTrials = trials & isnan(TE.CS2RT);

    %Find where the mouse did not lick for the specified reward size for 
    %the number of trials in a row specified by the 'numNoLickTrials' input
    satedIdx = find(cumsum(noLickTrials) == numNoLickTrials,1); 

    if ~isempty(satedIdx)
       satietyState(satedIdx:find(TE.sessionIndex==s,1, 'last'))=1; %1 means sated
    end
end
end
