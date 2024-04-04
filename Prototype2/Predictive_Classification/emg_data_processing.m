emg = readtable("elbow_flex_ext/elbow_flex_from90_Proprioception_Tests_Rep_1.2 - elbow_flex_from90_Proprioception_Tests_Rep_1.2.csv");
imu = readtable("elbow_flex_ext/elbow_t1.csv");

%% 1 = bicep IMU, 2 = wrist IMU
t = linspace(0, 55, size(imu.Time,1));

figure; plot(t, imu.ax1)
hold on; plot(t, imu.ay1)
hold on; plot(t, imu.az1)
% hold on; plot(t, imu.gx1)
% hold on; plot(t, imu.gy1)
% hold on; plot(t, imu.gz1)
% legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
legend('ax', 'ay', 'az');

%%

figure; plot(t, imu.ax2)
hold on; plot(t, imu.ay2)
hold on; plot(t, imu.az2)
% hold on; plot(t, imu.gx2)
% hold on; plot(t, imu.gy2)
% hold on; plot(t, imu.gz2)
% legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
legend('ax', 'ay', 'az');

%% EMG1 = bicep, EMG2 = tricep
figure; plot(emg.X_s_, emg.AvantiSensor1_EMG1)
hold on; plot(emg.X_s_, emg.AvantiSensor2_EMG2)
legend('bicep', 'tricep');

%%
adj_ind = find(t>6.5);
t_adj = t(adj_ind)-t(adj_ind(1));

fc = 200; % cutoff, Hz
fs = 5000; % sampling, Hz
n_order = 2;

[b,a] = butter(n_order, fc/(fs/2));
bicep_filt = filtfilt(b, a, emg.AvantiSensor1_EMG1); 

figure; plot(emg.X_s_, bicep_filt*100000)
hold on; plot(t_adj, imu.ay2(adj_ind))
hold on; plot(t_adj, imu.az2(adj_ind))
legend('bicep', 'ay', 'az');

