clear

%% Load file
% Arduino data
% data = readtable('choreos/choreo3_lleg.csv');
% data = removevars(data, ["Activity","User","TrialNumber"]);

% Arduino - define variables
% t = data.Time(2:end); % Get rid of initial large jump in time
% accX = data.accel_X(2:end);
% accY = data.accel_Y(2:end);
% accZ = data.accel_Z(2:end);
% gyroX = data.gyro_X(2:end);
% gyroY = data.gyro_Y(2:end);
% gyroZ = data.gyro_Z(2:end);

% Delsys data
data = readtable('demos/Trial4_Plot_and_Store_Rep_1.4.csv');

% Delsys - define variables
t = data.X_s_;
accX = data.AvantiSensor1_ACC_X1;
accY = data.AvantiSensor1_ACC_Y1;
accZ = data.AvantiSensor1_ACC_Z1;
gyroX = data.AvantiSensor1_GYRO_X1;
gyroY = data.AvantiSensor1_GYRO_Y1;
gyroZ = data.AvantiSensor1_GYRO_Z1;

gt = zeros(length(gyroZ),1);
t = (t-t(1)); % Convert to start at 0

% featurize events in file
cut = 12;
events = processEvents(t, accX, accY, accZ, gyroX, gyroY, gyroZ, gt, cut);

%% train classifier
dataset = makeDataset('data/');
[trainedClassifier, validationAccuracy] = trainSVMClassifier(dataset);

%% classify
[yfit,scores] = trainedClassifier.predictFcn(events(:,2:end-1));

%% export for ahap processing
writematrix([events(:,1),yfit],'demos/d4_lleg.csv')
