
function windowLickEvents = plotTrialLickRaster(TE, selectTrials, varargin)

defaults = {...
    'alignTo', 'SoundCue';... %when you want events to be aligned
    'window', [0 20];...%window containing lick events
    };
[s, ~] = parse_args(defaults, varargin{:});

nTrials = sum(selectTrials);

alignedLickEvents = cellfun(@(x,y) y-x(1,1), TE.(s.alignTo)(selectTrials), TE.Port1In(selectTrials), 'UniformOutput',false);
windowLickEvents = cellfun(@(x) x(x>s.window(1) & x<s.window(2)), alignedLickEvents, 'UniformOutput',false);

tiles = tiledlayout( 'vertical' ,'TileSpacing', 'tight', 'Padding', 'compact');
for n = 1:nTrials
    nexttile
    xline(windowLickEvents{n});
    yticks([])
    xticklabels([])
end


xlabel(tiles, 'Lick Times (s)')
ylabel(tiles, 'Trial')
xticklabels(num2str([s.window(1):s.window(2)]'))
set(gca, 'FontName', 'Arial', 'TickLength', [0.04 0.04], 'LineWidth', 0.25, 'TickDir','out', 'box', 'off', 'FontSize', 20);

end



