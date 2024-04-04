% Load data
data = readtable('heel_50ppm.csv');
data = removevars(data, ["Activity","User","TrialNumber"]);

%% Define variables
t = data.Time(2:end); % Get rid of initial large jump in time
accX = data.accel_X(2:end);
t = (t-t(1)); % Convert to start at 0

% Plot the raw data
figure;plot(t, accX);

%% Pull out the unique indices
% From acceleration
t_unique = find(diff(accX)~=0);
accX_2 = accX(t_unique);
t_2 = t(t_unique);

% Plot the compressed data
hold on;plot(t_2, accX_2);

%% Interpolate data to 100Hz
t_100Hz = round(linspace(0, max(t_2), max(t_2)*100),3);
accX_100Hz = interp1(t_2, accX_2, t_100Hz,'makima');

hold on;plot(t_100Hz, accX_100Hz);

%% Divide into sections based on time jumps
gap_inds = find(isoutlier(diff(t_2)));
for g = 1:numel(gap_inds)
    [~, start_ind] = min(abs(t_100Hz - t_2(gap_inds(g))));
    [~, stop_ind] = min(abs(t_100Hz - t_2(gap_inds(g)+1)));
    t_100Hz(start_ind-1:stop_ind+1) = [];
    accX_100Hz(start_ind-1:stop_ind+1) = [];
end
hold on;plot(t_100Hz, accX_100Hz);

%% Conduct fft
fs_orig = 1/median(diff(t));
fs_2 = 1/median(diff(t_2));
fs_100 = 1/median(diff(t_100Hz));
% plotfft(accX, fs_orig); % accX_fft
% plotfft(accX_2, fs_2); % accX_fft2
plotfft(accX_100Hz, fs_100); % accX_100Hz

%% Helper functions
function plotfft(y, Fs)
L = length(y);    
Y = fft(y);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
hold on; plot(f,P1)
% title('Single-Sided Amplitude Spectrum of Active Data')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
end