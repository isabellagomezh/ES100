function dataset = makeDataset(folder)
%% Load data

files = dir(fullfile(folder,'*.csv'));

dataset = [];

for i = 1:length(files)

    % open file and create table
    base = files(i).name;
    file = fullfile(folder, base);
    fprintf(1, 'Processing file: %s\n', base)
    data = readtable(file);
    data = removevars(data, ["Activity","User","TrialNumber"]);
    
    % define variables
    t = data.Time(2:end); % Get rid of initial large jump in time
    accX = data.accel_X(2:end);
    accY = data.accel_Y(2:end);
    accZ = data.accel_Z(2:end);
    gyroX = data.gyro_X(2:end);
    gyroY = data.gyro_Y(2:end);
    gyroZ = data.gyro_Z(2:end);
    gt = data.GT(2:end);
    t = (t-t(1)); % Convert to start at 0
    
    % featurize events in file
    cut = 12;
    event = processEvents(t, accX, accY, accZ, gyroX, gyroY, gyroZ, gt, cut);

    % append to dataset of events
    dataset = [dataset; event];

end

