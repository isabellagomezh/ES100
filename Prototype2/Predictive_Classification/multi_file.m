% open data file as table
data = readtable("class_data_labeled3/forearm1.csv");

%% change move to categorical variable
category_mapping = containers.Map({'sup', 'pro'}, {1, 2});
move_numeric = cellfun(@(x) category_mapping(x), data.move);

%% moving mean filter
fltdata = [data.Time, movmean(data.aX1,10), movmean(data.aY1,10), movmean(data.aZ1,10), movmean(data.gX1,10), movmean(data.gY1,10), movmean(data.gZ1,10), movmean(data.aX2,10), movmean(data.aY2,10), movmean(data.aZ2,10), movmean(data.gX2,10), movmean(data.gY2,10), movmean(data.gZ2,10), move_numeric];

%% put into table
fltdata = array2table(fltdata);
fltdata = renamevars(fltdata, ["fltdata1", "fltdata2", "fltdata3", "fltdata4", "fltdata5", "fltdata6", "fltdata7", "fltdata8", "fltdata9", "fltdata10", "fltdata11", "fltdata12", "fltdata13", "fltdata14"], ["Time", "aX1", "aY1", "aZ1", "gX1", "gY1", "gZ1", "aX2", "aY2", "aZ2", "gX2", "gY2", "gZ2", "move"]);

%% plot
t = fltdata.Time;

figure; plot(t, fltdata.aX1)
hold on; plot(t, fltdata.aY1)
hold on; plot(t, fltdata.aZ1)
hold on; plot(t, fltdata.gX1)
hold on; plot(t, fltdata.gY1)
hold on; plot(t, fltdata.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU')

figure; plot(t, fltdata.aX2)
hold on; plot(t, fltdata.aY2)
hold on; plot(t, fltdata.aZ2)
hold on; plot(t, fltdata.gX2)
hold on; plot(t, fltdata.gY2)
hold on; plot(t, fltdata.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU')

%% remove first and last rows
% fltdata = fltdata(find(fltdata.Time == 13971):find(fltdata.Time == 158309), :);

fltdata = fltdata(565:7523, :);

%% highlight & plot
sup_idx = find(fltdata.move == 1);
hold on; plot(t(sup_idx), fltdata.gX1(sup_idx), 'r.');

%% find places where move type changes
move_diff = diff(fltdata.move);

change_idx = find(move_diff ~= 0);
pro_to_sup = find(move_diff == 1);
sup_to_pro = find(move_diff == -1);

%% plot
hold on; plot(fltdata.aX1);
hold on; xline(fltdata.Time(pro_to_sup), 'b')
hold on; xline(fltdata.Time(sup_to_pro), 'r')
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Forearm Pronation/Supination')

%% make a table for each window and save to csv
odds = 1;
evens = 1;

for i = 1:length(change_idx)
    % select data for start of move
    if i == 1
        move_start = fltdata(1:change_idx(i), 1:end);
    else
        move_start = fltdata(change_idx(i)+1:change_idx(i+1)-1, 1:end);
    end

    if height(move_start) > 15
        % Append the new row of features to the appropriate table
        if move_start{15,"move"} == 1
            % dat = array2table(move_start);
            filename = strcat("full_dataset/supination1_", string(odds), ".csv")
            writetable(move_start, filename);
            odds = odds + 1;
        else
            % dat = array2table(move_start);
            filename = strcat("full_dataset/pronation1_", string(evens), ".csv")
            writetable(move_start, filename);
            evens = evens + 1;
        end
    end
end


