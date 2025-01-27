%% Extract animal names from session filename per trial
%Assumes you have filenames saved in struct
function animalID = getAnimalNames(TE)
idx = cellfun(@(x) strfind(x,'LW'), TE.filename);
animalID = cellfun(@(x,y) x(1:y-2), TE.filename, num2cell(idx), 'UniformOutput', false);
end