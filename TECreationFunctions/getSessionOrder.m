%% function getSessionOrder
% Get nTrialsx1 array indicating order of sessions in time by date for each animal
% Use getAnimalNames and getFileDates functions to generate correct inputs
function sessionOrder = getSessionOrder(TE)

sessionOrder = NaN(size(TE.sessionDate)); %initialize array
animals = unique(TE.animalID); %get names of all animals

for a = 1:length(animals)
    trials = contains(TE.animalID, animals{a});
    dates = sort(unique(TE.sessionDate(trials)));
    for d = 1:length(dates)
        sessionOrder(trials & TE.sessionDate == dates(d)) = d;
    end
end
end
