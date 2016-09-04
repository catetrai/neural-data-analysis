function edan_psth(spikeRates, stimulusDirections, binEdges, mode, varargin)
% function edan_psth(spikeRates, stimulusDirections, binEdges, mode, neuronNumber, direction)
%
% Produces PSTH of trial-averaged binned firing rates. Can run in two modes:
%
% MODE '1': Classic PSTH of one neuron.
%           This mode has the following optional inputs:
%           - varargin{1} is the neuron chosen for the PSTH.
%           - varargin{2} is the stimulus direction (condition) of the
%           trials to consider. If this input is not specified, the PSTH is
%           computed by averaging over all trials.
% MODE '2': Population PSTH visualised as color map of trial-averaged
%           firing rates of all neurons. Neurons (rows of the color map)
%           are sorted by overall mean firing rate.
%           This mode has only one optional input:
%           - varargin{1} is the stimulus direction (condition) of the
%           trials to consider. If this input is not specified, the
%           population PSTH is computed by averaging over all trials.
%
% INPUTS: 'spikeRates' is the firing rates matrix (#neurons x #bins x #trials).
%         'stimulusDirections' is the vector of sorted directions for all
%               1600 trials.
%         'binEdges' is a row vector of bin edges.


switch mode
    case 1
        neuron = varargin{1};
        if nargin>5     % if stimulus condition is specified
            direction = varargin{2};
            trialsInd = find(stimulusDirections==direction);
            rates = mean(spikeRates(neuron,:,trialsInd), 3);
        else
            rates = mean(spikeRates(neuron,:,:),3);
        end
        figure;
        bar(binEdges(1:end-1)+25, rates, 1, 'k')
        title(['PSTH of neuron ',num2str(neuron)])
        xlabel('Time relative to stimulus onset (ms)')
        ylabel('Firing rate (spikes/s)')
        hold on
        yheight = get(gca,'YLim');
        plot([0 0], yheight, '--r')
        plot([2000 2000], yheight, '--r')
    case 2
        if nargin>4     % if stimulus condition is specified
            direction = varargin{1};
            trialsInd = find(stimulusDirections==direction);
            rates = mean(spikeRates(:,:,trialsInd), 3);
            dirORavg = ['(stimulus direction ',num2str(direction),' degrees)'];
        else
            rates = mean(spikeRates,3);
            dirORavg = '(averaged over stimulus conditions)';
        end
        [~, ratesSortInd] = sort(mean(rates,2));
        figure;
        imagesc(rates(ratesSortInd,:));
        title(['Firing rates of all neurons ', dirORavg])
        set(gca, 'YDir', 'normal', 'XTick', 1:5:(length(binEdges)-1)+5, 'XTickLabel', binEdges(1:5:end));
        xlabel('Time relative to stimulus onset (ms)')
        ylabel('Neuron #')
        colormap(jet);
        c = colorbar;
        c.Label.String = 'Firing rate (spikes/s)';
end

end