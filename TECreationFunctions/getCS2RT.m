%% getCS2RT
% Generate array of reaction times to CS2 (second light, for reward
% retrieval). Will count no reactions (ie, max duration of CS2 elapsed) 
% as NaNs.
% Input requirement - TE struct with 'animalID' field generated from 
% getAnimalNames function

function CS2RT = getCS2RT(TE)

animals = unique(TE.animalID);
nAnimals = length(animals);
nTrials = length(TE.animalID);

CS2RT = NaN(nTrials,1); %initialize output

empties = cell2mat(cellfun(@(x) isnan(x(1)), TE.CS2, 'UniformOutput', false)); % find empty cells in case CS2
% state doesn't exist

CS2RT(~empties) = cell2mat(cellfun(@(x) diff(x), TE.CS2(~empties), 'UniformOutput', false));

CS2RT(empties) = NaN;

% get max duration of CS2 per animal (when mouse does not retrieve reward,
% duration of CS2 will be the pre-set maximum. This changed across time
% (from 5 to 3s), therefore you need to determine what the max was for each
% animal

maxCS2RT = zeros(nTrials,1);

for a = 1:nAnimals
    trials = contains(TE.animalID,animals{a});

    % for some reason, the max duration can return as x or x.000, which is 
    % not equivalent in MATLAB so I substract 0.001 and select for 
    % durations above that
    tempMax = max(CS2RT(trials)) - 0.001; 
    maxedTrials = trials & CS2RT > tempMax;
    maxCS2RT(maxedTrials) = 1;
end

% Replace max CS2RT durations with NaN, since mouse did not retrieve reward
CS2RT(maxCS2RT==1) = NaN;

end