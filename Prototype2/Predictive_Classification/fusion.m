% open data file as table
data = readtable("class_data_labeled3/forearm1.csv");

%%
accels = [data.aX1, data.aY1, data.aZ1];
gyros = [data.gX1, data.gY1, data.gZ1];

Fs = 200;
fuse = imufilter('SampleRate',Fs);

[orientation, angularVelocity] = fuse(accels, gyros);


%%
t = data.Time;
% figure; plot(t, data.gX1)
% hold on; plot(t, data.gY1)
hold on; plot(t, data.gZ1)
% hold on; plot(t, angularVelocity(:, 1));
% hold on; plot(t, angularVelocity(:, 2));
hold on; plot(t, angularVelocity(:, 3));

legend('gZ1', 'gZk');

% legend('gX1', 'gY1', 'gZ1', 'gXk', 'gYk', 'gZk');


%%
quats = fuse(accels,gyros);

euls = eulerd(quats, 'ZYX', 'frame');

roll = euls(:, 1);
pitch = euls(:, 2);
yaw = euls(:, 3);

%% plot
figure; plot(t(1:1000), roll(1:1000));
% hold on; plot(t, pitch);
% hold on; plot(t, yaw);
% legend('roll', 'pitch', 'yaw');

