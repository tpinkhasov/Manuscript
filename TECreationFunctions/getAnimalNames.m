function animalID = getAnimalNames(TE)

%Assumes you have filenames saved in struct
filenames = unique(TE.filename);

idx = cellfun(@(x) strfind(x,'LW'), filenames);
animalID = cellfun(@(x,y) x(1:y-2), filenames, num2cell(idx), 'UniformOutput', false);
end