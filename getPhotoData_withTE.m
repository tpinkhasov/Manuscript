%% Functions needed to run this code:
% 1) parse_args
% 2) demodulateTrial_TP
% 3) waveletDetrending
% 
function TE = getPhotoData_withTE(TE,  varargin)

defaults = {...
    'demodulate', 1;...
    'detrend', 1;...
    'detrendMethod', 'movmed';...
    'fcs', [0.006];...
    'movWin', [30];...
    'baselineWin', 2;...
    'tdtControl', 0;... % relevent ONLY when zeroTimes are supplied as a cell array (e.g. if you want to align to the beginning or end of a bpod state). Enter number of event from beginning desired. Enter 1000 if u want the last of that particular event in that trial.
    'jumpCutOff', 0.01;... % cut off for considering difference between adjacent photo data points noise/jump
    };
[s, ~] = parse_args(defaults, varargin{:});


TE.Photometry.settings.uniformOutput=0;
try
totalTrials = length(TE.TrialTypes);
catch
    totalTrials = sum(cellfun(@(x) x(1)-1, TE.nTrials));
end
%nSessions = length(TE.sessions.filename);
nSessions = max(TE.sessionIndex);
% find photometry channels
names = fieldnames(TE);
photoChannels = [{'NidaqData'}, {'Nidaq2Data'}];
%(find(cellfun(@(x) contains(x, 'NidaqData_ch'), names)==1)); %find indices of nidaq data channels in data struct
numChannels = sum(contains(names, 'Nidaq'));

% get modulation amp and freq for each channel
for ch = 1:numChannels
    modAmp(ch)          = TE.TrialSettings(1).GUI.(sprintf('LED%i_Amp', ch));
    modFreq (ch)        = TE.TrialSettings(1).GUI.(sprintf('LED%i_Freq', ch));
end

if s(1).demodulate == 1
    %% 1) DEMODULATE
    
    DecimateFactor  = 100;
    sampleRate = TE.TrialSettings(1).GUI.NidaqSamplingRate;
    lowpass = 15;
    artifact_nSamples = ceil(61*0.1);
    
    
    for ch = 1:numChannels
        
        rawData = cell(totalTrials,1);
        refData = cell(totalTrials,1);
        demodulatedData = cell(totalTrials,1);
        replaceIdx  = cell(totalTrials,1);
        
        containsPhotoData = cellfun(@(x) ~isempty(x),  TE.(photoChannels{ch})); %find trials with actual Nidaq data
        trials = (containsPhotoData );
        rawData(trials==1) = cellfun(@(x) x(:,1), TE.(photoChannels{ch})(trials==1), 'UniformOutput', 0);  % extract raw data
        refData(trials==1) = cellfun(@(x) x(:,2), TE.(photoChannels{ch})(trials==1), 'UniformOutput', 0); % extract ref data
        
        % demodulate & decimate data
        demodulatedData(trials==1) = cellfun(@(x,y) demodulateTrial_TP(x, y, sampleRate, modAmp(ch), modFreq(ch), lowpass), rawData(trials==1), refData(trials==1), 'UniformOutput', 0);
        
        useThesePhotoData = cellfun(@(x) unique(isfinite(x) & ~isnan(x)), demodulatedData, 'UniformOutput', 0); % find finite usable data
        useThesePhotoData = cellfun(@(x) ~isempty(x), useThesePhotoData);
        useThesePhotoData = (useThesePhotoData(1:length(containsPhotoData)));
        trials = (containsPhotoData & useThesePhotoData);
        demodulatedData(trials==1) = cellfun(@(x) getDecimated(x, DecimateFactor, artifact_nSamples), demodulatedData(trials==1), 'UniformOutput', 0); % decimate data
        
        % extract and replace indices in beginning and end to remove filter
        % artifacts
        replaceIdx(containsPhotoData==1) = cellfun(@(x) [1:artifact_nSamples,length(x(:,1))-artifact_nSamples+1:length( x(:,1))], demodulatedData(containsPhotoData==1), 'UniformOutput', 0);
        demodulatedData(containsPhotoData==1) = cellfun(@makeNaN, demodulatedData(containsPhotoData==1), replaceIdx(containsPhotoData==1), 'UniformOutput', 0);
        
        % add processed photo data to TE struct
        TE.Photometry.data(ch).deMod = demodulatedData;
    end
end


%% 2) DETREND & NORMALIZE
if s(1).detrend == 1
        if contains(s.detrendMethod, 'wavelet')
            for numFc = 1:length(s(1).fcs)
                TE.Photometry.data(ch).waveletDFF_detrended{numFc}= cell(totalTrials,1);
                TE.Photometry.data(ch).waveletDFF_trendFit{numFc} = cell(totalTrials,1);
            end
            for ch = 1:numChannels
                % A. wavelet approach
                for nSesh = 1:nSessions
                    tempDemod = cell2mat(TE.Photometry.data(ch).deMod(TE.sessionIndex==nSesh));
                    %
                    %                     figure()
                    %                     subplot(2,1,1)
                    %                     plot(tempDemod)
%                     subplot(2,1,2)
%                     plot(movvar(tempDemod, 30, 'omitnan')./std(movvar(tempDemod, 30, 'omitnan')))
%                     
%                     prompt = {'Enter photo data indices to split by', 'Enter indices that include noise'};
%                     dlgtitle = 'Input';
%                     dims = [1 35];
%                     definput = {'0',''};
%                     opts.WindowStyle = 'normal';
%                     opts.Resize = 'on';
%                     answer = inputdlg(prompt,dlgtitle,dims, definput, opts);
%                     dataEdges = [str2num(answer{1}), length(tempDemod)];
                    
                    dataEdges = [0 length(tempDemod)];
%                     if ~isempty(answer{2})
%                         tempDemod(str2num(answer{2})) = NaN;
%                     end
                    %close all
                    for numFc = 1:length(s(1).fcs)
                        dataFit = [];
                        detrendedData = [];
                        currentFc = s(1).fcs(numFc);                       
                        for idx = 2:length(dataEdges)
                            currentDemod = tempDemod(dataEdges(idx-1)+1:dataEdges(idx));
                            try
                                %f_sample, f_c_pseudo, wname, cutStart, cutEnd, toPlot
                                [subDataFit, subDetrendedData] = waveletDetrending(currentDemod, 61, currentFc, 'dmey',  1, 0,0);
                                dataFit = [dataFit; subDataFit];
                                detrendedData = [detrendedData; subDetrendedData];
                            catch
                                dataFit = [dataFit; NaN(size(currentDemod))];
                                detrendedData = [detrendedData; NaN(size(currentDemod))];
                            end
                        end
                        
                        % put back into trials
                        
                        deMod = TE.Photometry.data(ch).deMod(TE.sessionIndex==nSesh);
                        lengths = cellfun(@(x) length(x), deMod);
                        endIdx = num2cell(cumsum(lengths));
                        startIdx = num2cell([1; cellfun(@(x) x+1, endIdx(1:end-1))]);
                        
                        fittedData = cellfun(@(x,y) dataFit(x:y), startIdx, endIdx, 'UniformOutput', 0);
                        detrended = cellfun(@(x,y) detrendedData(x:y), startIdx, endIdx, 'UniformOutput', 0);
                        
                        TE.Photometry.data(ch).waveletDFF_detrended{numFc}(find(TE.sessionIndex==nSesh),1) = detrended;
                        TE.Photometry.data(ch).waveletDFF_trendFit{numFc}(find(TE.sessionIndex==nSesh),1) = fittedData;
                    end
                end
            end
            % B. moving median approach
        elseif contains(s.detrendMethod, 'movmed')
            
            for numWin = 1:length(s.movWin)
                TE.Photometry.data(ch).movmedDFF_detrended{numWin}= cell(size(TE.TrialTypes));
                TE.Photometry.data(ch).movmedDFF_trendFit{numWin} = cell(size(TE.TrialTypes));
            end
            
            for nSesh = 1:nSessions
                for numWin = 1:length(s.movWin)
                    currentDemod = TE.Photometry.data(ch).deMod;
                    currentDemod = currentDemod(TE.sessionIndex==nSesh);
                    
                    fittedData = movmedian(cell2mat(currentDemod), s.movWin(numWin)*61, 'omitnan');
                    detrended = (cell2mat(currentDemod) - fittedData)./fittedData;
                    
                    %put moving median detrended back into trials
                    endIdx = num2cell(cumsum(cellfun(@(x) length(x),currentDemod)));
                    startIdx = num2cell([1; cellfun(@(x) x+1, endIdx(1:end-1))]);
                    
                    dataFit = cellfun(@(x,y) fittedData(x:y), startIdx, endIdx, 'UniformOutput', 0);
                    detrendedData = cellfun(@(x,y) detrended(x:y), startIdx, endIdx, 'UniformOutput', 0);
                    
                    TE.Photometry.data(ch).movmedDFF_detrended{numWin}(find(TE.sessionIndex==nSesh),1) = detrendedData;
                    TE.Photometry.data(ch).movmedDFF_trendFit{numWin}(find(TE.sessionIndex==nSesh),1) = dataFit;
                end
            end
        elseif contains(s.detrendMethod, 'trial')
            for ch = 1:numChannels
                try
                    baselineWin = 61*1;
                    baselines = cellfun(@(x) (x(1:baselineWin,1)), TE.Photometry.data(ch).deMod, 'UniformOutput', 0);
                    TE.Photometry.data(ch).trialDFF = cellfun(@(x,y) (x-nanmean(y))./nanmean(y), TE.Photometry.data(ch).deMod, baselines, 'UniformOutput', 0);
                end
            end
        elseif contains(s.detrendMethod, 'blInterp')
           
                PreStateDurs = cellfun(@(x) diff(x), TE.PreState);
                baselineWindows = repmat(s.baselineWin*61, [length(PreStateDurs),1]);
                baselineWindows(PreStateDurs<s.baselineWin) = round(PreStateDurs(PreStateDurs<s.baselineWin)*61);
                baselineWindows = num2cell(baselineWindows);
                TE.Photometry.data(ch).blInterp_detrended= cell(size(TE.TrialTypes));
                TE.Photometry.data(ch).blInterp_trendFit = cell(size(TE.TrialTypes));
                for nSesh = 1:max(TE.sessionIndex)
                    currentDemod = TE.Photometry.data(ch).deMod;
                    currentDemod = currentDemod(TE.sessionIndex==nSesh); 
                    baselines = cellfun(@(x,y) nanmean(x(1:y)), currentDemod, baselineWindows(TE.sessionIndex==nSesh));
                    x = linspace(0, sum(TE.sessionNumber==nSesh), length(cell2mat(currentDemod)));
                    try
                        fittedData = interp1(1:sum(TE.sessionNumber==nSesh),movmedian(baselines, [0 10], 'omitnan'), x);
                        fittedData = fittedData';
                        detrended = (cell2mat(currentDemod) - fittedData)./fittedData;
                        %detrended=detrended';
                        endIdx = num2cell(cumsum(cellfun(@(x) length(x),currentDemod)));
                        startIdx = num2cell([1; cellfun(@(x) x+1, endIdx(1:end-1))]);
                        
                        dataFit = cellfun(@(x,y) fittedData(x:y), startIdx, endIdx, 'UniformOutput', 0);
                        detrendedData = cellfun(@(x,y) detrended(x:y), startIdx, endIdx, 'UniformOutput', 0);
                        TE.Photometry.data(ch).blInterp_detrended(find(TE.sessionIndex==nSesh),1) = detrendedData;
                        TE.Photometry.data(ch).blInterp_trendFit(find(TE.sessionIndex==nSesh),1) = dataFit;
                    catch
                        
                        TE.Photometry.data(ch).blInterp_detrended(find(TE.sessionIndex==nSesh),1) = cell(length(find(TE.sessionIndex==nSesh)),1);
                        TE.Photometry.data(ch).blInterp_trendFit(find(TE.sessionIndex==nSesh),1) = cell(length(find(TE.sessionIndex==nSesh)),1);
                    end
                end
            end
       
end

%% 3) NORMALIZE TO CONTROL CHANNEL (tdt)

if s(1).tdtControl == 1
    if numChannels>1
        
        TE.Photometry.data(1).tdtControlledDFF  = cell(size(TE.TrialTypes));
        photoDataFields = fieldnames(TE.Photometry.data);
        photoDataFields = photoDataFields(cellfun(@(x) ~contains(x, 'deMod') & ~contains(x, 'Fit'), photoDataFields));
        
        for pField = l:length(photoDataFields)
            for s = 1:nSessions
                x = cell2mat(TE.Photometry.data(2).(photoDataFields{pField})(TE.sessionIndex==s)); %tdt sessionDFF
                y = cell2mat(TE.Photometry.data(1).(photoDataFields{pField})(TE.sessionIndex==s)); %green sessionDFF
                try
                    [b,  stats]= robustfit(x,y);
                    normY = y-[b(1)+b(2)*x]; % subtract regressed data from green channel
                    if stats.p(1)>0.001 %if no significant covariance, omit session
                        TE.Photometry.data(1).tdtControlledDFF(find(TE.sessionIndex==s)) =  cellfun(@(x,y) NaN(y-x,1), startIdx, endIdx, 'UniformOutput', 0);
                    else
                        TE.Photometry.data(1).tdtControlledDFF(find(TE.sessionIndex==s))  = cellfun(@(x,y) normY(x:y), startIdx, endIdx, 'UniformOutput', 0); %subtract regression from green channel
                    end
                catch
                    TE.Photometry.data(1).tdtControlledDFF(find(TE.sessionIndex==s))  =  cellfun(@(x,y) NaN(y-x,1), startIdx, endIdx, 'UniformOutput', 0);
                end
            end
        end
        
    else
        disp('There is only one photometry channel')
    end
end

% nested functions: 
    function newX = makeNaN(x,y)
        x(y,1)=nan;
        newX =x;
    end

    function decimated = getDecimated(x, DecimateFactor, artifact_nSamples)
        if isfinite(x) & ~isnan(x)
            decimated(:,1) = decimate(x, DecimateFactor);
        else
            decimated(:,1) = NaN(artifact_nSamples*2,1);
        end
    end
end
