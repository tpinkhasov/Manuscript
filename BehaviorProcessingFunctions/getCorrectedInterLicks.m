function lickInfo = getCorrectedInterLicks(TE, epoch1, epoch2, minILI)

lickIdx = cellfun(@(x,y,z) find(x>y(1,1) & x<z(end,end)), TE.Port1In, epoch1,epoch2, 'UniformOutput', false);

tempLickTimes = cellfun(@(x,y) x(y), TE.Port1In, lickIdx, 'UniformOutput', false);
tempLickTimes(find(cell2mat(cellfun(@(x) isempty(x), tempLickTimes, 'UniformOutput', false))))={NaN};
realLicks = cellfun(@(x) getRealLicks(x, minILI), tempLickTimes, 'UniformOutput', false);
noLickIdx = cellfun(@(x) x(1), (cellfun(@(x) isnan(x(1)),realLicks, 'UniformOutput', false)));

realInterLicks = cellfun(@(x) diff(x), realLicks, 'UniformOutput', false);
realInterLicks(noLickIdx)={NaN};
realInterLicks(cellfun(@(x) isempty(x), realInterLicks))={NaN};

burstIdx = cellfun(@(x) [0, (find(x>0.8))]+1, realInterLicks, 'UniformOutput', false);
burstIdx(noLickIdx)={NaN};

sizeBursts = cellfun(@(x,y) diff([x, length(y)+1]), burstIdx, realLicks, 'UniformOutput', false);

numBursts = cellfun(@(x) length(x), sizeBursts);
numBursts(noLickIdx)=NaN;
for s = 1:20
    burstILI{s,1}= cell(size(numBursts));
end
for trial = 1:length(numBursts)
    if numBursts(trial)>1
        interBursts{trial,1} = realInterLicks{trial}(burstIdx{trial}(2:end)-1);
    else
        interBursts{trial,1} =NaN;
    end
    if ~isnan(numBursts(trial))
        for n = 1:numBursts(trial)
            trackLicks=0;
            for s = 2:sizeBursts{trial}(n)
                burstILI{s-1,1}{trial,1}(n,1) = realInterLicks{trial}(burstIdx{trial}(n)+(trackLicks));
                trackLicks=trackLicks+1;
                
            end
            if sizeBursts{trial}(n) > 1
                firstILI{trial,1}(n) = realInterLicks{trial}(burstIdx{trial}(n));
                lastILI{trial,1}(n) = realInterLicks{trial}(sizeBursts{trial}(n)-2+burstIdx{trial}(n));
                
            else
                firstILI{trial,1}(n)=NaN;
                lastILI{trial,1}(n)=NaN;
            end
        end
    end
end

lickInfo.numBursts = numBursts;
lickInfo.burstIdx = burstIdx;
lickInfo.realInterLicks = realInterLicks;
lickInfo.realLicks = realLicks;
lickInfo.sizeBursts = sizeBursts;
lickInfo.interBursts = interBursts;
lickInfo.burstILI = burstILI;
lickInfo.firstBurstILI = firstILI;
lickInfo.lastBurstILI = lastILI;
lickInfo.noLickTrials = noLickIdx;
end
function realLicks = getRealLicks(lickTimes, minILI)
if ~isempty(lickTimes)
    tempInterLicks = diff(lickTimes);
    % realLicks(1) = lickTimes(1);
    while ~isempty(find(tempInterLicks<minILI))
        tempInterLicks = diff(lickTimes);
        nextIdx = find(tempInterLicks<minILI, 1);
        lickTimes(nextIdx+1)=[];
    end
    realLicks = lickTimes;
end
end
