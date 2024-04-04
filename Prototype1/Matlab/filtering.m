% Load data
data = readtable('data/toe_rev_80ppm.csv');
data = removevars(data, ["Activity","User","TrialNumber"]);

%% Define variables
t = data.Time(2:end); % Get rid of initial large jump in time
accX = data.accel_X(2:end);
accY = data.accel_Y(2:end);
accZ = data.accel_Z(2:end);
gyroX = data.gyro_X(2:end);
gyroY = data.gyro_Y(2:end);
gyroZ = data.gyro_Z(2:end);
t = (t-t(1)); % Convert to start at 0

% Plot the raw data
figure;plot(t, accX);
hold on;plot(t, accY);
hold on;plot(t, accZ);

hold on;plot(t, gyroX);
hold on;plot(t, gyroY);
hold on;plot(t, gyroZ);
legend('x', 'y', 'z', 'gx', 'gy', 'gz');

%% Pull out the unique indices
% From X-acceleration
t_unique = find(diff(accX)~=0);
accX_2 = accX(t_unique);
t_2 = t(t_unique);

% Plot the compressed data
hold on;plot(t_2, accX_2);

%% From Y-accel
t_unique = find(diff(accY)~=0);
accY_2 = accY(t_unique);
t_2Y = t(t_unique);

% Plot the compressed data
hold on;plot(t_2Y, accY_2);

%% From Z-accel
t_unique = find(diff(accZ)~=0);
accZ_2 = accZ(t_unique);
t_2Z = t(t_unique);

% Plot the compressed data
hold on;plot(t_2Z, accZ_2);
legend('x', 'y', 'z');

%% From X-gyro
t_unique = find(diff(gyroX)~=0);
gyroX_2 = gyroX(t_unique);
t_2gX = t(t_unique);

% Plot the compressed data
figure;plot(t_2gX, gyroX_2);

%% From Y-gyro
t_unique = find(diff(gyroY)~=0);
gyroY_2 = gyroY(t_unique);
t_2gY = t(t_unique);

% Plot the compressed data
hold on;plot(t_2gY, gyroY_2);

%% From Z-gyro
t_unique = find(diff(gyroZ)~=0);
gyroZ_2 = gyroZ(t_unique);
t_2gZ = t(t_unique);

% Plot the compressed data
hold on;plot(t_2gZ, gyroZ_2);
legend('x', 'y', 'z');

%% Interpolate data to 100Hz
t_100Hz = round(linspace(0, max(t_2), max(t_2)*100),3);
accX_100Hz = interp1(t_2, accX_2, t_100Hz,'makima');
accY_100Hz = interp1(t_2Y, accY_2, t_100Hz,'makima');
accZ_100Hz = interp1(t_2Z, accZ_2, t_100Hz,'makima');
gyroX_100Hz = interp1(t_2gX, gyroX_2, t_100Hz,'makima');
gyroY_100Hz = interp1(t_2gY, gyroY_2, t_100Hz,'makima');
gyroZ_100Hz = interp1(t_2gZ, gyroZ_2, t_100Hz,'makima');

figure;plot(t_100Hz, accX_100Hz);
hold on;plot(t_100Hz, accY_100Hz);
hold on;plot(t_100Hz, accZ_100Hz);
legend('x', 'y', 'z');

figure;plot(t_100Hz, gyroX_100Hz);
hold on;plot(t_100Hz, gyroY_100Hz);
hold on;plot(t_100Hz, gyroZ_100Hz);
legend('x', 'y', 'z');

%% Cut off start
t_100Hz = t_100Hz(12:end);
accX_100Hz = accX_100Hz(12:end);
accY_100Hz = accY_100Hz(12:end);
accZ_100Hz = accZ_100Hz(12:end);
gyroX_100Hz = gyroX_100Hz(12:end);
gyroY_100Hz = gyroY_100Hz(12:end);
gyroZ_100Hz = gyroZ_100Hz(12:end);

figure;plot(t_100Hz, accX_100Hz);
hold on;plot(t_100Hz, accY_100Hz);
hold on;plot(t_100Hz, accZ_100Hz);
legend('x', 'y', 'z');

figure;plot(t_100Hz, gyroX_100Hz);
hold on;plot(t_100Hz, gyroY_100Hz);
hold on;plot(t_100Hz, gyroZ_100Hz);
legend('x', 'y', 'z');

%% Divide into sections based on time jumps
gap_inds = find(isoutlier(diff(t_2)));
t_100Hz_accX = t_100Hz;
for g = 1:numel(gap_inds)
    [~, start_ind] = min(abs(t_100Hz_accX - t_2(gap_inds(g))));
    [~, stop_ind] = min(abs(t_100Hz_accX - t_2(gap_inds(g)+1)));
    t_100Hz_accX(start_ind-1:stop_ind+1) = [];
    accX_100Hz(start_ind-1:stop_ind+1) = [];
end
hold on;plot(t_100Hz_accX, accX_100Hz);

%% Y-accel gaps
gap_inds = find(isoutlier(diff(t_2Y)));
for g = 1:numel(gap_inds)
    [~, start_ind] = min(abs(t_100Hz - t_2Y(gap_inds(g))));
    [~, stop_ind] = min(abs(t_100Hz - t_2Y(gap_inds(g)+1)));
    t_100Hz(start_ind-1:stop_ind+1) = [];
    accY_100Hz(start_ind-1:stop_ind+1) = [];
end
hold on;plot(t_100Hz, accY_100Hz);

%% Z-accel gaps
gap_inds = find(isoutlier(diff(t_2Z)));
for g = 1:numel(gap_inds)
    [~, start_ind] = min(abs(t_100Hz - t_2Z(gap_inds(g))));
    [~, stop_ind] = min(abs(t_100Hz - t_2Z(gap_inds(g)+1)));
    t_100Hz(start_ind-1:stop_ind+1) = [];
    accZ_100Hz(start_ind-1:stop_ind+1) = [];
end
hold on;plot(t_100Hz, accZ_100Hz);

%% Detrend
accX_100Hz_det = detrend(accX_100Hz);

hold on;plot(t_100Hz, accX_100Hz_det);

%% Conduct fft of detrended
fs_orig = 1/median(diff(t));
fs_2 = 1/median(diff(t_2));
fs_100 = 1/median(diff(t_100Hz));
% plotfft(accX, fs_orig); % accX_fft
% plotfft(accX_2, fs_2); % accX_fft2
plotfft(accX_100Hz_det, fs_100); % accX_100Hz


%% Apply Butterworth filter
fc = 10; % cutoff, Hz
fs = 100; % sampling, Hz
n_order = 2;

[b,a] = butter(n_order, fc/(fs/2));
accX_filt = filtfilt(b, a, accX_100Hz_det);

hold on;plot(t_100Hz, accX_filt);

%% Moving mean X
M_accX = movmean(accX_filt,21);

hold on;plot(t_100Hz, M_accX);
yline(2);
yline(-2);
yline(0)

%% Moving mean  Xderivative
M_accX_d = diff(M_accX);

hold on;plot(t_100Hz(2:end), M_accX_d);

%% Gyro analysis

% Detrend
gyroX_det = detrend(gyroX_100Hz);
gyroY_det = detrend(gyroY_100Hz);
gyroZ_det = detrend(gyroZ_100Hz);

figure;plot(t_100Hz,gyroX_det);
hold on;plot(t_100Hz,gyroY_det);
hold on;plot(t_100Hz,gyroZ_det);
legend('x', 'y', 'z');

%% FFTs
% fs_orig = 1/median(diff(t));
% fs_2 = 1/median(diff(t_2));
fs_100 = 1/median(diff(t_100Hz));

plotfft(gyroX_det, fs_100);
plotfft(gyroY_det, fs_100);
plotfft(gyroZ_det, fs_100);

%% Filter
fc = 20; % cutoff, Hz
fs = 100; % sampling, Hz
n_order = 2;

[b,a] = butter(n_order, fc/(fs/2));
gyroX_filt = filtfilt(b, a, gyroX_det);
gyroY_filt = filtfilt(b, a, gyroY_det);
gyroZ_filt = filtfilt(b, a, gyroZ_det);

figure;plot(t_100Hz, gyroX_filt);
hold on;plot(t_100Hz, gyroY_filt);
hold on;plot(t_100Hz, gyroZ_filt);
legend('gyro X', 'gyro Y', 'gyro Z')

%% FFTs

plotfft(gyroX_filt, fs_100);
plotfft(gyroY_filt, fs_100);
plotfft(gyroZ_filt, fs_100);

%% Moving mean
M_gyroX = movmean(gyroX_filt,21);
M_gyroY = movmean(gyroY_filt,21);
M_gyroZ = movmean(gyroZ_filt,21);

figure;plot(t_100Hz, M_gyroX);
hold on;plot(t_100Hz, M_gyroY);
hold on;plot(t_100Hz, M_gyroZ);
legend('gyro X', 'gyro Y', 'gyro Z')

%% Find peaks for Z
[pks,locs, w, p] = findpeaks(M_gyroZ, MinPeakDistance=40, MinPeakHeight=1.1*mean(abs(M_gyroZ)));

figure;plot(t_100Hz, M_gyroZ);
% hold on;plot(t_100Hz,gyroZ_filt)
hold on;scatter(t_100Hz(locs),pks);
% [dpks, dlocs, dw, dp] = findpeaks(diff(gyroZ_filt));
% 
% hold on;plot(t_2gZ(2:end), diff(gyroZ_filt));
% hold on;scatter(t_2gZ(dlocs),dpks);

%% Find peaks for X
[pksX,locsX, wX, pX] = findpeaks(M_gyroX, MinPeakDistance=40, MinPeakHeight=1.1*mean(abs(M_gyroX)));

% distance: take fastest tempo + convert to sampling
% maybe don't rectify

hold on;plot(t_100Hz, M_gyroX);
hold on;scatter(t_100Hz(locsX),pksX);

%% Find peaks for Y
[pksY,locsY, wY, pY] = findpeaks(M_gyroY, MinPeakDistance=35, MinPeakHeight=1.1*mean(abs(M_gyroX)));

hold on;plot(t_100Hz, M_gyroY);
hold on;scatter(t_100Hz(locsY),pksY);

legend('gyro Z', 'gyro Z peaks', 'gyro X', 'gyro X peaks', 'gyro Y', 'gyro Y peaks')

%% Average bounds for 3 gyros to find event bounds
Zbounds = zeros(length(locs)*2,1);

for i = 1:length(locs)
    Zbounds(2*i-1) = round(locs(i)-w(i));
    Zbounds(2*i) = round(locs(i)+w(i));
end

Xbounds = zeros(length(locsX)*2,1);

for i = 1:length(locsX)
    Xbounds(2*i-1) = t_100Hz(round(locsX(i)-wX(i)));
    Xbounds(2*i) = t_100Hz(round(locsX(i)+wX(i)));
end

Ybounds = zeros(length(locsY)*2,1);

for i = 1:length(locsY)
    Ybounds(2*i-1) = t_100Hz(round(locsY(i)-wY(i)));
    Ybounds(2*i) = t_100Hz(round(locsY(i)+wY(i)));
end

%% mean of each signal for each event
means = zeros(length(locs), 3);
gyros = [M_gyroZ; M_gyroX; M_gyroY].';

for i = 1:length(locs)
    for j = 1:3
        means(i,j) = mean(gyros(Zbounds(2*i-1):Zbounds(2*i),j));
    end  
end

% peak freq for event?

%% filtered final plot
M_accX = movmean(aX_filt,21);
M_accY = movmean(aY_filt,21);
M_accZ = movmean(aZ_filt,21);
M_gyroX = movmean(gyroX_filt,21);
M_gyroY = movmean(gyroY_filt,21);
M_gyroZ = movmean(gyroZ_filt,21);

hold on;plot(t_100Hz, M_accX);
hold on;plot(t_100Hz, M_accY);
hold on;plot(t_100Hz, M_accZ);
hold on;plot(t_100Hz, M_gyroX);
hold on;plot(t_100Hz, M_gyroY);
hold on;plot(t_100Hz, M_gyroZ);
legend('x', 'y', 'z', 'gx', 'gy', 'gz');

%%
% figure;plot(Zbounds);
% hold on;plot(Xbounds);
% hold on;plot(Ybounds);
% legend('z','x','y')

plotfft(M_gyroY((locsY(3)-wY(3)):(locsY(3)+wY(3))), fs_100);

%% Normalize for AHAP
pks_norm = normalize(pks, 'range');

%% export times, peaks
writematrix([t_2gZ(locs),pks_norm],'peaks.csv')

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
