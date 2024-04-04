clc
clear
%% data
folder = 'elbow_flex';
file_num = 'elbow_flex20';
move1 = 'ext'; 
move2 = 'flex';

%%
label(folder, file_num, move1, move2)

%%
function label(folder, file_num, move1, move2)

filename = strcat("class_data/", folder, "/", file_num, ".csv");
data = readtable(filename);

t = data.Time;
var = data.gZ1;

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
hold on; plot(t(sup_idx), data.gX1(sup_idx), 'r.-')
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');

% save to csv
newfile = strcat("class_data_labeled/", folder, "/", file_num, ".csv");
writetable(data, newfile);

end
%% find 0-intercepts using fit
% [fit_gY, fit_gY_gof] = fitSine(t, data.gY1);
% 
% times = linspace(0,43000,100000);
% fit_fun = fit_gY(times);
% t_int = find(fit_fun < 0.5 & fit_fun > -0.5);
% 
% figure; plot(t, data.gY1);
% hold on; xline(times(t_int));



