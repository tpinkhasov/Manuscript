function TE = makeTE_LW_new(sessions)

if nargin < 1
    sessions = bpLoadSessions;
end

% find total number of trials acrosss selected sesssions
sTally = zeros(size(sessions));
for i = 1:length(sessions)
    sTally(i) = length(sessions(i).SessionData.RawEvents.Trial) ;
end

nTrials = sum(sTally)- length(sessions);

% find all unique fieldnames across sessions uploaded
fields=[];
settingFields = [];
for s = 1:length(sessions)
    fields = [fields; fieldnames(sessions(s).SessionData)];
    %settingFields = [settingFields; fieldnames(sessions(s).SessionData.TrialSettings)];
end
 fields = unique(fields);
% 
 fields(contains(fields, 'Raw'))=[];
% fields(contains(fields, 'Nidaq'))=[];
fields(contains(fields, 'TrialSettings'))=[];
fields(contains(fields, 'sincWaveForm'))=[];
%% initialize TE
TE = cell2struct(cell(length(fields),1), fields);
%TE.TrialSettings = cell2struct(cell(length(settingFields),1),settingFields);
%% Add field data
nCounter(1) = 0;
for s = 1:length(sessions)
    nCounter(s+1) = nCounter(s) + sessions(s).SessionData.nTrials-1;
 %   TE.TrialSettings(s).GUI = [sessions(s).SessionData.TrialSettings(1).GUI];
    for f = 1:length(fields)
        if isfield(sessions(s).SessionData,(fields{f}))
            if size(sessions(s).SessionData.(fields{f}),2)>1
                sessions(s).SessionData.(fields{f})=sessions(s).SessionData.(fields{f})';
            end
            if isnumeric(sessions(s).SessionData.(fields{f}))
                TE.(fields{f}) = [TE.(fields{f}); num2cell(sessions(s).SessionData.(fields{f}))];
            else
                TE.(fields{f}) = [TE.(fields{f}); sessions(s).SessionData.(fields{f})];
            end
        else
            TE.(fields{f}) = [TE.(fields{f}); cell(sessions(s).SessionData.nTrials,1)];
        end
    end
end

% add filename & filepath
TE.trialNumber=NaN(nTrials,1);
TE.animalID =cell(nTrials,1);
nCounter(1) = 0;
for s = 1:length(sessions)
     nCounter(s+1) = nCounter(s) + sessions(s).SessionData.nTrials;
    TE.sessions.filename{s,1} = sessions(s).filename;
    TE.sessions.filepath{s,1} = sessions(s).filepath;
    TE.sessions.index(s,1) = s;
    
    TE.sessionName((nCounter(s)+1):nCounter(s+1),1) = {sessions(s).filename};

    TE.sessionNumber((nCounter(s)+1):nCounter(s+1),1) = s;
    
    TE.trialNumber((nCounter(s)+1):nCounter(s+1),1) = (1:sessions(s).SessionData.nTrials)';
    TE.animalID((nCounter(s)+1):nCounter(s+1),1) = {TE.sessions.filename{s}(1:strfind(TE.sessions.filename{s}, '_LW')-1)};
   % nCounter = nCounter+sessions(s).SessionData.nTrials;
end

%% Get all event states to add, including ones unique to certain sessions
for s = 1:length(sessions)
    statesToAdd = fieldnames(sessions(s).SessionData.RawEvents.Trial{1, 1}.States);
end
statesToAdd = unique(statesToAdd');

for i = 1:length(statesToAdd)
    TE(1).(statesToAdd{i}) = bpAddStateAsTrialEvent(sessions, statesToAdd{i});
end
TE(1).Port1In = bpAddEventAsTrialEvent(sessions, 'Port1In');

animalNames = unique(TE.animalID);
for a = 1:length(animalNames)
    TE.animalNumber(contains(TE.animalID, animalNames{a}),1) = a;
end
 TE.TrialTypes = cell2mat(TE.TrialTypes);
%  empties = cellfun(@(x) isempty(x), TE.stimTrial);
% TE.stimTrial(empties) = {NaN};
% TE.stimTrial=cell2mat(TE.stimTrial);
 TE.CS2RT = cellfun(@diff,TE.CS2, 'UniformOutput', false);
 TE.CS2RT = cell2mat(TE.CS2RT);
 TE.sessionIndex=TE.sessionNumber;
TE.SoundDur = cellfun(@(x) x(end,end), TE.SoundCue) - cellfun(@(x) x(1,1), TE.SoundCue);
TE.SoundDur(TE.SoundDur<2.00000001 & TE.SoundDur>1.99999)=2;
 TE.Photometry.sampleRate = 61;
% TE.lickInfo = getCorrectedInterLicks(TE, TE.SoundCue, .05);
 %TE.tone_ILI=TE.lickInfo.realInterLicks;

% 
 %[newCS2RT, TE.satietyState] = getSatietyStates(TE, 2);
% sessionSplit = splitSession(TE, 3);
% TE.sessionThird = sessionSplit;
% [~, TE.satietyState] = getSatietyStates(TE, 2);
%[TE.ITILR, TE.toneLR] = getLickRates(TE);
%[TE.ITI_ILI, TE.sound_ILI]=getInterLicks(TE,  3, .05);