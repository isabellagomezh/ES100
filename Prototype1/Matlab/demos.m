% Delsys data
data = readtable('demos/Trial4_Plot_and_Store_Rep_1.4.csv');

% define variables
t = data.X_s_(1:6756);
accX = data.AvantiSensor1_ACC_X1(1:6756);
accY = data.AvantiSensor1_ACC_Y1(1:6756);
accZ = data.AvantiSensor1_ACC_Z1(1:6756);
gyroX = data.AvantiSensor1_GYRO_X1(1:6756);
gyroY = data.AvantiSensor1_GYRO_Y1(1:6756);
gyroZ = data.AvantiSensor1_GYRO_Z1(1:6756);


%% plot

figure; plot(t, accX)
hold on; plot(t, accY)
hold on; plot(t, accZ)
hold on; plot(t, gyroX)
hold on; plot(t, gyroY)
hold on; plot(t, gyroZ)
legend('accX', 'accY', 'accZ', 'gyroX', 'gyroY', 'gyroZ')

%% one instance (3.5-4.9 s)
t_short = t(4405:6190);
accX_short = accX(4405:6190);

figure; plot(t_short, accX_short)

%% FFT
Fs = 1/median(diff(t_short));
plotfft(accX_short, Fs);

%% filter
fc = 300; % cutoff, Hz
n_order = 2;

[b,a] = butter(n_order, fc/(Fs/2));
accX_filt = filtfilt(b, a, accX_short);

hold on;plot(t_short, accX_filt);

%% peak finding


%% helper functions
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

