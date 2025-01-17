function demod = demodulateTrial_TP(rawData, refData, sampleRate, modAmp, modFreq, lowpass)

% pre-allocate data
nSamples = length(rawData);
dt = 1/sampleRate;
t = (0:dt:(nSamples - 1) * dt);
t = t(:);

%%% remove and index nans from raw data
% demod = NaN(size(rawData));
% nanIdx = (isnan(rawData));
% rawData(nanIdx==1) = [];
% refData(nanIdx==1) = [];
%% Prepare reference data and generates 90deg shifted ref data
refData             = refData(1:length(rawData),1);   % adjust length of refData to rawData
refData_0           = refData-mean(refData);          % suppress DC offset
samplesPerPeriod    = (1/modFreq)/(1/sampleRate);
quarterPeriod       = round(samplesPerPeriod/4);
refData_90           = circshift(refData_0,[1 quarterPeriod]);

processedData_0 = rawData .* refData_0;
processedData_90 = rawData .* refData_90;

%% filtering
% note-   5 pole Butterworth filter in Matlab used in Frohlich and McCormick
% Create butterworth filter
lowCutoff = lowpass/(sampleRate/2); % filter cutoff normalized to nyquist frequency
[z,p,k] = butter(10, lowCutoff, 'low');
[sos, g] = zp2sos(z,p,k);
if sampleRate<length(processedData_0)
    padStart_0 = flip(processedData_0(1:sampleRate, 1)); % AGV sez: pad with 1s of data, should be in phase as period should be an integer factor of 1 second
    padStart_90 = flip(processedData_90(1:sampleRate, 1)); % AGV sez: pad with 1s of data, should be in phase as period should be an integer factor of 1 second
    
    padEnd_0 = flip(processedData_0(end - sampleRate:end, 1));
    padEnd_90 = flip(processedData_90(end - sampleRate:end, 1));
    
    demodDataFilt_0 = filtfilt(sos, g, [padStart_0; processedData_0; padEnd_0]);
    demodDataFilt_90 = filtfilt(sos, g, [padStart_90; processedData_90; padEnd_90]);
    
    demod_0 = demodDataFilt_0(length(padStart_0) + 1:end - length(padEnd_0) + 1, 1);
    demod_90 = demodDataFilt_90(length(padStart_90)+1:end - length(padEnd_90) + 1, 1);
    
    tempDemod = (demod_0 .^2 + demod_90.^2) .^(1/2); % quadrature decoding
    
    %% Correct for amplitude of reference
    demod=tempDemod*2/modAmp;
    
%     %% re-insert Nans
%     counter=1;
%     for i = 1:length(demod)
%         if nanIdx(i)==0
%             demod(i) = tempDemod(counter);
%             counter = counter+1;
%         else
%             continue
%         end
%     end
else
    demod = NaN;
end
end

