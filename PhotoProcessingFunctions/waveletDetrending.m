function [fittedData, detrended] = waveletDetrending(RawSessionSignal, f_sample, f_c_pseudo, wname, cutStart, cutEnd, toPlot)

tempData = RawSessionSignal;
nanIdx = [1:length(tempData)]';

if cutStart>0
    tempData(1:f_sample*60*cutStart)=NaN;
    tempData((end-(f_sample*60*cutEnd)):end)=NaN;
else
    tempData((end-(f_sample*60*cutEnd)):end)=NaN;
end
RawSessionSignal = RawSessionSignal(~isnan(tempData));
nanIdx = nanIdx(~isnan(tempData));
N = length(RawSessionSignal);
wlevel = ceil(log2(f_sample/f_c_pseudo));
try
    [c,l] = wavedec(RawSessionSignal, wlevel, wname);
    %approx = wrcoef('a', c, l, wname);
    approx = movmean(wrcoef('a', c, l, wname), round(f_sample/2));
    
    if toPlot==1
        t = (0:1:N-1) * 1/f_sample;
        medfittedData = movmedian(RawSessionSignal, f_sample*60*1);
        figure();
        plot(t, RawSessionSignal);
        hold on;
        plot(t, medfittedData, 'linewidth', 2);
        plot(t, approx, 'linewidth', 2);
        title(['DWT Decomposition using ' wname ' level ' num2str(wlevel) '(pseudo cutoff: ' num2str(f_c_pseudo) 'Hz)']);
    end
end
fittedData = NaN(length(tempData),1);
fittedData(nanIdx) = approx;
% if cutStart>0
%     fittedData((61*60*cutStart):((61*60*cutStart)+length(approx)-1)) = approx;
% else
%     fittedData(1:length(approx)) = approx;
% end
detrended = (tempData-fittedData)./fittedData;
% % put back into trials
%
% lengths = cellfun(@(x) length(x), deMod);
% endIdx = num2cell(cumsum(lengths));
% startIdx = num2cell([1; cellfun(@(x) x+1, endIdx(1:end-1))]);
%
% dataFit = cellfun(@(x,y) fittedData(x:y), startIdx, endIdx, 'UniformOutput', 0);
% detrendedData = cellfun(@(x,y) detrended(x:y), startIdx, endIdx, 'UniformOutput', 0);
end