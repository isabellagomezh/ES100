%% forearm pronation/supination
forearm = readtable("class_data2/forearm1.csv");

%%
t = forearm.Time;

figure; plot(t, forearm.aX1)
hold on; plot(t, forearm.aY1)
hold on; plot(t, forearm.aZ1)
hold on; plot(t, forearm.gX1)
hold on; plot(t, forearm.gY1)
hold on; plot(t, forearm.aZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Forearm Pronation/Supination')

figure; plot(t, forearm.aX2)
hold on; plot(t, forearm.aY2)
hold on; plot(t, forearm.aZ2)
hold on; plot(t, forearm.gX2)
hold on; plot(t, forearm.gY2)
hold on; plot(t, forearm.aZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Forearm Pronation/Supination')

%%
idx = find(forearm.gY1 < 1.5 & forearm.gY1 > -1.5);

figure; plot(t, forearm.aX1)
hold on; plot(t, forearm.aY1)
hold on; plot(t, forearm.aZ1)
hold on; plot(t, forearm.gX1)
hold on; plot(t, forearm.gY1)
hold on; plot(t, forearm.aZ1)
hold on; xline(t(idx))

%%
[fit_gY, fit_gY_gof] = fitSine(t, forearm.gY1);

%%
times = linspace(0,43000,100000);
fit_fun = fit_gY(times);
t_int = find(fit_fun < 0.5 & fit_fun > -0.5);

figure; plot(t, forearm.gY1);
hold on; xline(times(t_int));

