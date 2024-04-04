%% forearm pronation/supination
forearm = readtable("class_data/forearm/forearm1.csv");

%%
t = forearm.Time;

figure; plot(t, forearm.aX1)
hold on; plot(t, forearm.aY1)
hold on; plot(t, forearm.aZ1)
hold on; plot(t, forearm.gX1)
hold on; plot(t, forearm.gY1)
hold on; plot(t, forearm.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Forearm Pronation/Supination')

figure; plot(t, forearm.aX2)
hold on; plot(t, forearm.aY2)
hold on; plot(t, forearm.aZ2)
hold on; plot(t, forearm.gX2)
hold on; plot(t, forearm.gY2)
hold on; plot(t, forearm.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Forearm Pronation/Supination')

%% elbow flexion/extension
elbow = readtable("class_data/elbow_flex/elbow_flex2.csv");

%%
t = elbow.Time;

figure; plot(t, elbow.aX1)
hold on; plot(t, elbow.aY1)
hold on; plot(t, elbow.aZ1)
hold on; plot(t, elbow.gX1)
hold on; plot(t, elbow.gY1)
hold on; plot(t, elbow.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Elbow Flexion/Extension')

figure; plot(t, elbow.aX2)
hold on; plot(t, elbow.aY2)
hold on; plot(t, elbow.aZ2)
hold on; plot(t, elbow.gX2)
hold on; plot(t, elbow.gY2)
hold on; plot(t, elbow.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Elbow Flexion/Extension')

%% arm rotation
arm_rot = readtable("class_data/arm_rotation/arm_rotation1.csv");

%%
t = arm_rot.Time;

figure; plot(t, arm_rot.aX1)
hold on; plot(t, arm_rot.aY1)
hold on; plot(t, arm_rot.aZ1)
hold on; plot(t, arm_rot.gX1)
hold on; plot(t, arm_rot.gY1)
hold on; plot(t, arm_rot.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Arm Rotation (Internal/External)')

figure; plot(t, arm_rot.aX2)
hold on; plot(t, arm_rot.aY2)
hold on; plot(t, arm_rot.aZ2)
hold on; plot(t, arm_rot.gX2)
hold on; plot(t, arm_rot.gY2)
hold on; plot(t, arm_rot.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Arm Rotation (Internal/External)')

%% arm extension/flexion
arm_ext = readtable("class_data/arm_ext_flex/arm_ext_flex1.csv");

%%
t = arm_ext.Time;

figure; plot(t, arm_ext.aX1)
hold on; plot(t, arm_ext.aY1)
hold on; plot(t, arm_ext.aZ1)
hold on; plot(t, arm_ext.gX1)
hold on; plot(t, arm_ext.gY1)
hold on; plot(t, arm_ext.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Arm Extension/Flexion')

figure; plot(t, arm_ext.aX2)
hold on; plot(t, arm_ext.aY2)
hold on; plot(t, arm_ext.aZ2)
hold on; plot(t, arm_ext.gX2)
hold on; plot(t, arm_ext.gY2)
hold on; plot(t, arm_ext.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Arm Extension/Flexion')

%% wrist extension/flexion
wrist_ef = readtable("class_data/wrist_ext_flex/wrist_ext_flex22.csv");

%%
t = wrist_ef.Time;

figure; plot(t, wrist_ef.aX1)
hold on; plot(t, wrist_ef.aY1)
hold on; plot(t, wrist_ef.aZ1)
hold on; plot(t, wrist_ef.gX1)
hold on; plot(t, wrist_ef.gY1)
hold on; plot(t, wrist_ef.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Wrist Extension/Flexion')

figure; plot(t, wrist_ef.aX2)
hold on; plot(t, wrist_ef.aY2)
hold on; plot(t, wrist_ef.aZ2)
hold on; plot(t, wrist_ef.gX2)
hold on; plot(t, wrist_ef.gY2)
hold on; plot(t, wrist_ef.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Wrist Extension/Flexion')

%% wrist abduction/adduction
wrist_abad = readtable("class_data/wrist_ab_ad/wrist_ab_ad1.csv");

%%
t = wrist_abad.Time;

figure; plot(t, wrist_abad.aX1)
hold on; plot(t, wrist_abad.aY1)
hold on; plot(t, wrist_abad.aZ1)
hold on; plot(t, wrist_abad.gX1)
hold on; plot(t, wrist_abad.gY1)
hold on; plot(t, wrist_abad.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Wrist Abduction/Adduction')

figure; plot(t, wrist_abad.aX2)
hold on; plot(t, wrist_abad.aY2)
hold on; plot(t, wrist_abad.aZ2)
hold on; plot(t, wrist_abad.gX2)
hold on; plot(t, wrist_abad.gY2)
hold on; plot(t, wrist_abad.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Wrist Abduction/Adduction')

%% grip
grip = readtable("class_data/grip/grip1.csv");

%%
t = grip.Time;

figure; plot(t, grip.aX1)
hold on; plot(t, grip.aY1)
hold on; plot(t, grip.aZ1)
hold on; plot(t, grip.gX1)
hold on; plot(t, grip.gY1)
hold on; plot(t, grip.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Grip Open/Close');

figure; plot(t, grip.aX2)
hold on; plot(t, grip.aY2)
hold on; plot(t, grip.aZ2)
hold on; plot(t, grip.gX2)
hold on; plot(t, grip.gY2)
hold on; plot(t, grip.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Grip Open/Close');

%% hand movement comparison

figure; plot(t, grip.gX1)
hold on; plot(t, grip.gY1)
hold on; plot(t, wrist_abad.gX1, "--")
hold on; plot(t, wrist_abad.gY1, "--")
hold on; plot(t, wrist_ef.gX1, "-.")
hold on; plot(t, wrist_ef.gY1, "-.")
legend('grip gX', 'grip gY', 'abd gX', 'abd gY', 'ext gX', 'ext gY');
title('Wrist Movement Comparison - Gyro X and Gyro Y');

%%
figure; plot(t, grip.gX1)
hold on; plot(t, wrist_abad.gX1)
hold on; plot(t, wrist_ef.gX1)
legend('grip gX', 'abd gX', 'ext gX');
title('Wrist Movement Comparison - Gyro X');

%%
figure; plot(t, grip.gY1)
hold on; plot(t, wrist_abad.gY1)
hold on; plot(t, wrist_ef.gY1)
legend('grip gY', 'abd gY', 'ext gY');
title('Wrist Movement Comparison - Gyro Y');

%% static 90 deg, palm down
stat = readtable("class_data/statics/static_90_palm_down.csv");

%%
t = stat.Time;

figure; plot(t, stat.aX1)
hold on; plot(t, stat.aY1)
hold on; plot(t, stat.aZ1)
hold on; plot(t, stat.gX1)
hold on; plot(t, stat.gY1)
hold on; plot(t, stat.gZ1)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Wrist IMU - Grip Open/Close');

figure; plot(t, stat.aX2)
hold on; plot(t, stat.aY2)
hold on; plot(t, stat.aZ2)
hold on; plot(t, stat.gX2)
hold on; plot(t, stat.gY2)
hold on; plot(t, stat.gZ2)
legend('ax', 'ay', 'az', 'gx', 'gy', 'gz');
title('Bicep IMU - Grip Open/Close');

