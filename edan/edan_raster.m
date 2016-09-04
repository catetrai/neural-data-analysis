function edan_raster(neuronsSpikes, stimulusDirections, neuronNumber, mode, varargin)
% function edan_raster(neuronsSpikes, stimulusDirections, neuronNumber, mode, direction)
%
% Produces a raster plot of one neuron. Can run in two modes:
%
% MODE '1': raster plot showing all 100 trials of one stimulus condition.
%           'direction' input argument must specified.
% MODE '2': raster plot of 10 trials (equally spaced) of all stimulus directions.
%           The plot has 'stimulus condition' on the y-axis. No optional
%           input argument to be specified.
%
% INPUT: 'neuronsSpikes' is the sorted, non-binned spike times data
%           (neurons.spikesSorted cell array).
%        'stimulusDirections' is the vector of sorted directions for all
%           1600 trials.

switch mode
    case 1
        direction = varargin{1};
        trialsInd = find(stimulusDirections==direction);
        
        figure;
        for i = 1:length(trialsInd)
            if ~isempty(neuronsSpikes{neuronNumber,trialsInd(i)})
                plot(neuronsSpikes{neuronNumber,trialsInd(i)}, i, '.k')
                hold on
            end
        end
        ylim([-1 101])
        plot([0 0],[-1 101],'-r')    % indicate stimulus onset and offset
        plot([2000 2000],[-1 101],'-r')
        ylabel('Trial #')
        title(['Raster plot of neuron ',num2str(neuronNumber),' (stimulus direction ',num2str(direction),' deg)'])
    
    case 2
        trialsInd = 5 : 10 : 1600-5; % take one every 10 trials (total of 10 trials per condition)
        figure;
        
        for i = 1:length(trialsInd)
            if ~isempty(neuronsSpikes{neuronNumber,trialsInd(i)})
                plot(neuronsSpikes{neuronNumber,trialsInd(i)}, i, '.k')
                hold on
            end
        end
        ylim([-1 161]);
        set(gca, 'YTick', 5 : 10 : 16*10-5, 'YTickLabel', cellstr(num2str(unique(stimulusDirections))));
        plot([0 0],[-1 161],'-r')    % indicate stimulus onset and offset
        plot([2000 2000],[-1 161],'-r')
        ylabel('Stimulus direction (degrees)')
        title(['Raster plot of neuron ',num2str(neuronNumber)])
end

% common plot specs
xlim([-500 2500])
xlabel('Time relative to stimulus onset (ms)')

end