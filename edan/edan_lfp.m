function varargout = edan_lfp(lfpDataInput, lfpT, Fs, stimulusDirection, stimulusOnsets, tetrode, varargin)
% function [lfpMatrix, x, xf, Sxx] = edan_lfp(lfpDataInput, lfpT, Fs, stimulusDirection, stimulusOnsets, tetrode, direction)
%
% Computes Fourier transform of LFP time series of one tetrode. Produces
% power spectrum plot. If no varargin is specified,  averages across all
% trials. Otherwise, averages across trials of only the condition of the
% specified stimulus direction.
%
% Input data is the raw dataset structure variables.


preStim = 500;
postStim = 500;
stimDuration = 2000;
trialDuration = 3*Fs;   % 3 seconds total time * sampling freq
nTrials = length(stimulusOnsets);

[dirsSort, sortInd] = sort(stimulusDirection);
stimOnsSort = stimulusOnsets(sortInd);


% create LFP DATA MATRIX (3*fs x #trials)
lfpData = zeros(trialDuration, nTrials);
for j = 1 : nTrials
    filter = (lfpT >= stimOnsSort(j) - preStim) &...
        (lfpT <= stimOnsSort(j) + stimDuration + postStim);
    lfpData(:,j) = lfpDataInput(filter, tetrode);
end

if nargin > 6   % if stimulus condition is specified
    direction = varargin{1};
    lfpData = lfpData(:, dirsSort == direction);
end

x = mean(lfpData,2);    % data on which we compute FFT
T = 3;                  % total recording time in seconds
[faxis, Sxx] = edan_fftpower(x, Fs, T);

% -------------------- POWER SPECTRUM PLOT -------------------- %
% figure;
% plot(faxis, Sxx);
% xlim([0 10])
% xlabel('Frequency (Hz)')
% ylabel('Power (dB)')
% title(['Power spectrum of trial-averaged LFP (tetrode #',num2str(tetrode),')'])


% -------------------- TIME-FREQUENCY ANALYSIS -------------------- %
winSizeMsec = 100;
winSize = winSizeMsec/1000 * Fs;   % window size in datapoints
overlapPoint = 1/2;                % overlap (hard-coded)
nWin = 2 * length(x)/winSize - 1;

% check that the window size fits the length of the data
while mod(length(x), winSize) ~= 0
    winSize = winSize + 1;
end

% timefreqData = zeros(length(x)/nWin, nWin);
winEdgesInd = 1 : winSize/2 : length(x);
for i = 1 : nWin
    winData = x(winEdgesInd(i) : winEdgesInd(i) + winSize/2);
    [faxis, timefreqData(:,i)] = edan_fftpower(winData, Fs, T);
end

% == FIX ===
imagesc(real(flip(timefreqData)));
set(gca, 'XTickLabel', cellstr(x(str2double(get(gca,'XTickLabel')))));

% baseline normalization? (plot decibel-normalized power)


% -------------------- optional outputs -------------------- %
if nargout > 0
    varargout{1} = lfpData;
    if nargout > 1
        varargout{2} = x;
        if nargout > 2
            varargout{3} = xf;
            if nargout > 3
                varargout{4} = Sxx;
            end
        end
    end
end


end