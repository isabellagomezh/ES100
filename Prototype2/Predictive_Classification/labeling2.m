%% time-based labeling
% open data file as table
data = readtable("class_data2/grip2.csv");

%% plot to check
t = data.Time;

figure; plot(t, data.aX1)
hold on; plot(t, data.aY1)
hold on; plot(t, data.aZ1)
hold on; plot(t, data.gX1)
hold on; plot(t, data.gY1)
hold on; plot(t, data.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU')

figure; plot(t, data.aX2)
hold on; plot(t, data.aY2)
hold on; plot(t, data.aZ2)
hold on; plot(t, data.gX2)
hold on; plot(t, data.gY2)
hold on; plot(t, data.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU')

%% record first 4 peaks and time between them
%sampling freq

[pks, locs] = findpeaks(data.gY1, 'MinPeakHeight', 5, 'MinPeakDistance', 50);

diffs = diff(t(locs(1:5)));

% window = mean([diffs(1), diffs(2), diffs(4)]);

window = 1600; %ms

% hold on; plot(t(locs), data.gY1(locs), 'o')

%% make array of times where beat happened, first one after 4th peak = start
start = t(locs(5)) + window;
n = (t(end) - start)/window - 1;

beats = linspace(start, t(end), n)';

%% find indexes of times closest to beats
beats_idx = ones(length(beats),1);
times = t(locs(5):end);

for i = 1:length(beats)
    target = beats(i);
    [~, closest_idx] = min(abs(t - target));
    beats_idx(i) = closest_idx;
end

%% plot to check division
figure; plot(t, data.aX1)
hold on; plot(t, data.aY1)
hold on; plot(t, data.aZ1)
hold on; plot(t, data.gX1)
hold on; plot(t, data.gY1)
hold on; plot(t, data.gZ1)
hold on; xline(t(beats_idx))
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU')

%% label times between beats, alternating between 1st/2nd move
m1 = 'close';
m2 = 'open';

data.move = cell(size(data, 1), 1);

for i = 1:length(beats)-2
    if rem(i,2) == 0
        data.move(beats_idx(i):beats_idx(i+1)) = {m2};
    else
        data.move(beats_idx(i):beats_idx(i+1)) = {m1};
    end
end

%% plot to check labelling
sup_idx = find(strcmp(data.move, m1));

figure; plot(t, data.aX1)
hold on; plot(t, data.aY1)
hold on; plot(t, data.aZ1)
hold on; plot(t, data.gX1)
hold on; plot(t, data.gY1)
hold on; plot(t, data.gZ1)
hold on; xline(t(beats_idx))
hold on; plot(t(sup_idx), data.gX1(sup_idx), 'r.-')
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');

%% save to csv
file_num = "grip2";
newfile = strcat("class_data_labeled2/", "/", file_num, ".csv");
writetable(data, newfile);

% window is shifting and not catching right moves!!

%% back to gyro-based labeling
file_num = 'grip2';
move1 = 'close'; % positive gyro
move2 = 'open';

label(file_num, move1, move2)

%%
function label(file_num, move1, move2)

filename = strcat("class_data2/", "/", file_num, ".csv");
data = readtable(filename);

t = data.Time;
var = data.gY1;

% figure; plot(t, data.aX1)
% hold on; plot(t, data.aY1)
% hold on; plot(t, data.aZ1)
% hold on; plot(t, data.gX1)
% hold on; plot(t, data.gY1)
% hold on; plot(t, data.aZ1)
% legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
% title('Wrist IMU')
% 
% figure; plot(t, data.aX2)
% hold on; plot(t, data.aY2)
% hold on; plot(t, data.aZ2)
% hold on; plot(t, data.gX2)
% hold on; plot(t, data.gY2)
% hold on; plot(t, data.aZ2)
% legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
% title('Bicep IMU')

% find times at which gyro of interest is close to 0
idx = find(var < 5.5 & var > -5.5);

% figure; plot(t, data.aX1)
% hold on; plot(t, data.aY1)
% hold on; plot(t, data.aZ1)
% hold on; plot(t, data.gX1)
% hold on; plot(t, data.gY1)
% hold on; plot(t, data.aZ1)
% hold on; xline(t(idx))

% combine close times into single value
for i = (size(idx,1)-1):-1:2
    if idx(i) - idx(i-1) < 25
        idx(i) = [];
    end
end    

% figure; plot(t, data.aX1)
% hold on; plot(t, data.aY1)
% hold on; plot(t, data.aZ1)
% hold on; plot(t, data.gX1)
% hold on; plot(t, data.gY1)
% hold on; plot(t, data.aZ1)
% hold on; xline(t(idx))

% label moves based on gyro of interest
data.move = cell(size(data, 1), 1);

for i = 1:size(data,1)
    if var(i) > 0
        data.move{i} = move1;
    else
        data.move{i} = move2;
    end
end

% plot w/ highlighted move
sup_idx = find(strcmp(data.move, move1));

figure; plot(t, data.aX1)
hold on; plot(t, data.aY1)
hold on; plot(t, data.aZ1)
hold on; plot(t, data.gX1)
hold on; plot(t, data.gY1)
hold on; plot(t, data.gZ1)
hold on; xline(t(idx))
hold on; plot(t(sup_idx), var(sup_idx), 'r.-')
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');

% save to csv
newfile = strcat("class_data_labeled2/", "/", file_num, ".csv");
writetable(data, newfile);

end

