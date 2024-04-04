% data = readtable("class_data_labeled3/elbow_ext_flex1.csv");

data = readtable("final_tests/jerry_elbow1_500g.csv");

data2 = readtable("final_tests/jerry_elbow1.csv");

data3 = readtable("final_tests/jerry_elbow_90Hz.csv");
%% matrix rotation
% R = [0 1 0 0 0 0; -1 0 0 0 0 0; 0 0 1 0 0 0; 0 0 0 0 1 0; 0 0 0 -1 0 0; 0 0 0 0 0 1];
% imu = [data2.aX, data2.aY, data2.aZ, data2.gX, data2.gY, data2.gZ];

R = [0 -1 0; 1 0 0; 0 0 1];
imu = [data2.aX, data2.aY, data2.aZ];

rot_imu = (imu * R')';

%%
figure; plot(data2.Time, data2.aX)
hold on; plot(data2.Time, data2.aY)
hold on; plot(data2.Time, data2.aZ)
hold on; plot(data2.Time, data2.gX)
hold on; plot(data2.Time, data2.gY)
hold on; plot(data2.Time, data2.gZ)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Elbow Extension/Flexion')

%%
figure; plot(data.Time(1:1065), data.aX(1:1065))
hold on; plot(data.Time(1:1065), data.aY(1:1065))
hold on; plot(data.Time(1:1065), data.aZ(1:1065))
hold on; plot(data.Time(1:1065),figure; plot(data2.Time, data2.aX) data.gX(1:1065))
hold on; plot(data.Time(1:1065), data.gY(1:1065))
hold on; plot(data.Time(1:1065), data.gZ(1:1065))
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Elbow Extension/Flexion with 500g Load')

%%
figure; plot(data3.Time(169:end), data3.aX(169:end))
hold on; plot(data3.Time(169:end), data3.aY(169:end))
hold on; plot(data3.Time(169:end), data3.aZ(169:end))
hold on; plot(data3.Time(169:end), data3.gX(169:end))
hold on; plot(data3.Time(169:end), data3.gY(169:end))
hold on; plot(data3.Time(169:end), data3.gZ(169:end))
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Elbow Extension/Flexion with 90Hz Vibration')

%% filtering

fc = 3; % cutoff, Hz
fs = 55; % sampling, Hz
n_order = 6;

[b,a] = butter(n_order, fc/(fs/2));

aX1 = filtfilt(b, a, data3.aX(169:end));
aY1 = filtfilt(b, a, data3.aY(169:end));
aZ1 = filtfilt(b, a, data3.aZ(169:end));
gX1 = filtfilt(b, a, data3.gX(169:end));
gY1 = filtfilt(b, a, data3.gY(169:end));
gZ1 = filtfilt(b, a, data3.gZ(169:end));

figure; plot(data3.Time(169:end), aX1)
hold on; plot(data3.Time(169:end), aY1)
hold on; plot(data3.Time(169:end), aZ1)
hold on; plot(data3.Time(169:end), gX1)
hold on; plot(data3.Time(169:end), gY1)
hold on; plot(data3.Time(169:end), gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Filtered Elbow Extension/Flexion with 90Hz Vibration')

%%
figure; plot(data2.Time, data2.aY)
hold on; plot(data2.Time, data2.aX*-1)
hold on; plot(data2.Time, data2.aZ)
hold on; plot(data2.Time, data2.gX)
hold on; plot(data2.Time, data2.gY)
hold on; plot(data2.Time, data2.gZ)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Flipped IMU')

%%
figure; plot(data2.Time, rot_imu(1, :));
hold on; plot(data2.Time, rot_imu(2, :));
hold on; plot(data2.Time, rot_imu(3, :));
hold on; plot(data2.Time, data2.gX);
hold on; plot(data2.Time, data2.gY);
hold on; plot(data2.Time, data2.gZ);
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Rotated IMU')

%%
t = data.Time;

figure; plot(t, data.aX1)
hold on; plot(t, data.aY1)
hold on; plot(t, data.aZ1)
hold on; plot(t, data.gX1)
hold on; plot(t, data.gY1)
hold on; plot(t, data.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Training IMU')

%%
figure; plot(movmean(data.aY1, 10))
f2aX = diff(diff(movmean(data.aY1, 10)));
plot(t(f2aX == 0), data.aY1(f2aX == 0), 'o')

%%
figure; plot(data2.Time, data2.aX)
hold on; plot(data2.Time, data2.aY)
hold on; plot(data2.Time, data2.aZ)
% figure; plot(data2.Time, data2.gX)
% hold on; plot(data2.Time, data2.gY)
% hold on; plot(data2.Time, data2.gZ)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU')

%%
figure; plot(data3.Time, data3.aX)
hold on; plot(data3.Time, data3.aY)
hold on; plot(data3.Time, data3.aZ)
% hold on; plot(data2.Time, data2.gX)
% hold on; plot(data2.Time, data2.gY)
% hold on; plot(data2.Time, data2.gZ)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU')

%%
fc = 2.93; % cutoff, Hz
fs = 55; % sampling, Hz
n_order = 6;

[b,a] = butter(n_order, fc/(fs/2));
accX_filt = filtfilt(b, a, data.aX1);
accY_filt = filtfilt(b, a, data.aY1);
accZ_filt = filtfilt(b, a, data.aZ1);
gyroX_filt = filtfilt(b, a, data.gX1);
gyroY_filt = filtfilt(b, a, data.gY1);
gyroZ_filt = filtfilt(b, a, data.gZ1);

figure; plot(data.Time, accX_filt)
hold on; plot(data.Time, accY_filt)
hold on; plot(data.Time, accZ_filt)
hold on; plot(data.Time, gyroX_filt)
hold on; plot(data.Time, gyroY_filt)
hold on; plot(data.Time, gyroZ_filt)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU')

%%
tiledlayout(2, 3)
title(t, 'Wrist Flexion')

nexttile
plot(t, data.aX1)
legend('ax')

nexttile
plot(t, data.aY1)
legend('aY')

nexttile
plot(t, data.aZ1)
legend('aZ')

nexttile
plot(t, data.gX1)
legend('gX')

nexttile
plot(t, data.gY1)
legend('gY')

nexttile
plot(t, data.aZ1)
legend('gZ')


%%
det_gx1 = detrend(data.gX1);
det2_gx1 = detrend(data2.gX1);

t2 = data2.Time;

figure; plot(t, data.gX1);
hold on; plot(t2, data2.gX1);
hold on; plot(t, det_gx1);
hold on; plot(t2, det2_gx1);
title('Gyro X - Wrist');
legend('raw', 'static', 'detrend raw', 'detrend static')

%% cp 3 prediction example
figure; plot(t(1:60), data.gX1(1:60));
hold on; plot(t(1:60), data.gY1(1:60));
hold on; xline(t([24, 30, 40, 46]));
hold on; xline(t([19, 29, 38, 44]), '--', 'Color', [0, 0.5, 0], 'LineWidth', 1);

legend('gX', 'gY', 'movement bounds', 'classification bounds');
xlabel('time [ms]');
ylabel('angular velocity [°/s]')
title('Wrist Flexion/Extension - Wrist IMU')

