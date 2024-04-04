% open data file as table
data = readtable("class_data_labeled3/forearm1.csv");
% data = readtable("full_dataset/arm_ext1_1.csv");

%%
t = data.Time;
figure; plot(t, data.aX1, '.');

%%
t_250 = round(linspace(0, max(t), max(t)*150), 3).';
x250 = interp1(t, data.aX1, t_250,'makima');

figure; plot(t_250, x250, '.');
hold on; plot(t, data.aX1, 'o');

%% resample all training data
files = dir(fullfile('class_data_labeled3/', '*.csv'));

for i = 1:length(files)

    base = files(i).name;
    file = fullfile('class_data_labeled3/', base);
    data = readtable(file);

    aX1_250 = interp1(data.Time, data.aX1, t_250,'makima');
    aY1_250 = interp1(data.Time, data.aY1, t_250,'makima');
    aZ1_250 = interp1(data.Time, data.aZ1, t_250,'makima');
    gX1_250 = interp1(data.Time, data.gX1, t_250,'makima');
    gY1_250 = interp1(data.Time, data.gY1, t_250,'makima');
    gZ1_250 = interp1(data.Time, data.gZ1, t_250,'makima');
    aX2_250 = interp1(data.Time, data.aX2, t_250,'makima');
    aY2_250 = interp1(data.Time, data.aY2, t_250,'makima');
    aZ2_250 = interp1(data.Time, data.aZ2, t_250,'makima');
    gX2_250 = interp1(data.Time, data.gX2, t_250,'makima');
    gY2_250 = interp1(data.Time, data.gY2, t_250,'makima');
    gZ2_250 = interp1(data.Time, data.gZ2, t_250,'makima');
    move = ones(length(t_250), 1) * data.move{1};

    data_250 = [t_250, aX1_250, aY1_250, aZ1_250, gX1_250, gY1_250, gZ1_250, aX2_250, aY2_250, aZ2_250, gX2_250, gY2_250, gZ2_250, move];

    writematrix(data_250, strcat('class_data_labeled_interp/', base));
end

