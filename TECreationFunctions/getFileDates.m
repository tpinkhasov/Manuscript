%% Extract dates from filenames and convert to numeric values in the format YYYYMMDD
%Assumes existence of filename struct
function dates = getFileDates(TE)
idx = num2cell(cellfun(@(x) strfind(x, '_Session'), TE.filename));
dateStrings = cellfun(@(x,y) x(y-10:y-1), TE.filename, idx, 'UniformOutput',false);
dateTimes = cellfun(@(x) datetime(x,'InputFormat', 'MMMdd_yyyy'), dateStrings);
dates = convertTo(dateTimes, 'yyyymmdd');
end