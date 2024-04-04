base = 'elbow_ext_flex3.csv';
data = readtable('class_data_labeled3/elbow_ext_flex3.csv');

%% take off start/end of file
data.Time = data.Time(); 

%% NOT 250 HZ, 150 HZ
t = data.Time;
[t_unique, t_idx] = unique(t);

t_250 = round(linspace(0, max(t), max(t)*150), 3).';

aX1_250 = interp1(data.Time(t_idx), data.aX1(t_idx), t_250,'makima');

%%

aY1_250 = interp1(data.Time(t_idx), data.aY1(t_idx), t_250,'makima');

aZ1_250 = interp1(data.Time(t_idx), data.aZ1(t_idx), t_250,'makima');

gX1_250 = interp1(data.Time(t_idx), data.gX1(t_idx), t_250,'makima');

gY1_250 = interp1(data.Time(t_idx), data.gY1(t_idx), t_250,'makima');

gZ1_250 = interp1(data.Time(t_idx), data.gZ1(t_idx), t_250,'makima');

aX2_250 = interp1(data.Time(t_idx), data.aX2(t_idx), t_250,'makima');

aY2_250 = interp1(data.Time(t_idx), data.aY2(t_idx), t_250,'makima');

aZ2_250 = interp1(data.Time(t_idx), data.aZ2(t_idx), t_250,'makima');

gX2_250 = interp1(data.Time(t_idx), data.gX2(t_idx), t_250,'makima');

gY2_250 = interp1(data.Time(t_idx), data.gY2(t_idx), t_250,'makima');

gZ2_250 = interp1(data.Time(t_idx), data.gZ2(t_idx), t_250,'makima');

%%
category_mapping = containers.Map({'ext', 'flex'}, {7, 8});
move_numeric = cellfun(@(x) category_mapping(x), data.move);

%%
moves = interp1(data.Time(t_idx), move_numeric(t_idx), t_250, 'nearest');

%%
% data_250 = [t_250, aX1_250, aY1_250, aZ1_250, gX1_250, gY1_250, gZ1_250, aX2_250, aY2_250, aZ2_250, gX2_250, gY2_250, gZ2_250, move];

data_250 = table(t_250, aX1_250, aY1_250, aZ1_250, gX1_250, gY1_250, gZ1_250, aX2_250, aY2_250, aZ2_250, gX2_250, gY2_250, gZ2_250, moves);


%%
writetable(data_250, strcat('class_data_labeled_interp/', base));

