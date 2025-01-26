function [allLickTimes, fs] = plot_lickAutocovariance(TE, animals, timeWin)

%% plot_lickAutocovariance
% Plots color map of premature lick autocovariances for each animal
% colormap scale generated for each individual animal (will not be exactly
% the same across animals but will be very similar)
% Colormap borrowed from slanCM
% animals - should be list of chars
for a = 1:length(animals)
    trials = contains(TE.animalID, animals{a}) & TE.lickInfo_tone.noLickTrials == 0;
    licks = cellfun(@(x, z) x-z(1,1), TE.lickInfo_tone.realLicks(trials), TE.SoundCue(trials), 'UniformOutput', false); %Get time of premature licks from tone onset for each trial

    %Generate matrix of time series with premature lick events
   % timeWin = 0.01; %desired window of time in s between time bins
    bins = [0:timeWin:30]; %Generate time bins between 0 and 30s with specified timeWin
    fs = 1/timeWin; %sample rate
    lickTimes = zeros(length(licks), length(bins));
    Y = cellfun(@(x) discretize(x, bins), licks, 'UniformOutput', false);
    for l = 1:length(licks)
        for n = 1:length(Y{l})
            if ~isnan(Y{l}(n))
                lickTimes(l, Y{l}(n)) = 1;
            end
        end
    end

    allLickTimes(a,:) = sum(lickTimes);
    %Get autocovariance of the summation of lick times (ie, the number of
    %licks that occur per time bin)
    tCov = 10; %What window of time in seconds do you want to focus on?
    [autocorr, lags]=xcov(sum(lickTimes), tCov*fs, 'coeff'); %'coeff' normalizes so autocovariance at lag 0 is 1
    allCorr(a,:) = autocorr;
end

% Plotting
figure()
for a = 1:length(animals)
    subplot(length(animals),1,a)
    imagesc([-tCov tCov], [1 1],allCorr(a,:))
    set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'ytick', [], 'xtick', []);
    colorList = slanCM('seasons_s'); %generate colormap
    colormap(colorList);
    ylabel(animals{a})
end
set(gca,'LineWidth',1,'TickDir','out', 'box', 'off', 'ytick', [], 'xtick', [-tCov:2:tCov]);
xlabel('Lag (s)')
end