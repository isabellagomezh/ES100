data = readtable("class_data_labeled3/forearm1.csv");
bno_data = readtable("bno_labeled/forearm1.csv");

%%

figure; plot(data.Time, data.aX1-4);
hold on; plot(bno_data.Time, bno_data.aX);
legend('Xiao IMU', 'BNO08x');
title('Wrist IMU - x-acceleration during forearm pronation/supination')
