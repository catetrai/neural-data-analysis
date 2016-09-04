function [faxis, Sxx] = edan_fftpower(x, Fs, T)
% Computes power spectrum of vector x in decibel scale.
% Fs: sampling frequency. T: total recording time in seconds.

if length(x) == numel(x)    % if x is a vector
    x = x(:);    % turn into column vector
else
    error('X must be a vector')
end

dt = 1/Fs;       % period in seconds
df = 1/T;        % frequency resolution
fNQ = Fs/2;      % nyquist frequency

% optional preprocessing steps
x = hann(length(x)) .* x;     % apply Hanning taper

% dfBin = 0.5;                  % change frequency binning
% faxis = 0 : dfBin : fNQ;
faxis = 0 : df : fNQ;

xf = fft(x);
Sxx = abs(2*dt^2/T * xf.*conj(xf)); % take only magnitude
Sxx = Sxx(1 : length(x)/2+1);
Sxx = Sxx(1 : end/length(faxis) : end);
Sxx = pow2db(Sxx);          % convert power to decibel scale

end