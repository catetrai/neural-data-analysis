function edan_tuning(spikeRates, stimulusDirections, neuronNumber)
% function edan_tuning(spikeRates, stimulusDirections, neuronNumber)
% 
% Produces a plot of firing rates per stimulus condition of one neuron.
% Plots individual trials, the condition mean, and a fitted cosine tuning
% curve. This is computed with the function 'fitCos'.
%
% INPUTS: 'spikeRates' is the firing rates matrix (#neurons x #bins x #trials).
%         'stimulusDirections' is the vector of sorted directions for all
%               1600 trials.


nTrials = length(stimulusDirections);
nDirs = length(unique(stimulusDirections));
nTrialsPerDir = nTrials/nDirs;

ratesPerDir = mean(spikeRates(neuronNumber,:,:), 2);
ratesPerDir = reshape(ratesPerDir, nTrialsPerDir, nDirs);
f = fitCos(unique(stimulusDirections), ratesPerDir);

figure;
h1 = plot(ratesPerDir', '.');
set(h1, 'MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7],...
    'MarkerSize',10);
hold on
h2 = plot(mean(ratesPerDir), '-ko');
h3 = plot(f,'-r');

xlim([0 nDirs+1]);
yheight = get(gca,'YLim');
ylim([-2 yheight(2)]);
set(gca, 'XTick', 1:nDirs, 'XTickLabel', num2str(unique(stimulusDirections)));
title(['Tuning curve of neuron ',num2str(neuronNumber)]);
xlabel('Stimulus direction (degrees)');
ylabel('Firing rate (spikes/s)');
legend([h1(1),h2,h3], 'All trials', 'Mean','Cosine fit');

end