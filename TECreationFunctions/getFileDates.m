%% Extract dates from filenames and convert to numeric values in the format YYYYMMDD
%Assumes existence of filename struct
function dates = getFileDates(TE, selectTrials)
idx = (cellfun(@(x) strfind(x, '_Session'), TE.filename(selectTrials), 'UniformOutput', false));
dateStrings = cellfun(@(x,y) x(y-10:y-1), TE.filename(selectTrials), idx, 'UniformOutput',false);
dateTimes = cellfun(@(x) datetime(x,'InputFormat', 'MMMdd_yyyy'), dateStrings, 'UniformOutput',false);
dates = cellfun(@(x) convertTo(x, 'yyyymmdd'), dateTimes);
end