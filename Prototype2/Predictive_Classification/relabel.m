files = dir(fullfile('full_dataset', '*.csv'));

for i = 1:length(files)

    base = files(i).name;
    file = fullfile('full_dataset/', base);
    data = readtable(file);

    if contains(file, 'wrist_abd')
        data.move = 12 * ones(height(data), 1);
    elseif contains(file, 'wrist_add')
        data.move = 11 * ones(height(data), 1);
    elseif contains(file, 'wrist_ext')
        data.move = 14 * ones(height(data), 1);
    elseif contains(file, 'wrist_flex')
        data.move = 13 * ones(height(data), 1);
    end

    writetable(data, file);
end

