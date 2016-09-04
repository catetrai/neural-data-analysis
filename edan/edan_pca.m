function [PC, D, scores, explVar] = edan_pca(dataset, mode, varargin)
% function [PC, D, scores, explVar] = edan_pca(dataset, mode, binEdges, dirs)
%
% MODE '1': performs the first PCA.
%         'dataset' is a #neurons x #timebins matrix.
%         the optional input is a vector of bin edges. this MUST be
%         specified.
% MODE '2': performs the second PCA.
%         'dataset' is a #neurons x #conditions matrix.
%         the optional input is a vector of unique stimulus directions.
%         this MUST be specified.
%
% OUTPUTS: 'PC' is a #neurons x #neurons matrix whose columns are the PCA
%              coefficients for each principal component.
%          'D' is a vector of the variances (sorted in descending order) of
%              each principal component.
%          'scores' are the new coordinates of the data in the principal
%              component space (#observations x #neurons matrix).
%          'explVar' is the percentage of explained variance of each
%              principal component.


% ---------------------------- PERFORM PCA ---------------------------- %
% 1. center the data
datameans = repmat(mean(dataset,2), [1, size(dataset,2)]);
data = dataset - datameans;

% 2. compute covariance matrix Cx of the dataset
N = size(data,2);
Cx = 1/(N-1) * data * data';

% 3. find eigenvectors of covariance matrix
[PC,D] = eig(Cx, 'vector');  % output is vector of eigenvalues
PC = real(PC);
D = real(D);

% 4. compute explained variance of each component
explVar = D/sum(D) * 100;

% 5. project the original dataset onto principal component space
scores = PC'*data;
scores = scores';

% ---------------------------- PCA PLOTS ---------------------------- %

% 1. barplot of percentage explained variance for all PCs
figure;
bar(explVar(1:10), 0.5, 'k')
set(gca, 'XTick', 1:10);
yheight = get(gca,'YLim');
ylim([0 yheight(2)])
xlabel('PC #')
ylabel('% variance explained')
title('Percentage of explained variance of first 10 PCs')

switch mode
    case 1
        % 2. comparison scatterplots: data in the old vs. new basis
        binEdges = varargin{1};
        colors = (1:N)';
        
        figure;
        
        subplot(1,2,1)
        neurons = [5, 12];  % two example neurons
        scatter(dataset(neurons(1),:), dataset(neurons(2),:), [], colors, 'filled')
        title('Original basis')
        xlabel(['Firing rate neuron ', num2str(neurons(1)), ' (spikes/s)'])
        ylabel(['Firing rate neuron ', num2str(neurons(2)), ' (spikes/s)'])

        subplot(1,2,2)
        scatter(scores(:,1), scores(:,2), [], colors, 'filled')
        colormap(jet);
        title('Principal component space')
        xlabel(['PC 1 (', num2str(round(explVar(1),1)), '% explained var.)'])
        ylabel(['PC 2 (', num2str(round(explVar(2),1)), '% explained var.)'])
        c = colorbar;
        c.Label.String = 'Time relative to stimulus onset (ms)';
        c.Ticks = 1 : 5 : length(binEdges);
        c.TickLabels = binEdges(1 : 5 : end);
        
        % 3. extracted features (time course 'seen' from the latent variables,
        % i.e. the first few PCs)
        nPCs = 4;       % choose how many PCs to consider
        
        figure;
        subplot(1,nPCs,1);
        plot(binEdges(1:end-1)+25, scores(:,1),'k-')
        xlim([binEdges(1), binEdges(end)])
        title('PC 1')
        xlabel('Time relative to stimulus onset (ms)')
        ylabel('Score')
        subplot(1,nPCs,2);
        plot(binEdges(1:end-1)+25, scores(:,2),'k-')
        xlim([binEdges(1), binEdges(end)])
        title('PC 2')
        subplot(1,nPCs,3);
        plot(binEdges(1:end-1)+25, scores(:,3),'k-')
        xlim([binEdges(1), binEdges(end)])
        title('PC 3')
        subplot(1,nPCs,4);
        plot(binEdges(1:end-1)+25, scores(:,4),'k-')
        xlim([binEdges(1), binEdges(end)])
        title('PC 4')
        
    case 2
        % 2. comparison scatterplots: data in the old vs. new basis
        dirs = varargin{1};

        cmap = [repmat([1,0.5,0.3], N/4, 1); repmat([1,0,0], N/4, 1); ...
            repmat([1,0.3,0.5], N/4, 1); repmat([1,0.5,0.8], N/4, 1)] ...
            .* repmat([(0.35:0.2:1)'; flip((0.35:0.2:1)')], 2, 3);
        colors = (1:N)';    % colormap for the circular colorbar
        
        figure;
        subplot(1,3,1)
        neurons = [5, 12];  % two example neurons
        scatter(dataset(neurons(1),:), dataset(neurons(2),:), 70, colors, 'filled')
        colormap(cmap);
        title('Original basis')
        xlabel(['Firing rate neuron ', num2str(neurons(1)), ' (spikes/s)'])
        ylabel(['Firing rate neuron ', num2str(neurons(2)), ' (spikes/s)'])
        
        subplot(1,3,2)
        scatter(scores(:,1), scores(:,2), 70, colors, 'filled')
        colormap(cmap);
        title('Principal component space')
        xlabel(['PC 1 (', num2str(round(explVar(1),1)), '% explained var.)'])
        ylabel(['PC 2 (', num2str(round(explVar(2),1)), '% explained var.)'])
        
        subplot(1,3,3)
        labels = cellstr(num2str(flip(dirs)));
        p = pie(ones(1,N), labels);     % circular colorbar
        
        % 3. extracted features (tuning profile)
        figure;
        subplot(1,4,1);
        plot(dirs, scores(:,1),'-k')
        xlim([dirs(1), dirs(end)])
        title('PC 1')
        xlabel('Stimulus direction (degrees)')
        ylabel('Score')
        set(gca, 'XTick', dirs(1:2:end));
        yheight = get(gca,'YLim');
        
        subplot(1,4,2);
        plot(dirs, scores(:,2),'-k')
        xlim([dirs(1), dirs(end)])
        ylim(yheight)
        set(gca, 'XTick', dirs(1:2:end));
        title('PC 2')
        
        subplot(1,4,3);
        plot(dirs, scores(:,3),'-k')
        xlim([dirs(1), dirs(end)])
        ylim(yheight)
        set(gca, 'XTick', dirs(1:2:end));
        title('PC 3')
        
        subplot(1,4,4);
        plot(dirs, scores(:,4),'-k')
        xlim([dirs(1), dirs(end)])
        ylim(yheight)
        set(gca, 'XTick', dirs(1:2:end));
        title('PC 4')        
end

end