% open data file as table
data = readtable("class_data_labeled3/arm_ext_flex3.csv");

%% change move to categorical variable
category_mapping = containers.Map({'wrist_flex', 'wrist_ext'}, {13, 14});
move_numeric = cellfun(@(x) category_mapping(x), data.move);

%% moving mean filter
fltdata = [data.Time, movmean(data.aX1,10), movmean(data.aY1,10), movmean(data.aZ1,10), movmean(data.gX1,10), movmean(data.gY1,10), movmean(data.gZ1,10), movmean(data.aX2,10), movmean(data.aY2,10), movmean(data.aZ2,10), movmean(data.gX2,10), movmean(data.gY2,10), movmean(data.gZ2,10), move_numeric];

%% put into table
fltdata = array2table(fltdata);
fltdata = renamevars(fltdata, ["fltdata1", "fltdata2", "fltdata3", "fltdata4", "fltdata5", "fltdata6", "fltdata7", "fltdata8", "fltdata9", "fltdata10", "fltdata11", "fltdata12", "fltdata13", "fltdata14"], ["Time", "aX1", "aY1", "aZ1", "gX1", "gY1", "gZ1", "aX2", "aY2", "aZ2", "gX2", "gY2", "gZ2", "move"]);

%% remove first and last rows
fltdata = fltdata(553:8101, :);

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

%% highlight
sup_idx = find(fltdata.move == 13);

hold on; plot(t(sup_idx), fltdata.gX1(sup_idx), 'r.');

%% find places where move type changes
move_diff = diff(fltdata.move);

change_idx = find(move_diff ~= 0);
pro_to_sup = find(move_diff == 1);
sup_to_pro = find(move_diff == -1);

hold on; xline(fltdata.Time(pro_to_sup), 'b')
hold on; xline(fltdata.Time(sup_to_pro), 'r')

%% make tables for each type of move
features = {'var_aX1','rms_aX1', 'mean_aX1', 'std_aX1', 'skew_aX1', 'kurt_aX1', 'var_aY1','rms_aY1', 'mean_aY1', 'std_aY1', 'skew_aY1', 'kurt_aY1', 'var_aZ1','rms_aZ1', 'mean_aZ1', 'std_aZ1', 'skew_aZ1', 'kurt_aZ1', 'var_gX1','rms_gX1', 'mean_gX1', 'std_gX1', 'skew_gX1', 'kurt_gX1', 'var_gY1','rms_gY1', 'mean_gY1', 'std_gY1', 'skew_gY1', 'kurt_gY1', 'var_gZ1','rms_gZ1', 'mean_gZ1', 'std_gZ1', 'skew_gZ1', 'kurt_gZ1', 'var_aX2','rms_aX2', 'mean_aX2', 'std_aX2', 'skew_aX2', 'kurt_aX2', 'var_aY2','rms_aY2', 'mean_aY2', 'std_aY2', 'skew_aY2', 'kurt_aY2', 'var_aZ2','rms_aZ2', 'mean_aZ2', 'std_aZ2', 'skew_aZ2', 'kurt_aZ2', 'var_gX2','rms_gX2', 'mean_gX2', 'std_gX2', 'skew_gX2', 'kurt_gX2', 'var_gY2','rms_gY2', 'mean_gY2', 'std_gY2', 'skew_gY2', 'kurt_gY2', 'var_gZ2','rms_gZ2', 'mean_gZ2', 'std_gZ2', 'skew_gZ2', 'kurt_gZ2'};
flex = cell2table(cell(0,72),'VariableNames',features);
ext = cell2table(cell(0,72),'VariableNames',features);

%%
for i = 1:length(change_idx)
    % select data for start of move
    if i == 1
        move_start = fltdata(1:30, 1:end);
    else
        move_start = fltdata(change_idx(i)+1:change_idx(i)+31, 1:end);
    end

    % Initialize a row of features
    feat_row = zeros(1, length(features));

    % extract features
    for j = 2:width(move_start)-1
        feat_start = (j-2)*6 + 1; % Adjusted index calculation
        
        feat_row(feat_start) = var(move_start{:, j});
        feat_row(feat_start + 1) = rms(move_start{:, j});
        feat_row(feat_start + 2) = mean(move_start{:, j}, "omitmissing");
        feat_row(feat_start + 3) = std(move_start{:, j}, "omitmissing");
        feat_row(feat_start + 4) = skewness(move_start{:, j});
        feat_row(feat_start + 5) = kurtosis(move_start{:, j});
    end

    % Convert the array of features into a table row
    feats = array2table(feat_row, "VariableNames",features);

    % Append the new row of features to the appropriate table
    if move_start{15,"move"} == 13
        flex = [flex; feats];
    else
        ext = [ext; feats];
    end
end

%% save file
writetable(flex, "class_data_fin/wrist_flexion3.csv");
writetable(ext, "class_data_fin/wrist_extension3.csv");

