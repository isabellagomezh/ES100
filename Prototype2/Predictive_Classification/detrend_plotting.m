clc
clear
%% import data and static data
% data = readtable("wrist_flex.csv");

data = readtable("class_data/wrist_ext_flex/wrist_ext_flex1.csv");
stat = readtable("class_data/statics/static_90_palm_down.csv");

%% detrended data
t1 = data.Time-data.Time(1);
w_aX = detrend(data.aX1);
w_aY = detrend(data.aY1);
w_aZ = detrend(data.aZ1);
w_gX = detrend(data.gX1);
w_gY = detrend(data.gY1);
w_gZ = detrend(data.gZ1);

b_aX = detrend(data.aX2);
b_aY = detrend(data.aY2);
b_aZ = detrend(data.aZ2);
b_gX = detrend(data.gX2);
b_gY = detrend(data.gY2);
b_gZ = detrend(data.gZ2);

t2 = stat.Time-stat.Time(1);
stat_w_aX = detrend(stat.aX1);
stat_w_aY = detrend(stat.aY1);
stat_w_aZ = detrend(stat.aZ1);
stat_w_gX = detrend(stat.gX1);
stat_w_gY = detrend(stat.gY1);
stat_w_gZ = detrend(stat.gZ1);

stat_b_aX = detrend(stat.aX2);
stat_b_aY = detrend(stat.aY2);
stat_b_aZ = detrend(stat.aZ2);
stat_b_gX = detrend(stat.gX2);
stat_b_gY = detrend(stat.gY2);
stat_b_gZ = detrend(stat.gZ2);

%%
ref_min_w_aX = min(stat_w_aX);

%%
[pks, locs, w, p] = findpeaks(data.aX1);

%% detrended
[hi, lo] = envelope(w_aX);

%%
figure; plot(t1, w_aX);
% hold on; plot(data.Time, data.aX1);
% hold on; yline(mean(w_aX));
hold on; plot(t1, movmean(w_aX, 200));
% hold on; yline(ref_min_w_aX);
hold on; plot(t1, hi, t1, lo);
hold on; plot(t2, stat_w_aX);
% hold on; plot(data.Time(locs), data.aX1(locs))

legend('detrended', 'moving mean', 'hi', 'lo', 'static')

%% raw

figure; plot(data.Time, data.aX1);
hold on; plot(data.Time, movmean(data.aX1, 200));
hold on; plot(stat.Time, stat.aX1);

hold on; plot(data.Time, data.aY1);
hold on; plot(data.Time, movmean(data.aY1, 200));
hold on; plot(stat.Time, stat.aY1);

legend('raw', 'moving mean', 'hi', 'lo', 'static')

%%
[x_int, iaccX, imeanX] = intersect(data.aX1, movmean(data.aX1, 200));
[y_int, iaccY, imeanY] = intersect(data.aY1, movmean(data.aY1, 200));

hold on; xline(data.Time(iaccX))
hold on; xline(data.Time(iaccY))

%%
figure; plot(data.Time, data.aX1);
hold on; plot(data.Time, movmean(data.aX1, 200));
hold on; plot(stat.Time, stat.aX1);
hold on; xline(data.Time(iaccX))

%% filter before moving mean

%%
[x_int, igX, istatgX] = intersect(data.gX1, stat.gX1);

figure; plot(data.Time, data.gX1)
hold on; plot(stat.Time, stat.gX1)
hold on; plot(data.Time(igX), data.gX1(igX), 'o')
