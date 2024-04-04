%% smoothed labeling

file_num = 'jerry_arm_flex_ext1';
move1 = 4; % positive gyro
move2 = 3;

label(file_num, move1, move2) 

%%
function label(file_num, move1, move2)

filename = strcat("final_tests", "/", file_num, ".csv");
data = readtable(filename);

aX = data.aX;
aY = data.aY;

data.aX = aY;
data.aY = aX*(-1);

t = data.Time;
% var = movmean(data.gZ, 2);
var = data.gZ;

% find times at which gyro of interest is close to 0
idx = find(var < .5 & var > -.5);

% combine close times of change into single value
for i = (size(idx,1)-1):-1:2
    if idx(i) - idx(i-1) < 25
        idx(i) = [];
    end
end    

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

figure; plot(t, data.aX)
hold on; plot(t, data.aY)
hold on; plot(t, data.aZ)
hold on; plot(t, data.gX)
hold on; plot(t, data.gY)
hold on; plot(t, data.gZ)
hold on; xline(t(idx))
hold on; plot(t(sup_idx), var(sup_idx), 'r.-')
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');

% save to csv
newfile = strcat("final_tests_labeled/", "/", file_num, ".csv");
writetable(data, newfile);

end