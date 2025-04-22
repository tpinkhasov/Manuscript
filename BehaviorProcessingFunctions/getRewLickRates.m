function rewLR = getRewLickRates(TE, varargin)

defaults = {...
    'rewardPeriod', 2;...%(s) how long do you consider the reward period?
    };
[s, ~] = parse_args(defaults, varargin{:});

lickInfo_Reward = getCorrectedInterLicks(TE, cellfun(@(x) x(2), TE.CS2,  'UniformOutput', false), cellfun(@(x) x(2)+s.rewardPeriod, TE.CS2,  'UniformOutput', false), 0.05);
rewLR = cell2mat(cellfun(@(x,y) sum(x>y(2) & x<((y(2)+s.rewardPeriod)))./s.rewardPeriod, lickInfo_Reward.realLicks, TE.CS2, 'UniformOutput', false));

end